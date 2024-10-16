<#
This scripts is to create a single VM, attach it to the designated switch, and then add a DVD Drive with ISO for the image afterwards.
It also defines the storage location which can be a network share or whatever you would like to add.
We designate the VMname as a variable in the first line to make it easier to call throughout.
#>

$VMName = "<Name Of VM>"

$VM = @{
    Name = $VMName
    MemoryStartupbytes = 4194304000
    Generation = 2
    NewVHDPath =  "C:\Virtual Machines\$VMName\$VMName.vhdx" #location of virtual machine folder
    NewVHDSizeBytes = 53687091200
    BootDevice = "VHD"
    Path = "C:\Virtual Machines\$VMName" #location of virtual machine folder
    SwitchName = "<Name Of Switch>" #the name of the switch you'd like to attach this too

}

New-VM @VM

Add-VMDvdDrive -VMName $VMName -Path C:\\_en-us.iso #what iso you want to attach to the VM
