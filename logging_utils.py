#
# Copyright (c) 2026 Robert Weber,Leo Germer, Andreas Hofmann and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

from colorama import Fore, init

init(autoreset=True)

STEP_COUNTER = 0


def log_step(message: str) -> None:
    global STEP_COUNTER
    STEP_COUNTER += 1
    print(Fore.CYAN + f"[STEP {STEP_COUNTER:02d}] {message}")


def log_info(message: str) -> None:
    print(Fore.BLUE + f"[INFO] {message}")


def log_ok(message: str) -> None:
    print(Fore.GREEN + f"[ OK ] {message}")


def log_warn(message: str) -> None:
    print(Fore.MAGENTA + f"[WARN] {message}")


def log_error(message: str) -> None:
    print(Fore.RED + f"[ERR ] {message}")
