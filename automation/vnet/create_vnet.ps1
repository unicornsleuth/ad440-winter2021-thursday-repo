# to run this, navigate to the repo and run ./Automation/create_vnet_script.ps1 
# with the 1st 7 parameters inline -location westus2

param(
        [string] [Parameter(Mandatory=$true)] $TenantId,          
        [string] [Parameter(Mandatory=$true)] $SPApplicationId,     #username for SP
        [string] [Parameter(Mandatory=$true)] $SPSecret,            #password for SP
        [string] [Parameter(Mandatory=$true)] $SubscriptionId,
        [string] [Parameter(Mandatory=$true)] $ResourceGroupName,
        [string] [Parameter(Mandatory=$true)] $Location,
        [string] [Parameter(Mandatory=$true)] $VNetName,
        [string] [Parameter(Mandatory=$false)] $VNetAddressPrefix
      )

$pathToVNetTemplate = "./vnet_template.json"   

# Logs in and sets subscription      
#& "../login.ps1" $tenantId $applicationId $secret $subscriptionId
Import-Module ..\Login
Login $tenantId $applicationId $secret $subscriptionId


# Creates/Updates resource group
New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Force

# Creates VNet if one of the same name does not already exist in the Resource Group
$vNetExists = (Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue).Name -eq $VNetName
if (!$vNetExists) { 
    Write-Host "Virtual Network does not exist. Creating now."
    # create vNet with given name (can also add address prefix and location if not same as rg)
    New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $pathToVNetTemplate -vNetName $VNetName
} else {
    Write-Host "Virtual Network with name $VNetName already exists."
}
