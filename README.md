# DHCP_Reservation_List
'
validate-data($data,$type)
Generate-MacAddress()
Replicate-DHCPServers()
New-Reservation()
    SYNOPSIS
    Collects all of the necessary information for the creation of new
    DHCP reservations
    
    DESCRIPTION
    Uses the Scope, IP address, MAC address, group name, and host name
    provided to create the reservation so that it will be property
    listed for the Palo Alto firewall
    Failure to configure reservations correctly could result in a host
    not being able to communicate.
    
    EXAMPLE
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
    
    EXAMPLE
    The following command with the -confirm switch will create a new 
    reservation. The information entered is not displayed and no 
    confirmation is needed. This is meant for bulk creation. 
    new-reservation -scope 10.10.0.0 -ip 10.10.0.1 -mac a7:e8:85:54:44:c5 -group skidata -hostname PCI-SKIDATA-A1 -confirm false
    
    EXAMPLE
    The following command with the -confirm parameter set to false
    and -mac set to auto will create a new reservation and generate
    a mac address. The information entered is not displayed and no 
    confirmation is needed. This is meant for bulk creation of test
    reservations. 
    new-reservation -scope 10.10.0.0 -ip 10.10.0.1 -mac auto -group skidata -hostname PCI-SKIDATA-A1 -confirm false
    
    PARAMETERS
    scope
    The DHCP scope that the reservation will be created in
    
    ip
    The IP address to be assigned to the host
    
    mac
    That MAC address of the host's interface that is to be configured.
    The address must be in the form of "a7:e8:85:54:44:c5" or 
    "a7-e8-85-54-44-c5"
    
    group
    The organization or service that is used by the Palo Alto firewall
    to create rulesets. For validation the groups are read from a text
    file.
    
    hostname
    The hostname of the host to be configured
    
    confirm
    Allows the command to be used without confirmation. Allows the 
    command to be used for bulk creation of reservations
    
Export-Reservation()
    SYNOPSIS
    Exports the DHCP reservations
    
    DESCRIPTION
    Exports the DHCP reservations including IP, Hostname, and
    Group.
    
    EXAMPLE
    The following command will export all reservations from a DHCP
    Server.
    Export-Reservations
    The -server switch will connect to a remote DHCP server 
    Export-Reservations -server server.domain.com
   
    PARAMETERS 
    server
    The DHCP server that is being used. If no service name is specified it will default to localhost
    
Edit-Reservation()
    SYNOPSIS
    Edits data for an existing DHCP reservation
    
    DESCRIPTION
    Used to update MAC address, group name, or host name
    based on the parameters used. Provides validation for 
    properly formed MAC addresses and group names.Failure 
    to configure reservations correctly could result in a host
    not being able to communicate.
    
    EXAMPLE
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
    
    EXAMPLE
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
    
    PARAMETERS
    ip
    The IP address of the reservation to be updated. The parameter is 
    
    mac
    The new mac address to configure
    The address must be in the form of "a7:e8:85:54:44:c5" or 
    "a7-e8-85-54-44-c5"
    
    group
    The new organization or service to be configured for the reservation
    
    hostname
    The new hostname to be configured for the reservation
    Get-Reservation()
    SYNOPSIS
    Searches for reservations
    
    DESCRIPTION
    Uses MAC address, group name, host name, or scope to search
    for reservations that are already configured. 
    
    EXAMPLE
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
    
    PARAMETERS 
    ip
    The IP address of the reservation to be searched for. The parameter
    is mandetory. 
    
    mac
    The mac address of the reservation to be searched for.
    The address must be in the form of "a7:e8:85:54:44:c5" or 
    "a7-e8-85-54-44-c5"
    
    group
    The organization or service of the reservation to be searched for.
    
    hostname
    The new hostname of the reservation to be searched for.
Edit-FilterLists()
Check-Replication()'
