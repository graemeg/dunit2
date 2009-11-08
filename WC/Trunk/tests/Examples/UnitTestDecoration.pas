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
 * Peter McNab <mcnabp@gmail.com>
 *
 *******************************************************************************
*)
unit UnitTestDecoration;
{.$DEFINE SELFTEST} // Define this at project level to include in testing.
interface
uses
  {$IFDEF CLR}System.Reflection,{$ENDIF}
  ProjectsManagerIface,
  TestFrameworkIfaces,
  TestExtensions,
  {$IFDEF SELFTEST}
    RefTestFramework,
  {$ELSE}
    TestFramework,  
  {$ENDIF}
  Classes;

type

  TTrialDecoratedTest = class(TTestCase)
  published
    procedure Method1;
    {$IFDEF CLR}[Test]{$ENDIF}
    procedure Method2;
    {$IFDEF CLR}[Test]{$ENDIF}
    procedure Method3;
  public
    constructor Create; override;
  end;

  TTestTheDecorator = class(TTestDecorator)
  protected
    procedure SetUp; override;
  end;

  TTestAnotherDecorator = class(TTestDecorator)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  end;

  TAnOrdinaryTest1 = class(TTestCase)
  published
    {$IFDEF CLR}[Test]{$ENDIF}
    procedure ATestThatPasses;
    {$IFDEF CLR}[Test]{$ENDIF}
    procedure AnotherTestThatPasses;
    {$IFDEF CLR}[Test]{$ENDIF}
    procedure ATestThatFails;
  end;

  TTestWithTearDownFailure = class(TTestCase)
  protected
    procedure TearDown; override;
  published
    {$IFDEF CLR}[Test]{$ENDIF}
    procedure ATestThatPasses;
  end;

  TDecoratedTestWithTearDownOnceFail = class(TTestCase)
  protected
    procedure TearDownOnce; override;
  published
    {$IFDEF CLR}[Test]{$ENDIF}
    procedure Method1;
  end;

  TTestDecoratorTearDownOnceFails = class(TTestDecorator)
  protected
    procedure TearDownOnce; override;
  end;

var
  GlobalVar: integer;

type
  TOldStyleDecorator = class(TTestSetUp)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  end;

  TDecoratedEmptySuitePopulates = class(TTestDecorator)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  end;

  TOneTestProc = class(TTestCase)
  published
    procedure OneProc;
  end;

  TDecoratedTestIncsVar = class(TTestCase)
  published
    procedure IncGlobalVar;
    procedure IncGlobalVar2;
  end;


var
  GlobalCount: Cardinal;

type
  TCountedTestFails = class(TTestCase)
  private
  protected
    procedure SetUpOnce; override;
  published
    {$IFDEF CLR}[Test]{$ENDIF}
    procedure PassesEarly;
    {$IFDEF CLR}[Test]{$ENDIF}
    procedure ShouldFailWhenGlobalCountIs1;
    {$IFDEF CLR}[Test]{$ENDIF}
    procedure ShouldFailWhenGlobalCountIs3;
    {$IFDEF CLR}[Test]{$ENDIF}
    procedure ShouldFailWhenGlobalCountIs5;
    {$IFDEF CLR}[Test]{$ENDIF}
    procedure Passes;
  end;

  TTestRepeatedTests = class(TRepeatedTest)
  end;

  TTestCountedTestHalts = class(TTestRepeatedTests)
  protected
    procedure SetUp; override;
  end;

  TDecorateRepeatTest = class(TTestDecorator)
  protected
    procedure SetUp; override;
  end;

implementation
uses
  SysUtils,
  Typinfo;

var
  PassedInVar: integer;

  { TTestTheDecorator }

procedure TTestTheDecorator.SetUp;
begin
  PassedInVar := 0;
end;

constructor TTrialDecoratedTest.Create;
begin
  inherited;
  Inc(PassedInVar);
  DisplayedName := DisplayedName + '[' + IntToStr(PassedInVar) + ']';
end;

procedure TTrialDecoratedTest.Method1;
begin
  Check(True);
end;

