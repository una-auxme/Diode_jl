#
# Copyright (c) 2026 Robert Weber,Leo Germer, Andreas Hofmann and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

import re

from ..models import TranslationData
from ..transforms.event_analysis import (
    build_p_init_expressions,
    extract_state_event_time_conditions,
    extract_state_event_trigger,
)
from ..transforms.text_utils import (
    comparison_to_root,
    extract_event_time,
    extract_parameter_numbers,
    insert_integrator,
    replace_der,
    replace_du_brackets,
    resolve_init_expression,
    wrap_matches_once,
)


def write_section_header(file, title: str) -> None:
    file.write("\n# ---------------------------------------\n")
    file.write(f"# {title}\n")
    file.write("# ---------------------------------------\n")


def write_callback_settings(file) -> None:
    file.write(
        """
Base.@kwdef mutable struct CallbackSettings
    repeat_nudge = 1//100
    reltol::Float64 = 1e-8
    abstol::Float64 = 1e-10
    interp_points::Int = 10
end

const DEFAULT_CB_SETTINGS = CallbackSettings()
"""
    )


def write_imports(file) -> None:
    write_section_header(file, "Imports")
    file.write(
        """using NonlinearSolve
using DifferentialEquations
using ForwardDiff
using DataFrames
"""
    )


def write_simulation_config(file, data: TranslationData) -> None:
    log_datatypes = {0: "Float64", 1: "Bool", 2: "Int64"}

    write_section_header(file, "SimulationConfig")
    file.write("@kwdef mutable struct SimulationConfig\n")
    for _, line in data.variables_df[
        data.variables_df["Category of variable"].isin(["parameter", "input"])
    ].iterrows():
        name = line["Name"].replace(".", "_")
        name = replace_der(name)
        name = wrap_matches_once(name, data.non_state_der_or_vec, 'var"', '"')
        value = line["fixed, free or desired"]
        mask = int(line["Data type of variable"]) & 3
        file.write(f"\t{name}::{log_datatypes[mask]} = {value}\n")
    file.write("end\n")


def write_nonlinear_guess_storage(file, data: TranslationData) -> None:
    if not data.nonlinear_guess_initials:
        return

    write_section_header(file, "Nonlinear Guess Storage")
    for number, init_vals in sorted(data.nonlinear_guess_initials.items()):
        init_vec = "[" + ", ".join(init_vals) + "]"
        file.write(f"\nconst NONLINEAR_GUESS_{number} = Ref({init_vec})\n")

    file.write("\n@inline function reset_nonlinear_guesses!()\n")
    for number, init_vals in sorted(data.nonlinear_guess_initials.items()):
        init_vec = "[" + ", ".join(init_vals) + "]"
        file.write(f"\tNONLINEAR_GUESS_{number}[] = {init_vec}\n")
    file.write("\treturn nothing\nend\n")


def write_main_ode_function(file, data: TranslationData) -> None:
    write_section_header(file, "Main ODE Function")
    file.write("@inline function Generated_Circuit!(du, u, p, t)\n")
    for n, state in enumerate(data.state_variables):
        file.write(f"\t# u[{n + 1}] = {state}\n")
    for n, der in enumerate(data.derivatives):
        file.write(f"\t# du[{n + 1}] = {der}\n")
    for parameter, sub in data.parameter_callbacks.items():
        file.write(f"\t# {sub} = {parameter}\n")

    file.write("\n\t@inbounds begin\n\t@fastmath begin\n")
    for eq in data.equations_all:
        if eq.startswith("//"):
            continue
        lhs = eq.split("=", 1)[0].strip()
        if lhs.startswith("p["):
            continue
        file.write(f"\t{eq}\n")
    file.write("\tend\n\tend\n")
    file.write("\treturn du\n")
    file.write("end\n")


def write_initialization(file, data: TranslationData) -> None:
    write_section_header(file, "Initialization")
    file.write("\n@inline function init_bound()\n")
    for eq in data.initial_section + data.equations_bound:
        file.write(f"\t{eq}\n")
    file.write("\treturn nothing\n")
    file.write("end\n")


