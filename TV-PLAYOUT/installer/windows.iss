[Setup]
AppId={{9C5B87A0-75E0-4D70-8D91-02D6C2C9B702}
AppName=TV PLAYOUT
AppVersion=0.2.0
AppPublisher=TV PLAYOUT
DefaultDirName={autopf}\TV PLAYOUT
DefaultGroupName=TV PLAYOUT
OutputDir=output
OutputBaseFilename=TV-PLAYOUT-0.2-Windows-Setup
ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\tv-playout.exe

[Files]
Source: "..\dist\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{group}\TV PLAYOUT"; Filename: "{app}\tv-playout.exe"
Name: "{autodesktop}\TV PLAYOUT"; Filename: "{app}\tv-playout.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Criar atalho na Área de Trabalho"; GroupDescription: "Atalhos:"
