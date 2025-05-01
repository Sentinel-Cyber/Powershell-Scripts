### Ramon DeWitt \ Cody Horn 2/15/2023
### This is an example on how to convert an AVD client etl file to a csv or xml
### To put out to XML, just use " -of xml " instead of " -of csv "
### etl file location "%temp%\DiagOutputDir\RdClientAutoTrace"

## Change the folder to whatever you're using. Whether the default etl file location or a custom one.
$Files = Get-ChildItem -Path C:\Users\DeWitt\AppData\Local\Temp\DiagOutputDir\RdClientAutoTrace
$outputFolder = "C:\Temp\AlmaLogs"
foreach ($file in $Files)
{
  # Get filename with no extension
    $fileName = $File.BaseName

  # Convert the .etl file to .csv file using tracerpt command
    tracerpt $file.FullName -o "$outputFolder\$fileName.csv" -of CSV

  # Remove the .etl file
    Remove-Item $File.FullName
}