def write_parameter_initialization(file, data: TranslationData) -> None:
    write_section_header(file, "Parameter Initialization")
    n_p = max(
        int(re.search(r"\d+", v).group(0)) for v in data.parameter_callbacks.values()
    )
    t0 = data.simulations_settings["StartTime"]
    init_expr = build_p_init_expressions(data.parameter_callbacks, t0, data.subs)

    file.write("\n@inline function p_vec()\n")
    file.write(f"\tt0 = {t0}\n")
    file.write(f"\tp = Vector{{Union{{Float64,Bool,Int64}}}}(undef, {n_p})\n")
    for i in range(1, n_p + 1):
        expr = init_expr.get(i, "false")
        file.write(f"\tp[{i}] = {expr}\n")
    file.write("\treturn p\n")
    file.write("end\n")


def write_state_initialization(file, data: TranslationData) -> None:
    write_section_header(file, "State Initialization")
    state_rows = data.variables_df[data.variables_df["Category of variable"] == "state"]
    state_init_vals = ", ".join(
        str(v) for v in state_rows["fixed, free or desired"].tolist()
    )

    file.write("\n@inline function u0_vec()\n")
    file.write(f"\treturn [{state_init_vals}]\n")
    file.write("end\n")


def write_time_span(file, data: TranslationData) -> None:
    write_section_header(file, "Time Span")
    file.write("\n@inline function tspan()\n")
    file.write(
        f"\treturn ({data.simulations_settings['StartTime']}, {data.simulations_settings['StopTime']})\n"
    )
    file.write("end\n")


def _write_state_event_followups(file, lhs, base_key, data: TranslationData) -> None:
    for nr, event in enumerate(data.state_events):
        _, rhs = extract_parameter_numbers("\n".join(event))
        if rhs & lhs:
            if data.order_time_events[event[0]] > data.order_time_events[base_key]:
                file.write(f"\taffect{nr + 1}!(integrator)\n")

    for nr, event in enumerate(data.state_time_events):
        equations = "\n".join(event["Equation"])
        equation = f"{event['parameter']} = {equations}"
        _, rhs = extract_parameter_numbers(equation)
        if rhs & lhs:
            if (
                data.order_time_events[event["Equation"][0]]
                > data.order_time_events[base_key]
            ):
                file.write(f"\taffect_state_time{nr + 1}!(integrator)\n")


def write_time_events(file, data: TranslationData) -> None:
    if not data.time_events_conditions:
        return

    write_section_header(file, "Time Events")
    for n, (k, v) in enumerate(data.time_events_conditions.items()):
        event_time = extract_event_time(insert_integrator(k)).replace(" ", "")
        file.write(
            f"\n@inline function event_times{n + 1}()\n\treturn [{event_time}]\nend\n"
        )
        file.write(
            f"@inline function affect_time_event{n + 1}!(integrator)\n"
            "\tu=integrator.u\n\tt=integrator.t\n\tdu=zeros(length(u))\n"
        )
        file.write(f"\tintegrator.{v}={insert_integrator(k)}\n")

        lhs = extract_parameter_numbers(f"{v}={insert_integrator(k)}")[0]
        _write_state_event_followups(file, lhs, k, data)

        file.write(
            "\tpush!(parameter_timeline,Parameters_and_Time(t,copy(integrator.p)))\n"
        )
        file.write("end\n")
        file.write(
            f"@inline function initialize_time_event{n + 1}!(c,u,t,integrator)\n"
        )
        file.write(f"\taffect_time_event{n + 1}!(integrator)\n")
        file.write("end\n")


