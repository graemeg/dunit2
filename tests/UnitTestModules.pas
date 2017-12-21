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
 * Peter McNab <mcnabp@gmail.com>
 *
 *******************************************************************************
*)

unit UnitTestModules;

{$I DUnit.inc}

{$IFNDEF SELFTEST}
  '!!!Alert SELFTEST must be defined'
{$ENDIF}

interface

uses
  TestFrameworkIfaces
  ,RefTestFramework
  ;

type
  TTwoTests = class(TTestCase)
  published
    procedure RunsAndPasses;
    procedure RunsAndWarns;
  end;

  TStatusArray = array[Ord(Low(TExecutionStatus))..Ord(High(TExecutionStatus))] of Integer;

  TTestProjectAndDLLOrderIndependence = class(TTestCase)
  private
    FTestProject: ITestProject;
    FMethodCallbackCount: Integer;
    FTopLevelProjectCount: Integer;
    FIndividualProjectCount: Integer;
    FTestSuiteCount: Integer;
    FTestCaseCount: Integer;
    FStatusArray: TStatusArray;
    FCallBackStatusStrs: array of string;
    FTotalCallbacks: Integer;
    FLogFileOpen: Boolean;
    FLogFile: Text;
    FLogFileName: string;
    FIndex: Integer;
    procedure ExecStatusCallBack1(const ATest: ITest);
  protected
    procedure SetUpOnce; override;
    procedure SetUp; override;
    procedure TearDown; override;

  published
    procedure LoadsAndUnloadsModuleTests;
    procedure LoadsAndRunsDLLTestSuite;
    procedure LoadsAndRunsDLLProject;
    procedure CountsTestsAndTestsRunInProjectsThenDLL;
    procedure CountsTestsAndTestsRunInDLLThenProjects;
    procedure OnRunProjectsThenDLLReportsMinimally;
    procedure OnRunDLLThenProjectsReportsMinimally;
  end;

implementation
uses
  Windows, // for Deletefile
  SysUtils,
  {$IFDEF VER130}
    D5Support,
  {$ENDIF}
  ProjectsManagerIface,
  TestFramework,
  TestModules,
  XPVistaSupport,
  TypInfo;


procedure RemoveProjectManager;
begin
  TestFramework.UnRegisterProjectManager;
end;

{ TTwoTests }

procedure TTwoTests.RunsAndPasses;
begin
  Check(True); // Produces _Passed
end;

procedure TTwoTests.RunsAndWarns;
begin
  Sleep(10);   //Produces _Warning because there are no calls to Check()
end;

{ TTestModuleLoads }
const
  LogFile = 'UnitTestModules.log';

procedure TTestProjectAndDLLOrderIndependence.SetUpOnce;
begin
  FLogFileName := LocalAppDataPath + LogFile;
  if FileExists(LogFile) then
    DeleteFile(LogFile);
  Assign(FLogFile, FLogFileName);
end;

procedure TTestProjectAndDLLOrderIndependence.SetUp;
var
  idx: Integer;
begin
  FTestProject := nil;
  FTopLevelProjectCount := 0;
  FIndividualProjectCount := 0;
  FTestSuiteCount := 0;
  FTestCaseCount := 0;
  FMethodCallbackCount := 0;
  FTotalCallbacks := 0;
  FIndex := 0;
  for idx := Ord(Low(TExecutionStatus)) to Ord(High(TExecutionStatus)) do
    FStatusArray[idx] := 0;
  SetLength(FCallBackStatusStrs,0);
  try
    Rewrite(FLogFile);
    FLogFileOpen := True;
  except
  end;
end;

procedure TTestProjectAndDLLOrderIndependence.TearDown;
begin
  SetLength(FCallBackStatusStrs,0);
  FTestProject := nil;
  RemoveProjectManager;
  TestModules.UnloadTestModules;
  if FLogFileOpen then
  try
    CloseFile(FLogFile);
  except
  end;
  FLogFileOpen := False;
  DeleteFile(FLogFileName);
end;


procedure TTestProjectAndDLLOrderIndependence.LoadsAndUnloadsModuleTests;
var
  LDLLFileName: string;
begin
  LDLLFileName := ExtractFilePath(ParamStr(0)) + 'MiniTestLibW32A.dtl';
  Check(FileExists(LDLLFileName), 'Cannot find MiniTestLibW32A.dtl');
  FTestProject := LoadModuleTests(LDLLFileName);
  Check(Assigned(FTestProject), 'FTestProjet not assigned');
  FTestProject := nil;
