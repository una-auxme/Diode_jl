#
# Copyright (c) 2026 Robert Weber,Leo Germer, Andreas Hofmann and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

import os
import sys
from functools import partial

import questionary

from .cli import get_generated_files_dir, prompt_for_time_settings, resolve_dataset_path
from .generators.julia_writer import write_julia_model
from .logging_utils import log_error, log_info, log_ok, log_step, log_warn
from .models import TranslationData
from .parsers import Read_dsfinal as dsfinal
from .parsers import Read_Mof as Mof
from .transforms.equation_rewriter import reformat_Derivatives, reformat_Equations
from .transforms.event_analysis import (
    bool_to_zero_crossing,
    callback_parameter_equations,
    callback_parameter_state_events,
    classify_state_event,
    extract_state_event_time_conditions,
    insert_calculated_variabels_for_State_events,
    parameter_from_when,
    remove_non_compiled_time_events,
    restructure_whenstatments,
)
from .transforms.system_translation import (
    Transform_structure_between_tags,
    translate_linear_system_of_equations,
    translate_nonlinear_system_of_equations,
)
from .transforms.text_utils import (
    extract_lhs_vars,
    extract_time_events,
    filter_valid_assignments,
)


def _has_usable_time_span(settings: dict) -> bool:
    try:
        return float(settings["StopTime"]) > float(settings["StartTime"])
    except (KeyError, TypeError, ValueError):
        return False


def _stop_time_from_dsfinal(path: str, start_time: float) -> float | None:
    if "dsfinal.txt" not in os.listdir(path):
        return None
    try:
        fallback = dsfinal.extract_simulations_Settings(f"{path}/dsfinal.txt")
        stop_time = float(fallback["StopTime"])
    except (KeyError, TypeError, ValueError, OSError):
        return None
    return stop_time if stop_time > start_time else None


def read_simulation_settings_and_variable_table(path: str):
    simulations_Settings = {}

    if "dsin.txt" in os.listdir(path):
        log_info("Trying to read dsin.txt")
        try:
            Variabels_df = dsfinal.read_and_process_file(f"{path}/dsin.txt")
            simulations_Settings = dsfinal.extract_simulations_Settings(
                f"{path}/dsin.txt"
            )
            log_ok("Successfully read dsin.txt")
        except ValueError:
            log_warn("Could not read dsin.txt. Falling back to dsfinal.txt")

    if simulations_Settings == {}:
        log_info("Trying to read dsfinal.txt")
        try:
            Variabels_df = dsfinal.read_and_process_file(f"{path}/dsfinal.txt")
            simulations_Settings = dsfinal.extract_simulations_Settings(
                f"{path}/dsfinal.txt"
            )
            log_ok("Successfully read dsfinal.txt")
        except ValueError:
            log_error("No data could be read from 'dsfinal.txt'.")
            sys.exit()

        print(
            "INFO - The file 'dsin.txt' could not be found in the selected path. It usually contains the simulation time settings. "
            "As a fallback, the time settings can be read from 'dsfinal.txt', but these values are often inaccurate."
        )
        if not questionary.confirm(
            "Should the simulation time settings be taken from 'dsfinal.txt'?"
        ).ask():
            simulations_Settings = prompt_for_time_settings()

    # dsin.txt carries StopTime 0 when the model has no experiment annotation.
    # Take the StopTime from dsfinal.txt instead - never its StartTime, which
    # describes a continuation window and would not match the initial values.
    if simulations_Settings and not _has_usable_time_span(simulations_Settings):
        stop_time = _stop_time_from_dsfinal(
            path, float(simulations_Settings["StartTime"])
        )
        if stop_time is not None:
            simulations_Settings["StopTime"] = stop_time

    return Variabels_df, simulations_Settings


def read_model_sections(data: TranslationData) -> None:
    log_step("Reading dsmodel.mof sections")
    try:
        (
            data.equations_dynamic,
            data.state_events,
            data.time_events,
            data.order_events,
        ) = Mof.read_mof(f"{data.path}/dsmodel.mof")
        data.initial_section = Mof.read_mof(
            f"{data.path}/dsmodel.mof",
            "// Initial Section",
            "// -----------------------------------------------------------------------------",
        )[0]
        log_ok("Successfully read dynamic and initial sections from dsmodel.mof")
    except UnboundLocalError:
        log_error("No data could be read from 'dsmodel.mof'.")
        log_error("The model could not be translated. Please report this error.")
        sys.exit(-1)

    try:
        data.equations_bound = Mof.read_mof(
            f"{data.path}/dsmodel.mof", "// Bound Parameter Section"
        )[0]
        data.equations_bound = [
            eq for eq in data.equations_bound if not eq.startswith("assert")
        ]
        log_ok(f"Bound parameter equations read: {len(data.equations_bound)}")
    except UnboundLocalError:
        data.equations_bound = []
        log_info("No bound parameter section found in dsmodel.mof")

    try:
        data.equations_conditional = Mof.read_conditional_equations(
            f"{data.path}/dsmodel.mof"
        )
        log_ok(f"Conditional equations read: {len(data.equations_conditional)}")
    except UnboundLocalError:
        data.equations_conditional = []
        log_info("No conditional equations found in dsmodel.mof")

    try:
        data.equations_alias = Mof.read_alias_equations(f"{data.path}/dsmodel.mof")
        log_ok(f"Alias equations read: {len(data.equations_alias)}")
    except UnboundLocalError:
        data.equations_alias = []
        log_info("No alias equations found in dsmodel.mof")


