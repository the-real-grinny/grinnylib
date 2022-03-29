# grinnylib
Just a pile of powershell scripts. They're usually kinda bespoke and solve specific problems, but they might be helpful for somebody who needs to also do those specific things to solve those specific problems.

## dedspool.ps1
Simple script you run locally to kill a print spooler service, remove spooler files (so long as they aren't being used) and restart the spooler.

## Get-OldEnabledUsers.ps1
Easy way to find users that are still Enabled inside an Active Directory but haven't logged in or changed password in a while.

## Find-AllUsersInSameGroup.ps1
Compares a user inside a group with all the users in that group, and finds out if any users have other, additional groups in common with the targeted user.

## Get-MFAUsers.ps1
Grabs users from an MSOnline connection and finds out how (or if) their MFA is configured, and then dumps the info into a CSV.
