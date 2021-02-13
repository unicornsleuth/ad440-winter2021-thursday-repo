[CmdletBinding()]
param (
    [Parameter(Mandatory=$True)]
    [string]
    $subscriptionId,

    [Parameter(Mandatory=$True)]
    [string]
    $tenantId,
    

    [Parameter(Mandatory=$True)]
    [string]
    $servicePrincipalId,

   
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$servicePrincipalPassword=$(Throw "Password required."),
   
    
    [Parameter(Mandatory=$True)]
    [string]
    $resourceGroupName,

    [Parameter(Mandatory=$True)]
    [string]
    $functionName,

    [Parameter(Mandatory=$True)]
    [string]
    $storageAccountName,

    [Parameter(Mandatory=$True)]
    [string]
    $appServicePlanName,

    [Parameter(Mandatory=$True)]
    [string]
    $location,

    [Parameter(Mandatory=$True)]
    $templateFilePath
)

#open log
$prefix = "yergu-Arm-deplo"
$stamp = (Get-Date).toString().Replace("/","-").Replace(":","-")
Start-Transcript "./$prefix-$stamp.log"


Clear-AzContext -Force;
$securePassword = $servicePrincipalPassword | ConvertTo-SecureString -AsPlainText -Force

$credentials = New-Object -TypeName System.Management.Automation.PSCredential($servicePrincipalId, $securePassword);


Connect-AzAccount -Credential $credentials -ServicePrincipal -Tenant $tenantId -Subscription $subscriptionId;

Set-AzContext $SubscriptionId
New-AzResourceGroup -Name $resourceGroupName -Location $location
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile  $templateFilePath -functionName $functionName -storageAccountName $storageAccountName -appServicePlanName $appServicePlanName -location $location


Stop-Transcript



