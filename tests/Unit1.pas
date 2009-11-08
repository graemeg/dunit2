{$IFDEF VER180}
  {$DEFINE FASTMM}
{$ENDIF}
{$IFDEF CLR}
  {$UNSAFECODE ON}
  {$UNDEF FASTMM}
{$ENDIF}

unit Unit1;
interface
uses
  {$IFDEF CLR}
    System.Reflection,
  {$ENDIF}

  {$IFDEF V93}
    TestExtensions,
  {$ENDIF}

  TestFramework;

type
  TTestCasePasses = class(TTestCase)
  published
  {$ifdef clr} [Test] {$endif}
    procedure AlwaysPass;
  end;

implementation

procedure TTestCasePasses.AlwaysPass;
begin
  Check(True, 'Check(True) failed which is very bad');
end;

initialization
  RegisterTest(TTestCasePasses.Suite);
end.
