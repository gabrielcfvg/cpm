assert __name__ != "__main__"

from typing import get_origin, get_args, Any, Dict, List, Union, Optional, Callable, TypeGuard, TypeAliasType, cast
from types import UnionType
from utils import panic



def check_type[T](value: Any, tp: type[T]) -> TypeGuard[T]:

    if tp == Any:
        return True

    if isinstance(tp, TypeAliasType):
        return check_type(value, tp.__value__) 

    if get_origin(tp) == tp or get_origin(tp) == None:
        return isinstance(value, tp)

    return check_generic_type(value, tp)

def check_generic_type(value: Any, tp: type) -> bool:

    def check_multiple(value: Any, tp: type) -> bool:

        assert isinstance(value, (Union, UnionType, Optional))

        return any(check_type(value, tp) for tp in get_args(tp))

    def check_dict(value: Any, tp: type) -> bool:

        assert isinstance(value, (Dict, dict))

        (key_tp, item_tp) = get_args(tp)
        _value: Dict[Any, Any] = cast(Dict[Any, Any], value)

        r = all([(check_type(key, key_tp) and check_type(item, item_tp))
                 for key, item in _value.items()])
        
        return r


    def check_list(value: Any, tp: type) -> bool:
        
        assert isinstance(value, (List, list))

        item_tp = get_args(tp)[0]

        item: Any
        for item in value:
            if not check_type(item, item_tp):
                return False
        return True


    check_map: Dict[type, Callable[[Any, type], bool]] = { # type: ignore
        Dict: check_dict,
        dict: check_dict,
        List: check_list,
        list: check_list,
        Union: check_multiple,
        Optional: check_multiple,
        UnionType: check_multiple,
    }

    origin = get_origin(tp)
    assert origin != None

    if type(value) != origin:
        return False

    if origin in check_map:
        return check_map[origin](value, tp)
    else:
        panic(f"internal_error: unsurported generic type: {origin}")
