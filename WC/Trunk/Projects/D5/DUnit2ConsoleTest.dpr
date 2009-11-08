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

program DUnit2ConsoleTest;
{
  Delphi DUnit Test Project
  -------------------------
}

{$APPTYPE CONSOLE}
{$IFNDEF SELFTEST}
  '!!!Alert SELFTEST must be defined in project options conditionals'
{$ENDIF}

uses
  {$IFDEF FASTMM}
    FastMM4,
  {$ENDIF}
  D5Support                in '..\..\src\D5Support.pas',
  TestFrameworkIfaces      in '..\..\src\TestFrameworkIfaces.pas',
  TestFramework            in '..\..\src\TestFramework.pas',
  TestFrameworkProxyIfaces in '..\..\src\TestFrameworkProxyIfaces.pas',
  TestListenerIface        in '..\..\src\TestListenerIface.pas',
  ProjectsManagerIface     in '..\..\src\ProjectsManagerIface.pas',
  ProjectsManager          in '..\..\src\ProjectsManager.pas',
  TestFrameworkProxy       in '..\..\src\TestFrameworkProxy.pas',
  XPVistaSupport           in '..\..\src\XPVistaSupport.pas',
  RefTestFrameworkProxy    in '..\..\Ref\RefTestFrameworkProxy.pas',
  RefTestFramework         in '..\..\Ref\RefTestFramework.pas',
  RefProjectsManager       in '..\..\Ref\RefProjectsManager.pas',
  {$IFDEF FASTMM}
    FastMMMonitorTest      in '..\..\tests\FastMMMonitorTest.pas',
  {$ENDIF}
  SharedTestClasses        in '..\..\tests\SharedTestClasses.pas',
  UnitTestFramework        in '..\..\tests\UnitTestFramework.pas',
  UnitTestModules          in '..\..\tests\UnitTestModules.pas',
  UnitTestFrameworkProxy   in '..\..\tests\UnitTestFrameworkProxy.pas',
//     ---- Only include in unit tests when required ----
//     --- See note in UnitTestGUITesting if build fails
//  UnitTestGUITesting       in '..\..\tests\UnitTestGUITesting.pas',
//
  TestExtensions           in '..\..\src\TestExtensions.pas',
  GUITesting               in '..\..\src\GUITesting.pas',
  TestModules              in '..\..\src\TestModules.pas',
  TextTestRunner           in '..\..\src\TextTestRunner.pas';

{$R *.RES}

begin
  TextTestRunner.RunRegisteredTests;
  Writeln;
  Writeln('Press <ENTER> to continue');
  Readln;
end.
