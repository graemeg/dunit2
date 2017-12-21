{: DUnit: An XTreme testing framework for Delphi programs.
   @author  The DUnit Group.
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
 * The Initial Developers of the Original Code are Kent Beck, Erich Gamma,
 * and Juancarlo Añez.
 * Portions created The Initial Developers are Copyright (C) 1999-2000.
 * Portions created by The DUnit Group are Copyright (C) 2000-2008.
 * All rights reserved.
 *
 * Contributor(s):
 * Kent Beck <kentbeck@csi.com>
 * Erich Gamma <Erich_Gamma@oti.com>
 * Juanco Añez <juanco@users.sourceforge.net>
 * Chris Morris <chrismo@users.sourceforge.net>
 * Jeff Moore <JeffMoore@users.sourceforge.net>
 * Uberto Barbini <uberto@usa.net>
 * Brett Shearer <BrettShearer@users.sourceforge.net>
 * Kris Golko <neuromancer@users.sourceforge.net>
 * The DUnit group at SourceForge <http://dunit.sourceforge.net>
 * Peter McNab <mcnabp@gmail.com>
 *
 *******************************************************************************
*)

unit FastMMMonitorTest;

{$I DUnit.inc}

interface

uses
  FastMM4,
  TestFrameworkIfaces,
  {$IFDEF SELFTEST}
    RefTestFramework,
  {$ELSE}
    TestFramework,
  {$ENDIF}
  SysUtils,
  Contnrs;

{$IFNDEF VER130}
  {$IFNDEF VER140}
    {$WARN UNSAFE_CODE OFF}
  {$ENDIF}
{$ENDIF}
type

  TBasicMemMonitor = class(TTestCase)
  private
    MLM : IDUnitMemLeakMonitor;
    FLeakList: array[0..4] of Integer; // As many as I think one ever might need
    FLeakListIndex : Word;
    function  Leaks: Integer;
    procedure SetLeakList(const ListOfLeaks : array of Integer);
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure CheckMemManagerLoaded;
    procedure CheckMemMonitorCreates;
    procedure CheckMemMonitorDestroys;
    procedure CheckMemMonitorComparesEqual;
    procedure CheckMemMonitorRecoversMemOK;
    procedure CheckMemMonitorFailsOnMemoryLeak;
    procedure CheckMemMonitorPassOnMemRecovery;
    procedure CheckMemMonitorFailsOnMemRecovery;
    procedure CheckMemMonitorPassesOnAllowedMemRecovery;
    procedure CheckMemMonitorPassedOnAllowedPositiveLeak;
    procedure CheckMemMonitorPassOnListAllowedNoLeak0;
    procedure CheckMemMonitorFailOnEmptyListAndPositiveLeak;
    procedure CheckMemMonitorPassOnListAllowedPositiveLeak1;
    procedure CheckMemMonitorFailOnEmptyListAndNegativeLeak;
    procedure CheckMemMonitorPassOnListNegativeLeak;
    procedure CheckMemMonitorPassOnListAllowedNegativeLeak1;
    procedure CheckOffsetProperty;
  end;

  TMemMonitorGetErrorMessage = class(TTestCase)
  private
    MLM : IDUnitMemLeakMonitor;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure CheckGetMemoryUseMsgOK;
    procedure CheckGetRecoveredMemMsg;
    procedure CheckGetAllowedRecoveredMemMsg;
    procedure CheckGetLeakedMemMsg;
  end;

  TMemMonitorGetErrorMessageNew = class(TTestCase)
  private
    MLM : IDUnitMemLeakMonitor;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure CheckSumOfLeaks;
    procedure CheckGetMemoryUseMsgOK;
    procedure CheckGetRecoveredMemMsg;
    procedure CheckGetLeakedMemMsg;
  end;

  TMemMonitorStringLeakHandling = class(TTestCase)
  private
    FClearVarsInTearDown: boolean;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure CheckMemManagerNoLeaks1;
    procedure CheckMemManagerNoLeaks2;
    procedure CheckMemManagerLeaks;
    procedure CheckMemManagerNoLeaks3;
    procedure CheckMemManagerNoLeaks4;
  end;

  TMemMonitorObjectLeakHandling = class(TTestCase)
  private
    FClearVarsInTearDown: boolean;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure CheckMemManagerNoLeaks1;
    procedure CheckMemManagerNoLeaks2;
    procedure CheckMemManagerLeaks;
    procedure CheckMemManagerNoLeaks3;
    procedure CheckMemManagerNoLeaks4;
  end;

  TMemMonitorExceptLeakHandling = class(TTestCase)
  private
    FClearVarsInTearDown: boolean;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure CheckMemManagerNoLeaks1;
    procedure CheckMemManagerNoLeaks2;
    procedure CheckMemManagerLeaks;
    procedure CheckMemManagerNoLeaks3;
    procedure CheckMemManagerNoLeaks4;
  end;

  TMemMonitorMemAllocLeakHandling = class(TTestCase)
  private
    FClearVarsInTearDown: boolean;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure CheckMemManagerNoLeaks1;
    procedure CheckMemManagerNoLeaks2;
    procedure CheckMemManagerLeaks;
    procedure CheckMemManagerNoLeaks3;
    procedure CheckMemManagerNoLeaks4;
  end;

