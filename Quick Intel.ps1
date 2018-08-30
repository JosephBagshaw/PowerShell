#========================================================================
# 
#
# Name		    : Quick Intel.ps1
# Author 	    : Joseph Bagshaw
# Build Version : 2.0
#
# 			
#========================================================================



Add-Type -AssemblyName PresentationFramework



#--------------------------------------------
# Declare Variables and Functions
#--------------------------------------------



$break = "`n`n******************************************************************`n"



Function Get-Connect{
    $clear = $output.Clear()
    $clear
    $connect = [DateTime]::Now – [Management.ManagementDateTimeConverter]::ToDateTime((Get-WmiObject Win32_OperatingSystem -computername $computer).LastBootUpTime) | Select Days, Hours, Minutes, Seconds
    $uptime.text = $connect | Out-String
}


Function Get-System{
    $output.ScrollToEnd()
    $system = Get-WmiObject Win32_ComputerSystem -ComputerName $computer | Select @{ Name = 'Current User'; Expression = { $_.Username } },
                    Manufacturer, Model,
                    @{ Name = 'System Type'; Expression = { $_.SystemType } },
                    @{ Name = 'RAM'; Expression = { "{0:N2}" -f ([math]::round(($_.TotalPhysicalMemory / 1GB), 2)) } },
                    @{ Name = 'Boot Up State'; Expression = { $_.BootupState } },
                    Status
    $output.text += $system, $break | Out-String
}


Function Get-Bios{
    $output.ScrollToEnd()
    $bios = Get-WmiObject Win32_BIOS -ComputerName $computer | Select @{ Name = 'Serial Number'; Expression = { $_.SerialNumber } },
                    @{ Name = 'System BIOS Version'; Expression = { $_.SMBIOSBIOSVersion } },
                    Manufacturer,
                    @{ Name = 'Language'; Expression = { $_.CurrentLanguage } },
                    Status
    $output.text += $bios, $break | Out-String
}


Function Get-Memory{
    $output.ScrollToEnd()
    $memory = Get-WmiObject Win32_PhysicalMemory -ComputerName $computer | select  @{Expression={$_.PSComputerName};Label="Computer Name"},
                    @{ Name = "Description"; Expression = { $_.Tag } },
                    @{ Name  = "Slot"; Expression = { $_.DeviceLocator } },
                    @{Name="Size (GB)";Expression={"{0:N2}" -f ($_.Capacity/1gb)}},
                    Speed
    $output.text += $memory, $break | Out-String
}   


