{#(@)$Id$ }
{  DUnit: An XTreme testing framework for Delphi programs. }
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
 * Peter McNab <mcnabp@qmail.com>
 *
 *******************************************************************************
*)
{$IFDEF VER180}
//##  {$DEFINE FASTMM}
{$ENDIF}
{$IFDEF CLR}
  {$UNSAFECODE ON}
  {$UNDEF FASTMM}
{$ENDIF}

unit UnitTestXMLListener;
interface
uses
  Classes,
  {$IFDEF CLR}
    System.Reflection,
  {$ENDIF}
  {$IFDEF SELFTEST}
    RefTestFramework,
  {$ELSE}
    TestFramework,
  {$ENDIF}
  {$IFDEF USE_JEDI_JCL}
    JclDebug,
  {$ENDIF}
  TestFrameworkIfaces,
  TestFrameworkProxyIfaces;

type
  TTDomDocWriteRoot = class(TTestCase)
  private
    FXMLFileName: string;
    FXMLListener: ITestListenerX;
  protected
    procedure SetUpOnce; override;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    {$IFDEF CLR}[Test]{$ENDIF}
    procedure VerifyTDOMDocOpensAndCloses;
  end;

  TTDomDocWriteElements = class(TTestCase)
  private
    FXMLFileName: string;
    FXMLListener: ITestListenerX;
    FXMLFile: Text;
  protected
    procedure SetUpOnce; override;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    {$IFDEF CLR}[Test]{$ENDIF}
    procedure VerifyTestingStarts;
    {$IFDEF CLR}[Test]{$ENDIF}
    procedure VerifyTestingEndsNil;
    {$IFDEF CLR}[Test]{$ENDIF}
    procedure VerifyTestingEnds;
    {$IFDEF CLR}[Test]{$ENDIF}
    procedure VerifyAddSuccessNil;
  end;

  TSingleTest = class(TTestCase)
  published
    procedure ATestProcPasses;
  end;

  TDoubleTest = class(TTestCase)
  published
    procedure TestProc1Passes;
    procedure TestProc2Passes;
  end;

  TTripleTest = class(TTestCase)
  published
    procedure TestProcPasses;
    procedure TestProcFails;
    procedure TestProcExcepts;
  end;

  TXMLListenerListens = class(TTestCase)
  private
    FXMLFileName: string;
//    FXMLListener: ITestListener;
    FXMLFile: Text;
    FProject: ITestProject;
    FExecControl: ITestExecControl;
    FTests: ITestSuiteProxy;
    FTestResult : TTestResult;
  protected
    procedure SetUpOnce; override;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    {$IFDEF CLR}[Test]{$ENDIF}
    procedure VerifyTripleTest;
  end;

implementation
uses
  {$IFDEF VER130}
    D5Support,
  {$ENDIF}
  TypInfo,
  Windows,
  {$IFDEF SELFTEST}
  TestFramework,
  {$ENDIF}
//  ProjectsManager,
  {$IFDEF FASTMM}
     FastMMMonitorTest,
  {$ENDIF}
  RefTestFrameworkProxy,
  TestFrameworkProxy,
  XMLListener,
  xdom,
  SysUtils;

procedure TTDomDocWriteRoot.SetUpOnce;
begin
  FXMLFileName := ChangeFileExt(ParamStr(0),'.xml');
end;

procedure TTDomDocWriteRoot.SetUp;
begin
  FXMLListener := nil;
  if(FileExists(FXMLFileName)) then
    DeleteFile(FXMLFileName);
end;

procedure TTDomDocWriteRoot.TearDown;
begin
  FXMLListener := nil;
end;

procedure TTDomDocWriteRoot.VerifyTDOMDocOpensAndCloses;
begin
  FXMLListener := TXMLListener.Create(ParamStr(0));
  FXMLListener := nil;
  Check(FileExists(FXMLFileName), 'XML file should have been created');
end;

{ TTDomDocWriteElements }

procedure TTDomDocWriteElements.SetUpOnce;
begin
  FXMLFileName := ChangeFileExt(ParamStr(0),'.xml');
end;

procedure TTDomDocWriteElements.SetUp;
begin
  FXMLListener := nil;
  if(FileExists(FXMLFileName)) then
    DeleteFile(FXMLFileName);
  FXMLListener := TXMLListener.Create(ParamStr(0));
end;

