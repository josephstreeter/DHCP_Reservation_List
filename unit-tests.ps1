$IP="10.10.1.9" 
$mac="e4-95-d2-93-b3-96"
$newmac="10-11-12-ab-cd-ef"
$Hostname="Servertest01" 

write-host "`nSetup Tests"

rm .\lists\*

Remove-Reservation -Data $newmac

write-host "`nSetup Complete"

#####################################
$DHCPServers="192.168.0.100","192.168.0.101" 

write-host "`n`nCheck for existing reservation for $mac"
pause
$DHCPServers | % {Get-DhcpServerv4Filter -ComputerName $_ | ? {$_.macaddress -eq $mac}} | ft -auto

write-host "`nCheck for existing filter for $mac"
pause
$DHCPServers | % {Get-Reservation -Data $mac -DHCPServer $_} | ft -auto

write-host "`ncreate new reservation for $mac"
pause
New-Reservation -scope 10.10.1.0 -ip $IP -mac $mac -Hostname $Hostname -group "SKIDATA"

write-host "`nCheck for new reservation for $mac"
pause
$DHCPServers | % {Get-DhcpServerv4Filter -ComputerName $_ | ? {$_.macaddress -eq $mac}} | ft -auto

write-host "`nCheck for new filter for $mac"
pause
$DHCPServers | % {Get-Reservation -Data $mac -DHCPServer $_} | ft -auto

write-host "`nEdit reservation for $mac"
pause
Edit-Reservation -ip $IP -mac $newmac

write-host "`nCheck for updated filter for $newmac"
pause
$DHCPServers | % {Get-DhcpServerv4Filter -ComputerName $_ | ? {$_.macaddress -eq $newmac}} | ft -auto

write-host "`nCheck for updated reservation for $newmac"
pause
$DHCPServers | % {Get-Reservation -DHCPServer $_ -Data $newmac} | ft -auto

write-host "`nExport files"
pause
Export-Reservation

write-host "`nCheck for created files"
pause
ls .\lists

write-host "`nCheck data in files"
pause
gc .\lists\Skidata.txt

write-host "`nCheck for existing reservation for $newmac"
pause
Remove-Reservation -Data $newmac