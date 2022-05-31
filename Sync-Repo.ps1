# checks the current commit hash in a git repo
# against an older hash from a previous run of the script
# if the hash isn't the same, the repo will be hard reset to origin/HEAD
# and then cleaned.
# includes a small log outputter with date-time and basic log output
# (C) the-real-grinny 2022
<#
  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
#>

$hashes = &git log --pretty=format:"%H" -2

$current = $hashes[0]

$previous = Get-Content -Path .\hash.txt

function Update-LogFile {
    param (
        [string] $logtext
    )
    Out-File -FilePath .\log.txt -InputObject $logtext -Append
}

if ($hashes[0] -ne $previous) {
    Write-Output "Hash has changed since script last ran"
    Write-Output "Reverting to origin repo"

    Update-Logfile -logtext "$(Get-Date -UFormat "%m/%d/%Y %R %Z") - Hash was modified with value $($hashes[0]); reverted to $($previous)"

    &git reset --hard
    &git clean -f -d

    Write-Output "Repo reset to origin HEAD"
    Write-Output "Any new untracked files were removed and modified ones were reverted."

    # get hashes again after reset
    $hashes = &git log --pretty=format:"%H" -2

    # set current newest hash as the "previous" that will be checked against next time
    Out-File -FilePath .\hash.txt -InputObject $hashes[0]

    Update-Logfile -logtext "$(Get-Date -UFormat "%m/%d/%Y %R %Z") - repo reset to origin/HEAD; canonical hash set to $($hashes[0])"

} else {
    Write-Output "Hash has not changed"
    Update-Logfile -logtext "$(Get-Date -UFormat "%m/%d/%Y %R %Z") - hashes unchanged from $previous; no action taken"
}

