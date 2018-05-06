#タイムスタンプ更新

$Args | ForEach-Object {
	
	echo $_
	$path = $_
	
	Set-ItemProperty -Path $path `
	                 -Name LastWriteTime `
	                 -Value $(Get-Date)
	                 
	if ((Test-Path $path -PathType container)){ #ディレクトリの場合
	    
	    Get-ChildItem  -Recurse -Path $path | ForEach-Object {
	        echo $_.FullName
	        Set-ItemProperty -Path $_.FullName `
	                         -Name LastWriteTime `
	                         -Value $(Get-Date)
	    }
	}
}
