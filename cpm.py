# this file do not should be imported
assert __name__ == "__main__"

# requires a minimum python version
import sys
MINIMUM_PYTHON_VERSION = (3, 12)
assert sys.version_info >= MINIMUM_PYTHON_VERSION, f"minimum python version is {MINIMUM_PYTHON_VERSION[0]}.{MINIMUM_PYTHON_VERSION[1]}"



from config_file import parse_config_file

config = parse_config_file()
print(config)
