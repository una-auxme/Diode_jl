#
# Copyright (c) 2026 Robert Weber,Leo Germer, Andreas Hofmann and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

from ..logging_utils import log_info
from ..models import TranslationData
from .julia_sections import (
    write_callback_generation,
    write_callback_settings,
    write_continuous_state_events,
    write_discrete_state_events,
    write_imports,
    write_initialization,
    write_main_ode_function,
    write_nonlinear_guess_storage,
    write_parameter_initialization,
    write_parameter_timeline,
    write_post_processing,
    write_preset_time_state_events,
    write_simulation_config,
    write_solver_entry_point,
    write_state_initialization,
    write_state_time_events,
    write_time_events,
    write_time_span,
)


def write_julia_model(output_path: str, data: TranslationData) -> None:
    with open(output_path, "w", encoding="utf-8") as file:
        log_info("Writing imports and SimulationConfig")
        write_imports(file)
        write_simulation_config(file, data)
        write_nonlinear_guess_storage(file, data)

        log_info("Writing main ODE function")
        write_main_ode_function(file, data)
        write_initialization(file, data)

        log_info("Writing initialization and callback settings")
        write_callback_settings(file)
        write_parameter_initialization(file, data)
        write_state_initialization(file, data)
        write_time_span(file, data)

        log_info("Writing event callback functions")
        write_time_events(file, data)
        write_continuous_state_events(file, data)
        write_discrete_state_events(file, data)
        write_preset_time_state_events(file, data)
        write_state_time_events(file, data)
        write_callback_generation(file, data)
        write_parameter_timeline(file)

        log_info("Writing post-processing")
        write_post_processing(file, data)

        log_info("Writing solver entry point")
        write_solver_entry_point(file, data)