def write_continuous_state_events(file, data: TranslationData) -> None:
    if not any(k == "continuous" for k in data.state_event_kinds):
        return

    write_section_header(file, "Continuous State Events")

    for n, line in enumerate(data.state_events):
        if data.state_event_kinds[n] != "continuous":
            continue

        buffer = extract_state_event_trigger(line)
        trigger_expr = resolve_init_expression(buffer, data.subs)
        root_expr = comparison_to_root(trigger_expr)

        file.write(f"\n@inline function condition{n + 1}(u,t,integrator)\n")
        file.write("\tp=integrator.p\n")
        file.write("\tdu=zeros(length(u))\n")
        file.write("\t@inbounds begin\n\t@fastmath begin\n")
        for eq in reversed(line[1:]):
            file.write(f"\t{eq}\n")
        file.write("\tend\n\tend\n")

        if root_expr is not None:
            file.write(f"\treturn {root_expr}\n")
        else:
            file.write(f"\tZerocrossing = {buffer}\n")
            file.write("\treturn Zerocrossing ? 1 : -1\n")
        file.write("end\n")

        file.write(f"@inline function affect{n + 1}!(integrator)\n")
        file.write("\tu=integrator.u\n")
        file.write("\tt=integrator.t\n")
        file.write("\tp=integrator.p\n")
        for eqs in reversed(line):
            for eq in eqs.split("\n"):
                eq = eq.strip()
                if eq:
                    file.write(f"\t{eq}\n")
        file.write(
            "\tpush!(parameter_timeline,Parameters_and_Time(t,copy(integrator.p)))\n"
        )

        lhs = extract_parameter_numbers("\n".join(line))[0]
        _write_state_event_followups(file, lhs, line[0], data)

        file.write("end\n")
        file.write(f"@inline function initialize{n + 1}!(c,u,t,integrator)\n")
        file.write(f"\taffect{n + 1}!(integrator)\n")
        file.write("end\n")


def write_discrete_state_events(file, data: TranslationData) -> None:
    if not any(k == "discrete" for k in data.state_event_kinds):
        return

    write_section_header(file, "Discrete State Events")

    for n, line in enumerate(data.state_events):
        if data.state_event_kinds[n] != "discrete":
            continue

        buffer = extract_state_event_trigger(line)

        file.write(f"\n@inline function condition_discrete{n + 1}(u,t,integrator)\n")
        file.write("\tp=integrator.p\n")
        file.write("\tdu=zeros(length(u))\n")
        file.write("\t@inbounds begin\n\t@fastmath begin\n")
        for eq in reversed(line[1:]):
            file.write(f"\t{eq}\n")
        file.write("\tend\n\tend\n")
        file.write(f"\treturn {buffer}\n")
        file.write("end\n")

        file.write(f"@inline function affect{n + 1}!(integrator)\n")
        file.write("\tu=integrator.u\n")
        file.write("\tt=integrator.t\n")
        file.write("\tp=integrator.p\n")
        for eqs in reversed(line):
            for eq in eqs.split("\n"):
                eq = eq.strip()
                if eq:
                    file.write(f"\t{eq}\n")
        file.write(
            "\tpush!(parameter_timeline,Parameters_and_Time(t,copy(integrator.p)))\n"
        )

        lhs = extract_parameter_numbers("\n".join(line))[0]
        _write_state_event_followups(file, lhs, line[0], data)

        file.write("end\n")
        file.write(f"@inline function initialize{n + 1}!(c,u,t,integrator)\n")
        file.write(f"\taffect{n + 1}!(integrator)\n")
        file.write("end\n")


