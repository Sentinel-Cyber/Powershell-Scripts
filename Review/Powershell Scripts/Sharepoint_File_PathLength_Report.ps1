Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
  
#Function to scan all files with long file names in a site
Function Scan-SPOLongFilePath($SiteURL)
{   
    Try {
        #Setup the context
        $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
        $Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.UserName,$Cred.Password)
   
        #Get the web from given URL and its subsites
        $Web = $Ctx.web
        $Ctx.Load($Web)
        $Ctx.Load($Web.Lists)
        $Ctx.Load($web.Webs)
        $Ctx.executeQuery()
           
        #Arry to Skip System Lists and Libraries
        $SystemLists = @("Converted Forms", "Master Page Gallery", "Customized Reports", "Form Templates", "List Template Gallery", "Theme Gallery",
                            "Reporting Templates", "Solution Gallery", "Style Library", "Web Part Gallery","Site Assets", "wfpub", "Site Pages", "Images")
       
        Write-host -f Yellow "Processing Site: $SiteURL"
   
        #Prepare the CAML query
        $Query = New-Object Microsoft.SharePoint.Client.CamlQuery
        $Query.ViewXml = "@
        <View Scope='RecursiveAll'>
            <Query>
                <OrderBy><FieldRef Name='ID' Ascending='TRUE'/></OrderBy>
            </Query>
            <RowLimit Paged='TRUE'>2000</RowLimit>
        </View>"
 
        #Filter Document Libraries to Scan 
        $Lists = $Web.Lists | Where {$_.BaseType -eq "DocumentLibrary" -and $_.Hidden -eq $false -and $SystemLists -notcontains $_.Title}
         
        #Loop through each document library
        Foreach ($List in $Lists)
        {
            $Counter=1
            #Batch Process List items 
            Do {
                $ListItems = $List.GetItems($Query)
                $Ctx.Load($ListItems)
                $Ctx.ExecuteQuery() 
                $Query.ListItemCollectionPosition = $ListItems.ListItemCollectionPosition
              
                If($ListItems.count -gt 0)
                {
                    Write-host -f Cyan "`t Processing Document Library: '$($List.Title)', Auditing $($ListItems.Count) Item(s)"
   
                    $DocumentInventory = @()
                    #Iterate through each file and get data
                    Foreach($Item in $ListItems | Where {$_.FileSystemObjectType -eq "File"})
                    {
                        #Display a Progress bar
                        Write-Progress -Activity "Scanning Files in the Library" -Status "Testing if the file has long URL '$($Item.FieldValues.FileRef)' ($Counter of $($List.ItemCount))" -PercentComplete (($Counter / $List.ItemCount) * 100) 
 
                        $File = $Item.File
                        $Ctx.Load($File)
                        $Ctx.ExecuteQuery()
  
                        #calculate the Absolute encoded URL of the File
                        If($Web.ServerRelativeUrl -eq "/")
                        {
                            $AbsoluteURL=  $("{0}{1}" -f $Web.Url, $ListItem.FieldValues["FileRef"])
                        }
                        else
                        {
                            $AbsoluteURL=  $("{0}{1}" -f $Web.Url.Replace($Web.ServerRelativeUrl,''), $Item.FieldValues["FileRef"])
                        }
                        $AbsoluteURL = [uri]::EscapeUriString($AbsoluteURL)
  
                        If($AbsoluteURL.length -gt $MaxUrlLength)
                        {
                            Write-host "`t`tFound a Long File URL at '$AbsoluteURL'" -f Green
                            #Collect document data
                            $DocumentData = New-Object PSObject
                            $DocumentData | Add-Member NoteProperty SiteURL($SiteURL)
                            $DocumentData | Add-Member NoteProperty DocLibraryName($List.Title)
                            $DocumentData | Add-Member NoteProperty FileName($File.Name)
                            $DocumentData | Add-Member NoteProperty FileURL($AbsoluteURL)
                            $DocumentData | Add-Member NoteProperty CreatedBy($Item["Author"].Email)
                            $DocumentData | Add-Member NoteProperty CreatedOn($File.TimeCreated)
                            $DocumentData | Add-Member NoteProperty ModifiedBy($Item["Editor"].Email)
                            $DocumentData | Add-Member NoteProperty LastModifiedOn($File.TimeLastModified)
                            $DocumentData | Add-Member NoteProperty Size-KB([math]::Round($File.Length/1KB))
  
                            #Add the result to an Array
                            $DocumentInventory += $DocumentData
                        }
                        $Counter++
                    }
                }
            }While($Query.ListItemCollectionPosition -ne $Null)
                 
            #Export the result to CSV file
            $DocumentInventory | Export-CSV $ReportOutput -NoTypeInformation -Append
        }
        #Iterate through all subsites of the current site
        ForEach ($Subweb in $Web.Webs)
        {
            #Call the function recursively
            Scan-SPOLongFilePath($Subweb.url)
        }
    }
    Catch {
        write-host -f Red "Error Scanning Document Library Inventory!" $_.Exception.Message
    }
}
 
#Set Parameters
$SiteURL= "https://hpinvestor.sharepoint.com/sites/HPInvestors"
$ReportOutput="C:\temp\LongFileNames.csv"
$FileExtension = "xlsx"
$MaxUrlLength = 259
  
#Get Credentials to connect
$Cred = Get-Credential
  
#Delete the Output Report if exists
If (Test-Path $ReportOutput) { Remove-Item $ReportOutput }
  
#Call the function 
Scan-SPOLongFilePath $SiteURL