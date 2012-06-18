{ #(@)$Id: GUIActionRecorder.pas,v 1.35 2010/05/04 09:55:00 jarrodh Exp $ }
{: DUnit: An XTreme testing framework for Delphi programs.
   @author  The DUnit Group.
   @version $Revision: 1.35 $
}
(*
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 *
 * The Original Code is DUnit.
 *
 * The Initial Developers of the Original Code are Serge Beaumont
 * and Juancarlo A�ez.
 * Portions created The Initial Developers are Copyright (C) 1999-2000.
 * Portions created by The DUnit Group are Copyright (C) 2000-2008.
 * All rights reserved.
 *
 * Contributor(s):
 * Serge Beaumont <beaumose@iquip.nl>
 * Juanco A�ez <juanco@users.sourceforge.net>
 * Uberto Barbini <uberto@usa.net>
 * Kris Golko <neuromancer@users.sourceforge.net>
 * Jon Bertrand <jonbsfnet@users.sourceforge.net>
 * The DUnit group at SourceForge <http://dunit.sourceforge.net>
 *
 * TODO:
 *   Select popup and main menu items (WM_SYSCOMMAND?)
 *   Copy/paste using keyboard (simulate with keypresses or need WM_COPY,
 *     WM_CUT, WM_PASTE?)
 *   Mouse wheel messages
 *   Context menu key
 *   Text selection using the mouse (independent mouse down, up, mouse move)
 *   Drag and drop
 *   TComboBox item selection using keyboard
 *   Use control hierarchy and index to find window handle of control at
 *     runtime for unnamed controls instead of using an absolute cursor
 *     position. This allows the control position to change such as when
 *     the window resized.
 *   Optionally record timing. Calculate time between actions and add delay
 *     to commands to simulate actual usage.
 *   Detect change in foreground window and add a WaitForNewForegroundWindow
 *     command.
 *   Optionally record all mouse movement at set intervals.
 *   Set mouse position prior to text/key entry command (if pos changed since
 *     prev click command).
 *)

{$I DUnit.inc}

unit GUIActionRecorder;

interface

uses
{$IFDEF LINUX}
  Types,
{$ELSE}
  Windows,
  Messages,
{$ENDIF}
{$IFDEF DUNIT_CLX}
  Qt,
  QControls,
  QForms,
{$ELSE}
  Controls,
  Forms,
{$ENDIF}
  Classes,
  Contnrs;

const
  rcs_id: string = '#(@)$Id: GUIActionRecorder.pas,v 1.35 2010/05/04 09:55:00 jarrodh Exp $';

  CEnterTextIntoCommandName = 'EnterTextInto';
  CEnterKeyIntoCommandName = 'EnterKeyInto';
  CEnterKeyCommandName = 'EnterKey';
  CLeftClickCommand = 'Left';
  CRightClickCommand = 'Right';
  CMiddleClickCommand = 'Middle';
  CDoubleClickCommand = 'Double';
  CClickCommand = 'Click';
  CClickAtCommand = 'At';

type
  TGUITestCaseStopRecordingEvent = procedure(Sender: TObject;
      var AStopRecording: boolean) of object;

  TMouseClickState = (mcsSingle, mcsDouble);

  TGUIActionAbs = class {$IFDEF DELPHI2006_UP}abstract{$ENDIF} (TObject)
  private
    FControlName: string;
  protected
    function GetCommandName: string; virtual; abstract;
    function GetCommandParameters: string; virtual;
    function GetAsString: string;
    function JoinParams(const AFirst: string; const ASecond: string): string;
  public
    constructor Create(const AControlName: string);
    property ControlName: string read FControlName;
    property CommandName: string read GetCommandName;
    property CommandParameters: string read GetCommandParameters;
    property AsString: string read GetAsString;
  end;

  TGUIActionList = class(TObjectList)
  protected
    function GetItem(AIndex: Integer): TGUIActionAbs;
    procedure SetItem(AIndex: Integer; AObject: TGUIActionAbs);
    function GetAsString: string;
  public
    property Items[AIndex: Integer]: TGUIActionAbs read GetItem write SetItem; default;
    property AsString: string read GetAsString;
  end;

  // Singleton
  TGUIActionRecorder = class(TObject)
  private
    FActive: boolean;
    FActions: TGUIActionList;
    FEnteredText: string;
    FControl: TControl;
    FOnStopRecording: TGUITestCaseStopRecordingEvent;
    procedure AddAction(AAction: TGUIActionAbs);
    procedure FlushTextEntry;
    function CharFromVirtualKey(const AKey: Word): string;
    function CheckKeyState(const AVKCode: Word; var AKeyState: string;
        const ANewKeyState: string): boolean;
    procedure SetActive(const AValue: boolean);
    procedure SetControl(const AControl: TControl);
    function IsDesignTimeControl(const AControl: TControl): boolean;
    function ControlName: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Initialize;
    procedure Finalize;
    procedure ProcessMessage(const AMessage: UINT; const AHwnd: HWND;
        const AWParam: WPARAM; out AStopRecording: boolean;
        const AX: Integer = -1; const AY: Integer = -1);
    procedure StopRecording;

    property Active: boolean read FActive write SetActive;
    property Actions: TGUIActionList read FActions;
    property OnStopRecording: TGUITestCaseStopRecordingEvent read
        FOnStopRecording write FOnStopRecording;
  end;

  TGUIActionEnterTextInto = class(TGUIActionAbs)
  private
    FText: string;
  protected
    function GetCommandName: string; override;
    function GetCommandParameters: string; override;
  public
    constructor Create(const AControlName: string; const AText: string);
    property Text: string read FText;
  end;

  TGUIActionEnterKey = class(TGUIActionAbs)
  private
    FKeyCode: Integer;
    FKeyState: string;
  protected
    function GetCommandName: string; override;
    function GetCommandParameters: string; override;
  public
    constructor Create(const AControlName: string; const AKeyCode: Integer;
        const AKeyState: string);
    property KeyCode: Integer read FKeyCode;
    property KeyState: string read FKeyState;
  end;

  TGUIActionClick = class(TGUIActionAbs)
  private
    FX: Integer;
    FY: Integer;
    FButton: TMouseButton;
    FClickState: TMouseClickState;
  protected
    function GetCommandName: string; override;
    function GetCommandParameters: string; override;
  public
    constructor Create(const AControlName: string; const AX: Integer;
        const AY: Integer; const AButton: TMouseButton;
        const AClickState: TMouseClickState);
    property X: Integer read FX;
    property Y: Integer read FY;
    property Button: TMouseButton read FButton;
    property ClickState: TMouseClickState read FClickState;
  end;

function GGUIActionRecorder: TGUIActionRecorder;

implementation

uses
   SysUtils
  ,Types
  ;

var
  URecorder: TGUIActionRecorder;
  UProcessGetMessageHook: HHOOK;
//  UCallWndProcHook: HHOOK;

{$IFNDEF LINUX}
  {$IFNDEF DELPHI2010_UP}

const
  MAPVK_VK_TO_VSC    = 0;
  {$EXTERNALSYM MAPVK_VK_TO_VSC}
  MAPVK_VSC_TO_VK    = 1;
  {$EXTERNALSYM MAPVK_VSC_TO_VK}
  MAPVK_VK_TO_CHAR   = 2;
  {$EXTERNALSYM MAPVK_VK_TO_CHAR}
  MAPVK_VSC_TO_VK_EX = 3;
  {$EXTERNALSYM MAPVK_VSC_TO_VK_EX}
  MAPVK_VK_TO_VSC_EX = 4;
  {$EXTERNALSYM MAPVK_VK_TO_VSC_EX}

  {$ENDIF}
{$ENDIF}

resourcestring
  CSingleInstanceErrorMessage = 'Only one instance of TGUIActionRecorder is permitted';

function GGUIActionRecorder: TGUIActionRecorder;
begin
  if Assigned(URecorder) then
    Result := URecorder
  else
    Result := TGUIActionRecorder.Create;
end;

function ProcessGetMessageProcHook(AnCode: Integer;
  AwParam: WPARAM; AlParam: LPARAM): LRESULT; stdcall;
var
  LMsg: PMsg;
  LStopRecording: boolean;
begin
  LStopRecording := false;
  if (AnCode = HC_ACTION) and (AwParam = PM_REMOVE) and
      Assigned(URecorder) and URecorder.Active then
  begin
    LMsg := PMsg(AlParam);
    URecorder.ProcessMessage(LMsg.message, LMsg.hwnd, LMsg.wParam,
        LStopRecording, LoWord(LMsg.lParam), HiWord(LMsg.lParam));
  end;

  Result := CallNextHookEx(UProcessGetMessageHook, AnCode, AwParam, AlParam);

  // Must only unhook after CallNextHookEx
  if Assigned(URecorder) and LStopRecording then
    URecorder.StopRecording;
end;

//function ProcessCallWndProcHook(AnCode: Integer;
//  AwParam: WPARAM; AlParam: LPARAM): Integer; stdcall;
//var
//  LStruct: PCWPStruct;
//  LStopRecording: boolean;
//begin
//  if Assigned(URecorder) and URecorder.Active then
//  begin
//    LStruct := PCWPStruct(AlParam);
//    URecorder.ProcessMessage(LStruct.message, LStruct.hwnd, LStruct.wParam,
//        LStopRecording);
//  end;
//
//  Result := CallNextHookEx(UCallWndProcHook, AnCode, AwParam, AlParam);
//
//  // Must only unhook after CallNextHookEx
//  if Assigned(URecorder) and LStopRecording then
//    URecorder.StopRecording;
//end;

{ TGUIActionAbs }

constructor TGUIActionAbs.Create(const AControlName: string);
begin
  inherited Create;
  FControlName := AControlName;
end;

function TGUIActionAbs.GetCommandParameters: string;
begin
  if FControlName = '' then
    Result := ''
  else
    Result := Format('''%s''', [FControlName]);
end;

function TGUIActionAbs.GetAsString: string;
var
  LParameters: string;
begin
  Result := CommandName;
  LParameters := CommandParameters;
  if LParameters <> '' then
    Result := Result + '(' + LParameters + ')';
end;

function TGUIActionAbs.JoinParams(const AFirst: string;
  const ASecond: string): string;
begin
  Result := AFirst;
  if (AFirst <> '') and (ASecond <> '') then
    Result := Result + ', ';
  Result := Result + ASecond;
end;

{ TGUIActionList }

function TGUIActionList.GetItem(AIndex: Integer): TGUIActionAbs;
begin
  Result := (inherited GetItem(AIndex)) as TGUIActionAbs;
end;

procedure TGUIActionList.SetItem(AIndex: Integer; AObject: TGUIActionAbs);
begin
  inherited SetItem(AIndex, AObject);
end;

function TGUIActionList.GetAsString: string;
var
  LActions: TStringList;
  I: Integer;
begin
  LActions := TStringList.Create;
  try
    for I := 0 to Count - 1 do
      LActions.Add(Items[I].AsString);
    Result := LActions.Text;
  finally
    LActions.Free;
  end;
end;

{ TGUIActionRecorder }

constructor TGUIActionRecorder.Create;
begin
  if URecorder <> nil then
    raise Exception.Create(CSingleInstanceErrorMessage);
  inherited;
  URecorder := Self;

  FActions := TGUIActionList.Create;
  FActive := false;
end;

destructor TGUIActionRecorder.Destroy;
begin
  Active := false; // Use setter
  FActions.Free;
  URecorder := nil;
  inherited;
end;

procedure TGUIActionRecorder.Initialize;
begin
  FActions.Clear;
end;

procedure TGUIActionRecorder.Finalize;
begin
  FlushTextEntry;
  FControl := nil;
end;

function TGUIActionRecorder.IsDesignTimeControl(const AControl: TControl):
  boolean;
begin
  Result := Assigned(FControl) and (FControl.Name <> '');
end;

function TGUIActionRecorder.ControlName: string;
begin
  if IsDesignTimeControl(FControl) then
    Result := FControl.Name
  else
    Result := '';
end;

procedure TGUIActionRecorder.AddAction(AAction: TGUIActionAbs);
begin
  FActions.Add(AAction);
end;

procedure TGUIActionRecorder.SetActive(const AValue: boolean);
begin
  if FActive <> AValue then
  begin
    if AValue then
    begin
      if UProcessGetMessageHook = 0 then
        UProcessGetMessageHook := SetWindowsHookEx(WH_GETMESSAGE,
            ProcessGetMessageProcHook, 0, GetCurrentThreadId);
//      if UCallWndProcHook = 0 then
//        UCallWndProcHook := SetWindowsHookEx(WH_CALLWNDPROC,
//            ProcessCallWndProcHook, 0, GetCurrentThreadId);
    end
    else
    begin
//      UnHookWindowsHookEx(UCallWndProcHook);
//      UCallWndProcHook := 0;
      UnHookWindowsHookEx(UProcessGetMessageHook);
      UProcessGetMessageHook := 0;
      Finalize;
    end;

    FActive := AValue;
  end;
end;

procedure TGUIActionRecorder.SetControl(const AControl: TControl);
begin
  if AControl <> FControl then
  begin
    FlushTextEntry;
    FControl := AControl;
  end;
end;

procedure TGUIActionRecorder.StopRecording;
var
  LStopRecording: boolean;
begin
  LStopRecording := true;
  if Assigned(FOnStopRecording) then
    FOnStopRecording(Self, LStopRecording);

  if LStopRecording then
    Active := false;
end;

procedure TGUIActionRecorder.FlushTextEntry;
begin
  if Assigned(FControl) and (FEnteredText <> '') then
  begin
    AddAction(TGUIActionEnterTextInto.Create(ControlName, FEnteredText));
    FEnteredText := '';
  end;
end;

function TGUIActionRecorder.CharFromVirtualKey(const AKey: Word): string;
var
  LState: TKeyboardState;
  LResult: Integer;
  LPResult: PChar;
begin
  GetKeyboardState(LState);
  SetLength(Result, 2);
  LPResult := PChar(Result);

  LResult := ToUnicode(AKey, MapVirtualKey(AKey, MAPVK_VK_TO_VSC),
      LState, LPResult, 2, 0);
  if LResult = 1 then
    SetLength(Result, 1)
  else if LResult <> 2 then
    Result := '';
end;

function TGUIActionRecorder.CheckKeyState(const AVKCode: Word;
  var AKeyState: string; const ANewKeyState: string): boolean;
begin
  Result := (GetKeyState(AVKCode) and $80) = $80;
  if Result then
  begin
    if AKeyState <> '' then
      AKeyState := AKeyState + ',';
    AKeyState := AKeyState + ANewKeyState;
  end;
end;

procedure TGUIActionRecorder.ProcessMessage(const AMessage: UINT;
  const AHwnd: HWND; const AWParam: WPARAM; out AStopRecording: boolean;
  const AX: Integer; const AY: Integer);
var
  LControl: TControl;
  LKeyState: string;
  LPoint: TPoint;
  LButton: TMouseButton;
  LClickState: TMouseClickState;

  // Translate control co-ords to window co-ords as we don't have a
  // repeatable window name or handle to rely on so we record it as
  // a click at the position relative to root window of the control.
  function _ControlToWindowCoords(const APoint: TPoint): TPoint;
  var
    LWindowHwnd: HWND;
  begin
    Result := APoint;
    ClientToScreen(AHwnd, Result);
    //LWindowHwnd := GetAncestor(AHwnd, GA_ROOT);
    LWindowHwnd := GetForegroundWindow;
    ScreenToClient(LWindowHwnd, Result);
  end;

begin
  if not FActive then
    Exit; //==>
  AStopRecording := false;

  // See if the window handle is for a VCL control
  LControl := FindControl(AHwnd);
  LPoint := Point(AX, AY);

  case AMessage of
    WM_SYSKEYDOWN, WM_KEYDOWN:
      begin
        // ctrl-break stops recording
        if (AWParam = VK_CANCEL) and
           ((GetKeyState(VK_CONTROL) and $80) = $80) then
        begin
          AStopRecording := true;
          Exit; //==>
        end;

        SetControl(LControl);

        if (AWParam <> VK_SHIFT) and (AWParam <> VK_CONTROL) and
           (AWParam <> VK_MENU) then
        begin
          LKeyState := '';
          CheckKeyState(VK_SHIFT, LKeyState, 'ssShift');
          CheckKeyState(VK_CONTROL, LKeyState, 'ssCtrl');
          CheckKeyState(VK_MENU, LKeyState, 'ssAlt');

          // Build up as much regular text to enter as possible
          if ((LKeyState = '') or (LKeyState = 'ssShift')) and
             (AWParam >= $30) and (AWParam <= $5A) then // Regular characters
            FEnteredText := FEnteredText + CharFromVirtualKey(AWParam)
          else
          begin // Special characters
            FlushTextEntry;
            AddAction(TGUIActionEnterKey.Create(ControlName, AWParam, LKeyState));
          end;
        end;
      end;
    WM_LBUTTONDOWN,
    WM_LBUTTONDBLCLK,
    WM_RBUTTONDOWN,
    WM_RBUTTONDBLCLK:
      begin
        SetControl(LControl);
        FlushTextEntry;

        if (AMessage = WM_LBUTTONDOWN) or (AMessage = WM_LBUTTONDBLCLK) then
          LButton := mbLeft
        else
          LButton := mbRight;

        if (AMessage = WM_LBUTTONDBLCLK) or (AMessage = WM_RBUTTONDBLCLK) then
          LClickState := mcsDouble
        else
          LClickState := mcsSingle;

        // If control cannot be identified by name then find the control
        // at runtime based on co-ords from foreground window.
        if not IsDesignTimeControl(FControl) then
          LPoint := _ControlToWindowCoords(LPoint);

        AddAction(TGUIActionClick.Create(ControlName, LPoint.X, LPoint.Y,
            LButton, LClickState));
      end;
  end;
end;

{ TGUIActionEnterTextInto }

constructor TGUIActionEnterTextInto.Create(const AControlName: string;
  const AText: string);
begin
  inherited Create(AControlName);
  FText := AText;
end;

function TGUIActionEnterTextInto.GetCommandName: string;
begin
  Result := CEnterTextIntoCommandName;
end;

function TGUIActionEnterTextInto.GetCommandParameters: string;
begin
  Result := JoinParams((inherited GetCommandParameters),
      Format('''%s''', [FText]));
end;

{ TGUIActionEnterKey }

constructor TGUIActionEnterKey.Create(const AControlName: string;
  const AKeyCode: Integer; const AKeyState: string);
begin
  inherited Create(AControlName);
  FKeyCode := AKeyCode;
  FKeyState := AKeyState;
end;

function TGUIActionEnterKey.GetCommandName: string;
begin
  if ControlName = '' then
    Result := CEnterKeyCommandName
  else
    Result := CEnterKeyIntoCommandName;
end;

function TGUIActionEnterKey.GetCommandParameters: string;
begin
  Result := JoinParams((inherited GetCommandParameters),
      Format('%d, [%s]', [FKeyCode, FKeyState]));
end;

{ TGUIActionClick }

constructor TGUIActionClick.Create(const AControlName: string;
  const AX: Integer; const AY: Integer; const AButton: TMouseButton;
  const AClickState: TMouseClickState);
begin
  inherited Create(AControlName);
  FX := AX;
  FY := AY;
  FButton := AButton;
  FClickState := AClickState;
end;

function TGUIActionClick.GetCommandName: string;
begin
  case FButton of
    mbLeft: Result := CLeftClickCommand;
    mbRight: Result := CRightClickCommand;
//    mbMiddle: Result := CMiddleClickCommand;
  else
    raise Exception.Create('Unhandled mouse button: ' + IntToStr(Ord(FButton)));
  end;

  case FClickState of
    mcsSingle: ;
    mcsDouble: Result := Result + CDoubleClickCommand;
  else
    raise Exception.Create('Unhandled click state: ' + IntToStr(Ord(FClickState)));
  end;

  Result := Result + CClickCommand;
  if ControlName = '' then
    Result := Result + CClickAtCommand;
end;

function TGUIActionClick.GetCommandParameters: string;
begin
  Result := JoinParams((inherited GetCommandParameters),
      Format('%d, %d', [FX, FY]));
end;

initialization
  URecorder := nil;
//  UCallWndProcHook := 0;
  UProcessGetMessageHook := 0;

finalization
  FreeAndNil(URecorder);

end.

