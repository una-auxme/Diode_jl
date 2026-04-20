#
# Copyright (c) 2026 Robert Weber,Leo Germer, Andreas Hofmann and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

import re
from typing import Dict, List

from ordered_set import OrderedSet

from .text_utils import (
    conditional_substitute,
    extract_time_events,
    find_keys,
    resolve_init_expression,
)


def callback_parameter_state_events(State_events: List[str]) -> Dict[str, str]:
    callack_para = {}
    n = 1
    for event in State_events:
        if event.startswith("when"):
            continue
        callack_para[event.split(" :=")[0].replace(".", "_")] = f"p[{n}]"
        n += 1
    return callack_para


def callback_parameter_equations(Equations: List[str], parameterdict: Dict[str, str]) -> None:
    def find_pre_occurrences(text):
        pattern = r"(?<![A-Za-z0-9_])pre\((.*?)\)"
        return re.findall(pattern, text)

    for eq in Equations:
        if var := find_pre_occurrences(eq):
            n = len(parameterdict) + 1
            if f"pre({var[0].replace('.', '_')})" not in parameterdict:
                if var[0].replace(".", "_") in parameterdict:
                    value = parameterdict[f"{var[0].replace('.', '_')}"]
                    parameterdict[f"pre({var[0].replace('.', '_')})"] = value
                    parameterdict[f"{var[0].replace('.', '_')}"] = value
                else:
                    parameterdict[f"pre({var[0].replace('.', '_')})"] = f"p[{n}]"
                    parameterdict[f"{var[0].replace('.', '_')}"] = f"p[{n}]"


def restructure_whenstatments(statements: List[str], parameter_callbacks: Dict[str, str]) -> None:
    replacements = {}
    for k, v in parameter_callbacks.items():
        if str(k).startswith("pre("):
            replacements[k[4:-1]] = v
    replacements.update({"when": "if", "elsewhen": "elseif", "end when": "end", "?": "\n\t"})
    for i, eq in enumerate(statements):
        if eq.strip().startswith("when"):
            eq = conditional_substitute(eq, replacements)
            statements[i] = eq


def insert_calculated_variabels_for_State_events(State_events: List[str], subs: Dict, subs_eq: Dict):
    for n, event in enumerate(State_events):
        res = find_keys(event, subs)
        buffer = OrderedSet(res)
        counter = 0
        while res != []:
            keys = []
            for key in res:
                result = find_keys(subs[key], subs)
                keys.extend(result)
            res = keys
            for key in keys:
                if key in buffer:
                    buffer.discard(key)
                buffer.add(key)
            counter += 1
            if counter > 1000:
                raise RuntimeError("Equations could not be matched")

        temp = [event]
        seen = set()
        for key in buffer:
            if key in subs_eq and subs_eq[key] not in seen:
                temp.append(subs_eq[key])
                seen.add(subs_eq[key])

        State_events[n] = temp.copy()
    return State_events


def remove_non_compiled_time_events(Time_events: Dict[str, str]) -> Dict[str, str]:
    def check_variables(s: str) -> bool:
        pattern = r"^t\s*(?:<|>|<=|>=|==|!=)\s*(?:par\.[A-Za-z_]\w*(?:\s*\+\s*par\.[A-Za-z_]\w*)*)\s*$"
        return bool(re.match(pattern, s))

    uncompiled_time_events = {k: v for k, v in Time_events.items() if not check_variables(k)}
    compiled_time_events = {k: v for k, v in Time_events.items() if check_variables(k)}
    Time_events.clear()
    Time_events.update(compiled_time_events)
    return uncompiled_time_events


def bool_to_zero_crossing(expressions: List[str]) -> List[str]:
    converted_expressions = []
    pattern = re.compile(r"^\s*t\s*([<>]=?)\s*(.+)$")

    for expr in expressions:
        match = pattern.match(expr)
        if match:
            operator = match.group(1).strip()
            rhs_expr = match.group(2).strip()

            if operator in ("<", "<="):
                zero_cross_expr = f"({rhs_expr}) - t"
            elif operator in (">", ">="):
                zero_cross_expr = f"t - ({rhs_expr})"
            else:
                zero_cross_expr = expr
            converted_expressions.append(zero_cross_expr)
        else:
            converted_expressions.append(expr)

    return converted_expressions


