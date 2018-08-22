function validate-data($data,$type)
    {
    $scopeadd="^(?:(?:0?0?\d|0?[1-9]\d|1\d\d|2[0-5][0-5]|2[0-4]\d)\.){3}(?:0?0?\d|0?[1-9]\d|1\d\d|2[0-5][0-5]|0\d)$" # make to require a 0 at the end
    $ipadd="^(?:(?:0?0?\d|0?[1-9]\d|1\d\d|2[0-5][0-5]|2[0-4]\d)\.){3}(?:0?0?\d|0?[1-9]\d|1\d\d|2[0-5][0-5]|2[0-4]\d)$"
    $macadd="^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$"
    $group=Get-Content .\groups.txt

    switch ($type) {
        "Scope" {$results = $data -match $scopeadd}
        "IP" {$results = $data -match $ipadd}
        "MAC" {if ($data -eq "auto"){$results=$true}Else{$results = $data -match $macadd}}
        "Group" {$results = $group -contains $data}
        }
    Return $results
    }

function Generate-MacAddress()
    {
    $results=(0..5 | ForEach-Object { '{0:x}{1:x}' -f (Get-Random -Minimum 0 -Maximum 15),(Get-Random -Minimum 0 -Maximum 15)})  -join '-'
    Return $results
    }

function Replicate-DNSServers()
    {
    Invoke-DhcpServerv4FailoverReplication
    }

