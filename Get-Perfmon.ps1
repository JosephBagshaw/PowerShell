function Get-Perfmon {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$True,ValueFromPipeLine=$True)]
            [String[]]$ComputerName
        )
        BEGIN {
                Write-Verbose "BEGIN Get-Perfmon"
              }
        PROCESS {
                    foreach ($Computer in $ComputerName){
                        Write-Verbose "Getting Data from $Computer"
                        $counters = '\PhysicalDisk(*)\Avg. Disk Queue Length',
                                    '\Memory\% Committed Bytes in Use',
                                    '\Processor(*)\% Processor Time'
                        Get-Counter -Counter $counters -MaxSamples 600 -SampleInterval 1 -ComputerName $Computer | Export-Counter -Path C:\PerfLogs\$Computer.blg -FileFormat blg
                        }
                }
        END {
                Write-Verbose "END Get-Perfmon"
            }
}
Get-Perfmon -Verbose
