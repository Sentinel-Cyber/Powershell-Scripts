$key = "584cdd87a51606a86d05"
$Sec = "f65a225c4f83fc490346cf1109580150f4a7c4f729ef758eccb2a528e767110d" 
$Text = $key + ":" + $Sec
$Bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
$EncodedText =[Convert]::ToBase64String($Bytes)
$EncodedText