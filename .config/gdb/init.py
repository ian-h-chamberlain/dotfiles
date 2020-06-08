#!/usr/bin/env python2

from __future__ import print_function

import re

# Replace working dir /i95code with ~/Documents/workspace
# This make things like cmd+click work properly
pwd_str = gdb.execute("pwd", from_tty=False, to_string=True).strip()

new_pwd = re.sub(r"^.+/i95code/(.+)\.$", r"~/Documents/workspace/\1", pwd_str)
print("cwd: '{}'".format(new_pwd))
gdb.execute("cd {}".format(new_pwd))
