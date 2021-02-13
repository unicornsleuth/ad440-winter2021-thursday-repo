param(
    # Default path, can be overwritten if custom path is provided
    $DefaultTemplateFilePath =  "./template.json",

    # Used for overwriting default path
    [Parameter(Mandatory=$False)]
    [string]
    $TemplateFilePath,

    # Your tenant Id in Azure
    [Parameter(Mandatory=$True)]
    [string]
    $TenantId,

    # Found in Azure secrets as appId
    [Parameter(Mandatory=$True)]
    [string]
    $SPApplicationId,

    # Found in Azure secrets as secret
    [Parameter(Mandatory=$True)]
    [string]
    $SPSecret,

    # Your tenant Id in Azure
    [Parameter(Mandatory=$True)]
    [string]
    $SubscriptionId,

    # Name for the resource group you will create
    [Parameter(Mandatory=$True)]
    [string]
    $ResourceGroupName,

    # Region. ex. westus, eastus...
    [Parameter(Mandatory=$True)]
    [string]
    $Location,

    [Parameter(Mandatory=$True)]
    [string]
    $DeploymentName,

    # For tags, please include your email
    [Parameter(Mandatory=$True)]
    [string]
    $OwnerEmail,

    # Security group name ex. automation-nsg-<initials>
    [Parameter(Mandatory=$True)]
    [string]
    $SecurityGroupName,

    # Security rule params, see example below in $params line 125 if unsure of inputs
    [Parameter(Mandatory=$True)]
    [string]
    $SecurityRuleName,

    [Parameter(Mandatory=$True)]
    [string]
    $Protocol,

    [Parameter(Mandatory=$True)]
    [string]
    $SourcePortRange,

    [Parameter(Mandatory=$True)]
    [string]
    $DestinationPortRange,

    [Parameter(Mandatory=$True)]
    [string]
    $SourceAddressPrefix,

    [Parameter(Mandatory=$True)]
    [string]
    $DestinationAddressPrefix,

    [Parameter(Mandatory=$True)]
    [string]
    $Access,

    [Parameter(Mandatory=$True)]
    [string]
    $Priority,

    [Parameter(Mandatory=$True)]
    [string]
    $Direction,

    # Note, below are not mandatory params and are here if further nsg specs are needed
    [Parameter(Mandatory=$False)]
    [string]
    $SourcePortRanges,

    [Parameter(Mandatory=$False)]
    [string]
    $DestinationPortRanges,

    [Parameter(Mandatory=$False)]
    [string]
    $SourceAddressPrefixes,

    [Parameter(Mandatory=$False)]
    [string]
    $DestinationAddressPrefixes
)

# If template path provded, do not use default
if ($TemplateFilePath) {
    $DefaultTemplateFilePath = $TemplateFilePath
}

# Hash table for template deployment
$templateParams = @{
    tags = @{
        "ownerEmail" = $OwnerEmail
    }
    securityGroupName = $SecurityGroupName

    securityRules = @{
        "name" = $SecurityRuleName
        "protocol" = $Protocol    
        "sourcePortRange" = $SourcePortRange  
        "destinationPortRange" = $DestinationPortRange
        "sourceAddressPrefix" = $SourceAddressPrefix
        "destinationAddressPrefix" = $DestinationAddressPrefix
        "access" = $Access          
        "priority" = $Priority
        "direction" = $Direction
        "sourcePortRanges" = $SourcePortRanges
        "destinationPortRanges" = $DestinationPortRanges     
        "sourceAddressPrefixes" = $SourceAddressPrefixes
        "destinationAddressPrefixes" = $DestinationAddressPrefixes
    }

# Example SSH security rule
<#
        "name" = SSH_Access;
        "protocol" = "TCP";         
        "sourcePortRange"= "*";   
        "destinationPortRange"= "22";
        "sourceAddressPrefix"= "97.113.101.80/32";
        "destinationAddressPrefix"= "*"
        "access"= "Allow";              
        "priority"= 100;                 
        "direction"= "Inbound";         
        "sourcePortRanges"= "";         
        "destinationPortRanges"= "";     
        "sourceAddressPrefixes"= "";    
        "destinationAddressPrefixes"= "";
#>
}

# Login using Larissa's Login module & contains error handling)
Import-Module ..\Login
Login $TenantId $SPApplicationId $SPSecret $SubscriptionId

# Error handling for general issues + resource group creation/update
If (New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Force) {
    Write-Host -ForegroundColor Blue "`nResource Group created/updated successfully.`n"
} Else {
    Write-Host -ForegroundColor Red $_.Exception.Message
    Write-Host -ForegroundColor Yellow "`nError creating/updating resource group. See above error message(s). Please double check all entered parameters and try again.`n"
}

# Error handling for general issues & nsg resource group deployment

# Check if NSG already exists
If (Get-AzNetworkSecurityGroup -Name $SecurityGroupName -ResourceGroupName $ResourceGroupName -ErrorAction Ignore) {
    Write-Host -ForegroundColor Red "`nNetwork Security Group already exists, please try again with a different SecurityGroupName.`n"
} Else {
    # Deploy with template + parameters
    If (New-AzResourceGroupDeployment -Name $DeploymentName -ResourceGroupName $ResourceGroupName -TemplateFile $DefaultTemplateFilePath -TemplateParameterObject $templateParams -Verbose) {
        Write-Host -ForegroundColor Blue "`nNSG created successfully.`n"
    } Else {
        Write-Host -ForegroundColor Red $_.Exception.Message
        Write-Host -ForegroundColor Yellow "`nError deploying resources. See above error message(s).Please double check all entered parameters and try again.`n"
    }
}

<# 
TODO: Look into creating multiple security rules
#>