#
# Copyright (c) 2026 Robert Weber,Leo Germer, Andreas Hofmann and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

import pandas as pd
from typing import Dict

def extract_simulations_Settings(file_path:str)->Dict[str,float]:
    simulation_settings={}
    labels = [
            "StartTime", "StopTime", "Increment", "nInterval", 
            "Tolerance", "MaxFixedStep", "Algorithm"
        ]
        
    with open(file_path, 'r') as file:
            lines = file.readlines()
            for i, line in enumerate(lines):
                if 'double experiment(' in line:
                    counter=0
                    form_start=1
                    while (counter<7):
                        try:
                            simulation_settings[labels[counter]]= float(lines[i+form_start].split("#")[0].strip())
                            counter+=1
                        except ValueError:
                            pass
                        form_start+=1
                    break
    if not all(key in simulation_settings for key in labels):
        raise ValueError
    return simulation_settings


def read_and_process_file(file_path:str)->pd.DataFrame:
    column_names = [
        "Type of initial value",
        "fixed, free or desired",
        "Minimum value",
        "Maximum value",
        "Category of variable",
        "Data type of variable",
        "Name"
    ]
    type_of_initial_value_mapping = {
        -2: "special case",
        -1: "fixed value",
        0: "free value",
    }
    category_of_variable_mapping = {
        1: "parameter",
        2: "state",
        3: "state derivative",
        4: "output",
        5: "input",
        6: "auxiliary variable"
    }
    df = pd.DataFrame(columns=column_names)
    go=0
   

    with open(file_path, 'r') as file:
        line_buffer=""
        for line in file:
            if line.startswith("double initialValue"):
                go=1
            elif go==1:
                if line.strip() == '':
                    break

                line=line_buffer+line
            
                val_plus_var=line.split('#')
                if len(val_plus_var)>1:
                    values = val_plus_var[0].strip().split()
                    if float(values[0]) > 0:
                        values[0] = "desired value"
                    else:
                        values[0] = type_of_initial_value_mapping.get(int(values[0]), values[0])
                    category_of_variable = int(values[4])
                    values[4] = category_of_variable_mapping.get(category_of_variable, values[4])
                    variable_name = line.split('#')[1].strip() if '#' in line else 'cound not read'
                    values.append(variable_name)  
                    new_row = pd.DataFrame([values], columns=column_names)          # mod lines, due to package version
                    df = pd.concat([df, new_row], ignore_index=True)
                    line_buffer=""
                else:
                    line_buffer=line.strip()
                    
    
    df['fixed, free or desired'] = df['fixed, free or desired'].astype(float)
    df['Minimum value'] = df['Minimum value'].astype(float)
    df['Maximum value'] = df['Maximum value'].astype(float)
    df['Data type of variable'] = df['Data type of variable'].astype(int)
    return df