implementation

var
  LeakyArray : array of Byte;
  LeakedObject: TObject = nil;
  Excpt: EAbort;
  LeakyString : string;
  LeakyMemory : PChar;
  ObjectList : TObjectList;

procedure ClearVars;
begin
  SetLength(LeakyArray,0);
  LeakyArray := nil;
  SetLength(LeakyString, 0);
  LeakyString := '';
  FreeAndNil(LeakedObject);
  if (LeakyMemory <> nil) then
  try
    FreeMem(LeakyMemory);
    LeakyMemory := nil;
  except
    LeakyMemory := nil;
  end;

  try
    if Assigned(Excpt) then
      raise Excpt;
  except
    Excpt := nil;
  end;

  try
    FreeAndNil(ObjectList);
  except
  end;
end;

procedure TBasicMemMonitor.SetUp;
begin
  inherited;
  ClearVars;
  MLM := nil;
end;

procedure TBasicMemMonitor.TearDown;
begin
  inherited;
  try
    ClearVars;
  finally
    MLM := nil;
  end;
end;

function MemManagerLoaded: boolean;
begin
  {$IFDEF VER180}
    Result := True;
  {$ELSE}
    Result := IsMemoryManagerSet;
  {$ENDIF}
end;

procedure TBasicMemMonitor.CheckMemManagerLoaded;
begin
  Check(MemManagerLoaded, 'Memory Manager not loaded');
end;

procedure TBasicMemMonitor.CheckMemMonitorCreates;
begin
  try
    MLM := MemLeakMonitor;
  finally
    Check(Assigned(MLM), 'MemLeakMonitor failed to create');
    MLM := nil;
  end;
end;

procedure TBasicMemMonitor.CheckMemMonitorDestroys;
var
  Lyyxx: boolean;
begin
  Lyyxx := False;
  try
    MLM := MemLeakMonitor;
    Lyyxx := True;
  finally
    Check(Assigned(MLM), 'MemLeakMonitor failed to create');
    try
      Check(Lyyxx = True, 'MemLeakMonitor failed to create cleanly');
      MLM := nil;
      Lyyxx := False;
    finally
      Check(Lyyxx = False, 'MemLeakMonitor failed to Destroy cleanly');
    end;
  end;
end;

procedure TBasicMemMonitor.CheckMemMonitorComparesEqual;
var
  LMemUsed    : Integer;
  LStatus     : boolean;
begin
  MLM := MemLeakMonitor;
  LStatus := (MLM as IMemLeakMonitor).MemLeakDetected(LMemUsed);
  Check(not LStatus, 'Return result on equal memory comparison not set false');
  Check((LMemUsed=0), 'Return value on equal memory comparison does not equal zero');
end;

procedure TBasicMemMonitor.CheckMemMonitorRecoversMemOK;
var
  LMemUsed : Integer;
  LStatus: boolean;
begin
  SetLength(LeakyArray, 100);
  MLM := MemLeakMonitor;
  SetLength(LeakyArray, 0);
  LeakyArray := nil;

  LStatus := MLM.MemLeakDetected(0, False, LMemUsed);
  Check(not LStatus, 'Return result on ignored less memory comparison not set False');
  Check((LMemUsed < 0), 'Return value on freed up memory comparison not less than zero');
end;

procedure TBasicMemMonitor.CheckMemMonitorPassOnMemRecovery;
var
  LMemUsed : Integer;
  LStatus: boolean;
begin
  SetLength(LeakyArray, 100);
  MLM := MemLeakMonitor;
  SetLength(LeakyArray, 0);
  LeakyArray := nil;
  LStatus := MLM.MemLeakDetected(0, False, LMemUsed);
  Check(not LStatus, 'Return result on memory recovery set True');
  Check((LMemUsed < 0), 'Return value on freed up memory comparison not less than zero');
end;

