#
# Copyright (c) 2026 Robert Weber,Leo Germer, Andreas Hofmann and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

from dataclasses import dataclass, field
from typing import Any


@dataclass
class TranslationData:
    path: str = ""
    variables_df: Any = None
    simulations_settings: dict[str, str] = field(default_factory=dict)

    equations_dynamic: list[str] = field(default_factory=list)
    state_events: list = field(default_factory=list)
    time_events: list[str] = field(default_factory=list)
    order_events: list = field(default_factory=list)
    initial_section: list[str] = field(default_factory=list)
    equations_bound: list[str] = field(default_factory=list)
    equations_conditional: list[str] = field(default_factory=list)
    equations_alias: list[str] = field(default_factory=list)

    state_variables: list[str] = field(default_factory=list)
    derivatives: list[str] = field(default_factory=list)
    parameters_struct: list[str] = field(default_factory=list)
    non_state_der_or_vec: list[str] = field(default_factory=list)

    parameter_callbacks: dict[str, str] = field(default_factory=dict)
    time_events_conditions: dict[str, str] = field(default_factory=dict)
    order_time_events: dict[str, int] = field(default_factory=dict)
    state_time_events: list[dict] = field(default_factory=list)

    subs: dict[str, str] = field(default_factory=dict)
    subs_eq: dict[str, str] = field(default_factory=dict)
    state_event_kinds: list[str] = field(default_factory=list)
    preset_time_state_links: dict[int, list[dict]] = field(default_factory=dict)
    nonlinear_guess_initials: dict[int, list[str]] = field(default_factory=dict)

    equations_all: list[str] = field(default_factory=list)
    equations_post_core: list[str] = field(default_factory=list)
    equations_post_conditional: list[str] = field(default_factory=list)
    equations_post_alias: list[str] = field(default_factory=list)
