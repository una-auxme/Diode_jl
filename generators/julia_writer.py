#
# Copyright (c) 2026 Robert Weber,Leo Germer, Andreas Hofmann and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

import shutil
from pathlib import Path

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

TEMPLATE_DIR = Path(__file__).parent / "template"
PROJECT_FILES = ("Project.toml", "Manifest.toml")
SIMULATION_CONFIG_FILE = "simulationConfig.jl"
POST_PROCESSING_FILE = "post.jl"


def write_julia_model(output_path: str, data: TranslationData) -> None:
    output_dir = Path(output_path).parent

    for name in PROJECT_FILES:
        log_info(f"Copying {name}")
        shutil.copy2(TEMPLATE_DIR / name, output_dir / name)

    log_info(f"Writing {SIMULATION_CONFIG_FILE}")
    with open(output_dir / SIMULATION_CONFIG_FILE, "w", encoding="utf-8") as file:
        write_simulation_config(file, data)

    log_info(f"Writing {Path(output_path).name}")
    with open(output_path, "w", encoding="utf-8") as file:
        write_imports(file)
        file.write(f'include("{SIMULATION_CONFIG_FILE}")\n')
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

        log_info("Writing solver entry point")
        write_solver_entry_point(file, data)

    log_info(f"Writing {POST_PROCESSING_FILE}")
    with open(output_dir / POST_PROCESSING_FILE, "w", encoding="utf-8") as file:
        file.write(f'include("{Path(output_path).name}")\n')
        write_post_processing(file, data)
