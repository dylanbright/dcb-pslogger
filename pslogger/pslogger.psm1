class psLogEntry {
    [datetime]$datetime
    [string]$source
    [string]$Message
    # [string] $dateTimeFormat
    psLogEntry ([datetime]$datetime,[string]$source,[string]$message){
        $this.datetime = $datetime
        $this.source = $source
        $this.Message = $message
        $this.datetime = Get-Date
    }
    # psLogEntry ([string]$source,[string]$message,[string]$datetimeformat){
    #     $this.source = $source
    #     $this.Message = $message
    #     $this.datetime = Get-Date -Format $datetimeformat
    # }
}

class psLogger {
    #TO DO Add error handling to the azure stuff and other things that could fail
    [string]$pslogname
    [string]$saveMode
    [boolean]$displayMessages
    [string]$outputPath
    [string]$outputFilePrefix
    $LogMessages
    [boolean]$ToAzure
    [string]$storageAccountName
    [string]$storageAccountContainer
    [string]$storageAccountKey
    [string]$lastoutputfilepath
    [string]$lastoutputfilename
    #Constructor with storage account logging.
    psLogger(  
            [string]$pslogname,
            [string]$saveMode, #add enum for this.  Options Append,aggregate
            [boolean]$displayMessages,
            [string]$outputpath,
            [string]$outputFilePrefix,
            [string]$ToAzure,
            [string]$storageAccountName,
            [string]$storageAccountContainer,
            [string]$storageAccountKey)
             {
                $this.pslogname = $pslogname
                $this.saveMode = $saveMode
                $this.displayMessages = $displayMessages
                $this.outputPath = $outputpath
                $this.outputFilePrefix = $outputFilePrefix
                $this.ToAzure = $ToAzure
                $this.storageAccountName = $storageAccountName
                $this.storageAccountContainer = $storageAccountContainer
                $this.storageAccountKey = $storageAccountKey
                $this.LogMessages = @()
                if ($saveMode -eq 'append'){
                    $this.initializeLogFile()
                }
             }
    #constructor for local storage only
    psLogger(  
            [string]$pslogname,
            [string]$saveMode, #add enum for this.  Options Append,aggregate
            [boolean]$displayMessages,
            [string]$outputpath,
            [string]$outputFilePrefix)
             {
                $this.pslogname = $pslogname
                $this.saveMode = $saveMode
                $this.displayMessages = $displayMessages
                $this.outputPath = $outputpath
                $this.outputFilePrefix = $outputFilePrefix
                $this.ToAzure = $false
                $this.LogMessages = @()
                if ($saveMode -eq 'append'){
                    $this.initializeLogFile()
                }
             }

    initializeLogFile (){
        $filename = $this.outputFilePrefix + '_' + (get-date -Format FileDateTime) + '.csv'
        $this.lastoutputfilename = $filename
        $this.lastoutputfilepath = ($this.outputPath + "/" + $filename)
        $this.addMessage('pslogger',"Created log file at" + $this.lastoutputfilepath)
    }         
    addMessage($source,$message){
        $newLogDateTime = Get-Date
        $newLogEntry = [psLogEntry]::new($newLogDateTime,$source,$message)
        if ($this.displayMessages){
            write-host $newLogEntry.datetime $newLogEntry.source $newLogEntry.Message
        }
        $this.LogMessages += $newLogEntry
        #[psLogEntry]::new($source,$message) #why was this here?
        switch ($this.saveMode){
            "append" {
                $newLogEntry | export-csv -Path $this.lastoutputfilepath -NoTypeInformation -Append
            }
            default {}
        }
    }
    #save all messages to local file
    [string]saveLog(){
        $this.initializeLogFile()
        $this.addMessage("pslogger","Saving log to $this.lastoutputfilepath") 
        $this.LogMessages | export-csv -Path $this.lastoutputfilepath -NoTypeInformation -Force
        return $this.lastoutputfilepath
    }
    #save file to azure storage         
    [string]exporttoazure(){
        $this.addMessage('pslogger',("uploading log" + $this.lastoutputfilename + " to storage account:" + $this.storageAccountName))
        #if we are not using append mode, save the log to a file.
        If (!($this.saveMode -eq 'append')){
            $this.saveLog()
        }
        Try {
            $context = New-AzStorageContext -StorageAccountName $this.storageAccountName -StorageAccountKey $this.storageAccountKey -ErrorAction Stop
        } catch {
            $this.addMessage('pslogger','error creating storage context.  Key or storage account may be invalid.')
            
        }


        #If the container does not exist, create it
        $storContainer = Get-AzStorageContainer -Name $this.storageAccountContainer -Context $context
        if (!($storContainer)){
            $storContainer = New-AzStorageContainer -Context $context -Name $this.storageAccountContainer
        }
        Set-AzStorageBlobContent -File $this.lastoutputfilepath -Container $this.storageAccountContainer -Blob $this.lastoutputfilename -Context $context
        return (Get-AzStorageBlob -Context $context -Container $this.storageAccountContainer -Blob $this.lastoutputfilename).Name
        
    }
}


# #testing
# #StorageAccountStuff
# $storageAccountName = 'dcbscriptsstor001'
# $storageAccountResourceGroupName  ='dcb-scripts-rg'
# $storageContainerName ='logs'
# $storageAccountkey = (Get-AzStorageAccountKey -ResourceGroupName $storageAccountResourceGroupName -Name $storageAccountName).value[0]

# $mylogger = [pslogger]::new('TestLogger','append','./','testLog',$true,$storageAccountName,$storageContainerName,$storageAccountkey)
# $mylogger.addMessage('mysource','test message')
# $mylogger.addMessage('newsource','mymessage')
# $mylogger.LogMessages
# #$mylogger.saveLog()
# $mylogger.exportToAzure()



