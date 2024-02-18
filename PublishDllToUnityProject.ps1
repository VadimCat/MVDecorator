# Путь к проекту
$projectPath = Join-Path (Get-Location) "Dependencies"

# Папка для публикации
$outputPath = Join-Path $projectPath "bin\Release\netstandard2.1\publish"

# Папка с DLL файлами
$destinationPath = Join-Path (Get-Location) "Assets\TemplateCore\Ji2Core\Dependencies"

# Создаем папку publish
New-Item -ItemType Directory -Force -Path $outputPath

# Публикация проекта .NET Standard 2.1
Write-Host "Publishing project..."
dotnet publish -c Release -f netstandard2.1 -o $outputPath $projectPath

# Проверка, была ли успешно выполнена команда публикации
if ($LastExitCode -ne 0) {
    Write-Host "Error: Failed to publish the project."
    pause
    exit
}

# Получаем список сгенерированных DLL
$generatedDLLs = Get-ChildItem -Path $outputPath -Filter *.dll | Select-Object -ExpandProperty FullName

# Получаем путь к файлу Assembly-CSharp-Editor.csproj
$editorCsprojPath = Join-Path (Get-Location) "Assembly-CSharp-Editor.csproj"

# Паттерн для извлечения названий DLL
$pattern = '<HintPath>.*\\(.*\.dll)</HintPath>'
$matches = [regex]::Matches((Get-Content -Raw -Path $editorCsprojPath), $pattern)

# Список названий DLL
$editorDLLs = $matches | ForEach-Object { $_.Groups[1].Value }

# Копирование DLL файлов, исключая указанные
Write-Host "Copying DLL files..."
$notCopiedDLLs = @()

foreach ($dllPath in (Get-ChildItem -Path "$outputPath\*.dll" -File)) {
    if ($editorDLLs -notcontains $dllPath.Name) {
        Copy-Item -Path $dllPath.FullName -Destination $destinationPath -Force
    } else {
        $notCopiedDLLs += $dllPath
    }
}

# Удаление дубликатов DLL файлов
Write-Host "Removing duplicate DLL files..."
Get-ChildItem -Path $destinationPath -Include *.dll -File -Recurse | Group-Object -Property Name | Where-Object { $_.Count -gt 1 } | ForEach-Object {
    $group = $_.Group | Sort-Object LastWriteTime -Descending
    $group | Select-Object -Skip 1 | ForEach-Object { Remove-Item $_.FullName -Force }
}

# Вывод списка файлов, которые не были скопированы
if ($notCopiedDLLs.Count -gt 0) {
    Write-Host "Files not copied due to exclusion:"
    $notCopiedDLLs | ForEach-Object { Write-Host $_.FullName }
}

Write-Host "Task completed successfully."

# Пауза перед закрытием окна консоли
pause
