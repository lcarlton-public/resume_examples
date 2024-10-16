<#
This scripts is to create a single VM, attach it to the designated switch, and then add a DVD Drive with ISO for the image afterwards.
It also defines the storage location which can be a network share or whatever you would like to add.
We designate the VMname as a variable in the first line to make it easier to call throughout.
#>

$VMName = "CLab-WS2019-06"

$VM = @{
    Name = $VMName
    MemoryStartupbytes = 4194304000
    Generation = 2
    NewVHDPath =  "E:\Virtual Hard Disks\Virtual Machines\$VMName\$VMName.vhdx"
    NewVHDSizeBytes = 53687091200
    BootDevice = "VHD"
    Path = "E:\Virtual Hard Disks\Virtual Machines\$VMName"
    SwitchName = "CLab-01-Switch"

}

New-VM @VM

Add-VMDvdDrive -VMName $VMName -Path \\192.168.1.149\media\iso\17763.3650.221105-1748.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso