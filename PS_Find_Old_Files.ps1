#By Andrew Pimpo
#06/27/19

#USE________________________________________________________
#	Used to build a profile of a directory for file "weeding".
#
#TUTORIAL___________________________________________________
#	Use -path to designate a file directory and -fileAge to denote
#	the age (in days) of files you want to find. For example:
##
# c:\PS_Scripts\**PS_FILE_NAME**.ps1 
# -fileAge 90
# -Select "Downloads" in window 
##
#	This line will find all files in the Downloads directory that are 90 days old.


param([string]$path, [string]$filter,  [int]$fileAge)

function find-Space ([string]$path, [string]$filter, [string]$fileAge)
{

	#Create list
	$P = (Get-ChildItem -path $path -filter $filter -Recurse | Where-Object {$_.CreationTime -lt (Get-Date).AddDays(-$fileAge)})
	
	#Grab measures
	$totalSpace = $P | Measure-Object -property Length -Sum
	
	#Grab Comparison
	$compare = Get-ChildItem -path $path -Recurse | Measure-Object -property Length -Sum
	
	#Send measures to variables
	[string]$age = ("Report for Files Over $fileAge days old: {0}" -f (Get-Date))
	[string]$total = ("`nSpace Taken by Old Files:      {0:N2}MB" -f ($totalSpace.sum / 1MB))
	[string]$c1 = ("`r`nDirectory Size:                {0:N2}MB" -f ($compare.sum / 1MB))
	[string]$c2 = ("`r`n - - Percentage Taken:        {0:N2}%" -f (($totalSpace.sum / $compare.sum)*100))
	[string]$count = ("`nCount Files: {0}" -f $totalSpace.count)
	
	#File-naming scheme
	[string]$sumFile = "PS_File_Summary_$(Get-Date -UFormat '%Y-%m-%d').txt"
	
	#Create output string
	[string]$output = $age + "`r`n- - - - - - - - - - - - - - - -`r`n`r`n" + $total + $c1 + $c2 + "	`r`r" + $count |
	
	#Send variables to first file
	Out-file "$path\$sumFile"
	
	#Format output for the second file
	$P | Sort-Object -property Directory,Length -Descending | 
	Select-Object -property Directory,`
	@{Label="File_Size(MB)"; Expression={[math]::Round(($_.Length / 1MB),4)}},`
	@{Label="Created On"; Expression={$_.CreationTime.ToString("MM/dd/yyyy")}},`
	@{Label="Last Open"; Expression={$_.LastAccessTime.ToString("MM/dd/yyyy")}},`
	@{Label="Ignored File"; Expression={($_.LastAccessTime - $_.CreationTime) -lt '24:01:00'}},`
	Name |
	Out-GridView -OutputMode Multiple
}

######## - BEGIN - #########
$prompt = "Y"

while ($prompt -eq "Y")
{
	#Ask to set file age
	$fileAge = Read-Host -Prompt "Enter age (in days) of files you want to list: "
	
	#UI select of directory
	Write-Host "Selecting directory..."
	
	#Load file browser
	[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
	$openDir = new-object System.Windows.Forms.FolderBrowserDialog
	$openDir.RootFolder = "MyComputer"
	$openDir.Description = "Select a Directory"
	
	#Show file browser
	$Show = $openDir.ShowDialog()

	#Use selected folder\drive as directory
	if($Show -eq "OK")
	{
		$path = $openDir.SelectedPath
		
		$filter = Read-Host "File type to find (or enter A for ALL)"
		
		if ($filter -eq "A")
		{
			$filter = $null
		}
		
		[string]$listFile = "PS_File_List_$(Get-Date -UFormat '%Y-%m-%d').csv"
		
		find-Space -path $path -filter $filter -fileAge $fileAge | Export-Csv "$path\$listFile"
		
		#Git dat stuff
		Write-Host ("`n`nSummary Files written to selected Directory: $path.")
	} 
	else
	{
		Write-Error "Run Cancelled by User."
	}

	$prompt = Read-Host -Prompt "Press Y and ENTER to RUN AGAIN (with any directory)- press ANY KEY and ENTER to finish:"
}

#Open the path that was last tested.
ii $path
#

#

#

#

#

#

#

#

#

#END