end;

procedure TTestProjectAndDLLOrderIndependence.LoadsAndRunsDLLTestSuite;
var
  LDLLFileName: string;
  LStatus: TExecutionStatus;
  LCount: Integer;
  LExecControl: ITestExecControl;
begin
  LDLLFileName := ExtractFilePath(ParamStr(0)) + 'MiniTestLibW32A.dtl';
  Check(FileExists(LDLLFileName), 'Cannot find MiniTestLibW32A.dtl');
  FTestProject := TestModules.LoadModuleTests(LDLLFileName);
  Check(Assigned(FTestProject), 'FTestProjet not assigned');
  LExecControl := TestFramework.TestExecControl;
  LExecControl.InhibitStackTrace := True;
  LCount := FTestProject.Count;
  Check(LCount = 4, 'Count should be 4 but is ' + IntToStr(LCount));
  LStatus := FTestProject.Run(LExecControl);
  Check(LStatus = _Passed, 'Status should be _Passed but was ' +
    GetEnumName(TypeInfo(TExecutionStatus), Ord(LStatus)));
  LCount := LExecControl.ExecutionCount;
  Check(LCount = 4, 'Execution Count should be 4 but is ' + IntToStr(LCount));
end;

procedure TTestProjectAndDLLOrderIndependence.LoadsAndRunsDLLProject;
var
  LDLLFileName: string;
  LStatus: TExecutionStatus;
  LCount: Integer;
  LExecControl: ITestExecControl;
begin
  LDLLFileName := ExtractFilePath(ParamStr(0)) + 'MiniTestLibW32A.dtl';
  Check(FileExists(LDLLFileName), 'Cannot find MiniTestLibW32A.dtl');
  TestModules.RegisterModuleTests(LDLLFileName);
  FTestProject := TestFramework.Projects;
  Check(Assigned(FTestProject), 'FTestProjet not assigned');
  LExecControl := TestFramework.TestExecControl;
  LExecControl.InhibitStackTrace := True;
  LCount := FTestProject.Count;
  Check(LCount = 4, 'Count should be 4 but is ' + IntToStr(LCount));
  LStatus := FTestProject.Run(LExecControl);
  Check(LStatus = _Passed, 'Status should be _Passed but was ' +
    GetEnumName(TypeInfo(TExecutionStatus), Ord(LStatus)));
  LCount := LExecControl.ExecutionCount;
  Check(LCount = 4, 'Execution Count should be 4 but is ' + IntToStr(LCount));
end;

procedure TTestProjectAndDLLOrderIndependence.CountsTestsAndTestsRunInProjectsThenDLL;
var
  LDLLFileName: string;
  LStatus: TExecutionStatus;
  LCount: Integer;
  LExecControl: ITestExecControl;
begin
  //Register a total of 2 + 2 + 2 + 4(in DLL) tests = 10.
  TestFramework.RegisterTest(TTwoTests.Suite); // Becomes Default Project
  TestFramework.RegisterTest('AsTestSuite', TTwoTests.Suite); // Becomes test suite within Default Project
  TestFramework.ProjectRegisterTest('AProject', TTwoTests.Suite); // Becomes separate project
  LDLLFileName := ExtractFilePath(ParamStr(0)) + 'MiniTestLibW32A.dtl';
  Check(FileExists(LDLLFileName), 'Cannot find MiniTestLibW32A.dtl');
  TestModules.RegisterModuleTests(LDLLFileName);

  FTestProject := TestFramework.Projects;
  Check(Assigned(FTestProject), 'FTestProjet not assigned');
  LExecControl := TestFramework.TestExecControl;
  LExecControl.InhibitStackTrace := True;
  LCount := FTestProject.Count;
  Check(LCount = 10, 'Count should be 10 but is ' + IntToStr(LCount));
  LStatus := FTestProject.Run(LExecControl);
  Check(LStatus = _Warning, 'Status should be _Warning but was ' +
    GetEnumName(TypeInfo(TExecutionStatus), Ord(LStatus)));
  LCount := LExecControl.EnabledCount;
  Check(LCount = 10, 'Enabled count should be 10 but is ' + IntToStr(LCount));
  LCount := LExecControl.ExecutionCount;
  Check(LCount = 10, 'Execution count should be 10 but is ' + IntToStr(LCount));
  LCount := LExecControl.WarningCount;
  Check(LCount = 3, 'Warning count should be 3 but is ' + IntToStr(LCount));
