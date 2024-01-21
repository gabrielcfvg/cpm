assert __name__ != "__main__"

import sys, subprocess
from pathlib import Path
from typing import Optional, Any, Callable, NoReturn



def cmd(command: str, get_stdout: bool = False, env: Optional[Any] = None) -> Optional[bytes]:

    if get_stdout:
        return subprocess.run(command.split(' '), check=True, capture_output=True, env=env).stdout
    else:
        subprocess.run(command.split(' '), check=True, stdout=sys.stdout)


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
            if any_newer_than(target, children) is True:
                return True

    if len(nodes) > 1:
        return any_newer_than(target, *nodes[1:])
    else:
        return False
