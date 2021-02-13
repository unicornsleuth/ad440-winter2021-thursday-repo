[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $SubscriptionId,

    [Parameter(Mandatory=$true)]
    [string]
    $rgName,

    [Parameter(Mandatory=$true)]
    [string]
    $location,

    [Parameter(Mandatory=$true)]
    [string]
    $TenantId,

    [Parameter(Mandatory=$true)]
    [string]
    $ServicePrincipalId,

    [Parameter(Mandatory=$true)]
    [string]
    $ServicePrincipalPassword,

    [Parameter(Mandatory=$true)]
    [string]
    $TemplatefilePath,

    [Parameter(Mandatory=$true)]
    [string]
    $FunctionName,

    [Parameter(Mandatory=$true)]
    [string]
    $StorageAccountName,

    [Parameter(Mandatory=$true)]
    [string]
    $AppServiceplaneName,

    [Parameter(Mandatory=$true)]
    [string]
    $DeployName
)
#open log
$prefix = "jin-templa-deployment"
$stamp = (Get-Date).toString().Replace("/","-").Replace(":","-")
Start-Transcript "./$prefix-$stamp.log"

# $credentials = New-Object -TypeName System.Management.Automation.PSCredential($ServicePrincipalId, $ServicePrincipalPassword );
# Connect-AzAccount -Credential $credentials -ServicePrincipal -Tenant $TenantId -Subscription $SubscriptionId;
# Set-AzContext $SubscriptionId

# Use new Login Module to Log In
Import-Module ..\..\Login
Login $TenantId $ServicePrincipalId $ServicePrincipalPassword $SubscriptionId

New-AzResourceGroup `
  -Name $rgName `
  -Location $location

New-AzResourceGroupDeployment `
  -Name $DeployName `
  -ResourceGroupName $rgName `
  -TemplateFile $TemplatefilePath `
  -Location $location `
  -StorageAccountName $StorageAccountName  `
  -AppServiceplaneName $AppServiceplaneName `
  -FunctionName $FunctionName



  Stop-Transcript