procedure TTrialDecoratedTest.Method2;
begin
  Check(False, 'Deliberate Failure');
end;

procedure TTrialDecoratedTest.Method3;
begin
  Check(True);
end;

{ TTestAnotherDecorator }

procedure TTestAnotherDecorator.SetUp;
begin
  Check(Self.SupportedIfaceType = _isTestDecorator,
    'Supported interface should be _isTestDecorator but was ' +
      GetEnumName(TypeInfo(TSupportedIface ), Ord(Self.SupportedIfaceType)));
end;

procedure TTestAnotherDecorator.TearDown;
begin
end;

{ TCountedTestFails }

procedure TCountedTestFails.Passes;
begin
  Check(True);
end;

procedure TCountedTestFails.PassesEarly;
begin
  Check(True);
end;

procedure TCountedTestFails.SetUpOnce;
begin
  Inc(GlobalCount);
end;

procedure TCountedTestFails.ShouldFailWhenGlobalCountIs5;
begin
  Check(GlobalCount <> 5, 'Failed when GlobalCount = ' + IntToStr(GlobalCount));
end;

procedure TCountedTestFails.ShouldFailWhenGlobalCountIs3;
begin
  Check(GlobalCount <> 3, 'Failed when GlobalCount = ' + IntToStr(GlobalCount));
end;

procedure TCountedTestFails.ShouldFailWhenGlobalCountIs1;
begin
  Check(GlobalCount <> 1, 'Failed when GlobalCount = ' + IntToStr(GlobalCount));
end;


{ TDecorateRepeatTest }

procedure TDecorateRepeatTest.SetUp;
begin
  GlobalCount := 0;
end;

{ TTestRepeatedTestHalts }

procedure TTestCountedTestHalts.Setup;
begin
  HaltOnError := True;
end;


procedure TTestDecoratorTearDownOnceFails.TearDownOnce;
begin
  Check(False, 'Deliberate exception in Decorator`s TearDownOnce');
end;

{ TDecoratedTestWithTearDownOnceFail }

procedure TDecoratedTestWithTearDownOnceFail.Method1;
begin
  Check(True, 'Passes');
end;

procedure TDecoratedTestWithTearDownOnceFail.TearDownOnce;
begin
  Check(False, 'Forced Failure');
end;

{ TAndOrdinaryTest1 }

procedure TAnOrdinaryTest1.AnotherTestThatPasses;
begin
  Check(True, 'Passes');
end;

procedure TAnOrdinaryTest1.ATestThatFails;
begin
  Check(False, 'A check to fail');
end;

procedure TAnOrdinaryTest1.ATestThatPasses;
begin
  Check(True, 'Passes');
end;

{ TTestWithTearDownFailure }

procedure TTestWithTearDownFailure.ATestThatPasses;
begin
  Check(True, 'Test Passes');
end;

procedure TTestWithTearDownFailure.TearDown;
begin
  Check(False, 'My deliberate failure in TearDown');
end;

{ TDecoratedEmptySuitePopulates }

procedure TDecoratedEmptySuitePopulates.SetUp;
begin
  GlobalVar := 0;
end;

procedure TDecoratedEmptySuitePopulates.TearDown;
begin
//  Assert(GlobalVar = 3, 'Should have increnmented twice');
end;

{ TDecoratedTestIncsVar }

procedure TDecoratedTestIncsVar.IncGlobalVar;
begin
  Inc(GlobalVar);
  Check(True);
end;

procedure TDecoratedTestIncsVar.IncGlobalVar2;
begin
  Inc(GlobalVar);
  Check(True);
end;

{ TOldStyleDecorator }

procedure TOldStyleDecorator.SetUp;
begin
  inherited;

end;

procedure TOldStyleDecorator.TearDown;
begin
  inherited;

end;

{ TOneTestProc }

procedure TOneTestProc.OneProc;
begin
  Check(True);
end;

