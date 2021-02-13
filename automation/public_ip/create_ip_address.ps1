## Command to create a public ip ##

# Take parameter used to create Public IP Address
param(
        [string] [Parameter(Mandatory=$true)] $tenantId, # Tenant ID found in the Key Vault     
        [string] [Parameter(Mandatory=$true)] $applicationId, # Application ID found in the Key Vault  
        [string] [Parameter(Mandatory=$true)] $secret, # Secret Key found in the Key Vault            
        [string] [Parameter(Mandatory=$true)] $subscriptionId, # Subscription ID found in the Key Vault  
        [string] [Parameter(Mandatory=$true)] $resourceGroupName, # Name of the resource group
        [string] [Parameter(Mandatory=$true)] $publicIp # Name of the azure public address
      )

      #Logs in and sets subscription      
      #& "../login.ps1" $tenantId $applicationId $secret $subscriptionId
      Import-Module ..\Login
      Login $tenantId $applicationId $secret $subscriptionId

      $pathToPubIpTemplate = "./public_ip_template.json"

      # Checks if resource group exists
      if (!(Get-AzResourceGroup $resourceGroupName -ErrorAction SilentlyContinue)){ 
        Write-Output "The resource group $resourceGroupName doesn't exist!"
      }
      else{  
        
        # Get the location of the resource group
        $loc = Get-AzResourceGroup -Name $resourceGroupName | select-object -expandproperty location

          # Creates a new Public IP Address based on the params.
          New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $pathToPubIpTemplate -pubIpName $publicIp -location $loc
        
          Write-Output "Successfully created public ip address named "$publicIp" for the resource group "$resourceGroupName"" 
      }

