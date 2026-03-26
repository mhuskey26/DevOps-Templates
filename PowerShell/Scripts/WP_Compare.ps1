$sharePath = 'C:\Code\WP_Vanilla\WordPress-default'

# WPVanilla is the Worpress Base Code you use as a code base comparison
$WPVanillas = Get-ChildItem -Recurse $sharePath

#Read WordPress folders to make a CSV of the folders and file names that can be Excluded
$WPFiles = ForEach ($WPVanilla in $WPVanillas)
    {
    $wpvanilla | Select-Object FullName, CreationTimeUtc, LastWriteTimeUtc
    }
#Exporting CSV with file and folder names
$WPFiles | Export-Csv -Path C:\Code\WPVanilla.csv

# WPcu is the Full Customized code you use as the code to be compared with WPExclusions list
$WPcus = Get-ChildItem -Recurse C:\Code\secu-credit-union

#Read the folders of Custom code and find all files that are NOT listed in the CSV of what to Exclude
ForEach ($WPcu in $WPcus)
    {
    $CustomFileName = $WPcu | Select-Object FullName, CreationTimeUtc, LastWriteTimeUtc
    
    ForEach ($WPFile in $WPFiles)
    {
    if $CustomFileName = $WPFile 
    }

    }


Import-Csv C:\Code\exclusions.csv | ForEach {
   
}

#If the file in the Custom code is not on the XML list of Excludes, we copy that whole file object to a Target folder
ForEach ($WPcu in $WPcus)
    {
    #$TargetFolder
    }


# Archive/Zip the Code in the Target folder and prep it to be Veracode scanned

Compress-Archive -$TargetFolder c:\code\CodeDiff.zip




#### 