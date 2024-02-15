assert __name__ != "__main__"

import sys, subprocess
from pathlib import Path
from typing import Optional, Any, Callable, NoReturn
from dataclasses import dataclass
from sys import exit


@dataclass
class CMDResult:
    exit_code: int
    stdout: Optional[bytes]

def cmd(command: str, get_stdout: bool = False, check: bool = True, shell: bool = False, env: Optional[Any] = None) -> CMDResult:

    try:
        r = subprocess.run(
            command.split(' '),
            shell=shell,
            check=check,
            env=env,
            capture_output=get_stdout,
            stdout=None if get_stdout else sys.stdout
        )

        return CMDResult(r.returncode, r.stdout if get_stdout == True else None)

    except KeyboardInterrupt:
        return CMDResult(1, None)
    
    except subprocess.CalledProcessError as e:
        return CMDResult(e.returncode, e.output)

def command_exists(command_name: str) -> bool:

    return cmd(f"command -v {command_name}", get_stdout=True, shell=True).exit_code == 0

def is_file_executable(file: Path) -> bool:

    # FIXME: não funciona

    assert file.exists()
    assert file.is_file()

    return cmd(f"test -x {file}", get_stdout=True, shell=True).exit_code == 0

def panic(*args: str, code: int = 1) -> NoReturn:

    print("ERROR:", *args)
    exit(code)



def any_newer_than(target: Path, *nodes: Path, filter: Optional[Callable[[Path], bool]] = None) -> bool:

    assert target.exists()
    assert nodes[0].exists()

    node = nodes[0]
    target_date = target.stat().st_mtime

    if node.stat().st_mtime > target_date:
        if filter != None and filter(node):
            return True

    if node.is_dir():
        if any(any_newer_than(target, children) == True for children in node.iterdir()):
            return True
        #for children in node.iterdir():
        #    if any_newer_than(target, children) == True:
        #        return True

    if len(nodes) > 1:
        return any_newer_than(target, *nodes[1:])
    else:
        return False
