# gets all users that have EITHER not logged in for the last 180 days, or have not changed their password in 90 days.
# and deposits them in the staleusers.csv in the same directory you ran the script in.
# (C) the-real-grinny 2022
<#
  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
#>

$office = ""

$login = [DateTime]::Today.AddDays(-180) # last log on 
$pw = [DateTime]::Today.AddDays(-90) # last pw change
Get-ADUser -Filter '((Enabled -eq $True) -and (Office -eq $Office) -and ((PasswordLastSet -lt $pw) -or (LastLogonTimestamp -lt $login)))' -Properties DistinguishedName,SamAccountName,PasswordLastSet,LastLogonTimestamp,Enabled,Office,Title | ft SamAccountName,Name,Title,Office,PasswordLastSet,@{N="LastLogonTimestamp";E={[datetime]::FromFileTime($_.LastLogonTimestamp)}},Enabled,DistinguishedName > staleusers.csv