procedure TTDomDocWriteElements.TearDown;
begin
  if(FileExists(FXMLFileName)) then
  try
    CloseFile(FXMLFile);
  except
  end;
  FXMLListener := nil;
end;

procedure TTDomDocWriteElements.VerifyTestingStarts;
var
  LLine: string;
  LPos: integer;
begin
  FXMLListener.TestingStarts;
  FXMLListener := nil;

  Check(FileExists(FXMLFileName), 'XML File should now exist');
  AssignFile(FXMLFile, FXMLFileName);
  System.Reset(FXMLFile);
  Append(FXMLFile);
  Writeln(FXMLFile);
  CloseFile(FXMLFile);

  AssignFile(FXMLFile, FXMLFileName);
  System.Reset(FXMLFile);
  Check(not EOF(FXMLFile), 'Should not be an empty file');

  ReadLn(FXMLFile, LLine);
  Check(not EOF(FXMLFile), 'Should not be an empty file');
  CheckEqualsString('<?xml version="1.0" encoding="UTF-8"?>', LLine, '');

  ReadLn(FXMLFile, LLine);
  Check(not EOF(FXMLFile), 'Should not be an empty file');
  CheckEqualsString('<TestResults>', LLine, '');

  ReadLn(FXMLFile, LLine);
  Check(not EOF(FXMLFile), 'Should not be an empty file');
  LPos := Pos('  <!--Generated using DUnit2 on ', LLine);
  Check(LPos = 1, 'Bad comment line = ' + LLine);

  ReadLn(FXMLFile, LLine);
  Check(not EOF(FXMLFile), 'Should not be an empty file');
  CheckEqualsString('  <TestListing></TestListing>', LLine, '');

  ReadLn(FXMLFile, LLine);
  Check(not EOF(FXMLFile), 'Should not be an empty file');
  CheckEqualsString('</TestResults>', LLine, '');

  ReadLn(FXMLFile, LLine);
  Check(EOF(FXMLFile), 'Should now be an empty file');
end;

procedure TTDomDocWriteElements.VerifyTestingEndsNil;
var
  LLine: string;
  LLineCount: integer;
begin
  FXMLListener.TestingEnds(nil);
  FXMLListener := nil;

  Check(FileExists(FXMLFileName), 'XML File should now exist');
  AssignFile(FXMLFile, FXMLFileName);
  System.Reset(FXMLFile);
  Append(FXMLFile);
  Writeln(FXMLFile);
  CloseFile(FXMLFile);

  AssignFile(FXMLFile, FXMLFileName);
  System.Reset(FXMLFile);
  Check(not EOF(FXMLFile), 'Should not be an empty file');

  LLineCount := 0;
  while not EOF(FXMLFile) do
  begin
    ReadLn(FXMLFile, LLine);
    Inc(LLineCount);
  end;
  Check(LLineCount = 5,
    'Line count should be 5 but was ' + IntToStr(LLineCount));
end;

procedure TTDomDocWriteElements.VerifyTestingEnds;
var
  LTestResult: TTestResult;
  LLine: string;
begin
  LTestResult := GetTestResult;
  FXMLListener.TestingStarts;
  FXMLListener.TestingEnds(LTestResult);
  FXMLListener := nil;

  Check(FileExists(FXMLFileName), 'XML File should now exist');
  AssignFile(FXMLFile, FXMLFileName);
  System.Reset(FXMLFile);
  Append(FXMLFile);
  Writeln(FXMLFile);
  CloseFile(FXMLFile);

  AssignFile(FXMLFile, FXMLFileName);
  System.Reset(FXMLFile);
  Check(not EOF(FXMLFile), 'Should not be an empty file');

  ReadLn(FXMLFile, LLine);
  ReadLn(FXMLFile, LLine);
  ReadLn(FXMLFile, LLine);
  ReadLn(FXMLFile, LLine);
  Check(not EOF(FXMLFile), 'Should not be an empty file');
  CheckEqualsString('  <TestListing></TestListing>', LLine, '');

  ReadLn(FXMLFile, LLine);
  Check(not EOF(FXMLFile), 'Should not be an empty file');
  CheckEqualsString('  <Title>Dunit2 XML test report</Title>', LLine, '');

  ReadLn(FXMLFile, LLine);
  Check(not EOF(FXMLFile), 'Should not be an empty file');
  CheckEqualsString('  <NumberOfRunTests>0</NumberOfRunTests>', LLine, '');

  ReadLn(FXMLFile, LLine);
  Check(not EOF(FXMLFile), 'Should not be an empty file');
  CheckEqualsString('  <NumberOfErrors>0</NumberOfErrors>', LLine, '');

  ReadLn(FXMLFile, LLine);
  Check(not EOF(FXMLFile), 'Should not be an empty file');
  CheckEqualsString('  <NumberOfFailures>0</NumberOfFailures>', LLine, '');

  ReadLn(FXMLFile, LLine);
  Check(not EOF(FXMLFile), 'Should not be an empty file');
  CheckEqualsString('  <NumberOfWarnings>0</NumberOfWarnings>', LLine, '');

  ReadLn(FXMLFile, LLine);
  Check(not EOF(FXMLFile), 'Should not be an empty file');
  CheckEqualsString('  <TotalElapsedTime>00:00:00.000</TotalElapsedTime>', LLine, '');
