@echo off
setlocal enabledelayedexpansion

REM === Obtiene ruta y nombre del archivo arrastrado ===
set "inputFile=%~1"
for %%F in ("%inputFile%") do (
    set "fileName=%%~nF"
    set "extension=%%~xF"
)

REM === Validación rápida por si no es .glb ===
if /I not "!extension!"==".glb" (
    echo El archivo no es .glb. Intenta de nuevo.
    pause
    exit /b
)

REM === Crea carpeta destino ===
set "destDir=modelos\!fileName!"
mkdir "!destDir!" 2>nul

REM === Copia el archivo GLB ===
copy /Y "!inputFile!" "!destDir!\"

REM === Genera index.html automático ===
echo ^<html^>^<head^>^<meta charset="UTF-8" /^>^<title^>Modelo: !fileName!^</title^>^</head^> > "!destDir!\index.html"
echo ^<body style="margin:0; background:#111;"^> >> "!destDir!\index.html"
echo ^<script type="module" src="https://unpkg.com/@google/model-viewer/dist/model-viewer.min.js"^>^</script^> >> "!destDir!\index.html"
echo ^<model-viewer src="!fileName!.glb" auto-rotate camera-controls ar style="width:100vw; height:100vh;"^>^</model-viewer^> >> "!destDir!\index.html"
echo ^<noscript^>Tu navegador no soporta model-viewer.^</noscript^> >> "!destDir!\index.html"
echo ^<script^>if (!window.customElements)^document.write('Tu navegador no soporta model-viewer.')^</script^> >> "!destDir!\index.html"
echo ^</body^>^</html^> >> "!destDir!\index.html"

REM === Subida a GitHub ===
cd modelos
git add .
git commit -m "Nuevo modelo !fileName!"
git push origin main
cd..

REM === Muestra el link final ===
echo.
echo ============================================
echo Tu modelo está disponible en:
echo https://mmg2302.github.io/modelos/!fileName!/index.html
echo ============================================
echo.
pause
