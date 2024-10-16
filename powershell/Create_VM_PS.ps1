<#
.SUMMARY
Create a new VM, 4MB, Gen 2, save location, and attach to lab switch.
.DESCRIPTION
This will create a new Hyper-V VM, and attach an ISO to boot when started.
.PARAMETER Name
This will be the naming convention of the VM. We could add a check for the name
.NOTES
Author: Leron Carlton
Contact: lcarlton@student.cscc.edu
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