end;

procedure TTDomDocWriteElements.VerifyAddSuccessNil;
var
  LLine: string;
  LLineCount: integer;
begin
  FXMLListener.TestingEnds(nil);
  FXMLListener := nil;

  Check(FileExists(FXMLFileName), 'XML File should now exist');
  AssignFile(FXMLFile, FXMLFileName);
  System.Reset(FXMLFile);
  Append(FXMLFile);
  Writeln(FXMLFile);
  CloseFile(FXMLFile);

  AssignFile(FXMLFile, FXMLFileName);
  System.Reset(FXMLFile);
  Check(not EOF(FXMLFile), 'Should not be an empty file');

  LLineCount := 0;
  while not EOF(FXMLFile) do
  begin
    ReadLn(FXMLFile, LLine);
    Inc(LLineCount);
  end;
  Check(LLineCount = 5,
    'Line count should be 5 but was ' + IntToStr(LLineCount));
end;


{ TSingleTest }

procedure TTripleTest.TestProcExcepts;
begin
  Assert(False, 'Deliberate error');
end;

procedure TTripleTest.TestProcFails;
begin
  Check(False, 'Deliberate failure');
end;

procedure TTripleTest.TestProcPasses;
begin
  Sleep(30);
  Check(True);
end;

{ TSingleTest }

procedure TSingleTest.ATestProcPasses;
begin
  Sleep(30);
  Check(True);
end;

{ TXMLListenerListens }

procedure TXMLListenerListens.SetUpOnce;
begin
  FXMLFileName := ChangeFileExt(ParamStr(0),'.xml');
end;

procedure TXMLListenerListens.SetUp;
begin
  if(FileExists(FXMLFileName)) then
    DeleteFile(FXMLFileName);

  TestFramework.RegisterTests('ASuiteName', [{TSingleTest.Suite,}
                                             TDoubleTest.Suite{,
                                             TTripleTest.Suite}]);
  FTests := TestFrameworkProxy.RegisteredTests;
  FExecControl := TestFramework.Projects.ExecutionControl;
end;

procedure TXMLListenerListens.TearDown;
begin
  FProject := nil;
  FExecControl := nil;
  FTests := nil;

  if(FileExists(FXMLFileName)) then
  try
    CloseFile(FXMLFile);
  except
  end;
end;

procedure TXMLListenerListens.VerifyTripleTest;
begin
  FTestResult := FTests.Run(TXMLListener.Create(ParamStr(0)));
  FTestResult.ReleaseProxyListener;
  Check(FTestResult.RunCount = 6, 'Runcount should be 6 but was ' + IntToStr(FTestResult.RunCount));
  Check(FTestResult.ErrorCount = 1, 'ErrorCount should be 1 but was ' + IntToStr(FTestResult.RunCount));
  Check(FTestResult.FailureCount = 1, 'FailureCount should be 1 but was ' + IntToStr(FTestResult.RunCount));
end;

{ TDoubleTest }

procedure TDoubleTest.TestProc1Passes;
begin
  Sleep(30);
  Check(True);
end;

procedure TDoubleTest.TestProc2Passes;
begin
  Sleep(50);
  Check(True);
end;

initialization
{
  RefTestFramework.
  RegisterTest(TTDomDocWriteRoot.Suite);
  RefTestFramework.
  RegisterTest(TTDomDocWriteElements.Suite);
}
  RefTestFramework.
  RegisterTest(TXMLListenerListens.Suite);
end.
