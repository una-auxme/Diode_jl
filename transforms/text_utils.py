#
# Copyright (c) 2026 Robert Weber,Leo Germer, Andreas Hofmann and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

import re


def extract_non_float_dots(input_string: str):
    """
    Replaces dotted identifiers such as a.b.c by a_b_c.
    Pure floating-point numbers such as 123.456 are left unchanged.
    """
    if not hasattr(extract_non_float_dots, "_pattern"):
        extract_non_float_dots._pattern = re.compile(
            r"\b(?!(?:\d+\.)+\d+\b)(?=.*[A-Za-z])[\w]+(?:\.[\w]+)+\b"
        )
    return extract_non_float_dots._pattern.sub(
        lambda m: m.group(0).replace(".", "_"),
        input_string,
    )


def remove_smooth(input_string: str) -> str:
    pattern = r"smooth\(\d+,"
    replaced_text = re.sub(pattern, "(", input_string)
    return replaced_text


def replace_non_flaot_dotes(input_string: str) -> str:
    pattern = re.compile(r"(?<!\d)\.(?!\d)")
    return pattern.sub("_", input_string)


def conditional_substitute(input_string: str, substitutions: dict, reverse=True) -> str:
    if not substitutions:
        return input_string

    if not hasattr(conditional_substitute, "_cache"):
        conditional_substitute._cache = {}

    sorted_keys = tuple(sorted(substitutions.keys(), key=len, reverse=reverse))
    cache_key = (sorted_keys, reverse)

    if cache_key not in conditional_substitute._cache:
        parts = []
        for key in sorted_keys:
            escaped_key = re.escape(key)
            prefix = r"\b" if key[0].isalnum() or key[0] == "_" else ""
            suffix = r"\b" if key[-1].isalnum() or key[-1] == "_" else ""
            parts.append(f"{prefix}{escaped_key}{suffix}")

        conditional_substitute._cache[cache_key] = re.compile("|".join(parts))

    pattern = conditional_substitute._cache[cache_key]
    return pattern.sub(lambda m: str(substitutions[m.group(0)]), input_string)


def insert_integrator(input_string: str, all=True) -> str:
    pattern_p = re.compile(r"\bp\[(\d+)\]")
    if all:
        pattern_t = re.compile(r"\bt\b")
        pattern_u = re.compile(r"\bu\[(\d+)\]")
        pattern_du = re.compile(r"\bdu\[(\d+)\]")

    input_string = pattern_p.sub(r"integrator.p[\1]", input_string)
    if all:
        input_string = pattern_t.sub(r"integrator.t", input_string)
        input_string = pattern_u.sub(r"integrator.u[\1]", input_string)
        input_string = pattern_du.sub(r"integrator.du[\1]", input_string)
    return input_string


def extract_event_time(input_string: str) -> str:
    regex = r"([^<>=!]+)$"
    match = re.search(regex, input_string)
    return match.group(1).strip()


def replace_du_brackets(input_string: str) -> str:
    pattern = r"du\[(\d+)\]"
    return re.sub(pattern, r"du_\1", input_string)


def replace_der(input_string: str) -> str:
    pattern = r"der\(([A-Za-z0-9_]+)\)"
    replacement = r"der_\1"
    return re.sub(pattern, replacement, input_string)


def extract_time_events(input_string: str) -> list[str]:
    pattern = r"t\s*(?:<|<=|>|>=|==|!=)\s*[^?\|&:]+(?:\?)?"
    return re.findall(pattern, input_string)


def wrap_matches_once(text: str, names: list[str], prefix: str, suffix: str) -> str:
    if not names:
        return text

    if not hasattr(wrap_matches_once, "_cache"):
        wrap_matches_once._cache = {}

    unique_names = tuple(sorted(set(names), key=len, reverse=True))
    cache_key = (unique_names, prefix, suffix)

    if cache_key not in wrap_matches_once._cache:
        pattern = re.compile("|".join(re.escape(name) for name in unique_names))
        wrap_matches_once._cache[cache_key] = pattern

    pattern = wrap_matches_once._cache[cache_key]
    return pattern.sub(lambda m: f"{prefix}{m.group(0)}{suffix}", text)


def find_keys(input_string: str, substitutions: dict[str, str]) -> list[str]:
    if not substitutions:
        return []

    if not hasattr(find_keys, "_cache"):
        find_keys._cache = {}

    sorted_keys = tuple(sorted(substitutions.keys(), key=len, reverse=True))
    cache_key = sorted_keys

    if cache_key not in find_keys._cache:
        parts = []
        for key in sorted_keys:
            escaped_key = re.escape(key)
            prefix = r"\b" if key[0].isalnum() or key[0] == "_" else ""
            suffix = r"\b" if key[-1].isalnum() or key[-1] == "_" else ""
            parts.append(f"{prefix}{escaped_key}{suffix}")

        combined_pattern = re.compile("|".join(parts))
        find_keys._cache[cache_key] = combined_pattern

    pattern = find_keys._cache[cache_key]
    return list(
        dict.fromkeys(match.group(0) for match in pattern.finditer(input_string))
    )


def extract_parameter_numbers(input_string: str) -> tuple[set, set]:
    lhs = set()
    rhs = set()
    pattern = r"p\[(\d+)\]"

    for m in re.finditer(pattern, input_string):
        nach_match = input_string[m.end() :]
        if re.match(r"\s*=", nach_match):
            lhs.add(int(m.group(1)))
        else:
            rhs.add(int(m.group(1)))

    return lhs, rhs


def extract_lhs_vars(lines: list[str]) -> list[str]:
    ignore_pattern = re.compile(r"^(?:u|du)\[\d+\]$")

    result: list[str] = []
    for line in lines:
        if "=" not in line:
            continue

        lhs = line.split(":=", 1)[0].strip()

        if ignore_pattern.fullmatch(lhs):
            continue

        if "[" in lhs or "(" in lhs:
            result.append(lhs)

    return result


def filter_valid_assignments(lines: list[str]) -> list[str]:
    valid = []
    for line in lines:
        if "=" not in line:
            continue

        _, rhs = line.split("=", 1)
        value = rhs.strip()

        if value.lower() in ("true", "false"):
            valid.append(line)
            continue

        try:
            int(value)
            valid.append(line)
            continue
        except ValueError:
            pass

        try:
            float(value)
            valid.append(line)
        except ValueError:
            pass

    return valid


def resolve_init_expression(expr: str, subs: dict[str, str], max_iter: int = 20) -> str:
    out = expr
    for _ in range(max_iter):
        prev = out
        out = conditional_substitute(out, subs)
        if out == prev:
            break
    return out


def comparison_to_root(expr: str):
    expr = expr.strip()

    if expr.startswith("(") and expr.endswith(")"):
        expr = expr[1:-1].strip()

    m = re.match(r"^\s*(.+?)\s*(>=|<=|>|<)\s*(.+?)\s*$", expr)
    if not m:
        return None

    lhs = m.group(1).strip()
    op = m.group(2).strip()
    rhs = m.group(3).strip()

    if op in (">", ">="):
        return f"({lhs}) - ({rhs})"
    if op in ("<", "<="):
        return f"({rhs}) - ({lhs})"

    return None
