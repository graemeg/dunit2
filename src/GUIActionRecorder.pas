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
 * and Juancarlo Añez.
 * Portions created The Initial Developers are Copyright (C) 1999-2000.
 * Portions created by The DUnit Group are Copyright (C) 2000-2008.
 * All rights reserved.
 *
 * Contributor(s):
 * Serge Beaumont <beaumose@iquip.nl>
 * Juanco Añez <juanco@users.sourceforge.net>
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
 *)

{$IFDEF LINUX}
{$DEFINE DUNIT_CLX}
{$ENDIF}

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
  Classes;

const
  rcs_id: string = '#(@)$Id: GUIActionRecorder.pas,v 1.35 2010/05/04 09:55:00 jarrodh Exp $';

  CAutomationCommandPrefix = 'Automation';
  CEnterTextIntoCommandName = 'EnterTextInto';
  CEnterKeyIntoCommandName = 'EnterKeyInto';
  CEnterKeyCommandName = 'EnterKey';
  CLeftClickCommandName = 'LeftClick';
  CLeftClickAtCommandName = 'LeftClickAt';
  CLeftDoubleClickCommandName = 'LeftDoubleClick';
  CLeftDoubleClickAtCommandName = 'LeftDoubleClickAt';
  CRightClickCommandName = 'RightClick';
  CRightClickAtCommandName = 'RightClickAt';
  CRightDoubleClickCommandName = 'RightDoubleClick';
  CRightDoubleClickAtCommandName = 'RightDoubleClickAt';

type
  TGUITestCaseStopRecordingEvent = procedure(Sender: TObject;
      var AStopRecording: boolean) of object;

  // Singleton
  TGUIActionRecorder = class(TObject)
  private
    FActive: boolean;
    FCommands: TStringList;
    FEnteredText: string;
    FControl: TControl;
    FOnStopRecording: TGUITestCaseStopRecordingEvent;
    procedure AddCommand(const ACommandName: string;
        const AOptionalArguments: string = '');
    procedure FlushTextEntry;
    function CharFromVirtualKey(const AKey: Word): string;
    function CheckKeyState(const AVKCode: Word; var AKeyState: string;
        const ANewKeyState: string): boolean;
    procedure SetActive(const AValue: boolean);
    procedure SetControl(const AControl: TControl);
    function IsDesignTimeControl(const AControl: TControl): boolean;
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
    property Commands: TStringList read FCommands;
    property OnStopRecording: TGUITestCaseStopRecordingEvent read
        FOnStopRecording write FOnStopRecording;
  end;

function GGUIActionRecorder: TGUIActionRecorder;

implementation

uses
   SysUtils
  ;

var
  URecorder: TGUIActionRecorder;
  UProcessGetMessageHook: HHOOK;
//  UCallWndProcHook: HHOOK;

resourcestring
  CSingleInstanceErrorMessage = 'Only one instance of TGUIActionRecorder is permitted';

function GGUIActionRecorder: TGUIActionRecorder;
begin
  if Assigned(URecorder) then
    result := URecorder
  else
    result := TGUIActionRecorder.Create;
end;

function ProcessGetMessageProcHook(AnCode: Integer;
  AwParam: WPARAM; AlParam: LPARAM): Integer; stdcall;
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

{ TGUIActionRecorder }

constructor TGUIActionRecorder.Create;
begin
  if URecorder <> nil then
    raise Exception.Create(CSingleInstanceErrorMessage);
  inherited;
  URecorder := Self;

  FCommands := TStringList.Create;
  FActive := false;
end;

destructor TGUIActionRecorder.Destroy;
begin
  Active := false; // Use setter
  FCommands.Free;
  URecorder := nil;
  inherited;
end;

procedure TGUIActionRecorder.Initialize;
begin
  FCommands.Clear;
end;

procedure TGUIActionRecorder.Finalize;
begin
  FlushTextEntry;
  FControl := nil;
end;

function TGUIActionRecorder.IsDesignTimeControl(const AControl: TControl):
  boolean;
begin
  result := Assigned(FControl) and (FControl.Name <> '');
end;

procedure TGUIActionRecorder.AddCommand(const ACommandName: string;
  const AOptionalArguments: string);
var
  LCommand: string;
  LArguments: string;
begin
  if IsDesignTimeControl(FControl) then
    LArguments := Format('''%s''', [FControl.Name])
  else
    LArguments := '';

  if AOptionalArguments <> '' then
  begin
    if LArguments <> '' then
      LArguments := LArguments + ', ';
    LArguments := LArguments + AOptionalArguments;
  end;

  LCommand := Format('%s.%s(%s);', [CAutomationCommandPrefix, ACommandName,
      LArguments]);
  FCommands.Add(LCommand);
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
    AddCommand(CEnterTextIntoCommandName, Format('''%s''', [FEnteredText]));
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
  LCommandName: string;

  // Translate control co-ords to window co-ords as we don't have a
  // repeatable window name or handle to rely on so we record it as
  // a click at the position relative to root window of the control.
  function _WindowCoords: TPoint;
  var
    LWindowHwnd: HWND;
  begin
    result := Point(AX, AY);
    ClientToScreen(AHwnd, result);
    //LWindowHwnd := GetAncestor(AHwnd, GA_ROOT);
    LWindowHwnd := GetForegroundWindow;
    ScreenToClient(LWindowHwnd, result);
  end;

begin
  if not FActive then
    Exit; //==>
  AStopRecording := false;

  // See if the window handle is for a VCL control
  LControl := FindControl(AHwnd);

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
            if IsDesignTimeControl(FControl) then
              AddCommand(CEnterKeyIntoCommandName, Format('%d, [%s]', [AWParam, LKeyState]))
            else
              AddCommand(CEnterKeyCommandName, Format('%d, [%s]', [AWParam, LKeyState]));
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

        // Note: See constants for valid command names.
        if (AMessage = WM_LBUTTONDOWN) or (AMessage = WM_LBUTTONDBLCLK) then
          LCommandName := 'Left'
        else
          LCommandName := 'Right';
        if (AMessage = WM_LBUTTONDBLCLK) or (AMessage = WM_RBUTTONDBLCLK) then
          LCommandName :=  LCommandName + 'Double';
        LCommandName := LCommandName + 'Click';

        // Send directly to control if it can be identified, else find control
        // at runtime based on co-ords from active window.
        if IsDesignTimeControl(FControl) then
          AddCommand(LCommandName, Format('%d, %d', [AX, AY]))
        else
        begin
          LPoint := _WindowCoords;
          Addcommand(LCommandName + 'At', Format('%d, %d', [LPoint.X, LPoint.Y]));
        end;
      end;
  end;
end;

initialization
  URecorder := nil;
//  UCallWndProcHook := 0;
  UProcessGetMessageHook := 0;

finalization
  FreeAndNil(URecorder);

end.

