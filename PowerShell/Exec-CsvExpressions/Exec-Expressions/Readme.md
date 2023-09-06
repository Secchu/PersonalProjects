Description
===========
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

Example 1
=========
For safety the commandlet does nothing and simply prints out the parsed expressions. You will need
to set Dryrun parameter to false to actually execute the expressions. Read the script and its comments For
more details.

.\Exec-CsvExpressions.ps1 -Cm New-AdUser -File Users1.csv -Dryrun:$false

The above cmdlet will execute the New-AdUser cmdlet and read the parameters and its values from Users1.CSV

Example 2
=========
.\Exec-CsvExpressions.ps1 -Cm New-AdUser -File Users2.csv -Dryrun:$false

The above cmdlet will execute the New-AdUser cmdlet and read the parameters and its values from Users2.CSV.
Users2.csv has the same format as Users1.csv however it contains a column header called WhatIf so in the
end doesn't execute any commandlet however demonstrates that you can include switch like parameters and 
leave an empty string as a value in the CSV file.

Example 3
=========
.\Exec-CsvExpressions.ps1 -Cm New-AdComputer -File Computers.csv -Dryrun:$False

The above commnd will execute the New-AdComputer cmdlet and read the parameters and its values
from Computers.csv