procedure TBasicMemMonitor.CheckMemMonitorFailsOnMemRecovery;
var
  LMemUsed : Integer;
  LStatus: boolean;
begin
  SetLength(LeakyArray, 100);
  MLM := MemLeakMonitor;
  SetLength(LeakyArray, 0);
  LeakyArray := nil;
  LStatus := MLM.MemLeakDetected(0, True, LMemUsed);
  Check(LStatus, 'Return result on memory recovery set False');
  Check((LMemUsed < 0), 'Return value on freed up memory comparison not less than zero');
end;

procedure TBasicMemMonitor.CheckMemMonitorPassesOnAllowedMemRecovery;
var
  LMemUsed : Integer;
  LStatus: boolean;
begin
  SetLength(LeakyArray, 100);
  MLM := MemLeakMonitor;
  SetLength(LeakyArray, 0);
  LeakyArray := nil;

  LStatus := MLM.MemLeakDetected(-112, True, LMemUsed);
  Check(not LStatus, 'Return result on less memory comparison set False');
  Check((LMemUsed < 0), 'Return value on freed up memory comparison not less than zero');
end;

procedure TBasicMemMonitor.CheckMemMonitorFailsOnMemoryLeak;
var
  LMemUsed : Integer;
  LStatus: boolean;
begin
  MLM := MemLeakMonitor;
  SetLength(LeakyArray, 100);
  try
    LStatus := (MLM as IMemLeakMonitor).MemLeakDetected(LMemUsed);
    Check(LStatus, 'Return result on less memory comparison not set true');
    Check((LMemUsed > 0), 'Return value leaked memory comparison not greater than zero');
  finally
    SetLength(LeakyArray, 0);
    LeakyArray := nil;
  end;
end;

procedure TBasicMemMonitor.CheckMemMonitorPassedOnAllowedPositiveLeak;
var
  LMemUsed : Integer;
  LStatus: boolean;
begin
  MLM := MemLeakMonitor;
  SetLength(LeakyArray, 100);
  try
    LStatus := MLM.MemLeakDetected(112, True, LMemUsed);
    Check(not LStatus, 'Return result on offset memory comparison not set true');
    Check((LMemUsed = 112), 'Return value = ' + IntToStr(LMemUsed) +
      ' Should be 112');
  finally
    SetLength(LeakyArray, 0);
    LeakyArray := nil;
  end;
end;

procedure TBasicMemMonitor.CheckMemMonitorFailOnEmptyListAndPositiveLeak;
var
  LMemUsed : Integer;
  LStatus: boolean;
  LLeaks: integer;
begin
  MLM := MemLeakMonitor;
  SetLength(LeakyArray, 100);
  try
    LLeaks := Leaks;
    LStatus := MLM.MemLeakDetected(LLeaks, True, LMemUsed);
    Check(LStatus, 'Return result on empty array with leak was set False');
    Check((LMemUsed = 112), 'Return value = ' + IntToStr(LMemUsed) +
      ' Should be 112');
  finally
    SetLength(LeakyArray, 0);
    LeakyArray := nil;
  end;
end;

procedure TBasicMemMonitor.CheckMemMonitorPassOnListAllowedNoLeak0;
var
  LMemUsed : Integer;
  LStatus: boolean;
begin
  MLM := MemLeakMonitor;
  SetLength(LeakyArray, 100);
  try
    LStatus := MLM.MemLeakDetected(112, True, LMemUsed);
    Check(not LStatus, 'Return result on offset memory comparison not set true');
    Check((LMemUsed = 112), 'Return value = ' + IntToStr(LMemUsed) +
      ' Should be 112');
  finally
    SetLength(LeakyArray, 0);
    LeakyArray := nil;
  end;
end;

procedure TBasicMemMonitor.CheckMemMonitorPassOnListAllowedPositiveLeak1;
var
  LMemUsed : Integer;
  LStatus: boolean;
  LIndex: Integer;
  LLeaks: integer;
begin
  SetLeakList([112]);
  MLM := MemLeakMonitor;
  SetLength(LeakyArray, 100);
  try
    LLeaks := Leaks;
    LStatus := MLM.MemLeakDetected(LLeaks, True, LMemUsed);
    Check(not LStatus, 'Return result on single matching allowed not set true');

    SetLeakList([112,1]);
    LStatus := MLM.MemLeakDetected(Leaks, True, LIndex, LMemUsed);
    Check(not LStatus, 'Return result on 1st in list match not set true');

    SetLeakList([1, 112]);
    LStatus := MLM.MemLeakDetected(Leaks, True, LIndex, LMemUsed);
    Check(not LStatus, 'Return result on 2nd in list not set true');

    Check((LMemUsed = 112), 'Return value = ' + IntToStr(LMemUsed) +
      ' Should be 112');
  finally
    SetLength(LeakyArray, 0);
    LeakyArray := nil;
  end;