def parameter_from_when(State_events: List[str], parameter_callbacks: Dict[str, str]) -> None:
    for eqs in State_events:
        if eqs.strip().startswith("when"):
            for eq in eqs.split("\n"):
                vars = eq.split(" := ")
                if len(vars) > 1:
                    varname = vars[0].split()[-1].replace(".", "_")
                    if varname not in parameter_callbacks:
                        parameter_callbacks[varname] = f"p[{len(parameter_callbacks) + 1}]"


def build_p_init_expressions(
    parameter_callbacks: Dict[str, str],
    start_time: str,
    subs: Dict[str, str],
) -> Dict[int, str]:
    init_expr = {}

    for key, slot in parameter_callbacks.items():
        if not isinstance(key, str):
            continue

        idx = int(re.search(r"\d+", slot).group(0))

        if key.endswith("_t1") or "startOfSwitchingTime" in key:
            init_expr[idx] = str(start_time)
        elif re.match(r"^\s*t\s*(?:<|<=|>|>=|==|!=)\s*", key):
            expr = resolve_init_expression(key, subs)
            expr = re.sub(r"^\s*t\b", f"({start_time})", expr)
            init_expr[idx] = expr
        else:
            init_expr[idx] = "false"

    return init_expr


def extract_state_event_trigger(event_lines: List[str]) -> str:
    first = event_lines[0].strip()
    first = first.split("\n", 1)[0].strip()

    if first.startswith("if "):
        return first[3:].strip()

    if first.startswith("when "):
        return first[5:].strip()

    if " = " in first:
        return first.split(" = ", 1)[1].strip()

    return first


def collect_trigger_dependency_lines(trigger: str, subs: Dict[str, str], subs_eq: Dict[str, str]) -> List[str]:
    res = find_keys(trigger, subs)
    buffer = OrderedSet(res)

    counter = 0
    while res != []:
        keys = []
        for key in res:
            result = find_keys(subs[key], subs)
            keys.extend(result)
        res = keys
        for key in keys:
            if key in buffer:
                buffer.discard(key)
            buffer.add(key)
        counter += 1
        if counter > 1000:
            raise RuntimeError("Trigger dependencies could not be resolved")

    lines = []
    seen = set()
    for key in buffer:
        if key in subs_eq and subs_eq[key] not in seen:
            lines.append(subs_eq[key])
            seen.add(subs_eq[key])

    return lines


def extract_state_event_time_conditions(event_lines: List[str], subs: Dict[str, str], subs_eq: Dict[str, str]) -> List[str]:
    trigger = extract_state_event_trigger(event_lines)
    dep_lines = collect_trigger_dependency_lines(trigger, subs, subs_eq)

    conditions = []
    for line in [trigger] + dep_lines:
        for cond in extract_time_events(line):
            cond = cond.replace("?", "").strip()
            if cond not in conditions:
                conditions.append(cond)
    return conditions


def has_continuous_dependency(event_lines: List[str], subs: Dict[str, str], subs_eq: Dict[str, str]) -> bool:
    trigger = extract_state_event_trigger(event_lines)
    dep_lines = collect_trigger_dependency_lines(trigger, subs, subs_eq)
    text = trigger + "\n" + "\n".join(dep_lines)
    return ("u[" in text) or ("du[" in text)


def classify_state_event(event_lines: List[str], subs: Dict[str, str], subs_eq: Dict[str, str]) -> str:
    if has_continuous_dependency(event_lines, subs, subs_eq):
        return "continuous"

    time_conds = extract_state_event_time_conditions(event_lines, subs, subs_eq)
    if time_conds:
        return "preset_time"

    return "discrete"