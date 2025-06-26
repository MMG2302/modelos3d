@echo off
setlocal enabledelayedexpansion

REM === Verifica archivo arrastrado ===
if "%~1"=="" (
    echo Arrastra un archivo .glb sobre este .bat para subirlo
    pause
    exit /b
)

REM === Ruta base del proyecto ===
set "baseDir=%~dp0"
set "modelosDir=%baseDir%modelos"

REM === Genera nombre de carpeta aleatoria ===
for /f %%A in ('powershell -Command "[guid]::NewGuid().ToString('N').Substring(0,10)"') do set "carpeta=%%A"
set "destDir=%modelosDir%\!carpeta!"

REM === Extrae nombre base del archivo ===
set "inputFile=%~1"
for %%F in ("%inputFile%") do set "fileName=%%~nF"

REM === Crea carpeta destino ===
mkdir "!destDir!" >nul

REM === Comprime el archivo .glb a .gz ===
copy "%inputFile%" "!destDir!\%fileName%.glb" >nul
powershell -Command "Compress-Archive -Path '!destDir!\%fileName%.glb' -DestinationPath '!destDir!\%fileName%.zip'"
powershell -Command "Expand-Archive -Path '!destDir!\%fileName%.zip' -DestinationPath '!destDir!'" >nul
powershell -Command "Remove-Item -Path '!destDir!\%fileName%.glb'" >nul
rename "!destDir!\%fileName%" "!fileName!.glb.gz"
del "!destDir!\%fileName%.zip"

REM === Genera el HTML para model-viewer ===
(
echo ^<html^>
echo ^<head^>
echo     ^<meta charset="UTF-8" /^>
echo     ^<meta name="viewport" content="width=device-width, initial-scale=1.0" /^>
echo     ^<title^>Modelo: !fileName!^</title^>
echo     ^<script type="module" src="https://unpkg.com/@google/model-viewer/dist/model-viewer.min.js"^>^</script^>
echo ^</head^>
echo ^<body style="margin:0; background:#111;"^>
echo     ^<model-viewer src="!fileName!.glb.gz" camera-controls auto-rotate ar ios-src="!fileName!.usdz" style="width:100vw; height:100vh;"^>^</model-viewer^>
echo     ^<noscript^>Tu navegador no soporta model-viewer.^</noscript^>
echo ^</body^>
echo ^</html^>
) > "!destDir!\index.html"

REM === Genera enlace de GitHub Pages ===
set "url=https://mmg2302.github.io/modelos3d/modelos/!carpeta!/index.html"
echo !url! > "!destDir!\enlace.txt"

REM === Subida a GitHub ===
cd /d "%baseDir%"
git add .
git commit -m "Subiendo modelo !fileName! en carpeta !carpeta!"
git push origin main

REM === Confirmación ===
echo.
echo ============================================
echo ¡Modelo subido exitosamente!
echo Link: !url!
echo También guardado en: !destDir!\enlace.txt
echo ============================================
echo.
pause