end;

procedure TBasicMemMonitor.CheckMemMonitorFailOnEmptyListAndNegativeLeak;
var
  LMemUsed : Integer;
  LStatus: boolean;
  LLeaks: integer;
begin
  SetLength(LeakyArray, 100);
  MLM := MemLeakMonitor;
  SetLength(LeakyArray, 0);
  LeakyArray := nil;

  SetLeakList([0]);
  LLeaks := Leaks;
  LStatus := MLM.MemLeakDetected(LLeaks, True, LMemUsed);
  Check(LStatus, 'Return result on less memory comparison set False');
  Check((LMemUsed < 0), 'Return value on freed up memory comparison not less than zero');
end;

procedure TBasicMemMonitor.CheckMemMonitorPassOnListNegativeLeak;
var
  LMemUsed : Integer;
  LIndex: Integer;
  LStatus: boolean;
  LLeaks: integer;
begin
  SetLength(LeakyArray, 100);
  MLM := MemLeakMonitor;
  SetLength(LeakyArray, 0);
  LeakyArray := nil;

  SetLeakList([]);
  LLeaks := Leaks;
  LStatus := MLM.MemLeakDetected(LLeaks, False, LMemUsed);
  Check(not LStatus, 'Return result on memory recovery set true');

  LStatus := MLM.MemLeakDetected(Leaks, False, LIndex, LMemUsed);
  Check(not LStatus, 'Return result on empty list memory recovery set true');

  Check((LMemUsed < 0), 'Return value on freed up memory comparison not less than zero');
end;

procedure TBasicMemMonitor.CheckMemMonitorPassOnListAllowedNegativeLeak1;
var
  LMemUsed : Integer;
  LStatus: boolean;
  LIndex: Integer;
  LLeaks: Integer;
begin
  SetLength(LeakyArray, 100);
  MLM := MemLeakMonitor;
  SetLength(LeakyArray, 0);
  LeakyArray := nil;

  SetLeakList([-112]);
  LLeaks := Leaks;
  LStatus := MLM.MemLeakDetected(LLeaks, True, LMemUsed);
  Check(not LStatus, 'Return result on single matching allowed not set true');

  SetLeakList([-112, 1]);
  LStatus := MLM.MemLeakDetected(Leaks, True, LIndex, LMemUsed);
  Check(not LStatus, 'Return result on 1st in list match not set true');

  SetLeakList([1, -112]);
  LStatus := MLM.MemLeakDetected(Leaks, True, LIndex, LMemUsed);
  Check(not LStatus, 'Return result on 2nd in list not set true');

  Check((LMemUsed < 0), 'Return value on freed up memory comparison not less than zero');
end;

procedure TBasicMemMonitor.CheckOffsetProperty;
begin
  Check(AllowedMemoryLeakSize = 0,
    ' AllowedMemoryLeakSize should always be zero on entry but was '
    + IntToStr(AllowedMemoryLeakSize));
  AllowedMemoryLeakSize := 10;
  Check(AllowedMemoryLeakSize = 10,
    ' AllowedMemoryLeakSize should always be 10 but was '
    + IntToStr(AllowedMemoryLeakSize));
  AllowedMemoryLeakSize := AllowedMemoryLeakSize - 10;
  Check(AllowedMemoryLeakSize = 0,
    ' AllowedMemoryLeakSize should always be 0 but was '
    + IntToStr(AllowedMemoryLeakSize));
end;

{------------------------------------------------------------------------------}
{ TMemMonitorStringLeakHandling }

procedure TMemMonitorStringLeakHandling.SetUp;
begin
  inherited;
  ClearVars;
  FClearVarsInTearDown := True;
end;

procedure TMemMonitorStringLeakHandling.TearDown;
begin
  inherited;
  if FClearVarsInTearDown then
    ClearVars;
end;

procedure TMemMonitorStringLeakHandling.CheckMemManagerLeaks;
begin
  Check(IsMemoryManagerSet, 'Memory Manager not loaded');
  SetLength(LeakyString,200);
  FClearVarsInTearDown := False;
end;

procedure TMemMonitorStringLeakHandling.CheckMemManagerNoLeaks1;
begin
  Check(IsMemoryManagerSet, 'Memory Manager not loaded');
  SetLength(LeakyString,200);
  FClearVarsInTearDown := True;
end;

