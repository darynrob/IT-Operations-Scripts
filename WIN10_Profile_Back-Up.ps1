function MainMenu()  # this function displays the menu
{
    Clear-Host;
    Write-Host "******************************************************************"
    Write-Host "*              Win10 Profile Back-up Script                      *"
    Write-Host "*                                                                *"
    Write-Host "* This script copies key profile folders from your desktop to    *"
    Write-Host "* the \\AWUB-FS-3466P\PROFILETEMP share and locks the folder.    *"
    Write-Host "*                                                                *"
    Write-Host "*                                                                *"
    Write-Host "* 1. Press '1' to create and secure your PROFILETEMP Folder      *"
    Write-Host "* x. Press 'A' to copy the contents of ALL profile folders       *"
    Write-Host "*                                                                *"
    Write-Host "* 2. Press '2' to copy just the CONTACTS folder and subfolders   *"
    Write-Host "* 3. Press '3' to copy just the DESKTOP folder and subfolders    *"
    Write-Host "* 4. Press '4' to copy just the DOCUMENTS folder and subfolders  *"
    Write-Host "* 5. Press '5' to copy just the DOWNLOADS folder and subfolders  *"
    Write-Host "* 6. Press '6' to copy just the FAVORITES folder and subfolders  *"
    Write-Host "* 7. Press '7' to copy just the MUSIC folder and subfolders      *"
    Write-Host "* 8. Press '8' to copy just the PICTURES folder and subfolders   *"
    Write-Host "* 9. Press '9' to copy just the VIDEOS folder and subfolders     *"
    Write-Host "* 0. Press '0' to copy a the folder of your choice               *"
    Write-Host "*                                                                *"
    Write-Host "* Q. Press 'Q' to QUIT the script                                *"
    Write-Host "*                                                                *"
    Write-Host "******************************************************************"
}

function returnmenu ($option)
{
    Clear-Host;
    Write-Host "******************************************************************"
    Write-Host "*                                                                *"
    Write-Host "* You chose option $option.                                      *"
    Write-Host "*                                                                *"
    Write-Host "******************************************************************"
    pause;
}

# Define variables
# $pathname is the path to the location on the local system where the profile directories are
# $input in the users menu choice
# $env:username is the username
# $env:computername is the local computer name
# $Contactspath is the path to the user's Contacts Directory
# $Desktoppath is the path to the user's Contacts Directory
# $Documentspath is the path to the user's Contacts Directory
# $Downloadspath is the path to the user's Contacts Directory
# $Favoritespath is the path to the user's Contacts Directory
# $Musicpath is the path to the user's Contacts Directory
# $Picturespath is the path to the user's Contacts Directory
# $Videospath is the path to the user's Contacts Directory


$pathname = 'C:\Users\' + $env:username
$PROFILETEMPPathname = '\\awub-fs-3466p\PROFILETEMP\CONTROLLED\' + $env:username

do
{
    MainMenu;
    $input = Read-Host "Your Choice:"
    switch ($input)
    {
        "1"
        {
            md $PROFILETEMPPathname
            dir $PROFILETEMPPathname
            Get-Acl $PROFILETEMPPathname
            set-acl $PROFILETEMPPathname 
            # Add-NTFSAccess -Path $PROFILETEMPPathname -Account $env:username -AccessRights FullControl -AppliesTo "ThisFolderSubfoldersAndFiles"
            pause;

        }
        "A"
        {
            $ContactsPath = $pathname + '\Contacts'
            write-host $ContactsPath
            write-host $PROFILETEMPPathname
            robocopy $Contactspath $PROFILETEMPPathname  /E /Z /XA:H /log+:$PROFILETEMPPathname\MigrationLog.txt
            pause;
        }
        "Q"
        {
            # Exit Section
            Write-host "*******************************************************************"
            Write-Host "*                             EXITING                             *"
            Write-host "*******************************************************************"
            pause;
        }
        default
        {
            Clear-host;
            Write-host "*******************************************************************"
            Write-Host "*           Invalid input. Please enter a valid option.           *"
            Write-host "*******************************************************************"
            pause;
        }
    }
} until ($input -eq "Q");