def write_preset_time_state_events(file, data: TranslationData) -> None:
    if not any(k == "preset_time" for k in data.state_event_kinds):
        return

    write_section_header(file, "Preset-Time State Events")

    for n, line in enumerate(data.state_events):
        if data.state_event_kinds[n] != "preset_time":
            continue

        time_conditions = extract_state_event_time_conditions(
            line, data.subs, data.subs_eq
        )
        event_times = []
        for cond in time_conditions:
            expr = extract_event_time(cond).strip()
            expr = resolve_init_expression(expr, data.subs)
            expr = expr.replace(" ", "")

            if (
                "u[" in expr
                or "du[" in expr
                or "p[" in expr
                or re.search(r"\bt\b", expr)
            ):
                raise RuntimeError(
                    f"State event {n + 1} was classified as preset-time, but its event time is not fixed: {expr}"
                )
            event_times.append(expr)

        if not event_times:
            raise RuntimeError(
                f"Could not extract preset times for State event {n + 1}"
            )

        file.write(f"\n@inline function event_times_state{n + 1}()\n")
        file.write(f"\treturn [{', '.join(event_times)}]\n")
        file.write("end\n")

        file.write(f"@inline function affect{n + 1}!(integrator)\n")
        file.write("\tu=integrator.u\n")
        file.write("\tt=integrator.t\n")
        file.write("\tp=integrator.p\n")

        for eqs in reversed(line):
            for eq in eqs.split("\n"):
                eq = eq.strip()
                if eq:
                    file.write(f"\t{eq}\n")

        for linked_st_event in data.preset_time_state_links.get(n, []):
            for eqs in reversed(linked_st_event["Equation"][1:]):
                for eq in eqs.split("\n"):
                    eq = eq.strip()
                    if eq:
                        file.write(f"\t{eq}\n")
            file.write(
                f"\t{linked_st_event['parameter']} = {linked_st_event['Equation'][0]}\n"
            )

        file.write(
            "\tpush!(parameter_timeline,Parameters_and_Time(t,copy(integrator.p)))\n"
        )

        lhs = extract_parameter_numbers("\n".join(line))[0]
        _write_state_event_followups(file, lhs, line[0], data)

        file.write("end\n")
        file.write(f"@inline function initialize{n + 1}!(c,u,t,integrator)\n")
        file.write("\tnothing\n")
        file.write("end\n")


def write_state_time_events(file, data: TranslationData) -> None:
    if not data.state_time_events:
        return

    write_section_header(file, "State-Time Events")

    for n, event in enumerate(data.state_time_events):
        file.write(f"\n@inline function condition_state_time{n + 1}(u,t,integrator)\n")
        file.write("\tp=integrator.p\n\tdu=zeros(length(u))\n")
        file.write("\t@inbounds begin\n\t@fastmath begin\n")
        for eq in reversed(event["Zerocrossing"][1:]):
            file.write(f"\t{eq}\n")
        file.write("\tend\n\tend\n")
        file.write(f"\treturn {event['Zerocrossing'][0]}\n")
        file.write("end\n")

        file.write(f"@inline function affect_state_time{n + 1}!(integrator)\n")
        file.write("\tu=integrator.u\n\tt=integrator.t\n\tp=integrator.p\n")
        for eqs in reversed(event["Equation"][1:]):
            for eq in eqs.split("\n"):
                file.write(f"\t{eq}\n")
        file.write(f"\tintegrator.{event['parameter']} = {event['Equation'][0]}\n")
        file.write(
            "\tpush!(parameter_timeline,Parameters_and_Time(t,copy(integrator.p)))\n"
        )

        equations = "\n".join(event["Equation"])
        lhs = extract_parameter_numbers(f"{event['parameter']} = {equations}")[0]
        _write_state_event_followups(file, lhs, event["Equation"][0], data)

        file.write("end\n")
        file.write(
            f"@inline function initialize_state_time{n + 1}!(c,u,t,integrator)\n"
        )
        file.write(f"\taffect_state_time{n + 1}!(integrator)\n")
        file.write("end\n")


