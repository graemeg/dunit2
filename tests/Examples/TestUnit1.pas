unit TestUnit1;

interface

uses
  Classes,
  TestFramework,
  Unit1;
type
  TStructureTest = class(TTestCase)
  strict private
    FTestedClassA: TTestedClassA;
  public
    procedure SetUpOnce; override;
    procedure TearDownOnce; override;
  published
    procedure TestReturnsTrue;
    procedure TestRetunesFalse;
    procedure TestReturnsTrueFalseAlternately;
  end;

  TDataTest = class(TTestCase)
  strict private
    FTestedClassB: TTestedClassB;
  public
    procedure SetUpOnce; override;
    procedure TearDownOnce; override;
  published
    procedure TestReturnsNotTrue;
    procedure TestRetunesNotFalse;
    procedure TestReturnsFalseTrueAlternately;
  end;

  TManualTestSuite = class(TTestSuite)
  protected
  end;

  TSetupTests = class(TTestDecorator)
  protected
  end;

implementation

procedure TStructureTest.SetUpOnce;
begin
  FTestedClassA := TTestedClassA.Create;
end;

procedure TStructureTest.TearDownOnce;
begin
  FTestedClassA.Free;
  FTestedClassA := nil;
end;

procedure TStructureTest.TestReturnsTrue;
var
  ReturnValue: Boolean;
begin
  ReturnValue := FTestedClassA.ReturnsTrue;
  Check(ReturnValue, 'Should have been True');
end;

procedure TStructureTest.TestRetunesFalse;
var
  ReturnValue: Boolean;
begin
  ReturnValue := FTestedClassA.RetunesFalse;
  Check(not ReturnValue, 'Should have been False');
end;

procedure TStructureTest.TestReturnsTrueFalseAlternately;
var
  ReturnValue: Boolean;
begin
  ReturnValue := FTestedClassA.ReturnsTrueFalseAlternately;
  if ReturnValue = True then
    CheckFalse(FTestedClassA.ReturnsTrueFalseAlternately, 'Should return False after True')
  else
    CheckTrue(FTestedClassA.ReturnsTrueFalseAlternately, 'Should return True after False');
end;

procedure TDataTest.SetUpOnce;
begin
  FTestedClassB := TTestedClassB.Create;
end;

procedure TDataTest.TearDownOnce;
begin
  FTestedClassB.Free;
  FTestedClassB := nil;
end;

procedure TDataTest.TestReturnsNotTrue;
var
  ReturnValue: Boolean;
begin
  ReturnValue := FTestedClassB.ReturnsNotTrue;
  Check(not ReturnValue, 'Should return False');
end;

procedure TDataTest.TestRetunesNotFalse;
var
  ReturnValue: Boolean;
begin
  ReturnValue := FTestedClassB.RetunesNotFalse;
  CheckFalse(not ReturnValue, 'Should return True');
end;

procedure TDataTest.TestReturnsFalseTrueAlternately;
var
  ReturnValue: Boolean;
begin
  ReturnValue := FTestedClassB.ReturnsFalseTrueAlternately;
  if ReturnValue = False then
    CheckTrue(FTestedClassB.ReturnsFalseTrueAlternately, 'Should return True after False')
  else
    CheckFalse(FTestedClassB.ReturnsFalseTrueAlternately, 'Should return False after True');
end;

initialization
  RegisterTest(TSetupTests.Suite(TTestSuite.Suite('xxx', [TStructureTest.Suite,
                                                          TDataTest.Suite])));

  RegisterTest(TSetupTests.Suite('xxx', [TStructureTest.Suite,
                                         TDataTest.Suite]));
end.

