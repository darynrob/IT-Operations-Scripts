<#
    Purpose: This script is intended to create Active Directory Computer accounts
             within the Barksdale AFB Computers OU
#>

#Script variables
$AD = [ADSI]"LDAP://DC=AREA52,DC=AFNOAPPS,DC=USAF,DC=MIL"
$ComputersOU = [DirectoryServices.DirectoryEntry][ADSI]"LDAP://OU=Barksdale AFB Computers,OU=Barksdale AFB,OU=AFCONUSWEST,OU=Bases,DC=AREA52,DC=AFNOAPPS,DC=USAF,DC=MIL"
${CFP-CSA} = [DirectoryServices.DirectoryEntry][ADSI]"LDAP://CN=GLS_Barksdale_CFP-CSA,OU=Barksdale AFB,OU=Administrative Groups,OU=Administration,DC=AREA52,DC=AFNOAPPS,DC=USAF,DC=MIL"
$L = "Barksdale AFB"

#Hides console window
$WindowCode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
$AsyncWindow = Add-Type -MemberDefinition $WindowCode -name Win32ShowWindowAsync -Namespace Win32Functions -PassThru
[void]$AsyncWindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)

#region STA/Admin Check
$Admin? = ([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).Groups -match "S-1-5-32-544"))

If ($Host.Runspace.ApartmentState -notmatch "STA" -or !$Admin?)
{
    Start-Process PowerShell.exe -Verb RunAs -ArgumentList ("-STA -File `"$($MyInvocation.MyCommand.Definition)`""); Exit
}

#endregion STA/Admin Check

#region GUI

#XAML GUI Code
$XAML = @"
<Window x:Class="WpfApplication1.MainWindow"
	    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
	    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Name="Window" Title="Create AD Computer - Barksdale" Height="222" Width="310" Background="#333333" ResizeMode="NoResize">
    <Grid>
        <TextBox Name="UniqueID" Margin="150,71,5,90" TextWrapping="Wrap" MaxLength="6" FontFamily="Segoe UI Semibold"/>
        <TextBox Name="ComputerName" IsReadOnly="True" Margin="150,112,5,49" TextWrapping="Wrap" FontFamily="Segoe UI Semibold"/>

        <Button Name="CreateBtn" Content="Create" Margin="150,150,5,5" Background="#FF555555" Foreground="#FFFDFDFD" IsEnabled="False" FontFamily="Segoe UI Semibold"/>

        <GroupBox Margin="135,10,5,120">
	        <Grid>
	            <RadioButton Name="Workstation" Content="Workstation" Margin="5,3,0,0" VerticalAlignment="Top" HorizontalAlignment="Left" Foreground="#FFDBDCDD" FontFamily="Segoe UI Semibold"/>
                <RadioButton Name="Laptop" Content="Laptop" Margin="5,18,0,0" VerticalAlignment="Top" HorizontalAlignment="Left" Foreground="#FFDBDCDD" FontFamily="Segoe UI Semibold"/>
                <RadioButton Name="Tablet" Content="Tablet" Margin="5,33,0,0" VerticalAlignment="Top" HorizontalAlignment="Left" Foreground="#FFDBDCDD" FontFamily="Segoe UI Semibold"/>
	        </Grid>
	    </GroupBox>

        <TextBox Name="Message" Margin="5,150,148,5" BorderThickness="1" VerticalContentAlignment="Center" Background="#333333" Foreground="#FFDBDCDD" BorderBrush="Black" IsReadOnly="True" FontFamily="Segoe UI Semibold"/>

        <TextBlock Text="Computer Type:" Margin="5,5,0,0" HorizontalAlignment="Left" VerticalAlignment="Top" Foreground="#FFDBDCDD" FontSize="16" FontFamily="Segoe UI Semibold"/>
        <TextBlock Text="Unique Identifier:" HorizontalAlignment="Left" Margin="5,70,0,0" VerticalAlignment="Top" Foreground="#FFDBDCDD" FontSize="16" FontFamily="Segoe UI Semibold"/>
        <TextBlock Text="Computer Name:" Margin="5,110,0,0" HorizontalAlignment="Left" VerticalAlignment="Top" Foreground="#FFDBDCDD" FontSize="16" FontFamily="Segoe UI Semibold"/>
    </Grid>
</Window>
"@

#Makes Changes to XAML code
$XAML = $XAML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'

#Loads Presentationframework.dll
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')

#Converts XAML to XML
[xml]$XML = $XAML

#Loader
$GUI = [Windows.Markup.XamlReader]::Load((new-object System.Xml.XmlNodeReader $XML))

#Creates Variables
$XML.SelectNodes("//*[@Name]") | Foreach {Set-Variable -Name $_.Name -Value $GUI.FindName($_.Name)}

#endregion GUI

#region UI Event Handlers

$Workstation.add_Checked({
    #Keeps UniqueID
    $ComputerName.Text = "AWUBW-$($UniqueID.Text)"
    #Sets Prefix
    $Global:Prefix = "AWUBW-"
    #Sets Focus to UniqueID
    $UniqueID.Focus()
})

$Laptop.add_Checked({
    #Keeps UniqueID
    $ComputerName.Text = "AWUBL-$($UniqueID.Text)"
    #Sets Prefix
    $Global:Prefix = "AWUBL-"
    #Sets Focus to UniqueID
    $UniqueID.Focus()
})

$Tablet.add_Checked({
    #Keeps UniqueID
    $ComputerName.Text = "AWUBT-$($UniqueID.Text)"
    #Sets Prefix
    $Global:Prefix = "AWUBT-"
    #Sets Focus to UniqueID
    $UniqueID.Focus()
})

$UniqueID.add_TextChanged({

    #Shows Final Computer Name
    $ComputerName.Text = $Global:Prefix + $UniqueID.Text

    #Enables or Disables Button based on ComputerName Length
    If ($ComputerName.Text.Length -ge 12)
    {
        $CreateBtn.IsEnabled = $True
    }
    Else 
    {
        $CreateBtn.IsEnabled = $False
    }
})

$CreateBtn.add_Click({
    #Creates Computer
    $Computer = $ComputersOU.Create("computer", "CN=$($ComputerName.Text)")

    #Sets a Few Properties
    $Computer.Put("sAMAccountName", $ComputerName.Text + "$")
    $Computer.Put("Description", [String]${CFP-CSA}.Name)
    $Computer.Put("userAccountControl", 4096)
    $Computer.Put("l", $L)

    #Sets Info
    $Computer.SetInfo()

    #Tests If Created
    $Searcher = New-Object DirectoryServices.DirectorySearcher
    $Searcher.Filter = "Name=$($ComputerName.Text)"
    $Test = $Searcher.FindOne()
    If ([bool]$Test)
    {
        $Message.Foreground = "#FFDBDCDD"
        $Message.Text = "Creation Verified"

        $UniqueId.Text = ""
        $Workstation.IsChecked = $False
        $Laptop.IsChecked = $False
        $Tablet.IsChecked = $False
        $ComputerName.Text = ""
    }
    Else
    {
        $Message.Foreground = "Red"
        $Message.Text = "Not Created"
    }
})

$Window.Add_keyDown({
    If ($Args[1].key -eq 'Return')
    {
        $Message.Foreground = "Orange"
        If ($ComputerName.Text.Length -eq 0)
        {
            $Message.Text = "Fill Out Form."
        }
        ElseIf ($ComputerName.Text.Length -lt 12)
        {
            $Message.Text = "Not Long Enough"
        }
        Else
        {
            $Message.Text = "Click The Button"
        }
    }
})

#endregion UI event handlers

#Shows GUI
$GUI.ShowDialog()