procedure TMemMonitorStringLeakHandling.CheckMemManagerNoLeaks2;
begin
  CheckMemManagerNoLeaks1;
end;

procedure TMemMonitorStringLeakHandling.CheckMemManagerNoLeaks3;
begin
  CheckMemManagerNoLeaks1;
end;

procedure TMemMonitorStringLeakHandling.CheckMemManagerNoLeaks4;
begin
  CheckMemManagerNoLeaks1;
end;

{ TMemMonitorObjectLeakHandling }

procedure TMemMonitorObjectLeakHandling.SetUp;
begin
  inherited;
  ClearVars;
  FClearVarsInTearDown := True;
end;

procedure TMemMonitorObjectLeakHandling.TearDown;
begin
  inherited;
  if FClearVarsInTearDown then
    ClearVars;
end;

procedure TMemMonitorObjectLeakHandling.CheckMemManagerLeaks;
begin
  Check(IsMemoryManagerSet, 'Memory Manager not loaded');
  LeakedObject := TObject.Create;
  FClearVarsInTearDown := False;
end;

procedure TMemMonitorObjectLeakHandling.CheckMemManagerNoLeaks1;
begin
  Check(IsMemoryManagerSet, 'Memory Manager not loaded');
  LeakedObject := TObject.Create;
  FClearVarsInTearDown := True;
end;

procedure TMemMonitorObjectLeakHandling.CheckMemManagerNoLeaks2;
begin
  CheckMemManagerNoLeaks1;
end;

procedure TMemMonitorObjectLeakHandling.CheckMemManagerNoLeaks3;
begin
  CheckMemManagerNoLeaks1;
end;

procedure TMemMonitorObjectLeakHandling.CheckMemManagerNoLeaks4;
begin
  CheckMemManagerNoLeaks1;
end;

{ TMemMonitorExceptLeakHandling }

procedure TMemMonitorExceptLeakHandling.SetUp;
begin
  inherited;
  ClearVars;
  FClearVarsInTearDown := True;
end;

procedure TMemMonitorExceptLeakHandling.TearDown;
begin
  inherited;
  if FClearVarsInTearDown then
    ClearVars;
end;

procedure TMemMonitorExceptLeakHandling.CheckMemManagerLeaks;
begin
  Check(IsMemoryManagerSet, 'Memory Manager not loaded');
  Excpt := EAbort.Create('');
  FClearVarsInTearDown := False;
end;

procedure TMemMonitorExceptLeakHandling.CheckMemManagerNoLeaks1;
begin
  Check(IsMemoryManagerSet, 'Memory Manager not loaded');
  Excpt := EAbort.Create('');
  FClearVarsInTearDown := True;
end;

procedure TMemMonitorExceptLeakHandling.CheckMemManagerNoLeaks2;
begin
  CheckMemManagerNoLeaks1;
end;

procedure TMemMonitorExceptLeakHandling.CheckMemManagerNoLeaks3;
begin
  CheckMemManagerNoLeaks1;
end;

procedure TMemMonitorExceptLeakHandling.CheckMemManagerNoLeaks4;
begin
  CheckMemManagerNoLeaks1;
end;

{ TMemMonitorMemAllocLeakHandling }

procedure TMemMonitorMemAllocLeakHandling.CheckMemManagerLeaks;
begin
  Check(MemManagerLoaded, 'Memory Manager not loaded');
  GetMem(LeakyMemory, 1000);
  FClearVarsInTearDown := False;
end;

procedure TMemMonitorMemAllocLeakHandling.CheckMemManagerNoLeaks1;
begin
  Check(MemManagerLoaded, 'Memory Manager not loaded');
  GetMem(LeakyMemory, 1000);
  FClearVarsInTearDown := True;
end;

procedure TMemMonitorMemAllocLeakHandling.CheckMemManagerNoLeaks2;
begin
  CheckMemManagerNoLeaks1;
end;

procedure TMemMonitorMemAllocLeakHandling.CheckMemManagerNoLeaks3;
begin
  CheckMemManagerNoLeaks1;
end;

procedure TMemMonitorMemAllocLeakHandling.CheckMemManagerNoLeaks4;
begin
  CheckMemManagerNoLeaks1;
end;

procedure TMemMonitorMemAllocLeakHandling.SetUp;
begin
  inherited;
  ClearVars;
  FClearVarsInTearDown := True;
end;

procedure TMemMonitorMemAllocLeakHandling.TearDown;
begin
  inherited;
  if FClearVarsInTearDown then
    ClearVars;
end;

{ TMemMonitorGetErrorMessage }

