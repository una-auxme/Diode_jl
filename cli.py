#
# Copyright (c) 2026 Robert Weber,Leo Germer, Andreas Hofmann and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

from pathlib import Path
import os
import questionary
import shutil
import sys
import tkinter as tk
from tkinter import filedialog

from .logging_utils import log_info, log_ok, log_step


def choose_folder(files_to_check=None) -> str:
    if files_to_check is None:
        files_to_check = []

    root = tk.Tk()
    root.withdraw()
    path = filedialog.askdirectory(title="Select the folder containing the simulation data")

    if path:
        files_in_path = os.listdir(path)
        for file in files_to_check:
            if file not in files_in_path:
                print(
                    f"WARNING - The file '{file}' could not be found in the selected path. "
                    "This file is required for simulation generation."
                )
                path = ""
    else:
        print("No folder was selected.")
        if not questionary.confirm("Do you want to select a folder?").ask():
            sys.exit(-1)
        path = ""

    return path


def is_convertable_to(input_string: str, datatype: type) -> bool:
    try:
        if datatype != bool:
            datatype(input_string)
            return True
        my_boolean_values = {"true", "false", "0", "1", "0.0", "1.0"}
        return input_string.lower().strip() in my_boolean_values
    except ValueError:
        return False


def get_package_root() -> Path:
    return Path(__file__).resolve().parent


def get_dymola_data_dir() -> Path:
    return get_package_root() / "Dymola_data"


def get_generated_files_dir() -> Path:
    generated_dir = get_package_root() / "Generated_Files"
    generated_dir.mkdir(exist_ok=True)
    return generated_dir


def resolve_dataset_path() -> str:
    path = ""
    dymola_dir = get_dymola_data_dir()

    if dymola_dir.is_dir():
        log_info(f"Found local folder '{dymola_dir.name}'")
        files_in_path = os.listdir(dymola_dir)

        has_required_files = (
            "dsmodel.mof" in files_in_path
            and ("dsin.txt" in files_in_path or "dsfinal.txt" in files_in_path)
        )

        if has_required_files:
            use_local = questionary.confirm(
                f"Do you want to use the files directly from '{dymola_dir.name}'?",
                default=True
            ).ask()

            if use_local:
                path = str(dymola_dir)
                log_ok(f"Using dataset from '{dymola_dir.name}'")
            else:
                log_step("Locating simulation dataset")
        else:
            print(
                f"WARNING - Folder '{dymola_dir.name}' exists, but required files are missing. "
                "Please choose another dataset."
            )

    if path == "":
        log_info("No valid local dataset selected. Opening folder chooser.")
        print("Please select a folder in the new window from which the data should be loaded.")

        while path == "":
            selected_path = choose_folder(["dsmodel.mof"])
            if selected_path != "":
                log_ok(f"Selected folder: {selected_path}")
                files_in_path = os.listdir(selected_path)

                if not ("dsin.txt" in files_in_path or "dsfinal.txt" in files_in_path):
                    print(
                        "WARNING - Neither 'dsin.txt' nor 'dsfinal.txt' could be found in the selected path. "
                        "At least one of these files is required for simulation generation."
                    )
                else:
                    path = selected_path

            if path == "":
                print("Please choose a different path.")

        copy_to_local = questionary.confirm(
            f"Should the selected dataset be copied to '{dymola_dir.name}'?",
            default=True
        ).ask()

        if copy_to_local:
            log_step(f"Copying selected dataset to '{dymola_dir.name}'")
            dymola_dir.mkdir(exist_ok=True)

            items = ("dsin.txt", "dsmodel.mof", "dsfinal.txt")
            for item in items:
                source_item = Path(path) / item
                destination_item = dymola_dir / item

                if not source_item.exists():
                    continue

                if source_item.resolve() == destination_item.resolve():
                    continue

                if source_item.is_dir():
                    if not destination_item.exists():
                        shutil.copytree(source_item, destination_item)
                else:
                    shutil.copy2(source_item, destination_item)

            log_ok(f"Dataset copied to '{dymola_dir.name}'")

    return path


def prompt_for_time_settings() -> dict:
    is_convertable_to_float = lambda s: is_convertable_to(s, float)
    return {
        "StartTime": questionary.text(
            "Please enter the simulation start time:", validate=is_convertable_to_float
        ).ask(),
        "StopTime": questionary.text(
            "Please enter the simulation stop time:", validate=is_convertable_to_float
        ).ask(),
    }


def main() -> None:
    from .pipeline import run_translation
    run_translation()