$a = Get-ADComputer -Properties OperatingSystem -Filter { (OperatingSystem -Like "Windows 10 Enterprise") -or (OperatingSystem -Like "Windows 7 Enterprise") -and (Enabled -eq "True") }
$f = Get-ADGroupMember "Security Group"
$d = Compare-Object -ReferenceObject $a -DifferenceObject $f -PassThru | Get-Random -Count 50
foreach ($computer in $d){Add-ADGroupMember -Identity "Security Group" -Members $computer}