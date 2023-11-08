$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host -Object 'Inciando Download...' -ForegroundColor 'Cyan'

if (-not (Get-Command -Name 'spicetify' -ErrorAction 'SilentlyContinue')) {
  Write-Host -Object 'Arquivo Nao Localizado.' -ForegroundColor 'Red'
  Write-Host -Object 'Instalando Para Você' -ForegroundColor 'Green'
  $Parameters = @{
    Uri             = 'https://raw.githubusercontent.com/UniverseHubScripts/SpotifyClient/main/install.ps1'
    UseBasicParsing = $true
  }
  Invoke-WebRequest @Parameters | Invoke-Expression
}

spicetify path userdata | Out-Null
$spiceUserDataPath = (spicetify path userdata)
if (-not (Test-Path -Path $spiceUserDataPath -PathType 'Container' -ErrorAction 'SilentlyContinue')) {
  $spiceUserDataPath = "$env:APPDATA\spicetify"
}
$marketAppPath = "$spiceUserDataPath\CustomApps\marketplace"
$marketThemePath = "$spiceUserDataPath\Themes\marketplace"
$isThemeInstalled = $(
  spicetify path -s | Out-Null
  -not $LASTEXITCODE
)
$currentTheme = (spicetify config current_theme)
$setTheme = $true

Write-Host -Object 'Removendo Arquivos e Criando Pastas Para o Marketplace...' -ForegroundColor 'Cyan'
Remove-Item -Path $marketAppPath, $marketThemePath -Recurse -Force -ErrorAction 'SilentlyContinue' | Out-Null
New-Item -Path $marketAppPath, $marketThemePath -ItemType 'Directory' -Force | Out-Null

Write-Host -Object 'Baixando Marketplace...' -ForegroundColor 'Cyan'
$marketArchivePath = "$marketAppPath\marketplace.zip"
$unpackedFolderPath = "$marketAppPath\spicetify-marketplace-dist"
$Parameters = @{
  Uri             = 'https://github.com/spicetify/spicetify-marketplace/releases/latest/download/spicetify-marketplace.zip'
  UseBasicParsing = $true
  OutFile         = $marketArchivePath
}
Invoke-WebRequest @Parameters

Write-Host -Object 'Extraindo e Instalando...' -ForegroundColor 'Cyan'
Expand-Archive -Path $marketArchivePath -DestinationPath $marketAppPath -Force
Move-Item -Path "$unpackedFolderPath\*" -Destination $marketAppPath -Force
Remove-Item -Path $marketArchivePath, $unpackedFolderPath -Force
spicetify config custom_apps spicetify-marketplace- -q
spicetify config custom_apps marketplace
spicetify config inject_css 1 replace_colors 1

Write-Host -Object 'Baixando Espaco para Temas...' -ForegroundColor 'Cyan'
$Parameters = @{
  Uri             = 'https://raw.githubusercontent.com/spicetify/spicetify-marketplace/main/resources/color.ini'
  UseBasicParsing = $true
  OutFile         = "$marketThemePath\color.ini"
}
Invoke-WebRequest @Parameters

Write-Host -Object 'Aplicando...' -ForegroundColor 'Cyan'
if ($isThemeInstalled -and ($currentTheme -ne 'marketplace')) {
  $Host.UI.RawUI.Flushinputbuffer()
  $choice = $Host.UI.PromptForChoice(
    'Tema local encontrado',
    'Você deseja substituí-lo por um espaço reservado para instalar temas do Marketplace?',
    ('&Sim', '&Nao'),
    0
  )
  if ($choice = 1) { $setTheme = $false }
}
if ($setTheme) { spicetify config current_theme marketplace }
spicetify backup
spicetify apply

Write-Host -Object 'Tudo Pronto!' -ForegroundColor 'Green'
Write-Host -Object 'Se Nada Ocorreu, verifique as mensagens a cima' -ForegroundColor 'Red'
Write-Host -Object 'Se Voce Nao Encontrou Erros A Cima, Vai Se Fuder.' -ForegroundColor 'Red'
Write-Host -Object 'Leo Gay' -ForegroundColor 'DarkMagenta'

