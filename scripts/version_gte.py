#!/usr/bin/env python3

assert __name__ == "__main__"
import sys

assert len(sys.argv) == 3

v1 = [int(vn) for vn in sys.argv[1].split('.')]
assert len(v1) == 3

v2 = [int(vn) for vn in sys.argv[2].split('.')]
assert len(v2) == 3


if v1[0] != v2[0]:
    exit(2)

if v1 >= v2:
    exit(0)
else:
    exit(1)