def write_callback_generation(file, data: TranslationData) -> None:
    write_section_header(file, "Callback Generation")
    file.write(
        "\nfunction generate_Callbacks(cb_settings::CallbackSettings=DEFAULT_CB_SETTINGS)"
    )

    for n, _line in enumerate(data.state_events):
        kind = data.state_event_kinds[n]
        if kind == "continuous":
            file.write(
                f"\n\tstate_event{n + 1} = ContinuousCallback("
                f"condition{n + 1}, affect{n + 1}!, initialize = initialize{n + 1}!,\n"
                f"\t\trepeat_nudge=cb_settings.repeat_nudge,"
                f"reltol=cb_settings.reltol,"
                f"abstol=cb_settings.abstol,"
                f"rootfind=SciMLBase.RightRootFind,"
                f"interp_points=cb_settings.interp_points)"
            )
        elif kind == "preset_time":
            file.write(
                f"\n\tstate_event{n + 1} = PresetTimeCallback("
                f"event_times_state{n + 1}(), affect{n + 1}!, initialize = initialize{n + 1}!)"
            )
        elif kind == "discrete":
            file.write(
                f"\n\tstate_event{n + 1} = DiscreteCallback("
                f"condition_discrete{n + 1}, affect{n + 1}!, initialize = initialize{n + 1}!, save_positions=(true,true))"
            )

    for n, _line in enumerate(data.state_time_events):
        file.write(
            f"\n\tstate_time_event{n + 1} = ContinuousCallback("
            f"condition_state_time{n + 1}, affect_state_time{n + 1}!, initialize = initialize_state_time{n + 1}!,\n"
            f"\t\trepeat_nudge=cb_settings.repeat_nudge,reltol=cb_settings.reltol,abstol=cb_settings.abstol,rootfind=SciMLBase.RightRootFind,interp_points=cb_settings.interp_points)"
        )

    for n, _line in enumerate(data.time_events_conditions):
        file.write(
            f"\n\ttime_event{n + 1} = PresetTimeCallback(event_times{n + 1}(), affect_time_event{n + 1}!, initialize = initialize_time_event{n + 1}!)"
        )

    buffer = [f"state_event{n + 1}" for n in range(len(data.state_events))]
    buffer += [f"state_time_event{n + 1}" for n in range(len(data.state_time_events))]
    buffer += [f"time_event{n + 1}" for n in range(len(data.time_events_conditions))]

    if buffer:
        file.write(f"\n\tcallbacks = CallbackSet({', '.join(buffer)})\n")
        file.write("\treturn callbacks\n")
    else:
        file.write("\treturn nothing\n")

    file.write("end\n")


def write_parameter_timeline(file) -> None:
    write_section_header(file, "Parameter Timeline")
    file.write(
        """
struct Parameters_and_Time
    time::Float64
    parameters::Vector{Union{Float64,Bool,Int64}}
end

global parameter_timeline=Vector{Parameters_and_Time}()

"""
    )