end;

procedure TTestProjectAndDLLOrderIndependence.CountsTestsAndTestsRunInDLLThenProjects;
var
  LDLLFileName: string;
  LStatus: TExecutionStatus;
  LCount: Integer;
  LExecControl: ITestExecControl;
begin
  LDLLFileName := ExtractFilePath(ParamStr(0)) + 'MiniTestLibW32A.dtl';
  Check(FileExists(LDLLFileName), 'Cannot find MiniTestLibW32A.dtl');
  TestModules.RegisterModuleTests(LDLLFileName);
  TestFramework.RegisterTest('AsTestSuite', TTwoTests.Suite); // Becomes test suite within Default Project
  TestFramework.ProjectRegisterTest('AProject', TTwoTests.Suite); // Becomes separate project
  TestFramework.RegisterTest(TTwoTests.Suite); // Becomes Default Project
  //We have registered a total of 4(in DLL) + 2 + 2 + 2  tests = 10.

  FTestProject := TestFramework.Projects;
  Check(Assigned(FTestProject), 'FTestProjet not assigned');
  LExecControl := TestFramework.TestExecControl;
  LExecControl.InhibitStackTrace := True;
  LCount := FTestProject.Count;
  Check(LCount = 10, 'Count should be 10 but is ' + IntToStr(LCount));
  LStatus := FTestProject.Run(LExecControl);
  Check(LStatus = _Warning, 'Status should be _Warning but was ' +
    GetEnumName(TypeInfo(TExecutionStatus), Ord(LStatus)));
  LCount := LExecControl.EnabledCount;
  Check(LCount = 10, 'Enabled count should be 10 but is ' + IntToStr(LCount));
  LCount := LExecControl.ExecutionCount;
  Check(LCount = 10, 'Execution count should be 10 but is ' + IntToStr(LCount));
  LCount := LExecControl.WarningCount;
  Check(LCount = 3, 'Warning count should be 3 but is ' + IntToStr(LCount));
end;

procedure TTestProjectAndDLLOrderIndependence.ExecStatusCallBack1(const ATest: ITest);
var
  Line: string;
begin
  if FLogFileOpen then
  try
    if (ATest <> nil) and Supports(ATest, ITest) then
    begin
      Line := IntToStr(FIndex) + ',';
      if FIndex < 10 then
        Line := Line + ' ';
      Writeln(FLogFile, Line + ' ' +
                        IntToStr((ATest as ITest).Depth) + ',' +
                        GetEnumName(TypeInfo(TExecutionStatus), Ord((ATest as ITest).ExecStatus))  + ',' +
                        (ATest as ITest).ParentPath + ',' +
                        (ATest as ITest).DisplayedName);
      Inc(FIndex);
   end
    else
      Writeln(FLogFile, '-1,,,');
  except
    FLogFileOpen := False;
  end;
end;

procedure TTestProjectAndDLLOrderIndependence.OnRunProjectsThenDLLReportsMinimally;
var
  LDLLFileName: string;
  LStatus: TExecutionStatus;
  LCount: Integer;
  LExeName: string;
  LRawText: string;
  LExecControl: ITestExecControl;
