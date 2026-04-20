#
# Copyright (c) 2026 Robert Weber,Leo Germer, Andreas Hofmann and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

import re
class TranslationError(ValueError):
    def __init__(self, structure):
        self.structure = structure
        super().__init__(self.structure)

    def __str__(self):
        return f"While reading the dsmodel.mof the following structure has not been closed: {self.structure} "


def read_mof(filepath, start="// Dynamics Section", end='// -------------'):
    with open(filepath, 'r', encoding='utf-8') as file:
        content = file.read()

        start_index = content.find(start)
        if start_index == -1:
            raise UnboundLocalError(f"Start tag not found: {start}")

        section_start = start_index + len(start)

        if end is None:
            section_text = content[section_start:]
        else:
            end_index = content.find(end, section_start)
            if end_index == -1:
                section_text = content[section_start:]
            else:
                section_text = content[section_start:end_index]

        dynamics_section = section_text.split("\n")


    cleaned_lines = []
    in_multiline_comment = False
    comment=False
    discrete_tag="##Discrete Event##"
    in_discrete=False
    in_discrete_new=False
    in_special_case=""
    linear_counter=1
    nonlinear_counter=1
    for n,line in enumerate(dynamics_section):
        if not in_multiline_comment:
            if line.strip().startswith("// Discrete part") :
                in_discrete_new = True
            elif line.strip().startswith("// Matrix solution:"):
                in_special_case="linear system"
            elif line.strip().startswith("// Torn part") and in_special_case=="linear system add lines":
                in_special_case=""
                cleaned_lines.append(f"##END Linear{linear_counter}##;")
                linear_counter+=1

            elif line.strip().startswith("// Nonlinear system of equations"):
                in_special_case = "nonlinear system"
            elif line.strip().startswith("// Start values for iteration variables of non-linear system") and in_special_case == "nonlinear system":
                in_special_case = "nonlinear system iteration variabels"
                cleaned_lines.append(f"## Nonlinear system of equations {nonlinear_counter};")
            elif in_special_case == "nonlinear system iteration variabels" and line.strip().startswith("algorithm // Torn part"):
                in_special_case = "nonlinear system algorithm"
                continue
            elif in_special_case == "nonlinear system iteration variabels":
                cleaned_lines.append(line.strip("//").strip()+";")
            elif in_special_case == "nonlinear system algorithm" and line.strip().startswith("equation // Residual equations"):
                in_special_case = "nonlinear system residual equations"
                cleaned_lines.append("## Residual equations;")
                continue
            elif in_special_case == "nonlinear system residual equations" and line.strip().startswith("// Non-zero elements of Jacobian"):
                in_special_case ="nonlinear system Jacobian"
                cleaned_lines.append("## Jacobian;")
                continue
            elif in_special_case == "nonlinear system Jacobian" and line.strip().startswith("// End of nonlinear system of equations"):
                cleaned_lines.append(f"##End nonlinear system of equations {nonlinear_counter};")
                nonlinear_counter+=1
                in_special_case =""
                continue
            line = re.sub(r'//.*?(?=//|$)', '', line)  
            
        line = re.sub(r'/\*.*?\*/', '', line) 
        if '/*' in line:
            comment= True
            line = line.split('/*')[0] 
        if '*/' in line:
            in_multiline_comment = False
            comment=False
            line = line.split('*/')[1] 
        if not in_multiline_comment and line.strip():
            if in_discrete:
                in_discrete_new=False
                line=discrete_tag+line
            elif in_special_case=="linear system":
                in_special_case="linear system add lines"
                cleaned_lines.append(f"##Linear{linear_counter}##;")
               
            in_multiline_comment= comment
            cleaned_lines.append(line)
        elif not line.strip():
            in_discrete=in_discrete_new
        in_multiline_comment=comment
    if in_special_case!="":
        raise TranslationError(in_special_case)
    if in_discrete or in_discrete_new:
        raise TranslationError("Discrete System")

    equations = []
    Time_events=[]
    current_equation = []
    State_events=[]
    when_struct=[]
    in_when=0
    order_events=[]
    for n,line in enumerate(cleaned_lines):
        line = line.strip()
        if line.endswith(';'):
            current_equation.append(line[:-1])
            eq=' '.join(current_equation)
            if eq.startswith(discrete_tag):
            #if discrete_tag in eq:
                eq=eq.replace(discrete_tag,"").strip()
                State_events.append(eq)
                order_events.append((n,eq))
            elif eq.startswith("when "):
                when_struct.append(eq)
                in_when+=1
            elif eq.startswith("end when"):
                when_struct.append(eq)
                State_events.append("\n".join(when_struct))
                order_events.append((n,"\n".join(when_struct)))

                #in_when-=1                             # mod
                in_when -= 1
                if in_when == 0:
                    when_struct = []

            elif in_when!=0:
                when_struct.append(eq)
            elif re.search(r"if\s+time ", eq):
                Time_events.append(eq)
                order_events.append([n,eq])
                equations.append(eq)
            else:
                equations.append(eq)
            current_equation = []
        else:
            current_equation.append(line)
    if in_when != 0:
        raise TranslationError("When")
    return equations,State_events,Time_events,order_events

if __name__=="__main__":
    eq=read_mof("Dymola_data/dsmodel.mof")



def read_equation_section(filepath, start_prefix, end_prefix=None):
    with open(filepath, 'r', encoding='utf-8') as file:
        lines = file.readlines()

    in_section = False
    equations = []
    current_equation = []
    in_multiline_comment = False

    for raw_line in lines:
        stripped = raw_line.strip()

        if not in_section:
            if stripped.lower().startswith(start_prefix.lower()):
                in_section = True
            continue

        if end_prefix is not None and stripped.lower().startswith(end_prefix.lower()):
            break

        line = raw_line

        if in_multiline_comment:
            if "*/" in line:
                line = line.split("*/", 1)[1]
                in_multiline_comment = False
            else:
                continue

        if "/*" in line:
            before, after = line.split("/*", 1)
            line = before
            if "*/" in after:
                line += after.split("*/", 1)[1]
            else:
                in_multiline_comment = True

        line = re.sub(r'//.*$', '', line).strip()

        if not line:
            continue

        current_equation.append(line)

        if line.endswith(";"):
            eq = " ".join(current_equation)[:-1].strip()
            if eq:
                equations.append(eq)
            current_equation = []

    if not in_section:
        raise UnboundLocalError(f"Section not found: {start_prefix}")

    return equations


def read_conditional_equations(filepath):
    return read_equation_section(
        filepath,
        start_prefix="// Conditionally Accepted Section",
        end_prefix="// Eliminated alias"
    )


def read_alias_equations(filepath):
    return read_equation_section(
        filepath,
        start_prefix="// Eliminated alias"
    )