def prepare_translation_structures(data: TranslationData) -> None:
    log_step("Preparing translation structures")

    data.state_variables = (
        data.variables_df[data.variables_df["Category of variable"] == "state"]
    )["Name"].tolist()
    data.derivatives = (
        data.variables_df[
            data.variables_df["Category of variable"] == "state derivative"
        ]
    )["Name"].tolist()
    data.parameters_struct = (
        data.variables_df[
            data.variables_df["Category of variable"].isin(["parameter", "input"])
        ]
    )["Name"].tolist()

    log_info(f"States found: {len(data.state_variables)}")
    log_info(f"State derivatives found: {len(data.derivatives)}")
    log_info(f"Parameters and inputs found: {len(data.parameters_struct)}")

    data.non_state_der_or_vec = extract_lhs_vars(
        data.equations_dynamic
        + data.equations_bound
        + [var + " :=  " for var in data.parameters_struct]
        + data.initial_section
    )
    data.non_state_der_or_vec = [
        var.replace(".", "_") for var in data.non_state_der_or_vec
    ]

    reformat_Derivatives(data.derivatives)

    data.parameter_callbacks = callback_parameter_state_events(data.state_events)
    parameter_from_when(data.state_events, data.parameter_callbacks)
    callback_parameter_equations(data.state_events, data.parameter_callbacks)
    callback_parameter_equations(data.equations_dynamic, data.parameter_callbacks)

    reformat_Equations(
        data.time_events,
        data.state_variables,
        data.parameters_struct,
        data.derivatives,
        data.non_state_der_or_vec,
        data.parameter_callbacks,
    )

    reformated = [event[1] for event in data.order_events]
    reformat_Equations(
        reformated,
        data.state_variables,
        data.parameters_struct,
        data.derivatives,
        data.non_state_der_or_vec,
        data.parameter_callbacks,
    )
    data.order_events = [
        [event[0], eq] for event, eq in zip(data.order_events, reformated)
    ]

    data.time_events_conditions = {
        event: f"p[{n + 1 + len(data.parameter_callbacks)}]"
        for n, event in enumerate(
            [
                item.replace("?", "").strip()
                for t in data.time_events
                for item in extract_time_events(t)
            ]
        )
    }

    data.order_time_events = {}
    for nr, t in data.order_events:
        eqs = extract_time_events(t)
        for eq in eqs:
            eq = eq.replace("?", "").strip()
            data.order_time_events[eq] = nr

    non_compiled_time_events = remove_non_compiled_time_events(
        data.time_events_conditions
    )
    data.state_time_events = [
        {"Zerocrossing": z, "Equation": k, "parameter": v}
        for z, (k, v) in zip(
            bool_to_zero_crossing(list(non_compiled_time_events.keys())),
            non_compiled_time_events.items(),
        )
    ]

    data.parameter_callbacks.update(data.time_events_conditions)
    data.parameter_callbacks.update(non_compiled_time_events)

    reformat_Equations(
        data.equations_dynamic,
        data.state_variables,
        data.parameters_struct,
        data.derivatives,
        data.non_state_der_or_vec,
        data.parameter_callbacks,
    )
    reformat_Equations(
        data.initial_section,
        data.state_variables,
        data.parameters_struct,
        data.derivatives,
        data.non_state_der_or_vec,
        data.parameter_callbacks,
    )
    data.initial_section = filter_valid_assignments(data.initial_section)
    reformat_Equations(
        data.equations_bound,
        data.state_variables,
        data.parameters_struct,
        data.derivatives,
        data.non_state_der_or_vec,
        data.parameter_callbacks,
    )
    reformat_Equations(
        data.equations_conditional,
        data.state_variables,
        data.parameters_struct,
        data.derivatives,
        data.non_state_der_or_vec,
        data.parameter_callbacks,
    )
    reformat_Equations(
        data.equations_alias,
        data.state_variables,
        data.parameters_struct,
        data.derivatives,
        data.non_state_der_or_vec,
        data.parameter_callbacks,
    )
    reformat_Equations(
        data.state_events,
        data.state_variables,
        data.parameters_struct,
        data.derivatives,
        data.non_state_der_or_vec,
        data.parameter_callbacks,
    )

    restructure_whenstatments(data.state_events, data.parameter_callbacks)
    restructure_whenstatments(reformated, data.parameter_callbacks)
    data.order_events = [
        [event[0], eq] for event, eq in zip(data.order_events, reformated)
    ]

    for nr, eq in data.order_events:
        if eq in data.state_events:
            data.order_time_events[eq] = nr


