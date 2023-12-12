''' This script should open the javascript file from the same folder where it is located.
    The file to open is: TclCodeDefines.js
    It should parse the file and create a file of snippets for VS Code language package.
'''

import os
import re
import json
import sys

# Functions definitions
def process_line(line, id_prefix):
    name_match = re.search(r"= '(.*?)'", line)
    id_match = re.search(rf"{id_prefix}(.*?) ", line)
    if name_match and id_match:
        return name_match.group(1), id_match.group(1)
    return None, None

def process_macro_line(line, id_prefix):
    name_match = re.search(rf"{id_prefix}(.*?) ", line)
    id_match = line.split(" =")[0].strip()
    if name_match and id_match:
        return name_match.group(1), id_match
    return None, None

def find_doc_string(js_lines, id_of_item):
    for doc_line in js_lines:
        if doc_line.strip().startswith("this." + id_of_item + "Doc"):
            doc_match = re.search(r"= '(.*?)'", doc_line)
            if doc_match:
                doc_string = doc_match.group(1)
                doc_string = doc_string.replace("&gt;", ">").replace("&gt", ">").replace("&lt;", "<").replace("&lt", "<").replace("' + '", ". ")
                return doc_string
    return None

def find_macro_doc_string(js_lines, id_of_item):
    for doc_line in js_lines:
        if doc_line.strip().startswith(id_of_item + "Doc"):
            doc_match = re.search(r"= '(.*?)'", doc_line)
            if doc_match:
                doc_string = doc_match.group(1)
                doc_string = doc_string.replace("&gt;", ">").replace("&gt", ">").replace("&lt;", "<").replace("&lt", "<").replace("' + '", ". ")
                return doc_string
    return None



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
line_counts = {"NGMK Macros": 0, "MOM Commands": 0, "LIBRARY Procedures": 0, "MOM Variables": 0}
snippets = {}
doc_string = None

# Read the lines of the file into a list
js_lines = js_file.readlines()

for line in js_lines:
    # If the line starts with pattern "/* MOM Commands" then start parsing next lines
    # until the empty line
    stripped_line = line.strip()
    if stripped_line.startswith("/* NGMK Macros"):
        print(line.strip())
        section = "NGMK Macros"
        parsing = True
    elif stripped_line.startswith("/* MOM Commands"):
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
        if section == "NGMK Macros":
            continue
            # process the line
            print(line.strip())
            name_of_item, id_of_item = process_macro_line(line, "this.")
            print(name_of_item, id_of_item)
            doc_string = find_macro_doc_string(js_lines, id_of_item)

            snippets[name_of_item] = {
                "prefix": name_of_item,
                "body": [name_of_item],
                "description": doc_string if doc_string else "Description of " + name_of_item
            }

        elif section == "MOM Commands":
            # process the line
            # print(line.strip())
            name_of_item, id_of_item = process_line(line, "this.")
            doc_string = find_doc_string(js_lines, id_of_item)

            snippets[name_of_item] = {
                "prefix": name_of_item,
                "body": [name_of_item],
                "description": doc_string if doc_string else "Description of " + name_of_item
            }

        elif section == "LIBRARY Procedures":
            # process the line
            # print(line.strip())
            name_of_item, id_of_item = process_line(line, "this.")
            doc_string = find_doc_string(js_lines, id_of_item)
            
            snippets[name_of_item] = {
                "prefix": name_of_item,
                "body": [name_of_item],
                "description": doc_string if doc_string else "Description of " + name_of_item
            }
        
        elif section == "MOM Variables":
            # process the line
            # print(line.strip())
            name_of_item, id_of_item = process_line(line, "this.")
            doc_string = find_doc_string(js_lines, id_of_item)
            
            snippets[name_of_item] = {
                "prefix": name_of_item,
                "body": [name_of_item],
                "description": doc_string if doc_string else "Description of " + name_of_item
            }


for section, count in line_counts.items():
    print("Section: {}, Count: {}".format(section, count))

json_snippets = json.dumps(snippets, indent=4)
# Write the snippets to the file
snippets_file.write(json_snippets)
# Close the files
js_file.close()
snippets_file.close()
# ask the user to press enter to exit
input("All files are written and closed.\nPress Enter to exit...")
# Exit the script
sys.exit(0)
