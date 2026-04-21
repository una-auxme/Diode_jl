#
# Copyright (c) 2026 Robert Weber,Leo Germer, Andreas Hofmann and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

import re
import sys
from typing import Callable


def translate_linear_system_of_equations(input_lines: list[str], number) -> list[str]:
    j_lines = [
        line
        for line in input_lines
        if line.strip("par.").strip('var"').startswith("J[")
    ]

    try:
        j_max_row = max(int(re.search(r"J\[(\d+),", line).group(1)) for line in j_lines)
    except ValueError:
        print(
            "The Jacobian in the Linear system of equations is missing\n"
            "Try activating 'Advanced.OutputModelicaCodeWithJacobians = true'"
        )
        sys.exit(1)

    j_max_col = max(
        int(re.search(r"J\[\d+, (\d+)\]", line).group(1)) for line in j_lines
    )

    j_matrix = [["0"] * j_max_col for _ in range(j_max_row)]
    for line in j_lines:
        row = int(re.search(r"J\[(\d+),", line).group(1)) - 1
        col = int(re.search(r"J\[\d+, (\d+)\]", line).group(1)) - 1
        value = re.search(r"=(.*)", line).group(1).strip()
        j_matrix[row][col] = "(" + value + ")"

    julia_code = ["// Start Linear System"]
    julia_code.extend(
        [
            f"J{number} = ["
            + ";\n\t\t".join("\t" + "\t\t".join(row) for row in j_matrix)
            + "\n\t\t]\n"
        ]
    )

    b_lines = [
        line
        for line in input_lines
        if line.strip("par.").strip('var"').startswith("b[")
    ]
    b_vector = ["0"] * j_max_row
    for line in b_lines:
        index = int(re.search(r"b\[(\d+)\]", line).group(1)) - 1
        value = re.search(r"=(.*)", line).group(1).strip()
        b_vector[index] = "(" + value + ")"

    julia_code.append(f"b{number} = [" + ";\n\t\t".join(b_vector) + "\n\t\t]\n")
    julia_code.append(f"x{number} = J{number}\\b{number}\n")
    julia_code.append(
        "".join(
            [line.split("=")[0] for line in input_lines if line.strip().endswith("x")]
        )
        + f" = x{number}\n"
    )
    julia_code.append("// End Linear System")
    return julia_code


def translate_nonlinear_system_of_equations(
    input_lines: list[str],
    number,
    nonlinear_guess_initials: dict[int, list[str]],
) -> list[str]:
    def residuals(lines: list[str]) -> str:
        return (
            "return ["
            + ", ".join(["(" + var.split("=")[1] + ")" for var in lines])
            + "]"
        )

    output_lines = ["nonlineareq(u0,p) = begin"]

    inital_values = [line for line in input_lines if line.startswith(r"//")]
    init_vals = [value.strip(")").split("=")[1].strip() for value in inital_values]
    nonlinear_guess_initials[number] = init_vals.copy()

    if len(inital_values) > 1:
        startline = (
            ", ".join([var.strip("/").split("(")[0].strip() for var in inital_values])
            + " = u0"
        )
    else:
        startline = (
            ", ".join([var.strip("/").split("(")[0].strip() for var in inital_values])
            + " = u0[1]"
        )
    output_lines.append(startline)

    residuals_eq = []
    var_eqs = []
    for line in input_lines:
        if line.startswith(r"//"):
            continue
        if line.startswith("## Jacobian"):
            break
        if line.startswith("0 = "):
            residuals_eq.append(line)
            continue
        var_eqs.append(line)

    output_lines.extend(var_eqs)
    output_lines.append(residuals(residuals_eq))
    output_lines.append("end")

    output_lines.append(f"u{number} = copy(NONLINEAR_GUESS_{number}[])")
    output_lines.append(f"p{number} = nothing")
    output_lines.append(f"prob = NonlinearProblem(nonlineareq, u{number}, p{number})")
    output_lines.append("sol = solve(prob)")
    output_lines.append("if !(sol.u[1] isa ForwardDiff.Dual)")
    output_lines.append(f"\tNONLINEAR_GUESS_{number}[] = collect(Float64.(sol.u))")
    output_lines.append("end")

    if len(inital_values) > 1:
        output_lines.append(
            ", ".join([var.strip("/").split("(")[0].strip() for var in inital_values])
            + " = sol.u"
        )
    else:
        output_lines.append(
            ", ".join([var.strip("/").split("(")[0].strip() for var in inital_values])
            + " = sol.u[1]"
        )

    output_lines.extend([var for var in var_eqs if not var.startswith("##")])
    return output_lines


def Transform_structure_between_tags(
    input_list: list[str],
    start_tag: str,
    end_tag: str,
    trasnslator: Callable,
) -> list[str]:
    output_list = []
    i = 0
    while i < len(input_list):
        if start_tag in input_list[i]:
            matches = re.findall(r"\d+", input_list[i])
            number = int(matches[-1]) if matches else 0
            system = []
            i += 1
            while i < len(input_list) and end_tag not in input_list[i]:
                system.append(input_list[i])
                i += 1
            translated_system = trasnslator(system, number)
            output_list.extend(translated_system)
        else:
            output_list.append(input_list[i])
        i += 1

    return output_list
