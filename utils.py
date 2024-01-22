assert __name__ != "__main__"

import sys, subprocess
from pathlib import Path
from typing import Optional, Any, Callable, NoReturn



def cmd(command: str, get_stdout: bool = False, shell: bool = False, env: Optional[Any] = None) -> Optional[bytes]:

    try:

        if get_stdout:
            return subprocess.run(command.split(' '), shell=shell, check=True, env=env, capture_output=True).stdout
        else:
            subprocess.run(command.split(' '), shell=shell, check=True, env=env, stdout=sys.stdout)
    
    except KeyboardInterrupt:
        pass

def command_exists(command_name: str) -> bool:

    try:
        cmd(f"command -v {command_name}", get_stdout=True, shell=True)
        return True
    except subprocess.CalledProcessError:
        return False

def is_file_executable(file: Path) -> bool:

    assert file.exists()
    assert file.is_file()

    try:
        cmd(f"test -x {file}", get_stdout=True, shell=True) # FIXME: falha mesmo que o arquivo seja executável
        return True
    except subprocess.CalledProcessError:
        return False

def panic(*args: str) -> NoReturn:

    print("ERROR:", *args)
    exit(1)



def any_newer_than(target: Path, *nodes: Path, filter: Optional[Callable[[Path], bool]] = None) -> bool:

    assert target.exists()
    assert nodes[0].exists()

    node = nodes[0]
    target_date = target.stat().st_mtime

    if node.stat().st_mtime > target_date:
        if filter != None and filter(node):
            return True

    if node.is_dir():
        for children in node.iterdir():
            if any_newer_than(target, children) == True:
                return True

    if len(nodes) > 1:
        return any_newer_than(target, *nodes[1:])
    else:
        return False
