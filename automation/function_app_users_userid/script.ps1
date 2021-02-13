param(
    [Parameter(Mandatory=$true)] 
    [string]
    $TenantID,

    [Parameter(Mandatory=$true)] 
    [string]
    $SPApplicationId,

    [Parameter(Mandatory=$true)] 
    [string]
    $SPSecret,

    [Parameter(Mandatory=$true)] 
    [string]
    $SubscriptionId,

    [Parameter(Mandatory=$true)] 
    [string] 
    $resourceGroupName,

    [Parameter(Mandatory=$true)] 
    [string]
    $location,

    [Parameter(Mandatory=$true)] 
    [string]
    $templateUri
)

Import-Module ..\Login

Login $TenantId $SPApplicationId $SPSecret $SubscriptionId

New-AzResourceGroup -Name $resourceGroupName -Location $location
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $templateUri