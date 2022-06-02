# checks the current commit hash in a git repo
# against an older hash from a previous run of the script
# if the hash isn't the same, the repo will be hard reset to origin/HEAD
# and then cleaned.
# also handles individual, untracked and uncommitted changes.
# basically if you want anything in the repo directory to survive,
# then make sure it's tracked in git.
# includes a small log outputter with date-time and basic log output

# really this is intended to run as a Task Scheduler script on a given directory
# but you can run it manually whenever

# (C) the-real-grinny 2022
<#
  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
#>

try {

    $hash = &git log --pretty=format:"%H" -1

    $current = $hash

    if ((Get-Item .\hash.txt).exists -eq $true) {

        $previous = Get-Content -Path .\hash.txt

    }

} catch {

    Write-Error "THIS IS NOT A GIT REPO. SCRIPT IS FAILING."
    Exit "0x2 Git repo could not be found."
}

function Update-LogFile {
    param (
        [string] $logtext
    )

    Out-File -FilePath .\log.txt -InputObject $logtext -Append
}

function Remove-FileChanges {
    param (
        [string] $RepoDir
    )

    Set-Location $RepoDir

    &git fetch

    &git checkout . # essentially reverts the repo back to the most recent commit's status, removing uncommitted changes

}

function Restore-Repo {
    # this function is only useful if changes have been _committed_ to the repo independently, and haven't come from prod.
    # and, though it might not be apparent, this logic can force an update to origin in the event that
    # A, the origin/prod branch has been updated, B, the local repo has had committed changes separate of origin, and C, this script runs.
    # considering that the whole point is to keep the repo synced with origin/prod I don't consider that undefined behavior. Just inadvertent. 

    if ((get-item .\hash.txt).exists -eq $true -and $previous -ne $hash) {

            # won't run unless hash file exists first, _and_ the hash gathered doesn't match the one in the file.
            # next elseif will handle if the hash file doesn't exist.

            Write-Output "Hash has changed since script last ran"
            Write-Output "Reverting to origin repo"

            Update-Logfile -logtext "$(Get-Date -UFormat "%m/%d/%Y %R %Z") - Hash was modified with value $($hash); reverted to $($previous)"

            &git reset --hard
            &git clean -f -d

            Write-Output "Repo reset to origin HEAD"
            Write-Output "Any new untracked files were removed and modified ones were reverted."

            # get hashes again after reset
            $hash = &git log --pretty=format:"%H" -1

            # set current newest hash as the "previous" that will be checked against next time
            Out-File -FilePath .\hash.txt -InputObject $hash

            Update-Logfile -logtext "$(Get-Date -UFormat "%m/%d/%Y %R %Z") - repo reset to origin/HEAD; canonical hash set to $($hash)"

        } elseif ((get-item .\hash.txt).exists -eq $false) {

            # same as the above code block but only fires if the hash.txt file doesn't exist yet.
            
            Write-Output "Hash history file doesn't exist. Treating repo as if it's a new pull."
            Update-LogFile -logtext "$(Get-Date -UFormat "%m/%d/%Y %R %Z") - Hash history file didn't exist. Resetting to head and creating file."

            &git reset --hard
            &git clean -f -d

            Write-Output "Repo reset to origin HEAD"
            Write-Output "Any new untracked files were removed and modified ones were reverted."        
            
            Out-File -FilePath .\hash.txt -InputObject $hash

            Update-Logfile -logtext "$(Get-Date -UFormat "%m/%d/%Y %R %Z") - repo reset to origin/HEAD; canonical hash set to $($hash)"
        
        } else {

            # if the hashes haven't changed, nothing really needs to be reverted, since Remove-FileChanges fires in parent scope before Restore-Repo does.
            # so the script will just `git pull` and therefore grab any updates from prod that haven't already come down.
            Write-Output "Hash has not changed, making a pull from origin"
            Update-Logfile -logtext "$(Get-Date -UFormat "%m/%d/%Y %R %Z") - hashes unchanged from $previous; pulling from origin and saving hash to file"

            &git pull
            $hash = &git log --pretty=format:"%H" -1
            Out-File -FilePath .\hash.txt -InputObject $hash
        }

}

function Main {

    param (
        [string] $RepoDir
    )

    $current = pwd

    Remove-FileChanges -RepoDir $RepoDir # this will take care of repo's that have only drifted without committing their changes

    # Since Remove-FileChanges always runs, that's also where a possibly redundant &git fetch lives.

    # in the event that changes _have_ been committed, that's what Restore-Repo is for.

    Restore-Repo

    cd $current.Path # after all is said and done, bring you back to wherever you were when the main function started running.

}

Main
