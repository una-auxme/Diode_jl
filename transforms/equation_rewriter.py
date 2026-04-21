#
# Copyright (c) 2026 Robert Weber,Leo Germer, Andreas Hofmann and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#


from .text_utils import (
    conditional_substitute,
    extract_non_float_dots,
    remove_smooth,
    replace_der,
    replace_non_flaot_dotes,
    wrap_matches_once,
)


def reformat_Derivatives(derivatives: list[str]) -> None:
    for n, der in enumerate(derivatives):
        name = ".".join(der.split(".")[:-1])
        variable = der.split("(")[-1].split(")")[0]
        derivatives[n] = f"der({name}.{variable})"


def reformat_Equations(
    eqs: list[str],
    state_variables: list[str],
    parameters_struct: list[str],
    derivatives: list[str],
    non_state_der_or_vec: list[str],
    parameter_callbacks: dict[str, str],
) -> None:
    state_substi = {state: f"u[{i + 1}]" for i, state in enumerate(state_variables)}
    parametersubsti = {
        par.replace(".", "_"): f"par.{par.replace('.', '_')}"
        for par in parameters_struct
    }
    replacements = {
        "time": "t",
        "else": ":",
        "then": "?",
        "if": "",
        "not ": " !",
        "noEvent": "",
        "and": "&&",
        "or": "||",
        "integer(": "floor(Int,",
        "atan2": "atan",
        "{": "",
        "}": "",
    }

    for n, eq in enumerate(eqs):
        for i, der in enumerate(derivatives):
            eq = eq.replace(der.strip(), f"du[{i + 1}]")

        eq = conditional_substitute(eq, state_substi)
        eq = extract_non_float_dots(eq)
        eq = replace_non_flaot_dotes(eq)
        eq = conditional_substitute(eq, parametersubsti)
        eq = wrap_matches_once(eq, non_state_der_or_vec, 'var"', '"')
        eq = conditional_substitute(eq, replacements)
        eq = eq.replace(":=", "=")
        eq = replace_der(eq)
        eq = remove_smooth(eq)

        line_before = eq
        eq = conditional_substitute(eq, parameter_callbacks)
        while eq != line_before:
            line_before = eq
            eq = conditional_substitute(eq, parameter_callbacks)

        eqs[n] = eq
