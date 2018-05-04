#Argment check
if (($Args.Length -eq 0) -Or ($Args[0] -eq "")) {
    echo "Arg[0] is empty string"
    exit
}

if (!(Test-Path $Args[0])) {
    echo ("Not found `"" + $Args[0] + "`"")
    exit
}

#タイムスタンプ更新
echo $Args[0]
Set-ItemProperty -Path $Args[0] `
                 -Name LastWriteTime `
                 -Value $(Get-Date)
                 
if ((Test-Path $Args[0] -PathType container)){ #ディレクトリの場合
    
    Get-ChildItem  -Recurse -Path $Args[0] | ForEach-Object {
        echo $_.FullName
        Set-ItemProperty -Path $_.FullName `
                         -Name LastWriteTime `
                         -Value $(Get-Date)
    }

}

echo $Error[0]

#Write-Host "please press any key" -NoNewLine
#[Console]::ReadKey() | Out-Null
