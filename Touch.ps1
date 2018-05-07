#変数宣言
$total = 0
$scsOfTotal = 0
$errOfTotal = 0
$file = 0
$scsOfFile = 0
$errOfFile = 0
$dir = 0
$scsOfDir = 0
$errOfDir = 0

#タイムスタンプ更新ループ
$Args | ForEach-Object {
	
	$path = $_
	echo $path
	
	
	if ((Test-Path $path -PathType container)){ #ディレクトリの場合
		
		#ディレクトリのタイムスタンプ更新
		try{
			Set-ItemProperty -Path $path `
							 -Name LastWriteTime `
							 -Value $(Get-Date)
			$scsOfDir++
			
		} catch {
			Write-Error $error[0]
			$errOfDir++
		}
		$dir++
		
		#サブディレクトリのタイムスタンプ更新ループ
		Get-ChildItem  -Recurse -Path $path | ForEach-Object {
			
			$subPath = $_
			echo $subPath.FullName
			
			if ((Test-Path $subPath -PathType container)){ #ディレクトリの場合
			
				#サブディレクトリのタイムスタンプ更新
				try {
					Set-ItemProperty -Path $subPath.FullName `
									 -Name LastWriteTime `
									 -Value $(Get-Date)
					$scsOfDir++
					
				} catch {
					Write-Error $Error[0]
					$errOfDir++
				}
				$dir++
			
			} else { #ファイルの場合
				
				#ファイルのタイムスタンプ更新
				try {
					Set-ItemProperty -Path $subPath.FullName `
									 -Name LastWriteTime `
									 -Value $(Get-Date)
					$scsOfFile++
					
				} catch {
					Write-Error $Error[0]
					$errOfFile++
				}
				$file++
			}
		}
	
	}else{ #ファイルの場合
		
		#ファイルのタイムスタンプ更新
		try{
			Set-ItemProperty -Path $path `
							 -Name LastWriteTime `
							 -Value $(Get-Date)
			$scsOfFile++
			
		} catch {
			Write-Error $error[0]
			$errOfFile++
		}
		$file++
	}
}

#結果表示
$total = $file + $dir
$scsOfTotal = $scsOfFile + $scsOfDir
$errOfTotal = $errOfFile + $errOfDir

""
"ディレクトリの処理失敗数"
$errOfDir

"ファイルの処理失敗数"
$errOfFile

if ($errOfTotal -gt 0){
	exit 1
} else {
	exit 0
}