initialization

  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest(TTestTheDecorator.Suite('Renamed Decorator', TTrialDecoratedTest.Suite));

  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest(TTestTheDecorator.Suite('XXX',
                 TTestAnotherDecorator.Suite('YYY',
                   TTestTheDecorator.Suite('ZZZ',
                     TTrialDecoratedTest.Suite))));

  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest(TTestTheDecorator.Suite('XXX', [TTrialDecoratedTest.Suite,// This is just an ordinary test
                 TTestAnotherDecorator.Suite('YYY',
                   [TTrialDecoratedTest.Suite,
                    TTestTheDecorator.Suite('ZZZ',
                      TTrialDecoratedTest.Suite)])]));

  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest(TTestRepeatedTests.Suite(TTrialDecoratedTest.Suite, 3));

  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest(TDecorateRepeatTest.Suite('Initialise Global Counter',
                 TTestRepeatedTests.Suite(TCountedTestFails.Suite, 5)));

  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest(TTestDecoratorTearDownOnceFails.Suite('Failing Decorator', TTrialDecoratedTest.Suite));

  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest(TDecorateRepeatTest.Suite('Initialise Global Counter',
                 TTestCountedTestHalts.Suite(TCountedTestFails.Suite, 5)));

  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest(TTestTheDecorator.Suite('Failing Decorator', TDecoratedTestWithTearDownOnceFail.Suite));


  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest(TTestDecoratorTearDownOnceFails.Suite('XXX',
                                                     [TAnOrdinaryTest1.Suite,
                                                     TTestWithTearDownFailure.Suite,
                                                     TDecoratedTestWithTearDownOnceFail.Suite,
                                                     TAnOrdinaryTest1.Suite
                                                     ]));

  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest('PQR', TDecoratedEmptySuitePopulates.Suite('KLM', TAnOrdinaryTest1.suite{TTestCase.suite}));
  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest('KLM', TAnOrdinaryTest1.suite);
  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest('PQR', TAnOrdinaryTest1.suite);
  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}

  RegisterTest('JKL', TTestDecorator.Suite('A suite with name', TAnOrdinaryTest1.suite));
  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest('JKL', TAnOrdinaryTest1.suite);
  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest('JKL', TAnOrdinaryTest1.suite);

  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest('JKL', TTestDecorator.Suite(nil));
  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest('JKL', TAnOrdinaryTest1.suite);
  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest('JKL', TAnOrdinaryTest1.suite);


  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest(       TDecoratedEmptySuitePopulates.Suite(       TOneTestProc.suite));

  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest(       TDecoratedEmptySuitePopulates.Suite(       TDecoratedTestIncsVar.suite));

  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest('X',   TDecoratedEmptySuitePopulates.Suite(       TDecoratedTestIncsVar.suite));
  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest('X',   TDecoratedEmptySuitePopulates.Suite( '',  TDecoratedTestIncsVar.suite));

  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest('X',   TDecoratedEmptySuitePopulates.Suite( '', [TDecoratedTestIncsVar.suite,
                                                                 TAnOrdinaryTest1.suite]));
  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest(       TOldStyleDecorator.Suite(       TDecoratedTestIncsVar.suite));


  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest('X',   TDecoratedEmptySuitePopulates.Suite( 'Z',  TDecoratedTestIncsVar.suite));

  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest(       TDecoratedEmptySuitePopulates.Suite('X',[TDecoratedTestIncsVar.suite,
                                                               TDecoratedTestWithTearDownOnceFail.suite]));
  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest(       TDecoratedEmptySuitePopulates.Suite('ABC', TDecoratedTestIncsVar.suite));
  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest('JKL', TDecoratedEmptySuitePopulates.Suite(       TDecoratedTestIncsVar.suite));
  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest('JKL', TDecoratedEmptySuitePopulates.Suite('ABC', TDecoratedTestIncsVar.suite));

  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest('JKL', TDecoratedEmptySuitePopulates.Suite('', TAnOrdinaryTest1.suite));
  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest(TDecoratedEmptySuitePopulates.Suite('', TAnOrdinaryTest1.suite));

  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest('JKL', TDecoratedTestIncsVar.suite);
  {$IFDEF SELFTEST} RefTestFramework. {$ENDIF}
  RegisterTest('JKL', TDecoratedTestIncsVar.suite);

end.