procedure TMemMonitorGetErrorMessage.SetUp;
begin
  inherited;
  ClearVars;
  MLM := nil;
end;

procedure TMemMonitorGetErrorMessage.TearDown;
begin
  inherited;
  try
    ClearVars;
  finally
    MLM := nil;
  end;
end;

procedure TMemMonitorGetErrorMessage.CheckGetMemoryUseMsgOK;
var
  LErrorStr: string;
  LStatus: boolean;
begin
  MLM := MemLeakMonitor;
  LStatus := MLM.GetMemoryUseMsg(False, 0, LErrorStr);
  Check(LStatus, 'LStatus should be True');
  Check(LErrorStr = '', 'Simple Test String should be empty but = ' + LErrorStr);

  LStatus := MLM.GetMemoryUseMsg(True, 0, LErrorStr);
  Check(LStatus, 'LStatus should be True');
  Check(LErrorStr = '', 'Simple Test String should be empty but = ' + LErrorStr);

end;

procedure TMemMonitorGetErrorMessage.CheckGetRecoveredMemMsg;
var
  LErrorStr: string;
  LStatus: boolean;
begin
  MLM := MemLeakMonitor;
  LStatus := MLM.GetMemoryUseMsg(False, -1, LErrorStr);
  Check(LStatus, 'LStatus should be True');
  Check(LErrorStr = '', 'Simple Test string should be empty');

end;

procedure TMemMonitorGetErrorMessage.CheckGetAllowedRecoveredMemMsg;
var
  LErrorStr: string;
  LStatus: boolean;
begin
  MLM := MemLeakMonitor;
  LStatus := MLM.GetMemoryUseMsg(True, -1, LErrorStr);
  Check(not LStatus, 'LStatus should be False');
  Check(LErrorStr <> '', 'Simple Test string should not be empty');
  Check(LErrorStr = '1 Bytes Memory Recovered in Test Procedure',
   ' Error String reads <' + LErrorStr +
   '> but should read  <1 Bytes Memory Recovered in Test Procedure>');

end;

procedure TMemMonitorGetErrorMessage.CheckGetLeakedMemMsg;
var
  LErrorStr: string;
  LStatus: boolean;
begin
  MLM := MemLeakMonitor;
  LStatus := MLM.GetMemoryUseMsg(False, 1, LErrorStr);
  Check(not LStatus, 'LStatus should be False');
  Check(LErrorStr = '1 Bytes Memory Leak in Test Procedure',
   ' Error String reads <' + LErrorStr +
   '> but should read  <1 Bytes Memory Leak in Test Procedure>');

  LStatus := MLM.GetMemoryUseMsg(True, 1, LErrorStr);
  Check(not LStatus, 'LStatus should be False');
  Check(LErrorStr = '1 Bytes Memory Leak in Test Procedure',
   ' Error String reads <' + LErrorStr +
   '> but should read  <1 Bytes Memory Leak in Test Procedure>');

end;

function TBasicMemMonitor.Leaks: Integer;
begin
  if FLeakListIndex >= Length(FLeakList) then
    result := 0
  else
  begin
    result := FLeakList[FLeakListIndex];
    inc(FLeakListIndex);
  end;
end;

procedure TBasicMemMonitor.SetLeakList(const ListOfLeaks: array of Integer);
var
  i: Integer;
begin
  for i := 0 to Length(FLeakList) - 1 do    // Iterate
  begin
    if i < Length(ListOfLeaks) then
      FLeakList[i] := ListOfLeaks[i]
    else
      FLeakList[i] := 0;
  end;    // for
  FLeakListIndex := 0;
end;

{ TMemMonitorGetErrorMessageNew }

procedure TMemMonitorGetErrorMessageNew.SetUp;
begin
  inherited;
  ClearVars;
  MLM := nil;
end;

procedure TMemMonitorGetErrorMessageNew.TearDown;
begin
  inherited;
  try
    ClearVars;
  finally
    MLM := nil;
  end;
end;

procedure TMemMonitorGetErrorMessageNew.CheckSumOfLeaks;
var
  LErrorStr: string;
  LStatus: boolean;
begin
  MLM := MemLeakMonitor;

  LStatus := MLM.GetMemoryUseMsg(False, 0, 0, 0, 1, LErrorStr);
  Check(not LStatus, 'LStatus should be False');
  Check(LErrorStr =
    ('Error in TestFrameWork. No leaks in Setup, TestProc or Teardown but '+
    '1 Bytes Memory Leak reported across TestCase'), 'LErrorStr = ' + LErrorStr);

  LStatus := MLM.GetMemoryUseMsg(False, 1, 2, 3, 1, LErrorStr);
  Check(not LStatus, 'LStatus should be False');
  Check(LErrorStr =
    ('Error in TestFrameWork. Sum of Setup, TestProc and Teardown leaks <> '+
    '1 Bytes Memory Leak reported across TestCase'), 'LErrorStr = ' + LErrorStr);
