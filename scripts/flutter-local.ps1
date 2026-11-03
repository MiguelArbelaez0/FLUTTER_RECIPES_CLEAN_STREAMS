param(
    [Parameter(Mandatory = $true)]
    [string]$JdkPath,
    [Parameter(Mandatory = $true)]
    [string[]]$FlutterArguments
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$flutterRoot = Join-Path $repositoryRoot 'flutter_recipes_clean_streams'
$JdkPath = (Resolve-Path -LiteralPath $JdkPath).Path
if (-not (Test-Path -LiteralPath (Join-Path $JdkPath 'bin/java.exe'))) {
    throw 'JdkPath must contain bin/java.exe.'
}
$flutterCommand = (Get-Command flutter -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
$configDirectory = Join-Path $repositoryRoot '.tooling/flutter-config'
New-Item -ItemType Directory -Force -Path $configDirectory | Out-Null
[System.IO.File]::WriteAllText(
    (Join-Path $configDirectory '.flutter_settings'),
    (@{ 'jdk-dir' = $JdkPath } | ConvertTo-Json),
    [System.Text.UTF8Encoding]::new($false)
)

# Only this process and its children see these settings. Restore on failure too.
$previousAppData = $env:APPDATA
$previousJavaHome = $env:JAVA_HOME
$previousPath = $env:PATH
Push-Location -LiteralPath $flutterRoot
try {
    $env:APPDATA = $configDirectory
    $env:JAVA_HOME = $JdkPath
    $env:PATH = (Join-Path $JdkPath 'bin') + ';' + $previousPath
    & $flutterCommand @FlutterArguments
    $commandExitCode = $LASTEXITCODE
} finally {
    $env:APPDATA = $previousAppData
    $env:JAVA_HOME = $previousJavaHome
    $env:PATH = $previousPath
    Pop-Location
}
exit $commandExitCode
