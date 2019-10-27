#Example use of the pslogger class.

using module "./dcb-pslogger/drop/pslogger/pslogger.psm1"
param ($azStorageKey,$testName)
Install-Module Az -Force -AllowClobber  #get the latest az module
#using module @{ModuleName="$(Build.ArtifactStagingDirectory)/pslogger/pslogger.psm1";ModuleVersion="0.0.2"}
$pslogname = 'testLogging'
$saveMode ='append' #add enum for this.  Options Append,aggregate
$displayMessages = $true
$outputpath = './'
$outputFilePrefix = $testName
$ToAzure = $true
$storageAccountName = 'dcbscriptsstor001'
#$storageAccountResourceGroupName  ='dcb-scripts-rg'
$storageContainerName ='logs'
#$storageAccountkey = (Get-AzStorageAccountKey -ResourceGroupName $storageAccountResourceGroupName -Name $storageAccountName).value[0]
$storageAccountkey = $azStorageKey
$mylogger = [pslogger]::new($pslogname,$saveMode,$displayMessages,$outputpath,$outputFilePrefix,$ToAzure,$storageAccountName,$storageContainerName,$storageAccountkey)
$mylogger.addMessage('azuredevops','test message')
$mylogger.addMessage('azuredevops',$stageName)
$mylogger.LogMessages
#$mylogger.saveLog()
$mylogger.exportToAzure()

