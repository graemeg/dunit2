{#(@)$Id: $ }
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

program ShowOverrides;
{
  Delphi DUnit Test Project
  -------------------------
}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

{%TogetherDiagram 'ModelSupport_ShowOverrides\default.txaPackage'}

uses
  FastMM4                  in '..\..\..\..\Externals\FastMM\FastMM4.pas',
  SysUtils,
{
  TestFrameworkIfaces      in '..\..\src\TestFrameworkIfaces.pas',
  TestFramework            in '..\..\src\TestFramework.pas',
  TestFrameworkProxyIfaces in '..\..\src\TestFrameworkProxyIfaces.pas',
  TestListenerIface        in '..\..\src\TestListenerIface.pas',
  ProjectsManagerIface     in '..\..\src\ProjectsManagerIface.pas',
  ProjectsManager          in '..\..\src\ProjectsManager.pas',
  TestFrameworkProxy       in '..\..\src\TestFrameworkProxy.pas',
  FastMMMemLeakMonitor     in '..\..\src\FastMMMemLeakMonitor.pas',
  RefTestFrameworkProxy    in '..\..\Ref\RefTestFrameworkProxy.pas',
  RefTestFramework         in '..\..\Ref\RefTestFramework.pas',
  RefProjectsManager       in '..\..\Ref\RefProjectsManager.pas',
  RefTestModules           in '..\..\Ref\RefTestModules.pas',
}
  GUITestRunner            in '..\..\src\GUITestRunner.pas',
//  TestExtensions           in '..\..\src\TestExtensions.pas',

  TextTestRunner           in '..\..\src\TextTestRunner.pas',
//  TestModules              in '..\..\src\TestModules.pas',
  CheckOverrides           in '..\..\tests\Examples\CheckOverrides.pas';

{$R *.RES}

begin
  if IsConsole then
  begin
    try
      try
        TextTestRunner.RunRegisteredTests;
      except
        on e:Exception do
        begin
          writeln;
          writeln('Unhandled exception: ' + E.ClassName + '  ' + E.Message);
        end;  
      end;
    finally
      writeln;
      writeln('Press <ENTER> to continue');
      readln;
    end;
  end
  else
    GUITestRunner.RunRegisteredTests;
end.
