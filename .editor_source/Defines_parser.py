''' This script should open the javascript file from the same folder where it is located.
    The file to open is: TclCodeDefines.js
    It should parse the file and create a file of snippets for VS Code language package.
'''

import os
import re
import json
import sys

# Get the path of the script
script_path = os.path.dirname(os.path.realpath(__file__))
# Get the path of the javascript file
js_path = os.path.join(script_path, "TclCodeDefines.js")
# Use the script path to ouptut the snippets file
snippets_path = os.path.join(script_path, "tcl4snx.json")
# Open the javascript file for reading
js_file = open(js_path, "r")
# Open the snippets file for writing
snippets_file = open(snippets_path, "w")
# Start reading the javascript file line by line
parsing = False
section = None
line_counts = {"MOM Commands": 0, "LIBRARY Procedures": 0, "MOM Variables": 0}
for line in js_file:
    # If the line starts with pattern "/* MOM Commands" then start parsing next lines
    # until the empty line
    stripped_line = line.strip()
    if stripped_line.startswith("/* MOM Commands"):
        print(line.strip())
        section = "MOM Commands"
        parsing = True
    elif stripped_line.startswith("/* LIBRARY Procedures"):
        print(line.strip())
        section = "LIBRARY Procedures"
        parsing = True
    elif stripped_line.startswith("/* MOM Variables"):
        print(line.strip())
        section = "MOM Variables"
        parsing = True
    elif not stripped_line:
        parsing = False
    elif parsing:
        # Increment the line counter for section
        line_counts[section] += 1
        if section == "MOM Commands":
            # process the line
            print(line.strip())
        elif section == "LIBRARY Procedures":
            # process the line
            print(line.strip())
        elif section == "MOM Variables":
            # process the line
            print(line.strip())

for section, count in line_counts.items():
    print("Section: {}, Count: {}".format(section, count))
