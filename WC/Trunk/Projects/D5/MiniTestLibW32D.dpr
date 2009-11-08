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
 * and Juancarlo A�ez.
 * Portions created The Initial Developers are Copyright (C) 1999-2000.
 * Portions created by The DUnit Group are Copyright (C) 2000-2008.
 * All rights reserved.
 *
 * Contributor(s):
 * Kent Beck <kentbeck@csi.com>
 * Erich Gamma <Erich_Gamma@oti.com>
 * Juanco A�ez <juanco@users.sourceforge.net>
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

library MiniTestLibW32D;

uses
  {$IFDEF FASTMM}
    FastMM4,
  {$ENDIF}
  D5Support                in '..\..\src\D5Support.pas',
  TestFrameworkIfaces      in '..\..\src\TestFrameworkIfaces.pas',
  TestListenerIface        in '..\..\src\TestListenerIface.pas',
  TestFramework            in '..\..\src\TestFramework.pas',
  TestFrameworkProxyIfaces in '..\..\src\TestFrameworkProxyIfaces.pas',
  ProjectsManagerIface     in '..\..\src\ProjectsManagerIface.pas',
  ProjectsManager          in '..\..\src\ProjectsManager.pas',
  MiniTestSuite2           in '..\..\tests\MiniTestSuite2.pas',
  SysUtils;

{$R *.res}
{$E .dtl}

  exports RegisteredTests name 'Test';


end.