begin
  LExeName := ExtractFileName(ParamStr(0));
  TestFramework.RegisterTest(TTwoTests.Suite); // Becomes Default Project
  TestFramework.RegisterTest('AsTestSuite', TTwoTests.Suite); // Becomes test suite within Default Project
  TestFramework.ProjectRegisterTest('AProject', TTwoTests.Suite); // Becomes separate project
  LDLLFileName := ExtractFilePath(ParamStr(0)) + 'MiniTestLibW32A.dtl';
  Check(FileExists(LDLLFileName), 'Cannot find MiniTestLibW32A.dtl');
  TestModules.RegisterModuleTests(LDLLFileName);
  //We have registered a total of 2 + 2 + 2 + 4(in DLL) tests = 10.

  FTestProject := TestFramework.Projects;
  Check(Assigned(FTestProject), 'FTestProjet not assigned');
  LCount := FTestProject.Count;
  Check(LCount = 10, 'Count should be 10 but was ' + IntToStr(LCount));
  LExecControl := TestFramework.TestExecControl;
  LExecControl.InhibitStackTrace := True;
  LExecControl.ExecStatusUpdater := ExecStatusCallBack1;
  LStatus := FTestProject.Run(LExecControl);
  Check(LStatus = _Warning, 'Status should be _Warning but was ' +
    GetEnumName(TypeInfo(TExecutionStatus), Ord(LStatus)));

  LCount := LExecControl.EnabledCount;
  Check(LCount = 10, 'Enabled count should be 10 but was ' + IntToStr(LCount));
  LCount := LExecControl.ExecutionCount;
  Check(LCount = 10, 'Execution count should be 10 but was ' + IntToStr(LCount));
  LCount := LExecControl.WarningCount;
  Check(LCount = 3, 'Warning count should be 3 but was ' + IntToStr(LCount));

  Check(FLogFileOpen, 'LogFile was not opened');
  CloseFile(FLogFile);
  Assign(FLogFile, FLogFileName);
  System.Reset(FLogFile);
  while not EOF(FLogFile) do
  begin
    ReadLn(FLogFile, LRawText);
    LRawText := StringReplace(LRawText, LExeName, 'ExeName', [rfReplaceAll, rfIgnoreCase]);
    LRawText := StringReplace(LRawText, DefaultProject, 'DefaultProject', [rfReplaceAll, rfIgnoreCase]);
    SetLength(FCallBackStatusStrs, Length(FCallBackStatusStrs) + 1);
    FCallBackStatusStrs[Length(FCallBackStatusStrs)-1] := LRawText;
  end;
  Check(Length(FCallBackStatusStrs) > 0, 'No strings read from logfile');

  Check(FCallBackStatusStrs[ 0]= '0,  0,_Running,,ExeName',                                                   FCallBackStatusStrs[ 0]);
  Check(FCallBackStatusStrs[ 1]= '1,  1,_Running,ExeName,DefaultProject',                                     FCallBackStatusStrs[ 1]);
  Check(FCallBackStatusStrs[ 2]= '2,  2,_Running,ExeName.DefaultProject,TTwoTests',                           FCallBackStatusStrs[ 2]);
  Check(FCallBackStatusStrs[ 3]= '3,  3,_Running,ExeName.DefaultProject.TTwoTests,RunsAndPasses',             FCallBackStatusStrs[ 3]);
  Check(FCallBackStatusStrs[ 4]= '4,  3,_Passed,ExeName.DefaultProject.TTwoTests,RunsAndPasses',              FCallBackStatusStrs[ 4]);
  Check(FCallBackStatusStrs[ 5]= '5,  3,_Running,ExeName.DefaultProject.TTwoTests,RunsAndWarns',              FCallBackStatusStrs[ 5]);
  Check(FCallBackStatusStrs[ 6]= '6,  3,_Warning,ExeName.DefaultProject.TTwoTests,RunsAndWarns',              FCallBackStatusStrs[ 6]);
  Check(FCallBackStatusStrs[ 7]= '7,  2,_Warning,ExeName.DefaultProject,TTwoTests',                           FCallBackStatusStrs[ 7]);
  Check(FCallBackStatusStrs[ 8]= '8,  2,_Running,ExeName.DefaultProject,AsTestSuite',                         FCallBackStatusStrs[ 8]);
  Check(FCallBackStatusStrs[ 9]= '9,  3,_Running,ExeName.DefaultProject.AsTestSuite,TTwoTests',               FCallBackStatusStrs[ 9]);
  Check(FCallBackStatusStrs[10]= '10, 4,_Running,ExeName.DefaultProject.AsTestSuite.TTwoTests,RunsAndPasses', FCallBackStatusStrs[10]);
  Check(FCallBackStatusStrs[11]= '11, 4,_Passed,ExeName.DefaultProject.AsTestSuite.TTwoTests,RunsAndPasses',  FCallBackStatusStrs[11]);
  Check(FCallBackStatusStrs[12]= '12, 4,_Running,ExeName.DefaultProject.AsTestSuite.TTwoTests,RunsAndWarns',  FCallBackStatusStrs[12]);
  Check(FCallBackStatusStrs[13]= '13, 4,_Warning,ExeName.DefaultProject.AsTestSuite.TTwoTests,RunsAndWarns',  FCallBackStatusStrs[13]);
  Check(FCallBackStatusStrs[14]= '14, 3,_Warning,ExeName.DefaultProject.AsTestSuite,TTwoTests',               FCallBackStatusStrs[14]);
  Check(FCallBackStatusStrs[15]= '15, 2,_Warning,ExeName.DefaultProject,AsTestSuite',                         FCallBackStatusStrs[15]);
  Check(FCallBackStatusStrs[16]= '16, 1,_Warning,ExeName,DefaultProject',                                     FCallBackStatusStrs[16]);

  Check(FCallBackStatusStrs[17]= '17, 1,_Running,ExeName,AProject',                                           FCallBackStatusStrs[17]);
  Check(FCallBackStatusStrs[18]= '18, 2,_Running,ExeName.AProject,TTwoTests',                                 FCallBackStatusStrs[18]);
  Check(FCallBackStatusStrs[19]= '19, 3,_Running,ExeName.AProject.TTwoTests,RunsAndPasses',                   FCallBackStatusStrs[19]);
  Check(FCallBackStatusStrs[20]= '20, 3,_Passed,ExeName.AProject.TTwoTests,RunsAndPasses',                    FCallBackStatusStrs[20]);
  Check(FCallBackStatusStrs[21]= '21, 3,_Running,ExeName.AProject.TTwoTests,RunsAndWarns',                    FCallBackStatusStrs[21]);
  Check(FCallBackStatusStrs[22]= '22, 3,_Warning,ExeName.AProject.TTwoTests,RunsAndWarns',                    FCallBackStatusStrs[22]);
  Check(FCallBackStatusStrs[23]= '23, 2,_Warning,ExeName.AProject,TTwoTests',                                 FCallBackStatusStrs[23]);
  Check(FCallBackStatusStrs[24]= '24, 1,_Warning,ExeName,AProject',                                           FCallBackStatusStrs[24]);

  Check(FCallBackStatusStrs[25]= '25, 1,_Running,ExeName,MiniTestLibW32A.dtl',                                FCallBackStatusStrs[25]);
  Check(FCallBackStatusStrs[26]= '26, 2,_Running,ExeName.MiniTestLibW32A.dtl,TwoTestCases',                   FCallBackStatusStrs[26]);
  Check(FCallBackStatusStrs[27]= '27, 3,_Running,ExeName.MiniTestLibW32A.dtl.TwoTestCases,TTestSuite1',       FCallBackStatusStrs[27]);
  Check(FCallBackStatusStrs[28]= '28, 4,_Running,ExeName.MiniTestLibW32A.dtl.TwoTestCases.TTestSuite1,Proc1', FCallBackStatusStrs[28]);
  Check(FCallBackStatusStrs[29]= '29, 4,_Passed,ExeName.MiniTestLibW32A.dtl.TwoTestCases.TTestSuite1,Proc1',  FCallBackStatusStrs[29]);
  Check(FCallBackStatusStrs[30]= '30, 4,_Running,ExeName.MiniTestLibW32A.dtl.TwoTestCases.TTestSuite1,Proc2', FCallBackStatusStrs[30]);
  Check(FCallBackStatusStrs[31]= '31, 4,_Passed,ExeName.MiniTestLibW32A.dtl.TwoTestCases.TTestSuite1,Proc2',  FCallBackStatusStrs[31]);
  Check(FCallBackStatusStrs[32]= '32, 3,_Passed,ExeName.MiniTestLibW32A.dtl.TwoTestCases,TTestSuite1',        FCallBackStatusStrs[32]);
  Check(FCallBackStatusStrs[33]= '33, 3,_Running,ExeName.MiniTestLibW32A.dtl.TwoTestCases,TTestSuite2',       FCallBackStatusStrs[33]);
  Check(FCallBackStatusStrs[34]= '34, 4,_Running,ExeName.MiniTestLibW32A.dtl.TwoTestCases.TTestSuite2,ProcA', FCallBackStatusStrs[34]);
  Check(FCallBackStatusStrs[35]= '35, 4,_Passed,ExeName.MiniTestLibW32A.dtl.TwoTestCases.TTestSuite2,ProcA',  FCallBackStatusStrs[35]);
  Check(FCallBackStatusStrs[36]= '36, 4,_Running,ExeName.MiniTestLibW32A.dtl.TwoTestCases.TTestSuite2,ProcB', FCallBackStatusStrs[36]);
  Check(FCallBackStatusStrs[37]= '37, 4,_Passed,ExeName.MiniTestLibW32A.dtl.TwoTestCases.TTestSuite2,ProcB',  FCallBackStatusStrs[37]);
  Check(FCallBackStatusStrs[38]= '38, 3,_Passed,ExeName.MiniTestLibW32A.dtl.TwoTestCases,TTestSuite2',        FCallBackStatusStrs[38]);
  Check(FCallBackStatusStrs[39]= '39, 2,_Passed,ExeName.MiniTestLibW32A.dtl,TwoTestCases',                    FCallBackStatusStrs[39]);
  Check(FCallBackStatusStrs[40]= '40, 1,_Passed,ExeName,MiniTestLibW32A.dtl',                                 FCallBackStatusStrs[40]);
  Check(FCallBackStatusStrs[41]= '41, 0,_Warning,,ExeName',                                                   FCallBackStatusStrs[41]);
