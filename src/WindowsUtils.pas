unit WindowsUtils;

{$I dunit.inc}

interface


function ApplicationName: string;
function GetEXEPath: string;
function GetAppConfigDir(Global: Boolean = False): string;


implementation

uses
  Windows
  ,SysUtils
  ;

const
  CSIDL_LOCAL_APPDATA   = $001C; { %USERPROFILE%\Local Settings\Application Data (non roaming)}
  CSIDL_COMMON_APPDATA  = $0023; { \All Users\Application Data }
  CSIDL_FLAG_CREATE     = $8000; { (force creation of requested folder if it doesn't exist yet)}
  CSIDL_PERSONAL        = $0005;

type
  PFNSHGetFolderPath = function(Ahwnd: HWND; Csidl: Integer; Token: THandle; Flags: DWord; Path: PChar): HRESULT; stdcall;

var
  SHGetFolderPath: PFNSHGetFolderPath = nil;
  CFGDLLHandle: THandle = 0;

procedure _InitDLL;
var
  LProcAddress: Pointer;
begin
  LProcAddress:= nil;
  CFGDLLHandle := LoadLibrary('shell32.dll');
  if (CFGDLLHandle<>0) then
  begin
    LProcAddress := GetProcAddress(CFGDLLHandle,'SHGetFolderPathA');
    if (LProcAddress = nil) then
    begin
      FreeLibrary(CFGDLLHandle);
      CFGDllHandle := 0;
    end
    else
      SHGetFolderPath := PFNSHGetFolderPath(LProcAddress);
  end;

  if (LProcAddress = nil) then
  begin
    CFGDLLHandle := LoadLibrary('shfolder.dll');
    if (CFGDLLHandle <> 0) then
    begin
      LProcAddress := GetProcAddress(CFGDLLHandle,'SHGetFolderPathA');
      if (LProcAddress=Nil) then
      begin
        FreeLibrary(CFGDLLHandle);
        CFGDllHandle := 0;
      end
      else
        ShGetFolderPath := PFNSHGetFolderPath(LProcAddress);
    end;
  end;

  if (@ShGetFolderPath = nil) then
    raise Exception.Create('Could not determine SHGetFolderPath function');
end;

function _GetSpecialDir(ID: Integer): string;
var
  APath: Array[0..MAX_PATH] of ansichar;
  APtr: PAnsiChar;
begin
  Result := '';
  if (CFGDLLHandle = 0) then
    _InitDLL;
  if Assigned(SHGetFolderPath) then
  begin
    if SHGetFolderPath(0,ID or CSIDL_FLAG_CREATE,0,0,@APATH[0]) = S_OK then
    begin
      APtr    := PAnsiChar(@APath[0]);
      Result  := IncludeTrailingPathDelimiter(APtr);
    end;
  end;
end;

function ApplicationName: string;
begin
  Result := ChangeFileExt(ExtractFileName(Paramstr(0)),'');
end;

function GetEXEPath: string;
var
  path: array[0..MAX_PATH - 1] of char;
begin
  if IsLibrary then
    SetString(Result, path, GetModuleFileName(HInstance, path, SizeOf(path)))
  else
    Result := Paramstr(0);
  Result := ExtractFilePath(Result);
end;

function GetAppConfigDir(Global: Boolean): string;
begin
  if Global then
    Result := _GetSpecialDir(CSIDL_COMMON_APPDATA) + ApplicationName
  else
    Result := _GetSpecialDir(CSIDL_LOCAL_APPDATA) + ApplicationName;

  if (Result = '') then
    Result := GetEXEPath;
end;


end.