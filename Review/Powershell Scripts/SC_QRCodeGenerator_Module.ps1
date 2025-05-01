# Needs QRCodeGenerator module
Import-Module QRCodeGenerator

function New-Base32Secret {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int32]$SecretLength = 16
    )
    $Rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::Create()
    [Byte[]]$ByteArray = 1
    $Secret = ''
    while ($Secret.Length -lt $SecretLength) {
        $Rng.GetBytes($ByteArray)
        if ([char]$ByteArray[0] -clike '[2-7A-Z]') {
            $Secret += [char]$ByteArray[0] # What, am I going to use StringBuilder??
        }
    }
    $Secret
}

# Generate a 10-bit base32 secret
$Secret = New-Base32Secret

# Generate a guid for the qr code file
$Guid = ([guid]::NewGuid()).Guid

# Get the display name
$DisplayName = 'My Cool ScreenConnect Instance'

# Format the string for the QR code
$OtpString = 'otpauth://totp/{0}?secret={1}' -f $DisplayName, $Secret

# Generate the QR code
New-PSOneQRCodeText -Text $OtpString -OutPath "/tmp/$Guid.png"