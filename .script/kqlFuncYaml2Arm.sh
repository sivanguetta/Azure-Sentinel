#!/bin/bash

failed=0

# The KqlFuncYaml2Arm script generates deployable ARM templates from KQL function YAML files.
# Currently, the script only runs on the Schemas listed below.
parsersSchemas=(ASimDns ASimNetworkSession ASimWebSession ASimProcessEvent)
for schema in ${parsersSchemas[@]}
	do  
		filesThatWereChanged=$(echo $(git diff origin/master  --name-only -- Parsers/$schema/))
		if [ "$filesThatWereChanged" = "" ]; then 
			echo No files were changed under Azure-Sentinel/Parsers/$schema/
		else
			echo Regenerate ARM templates under Azure-Sentinel/Parsers/$schema/ARM
			echo $filesThatWereChanged
			rm -rf Parsers//$schema/ARM
			python ASIM/dev/ASimYaml2ARM/KqlFuncYaml2Arm.py -m asim -d Parsers//$schema/ARM Parsers//$schema/Parsers
		fi
	done

exit $failed