$arch = DATA {ConvertFrom-StringData -StringData @'
0 = x86
9 = x64
'@}
$fam = DATA {ConvertFrom-StringData -StringData @'
1 = Other
2 = Unknown
3 = 8086
4 = 80286
5 = Intel386™ Processor
6 = Intel486™ Processor
7 = 8087
8 = 80287
9 = 80387
10 = 80487
11 = Pentium Brand
12 = Pentium Pro
13 = Pentium II
14 = Pentium Processor with MMX™ Technology
15 = Celeron™
16 = Pentium II Xeon™
17 = Pentium III
18 = M1 Family
19 = M2 Family
24 = AMD Duron™ Processor Family
25 = K5 Family
26 = K6 Family
27 = K6-2
28 = K6-3
29 = AMD Athlon™ Processor Family
30 = AMD2900 Family
31 = K6-2+
32 = Power PC Family
33 = Power PC 601
34 = Power PC 603
35 = Power PC 603+
36 = Power PC 604
37 = Power PC 620
38 = Power PC X704
39 = Power PC 750
48 = Alpha Family
49 = Alpha 21064
50 = Alpha 21066
51 = Alpha 21164
52 = Alpha 21164PC
53 = Alpha 21164a
54 = Alpha 21264
55 = Alpha 21364
64 = MIPS Family
65 = MIPS R4000
66 = MIPS R4200
67 = MIPS R4400
68 = MIPS R4600
69 = MIPS R10000
80 = SPARC Family
81 = SuperSPARC
82 = microSPARC II
83 = microSPARC IIep
84 = UltraSPARC
85 = UltraSPARC II
86 = UltraSPARC IIi
87 = UltraSPARC III
88 = UltraSPARC IIIi
96 = 68040
97 = 68xxx Family
98 = 68000
99 = 68010
100 = 6802
101 = 68030
112 = Hobbit Family
120 = Crusoe™ TM5000 Family
121 = Crusoe™ TM3000 Family
122 = Efficeon™ TM8000 Family
128 = Weitek
130 = Itanium™ Processor
131 = AMD Athlon™ 64 Processor Family
132 = AMD Opteron™ Processor Family
144 = PA-RISC Family
145 = PA-RISC 8500
146 = PA-RISC 8000
147 = PA-RISC 7300LC
148 = PA-RISC 7200
149 = PA-RISC 7100LC
150 = PA-RISC 7100
160 = V30 Family
176 = Pentium III Xeon™ Processor
177 = Pentium III Processor with Intel SpeedStep™ Technology
178 = Pentium 4
179 = Intel Xeon™
180 = AS400 Family
181 = Intel Xeon™ Processor MP
182 = AMD Athlon™ XP Family
183 = AMD Athlon™ MP Family
184 = Intel Itanium 2
185 = Intel Pentium M Processor
190 = K7
198 = Intel Core™ i7-2760QM
200 = IBM390 Family
201 = G4
202 = G5
203 = G6
204 = z/Architecture Base
250 = i860
251 = i960
260 = SH-3
261 = SH-4
280 = ARM
281 = StrongARM
300 = 6x86
301 = MediaGX
302 = MII
320 = WinChip
350 = DSP
500 = Video Processor
'@}
$type = DATA {ConvertFrom-StringData -StringData @'
1 = Other
2 = Unknown
3 = Central Processor
4 = Math processor
5 = DSP Processor
6 = Video Processor
'@}


Function Get-Processor{
    $output.ScrollToEnd()
    $processor = Get-WmiObject Win32_Processor -ComputerName $computer | Select @{Expression={$_.PSComputerName};Label="Computer Name"},
                    @{Name="Processor Type";Expression={$type["$($_.ProcessorType)"]}}, 
                    Manufacturer, Name, Description,
                    @{Name="CPU Family";Expression={$fam["$($_.Family)"]}}, @{Name="CPU Architecture";Expression={$arch["$($_.Architecture)"]}}
    $output.text += $processor, $break | Out-String
}


Function Get-Printers{
    $output.ScrollToEnd()
    $printers = Get-WmiObject  Win32_Printer -ComputerName $computer | Format-Table @{ Name = "System Name"; Expression = { $_.SystemName } },
                    Name,
                    @{ Name = "Port Name"; Expression = { $_.PortName } }, Location,
                    @{ Name = "Driver Name"; Expression = { $_.DriverName } } -AutoSize
    $output.text += $printers, $break | Out-String
}


function Get-Perfmon{
	$output.ScrollToEnd()
	$counters = '\PhysicalDisk(*)\Avg. Disk Queue Length',
                '\Memory\% Committed Bytes in Use',
                '\Processor(*)\% Processor Time'
    $perfmonpath = "C:\PerfLogs\$computer.blg"
    $perfmon = Get-Counter -Counter $counters -MaxSamples $secondsfield -SampleInterval 1 -ComputerName $computer | Export-Counter -Path $perfmonpath -FileFormat blg
    $output.text += "`nPerformance Monitor has completed. The Binary Performance Log file is located at " + "$perfmonpath`n`n", $break | Out-String
}


Function Get-OS{
    $output.ScrollToEnd()
    $operatingsystem = Get-WmiObject Win32_OperatingSystem -ComputerName $computer | Select @{ Name = 'Operating System'; Expression = { $_.caption } },
                    @{ Name = 'Service Pack'; Expression = { $_.ServicePackMajorVersion } },
                    @{ Name = 'Architecture'; Expression = { $_.OSArchitecture } },
                    @{ Name = 'Last Boot Up Time';Expression = { $_.ConvertToDateTime($_.LastBootUpTime) } },
                    @{ Name = 'Install Date';Expression = { $_.ConvertToDateTime($_.InstallDate) } },
                    @{ Name = 'Local Date Time';Expression = { $_.ConvertToDateTime($_.LocalDateTime) } },
                    @{ Name = 'Status'; Expression = { $_.Status } }
    $output.text += $operatingsystem, $break | Out-String
}


Function Get-Applications{
    $output.ScrollToEnd()
    $applications = Get-WmiObject Win32_Product -ComputerName $computer | Sort Name | Format-Table -AutoSize @{Name="Software";Expression={($_.Name)}},
                    Vendor, Version
    $output.text += $applications, $break | Out-String
}


Function Get-Startup{
    $output.ScrollToEnd()
    $startup = Get-WmiObject Win32_StartupCommand –ComputerName $computer | Sort-Object Caption | Format-Table __Server, Caption, Command, User -AutoSize
    $output.text += $startup, $break | Out-String
}


$dtype = DATA {ConvertFrom-StringData -StringData @'
0 = Unknown
1 = No Root Directory
2 = Removable Disk
3 = Local Disk
4 = Network Drive
5 = Compact Disc
6 = RAM Disk
'@}

$mtype = DATA {ConvertFrom-StringData -StringData @'
0 = Unknown
11 = Removable media other than floppy
12 = Fixed hard disk media
'@}


Function Get-LogicalDisk{
    $output.ScrollToEnd()
    $logicaldisk = Get-WmiObject Win32_LogicalDisk -ComputerName $computer | Select @{Expression={$_.PSComputerName};Label="Computer Name"},
                    @{ Name = 'Device ID'; Expression = { $_.DeviceID } },
                    Compressed,
                    @{ Name = 'File System'; Expression = { $_.FileSystem } },
                    @{ Name = 'Disk Size (GB)' ; Expression = {"{0:N3}" -f ($_.Size/1GB) } },
                    @{ Name = 'Free Space (GB)' ; Expression = {"{0:N3}" -f ($_.FreeSpace/1GB) } },
                    @{ Name = 'Media Type' ; Expression = {$mtype["$($_.MediaType)"] } },
                    @{ Name = 'Volume Name' ; Expression = {$dtype["$($_.VolumeName)"] } }
    $output.text += $logicaldisk, $break | Out-String
}


$err = DATA {ConvertFrom-StringData -StringData @'
0 = Device is working properly.
1 = Device is not configured correctly.
2 = Windows cannot load the driver for this device.
3 = Driver for this device might be corrupted, or the system may be low on memory or other resources.
4 = Device is not working properly. One of its drivers or the registry might be corrupted.
5 = Driver for the device requires a resource that Windows cannot manage.
6 = Boot configuration for the device conflicts with other devices.
7 = Cannot filter.
8 = Driver loader for the device is missing.
9 = Device is not working properly. The controlling firmware is incorrectly reporting the resources for the device.
10 = Device cannot start.
11 = Device failed.
12 = Device cannot find enough free resources to use.
13 = Windows cannot verify the device resources.
14 = Device cannot work properly until the computer is restarted.
15 = Device is not working properly due to a possible re-enumeration problem.
16 = Windows cannot identify all of the resources that the device uses 
17 = Device is requesting an unknown resource type.
18 = Device drivers must be reinstalled.
19 = Failure using the VxD loader.
20 = Registry might be corrupted.
21 = System failure. If changing the device driver is ineffective, see the hardware documentation. Windows is removing the device.
22 = Device is disabled.
23 = System failure. If changing the device driver is ineffective, see the hardware documentation.
24 = Device is not present, not working properly, or does not have all of its drivers installed.
25 = Windows is still setting up the device.
26 = Windows is still setting up the device.
27 = Device does not have valid log configuration.
28 = Device drivers are not installed.
29 = Device is disabled. The device firmware did not provide the required resources.
30 = Device is using an IRQ resource that another device is using.
31 = Device is not working properly. Windows cannot load the required device drivers.
'@}


Function Get-PhysicalDisk{
    $output.ScrollToEnd()
    $physicaldisk = Get-WmiObject Win32_DiskDrive -ComputerName $computer | Select @{Expression={$_.PSComputername};Label="Computer Name"},
                    @{ Name = 'Device ID'; Expression = { $_.DeviceID } }, 
                    @{ Name = 'Interface Type'; Expression = { $_.InterfaceType } },
                    Manufacturer, Model,
                    @{ Name = 'Media Type'; Expression = { $_.MediaType } },
                    @{ Name = 'Firmware Revision'; Expression = { $_.FirmwareRevision } },
                    @{ Name = 'Serial Number'; Expression = { $_.SerialNumber } },
                    Signature, 
                    @{Name="Disk Size (GB)";Expression={"{0:N2}" -f ($_.Size/1GB)}},
                    Partitions,
                    @{Name="Status";Expression={$err["$($_.ConfigManagerErrorCode)"]}}
    $output.text += $physicaldisk, $break | Out-String
}



#--------------------------------------------
# Declare Variables and Add_Click Functions
#---------------------------------------------



[xml]$form = Get-Content '.\MyApp.xaml'
$NR=(New-Object System.Xml.XmlNodeReader $form)
$Win=[Windows.Markup.XamlReader]::Load( $NR)


$computer = $Win.FindName("computername")
$output = $Win.FindName("output")
$uptime = $Win.Findname("uptime")
$seconds = $Win.Findname("seconds")
$button_connect = $Win.FindName("connect")
$button_system = $Win.FindName("system")
$button_bios = $Win.FindName("bios")
$button_memory = $Win.FindName("memory")
$button_processor = $Win.FindName("processor")
$button_printers = $Win.FindName("printers")
$button_run = $Win.FindName("run")
$button_os = $Win.FindName("operatingsystem")
$button_applications = $Win.FindName("applications")
$button_startup = $Win.FindName("startup")
$button_logicaldisk = $Win.FindName("logicaldisk")
$button_physicaldisk = $Win.FindName("physicaldisk")



$button_connect.Add_Click({
$computer = $computer.text
If([string]::IsNullOrEmpty($computer)){
[System.Windows.MessageBox]::Show("Please enter a Computer Name")}
Else
    {
        Get-Connect
    }
})

$button_system.Add_Click({
$computer = $computer.text
If([string]::IsNullOrEmpty($computer)){
[System.Windows.MessageBox]::Show("Please enter a Computer Name")}
Else
    {
        Get-System
    }
})

$button_bios.Add_Click({
$computer = $computer.text
If([string]::IsNullOrEmpty($computer)){
[System.Windows.MessageBox]::Show("Please enter a Computer Name")}
Else
    {
        Get-Bios
    }
})

$button_memory.Add_Click({
$computer = $computer.text
If([string]::IsNullOrEmpty($computer)){
[System.Windows.MessageBox]::Show("Please enter a Computer Name")}
Else
    {
        Get-Memory
    }
})

$button_processor.Add_Click({
$computer = $computer.text
If([string]::IsNullOrEmpty($computer)){
[System.Windows.MessageBox]::Show("Please enter a Computer Name")}
Else
    {
        Get-Processor
    }
})

$button_printers.Add_Click({
$computer = $computer.text
If([string]::IsNullOrEmpty($computer)){
[System.Windows.MessageBox]::Show("Please enter a Computer Name")}
Else
    {
        Get-Printers
    }
})

$button_run.Add_Click({
$computer = $computer.text
$secondsfield = $seconds.text
If([string]::IsNullOrEmpty($computer)){
[System.Windows.MessageBox]::Show("Please enter a Computer Name")}
ElseIf([string]::IsNullOrEmpty($secondsfield)){
[System.Windows.MessageBox]::Show("Please enter time allocation")}
Else
    {
        Get-Perfmon
    }
})

$button_os.Add_Click({
$computer = $computer.text
If([string]::IsNullOrEmpty($computer)){
[System.Windows.MessageBox]::Show("Please enter a Computer Name")}
Else
    {
        Get-OS
    }
})

$button_applications.Add_Click({
$computer = $computer.text
If([string]::IsNullOrEmpty($computer)){
[System.Windows.MessageBox]::Show("Please enter a Computer Name")}
Else
    {
        Get-Applications
    }
})

$button_startup.Add_Click({
$computer = $computer.text
If([string]::IsNullOrEmpty($computer)){
[System.Windows.MessageBox]::Show("Please enter a Computer Name")}
Else
    {
        Get-Startup
    }
})

$button_logicaldisk.Add_Click({
$computer = $computer.text
If([string]::IsNullOrEmpty($computer)){
[System.Windows.MessageBox]::Show("Please enter a Computer Name")}
Else
    {
        Get-LogicalDisk
    }
})

$button_physicaldisk.Add_Click({
$computer = $computer.text
If([string]::IsNullOrEmpty($computer)){
[System.Windows.MessageBox]::Show("Please enter a Computer Name")}
Else
    {
        Get-PhysicalDisk
    }
})


[void]$Win.ShowDialog()