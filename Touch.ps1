<# License>------------------------------------------------------------

 Copyright (c) 2018 Shinnosuke Yakenohara

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>

-----------------------------------------------------------</License #>

#変数宣言
$opRec = "/r" #Recursive処理指定文字列
$isRec = $FALSE #Recursiveに処理するかどうか
$opPau = "/p" #エラーがあった場合にpauseする事を指定する文字列
$pauseWhenErr = $FALSE  #エラーがあった場合にpauseするかどうか

$total = 0
$scsOfTotal = 0
$errOfTotal = 0
$file = 0
$scsOfFile = 0
$errOfFile = 0
$dir = 0
$scsOfDir = 0
$errOfDir = 0
$newFile = 0
$scsOfnewFile = 0
$errOfnewFile = 0

#Recursiveに処理するかどうかをチェック
$isRec = $FALSE
$mxOfArgs = $Args.count
for ($idx = 0 ; $idx -lt $mxOfArgs ; $idx++){
    
    if($Args[$idx] -eq $opRec){ #Recursive処理指定文字列の場合
        $isRec = $TRUE
        $Args[$idx] = $null #処理対象から除外
        
    } elseif ($Args[$idx] -eq $opPau){ #エラーがあった場合にpauseする事を指定する文字列の場合
        $pauseWhenErr = $TRUE
        $Args[$idx] = $null #処理対象から除外
    }
}

#処理対象リスト作成
$list = New-Object System.Collections.Generic.List[System.String]

foreach ($arg in $args){
    
    if($arg -ne $null){ #処理対象から除外していなければ
        
        $list.Add($arg)
        
        if ((Test-Path $arg -PathType Container) -And ($isRec)){ #ディレクトリでかつRecursive処理指定の場合
            Get-ChildItem  -Recurse -Force -Path $arg | ForEach-Object {
                $list.Add($_.FullName)
            }
        }
    }
}

#パラメータ数チェック
if($list.count -eq 0){ #処理対象が指定されていない
    Write-Host "Argument not specified"
    $errOfTotal = 1
    
}else{ #処理対象が1つ以上ある

    #タイムスタンプ更新ループ
    foreach ($path in $list) {
        
        Write-Host $path
        
        if (Test-Path $path -PathType container){ #ディレクトリの場合
                
            try {
                Set-ItemProperty -Path $path `
                                -Name LastWriteTime `
                                -Value $(Get-Date)
                $scsOfDir++
                
            } catch {
                Write-Error $Error[0]
                $errOfDir++
            }
            $dir++
        
        } elseif (Test-Path $path -PathType leaf) { #ファイルの場合
            
            try {
                Set-ItemProperty -Path $path `
                                -Name LastWriteTime `
                                -Value $(Get-Date)
                $scsOfFile++
                
            } catch {
                Write-Error $Error[0]
                $errOfFile++
            }
            $file++
        
        } else { #存在しないパスの場合

            try{
                
                New-Item -Itemtype file $path -ErrorAction stop | Out-Null
                # `New-Item`実行時にアクセスエラーが発生した場合は、catch出来ないので、 ` -ErrorAction stop` する
                # アクセスエラーが発生しない場合に表示されるls結果は不要な為、` | Out-Null` する
                
                $scsOfnewFile++

            } catch { #アクセスエラーが発生した場合
                Write-Error $Error[0]
                $errOfnewFile++
            }
            $newFile++
        }
    }

    #結果集計
    $total = $file + $dir + $newFile
    $scsOfTotal = $scsOfFile + $scsOfDir +$scsOfnewFile
    $errOfTotal = $errOfFile + $errOfDir +$errOfnewFile

    #結果表示
    Write-Host ""
    Write-Host "Number of failed to directories:"
    Write-Host $errOfDir

    Write-Host "Number of failed to update files:"
    Write-Host $errOfFile

    Write-Host "Number of failed to create files:"
    Write-Host $errOfnewFile

    Write-Host "Number of created files:"
    Write-Host $scsOfnewFile
}

#失敗処理がある場合はpauseする
if (($errOfTotal -gt 0) -And ($pauseWhenErr)){
    Write-Host ""
    Read-Host "Press Enter key to continue..."
    
}
