#
# Copyright (c) 2026 Robert Weber,Leo Germer, Andreas Hofmann and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

from dataclasses import dataclass, field
from typing import Any, Dict, List


@dataclass
class TranslationData:
    path: str = ""
    variables_df: Any = None
    simulations_settings: Dict[str, str] = field(default_factory=dict)

    equations_dynamic: List[str] = field(default_factory=list)
    state_events: List = field(default_factory=list)
    time_events: List[str] = field(default_factory=list)
    order_events: List = field(default_factory=list)
    initial_section: List[str] = field(default_factory=list)
    equations_bound: List[str] = field(default_factory=list)
    equations_conditional: List[str] = field(default_factory=list)
    equations_alias: List[str] = field(default_factory=list)

    state_variables: List[str] = field(default_factory=list)
    derivatives: List[str] = field(default_factory=list)
    parameters_struct: List[str] = field(default_factory=list)
    non_state_der_or_vec: List[str] = field(default_factory=list)

    parameter_callbacks: Dict[str, str] = field(default_factory=dict)
    time_events_conditions: Dict[str, str] = field(default_factory=dict)
    order_time_events: Dict[str, int] = field(default_factory=dict)
    state_time_events: List[dict] = field(default_factory=list)

    subs: Dict[str, str] = field(default_factory=dict)
    subs_eq: Dict[str, str] = field(default_factory=dict)
    state_event_kinds: List[str] = field(default_factory=list)
    preset_time_state_links: Dict[int, List[dict]] = field(default_factory=dict)
    nonlinear_guess_initials: Dict[int, List[str]] = field(default_factory=dict)

    equations_all: List[str] = field(default_factory=list)
    equations_post_core: List[str] = field(default_factory=list)
    equations_post_conditional: List[str] = field(default_factory=list)
    equations_post_alias: List[str] = field(default_factory=list)