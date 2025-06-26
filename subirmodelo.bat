@echo off
setlocal enabledelayedexpansion

REM === Verifica archivo ===
if "%~1"=="" (
    echo Arrastra un archivo .glb sobre este .bat
    pause
    exit /b
)

REM === Rutas base ===
set "baseDir=%~dp0"
set "modelosDir=%baseDir%modelos"

REM === Genera nombre aleatorio de carpeta ===
for /f %%A in ('powershell -Command "[guid]::NewGuid().ToString('N').Substring(0,10)"') do set "carpeta=%%A"
set "destDir=%modelosDir%\!carpeta!"

REM === Datos del archivo ===
set "inputFile=%~1"
for %%F in ("%inputFile%") do (
    set "fileName=%%~nF"
    set "ext=%%~xF"
)

if /I not "!ext!"==".glb" (
    echo El archivo debe ser .glb
    pause
    exit /b
)

REM === Crear carpeta destino ===
mkdir "!destDir!" >nul

REM === Copiar y comprimir con gzip ===
copy "!inputFile!" "!destDir!\!fileName!.glb" >nul
pushd "!destDir!"
gzip -k "!fileName!.glb" >nul
del "!fileName!.glb"
popd

REM === Generar HTML ===
(
echo ^<html^>
echo ^<head^>
echo   ^<meta charset="UTF-8" /^>
echo   ^<meta name="viewport" content="width=device-width, initial-scale=1.0" /^>
echo   ^<script type="module" src="https://unpkg.com/@google/model-viewer/dist/model-viewer.min.js"^>^</script^>
echo   ^<title^>Modelo !fileName!^</title^>
echo ^</head^>
echo ^<body style="margin:0; background:#111;"^>
echo   ^<model-viewer src="!fileName!.glb.gz" camera-controls auto-rotate ar style="width:100vw; height:100vh;"^>^</model-viewer^>
echo   ^<noscript^>Tu navegador no soporta model-viewer.^</noscript^>
echo ^</body^>
echo ^</html^>
) > "!destDir!\index.html"

REM === Generar enlace Pages ===
set "url=https://mmg2302.github.io/modelos3d/modelos/!carpeta!/index.html"
echo !url! > "!destDir!\enlace.txt"

REM === Subida a GitHub ===
cd /d "%baseDir%"
git add .
git commit -m "Subiendo modelo !fileName! en carpeta !carpeta!"
git push origin main

REM === Final ===
echo.
echo ============================================
echo ¡Modelo subido exitosamente!
echo Link: !url!
echo Guardado también en: !destDir!\enlace.txt
echo ============================================
echo.
pause
