# -----------------------------------------------------------------------------
# Script: GenerateRandomPassword.ps1
# Author: Robert Waight
# Date: 03/11/2016
# Keywords: 
# comments: Version 1 for password generation
#
# -----------------------------------------------------------------------------
# Generate Random Password

# Test Password Dictionaries
#$alphabet=65..90|foreach-object{[char]$_} #create the alphabet array
#$asciiFull=33..126|foreach-object{[char]$_} #create the asciiFull array
#$ascii=48..122|foreach-object{[char]$_} #create the ascii array

#$asciiTable=0..127 | % {"{0}  {1}" -f $_, [char]$_}

# Password Dictionaries
$alphabet=$NULL;For ($a=65;$a –le 90;$a++) {$alphabet+=,[char][byte]$a }
$asciiFull=$NULL;For ($a=33;$a –le 126;$a++) {$ascii+=,[char][byte]$a }
$ascii=$NULL;For ($a=48;$a -le 122;$a++) {$ascii+=,[char][byte]$a }

Function Get-TempPassword() {
    Param(
    [int]$length=16,
    #[int]$length,
    [string[]]$sourcedata
    )
        For ($loop=1; $loop -le $length; $loop++) {
            $TempPassword+=($sourcedata | GET-RANDOM)
            }        
    return $TempPassword
}

Function Get-PassLength(){
    do{
        $passLenInteg = read-host "Enter an integer"
        $a = ""
        $b = [int32]::TryParse( $passLenInteg , [ref]$a )
        if(  !$b)
          {
            Write-Host "Only integers please"
          }
      } until ($b)
    
  return $passLenInteg
}

Function PromptUser{
    CLS
    Write-Host "How many characters do you want your new password to be? " -NoNewLine
    $passLen=Get-PassLength
    $tPass=Get-TempPassword -length $passLen -sourcedata $ascii
    $tPass | CLIP
    Write-Host "`tYour new password is $tPass and is in your clipboard." -ForegroundColor Yellow
}

PromptUser
