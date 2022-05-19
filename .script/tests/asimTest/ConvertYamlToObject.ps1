<#
.SYNOPSIS
    Convert YAML file to object
.DESCRIPTION
    This function converts the Microsoft Sentinel rules published on Microsoft Sentinel GitHub in YAML format to the right ARM JSON format
.EXAMPLE
    ConvertSentinelRuleFrom-Yaml -Path './PathToYamlFolder'
    In This example all the YAML files in the folder will be converted to the right JSON format in the same folder
.EXAMPLE
    ConvertSentinelRuleFrom-Yaml -Path './pathToYAMLFolder' -OutputFolder ./PathToJsonFolder
    In this example all the YAML files in the fodler will be converted to JSON and exported to the OutPutFolder
.EXAMPLE
    ConvertSentinelRuleFrom-Yaml -Path './.tmp/ASimDNS/imDns_DomainEntity_DnsEvents.yaml'
    In this example one specific YAML file will be converted to the right JSON format
.PARAMETER Path
    Specifies the object to be processed.  ou can also pipe the objects to this command.
.OUTPUTS
    Output is the JSON file
.NOTES
    AUTHOR: P.Khabazi
    LASTEDIT: 16-03-2022
#>

param($Path)

function ConvertYamlToObject {
    [CmdletBinding()]
    param (
        [System.IO.FileInfo] $Path
    )

    if (Get-Module -ListAvailable -Name powershell-yaml) {
        Write-Host "Module already installed"
    }
    else {
        Write-Host "Installing PowerShell-YAML module"
        try {
            Install-Module powershell-yaml -AllowClobber -Force -ErrorAction Stop
            Import-Module powershell-yaml
        }
        catch {
            Write-Error $_.Exception.Message
            break
        }
    }

    <#
        Test if path exists and extract the data from folder or file
    #>
    if ($Path.Extension -in '.yaml', '.yml') {
        Write-Verbose "Singel YAML file selected"
        try {
            $content = Get-Item -Path $Path -ErrorAction Stop
        }
        catch {
            Write-Error $_.Exception.Message
        }
    }
    elseif ($Path.Extension -in '') {
        Write-Verbose "Folder defined"
        try {
            $content = Get-ChildItem -Path $Path -Filter *.yaml -Recurse -ErrorAction Stop
        }
        catch {
            Write-Error $_.Exception.Message
        }
    }
    else {
        Write-Error 'Wrong Path please see example'
    }

    <#
        If any YAML file found starte lopp to process all the files
    #>
    if ($content) {
        Write-Host "'$($content.count)' templates found to convert"

        $data = @()
        # Start Loop
        $content | ForEach-Object {
            # Update the template format with the data from YAML file
            $convert = $_ | Get-Content -Raw | ConvertFrom-Yaml -ErrorAction Stop
            $data += $convert

        }
    }
    else {
        Write-Error "No YAML templates found"
        break
    }

    return $data
}

ConvertYamlToObject -Path $Path