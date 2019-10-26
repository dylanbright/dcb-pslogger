#testing
#StorageAccountStuff
using module './pslogger/pslogger.psm1'

$storageAccountName = 'dcbscriptsstor001'
$storageAccountResourceGroupName  ='dcb-scripts-rg'
$storageContainerName ='logs'
$storageAccountkey = (Get-AzStorageAccountKey -ResourceGroupName $storageAccountResourceGroupName -Name $storageAccountName).value[0]

$mylogger = [pslogger]::new('TestLogger','append','./','testLog',$true,$storageAccountName,$storageContainerName,$storageAccountkey)
$mylogger.addMessage('mysource','test message')
$mylogger.addMessage('newsource','mymessage')
$mylogger.LogMessages
#$mylogger.saveLog()
$mylogger.exportToAzure()

Remove-Module pslogger