# Find all users inside a $targetgroup (could be an SG, an OU, it just needs to be a listof AD User objects)
# And then check if any $user inside that $targetgroup also is in other groups in $MYADGROUPS,
# which I would normally set with $myadgroups = Get-ADPrincipalGroupMembership -Identity "whatever user I want"
# With the optional provision that "WHATEVER GROUP I'M IN" is excluded from the results.
# (C) the-real-grinny 2022
<#
  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
#>

$myadgroup = Get-ADPrincipalGroupMembership -Identity "whatever user I want to compare with"

$basegroup = "" # I'd usually put the group's Name or Alias here that I want to source users from

foreach ($user in $targetgroup) {
    $user | Get-ADPrincipalGroupMembership | ForEach-Object <# the $_.name -like part is optional. It allows you to more strictly check group names #> {if (<#($_.name -like "**") -and#> !($_.name -eq $basegroup) -and ($_.name -in $myadgroups)) { write-host $user is also in group $_.name}}
}
