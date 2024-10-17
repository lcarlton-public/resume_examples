<#
.SUMMARY
Create a new VM with specified parameters.
.DESCRIPTION
This script creates a new Hyper-V VM with configurable options for name, memory, generation, disk size, and network switch. 
.PARAMETER VMName
The name of the virtual machine.
.PARAMETER MemoryStartupBytes
The amount of startup memory in bytes.
.PARAMETER Generation
The generation of the virtual machine (1 or 2).
.PARAMETER NewVHDPath
The path to the new virtual hard disk file.
.PARAMETER NewVHDSizeBytes
The size of the new virtual hard disk in bytes.
.PARAMETER SwitchName
The name of the virtual switch to connect the VM to.
.PARAMETER ISOPath
The path to the ISO file for the DVD drive.
.NOTES
Author: Leron Carlton
Contact: lcarlton@student.cscc.edu
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$VMName,

    [Parameter(Mandatory = $false)]
    [int64]$MemoryStartupBytes = 4GB, 

    [Parameter(Mandatory = $false)]
    [int]$Generation = 2,

    [Parameter(Mandatory = $false)]
    [string]$NewVHDPath = "C:\Virtual Machines\$VMName\$VMName.vhdx",

    [Parameter(Mandatory = $false)]
    [int64]$NewVHDSizeBytes = 50GB,

    [Parameter(Mandatory = $true)]
    [string]$SwitchName,

    [Parameter(Mandatory = $false)]
    [string]$ISOPath = "C:\_en-us.iso" 
)

# Input Validation (Examples)
if (Get-VM -Name $VMName) {
    Write-Error "A VM with the name '$VMName' already exists."
    exit 1
}

if (!(Get-VMSwitch -Name $SwitchName)) {
    Write-Error "The virtual switch '$SwitchName' does not exist."
    exit 1
}

# Create the VM
try {
    $VM = @{
        Name = $VMName
        MemoryStartupBytes = $MemoryStartupBytes
        Generation = $Generation
        NewVHDPath = $NewVHDPath
        NewVHDSizeBytes = $NewVHDSizeBytes
        BootDevice = "VHD"
        Path = "C:\Virtual Machines\$VMName"
        SwitchName = $SwitchName
    }

    New-VM @VM

    # Add DVD Drive
    Add-VMDvdDrive -VMName $VMName -Path $ISOPath

    Write-Host "VM '$VMName' created successfully."
}
catch {
    Write-Error "An error occurred while creating the VM: $_"
    exit 1
}

# Optionally start the VM
# Start-VM -Name $VMName
