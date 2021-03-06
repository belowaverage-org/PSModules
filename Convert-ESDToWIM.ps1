function Global:Convert-ESDToWIM {
    <#
        .SYNOPSIS
            Converts ESD files to WIM files (Also lets you change WIM editions).
        .LINK
            https://cp-wiki/Convert-ESDToWIM
    #>
    $esdFile = Read-Host -Prompt "Enter the ESD path"
    Get-WindowsImage -ImagePath $esdFile
    $index = Read-Host -Prompt "Enter index"
    Export-WindowsImage -SourceImagePath $esdFile -SourceIndex $index -CheckIntegrity -CompressionType "maximum" -DestinationImagePath "install.wim"
    $shouldContinue = Read-Host -Prompt "Mount WIM / Change Edition? (Y/N)"
    if(-not ($shouldContinue -like "y")) {
        return
    }
    New-Item -ItemType Directory -Path ".\TEMP\"
    Mount-WindowsImage -Path ".\TEMP\" -ImagePath "install.wim" -Index 1 -Optimize -CheckIntegrity
    Get-WindowsEdition -Path ".\TEMP\" -Target
    $edition = Read-Host -Prompt "Enter the edition you would like to switch too"
    Set-WindowsEdition -Path ".\TEMP\" -Edition $edition
    Get-WindowsEdition -Path ".\TEMP\"
    Dismount-WindowsImage -Path ".\TEMP\" -Save
    Remove-Item -Path ".\TEMP\"
}
