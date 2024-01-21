assert __name__ != "__main__"

# builtin
from enum import Enum
from dataclasses import dataclass
from typing import List, Optional, Dict, Any
from pathlib import Path
import tomllib

# local
from utils import panic
from type_check import check_type


CONFIG_FILE_PATH = "./cpmconfig.toml"
DEFAULT_BUILD_FOLDER = "./build/"

class TargetType(Enum):
    Executable = 1
    Library = 2

@dataclass
class Target:
    name: str
    type: TargetType
    is_test: bool
    test_exclude_from_all: bool
    associated_test_target_name: Optional[str]

@dataclass
class ProjectConfig:
    targets: Dict[str, Target]
    build_types: List[str]
    build_folder: Path
    main_target: Optional[str]
    default_build_mode: str

    def get_executable_path(self, target: str, build_mode: str) -> Path:

        assert target in self.targets
        assert self.targets[target].type is TargetType.Executable
        assert build_mode in self.build_types

        return Path(".", self.build_folder, build_mode, self.targets[target].name)



def parse_config_file() -> ProjectConfig:
    
    PATH_VAR = "__TREE_PATH__"

    def insert_tree_path(map: Dict[str, Any], path: List[str] = []):

        def build_path_str(path: List[str]) -> str:
            return "".join("." + key for key in path)[1:]

        def dispatch(value: Any, path: List[str]):
            
            if check_type(value, Dict[str, Any]):
                insert_tree_path(value, path + [key])
            elif check_type(value, List[Any]):
                handle_arrays(value, path + [key])

        def handle_arrays(array: List[Any], path: List[str]):
            for idx, item in enumerate(array):
                dispatch(item, path + [str(idx)])


        if PATH_VAR in map:
            panic(f"please, do not use the '{PATH_VAR}' key")

        for key, value in map.items():
            dispatch(value, path + [key])

        map[PATH_VAR] = build_path_str(path)


    def take_if[T](map: Dict[str, Any], key: str, vT: type[T]) -> Optional[T]:

        if (key not in map) or not check_type(map[key], vT):
            return None
        
        value: T = map[key]
        map.pop(key)
        return value
    

    def take_if_or_default[T](map: Dict[str, Any], key: str, vT: type[T], default: T) -> T:

        value = take_if(map, key, vT)
        
        if value == None:
            return default
        
        return value


    def take[T](map: Dict[str, Any], key: str, vT: type[T]) -> T:

        assert PATH_VAR in map, "internal error, the tree shold be annotated with tree path"

        if key not in map:
            panic(f"{map[PATH_VAR]}.{key} is required")

        if not check_type(map[key], vT):
            panic(f"{map[PATH_VAR]}.{key} needs to be an {T}")

        value: T = map[key]
        map.pop(key)
        return value
    


    file = open(CONFIG_FILE_PATH, "rb")
    config_data = tomllib.load(file)
    insert_tree_path(config_data)

    project = config_data["project"]
    main_target: Optional[str] = take_if(project, "main_target", str) # TODO: checar se o target existe e é um executável
    build_types: List[str] = take(project, "build_types", List[str]) # TODO: checar repetições
    default_build_mode: str = take(project, "default_build_mode", str)
    build_folder: str = take_if_or_default(project, "build_folder", str, DEFAULT_BUILD_FOLDER)
    
    if project.get("targets", None) == None:
        panic("at least one target is required")

    targets: Dict[str, Target] = dict()
    type TargetList = List[Dict[str, Any]]

    executables: TargetList = take_if_or_default(project["targets"], "executable", TargetList, [])
    for executable in executables:
        name: str = take(executable, "name", str)
        associated_test_target_name: Optional[str] = take_if(executable, "test_target", str)
        is_test: bool = take_if_or_default(executable, "is_test", bool, False)
        exclude_from_all: bool = is_test and take_if_or_default(executable, "exclude_from_all", bool, False)

        assert name not in targets
        targets[name] = Target(name, TargetType.Executable, is_test, exclude_from_all, associated_test_target_name)


    libraries: TargetList = take_if_or_default(project["targets"], "library", TargetList, [])
    for library in libraries:
        name: str = take(library, "name", str)
        associated_test_target_name: Optional[str] = take_if(library, "test_target", str)
        
        assert name not in targets
        targets[name] = Target(name, TargetType.Library, False, False, associated_test_target_name)

    # TODO: garantir que não existem outros tipos de target além de 'executable' e 'library'
    # TODO: garantir que não existe nenhuma outra entrada em 'project' além das usadas

    return ProjectConfig(targets, build_types, Path(build_folder), main_target, default_build_mode)

