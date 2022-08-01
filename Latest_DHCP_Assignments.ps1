$newest = @()
$line = "" | select tick,device,ip,stamp
$line.tick = ""
$line.device = ""
$line.ip = ""
$line.stamp = ""
$newest+=$line

$devices = get-content C:\Windows\System32\dhcp\dhcpsrvlog* | select-string -pattern ',Renew,',',Request,'

write-output "

...Scraping dhcpv4 logs for Renew and Request patterns"

foreach ( $reader in $devices ) {
    $split = $reader -split ","
    $timestr = $split[1]+" "+$split[2]
    $timestamp = get-date $timestr
    $tickeq = ($timestamp).ticks
    $ip = $split[4]
    $device = $split[6]
    $newobj = [PSCustomObject]@{ 'Tick' = $tickeq; 'Device' = $device; 'IP' = $ip; 'Stamp' = $timestamp }
    if ($newest.Device.contains($device)) {
        $indexnum = $newest.device.indexof($device)
        write-verbose "Found $device at position $indexnum"
        write-verbose "$timestamp EVALUATE"
        write-verbose "$($newest.stamp[$indexnum]) FOUND"
        if ($newest.tick[$indexnum] -lt $tickeq) { 
            write-verbose "$timestamp NEWER THAN $($newest[$indexnum].stamp)"
            $newest[$indexnum].tick = $tickeq
            $newest[$indexnum].ip = $ip
            $newest[$indexnum].stamp = $timestamp 
            write-verbose "Timestamp now $($newest[$indexnum].stamp)"}
        else {
            write-verbose "$timestamp OLDER THAN $($newest[$indexnum].stamp), no update needed"
            } 
        }
    else {
        write-output "No previous record, adding $device to array"
        $newest+=$newobj 
        }
    }

$newest = $newest[1..($newest.length-1)] #Remove null first initialization row
write-output "
...Current DHCP assignments, total elements $($newest.count):"
$newest | sort IP -descending | ft IP,Device,Stamp
