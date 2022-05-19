Class Parser{
    [string] $Name;
    [string] $OriginalQuery;
    [string] $Schema;
    [System.Collections.Generic.List`1[System.Object]] $Parameters
    Parser([string] $Name, [string] $OriginalQuery, [string] $Schema, [System.Collections.Generic.List`1[System.Object]] $Parameters) {
        $this.Name = $Name;
        $this.OriginalQuery = $OriginalQuery;
        $this.Schema = $Schema;
        $this.Parameters = $Parameters;
    }
 
    Test() {
        Write-Host "Testing parser- '$($this.Name)'"
        $letStatementName = "generated$($this.Name)"
        $parserAsletStatement = "let $($letStatementName)= ($(getParameters($this.Parameters))) { $($this.OriginalQuery) };"

        Write-Host "-- Running schema test for '$($this.Name)'"
        $schemaTest = "$($parserAsletStatement)`n$($letStatementName) | getschema | invoke ASimSchemaTester('$($this.Schema)')"
        invokeTest $schemaTest $this.Name "schema"

        Write-Host "-- Running data test for '$($this.Name)'"
        $dataTest = "$($parserAsletStatement)`n$($letStatementName) | invoke ASimDataTester('$($this.Schema)')"
        invokeTest $dataTest  $this.Name "data"
    }
}

function invokeTest([string] $test, [string] $name, [string] $kind) {
    $query = $test + " | where Result startswith '(0) Error:'"
    try {
        # $rawResults = Invoke-AzureRmOperationalInsightsQuery -WorkspaceId "6b57e303-6aa4-4f18-b3ba-b2f816756897" -Query $query -ErrorAction Stop
        $rawResults = Invoke-AzOperationalInsightsQuery -WorkspaceId "059f037c-1b3b-42b1-bb90-e340e8c3142c" -Query $query -ErrorAction Stop
        if ($rawResults.Results)
        {
            $resultsArray = [System.Linq.Enumerable]::ToArray($rawResults.Results)
            if ($resultsArray.count) {  
                $errorMessage = "`n$($name) $($kind)- test failed with $($resultsArray.count) errors:`n"        
                $resultsArray | ForEach-Object { $errorMessage += "$($_.Result)`n" } 
                Write-Error $errorMessage
            } else {
                Write-Host "  -- $($name) $($kind) test done successfully"
            }
        }    
    } catch {
        Write-Error $_.Exception
    }

    
}

function run {
    # $subscription = Select-AzureRmSubscription -SubscriptionId "de5fb112-5d5d-42d4-a9ea-5f3b1359c6a6"
    $subscription = Select-AzSubscription -SubscriptionId "419581d6-4853-49bd-83b6-d94bb8a77887"
    $schemas = ("DNS", "WebSession", "NetworkSession");
    $schemas | ForEach-Object { testSchema($_) }
}

function testSchema([string] $schema) {
    $parsersObjects = & "./ConvertYamlToObject.ps1" -Path "../../../Parsers/ASim$($schema)/Parsers"
    Write-Host "Testing $($schema) schema, $($parsersObjects.count) parsers were found"
    $parsersObjects | ForEach-Object {
        $functionName = "$($_.EquivalentBuiltInParser)V$($_.Parser.Version.Replace('.',''))"
        if ($_.Parsers){
            Write-Host "The parser '$($functionName)' is a main parser, ignoring it"
        } else {
            $parser = [Parser]::new($functionName, $_.ParserQuery, $schema, $_.ParserParams)
            $parser.Test()
        }
    }
}

function getParameters {
    param (
        [System.Collections.Generic.List`1[System.Object]] $parserParams
    )

    $paramsArray = @()
    if ($parserParams){
        $parserParams | ForEach-Object {
            if ($_.Type -eq "string") {
                $_.Default = "'{0}'" -f $_.Default
            }
            $paramsArray += ("{0}:{1}= {2}" -f $_.Name,$_.Type,$_.Default)
        }

        return $paramsArray -join ','
    }
    return $paramsString
}

run