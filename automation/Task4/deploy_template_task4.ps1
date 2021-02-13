#parameters required to run the script.
param(
    [Parameter(Mandatory=$True)]
    [string]
    $subscriptionId,

    [Parameter(Mandatory=$True)]
    [string]
    $tenantId,

    [Parameter(Mandatory=$True)]
    [string]
    $servicePrincipalId,

    [Parameter(Mandatory=$True)]
    [String]
    $servicePrincipalPassword,

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
    [string]
    $templateFilePath
)

Clear-AzContext -Force;
$securePassword = ConvertTo-SecureString -String $servicePrincipalPassword -AsPlainText -Force;
$credentials = New-Object -TypeName System.Management.Automation.PSCredential($servicePrincipalId, $securePassword);

Connect-AzAccount -Credential $credentials -ServicePrincipal -Tenant $tenantId -SubscriptionId $subscriptionId;

New-AzResourceGroup -Name $resourceGroupName -Location $location

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile  $templateFilePath -functionName $functionName -storageAccountName $storageAccountName -appServicePlanName $appServicePlanName -location $location

