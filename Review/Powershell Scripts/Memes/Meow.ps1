Add-Type -AssemblyName System.speech
$speechSynthesizer = New-Object System.Speech.Synthesis.SpeechSynthesizer
$speechSynthesizer.Speak("meow")