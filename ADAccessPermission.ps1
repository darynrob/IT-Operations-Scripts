# By A1C Roberts
# This is an attempt to grant users within organization full priviledged access


$SharedMailbox = "SharedMailboxName"
$ADAccessGroup = "ADAccessGroupName"

Add-MailboxPermission -Identity $ADAccessGroup -User $SharedMailbox -AccessRights FullAccess -InheritanceType All