function New-Reservation()
    {
    <#
    .SYNOPSIS
    Collects all of the necessary information for the creation of new
    DHCP reservations
    .DESCRIPTION
    Uses the Scope, IP address, MAC address, group name, and host name
    provided to create the reservation so that it will be property
    listed for the Palo Alto firewall
    Failure to configure reservations correctly could result in a host
    not being able to communicate.
    .EXAMPLE
    The following command will create a new reservation. The 
    information entered is displayed for review and a confirmation 
    is required. 

    new-reservation -scope 10.10.0.0 -ip 10.10.0.1 -mac a7:e8:85:54:44:c5 -group skidata -hostname PCI-SKIDATA-A1
    Reservation information:
        	 Scope    10.10.0.0
        	 IP       10.10.0.1
        	 MAC      a7:e8:85:54:44:c5
        	 Hostname PCI-SKIDATA-A1
        	 Group    skidata
        
    Is this information accurate? (y/n): 
    .EXAMPLE
    The following command with the -confirm switch will create a new 
    reservation. The information entered is not displayed and no 
    confirmation is needed. This is meant for bulk creation. 

    new-reservation -scope 10.10.0.0 -ip 10.10.0.1 -mac a7:e8:85:54:44:c5 -group skidata -hostname PCI-SKIDATA-A1 -confirm false
    .EXAMPLE
    The following command with the -confirm parameter set to false
    and -mac set to auto will create a new reservation and generate
    a mac address. The information entered is not displayed and no 
    confirmation is needed. This is meant for bulk creation of test
    reservations. 

    new-reservation -scope 10.10.0.0 -ip 10.10.0.1 -mac auto -group skidata -hostname PCI-SKIDATA-A1 -confirm false
    .PARAMETER scope
    The DHCP scope that the reservation will be created in
    .PARAMETER ip
    The IP address to be assigned to the host
    .PARAMETER mac
    That MAC address of the host's interface that is to be configured.
    The address must be in the form of "a7:e8:85:54:44:c5" or 
    "a7-e8-85-54-44-c5"
    .PARAMETER group
    The organization or service that is used by the Palo Alto firewall
    to create rulesets. For validation the groups are read from a text
    file.
    .PARAMETER hostname
    The hostname of the host to be configured
    .PARAMETER confirm
    Allows the command to be used without confirmation. Allows the 
    command to be used for bulk creation of reservations
    #>
    Param(
    [Parameter(Mandatory=$True)][ValidateScript({validate-data -data $_ -type Scope})][string]$scope,
    [Parameter(Mandatory=$True)][ValidateScript({validate-data -data $_ -type IP})][string]$ip,
    [Parameter(Mandatory=$True)][ValidateScript({validate-data -data $_ -type MAC})][string]$mac,
    [Parameter(Mandatory=$True)][ValidateScript({validate-data -data $_ -type group})][string]$group,
    [Parameter(Mandatory=$True)][string]$Hostname,
    [Parameter(Mandatory=$False)][string]$DHCPServer,
    [Parameter(Mandatory=$False)][string]$confirm
    )
    if (-not $DHCPServer) {$DHCPServer="LocalHost"}
    
    $results=@()
    $results=New-Object psobject -Property @{"scope"=$scope;"ip"=$ip;"group"=$group;"mac"=if ($mac -eq "auto"){Generate-MacAddress}Else{$mac};"Hostname"=$hostname}
    
    if ($confirm -ne $false) 
        {
        "Reservation information:
        `t Scope    $($results.scope)
        `t IP       $($results.ip)
        `t MAC      $($results.mac)
        `t Hostname $($results.hostname)
        `t Group    $($results.group)
        "
        $valid=Read-Host "Is this information accurate? (y/n)"
        }
 
    if (($confirm -eq $false) -or ($valid -eq "y"))
        {
        Add-DhcpServerv4Reservation `
            -ComputerName $DHCPServer `
            -ScopeId $results.scope `
            -IP $results.ip `
            -Description $results.group `
            -hostname $results.hostname `
            -ClientId $results.mac
        }
    Else
        {
        "Nothing created"
        }
    Replicate-DNSServers
    }

Function Export-Reservation()
    {
    <#
    .SYNOPSIS
    Exports the DHCP reservations
    
    .DESCRIPTION
    Exports the DHCP reservations including IP, Hostname, and
    Group.
    
    .EXAMPLE
    The following command will export all reservations from a DHCP
    Server.

    Export-Reservations

    The -server switch will connect to a remote DHCP server 

    Export-Reservations -server server.domain.com
   
    .PARAMETER server
    The DHCP server that is being used. If no service name is specified it will default to localhost
    #>

    Param(
    [Parameter(Mandatory=$False)][string]$DHCPServer
    )
    
    if (-not $DHCPServer) {$DHCPServer="LocalHost"}

    $Results= @()
    $scopes = Get-DhcpServerv4Scope -ComputerName $DHCPServer

    foreach ($scope in $scopes)
        { 
        $Reservations = Get-DhcpServerv4Reservation -ComputerName $DHCPServer -ScopeId $scope.ScopeId
        foreach ($Reservation in $Reservations)
            {
            $Results += New-Object psobject -Property @{"IP"=$($Reservation.IPAddress[0].ToString())
                                                        "Host"=$Reservation.Name
                                                        "Group"=$Reservation.Description
                                                        }
            }
        }
    
    $groups = $Results.group | Select-Object -Unique
    $datetime=get-date -UFormat "%Y-%m-%d-%H-%M-%S"
    
    foreach ($group in $groups)
        {
        $results | Where-Object {$_.group -eq $group} |  % {"{0,-10}{1,-10}" -f $_.IP,$_.Host} | Out-File ".\lists\$group.txt"
        }
    Return "$($results.count) Reservations"
    }

Function Edit-Reservation()
    {
    <#
    .SYNOPSIS
    Edits data for an existing DHCP reservation
    .DESCRIPTION
    Used to update MAC address, group name, or host name
    based on the parameters used. Provides validation for 
    properly formed MAC addresses and group names.Failure 
    to configure reservations correctly could result in a host
    not being able to communicate.
    .EXAMPLE
    The following command will edit an existing reservation. 

    Edit-Reservation -ip 10.0.101.100 -group skidata
    
    Review
    Mac       
    	Current:12-12-12-13-13-13 
    	New:12-12-12-13-13-13
    Hostname  
    	Current:Server100 
    	New:Server100
    Mac
    	Current:group1 
    	New:skidata
    Is this correct? [y/n]: 

    .EXAMPLE
    Multiple attributes can be updated by using multiple parameters

    Edit-Reservation -ip 10.0.101.100 -group skidata -Hostname ServerAAA -mac ab-ab-ab-cd-cd-cd
    Review
        Mac       
    	    Current:12-12-12-13-13-13 
    	    New:ab-ab-ab-cd-cd-cd
        Hostname  
    	    Current:Server100 
    	    New:ServerAAA
        Mac
    	    Current:group1 
    	    New:skidata

    Is this correct? [y/n]: 
    .PARAMETER ip
    The IP address of the reservation to be updated. The parameter is 
    .PARAMETER mac
    The new mac address to configure
    The address must be in the form of "a7:e8:85:54:44:c5" or 
    "a7-e8-85-54-44-c5"
    .PARAMETER group
    The new organization or service to be configured for the reservation
    .PARAMETER hostname
    The new hostname to be configured for the reservation
    #>
    
    Param(
    [Parameter(Mandatory=$True)][ValidateScript({validate-data -data $_ -type IP})][string]$ip,
    [Parameter(Mandatory=$False)][ValidateScript({validate-data -data $_ -type MAC})][string]$mac,
    [Parameter(Mandatory=$false)][ValidateScript({validate-data -data $_ -type group})][string]$group,
    [Parameter(Mandatory=$False)][string]$Hostname,
    [Parameter(Mandatory=$False)][string]$DHCPServer
    )
    
    if (-not $DHCPServer) {$DHCPServer="LocalHost"}

    if (-not($mac -or $Hostname -or $group))
        {
        "You must include at least one attribute to update"
        Break
        }
    
    $Current=Get-DhcpServerv4Reservation -IPAddress $ip -ComputerName $DHCPServer
    $new=@()
    $New=New-Object psobject -Property @{"IP"=$current.IPAddress[0].ToString()
                                        "ClientID"=if ($mac) {$mac} Else {$current.ClientID}
                                        "Name"=if ($Hostname) {$Hostname} Else {$current.Name} 
                                        "Description"=if ($Group) {$Group} Else {$current.Description}
                                        }
    
    "Review
    Mac       
    `tCurrent: $($Current.clientid) 
    `tNew:     $($New.ClientID)
    Hostname  
    `tCurrent: $($Current.Name) 
    `tNew:     $($New.Name)
    Mac
    `tCurrent: $($Current.Description) 
    `tNew:     $($New.Description)`n"

    if ($(Read-Host "Is this correct? [y/n]") -eq "y")
        {
        Set-DhcpServerv4Reservation `
            -ComputerName $DHCPServer `
            -IPAddress $($current.IPAddress[0].ToString()) `
            -ClientID $(if ($mac) {$mac} Else {$current.ClientID}) `
            -Name $(if ($Hostname) {$Hostname} Else {$current.Name}) `
            -Description $(if ($Group) {$Group} Else {$current.Description})
    
        #$res=Get-DhcpServerv4Reservation -IPAddress $ip
        }
    Replicate-DNSServers
    }

Function Get-Reservation()
    {
    <#
    .SYNOPSIS
    Searches for reservations
    .DESCRIPTION
    Uses MAC address, group name, host name, or scope to search
    for reservations that are already configured. 
    .EXAMPLE
    The following command will search for an existing reservation by
    mac address

    Get-Reservation -mac 00-aa-00-10-11-04

    IPAddress       ScopeId         ClientId             Name               Type    Description         
    ---------       -------         --------             ----               ----    -----------         
    10.0.101.104    10.0.101.0      00-aa-00-10-11-04    Server-101-104     Both    Server-101-104 Desc

    .EXAMPLE
    Multiple attributes can be updated by using multiple parameters

    Get-Reservation -group skidata
    IPAddress       ScopeId        ClientId             Name              Type      Description         
    ---------       -------        --------             ----              ----      -----------         
    10.0.101.100    10.0.101.0     ab-ab-ab-cd-cd-cd    ServerAAA         Both      skidata             
    10.0.101.101    10.0.101.0     00-aa-00-10-11-01    Server-101-101    Both      Skidata      
    
    .PARAMETER ip
    The IP address of the reservation to be searched for. The parameter
    is mandetory. 
    .PARAMETER mac
    The mac address of the reservation to be searched for.
    The address must be in the form of "a7:e8:85:54:44:c5" or 
    "a7-e8-85-54-44-c5"
    .PARAMETER group
    The organization or service of the reservation to be searched for.
    .PARAMETER hostname
    The new hostname of the reservation to be searched for.
    #>
    
    Param(
    [Parameter(Mandatory=$false)][ValidateScript({validate-data -data $_ -type IP})][string]$ip,
    [Parameter(Mandatory=$False)][ValidateScript({validate-data -data $_ -type MAC})][string]$mac,
    [Parameter(Mandatory=$False)][ValidateScript({validate-data -data $_ -type group})][string]$group,
    [Parameter(Mandatory=$False)][ValidateScript({validate-data -data $_ -type IP})][string]$scope,
    [Parameter(Mandatory=$False)][string]$HostName,
    [Parameter(Mandatory=$False)][string]$DHCPServer
    )
    
    if (-not $DHCPServer) {$DHCPServer="LocalHost"}

    if ($scope)
        {
        Get-DhcpServerv4Reservation -scopeID $scope -ComputerName $DHCPServer
        }
    Elseif ($ip)
        {
        Get-DhcpServerv4Reservation -IPAddress $ip
        }
    Elseif ($mac)
        {
        foreach ($scopeid in $(Get-DhcpServerv4scope).ScopeId)
            {
            Get-DhcpServerv4Reservation -ScopeId $scopeid -ClientId $mac -ea SilentlyContinue
            }
        }
    Elseif ($Group)
        {
        foreach ($scopeid in $(Get-DhcpServerv4scope).ScopeId)
            {
            Get-DhcpServerv4Reservation -ScopeId $scopeid -ea SilentlyContinue | ? {$_.description -eq $group}
            }
        }
    Elseif ($hostname)
        {
        foreach ($scopeid in $(Get-DhcpServerv4scope).ScopeId)
            {
            Get-DhcpServerv4Reservation -ScopeId $scopeid -ea SilentlyContinue | ? {$_.name -eq $hostname}
            }
        }
    
    }