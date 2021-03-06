 <# 
    .SYNOPSIS
     Prompt user for Bitlocker password after bitlocker/TPM has already been enabled.

    .NOTES 
     NAME: Set-BitlockerPIN.ps1
	 VERSION: 1.2
     AUTHOR: Daniel Tsekhanskiy
     LASTEDIT: 11/9/16
#>

#Loop until the user hits cancel, there is an error, or the PIN is set
Do
{

#Continue until there is an error
Try
{
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.TextBox")

#Container size, position, and title
$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Startup Password Setup"
$objForm.Size = New-Object System.Drawing.Size(450,185) 
$objForm.StartPosition = "CenterScreen"

#Form Icon - uncomment to add icon from current directory
#$objform.Icon = New-Object system.drawing.icon (".\Icon.ICO")

#Disable Maximize button
$objForm.MaximizeBox = $false
$objForm.FormBorderStyle = 'FixedSingle'

#Enter and Esc actions
$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$w=$objTextBox.Text;$x=$objTextBox2.Text;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})
    
#OK button
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(345,84)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({$Script:w=$objTextBox.Text;$Script:x=$objTextBox2.Text;$objForm.Close()})
$objForm.Controls.Add($OKButton)
$objForm.AcceptButton = $OKButton
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK

#Cancel Button
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(345,115)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)

#Font Type/size/etc
$FontBold = new-object System.Drawing.Font("Arial",8)

#Main message
$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(5,8) 
$objLabel.Size = New-Object System.Drawing.Size(445,70)
$objLabel.Font = $fontBold
$objLabel.text = "Company requires all laptop's be password protected.

You will be asked to enter this password every time you restart your laptop.

The password must be at least 7 characters long, and include no special characters."
$objForm.Controls.Add($objLabel)

#"Password:" text
$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(8,89) 
$objLabel.Size = New-Object System.Drawing.Size(60,20)
$objLabel.Text = "Password:"
$objForm.Controls.Add($objLabel)

#"Confirm Password:" text
$objLabel2 = New-Object System.Windows.Forms.Label
$objLabel2.Location = New-Object System.Drawing.Size(8,112) 
$objLabel2.Size = New-Object System.Drawing.Size(60,28)
$objLabel2.Text = "Confirm Password:"
$objForm.Controls.Add($objLabel2)

#Obfuscate entered password
$objTextBox = New-Object System.Windows.Forms.TextBox
$objTextBox.Location = New-Object System.Drawing.Size(70,87)
$objTextBox.PasswordChar = '*'
$objTextBox.Size = New-Object System.Drawing.Size(260,20)
$objForm.Controls.Add($objTextBox)

#Obfuscate re-entered password
$objTextBox2 = New-Object System.Windows.Forms.TextBox
$objTextBox2.Location = New-Object System.Drawing.Size(70,117)
$objTextBox2.PasswordChar = '*'
$objTextBox2.Size = New-Object System.Drawing.Size(260,20) 
$objForm.Controls.Add($objTextBox2)

#Disable OK Button by default. Enable when there is text in both textbox's
$OKButton.Enabled = $false
$objTextBox.add_TextChanged -and $objTextBox2.add_TextChanged({ Checkfortext })

function Checkfortext
{ 
	if ($objTextBox.Text.Length -ne 0 -and $objTextBox2.Text.Length -ne 0) 
	{
		$OKButton.Enabled = $true
	}
	else
	{
		$OKButton.Enabled = $false
	}
}

$objForm.Topmost = $True
$handler = {$objForm.ActiveControl = $objTextBox}

$objForm.add_Load($handler)
$objForm.Add_Shown({$objForm.Activate()})
[Void] $objForm.ShowDialog()

#If the values entered are not empty, null, and equal eachother
if (!([string]::IsNullOrEmpty($x)) -and ($w -ceq $x) -and ($objTextBox.Text -match '^[a-zA-Z0-9\s]+$') -and ($objTextBox.Text.Length -ge 7)) {
[System.Windows.Forms.MessageBox]::Show("PIN will now be set.","Passwords Match")
[System.Windows.Forms.MessageBox]::Show((manage-bde.exe -protectors -add c: -TPMAndPIN $x),"Please show this to your System Administrator if there was an error.")
exit

} 
#If the values entered are empty or null
elseif (([string]::IsNullOrEmpty($w)) -or ([string]::IsNullOrEmpty($x)) -and ($objForm.DialogResult -ne "Cancel")) {
$OUTPUT=[System.Windows.Forms.MessageBox]::Show("Password was not entered. Try Again?", "Error","RetryCancel","Error")
$objTextBox.Text
$w
}

#If special characters were entered
elseif (($objTextBox.Text -notmatch '^[a-zA-Z0-9\s]+$') -and ($objForm.DialogResult -ne "Cancel")) {
$OUTPUT=[System.Windows.Forms.MessageBox]::Show("Password cannot contain special characters. Try Again?", "Error","RetryCancel","Error")
}

#If the values don't equal
elseif (($w -ne $x) -and ($objForm.DialogResult -ne "Cancel")) {
$OUTPUT=[System.Windows.Forms.MessageBox]::Show("Password do not match. Try Again?", "Error","RetryCancel","Error")
}

#If the values entered are not long enough
elseif (($objTextBox.Text.Length -lt 7) -and ($objForm.DialogResult -ne "Cancel")) {
$OUTPUT=[System.Windows.Forms.MessageBox]::Show("Password must be at least 7 characters. Try Again?", "Error","RetryCancel","Error")
}

#Anything else
else { exit }

#Clear any entered values between loops
if ($w) { Clear-Variable w }
if ($x) { Clear-Variable x }

}

Catch
{
[System.Windows.Forms.MessageBox]::Show($_.Exception.Message,"Please forward this error to your System Administrator") 
}

}
#Keep looping if user selects "Retry" on a failed entry
while ($OUTPUT -eq "Retry")