def write_post_processing(file, data: TranslationData) -> None:
    write_section_header(file, "Post Processing")
    file.write(
        "\nfunction post_process(solution::ODESolution, parameter_timeline::Vector{Parameters_and_Time})\n"
    )
    if data.nonlinear_guess_initials:
        file.write("\treset_nonlinear_guesses!()\n")
    file.write("\tdf = DataFrame(time=solution.t")

    nogo = False
    for eq in data.equations_post_core:
        if eq.startswith("p["):
            continue
        elif eq.startswith("// Start Linear System"):
            nogo = True
            continue
        elif eq.startswith("// End Linear System") and nogo:
            nogo = False
            continue
        elif eq.startswith("nonlineareq(u0,p) = begin"):
            nogo = True
            continue
        elif " = sol.u" in eq and nogo:
            nogo = False
        elif eq.startswith("//"):
            continue

        if nogo and " = x" in eq:
            for var in eq.split("=")[0].split(","):
                var = replace_du_brackets(var.strip())
                file.write(f",\n\t{var}=Vector{{Float64}}(undef, length(solution.t))")

        if not nogo:
            var = replace_du_brackets(eq.split("=", 1)[0].strip())
            file.write(f",\n\t{var}=Vector{{Float64}}(undef, length(solution.t))")

    for eq in data.equations_post_conditional:
        if eq.startswith("//") or eq.startswith("p[") or "=" not in eq:
            continue
        var = replace_du_brackets(eq.split("=", 1)[0].strip())
        file.write(f",\n\t{var}=Vector{{Float64}}(undef, length(solution.t))")

    for eq in data.equations_post_alias:
        if eq.startswith("//") or eq.startswith("p[") or "=" not in eq:
            continue
        var = replace_du_brackets(eq.split("=", 1)[0].strip())
        file.write(f",\n\t{var}=Vector{{Float64}}(undef, length(solution.t))")

    file.write(")\n")
    file.write(
        """
	counter::Int=1
	if length(parameter_timeline)>0
		p=parameter_timeline[counter].parameters
	else
		p=[]
	end

	@inbounds begin
	@fastmath begin
	for i in 1:length(solution.t)
		t = solution.t[i]
		u = solution.u[i]
		if counter<length(parameter_timeline)
			while parameter_timeline[counter+1].time<=t
				counter = counter+1
				p = parameter_timeline[counter].parameters
				if counter>=length(parameter_timeline)
					break
				end
			end
		end
"""
    )

    for eq in data.equations_post_core:
        if eq.startswith("//"):
            continue
        file.write(f"\t\t{replace_du_brackets(eq)}\n")

    for eq in data.equations_post_conditional:
        if eq.startswith("//") or eq.startswith("p[") or "=" not in eq:
            continue
        file.write(f"\t\t{replace_du_brackets(eq)}\n")

    for eq in data.equations_post_alias:
        if eq.startswith("//") or eq.startswith("p[") or "=" not in eq:
            continue
        file.write(f"\t\t{replace_du_brackets(eq)}\n")

    nogo = False
    for eq in data.equations_post_core:
        if eq.startswith("p["):
            continue
        if eq.startswith("// Start Linear System"):
            nogo = True
            continue
        elif eq.startswith("// End Linear System") and nogo:
            nogo = False
            continue
        elif eq.startswith("nonlineareq(u0,p) = begin"):
            nogo = True
            continue
        elif " = sol.u" in eq and nogo:
            nogo = False
        elif eq.startswith("//"):
            continue

        if nogo and " = x" in eq:
            for var in eq.split("=")[0].split(","):
                var = replace_du_brackets(var.strip())
                file.write(f"\t\tdf.{var}[i] = {var}\n")

        if not nogo:
            var = replace_du_brackets(eq.split("=", 1)[0].strip())
            file.write(f"\t\tdf.{var}[i] = {var}\n")

    for eq in data.equations_post_conditional:
        if eq.startswith("//") or eq.startswith("p[") or "=" not in eq:
            continue
        var = replace_du_brackets(eq.split("=", 1)[0].strip())
        file.write(f"\t\tdf.{var}[i] = {var}\n")

    for eq in data.equations_post_alias:
        if eq.startswith("//") or eq.startswith("p[") or "=" not in eq:
            continue
        var = replace_du_brackets(eq.split("=", 1)[0].strip())
        file.write(f"\t\tdf.{var}[i] = {var}\n")

    file.write("\tend\n\tend\n\tend\n\treturn df\nend\n")


def write_solver_entry_point(file, data: TranslationData) -> None:
    write_section_header(file, "Solver Entry Point")
    file.write(
        "\nfunction solving_ode(alg=nothing, cb_settings::CallbackSettings=DEFAULT_CB_SETTINGS)\n"
    )
    file.write("\talg = isnothing(alg) ? RadauIIA5(autodiff=false) : alg\n")
    file.write("\tglobal par=SimulationConfig()\n")
    file.write("\tp = p_vec()\n")
    file.write("\tu0 = u0_vec()\n")
    file.write("\ttime_span = tspan()\n")
    file.write("\tinit_bound()\n")
    if data.nonlinear_guess_initials:
        file.write("\treset_nonlinear_guesses!()\n")
    file.write("\tprob = ODEProblem(Generated_Circuit!, u0, time_span::Tuple, p)\n")
    file.write("\tcbs = generate_Callbacks(cb_settings)\n")
    file.write(
        "\tif isnothing(cbs)\n\t\tsol = solve(prob, alg=alg)\n\telse\n\t\tsol = solve(prob, alg=alg, callback=cbs)\n\tend\n"
    )
    file.write("\treturn sol\n")
    file.write("end\n")
