# to run this, navigate to the repo and run ./Automation/create_alert.ps1 
# with the 1st 7 parameters inline 

param(
        [string] [Parameter(Mandatory=$true)] $TenantId,          
        [string] [Parameter(Mandatory=$true)] $SPApplicationId,     #username for SP
        [string] [Parameter(Mandatory=$true)] $SPSecret,            #password for SP
        [string] [Parameter(Mandatory=$true)] $SubscriptionId,
        [string] [Parameter(Mandatory=$true)] $AlertName,
        [string] [Parameter (Mandatory=$false)] $TargetResourceGroupName = "nsc-functions-team1",   # RG for target Function App
        [string] [Parameter (Mandatory=$false)] $TargetResourceId = "nsc-functionsapp-team1",       # name of target Function App
        [string] [Parameter (Mandatory=$false)] $AlertDescription = "Check every 5 minutes to see if more than 30 5xx responses have been generated",
        [int]    [Parameter (Mandatory=$false)] $AlertSeverity = 3,
        [string] [Parameter (Mandatory=$false)] $MetricName = "Http5xx",       # to get possible metric names: Get-AzMetricDefinition [resourceId]
        [string] [Parameter (Mandatory=$false)] $Operator = "GreaterThanOrEqual",
        [int]    [Parameter (Mandatory=$false)] $Threshold = 30,
        [string] [Parameter (Mandatory=$false)] $TimeAggregation = "Count",
        [string] [Parameter (Mandatory=$false)] $WindowSize = "PT5M",
        [string] [Parameter (Mandatory=$false)] $EvaluationFrequency = "PT5M",
        [string] [Parameter (Mandatory=$false)] $ActionResourceGroupName = "nataliasprint1test",        # RG for Action
        [string] [Parameter (Mandatory=$false)] $ActionGroupId = "application insights smart detection" # name of Action
      )

$pathToAlertTemplate = "./alert_template.json"   

# Logs in and sets subscription   
Import-Module ..\Login   
Login $TenantId $SPApplicationId $SPSecret $SubscriptionId

# Check Resource Groups
$targetResourceGroupExists = (Get-AzResourceGroup $TargetResourceGroupName -ErrorAction SilentlyContinue).ResourceGroupName -eq $TargetResourceGroupName
$actionResourceGroupExists = (Get-AzResourceGroup $ActionResourceGroupName -ErrorAction SilentlyContinue).ResourceGroupName -eq $ActionResourceGroupName

# Create Parameter Hash Table
$templateParams = @{
        "alertName" = $AlertName
        "alertDescription" = $AlertDescription
        "alertSeverity" = $AlertSeverity
        "targetResourceGroup" = $TargetResourceGroupName
        "targetResourceId" = $TargetResourceId
        "metricName" = $MetricName
        "operator" = $Operator
        "threshold" = $Threshold
        "timeAggregation" = $TimeAggregation
        "windowSize" = $WindowSize
        "evaluationFrequency" = $EvaluationFrequency
        "actionResourceGroup" = $ActionResourceGroupName
        "actionGroupId" = $ActionGroupId
}

if (!$targetResourceGroupExists) {
    Write-Host "Resource Group $TargetResourceGroupName does not exist. Cannot create Alert."
} elseif (!$actionResourceGroupExists) {
    Write-Host "Resource Group $ActionResourceGroupName does not exist. Cannot create Alert."
} else {
    # Creates Alert if one of the same name does not already exist in the Resource Group
    $alertExists = (Get-AzMetricAlertRuleV2 -Name $AlertName -ResourceGroupName $TargetResourceGroupName -ErrorAction SilentlyContinue).Name -eq $AlertName
    if (!$alertExists) { 
        Write-Host "Alert does not exist. Creating now."
        # create Alert with given name
        New-AzResourceGroupDeployment `
            -ResourceGroupName $TargetResourceGroupName `
            -TemplateFile $pathToAlertTemplate `
            -TemplateParameterObject $templateParams
    } else {
        Write-Host "Alert with name $AlertName already exists."
    }
}
