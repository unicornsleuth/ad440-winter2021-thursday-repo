param(
    [string]
    [Parameter(Mandatory=$true)]
    $resourceGroup, # Name of resource group to put storage account in

    [string]
    [Parameter(Mandatory=$true)]
    $location, # Regional location EG "westus2" or "japaneast"

    [string]
    [Parameter(Mandatory=$true)]
    $storageAccountName, # Name to give storage account

    # Below required for Login module
    [string] [Parameter(Mandatory=$true)] $tenantId,
    [string] [Parameter(Mandatory=$true)] $applicationId,
    [string] [Parameter(Mandatory=$true)] $secret,
    [string] [Parameter(Mandatory=$true)] $subscriptionId
)

Start-Transcript -Path "$PSScriptRoot\create_Azure_StorageAccountlog.log"
Write-Host "Logging to $PSScriptRoot\create_Azure_StorageAccountlog.log"
Write-Host "Create Azure Storage Account"

# Custom module Login
Import-Module ..\Login
# Provides function Login (tenantID, applicationID, secret, subscriptionID)
Login $tenantId $applicationId $secret $subscriptionId

# Checks if resource group exists
Get-AzResourceGroup -Name $resourceGroup -ErrorVariable noRG -ErrorAction SilentlyContinue
if($noRG){
    #Resource group does not exist
    Write-Host "Creating Resource Group $resourceGroup"
    New-AzResourceGroup -Name $resourceGroup -Location $location
} else {
    Write-Host "Using existing Resource Group $resourceGroup"
}

#Get location from resource group, useful for if RG already exists
$location = Get-AzResourceGroup -Name $resourceGroup | Select-Object -expandproperty location

#Check if the named storage account already exists
$doesntExist = Get-AzStorageAccountNameAvailability -Name $storageAccountName

if($doesntExist.NameAvailable){
    #If storage account name is not used
    Write-Host "Create StorageAccount from template.json"
    New-AzResourceGroupDeployment `
        -ResourceGroupName $resourceGroup `
        -TemplateFile "./template.json" `
        -location $location `
        -storageAccountName $storageAccountName

    if(Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName){
        Write-Host "Successfully created storage account $storageAccountName"
    } else {
        Write-Error "Failed to create storage account, Failure in create_Azure_StorageAccount.ps1"
    }
} else {
    #If storage account name is invalid
    $createSAError = $doesntExist.Message
    Write-Error "$createSAError"
}

Stop-Transcript