function Load-Modules($module)
    {
    if (-not (Get-Module $module -ea SilentlyContinue))
        {
        Import-Module $module
        }
    }

Function Get-Group()
    {
    $groups=Get-Content C:\utilities\scripts\groups.txt
    $i=0
    $Groups | % {write-host "$i $_" ; $i++ }
    $Response=Read-Host "Enter group number"
    
    Return $groups[$Response]
    }

Function New-ReservationMenu()
    {
    Clear-Host
    $ip=Read-Host "Enter Reservation IP"
    $scope=$ip.split(".")[0]+"."+$ip.split(".")[1]+"."+$ip.split(".")[2]+".0"
    $mac=Read-Host "Enter MAC Address (aa-aa-aa-aa-aa-aa)"
    $Hostname=Read-Host "Enter Reservation hostname"
    $group=$(Get-Group)

    $res=Get-Reservation -Data $ip
    if ($res)
        {
        "Reservation for $ip already exists"
        }
    Else
        {
        New-Reservation `
            -scope $scope `
            -ip $ip `
            -Hostname $Hostname `
            -mac $mac `
            -group $group
        }
    Show-Information
    }

Function Edit-ReservationMenu()
    {
    $data=Read-Host "Enter reservation information"
    $res=Get-Reservation -Data $data 
    Edit-Reservation 
    Show-Information
    }

Function Remove-ReservationMenu()
    {
    $data=Read-Host "Enter reservation information"
    Get-Reservation -Data $data
    Remove-Reservation -Data $data 
    Show-Information
    }

Function Export-ReservationMenu()
    {
    Export-Reservation
    Pause
    Show-Information
    }

Function Setup-Environment()
    {
    Clear-Host
    $path="C:\Program Files\WindowsPowerShell\Modules\"
    $folder="PCIDHCPManagement"

    if (Get-Module -ListAvailable PCIDHCPManagement)
        {
        "Module is already installed"
        }
    Else 
        {
        "Installing Module"
        if (-not (Get-Item $location -ea SilentlyContinue))
            {
            New-Item -ItemType Directory -Path $path -Name $folder | Out-Null
            }
        
        if (-not (Get-Item $($location + $path + "\PCIdhcpmanagement.psm1") -ea SilentlyContinue))
            {
            Copy-Item .\PCIdhcpmanagement.psm1 $path$folder | Out-Null
            }
        }

    if (Get-Module PCIDHCPManagement)
        {
        "Module is already loaded"
        }
    Else 
        {
        "Loading Module"
        Import-Module PCIDHCPManagement
        }
    pause
    Show-Information
    }

Function Show-Information {
    CLS
    "********************************************************"
    "*     Collect User Information for object creation     *"
    "*                                                      *"
    "********************************************************"
    "`t1 - New Reservation"
    "`t2 - Edit Reservation"
    "`t3 - Remove Reservation"
    "`t4 - Export Reservations"
    "`ts - Setup"
    "`tq - Quit"
        
    $Choice = Read-Host "`nSelect task"

    Switch ($Choice) {
        1 {New-ReservationMenu}
        2 {Edit-ReservationMenu}
        3 {Remove-ReservationMenu}
        4 {Export-ReservationMenu}
        s {Setup-Environment}
        q {Break}
        Default {Show-Information}
        }
    }

cd C:\utilities\scripts

Show-Information    
