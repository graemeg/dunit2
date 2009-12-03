program DemoDecorateTestSuite;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options 
  to use the console test runner.  Otherwise the GUI test runner will be used by 
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  GUITestRunner               in '..\..\src\GUITestRunner.pas',
  TextTestRunner              in '..\..\src\TextTestRunner.pas',
  Unit1                       in '..\..\tests\examples\Unit1.pas',
  TestUnit1                   in '..\..\tests\examples\TestUnit1.pas';

{$R *.RES}

begin
  if IsConsole then
  begin
    TextTestRunner.RunRegisteredTests;
    writeln;
    writeln('Press <ENTER> to continue');
    readln;
  end
  else
    GUITestRunner.RunRegisteredTests;
end.