end;

procedure TTestProjectAndDLLOrderIndependence.OnRunDLLThenProjectsReportsMinimally;
var
  LDLLFileName: string;
  LStatus: TExecutionStatus;
  LCount: Integer;
  LExeName: string;
  LRawText: string;
  LExecControl: ITestExecControl;
begin
  LExeName := ExtractFileName(ParamStr(0));
  LDLLFileName := ExtractFilePath(ParamStr(0)) + 'MiniTestLibW32A.dtl';
  Check(FileExists(LDLLFileName), 'Cannot find MiniTestLibW32A.dtl');
  TestModules.RegisterModuleTests(LDLLFileName);
  TestFramework.RegisterTest('AsTestSuite', TTwoTests.Suite); // Becomes Default Project
  TestFramework.ProjectRegisterTest('AProject', TTwoTests.Suite); // Becomes separate project
  TestFramework.RegisterTest(TTwoTests.Suite); // Becomes test within Default Project
  //We have registered a total of 4(in DLL) + 2 + 2 + 2  tests = 10.

  FTestProject := TestFramework.Projects;
  Check(Assigned(FTestProject), 'FTestProjet not assigned');
  LCount := FTestProject.Count;
  Check(LCount = 10, 'Count should be 10 but was ' + IntToStr(LCount));
  LExecControl := TestFramework.TestExecControl;
  LExecControl.InhibitStackTrace := True;
  LExecControl.ExecStatusUpdater := ExecStatusCallBack1;
  LStatus := FTestProject.Run(LExecControl);
  Check(LStatus = _Warning, 'Status should be _Warning but was ' +
    GetEnumName(TypeInfo(TExecutionStatus), Ord(LStatus)));

  LCount := LExecControl.EnabledCount;
  Check(LCount = 10, 'Enabled count should be 10 but was ' + IntToStr(LCount));
  LCount := LExecControl.ExecutionCount;
  Check(LCount = 10, 'Execution count should be 10 but was ' + IntToStr(LCount));
  LCount := LExecControl.WarningCount;
  Check(LCount = 3, 'Warning count should be 3 but was ' + IntToStr(LCount));

  Check(FLogFileOpen, 'LogFile was not opened');
  CloseFile(FLogFile);
  Assign(FLogFile, FLogFileName);
  System.Reset(FLogFile);
  while not EOF(FLogFile) do
  begin
    ReadLn(FLogFile, LRawText);
    LRawText := StringReplace(LRawText, LExeName, 'ExeName', [rfReplaceAll, rfIgnoreCase]);
    LRawText := StringReplace(LRawText, DefaultProject, 'DefaultProject', [rfReplaceAll, rfIgnoreCase]);
    SetLength(FCallBackStatusStrs, Length(FCallBackStatusStrs) + 1);
    FCallBackStatusStrs[Length(FCallBackStatusStrs)-1] := LRawText;
  end;
  Check(Length(FCallBackStatusStrs) > 0, 'No strings read from logfile');

  Check(FCallBackStatusStrs[ 0]= '0,  0,_Running,,ExeName',                                                     FCallBackStatusStrs[ 0]);
  Check(FCallBackStatusStrs[ 1]= '1,  1,_Running,ExeName,MiniTestLibW32A.dtl',                                  FCallBackStatusStrs[ 1]);
  Check(FCallBackStatusStrs[ 2]= '2,  2,_Running,ExeName.MiniTestLibW32A.dtl,TwoTestCases',                     FCallBackStatusStrs[ 2]);
  Check(FCallBackStatusStrs[ 3]= '3,  3,_Running,ExeName.MiniTestLibW32A.dtl.TwoTestCases,TTestSuite1',         FCallBackStatusStrs[ 3]);
  Check(FCallBackStatusStrs[ 4]= '4,  4,_Running,ExeName.MiniTestLibW32A.dtl.TwoTestCases.TTestSuite1,Proc1',   FCallBackStatusStrs[ 4]);
  Check(FCallBackStatusStrs[ 5]= '5,  4,_Passed,ExeName.MiniTestLibW32A.dtl.TwoTestCases.TTestSuite1,Proc1',    FCallBackStatusStrs[ 5]);
  Check(FCallBackStatusStrs[ 6]= '6,  4,_Running,ExeName.MiniTestLibW32A.dtl.TwoTestCases.TTestSuite1,Proc2',   FCallBackStatusStrs[ 6]);
  Check(FCallBackStatusStrs[ 7]= '7,  4,_Passed,ExeName.MiniTestLibW32A.dtl.TwoTestCases.TTestSuite1,Proc2',    FCallBackStatusStrs[ 7]);
  Check(FCallBackStatusStrs[ 8]= '8,  3,_Passed,ExeName.MiniTestLibW32A.dtl.TwoTestCases,TTestSuite1',          FCallBackStatusStrs[ 8]);
  Check(FCallBackStatusStrs[ 9]= '9,  3,_Running,ExeName.MiniTestLibW32A.dtl.TwoTestCases,TTestSuite2',         FCallBackStatusStrs[ 9]);
  Check(FCallBackStatusStrs[10]= '10, 4,_Running,ExeName.MiniTestLibW32A.dtl.TwoTestCases.TTestSuite2,ProcA',   FCallBackStatusStrs[10]);
  Check(FCallBackStatusStrs[11]= '11, 4,_Passed,ExeName.MiniTestLibW32A.dtl.TwoTestCases.TTestSuite2,ProcA',    FCallBackStatusStrs[11]);
  Check(FCallBackStatusStrs[12]= '12, 4,_Running,ExeName.MiniTestLibW32A.dtl.TwoTestCases.TTestSuite2,ProcB',   FCallBackStatusStrs[12]);
  Check(FCallBackStatusStrs[13]= '13, 4,_Passed,ExeName.MiniTestLibW32A.dtl.TwoTestCases.TTestSuite2,ProcB',    FCallBackStatusStrs[13]);
  Check(FCallBackStatusStrs[14]= '14, 3,_Passed,ExeName.MiniTestLibW32A.dtl.TwoTestCases,TTestSuite2',          FCallBackStatusStrs[14]);
  Check(FCallBackStatusStrs[15]= '15, 2,_Passed,ExeName.MiniTestLibW32A.dtl,TwoTestCases',                      FCallBackStatusStrs[15]);
  Check(FCallBackStatusStrs[16]= '16, 1,_Passed,ExeName,MiniTestLibW32A.dtl',                                   FCallBackStatusStrs[16]);

  Check(FCallBackStatusStrs[17]= '17, 1,_Running,ExeName,DefaultProject',                                       FCallBackStatusStrs[17]);
  Check(FCallBackStatusStrs[18]= '18, 2,_Running,ExeName.DefaultProject,AsTestSuite',                           FCallBackStatusStrs[18]);
  Check(FCallBackStatusStrs[19]= '19, 3,_Running,ExeName.DefaultProject.AsTestSuite,TTwoTests',                 FCallBackStatusStrs[19]);
  Check(FCallBackStatusStrs[20]= '20, 4,_Running,ExeName.DefaultProject.AsTestSuite.TTwoTests,RunsAndPasses',   FCallBackStatusStrs[20]);
  Check(FCallBackStatusStrs[21]= '21, 4,_Passed,ExeName.DefaultProject.AsTestSuite.TTwoTests,RunsAndPasses',    FCallBackStatusStrs[21]);
  Check(FCallBackStatusStrs[22]= '22, 4,_Running,ExeName.DefaultProject.AsTestSuite.TTwoTests,RunsAndWarns',    FCallBackStatusStrs[22]);
  Check(FCallBackStatusStrs[23]= '23, 4,_Warning,ExeName.DefaultProject.AsTestSuite.TTwoTests,RunsAndWarns',    FCallBackStatusStrs[23]);
  Check(FCallBackStatusStrs[24]= '24, 3,_Warning,ExeName.DefaultProject.AsTestSuite,TTwoTests',                 FCallBackStatusStrs[24]);
  Check(FCallBackStatusStrs[25]= '25, 2,_Warning,ExeName.DefaultProject,AsTestSuite',                           FCallBackStatusStrs[25]);
  Check(FCallBackStatusStrs[26]= '26, 2,_Running,ExeName.DefaultProject,TTwoTests',                             FCallBackStatusStrs[26]);
  Check(FCallBackStatusStrs[27]= '27, 3,_Running,ExeName.DefaultProject.TTwoTests,RunsAndPasses',               FCallBackStatusStrs[27]);
  Check(FCallBackStatusStrs[28]= '28, 3,_Passed,ExeName.DefaultProject.TTwoTests,RunsAndPasses',                FCallBackStatusStrs[28]);
  Check(FCallBackStatusStrs[29]= '29, 3,_Running,ExeName.DefaultProject.TTwoTests,RunsAndWarns',                FCallBackStatusStrs[29]);
  Check(FCallBackStatusStrs[30]= '30, 3,_Warning,ExeName.DefaultProject.TTwoTests,RunsAndWarns',                FCallBackStatusStrs[30]);
  Check(FCallBackStatusStrs[31]= '31, 2,_Warning,ExeName.DefaultProject,TTwoTests',                             FCallBackStatusStrs[31]);
  Check(FCallBackStatusStrs[32]= '32, 1,_Warning,ExeName,DefaultProject',                                       FCallBackStatusStrs[32]);

  Check(FCallBackStatusStrs[33]= '33, 1,_Running,ExeName,AProject',                                             FCallBackStatusStrs[33]);
  Check(FCallBackStatusStrs[34]= '34, 2,_Running,ExeName.AProject,TTwoTests',                                   FCallBackStatusStrs[34]);
  Check(FCallBackStatusStrs[35]= '35, 3,_Running,ExeName.AProject.TTwoTests,RunsAndPasses',                     FCallBackStatusStrs[35]);
  Check(FCallBackStatusStrs[36]= '36, 3,_Passed,ExeName.AProject.TTwoTests,RunsAndPasses',                      FCallBackStatusStrs[36]);
  Check(FCallBackStatusStrs[37]= '37, 3,_Running,ExeName.AProject.TTwoTests,RunsAndWarns',                      FCallBackStatusStrs[37]);
  Check(FCallBackStatusStrs[38]= '38, 3,_Warning,ExeName.AProject.TTwoTests,RunsAndWarns',                      FCallBackStatusStrs[38]);
  Check(FCallBackStatusStrs[39]= '39, 2,_Warning,ExeName.AProject,TTwoTests',                                   FCallBackStatusStrs[39]);
  Check(FCallBackStatusStrs[40]= '40, 1,_Warning,ExeName,AProject',                                             FCallBackStatusStrs[40]);
  Check(FCallBackStatusStrs[41]= '41, 0,_Warning,,ExeName',                                                     FCallBackStatusStrs[41]);