end;

procedure TMemMonitorGetErrorMessageNew.CheckGetMemoryUseMsgOK;
var
  LErrorStr: string;
  LStatus: boolean;
begin
  MLM := MemLeakMonitor;

  LStatus := MLM.GetMemoryUseMsg(False, 0, 0, 0, 0, LErrorStr);
  Check(LStatus, 'LStatus should be True');
  Check(LErrorStr = '', 'Complete Test String should be empty but = ' + LErrorStr);

  LStatus := MLM.GetMemoryUseMsg(True, 0, 0, 0, 0, LErrorStr);
  Check(LStatus, 'LStatus should be True');
  Check(LErrorStr = '', 'Complete Test String should be empty but = ' + LErrorStr);
end;

procedure TMemMonitorGetErrorMessageNew.CheckGetRecoveredMemMsg;
var
  LErrorStr: string;
  LStatus: boolean;
begin
  MLM := MemLeakMonitor;

  LStatus := MLM.GetMemoryUseMsg(False, -1, 0, 0, -1, LErrorStr);
  Check(LStatus, 'LStatus should be True. ErrorMessage =' + LErrorStr);
  Check(LErrorStr = '', 'Complete Test String should be empty but = ' + LErrorStr);

  LStatus := MLM.GetMemoryUseMsg(False,  0, -1, 0, -1, LErrorStr);
  Check(LStatus, 'LStatus should be True. ErrorMessage =' + LErrorStr);
  Check(LErrorStr = '', 'Complete Test String should be empty but = ' + LErrorStr);

  LStatus := MLM.GetMemoryUseMsg(False,  0, 0, -1, -1, LErrorStr);
  Check(LStatus, 'LStatus should be True. ErrorMessage =' + LErrorStr);
  Check(LErrorStr = '', 'Complete Test String should be empty but = ' + LErrorStr);

  LStatus := MLM.GetMemoryUseMsg(False, -1, -2, 0, -3, LErrorStr);
  Check(LStatus, 'LStatus should be True. ErrorMessage =' + LErrorStr);
  Check(LErrorStr = '', 'Complete Test String should be empty but = ' + LErrorStr);

  LStatus := MLM.GetMemoryUseMsg(False,  0, -1, -2, -3, LErrorStr);
  Check(LStatus, 'LStatus should be True. ErrorMessage =' + LErrorStr);
  Check(LErrorStr = '', 'Complete Test String should be empty but = ' + LErrorStr);

  LStatus := MLM.GetMemoryUseMsg(False,  -1, -2, -3, -6, LErrorStr);
  Check(LStatus, 'LStatus should be True. ErrorMessage =' + LErrorStr);
  Check(LErrorStr = '', 'Complete Test String should be empty but = ' + LErrorStr);

  LStatus := MLM.GetMemoryUseMsg(True, -1, 0, 0, -1, LErrorStr);
  Check(not LStatus, 'LStatus should be False');
  Check(LErrorStr = '-1 Bytes memory recovered  (Setup= -1  )',
    'ErrorMsg should read <-1 Bytes memory recovered  (Setup= -1  )>'+
    ' but was <' + LErrorStr + '>');

  LStatus := MLM.GetMemoryUseMsg(True, 0, -1, 0, -1, LErrorStr);
  Check(not LStatus, 'LStatus should be False');
  Check(LErrorStr = '-1 Bytes memory recovered  (' +
    'TestProc= -1  )',
    'ErrorMsg should read <-1 Bytes memory recovered   (TestProc= -1  )>' +
    ' but was <' + LErrorStr + '>');

  LStatus := MLM.GetMemoryUseMsg(True, 0, 0, -1, -1, LErrorStr);
  Check(not LStatus, 'LStatus should be False');
  Check(LErrorStr = '-1 Bytes memory recovered  (' +
    'TearDown= -1  )',
    'ErrorMsg should read <-1 Bytes memory recovered  (TearDown= -1  )>'+
    ' but was <' + LErrorStr + '>');

  LStatus := MLM.GetMemoryUseMsg(True, -1, -2, -3, -6, LErrorStr);
  Check(not LStatus, 'LStatus should be False');
  Check(LErrorStr = '-6 Bytes memory recovered  (' +
    'Setup= -1  TestProc= -2  TearDown= -3  )',
    'ErrorMsg should read ' +
    '<-6 Bytes memory recovered  (Setup= -1  TestProc= -2  TearDown= -3  )>' +
    ' but was <' + LErrorStr + '>');
