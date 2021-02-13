#This script creates a Ubuntu VM on Azure.
#The script logs user into Azure using Service Principal. To log in,
#Tenant ID, App ID, Secret, and Subscription ID are required.
#User must provide Azure Resource Group Name, VM Name, Admin Username/Password

param (
    [string] [Parameter(Mandatory=$true)] $tenantId, #Tenant ID used to login to Azure with Service Principal
    [string] [Parameter(Mandatory=$true)] $applicationId, #App ID used to login to Azure with Service Principal
    [string] [Parameter(Mandatory=$true)] $secret, #Azure Secret used to login to Azure with Service Principal
    [string] [Parameter(Mandatory=$true)] $subscriptionId, #Subscr. ID used to login to Azure with Service Principal
    [string] [Parameter(Mandatory=$true)] $rgName, #Resource Group Name required
    [string] [Parameter(Mandatory=$true)] $vmName, #VM Name required
    [string] [Parameter(Mandatory=$true)] $adminUsername, #Admin Username required
    [string] [Parameter(Mandatory=$true)] $adminPassword, #Admin Password required
    [string] [Parameter(Mandatory=$false)] $location='West US2', #Default value for RG/VM Location
    [string] [Parameter(Mandatory=$false)] $vNetName='-vnet',  #Default value for Virtual Network Name
    [string] [Parameter(Mandatory=$false)] $nsgName='-nsg', #Default value for Network Security Group Name
    [string] [Parameter(Mandatory=$false)] $publicIpName='-publicIpAddress' #Default value for Public IP Address Name
    )

#Concat vnet, nsg, and public ip names with virtual machine names
$vNetName = $vmName + $vNetName
$nsgName = $vmName + $nsgName
$publicIpName = $vmName + $publicIpName

#convert password to secure string
[securestring]$securePassword = ConvertTo-SecureString $adminPassword -AsPlainText -Force  

#template file for Virtual Machine ARM Template    
$templateFile = "$PSScriptRoot\ubuntu_vm_parameters.json" 

# Logs in and sets subscription      
#& "../login.ps1" $tenantId $applicationId $secret $subscriptionId
Import-Module ..\Login
Login $tenantId $applicationId $secret $subscriptionId

#Check to see if resource group name exists. If not it will create one by that name.
#If Resource Group already exists, the script will proceed to the VM.
Write-Output "Checking to see if Azure Resource Group exists."
Get-AzResourceGroup -Name $rgName -ErrorVariable norg -ErrorAction SilentlyContinue
if ($norg)
{ 
    Write-Output "Resource group did not exist. Creating now."
    New-AzResourceGroup -Name $rgName -Location $location
}
else
{

    Write-Output "Resource group already exists, proceeding to create VM."
}

#Check to see if VM exists
#If not, it will create VM using ARM Template/User provided parameters
Write-Output "Checking to see if Virtual Machine by this name exists in resource group $rgName."
Get-AzVM -Name "$vmName" -ResourceGroupName $rgName -ErrorVariable notPresent -ErrorAction SilentlyContinue

if ($notPresent) {
    Write-Output "Virtual Machine did not exist in resource group $rgName. Creating Now."  
    
    #Create VM
    New-AzResourceGroupDeployment `
    -ResourceGroupName "$rgName" `
    -TemplateFile "$templateFile" `
    -adminUsername "$adminUsername" `
    -adminPassword $securePassword `
    -vmName "$vmName" `
    -virtualNetworkName "$vNetName" `
    -networkSecurityGroupName "$nsgName" `
    -publicIpName "$publicIpName" 
}
else {
    Write-Output "Error: A Virtual Machine by this name already exists in Resource Group $rgName."  
}