end;

initialization

 RefTestFramework.
  RegisterTest('Verify MultiProject handling below TestFrameWorkProxy', TTestProjectAndDLLOrderIndependence.Suite);

(*
  // The next 4 are the DLLs used in the above unit tests.
 RefTestModules.
  RegisterModuleTests(ExtractFilePath(ParamStr(0)) + 'MiniTestLibW32A.dtl');

 RefTestModules.
  RegisterModuleTests(ExtractFilePath(ParamStr(0)) + 'MiniTestLibW32B.dtl');

 RefTestModules.
  RegisterModuleTests(ExtractFilePath(ParamStr(0)) + 'MiniTestLibW32C.dtl');

 RefTestModules.
  RegisterModuleTests(ExtractFilePath(ParamStr(0)) + 'MiniTestLibW32D.dtl');


 // Test sequence used in TTestModuleLoads OnRunProjectsThenDLLReportMinimally
  RefTestFramework.
  RegisterTest(TTwoTests.Suite); // Becomes Default Project

 RefTestFramework.
  RegisterTest('AsTestSuite', TTwoTests.Suite); // Becomes test suite within Default Project

 RefTestFramework.
  ProjectRegisterTest('AProject', TTwoTests.Suite); // Becomes separate project

 RefTestModules.
  RegisterModuleTests(ExtractFilePath(ParamStr(0)) + 'MiniTestLibW32A.dtl');


 // Test sequence used in TTestModuleLoads OnRunDLLThenProjectsReportMinimally
 RefTestModules.
  RegisterModuleTests(ExtractFilePath(ParamStr(0)) + 'MiniTestLibW32A.dtl');

 RefTestFramework.
  RegisterTest('AsTestSuite', TTwoTests.Suite); // Becomes Default Project

 RefTestFramework.
  ProjectRegisterTest('AProject', TTwoTests.Suite); // Becomes separate project

 RefTestFramework.
  RegisterTest(TTwoTests.Suite); // Becomes test suite within Default Project
*)

end.