def translate_equation_systems(data: TranslationData) -> None:
    log_step("Translating linear and nonlinear equation systems")
    data.equations_dynamic = Transform_structure_between_tags(
        data.equations_dynamic,
        "##Linear",
        "##END Linear",
        translate_linear_system_of_equations,
    )
    data.equations_dynamic = Transform_structure_between_tags(
        data.equations_dynamic,
        "## Nonlinear system of equations",
        "##End nonlinear system of equations",
        partial(
            translate_nonlinear_system_of_equations,
            nonlinear_guess_initials=data.nonlinear_guess_initials,
        ),
    )
    log_ok("Equation system translation finished")

    data.equations_all = (
        data.initial_section
        + [var for var in data.equations_bound if not var.startswith("par.")]
        + data.equations_dynamic
    )
    data.equations_post_core = data.equations_all
    data.equations_post_conditional = data.equations_conditional
    data.equations_post_alias = data.equations_alias


def build_substitution_tables(data: TranslationData) -> None:
    equations_to_sub = data.equations_all + data.time_events
    data.subs = {}
    data.subs_eq = {}

    for eq in equations_to_sub:
        if eq.startswith("//"):
            continue
        buffer = eq.split(" = ")
        if len(buffer) > 1:
            for var in buffer[0].split(","):
                var = var.replace("{", "").replace("}", "").strip()
                data.subs[var] = "(" + "".join(buffer[1:]) + ")"
                data.subs_eq[var] = eq

    insert_calculated_variabels_for_State_events(
        data.state_events, data.subs, data.subs_eq
    )
    for eq in data.state_time_events:
        eq["Zerocrossing"] = insert_calculated_variabels_for_State_events(
            [eq["Zerocrossing"]], data.subs, data.subs_eq
        )[0]
        eq["Equation"] = insert_calculated_variabels_for_State_events(
            [eq["Equation"]], data.subs, data.subs_eq
        )[0]


def classify_and_link_events(data: TranslationData) -> None:
    data.state_event_kinds = [
        classify_state_event(ev, data.subs, data.subs_eq) for ev in data.state_events
    ]

    data.preset_time_state_links = {}
    filtered_state_time_events = []

    for st_event in data.state_time_events:
        st_cond = st_event["Equation"][0].replace(" ", "")
        matched = False

        for ev_idx, ev in enumerate(data.state_events):
            if data.state_event_kinds[ev_idx] != "preset_time":
                continue

            ev_conds = [
                c.replace(" ", "")
                for c in extract_state_event_time_conditions(
                    ev, data.subs, data.subs_eq
                )
            ]

            if st_cond in ev_conds:
                data.preset_time_state_links.setdefault(ev_idx, []).append(st_event)
                matched = True
                break

        if not matched:
            filtered_state_time_events.append(st_event)

    data.state_time_events = filtered_state_time_events

    log_step("Classifying events")
    log_info(
        "State/Time events: total="
        f"{len(data.state_events)}, "
        f"continuous={sum(k == 'continuous' for k in data.state_event_kinds)}, "
        f"fixed-time={sum(k == 'preset_time' for k in data.state_event_kinds)}, "
        f"discrete={sum(k == 'discrete' for k in data.state_event_kinds)}"
    )


def run_translation(output_file: str | None = None) -> TranslationData:
    log_step("Starting translator")

    data = TranslationData()
    data.path = resolve_dataset_path()

    log_step("Reading simulation settings and variable table")
    data.variables_df, data.simulations_settings = (
        read_simulation_settings_and_variable_table(data.path)
    )

    read_model_sections(data)
    prepare_translation_structures(data)
    translate_equation_systems(data)
    build_substitution_tables(data)
    classify_and_link_events(data)

    generated_dir = get_generated_files_dir()
    output_path = (
        generated_dir / "GeneratedModel.jl"
        if output_file is None
        else generated_dir / output_file
    )

    log_step(f"Writing Julia file {output_path}")
    write_julia_model(str(output_path), data)

    log_ok(
        f"Translation finished successfully. Julia file was written to: {output_path}"
    )
    return data
