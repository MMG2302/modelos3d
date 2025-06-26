@echo off
setlocal enabledelayedexpansion

REM === Verifica que haya un archivo ===
if "%~1"=="" (
    echo Arrastra un archivo .glb sobre este .bat para subirlo
    pause
    exit /b
)

REM === Variables ===
set "inputFile=%~1"
for %%F in ("%inputFile%") do (
    set "fileName=%%~nF"
    set "extension=%%~xF"
)

REM === Validación del archivo .glb ===
if /I not "!extension!"==".glb" (
    echo El archivo no es .glb. Intenta de nuevo.
    pause
    exit /b
)

REM === Ruta del modelo ===
set "destDir=modelos\!fileName!"
mkdir "!destDir!" 2>nul

REM === Copia el archivo .glb ===
copy /Y "!inputFile!" "!destDir!\"

REM === Genera index.html del modelo ===
echo ^<html^>^<head^>^<meta charset="UTF-8" /^>^<title^>Modelo: !fileName!^</title^>^</head^> > "!destDir!\index.html"
echo ^<body style="margin:0; background:#111;"^> >> "!destDir!\index.html"
echo ^<script type="module" src="https://unpkg.com/@google/model-viewer/dist/model-viewer.min.js"^>^</script^> >> "!destDir!\index.html"
echo ^<model-viewer src="!fileName!.glb" auto-rotate camera-controls ar style="width:100vw; height:100vh;"^>^</model-viewer^> >> "!destDir!\index.html"
echo ^<noscript^>Tu navegador no soporta model-viewer.^</noscript^> >> "!destDir!\index.html"
echo ^<script^>if (!window.customElements)^document.write('Tu navegador no soporta model-viewer.')^</script^> >> "!destDir!\index.html"
echo ^</body^>^</html^> >> "!destDir!\index.html"

REM === Genera el link público (GitHub Pages) ===
set "url=https://mmg2302.github.io/modelos3d/modelos/!fileName!/index.html"
echo !url! > "!destDir!\enlace.txt"

REM === Subida a GitHub ===
cd modelos
git add .
git commit -m "Subiendo modelo !fileName!"
git push origin main
cd..

REM === Resultado final ===
echo.
echo ============================================
echo ¡Modelo subido exitosamente!
echo Link: !url!
echo También guardado en: !destDir!\enlace.txt
echo ============================================
echo.
pause
