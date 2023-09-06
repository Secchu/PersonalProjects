<#
 .Description
    This script automates execution of a Powershell cmdlet where the parameters are read from a CSV File
    and the whole parsed expression is executed as a Powershell commandlet. It uses Invoke-Expression
    commandlet to execute the expression.

    Note that this is a very basic script and only deals with simple types. It definitely has potential
    to be improved as a powerful expression reader however it only deals with simple types. Arguments
    that don't start with a dollar sign are assumed to be string and are therefore surrounded in quotes
    so when the Invoke-Expression commandlet is invoked it will recognize string variables from other simple
    types.

    It shows the power of Powershell that even with a simple script it can achieve so much. What this
    script is missing is code to parse strings as objects. I don't recommend putting credentials as
    in CSV files but I am using this as an example. The script doesn't parse objects so we cannot include
    Credentials as a header.

    The script doesn't recognize other commandlets so we cannot use -Get-Credential or Get-ADDomain. If
    this was included it would be extremely powerful. I going to leave that task to you.

 .Parameter Cm
  This is a mandatory parameter and it is the Powershell commandlet to execute. It has the following aliases
  Cmdlet, PS and Cmd
 
 .Parameter File
  This is an optional parameter and it is the CSV file that contains the expressions. If this is absent it
  will use the file expressions.csv in the current working directory. It has the following aliases PSFile,
  Csv,"Expressions"

 .Parameter Dryrun
  This is an optional switch parameter. For safety reasons the commandlet will not execute any expressions
  because the default value of this parameter is $True. The commandlet will simply output all the 
  expressions. Set this switch to $False to execute all the parsed expressions.
 
 .Example
    Print all parsed expressions without executing with the default filename expressions.csv and use the New-ADUser
    commandlet reading all the parameters and values from the CSV file.

    .\Exec-CsvExpressions.ps1

.Example
    Print all parsed expressions from filename users1.csv and use the New-ADUser
    commandlet reading all the parameters and values from the CSV file.

    .\Exec-CsvExpressions.ps1 -Cm New-AdComputer -File Users1.csv

.Example
    Execute all parsed expressions from filename users1.csv and use the New-ADUser
    commandlet reading all the parameters and values from the CSV file.

    .\Exec-CsvExpressions.ps1 -Cm New-AdComputer -File Users1.csv -Dryrun:$False

#>

[CmdletBinding()]
param (
        [Parameter(Position=0,mandatory=$true)]
        [Alias("Cmdlet","PS","Cmd")]
        [string]$Cm,
        [Parameter(Position=1,mandatory=$False)]
        [Alias("PSFile","Csv","Expressions")]
        [string]$File  = "expressions.csv",
        [Parameter(Position=2,mandatory=$False)]
        [Alias("WhatIf","DR","TestCsv")]
        [switch]$Dryrun = $True
     )
	
function Add-QuotesToStringVar{
	param (
        [Parameter(Position=0,mandatory=$true)]
        $var
	)
    
    if(!$var)
        {return $var}

    if($var.ToString().StartsWith('$'))
        { return $var }
    else
        { return '"' + $var.ToString() + '"' }

}

function Exec-CsvExpressions{
[CmdletBinding()]
param (
        [Parameter(Position=0,mandatory=$true)]
        [Alias("Cmdlet","PS","Cmd")]
        [string]$Cm,
        [Parameter(Position=1,mandatory=$False)]
        [Alias("PSFile","Csv","Expressions")]
        [string]$File  = "expressions.csv",
        [Parameter(Position=2,mandatory=$False)]
        [Alias("WhatIf","DR","TestCsv")]
        [switch]$Dryrun = $True
     )
$content = Import-Csv $File

$list = @()

    for($i=0; $i -lt $content.Count;$i++)
    {
        $headers = $content | get-member -MemberType NoteProperty | select-object -ExpandProperty 'Name'
        $psExpression = ""

        for($x=0; $x -lt $headers.Count;$x++)
        {
            $paramValue = $content[$i] | Select -ExpandProperty $headers[$x]
            $var = Add-QuotesToStringVar -var $paramValue
            $psExpression += "-" + $headers[$x].ToString() + " " + $var + " "
        }

        $pscmd = $Cm + " " + $psExpression.TrimEnd()

        $list += $pscmd

    }

    if($Dryrun)
    {
        Write-Host "The following Comandlets would have executed if Dryrun is set to false`n"

        for($i=0; $i -lt $list.Count;$i++)
        {
            Write-Host $list[$i]
            Write-Host "`n"
        }

        Write-Warning "Be sure that the cmdlets are correct before setting Dryrun to False"
        Write-Warning "Note there is no error checking involved"
    }
    else
    {
        Write-Host "Executing all expressions for real`n"

        for($x=0; $x -lt $list.Count;$x++)
        {
            $output = "Executing cmdlet: " + $list[$x] + "`n"
            Write-Host $output
            Invoke-Expression $list[$x]
        } 

        Write-Host "Finished executing all expressions"
    }
}

Exec-CsvExpressions -Cm $Cm -File $File -Dryrun:$Dryrun





