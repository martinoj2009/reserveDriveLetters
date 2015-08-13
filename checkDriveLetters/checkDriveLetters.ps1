#
# This script will compare current drive letters, and compare them against reserved drive letters
# Martino Jones
# 20150807
#


#Get a list of current drives
$drives = @((GET-WMIOBJECT win32_logicaldisk | where {$_.ProviderName -notlike "\\*"}).DeviceID).replace(":", "")


#List of drives we want to reserve
$reservedDriveLetters = @("h", "a", "b", "g", "i", "s", "t", "y", "x")

#Get colliding drive letters, use Compare, too lazy to make loop within loop ;-)
$collide = @(Compare-Object -ReferenceObject $reservedDriveLetters -DifferenceObject $drives -IncludeEqual | where {$_.SideIndicator -eq "=="})

#Get available drive letters
$availableLetters = @(ls function:[d-z]: -n | ?{ !(test-path $_) })

#Change the letter for collide drive(s)
for($i = 0; $i -lt $collide.Length; $i++)
{
	$driveLetter = $collide[$i].InputObject + ":"
	#I don't know how to pop array with fixed size, this will just count up from the bottom
	$newDriveLetter = $availableLetters[-($i+1)]

	$drive = gwmi win32_volume -Filter "DriveLetter = '$driveLetter'"
	$drive.DriveLetter = "$newDriveLetter"
	$drive.put()
}