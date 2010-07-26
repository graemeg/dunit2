; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define PluginName "DUnitTestInspector"
#define VersionNumber "0.3"
#define MyAppPublisher "DUnit project group"

#define PluginIDEDescription "DUnit Test Inspector"

#define ProductKey "Software\DunitTestInspector"

#define D2010ProductKey "Software\DUnitTestInspector\Delphi2010"
#define D2010KnownPackageKey "Software\CodeGear\BDS\7.0\Known Packages"
#define D2010DisabledPackageKey "Software\CodeGear\BDS\7.0\Disabled Packages"
#define D2010WatchFolder "{userappdata}\DUnitTestInspector\Delphi2010"
#define D2010WatchPath "{userappdata}\DUnitTestInspector\Delphi2010\watchFile"
#define D2010KnownPackageFolder "{commondocs}\RAD Studio\7.0\Bpl"
#define D2010SourceBinariesFolder "{src}\..\D2010\_bin"

#define D2009ProductKey "Software\DUnitTestInspector\Delphi2009"
#define D2009KnownPackageKey "Software\CodeGear\BDS\6.0\Known Packages"
#define D2009DisabledPackageKey "Software\CodeGear\BDS\6.0\Disabled Packages"
#define D2009WatchFolder "{userappdata}\DUnitTestInspector\Delphi2009"
#define D2009WatchPath "{userappdata}\DUnitTestInspector\Delphi2009\watchFile"
#define D2009KnownPackageFolder "{commondocs}\RAD Studio\6.0\Bpl"
#define D2009SourceBinariesFolder "{src}\..\D2009\_bin"

[Setup]
AppName={#PluginName}
AppVerName={#PluginName} {#VersionNumber}
AppPublisher={#MyAppPublisher}
DefaultDirName={pf}\{#PluginName}
DefaultGroupName={#PluginName}
OutputDir=.
OutputBaseFilename={#PluginName}.Setup
Compression=lzma
SolidCompression=yes

[Languages]
Name: english; MessagesFile: compiler:Default.isl

[Dirs]
; Delphi 2010
Name: {#D2010WatchFolder}; Languages: ; Flags: uninsalwaysuninstall; Components: Delphi2010
; Delphi 2009
Name: {#D2009WatchFolder}; Languages: ; Flags: uninsalwaysuninstall; Components: Delphi2009

[Files]
; Delphi 2010
Source: {#D2010SourceBinariesFolder}\DUnitTestInspector.bpl; DestDir: {#D2010KnownPackageFolder}; Flags: ignoreversion external; Components: Delphi2010
Source: {#D2010SourceBinariesFolder}\OTAUtils.bpl; DestDir: {#D2010KnownPackageFolder}; Flags: ignoreversion external; Components: Delphi2010
; Delphi 2009
Source: {#D2009SourceBinariesFolder}\DUnitTestInspector.bpl; DestDir: {#D2009KnownPackageFolder}; Flags: ignoreversion external; Components: Delphi2009
Source: {#D2009SourceBinariesFolder}\OTAUtils.bpl; DestDir: {#D2009KnownPackageFolder}; Flags: ignoreversion external; Components: Delphi2009
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Registry]
Root: HKCU; Subkey: {#ProductKey}; ValueType: none; Flags: uninsdeletekeyifempty

; Delphi 2010
Root: HKCU; Subkey: {#D2010ProductKey}; ValueType: string; ValueName: WatchFile; ValueData: {#D2010WatchPath}; Flags: uninsdeletekey; Languages: ; Components: Delphi2010
Root: HKCU; Subkey: {#D2010KnownPackageKey}; ValueType: string; ValueName: {#D2010KnownPackageFolder}\DUnitTestInspector.bpl; ValueData: {#PluginIDEDescription}; Languages: ; Flags: uninsdeletevalue dontcreatekey; Components: Delphi2010
Root: HKCU; Subkey: {#D2010DisabledPackageKey}; ValueType: none; ValueName: {#D2010KnownPackageFolder}\DUnitTestInspector.bpl; Flags: uninsdeletevalue deletevalue; Components: Delphi2010
; Delphi 2009
Root: HKCU; Subkey: {#D2009ProductKey}; ValueType: string; ValueName: WatchFile; ValueData: {#D2009WatchPath}; Flags: uninsdeletekey; Languages: ; Components: Delphi2009
Root: HKCU; Subkey: {#D2009KnownPackageKey}; ValueType: string; ValueName: {#D2009KnownPackageFolder}\DUnitTestInspector.bpl; ValueData: {#PluginIDEDescription}; Languages: ; Flags: uninsdeletevalue dontcreatekey; Components: Delphi2009
Root: HKCU; Subkey: {#D2009DisabledPackageKey}; ValueType: none; ValueName: {#D2009KnownPackageFolder}\DUnitTestInspector.bpl; Flags: uninsdeletevalue deletevalue; Components: Delphi2009

[Icons]
Name: {group}\{cm:UninstallProgram,{#PluginName}}; Filename: {uninstallexe}

[Components]
Name: Delphi2010; Description: Install wizard in Delphi 2010 IDE; Flags: checkablealone; Types: custom compact full
Name: Delphi2009; Description: Install wizard in Delphi 2009 IDE; Flags: checkablealone; Types: custom compact full
