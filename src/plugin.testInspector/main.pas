unit main;

interface

procedure Register;

implementation

uses
   ToolsAPI
  ,XP_OTAWizards  // TXP_OTAWizard
  ,ExtCtrls       // TTimer
  ,Classes        // TNotifyEvent
  ,IniFiles       // TIniFile
  ,SysUtils       // StrToIntDef
  ,WatchFile      // ReadWatchFile
  ,XP_OTAUtils    // GetCurrentProject, GetProjectAbsoluteSearchPaths, OpenFileInIDE...
  ,Forms          // Application
  ,Windows
  ;

const
  cPluginAuthor = 'Paul Spain';
  cPluginName = 'DUnitTestInspector';

type

  TDUnitTestInspector = class(TXP_OTAWizard)
  private
    FTimer: TTimer;
    FDestroyed: boolean;
    FIDENotifier: IOTAIDENotifier;
    function DoInitiateTimer(var ATimer: TTimer;
      const ATimerEvent: TNotifyEvent;
      const AFrequencyMSec: integer = cWatchFileInspectionFrequencyMSec): boolean;
    procedure TimerEvent(Sender: TObject);
    function BuildSearchPaths(const ASearchPaths: TStrings): boolean;

  protected
    function GetAuthor: string; override;
    function GetName: string; override;
    procedure Destroyed; override;

    procedure InitiateTimer;

  public
    constructor Create;
    destructor Destroy; override;
  end;

  TIDENotifier = class (TXP_OTANotifier, IOTAIDENotifier)
  private
    FDUnitTestInspector: TDUnitTestInspector;
    FNotifierIndex: integer;
  protected
    procedure FileNotification(NotifyCode: TOTAFileNotification;
      const FileName: string; var Cancel: Boolean);
    procedure BeforeCompile(const Project: IOTAProject; var Cancel: Boolean); overload;
    procedure AfterCompile(Succeeded: Boolean); overload;
    procedure Destroyed; override;
  public
    constructor Create(const ADUnitTestInspector: TDUnitTestInspector);
    destructor Destroy; override;
  end;

procedure Register;
begin
  ToolsAPI.RegisterPackageWizard(TDUnitTestInspector.Create);
end;

procedure SwitchToThisWindow(hwnd: HWND; fUnknown: BOOL); stdcall;
  external user32 name 'SwitchToThisWindow';

{ TDUnitTestInspector }

function TDUnitTestInspector.BuildSearchPaths(const ASearchPaths: TStrings): boolean;
var
  LActiveProject: IOTAProject;
  LSearchPaths: TStrings;
begin
  Result := false;
  LSearchPaths := TStringList.Create;

  try

    if XP_OTAUtils.GetCurrentProject(LActiveProject)
      and XP_OTAUtils.GetProjectAbsoluteSearchPaths(LActiveProject, LSearchPaths) then
    begin
      ASearchPaths.AddStrings(LSearchPaths);
      LSearchPaths.Clear;

      if XP_OTAUtils.GetIDEDelphiLibraryPath(LSearchPaths) then
      begin
        ASearchPaths.AddStrings(LSearchPaths);
        Result := true;
      end;

    end;

  finally
    LSearchPaths.Free;
  end;
end;

constructor TDUnitTestInspector.Create;
begin
  inherited Create;
  // register notifier to listen for IDE DesktopLoad event and initiate timer
  // at that point.
  FIDENotifier := TIDENotifier.Create(self);
end;

destructor TDUnitTestInspector.Destroy;
begin
  FTimer.Free;
  inherited;
end;

procedure TDUnitTestInspector.Destroyed;
begin
  inherited;
  // TODO: not being called by IDE
  FDestroyed := true;
end;

function TDUnitTestInspector.GetAuthor: string;
begin
  Result := cPluginAuthor;
end;

function TDUnitTestInspector.GetName: string;
begin
  Result := cPluginName;
end;

procedure TDUnitTestInspector.InitiateTimer;
begin
  DoInitiateTimer(FTimer, TimerEvent);
end;

function TDUnitTestInspector.DoInitiateTimer(var ATimer: TTimer;
  const ATimerEvent: TNotifyEvent; const AFrequencyMSec: integer): boolean;
begin
  Result := false;

  if not Assigned(ATimer) then
  begin
    ATimer := TTimer.Create(nil);
    ATimer.Enabled := false;
    ATimer.OnTimer := ATimerEvent;
    ATimer.Interval := AFrequencyMSec;
    ATimer.Enabled := true;
    Result := true;
  end;
end;

procedure TDUnitTestInspector.TimerEvent(Sender: TObject);
var
  LFilesToOpen: TStrings;
  LSearchPaths: TStrings;
  LFileName: string;
  LFilePath: string;
  LLineNumber: integer;
  i,j: integer;
const
  cAltTab = true;
begin
  LFilesToOpen := nil;
  LSearchPaths := nil;

  if FDestroyed then
    exit;

  try
    LFilesToOpen := TStringList.Create;

    if WatchFile.ReadWatchFile(LFilesToOpen) then
    begin
      LSearchPaths := TStringList.Create;
      BuildSearchPaths(LSearchPaths);

      for i := 0 to LFilesToOpen.Count - 1 do
      begin
        LFileName := LFilesToOpen.Names[i];
        LLineNumber := StrToIntDef(LFilesToOpen.ValueFromIndex[i], 1);

        for  j := 0 to LSearchPaths.Count - 1 do
        begin
          LFilePath := LSearchPaths[j] + LFileName;

          if FileExists(LFilePath) then
          begin
            XP_OTAUtils.OpenFileInIDE(LFilePath, LLineNumber);
            Break;
          end;

        end;

        // Application.BringToFront; // doesn't work for minimised app
        // Bring app to foreground (even if minimised)
        SwitchToThisWindow(Application.MainForm.Handle, cAltTab);
      end;

    end;

  finally
    LSearchPaths.Free;
    LFilesToOpen.Free;
  end;

end;

{ TIDENotifier }

procedure TIDENotifier.AfterCompile(Succeeded: Boolean);
begin
  // do nothing
end;

procedure TIDENotifier.BeforeCompile(const Project: IOTAProject;
  var Cancel: Boolean);
begin
  // do nothing
end;

constructor TIDENotifier.Create(const ADUnitTestInspector: TDUnitTestInspector);
var
  Services50: IOTAServices50;
begin
  inherited Create;
  FDUnitTestInspector := ADUnitTestInspector;
  FNotifierIndex := -1;
  if SysUtils.Supports(BorlandIDEServices, IOTAServices50, Services50) then
    FNotifierIndex := Services50.AddNotifier(self);
end;

destructor TIDENotifier.Destroy;
begin
  Destroyed;
  inherited;
end;


procedure TIDENotifier.Destroyed;
var
  Services50: IOTAServices50;
begin
  //  Clean up the notifier
  if (FNotifierIndex >= 0) and
    SysUtils.Supports(BorlandIDEServices, IOTAServices50, Services50) then
  begin
    Services50.RemoveNotifier(FNotifierIndex);
    FNotifierIndex := -1;
    FDUnitTestInspector := nil;
  end;
end;


procedure TIDENotifier.FileNotification(NotifyCode: TOTAFileNotification;
  const FileName: string; var Cancel: Boolean);
begin
  case NotifyCode of
    ofnDefaultDesktopLoad, ofnProjectDesktopLoad:
    begin
      if Assigned(FDUnitTestInspector) then
        FDUnitTestInspector.InitiateTimer;
    end;
  end;
end;

end.
