#Example use of the pslogger class.

#using module './pslogger/pslogger.psm1'lo  
using module @{ModuleName='./pslogger/pslogger.psm1';ModuleVersion='0.0.2'}
$pslogname = 'testLogging'
$saveMode ='append' #add enum for this.  Options Append,aggregate
$displayMessages = $true
$outputpath = './'
$outputFilePrefix = 'testLog'
$ToAzure = $true
$storageAccountName = 'dcbscriptsstor001'
#$storageAccountResourceGroupName  ='dcb-scripts-rg'
$storageContainerName ='logs'
#$storageAccountkey = (Get-AzStorageAccountKey -ResourceGroupName $storageAccountResourceGroupName -Name $storageAccountName).value[0]
$storageAccountkey = get-content '~/azstorkey.txt'
$mylogger = [pslogger]::new($pslogname,$saveMode,$displayMessages,$outputpath,$outputFilePrefix,$ToAzure,$storageAccountName,$storageContainerName,$storageAccountkey)
$mylogger.addMessage('mysource','test message')
$mylogger.addMessage('newsource','mymessage')
$mylogger.LogMessages
#$mylogger.saveLog()
$mylogger.exportToAzure()

