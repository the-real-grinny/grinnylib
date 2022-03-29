# pulls all users from the MSOnline user list
# and then checks their MFA status
# and outputs it into a CSV at PWD
# (C) the-real-grinny 2022
<#
  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
#>

Import-Module MSOnline

Connect-MsolService

$users = Get-MsolUser -All

$MFADataDef = @"
public class MFAUserData
{
    public string UPN;
    public string Requirement;
    public string Methods;
}
"@

Add-Type -TypeDefinition $MFADataDef

foreach ($user in $users) {
    $output = New-Object -TypeName MFAUserData
    $output.UPN = $user.UserPrincipalName
    $output.Requirement = ($User | Select-Object -ExpandProperty StrongAuthenticationRequirements).State
    $output.Methods = ($User | Select-Object -ExpandProperty StrongAuthenticationMethods).MethodType
    $MFAStatus = "$($output.Requirement), $($output.Methods)"
    $output | Select-Object -Property UPN,Requirements,Methods | Export-Csv -Path .\test.csv -NoTypeInformation -Append
}
