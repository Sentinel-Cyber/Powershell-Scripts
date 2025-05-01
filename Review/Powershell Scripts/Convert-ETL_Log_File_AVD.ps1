### Ramon DeWitt 2/15/2023
### This is an example on how to convert an AVD client etl file to a csv or xml
### To put out to XML, just use " -of xml " instead of " -of csv "
### etl file location "%temp%\DiagOutputDir\RdClientAutoTrace"
$filename = "<filename>"
$outputFolder = "C:\Temp"
cd $env:TEMP\DiagOutputDir\RdClientAutoTrace
tracerpt "$filename.etl" -o "$outputFolder\$filename.csv" -of csv