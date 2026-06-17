[Setup]
AppName=Sortia
AppVersion=1.0.0
AppPublisher=Sortia Inc.
DefaultDirName={autopf}\Sortia
DefaultGroupName=Sortia
OutputDir=.\build\windows\x64\installer
OutputBaseFilename=Sortia_Setup
Compression=lzma2
SolidCompression=yes
SetupIconFile=.\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\sortia.exe

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: ".\build\windows\x64\runner\Release\sortia.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: ".\build\windows\x64\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: ".\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: ".\build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Sortia"; Filename: "{app}\sortia.exe"
Name: "{group}\{cm:UninstallProgram,Sortia}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\Sortia"; Filename: "{app}\sortia.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\sortia.exe"; Description: "{cm:LaunchProgram,Sortia}"; Flags: nowait postinstall skipifsilent