end;

procedure TMemMonitorGetErrorMessageNew.CheckGetLeakedMemMsg;
var
  LErrorStr: string;
  LStatus: boolean;
begin
  MLM := MemLeakMonitor;

  LStatus := MLM.GetMemoryUseMsg(False, 0, 0, 0, 0, LErrorStr);
  Check(LStatus, 'LStatus should be True');
  Check(LErrorStr = '', 'Complete Test String should be empty but = ' + LErrorStr);

  LStatus := MLM.GetMemoryUseMsg(False, 1, 0, 0, 1, LErrorStr);
  Check(not LStatus, 'LStatus should be False');
  Check(LErrorStr = '1 Bytes memory leak  (' +
    'Setup= 1  )',
    'ErrorMsg should read <1 Bytes memory leak  (Setup= 1  )' +
    ' but was <' + LErrorStr + '>');

  LStatus := MLM.GetMemoryUseMsg(False, 1, 0, 0, 1, LErrorStr);
  Check(not LStatus, 'LStatus should be False');
  Check(LErrorStr = '1 Bytes memory leak  (' +
    'Setup= 1  )',
    'LErrorMsg should read <1 Bytes memory leak  (Setup=1  )' +
    ' but was <' + LErrorStr + '>');

  LStatus := MLM.GetMemoryUseMsg(False, 0, 1, 0, 1, LErrorStr);
  Check(not LStatus, 'LStatus should be False');
  Check(LErrorStr = '1 Bytes memory leak  (' +
    'TestProc= 1  )',
    'LErrorMsg should read <1 Bytes memory leak  (TestProc= 1  )>' +
    ' but was <' + LErrorStr + '>');

  LStatus := MLM.GetMemoryUseMsg(False, 0, 0, 1, 1, LErrorStr);
  Check(not LStatus, 'LStatus should be False');
  Check(LErrorStr = '1 Bytes memory leak  (' +
    'TearDown= 1  )',
    'LErrorMsg should read <1 Bytes memory leak  (TearDown= 1  )>' +
    ' but was <' + LErrorStr + '>');

  LStatus := MLM.GetMemoryUseMsg(False, 1, 2, 0, 3, LErrorStr);
  Check(not LStatus, 'LStatus should be False');
  Check(LErrorStr = '3 Bytes memory leak  (' +
    'Setup= 1  TestProc= 2  )',
    'LErrorMsg should read <3 Bytes memory leak  (Setup= 1  TestProc= 2  )>' +
    ' but was <' + LErrorStr + '>');

  LStatus := MLM.GetMemoryUseMsg(False, 0, 2, 1, 3, LErrorStr);
  Check(not LStatus, 'LStatus should be False');
  Check(LErrorStr = '3 Bytes memory leak  (' +
    'TestProc= 2  TearDown= 1  )',
    'LErrorMsg should read <3 Bytes memory leak  (TestProc= 2  TearDown= 1  )>' +
    ' but was <' + LErrorStr + '>');

  LStatus := MLM.GetMemoryUseMsg(False, 1, 0, 2, 3, LErrorStr);
  Check(not LStatus, 'LStatus should be False');
  Check(LErrorStr = '3 Bytes memory leak  (' +
    'Setup= 1  TearDown= 2  )',
    'LErrorMsg should read <3 Bytes memory leak  (Setup= 1  TearDown= 2  )>' +
    ' but was <' + LErrorStr + '>');

  LStatus := MLM.GetMemoryUseMsg(False, 1, 2, 3, 6, LErrorStr);
  Check(not LStatus, 'LStatus should be False');
  Check(LErrorStr = '6 Bytes memory leak  (' +
    'Setup= 1  TestProc= 2  TearDown= 3  )',
    'LErrorMsg should read ' +
    '<3 Bytes memory leak  (Setup= 1  TestProc= 2  TearDown= 3  )>' +
    ' but was <' + LErrorStr + '>');

end;

initialization
  Excpt := nil;
  LeakyMemory := nil;
  LeakyString := '';
  ObjectList := nil;

  {$IFDEF SELFTEST}
    RefTestFramework.
  {$ENDIF}
    RegisterTests('TestMemoryMonitor',
                              [TBasicMemMonitor.Suite,
                               TMemMonitorGetErrorMessage.Suite,
                               TMemMonitorGetErrorMessageNew.Suite
                              ]);
end.
