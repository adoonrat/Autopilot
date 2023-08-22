function Invoke-Command() {
    param ( [string]$program = $(throw "Please specify a program" ),
            [string]$argumentString = "",
            [switch]$waitForExit )

 

    $psi = new-object "Diagnostics.ProcessStartInfo"
    $psi.FileName = $program 
    $psi.Arguments = $argumentString
    $proc = [Diagnostics.Process]::Start($psi)
    if ( $waitForExit ) {
        $proc.WaitForExit();
    }
}

 
#Example
#Invoke-Command -program lpksetup -argumentString "/i * /p C:\Temp\LP\Microsoft-Windows-Client-Language-Pack_x64_ja-jp.cab" -waitForExit $True
