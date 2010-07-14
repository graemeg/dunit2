{ $Id$ }
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
 * Kenneth Semeijn <dunit@designtime.demon.nl>
 * Uberto Barbini <uberto@usa.net>
 * Brett Shearer <BrettShearer@users.sourceforge.net>
 * Kris Golko <neuromancer@users.sourceforge.net>
 * The DUnit group at SourceForge <http://dunit.sourceforge.net>
 *
 *)

{$I DUnit.inc}

unit GUITestRunner;

interface

uses
  Windows, Classes, Graphics, Controls, Forms,
  ComCtrls, ExtCtrls, StdCtrls, ImgList, Buttons, Menus, ActnList,
  IniFiles, ToolWin,
  TestFrameworkProxyIfaces,
  GUISearchPanel, GUISearchController;

type
  {: Function type used by the TDUnitDialog.ApplyToTests method
     @param item  The ITest instance on which to act
     @return true if processing should continue, false otherwise
  }
  TTestFunc = function (item :ITestProxy):Boolean of object;

  TGUITestRunner = class(TForm, ITestListener, ITestListenerX)
    StateImages: TImageList;
    RunImages: TImageList;
    DialogActions: TActionList;
    SelectAllAction: TAction;
    DeselectAllAction: TAction;
    SelectFailedAction: TAction;
    MainMenu: TMainMenu;
    TestTreeMenu: TMenuItem;
    SelectAllItem: TMenuItem;
    DeselectAllItem: TMenuItem;
    SelectFailedItem: TMenuItem;
    FileMenu: TMenuItem;
    SaveConfigurationAction: TAction;
    AutoSaveAction: TAction;
    SaveConfigurationItem: TMenuItem;
    AutoSaveItem: TMenuItem;
    RestoreSavedAction: TAction;
    RestoreSavedConfigurationItem: TMenuItem;
    ViewMenu: TMenuItem;
    HideErrorBoxItem: TMenuItem;
    BodyPanel: TPanel;
    ErrorBoxVisibleAction: TAction;
    TopPanel: TPanel;
    TreePanel: TPanel;
    TestTree: TTreeView;
    ResultsPanel: TPanel;
    ProgressPanel: TPanel;
    ResultsView: TListView;
    FailureListView: TListView;
    ErrorBoxPanel: TPanel;
    ErrorBoxSplitter: TSplitter;
    ResultsSplitter: TSplitter;
    AutoChangeFocusItem: TMenuItem;
    TopProgressPanel: TPanel;
    ProgressBar: TProgressBar;
    pnlProgresslabel: TPanel;
    ScorePanel: TPanel;
    ScoreLabel: TPanel;
    ScoreBar: TProgressBar;
    pmTestTree: TPopupMenu;
    pmiSelectAll: TMenuItem;
    pmiDeselectAll: TMenuItem;
    pmiSelectFailed: TMenuItem;
    HideTestNodesAction: TAction;
    CollapseLowestSuiteNodesItem: TMenuItem;
    CollapseLowestSuiteNodes1: TMenuItem;
    HideTestNodesOnOpenAction: TAction;
    HideTestNodesItem: TMenuItem;
    ExpandAllNodesAction: TAction;
    TestTreeMenuSeparator: TMenuItem;
    ExpandAllItem: TMenuItem;
    TestTreeLocalMenuSeparator: TMenuItem;
    ExpandAll2: TMenuItem;
    lblTestTree: TLabel;
    RunAction: TAction;
    ExitAction: TAction;
    BreakOnFailuresAction: TAction;
    BreakonFailuresItem: TMenuItem;
    ShowTestedNodeAction: TAction;
    SelectTestedNodeItem: TMenuItem;
    ErrorMessagePopup: TPopupMenu;
    CopyFailureMessage: TMenuItem;
    CopyMessageToClipboardAction: TAction;
    ActionsMenu: TMenuItem;
    CopyMessagetoCllipboardItem: TMenuItem;
    LbProgress: TLabel;
    UseRegistryAction: TAction;
    UseRegistryItem: TMenuItem;
    ErrorMessageRTF: TRichEdit;
    SelectCurrentAction: TAction;
    DeselectCurrentAction: TAction;
    SelectCurrent1: TMenuItem;
    DeselectCurrent1: TMenuItem;
    ActionsImages: TImageList;
    CloseItem: TMenuItem;
    RunItem: TMenuItem;
    StopAction: TAction;
    StopActionItem: TMenuItem;
    ToolBar1: TToolBar;
    SelectAllButton: TToolButton;
    DeselectAllButton: TToolButton;
    ToolButton1: TToolButton;
    SelectFailedButton: TToolButton;
    ToolButton2: TToolButton;
    SelectCurrentButton: TToolButton;
    DeselectCurrentButton: TToolButton;
    ToolButton3: TToolButton;
    RunButton: TToolButton;
    StopButton: TToolButton;
    Alt_R_RunAction: TAction;
    Alt_S_StopAction: TAction;
    N1: TMenuItem;
    DeselectCurrent2: TMenuItem;
    SelectCurrent2: TMenuItem;
    N2: TMenuItem;
    CopyProcnameToClipboardAction: TAction;
    N3: TMenuItem;
    Copytestnametoclipboard1: TMenuItem;
    N4: TMenuItem;
    Copytestnametoclipboard2: TMenuItem;
    RunSelectedTestAction: TAction;
    N5: TMenuItem;
    RunFromHereItem3: TMenuItem;
    N6: TMenuItem;
    RunFromHereItem2: TMenuItem;
    RunFromHereItem4: TMenuItem;
    RunSelectedTestButton: TToolButton;
    GoToNextSelectedTestAction: TAction;
    GoToPrevSelectedTestAction: TAction;
    N7: TMenuItem;
    GoToNextSelectedNode1: TMenuItem;
    GoToPreviousSelectedNode1: TMenuItem;
    N8: TMenuItem;
    GoToNextSelectedNode2: TMenuItem;
    GoToPreviousSelectedNode2: TMenuItem;
    FailIfNoChecksExecutedMenuItem: TMenuItem;
    FailIfNoChecksExecutedAction: TAction;
    FailTestCaseIfMemoryLeakedMenuItem: TMenuItem;
    FailTestCaseIfMemoryLeakedAction: TAction;
    FailsOnMemoryLeakMenuItem: TMenuItem;
    AllowedLeakSizeMenuItem: TMenuItem;
    TestCaseProperty: TPopupMenu;
    TestCaseProperties: TMenuItem;
    N10: TMenuItem;
    FailNoCheckExecutedMenuItem: TMenuItem;
    N11: TMenuItem;
    TestCasePopup: TMenuItem;
    ShowTestCasesWithRunTimePropertiesAction: TAction;
    N9: TMenuItem;
    ShowOverriddenFailuresMenuItem: TMenuItem;
    EnableWarningsAction: TAction;
    N12: TMenuItem;
    TestCasePropertiesAction: TAction;
    N13: TMenuItem;
    Previous1: TMenuItem;
    Next1: TMenuItem;
    RunSelectedTest1: TMenuItem;
    RunSelectedTestAltAction: TAction;
    ReportMemoryLeakTypeOnShutdownMenuItem: TMenuItem;
    IgnoreMemoryLeakInSetUpTearDownMenuItem: TMenuItem;
    IgnoreMemoryLeakInSetUpTearDownAction: TAction;
    ReportMemoryLeakTypeOnShutdownAction: TAction;
    TestCaseIgnoreSetUpTearDownLeaksMenuItem: TMenuItem;
    N15: TMenuItem;
    N16: TMenuItem;
    CheckMemLeaksToolButton: TToolButton;
    Exclude_Test_Execution: TMenuItem;
    Include_Test_Execution: TMenuItem;
    ExcludeCurrentAction: TAction;
    IncludeCurrentAction: TAction;
    ShowSummaryLevelExitsMenuItem: TMenuItem;
    ShowTestCasesWithWarningsAction: TAction;
    ToolButton6: TToolButton;
    CheckCheckedToolButton: TToolButton;
    ToolButton10: TToolButton;
    PropertyOverrideToolButton: TToolButton;
    ShowOverriddenFailuresToolButton: TToolButton;
    ToolButton11: TToolButton;
    CopySelectedMessageToClipboardAction: TAction;
    Copyselectederrormessagetoclipboard1: TMenuItem;
    CopyQuotedSelectedMessageToClipboardAction: TAction;
    Copyselectederrormessagetoclipboardasquotedstring1: TMenuItem;
    N14: TMenuItem;
    InhibitSummaryLevelChecksToolButton: TToolButton;
    ShowSummaryLevelExitsToolButton: TToolButton;
    InhibitSummaryLevelChecksAction: TAction;
    ShowEarlyExitedTestAction: TAction;
    ShowOverriddenFailuresAction: TAction;
    EnableWarningsMenuItem: TMenuItem;
    InhibitSummaryLevelChecksMenuItem: TMenuItem;
    PropertyOverrideMenuItem: TMenuItem;
    ShowWarnedTestToolButton: TToolButton;
    SearchBasePanel: TPanel;
    SearchImages: TImageList;
    RunFromHereAction: TAction;
    RunFromHereButton: TToolButton;
    Runselectedtest3: TMenuItem;
    RecordSelectedTestItem1: TMenuItem;
    RecordSelectedTestItem2: TMenuItem;
    RecordSelectedTestItem3: TMenuItem;
    RecordSelectedTestAction: TAction;
    RecordSelectedTestAltAction: TAction;
    RecordSelectedTestButton: TToolButton;
    Runselectedtest2: TMenuItem;
    Runselectedtest4: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure TestTreeClick(Sender: TObject);
    procedure FailureListViewSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure FailureListViewClick(Sender: TObject);
    procedure TestTreeKeyPress(Sender: TObject; var Key: Char);
    procedure SelectAllActionExecute(Sender: TObject);
    procedure DeselectAllActionExecute(Sender: TObject);
    procedure SelectFailedActionExecute(Sender: TObject);
    procedure SaveConfigurationActionExecute(Sender: TObject);
    procedure RestoreSavedActionExecute(Sender: TObject);
    procedure AutoSaveActionExecute(Sender: TObject);
    procedure ErrorBoxVisibleActionExecute(Sender: TObject);
    procedure ErrorBoxSplitterMoved(Sender: TObject);
    procedure ErrorBoxPanelResize(Sender: TObject);
    procedure HideTestNodesActionExecute(Sender: TObject);
    procedure HideTestNodesOnOpenActionExecute(Sender: TObject);
    procedure ExpandAllNodesActionExecute(Sender: TObject);
    procedure RunActionExecute(Sender: TObject);
    procedure ExitActionExecute(Sender: TObject);
    procedure BreakOnFailuresActionExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ShowTestedNodeActionExecute(Sender: TObject);
    procedure CopyMessageToClipboardActionExecute(Sender: TObject);
    procedure UseRegistryActionExecute(Sender: TObject);
    procedure RunActionUpdate(Sender: TObject);
    procedure CopyMessageToClipboardActionUpdate(Sender: TObject);
    procedure SelectCurrentActionExecute(Sender: TObject);
    procedure DeselectCurrentActionExecute(Sender: TObject);
    procedure StopActionExecute(Sender: TObject);
    procedure StopActionUpdate(Sender: TObject);
    procedure TestTreeChange(Sender: TObject; Node: TTreeNode);
    procedure CopyProcnameToClipboardActionExecute(Sender: TObject);
    procedure CopyProcnameToClipboardActionUpdate(Sender: TObject);
    procedure RunSelectedTestActionExecute(Sender: TObject);
    procedure RunSelectedTestActionUpdate(Sender: TObject);
    procedure TestTreeMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GoToNextSelectedTestActionExecute(Sender: TObject);
    procedure GoToPrevSelectedTestActionExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FailIfNoChecksExecutedActionExecute(Sender: TObject);
    procedure ShowTestCasesWithRunTimePropertiesActionExecute(
      Sender: TObject);
    procedure TestCasePropertiesActionExecute(Sender: TObject);
    procedure Previous1Click(Sender: TObject);
    procedure Next1Click(Sender: TObject);
    procedure TestCasePropertiesMeasureItem(Sender: TObject;
      ACanvas: TCanvas; var Width, Height: Integer);
    procedure TestCasePropertiesDrawItem(Sender: TObject; ACanvas: TCanvas;
      ARect: TRect; Selected: Boolean);
    procedure FailNoCheckExecutedMenuItemDrawItem(Sender: TObject;
      ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure pmTestTreePopup(Sender: TObject);
    procedure FailNoCheckExecutedMenuItemClick(Sender: TObject);
    procedure RunSelectedTestAltActionExecute(Sender: TObject);
    procedure Previous1DrawItem(Sender: TObject; ACanvas: TCanvas;
      ARect: TRect; Selected: Boolean);
    procedure RunSelectedTest1DrawItem(Sender: TObject; ACanvas: TCanvas;
      ARect: TRect; Selected: Boolean);
    procedure Next1DrawItem(Sender: TObject; ACanvas: TCanvas;
      ARect: TRect; Selected: Boolean);
    procedure FailTestCaseIfMemoryLeakedActionExecute(Sender: TObject);
    procedure AllowedLeakSizeMenuItemDrawItem(Sender: TObject;
      ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure FailsOnMemoryLeakMenuItemDrawItem(Sender: TObject;
      ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure AllowedLeakSizeMenuItemClick(Sender: TObject);
    procedure FailsOnMemoryLeakMenuItemClick(Sender: TObject);
    procedure ReportMemoryLeakTypeOnShutdownActionExecute(Sender: TObject);
    procedure IgnoreMemoryLeakInSetUpTearDownActionExecute(
      Sender: TObject);
    procedure TestCaseIgnoreSetUpTearDownLeaksMenuItemClick(Sender: TObject);
    procedure TestCaseIgnoreSetUpTearDownLeaksMenuItemDrawItem(Sender: TObject;
      ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure FailTestCaseIfMemoryLeakedActionUpdate(Sender: TObject);
    procedure ExcludeCurrentActionExecute(Sender: TObject);
    procedure IncludeCurrentActionExecute(Sender: TObject);
    procedure FailIfNoChecksExecutedActionUpdate(Sender: TObject);
    procedure ShowTestCasesWithRunTimePropertiesActionUpdate(
      Sender: TObject);
    procedure ShowOverriddenFailuresActionUpdate(Sender: TObject);
    procedure EnableWarningsActionUpdate(Sender: TObject);
    procedure ShowTestCasesWithWarningsActionUpdate(Sender: TObject);
    procedure CopySelectedMessageToClipboardActionExecute(Sender: TObject);
    procedure CopySelectedMessageToClipboardActionUpdate(Sender: TObject);
    procedure CopyQuotedSelectedMessageToClipboardActionExecute(
      Sender: TObject);
    procedure CopyQuotedSelectedMessageToClipboardActionUpdate(Sender: TObject);
    procedure InhibitSummaryLevelChecksActionExecute(Sender: TObject);
    procedure InhibitSummaryLevelChecksActionUpdate(Sender: TObject);
    procedure ShowEarlyExitedTestActionExecute(Sender: TObject);
    procedure ShowOverriddenFailuresActionExecute(Sender: TObject);
    procedure ShowEarlyExitedTestActionUpdate(Sender: TObject);
    procedure EnableWarningsActionExecute(Sender: TObject);
    procedure FailureListViewDblClick(Sender: TObject);
    procedure ErrorMessageRTFDblClick(Sender: TObject);
    procedure RunFromHereActionExecute(Sender: TObject);
    procedure RunFromHereActionUpdate(Sender: TObject);
    procedure RecordSelectedTestActionExecute(Sender: TObject);
    procedure RecordSelectedTestActionUpdate(Sender: TObject);
    procedure RecordSelectedTestAltActionExecute(Sender: TObject);
    procedure RecordSelectedTestItem1DrawItem(Sender: TObject; ACanvas: TCanvas;
      ARect: TRect; Selected: Boolean);

  private
    FSuite:         ITestProxy;
    FTestResult:    TTestResult;
    FRunning:       Boolean;
    FTests:         TInterfaceList;
    FSelectedTests: TInterfaceList;
    FSelectedTestCount: Integer;
    FTotalTime:     Int64;
    FNoChecksStr:   string;
    FUpdateTimer:   TTimer;
    FTimerExpired:  Boolean;
    TotalTestsCount: Integer;
    FMemLeakStr:    string;
    FMemBytesStr:   string;
    FBytes:         string;
    FIgnoreLeakStr: string;
    FMemLeakDetectedPtyOverridden: Boolean;
    FIgnoreSetUpTearDownLeakPtyOverridden: Boolean;
    FNoCheckExecutedPtyOverridden: Boolean;
    FPopupY: Integer;
    FPopupX: Integer;
    FHoldOptions: boolean;
    FTestFailed: Boolean;
    FSP: TGUISearchPanel;
    FSearchController: TGUISearchController;
    procedure ResetProgress;
    procedure MenuLooksInactive(ACanvas: TCanvas; ARect: TRect; Selected: Boolean;
      ATitle: string; TitlePosn: UINT; PtyOveridesGUI: boolean);
    procedure MenuLooksActive(ACanvas: TCanvas; ARect: TRect; Selected: Boolean;
      ATitle: string; TitlePosn: UINT);
    function  GetPropertyName(const Caption: string): string;
    procedure RefreshTestCount;
    procedure HoldOptions(const Value: boolean);
    function  ShowNodeChildrenFailures(const ANode: TTreeNode): TTreeNode;
    function StripAllCRLFs(const AString: string): string;
    function SplitPair(const APair: string; out AFirst, ASecond: string;
      const ASeparator: char): boolean;
    procedure CreateSearchPanel(const AOwner: TWinControl);
    procedure CreateSearchController(const ASearchPanel: TGUISearchPanel;
      const ATreeView: TTreeView);
    procedure InitResultsView;
    function FindStackTraceSourceReference(const AString: string;
      const AStartIndex: integer; out AFileName, ALineNumber: string): boolean;
    function FindMultiErrorSourceReference(const AString: string;
      const AStartIndex: integer; out AFileName, ALineNumber: string): boolean;
  protected
    procedure OnUpdateTimer(Sender: TObject);
    function  get_TestResult: TTestResult;
    procedure set_TestResult(const Value: TTestResult);
    procedure SetUp;
    procedure SetUpStateImages;
    procedure SetSuite(Value: ITestProxy);
    procedure ClearResult;
    procedure DisplayFailureMessage(Item :TListItem);
    procedure ClearFailureMessage;

    function  AddFailureItem(Failure: TTestFailure): TListItem;
    procedure UpdateStatus(const fullUpdate: Boolean);

    procedure FillTestTree(RootNode: TTreeNode; ATest: ITestProxy); overload;
    procedure FillTestTree(ATest: ITestProxy);                      overload;

    procedure UpdateNodeImage(Node: TTreeNode);
    procedure UpdateNodeState(Node: TTreeNode);
    procedure SetNodeState(Node: TTreeNode; Enabled :boolean);
    procedure SwitchNodeState(Node: TTreeNode);
    procedure UpdateTestTreeState;

    procedure MakeNodeVisible(Node :TTreeNode);
    procedure SetTreeNodeImage(Node :TTReeNode; imgIndex :Integer);
    procedure SelectNode(Node: TTreeNode);

    function  NodeToTest(Node :TTreeNode) :ITestProxy;
    function  TestToNode(Test :ITestProxy) :TTreeNode;
    function  SelectedTest :ITestProxy;
    procedure ListSelectedTests;
    procedure ListTestsFromHere;

    function  EnableTest(Test :ITestProxy) : boolean;
    function  DisableTest(Test :ITestProxy) : boolean;
    function  IncludeTest(Test :ITestProxy) : boolean;
    function  ExcludeTest(Test :ITestProxy) : boolean;
    procedure ApplyToTests(root :TTreeNode; const func :TTestFunc);

    procedure EnableUI(enable :Boolean);
    procedure RunTheTest(ATest: ITestProxy);

    procedure InitTree; virtual;

    function  IniFileName :string;
    function  GetIniFile(const FileName : string) : tCustomIniFile;

    procedure LoadRegistryAction;
    procedure SaveRegistryAction;

    procedure LoadFormPlacement;
    procedure SaveFormPlacement;

    procedure SaveConfiguration;
    procedure LoadConfiguration;

    procedure LoadSuiteConfiguration;
    procedure AutoSaveConfiguration;

    function  NodeIsGrandparent(ANode: TTreeNode): boolean;
    procedure CollapseNonGrandparentNodes(RootNode: TTreeNode);

    procedure ProcessClickOnStateIcon;
    procedure ClearStatusMessage;

    procedure CopyTestNametoClipboard(ANode: TTreeNode);

    procedure SetupCustomShortcuts;
    procedure SetupGUINodes;

    function SelectNodeIfTestEnabled(ANode: TTreeNode): boolean;
  public
    procedure AddSuccess(ATest: ITestProxy);
    procedure AddError(Failure: TTestFailure);
    procedure AddFailure(Failure: TTestFailure);
    procedure AddWarning(AWarning: TTestFailure);
    procedure Warning(const ATest: ITestProxy; const AMessage: string);

    class procedure RunTest(Test: ITestProxy);
    class procedure RunRegisteredTests;

    {: implement the ITestListener interface }
    procedure TestingStarts;
    procedure StartSuite(Suite: ITestProxy); virtual;
    procedure StartTest(Test: ITestProxy); virtual;
    procedure EndTest(Test: ITestProxy); virtual;
    procedure EndSuite(Suite: ITestProxy); virtual;
    procedure TestingEnds(TestResult :TTestResult);
    function  ShouldRunTest(const ATest :ITestProxy):boolean;
    procedure Status(const ATest: ITestProxy; AMessage: string);
    property SP: TGUISearchPanel read FSP;
    property VT: TTreeView read TestTree;
  published
    {: The Test Suite to be run in this runner }
    property Suite: ITestProxy read FSuite write SetSuite;
    {: The result of the last Test run }
    property TestResult : TTestResult read get_TestResult write set_TestResult;

  end;

//procedure RunTest(Test: ITestProxy);
procedure RunRegisteredTests;

//procedure RunTestModeless(Test: ITestProxy);
procedure RunRegisteredTestsModeless;
function  RunRegisteredTestsModelessUnattended: Integer;

implementation
uses
{$IFDEF FASTMM}
  FastMM4,
{$ENDIF}
  TestFrameworkProxy,
{$IFDEF XMLLISTENER}
  XMLListener,
{$ENDIF}
  TestListenerIface,
  Registry,
  XPVistaSupport,
  SysUtils,
  Clipbrd,
  Math,
  StrUtils,
  WatchFile,
  GUIActionRecorder;

{$BOOLEVAL OFF}  // Required or you'll get an AV
{$R *.DFM}

type
  TProgressBarCrack = class(TProgressBar);

const
  {: Section of the dunit.ini file where GUI information will be stored }
  cnConfigIniSection = 'GUITestRunner Config';

  {: Color constants for the progress bar and failure details panel }
  clOK        = clGreen;
  clFAILURE   = clFuchsia;
  clERROR     = clRed;

  {: Indexes of the color images used in the Test tree and failure list }
  imgNONE      = 0;
  imgRUNNING   = 1;
  imgRUN       = 2;
  imgOVERRIDE  = 3;
  imgWARNFAIL  = 4;
  imgFAILED    = 5;
  imgERROR     = 6;
  imgWARNING   = 7;
  imgEARLYEXIT = 8;

  {: Indexes of the images used for Test tree checkboxes }
  imgDISABLED        = 1;
  imgPARENT_DISABLED = 2;
  imgENABLED         = 3;
  imgEXCLUDED        = 4;
  imgPARENT_EXCLUDED = 5;

  siTestsRun = 0;
  siFailures = 1;
  siErrors = 2;
  siWarnings = 3;
  siTestTime = 4;
  siTotalTestTime = 5;

  // TGUITestCase automation property.
  CGUIAutomationCommandPrefix = 'Automation';


procedure RunTest(Test: ITestProxy);
begin
  with TGUITestRunner.Create(nil) do
  begin
    try
      Suite := Test;
      ShowModal;
    finally
      Free;
    end;
    if Assigned(Test) then
      Test.ReleaseTests;
  end;
end;

procedure RunTestModeless(Test: ITestProxy);
var
  GUI :TGUITestRunner;
begin
  Application.CreateForm(TGUITestRunner, GUI);
  GUI.Suite := Test;
  GUI.Show;
  Test.ReleaseTests;
end;

procedure RunRegisteredTests;
begin
  RunTest(RegisteredTests);
end;

procedure RunRegisteredTestsModeless;
begin
  RunTestModeless(RegisteredTests);
end;

// Run all tests in unattended mode, i.e. automatically
function RunRegisteredTestsModelessUnattended: Integer;
var
  GUI :TGUITestRunner;
begin
  // Create and show the GUI runner form

  Application.CreateForm(TGUITestRunner, GUI);
  GUI.Suite := RegisteredTests;
  GUI.Show;

  GUI.RunActionExecute(GUI.RunItem);

  // Process messages until the tests have finished

  repeat
    try
      Application.HandleMessage;
    except
      Application.HandleException(Application);
    end;
  until TGUITestRunner(Application.MainForm).RunAction.Enabled;

  // Return the number of errors and failures and free the runner form

  Result := 0; //GUI.ErrorCount + GUI.FailureCount;

  GUI.Free;
end;

{ TGUITestRunner }

procedure TGUITestRunner.InitResultsView;
var
  totalTests: TListItem;
  i: integer;

begin
  ResultsView.Items.Clear;
  totalTests := ResultsView.Items.Add;

  for i := siTestsRun to siTotalTestTime do
    totalTests.SubItems.Add('');

end;

procedure TGUITestRunner.InitTree;
begin
  FTests.Clear;
  FillTestTree(Suite);
  SetUp;
  if HideTestNodesOnOpenAction.Checked then
    HideTestNodesAction.Execute
  else
    ExpandAllNodesAction.Execute;
  TestTree.Selected := TestTree.Items.GetFirstNode;
end;

function TGUITestRunner.NodeToTest(Node: TTreeNode): ITestProxy;
var
  idx: Integer;
begin
  Result := nil;
  if not assigned(Node) then
    Exit;

  idx  := Integer(Node.data);
  if (idx >= 0) and (idx < FTests.Count) then
    result := FTests[idx] as ITestProxy;
end;

procedure TGUITestRunner.OnUpdateTimer(Sender: TObject);
begin
  FTimerExpired := True;
  FUpdateTimer.Enabled := False;
end;

function TGUITestRunner.TestToNode(Test: ITestProxy): TTreeNode;
begin
  Result := nil;
  if not Assigned(Test) then
    Exit;

  if Assigned(Test.GUIObject) then
    Result := Test.GUIObject as TTreeNode;
end;

function TGUITestRunner.ShouldRunTest(const ATest: ITestProxy): boolean;
begin
  Result := not ATest.Excluded;
  if Result and (FSelectedTests <> nil) then
    Result := FSelectedTests.IndexOf(ATest as ITestProxy) >= 0;
end;

procedure TGUITestRunner.StartTest(Test: ITestProxy);
var
  Node :TTreeNode;
begin
  assert(assigned(TestResult));
  assert(assigned(Test));
  Node := TestToNode(Test);
  assert(assigned(Node));
  SetTreeNodeImage(Node, imgRUNNING);
  if ShowTestedNodeAction.Checked then
  begin
    MakeNodeVisible(Node);
    TestTree.Update;
  end;
  ErrorMessageRTF.Lines.Clear;
  UpdateStatus(False);
end;

procedure TGUITestRunner.EndTest(Test: ITestProxy);
begin
  UpdateStatus(False);
end;

procedure TGUITestRunner.TestingStarts;
begin
  FTotalTime := 0;
  UpdateStatus(True);
  TProgressBarCrack(ScoreBar).Color := clOK;
  TProgressBarCrack(ScoreBar).RecreateWnd;
  ClearStatusMessage;
end;

procedure TGUITestRunner.AddSuccess(ATest: ITestProxy);
var
  LOverridesGUI: Boolean;
  LHasRunTimePropsSet: Boolean;
begin
  assert(assigned(ATest));
  if not IsTestMethod(ATest) then
    SetTreeNodeImage(TestToNode(ATest), imgRUN)
  else
  begin
    FTestFailed := False;
    if ShowOverriddenFailuresMenuItem.Checked then
    begin
      LOverridesGUI :=
        ((FailIfNoChecksExecutedMenuItem.Checked and not ATest.FailsOnNoChecksExecuted) or
         (FailTestCaseIfMemoryLeakedMenuItem.Checked and not ATest.FailsOnMemoryLeak)) or
         (FailTestCaseIfMemoryLeakedMenuItem.Checked and
            IgnoreMemoryLeakInSetUpTearDownMenuItem.Checked and
           not ATest.IgnoreSetUpTearDownLeaks) or ATest.LeakAllowed;

      ATest.IsOverridden := LOverridesGUI;

      if LOverridesGUI then
      begin
        if ATest.IsWarning then
          SetTreeNodeImage(TestToNode(ATest), imgWARNFAIL)
        else
          SetTreeNodeImage(TestToNode(ATest), imgOVERRIDE)
      end
      else
        SetTreeNodeImage(TestToNode(ATest), imgRUN);
    end
    else
    if PropertyOverrideMenuItem.Checked then
    begin
      LHasRunTimePropsSet :=
        ((ATest.FailsOnNoChecksExecuted and not FailIfNoChecksExecutedMenuItem.Checked) or
         (ATest.FailsOnMemoryLeak and not FailTestCaseIfMemoryLeakedMenuItem.Checked) or
         (FailTestCaseIfMemoryLeakedMenuItem.Checked and
          (not IgnoreMemoryLeakInSetUpTearDownMenuItem.Checked and
            ATest.IgnoreSetUpTearDownLeaks)) or
         (ATest.AllowedMemoryLeakSize <> 0));

      if LHasRunTimePropsSet then
        SetTreeNodeImage(TestToNode(ATest), imgOVERRIDE)
      else
        SetTreeNodeImage(TestToNode(ATest), imgRUN);
    end

    else
    if ShowWarnedTestToolButton.Down and ATest.IsWarning then
      SetTreeNodeImage(TestToNode(ATest), imgWARNING)

    else
    if ShowSummaryLevelExitsToolButton.Down and ATest.EarlyExit then
      SetTreeNodeImage(TestToNode(ATest), imgEARLYEXIT)
    else
      SetTreeNodeImage(TestToNode(ATest), imgRUN);
  end;
end;

procedure TGUITestRunner.AddWarning(AWarning: TTestFailure);
var
  ListItem: TListItem;
begin
  if EnableWarningsMenuItem.Checked then
  begin
    ListItem := AddFailureItem(AWarning);
    ListItem.ImageIndex := imgWARNING;
    SetTreeNodeImage(TestToNode(AWarning.failedTest), imgWARNING);
    UpdateStatus(True);
  end
  else
    AddSuccess(AWarning.FailedTest);
end;

procedure TGUITestRunner.AddError(Failure: TTestFailure);
var
  ListItem: TListItem;
begin
  FTestFailed := True;
  ListItem := AddFailureItem(Failure);
  ListItem.ImageIndex := imgERROR;
  TProgressBarCrack(ScoreBar).Color := clERROR;
  TProgressBarCrack(ScoreBar).RecreateWnd;
  SetTreeNodeImage(TestToNode(Failure.failedTest), imgERROR);
  UpdateStatus(True);
end;

procedure TGUITestRunner.AddFailure(Failure: TTestFailure);
var
  ListItem: TListItem;
begin
  FTestFailed := True;
  ListItem := AddFailureItem(Failure);
  ListItem.ImageIndex := imgFAILED;
  if TestResult.ErrorCount = 0 then //Dont override higher priority error colour
  begin
    TProgressBarCrack(ScoreBar).Color := clFAILURE;
    TProgressBarCrack(ScoreBar).RecreateWnd;
  end;
  SetTreeNodeImage(TestToNode(Failure.failedTest), imgFAILED);
  UpdateStatus(True);
end;

function TGUITestRunner.IniFileName: string;
const
  TEST_INI_FILE = 'dunit.ini';
begin
  result := LocalAppDataPath  + TEST_INI_FILE;
end;

procedure TGUITestRunner.LoadFormPlacement;
begin
  with GetIniFile(IniFileName) do
  try
    Self.SetBounds(
                   ReadInteger(cnConfigIniSection, 'Left',   Left),
                   ReadInteger(cnConfigIniSection, 'Top',    Top),
                   ReadInteger(cnConfigIniSection, 'Width',  Width),
                   ReadInteger(cnConfigIniSection, 'Height', Height)
                  );
    if ReadBool(cnConfigIniSection, 'Maximized', False) then
      WindowState := wsMaximized;
  finally
    Free;
  end;
end;

procedure TGUITestRunner.SaveFormPlacement;
begin
  with GetIniFile(IniFileName) do
    try
      WriteBool(cnConfigIniSection, 'AutoSave', AutoSaveAction.Checked);

      if WindowState <> wsMaximized then
      begin
        WriteInteger(cnConfigIniSection, 'Left',   Left);
        WriteInteger(cnConfigIniSection, 'Top',    Top);
        WriteInteger(cnConfigIniSection, 'Width',  Width);
        WriteInteger(cnConfigIniSection, 'Height', Height);
      end;

      WriteBool(cnConfigIniSection, 'Maximized', WindowState = wsMaximized);
    finally
      Free
    end;
end;

procedure TGUITestRunner.LoadConfiguration;
var
  i: Integer;
begin
  LoadRegistryAction;
  LoadFormPlacement;
  LoadSuiteConfiguration;
  with GetIniFile(IniFileName) do
  try
    with AutoSaveAction do
      Checked := ReadBool(cnConfigIniSection, 'AutoSave', Checked);

    { center splitter location }
    with ResultsPanel do
      Height := ReadInteger(cnConfigIniSection, 'ResultsPanel.Height', Height);

    { error splitter location }
    with ErrorBoxPanel do
      Height := ReadInteger(cnConfigIniSection, 'ErrorMessage.Height', Height);
    with ErrorBoxVisibleAction do
      Checked := ReadBool(cnConfigIniSection, 'ErrorMessage.Visible', Checked);

    ErrorBoxSplitter.Visible := ErrorBoxVisibleAction.Checked;
    ErrorBoxPanel.Visible    := ErrorBoxVisibleAction.Checked;

    { failure list configuration }
    with FailureListView do begin
      for i := 0 to Columns.Count-1 do
      begin
        Columns[i].Width := Max(4, ReadInteger(cnConfigIniSection,
                                   Format('FailureList.ColumnWidth[%d]', [i]),
                                   Columns[i].Width));
      end;
    end;

    { other options }
    HideTestNodesOnOpenAction.Checked := ReadBool(cnConfigIniSection,
      'HideTestNodesOnOpen', HideTestNodesOnOpenAction.Checked);
    BreakOnFailuresAction.Checked := ReadBool(cnConfigIniSection,
      'BreakOnFailures', BreakOnFailuresAction.Checked);
    ShowTestedNodeAction.Checked := ReadBool(cnConfigIniSection,
      'SelectTestedNode', ShowTestedNodeAction.Checked);

    ReportMemoryLeakTypeOnShutdownAction.Checked := ReadBool(cnConfigIniSection,
      'ReportMemoryLeakTypes', ReportMemoryLeakTypeOnShutdownAction.Checked);
    ShowTestCasesWithRunTimePropertiesAction.Checked := ReadBool(cnConfigIniSection,
      'ShowRunTimeProperties', ShowTestCasesWithRunTimePropertiesAction.Checked);
    ShowOverriddenFailuresAction.Checked := ReadBool(cnConfigIniSection,
      'ShowOverriddenFailures', ShowOverriddenFailuresAction.Checked);
    ShowEarlyExitedTestAction.Checked := ReadBool(cnConfigIniSection,
      'ShowEarlyExitTests', ShowEarlyExitedTestAction.Checked);

    FPopupX := ReadInteger(cnConfigIniSection,'PopupX', 350);
    FPopupY := ReadInteger(cnConfigIniSection,'PopupY', 30);

    // Read settings common to all test runners
    FailIfNoChecksExecutedAction.Checked := ReadBool(cnRunners,
      'FailOnNoChecksExecuted', FailIfNoChecksExecutedAction.Checked);
    FailTestCaseIfMemoryLeakedAction.Checked := ReadBool(cnRunners,
      'FailOnMemoryLeaked', FailTestCaseIfMemoryLeakedAction.Checked);
    EnableWarningsAction.Checked := ReadBool(cnRunners,
      'EnableWarnings', EnableWarningsAction.Checked);
    InhibitSummaryLevelChecksAction.Checked := ReadBool(cnRunners,
      'InhibitSummaryLevelChecks', InhibitSummaryLevelChecksAction.Checked);
    IgnoreMemoryLeakInSetUpTearDownAction.Checked := ReadBool(cnRunners,
      'IgnoreSetUpTearDownLeaks', IgnoreMemoryLeakInSetUpTearDownAction.Checked);
  finally
    Free;
  end;

  if Suite <> nil then
    UpdateTestTreeState;
end;

procedure TGUITestRunner.AutoSaveConfiguration;
begin
  if AutoSaveAction.Checked then
    SaveConfiguration;
end;

procedure TGUITestRunner.SaveConfiguration;
var
  i: Integer;
begin
  if Suite <> nil then
    Suite.SaveConfiguration(IniFileName, UseRegistryAction.Checked, True);

  SaveFormPlacement;
  SaveRegistryAction;

  with GetIniFile(IniFileName) do
  try
    { center splitter location }
    WriteInteger(cnConfigIniSection, 'ResultsPanel.Height',
      ResultsPanel.Height);

    { error box }
    WriteInteger(cnConfigIniSection, 'ErrorMessage.Height',
      ErrorBoxPanel.Height);
    WriteBool(cnConfigIniSection, 'ErrorMessage.Visible',
      ErrorBoxVisibleAction.Checked);

    { failure list configuration }
    with FailureListView do begin
      for i := 0 to Columns.Count-1 do
      begin
       WriteInteger(cnConfigIniSection,
                     Format('FailureList.ColumnWidth[%d]', [i]),
                     Columns[i].Width);
      end;
    end;

    { other options }
    WriteBool(cnConfigIniSection, 'HideTestNodesOnOpen',      HideTestNodesOnOpenAction.Checked);
    WriteBool(cnConfigIniSection, 'BreakOnFailures',          BreakOnFailuresAction.Checked);
    WriteBool(cnConfigIniSection, 'ReportMemoryLeakTypes',    ReportMemoryLeakTypeOnShutdownAction.Checked);
    WriteBool(cnConfigIniSection, 'SelectTestedNode',         ShowTestedNodeAction.Checked);
    WriteBool(cnConfigIniSection, 'ShowRunTimeProperties',    ShowTestCasesWithRunTimePropertiesAction.Checked);
    WriteBool(cnConfigIniSection, 'ShowOverriddenFailures',   ShowOverriddenFailuresAction.Checked);
    WriteBool(cnConfigIniSection, 'ShowEarlyExitTests',       ShowEarlyExitedTestAction.Checked);

    WriteInteger(cnConfigIniSection, 'PopupX',                FPopupX);
    WriteInteger(cnConfigIniSection, 'PopupY',                FPopupY);

    // Settings common to all test runners
    WriteBool(cnRunners, 'FailOnNoChecksExecuted',    FailIfNoChecksExecutedAction.Checked);
    WriteBool(cnRunners, 'FailOnMemoryLeaked',        FailTestCaseIfMemoryLeakedAction.Checked);
    WriteBool(cnRunners, 'EnableWarnings',            EnableWarningsAction.Checked);
    WriteBool(cnRunners, 'IgnoreSetUpTearDownLeaks',  IgnoreMemoryLeakInSetUpTearDownAction.Checked);
    WriteBool(cnRunners, 'InhibitSummaryLevelChecks', InhibitSummaryLevelChecksAction.Checked);
  finally
    Free;
  end;
end;

procedure TGUITestRunner.TestingEnds(TestResult: TTestResult);
var
  idx: Integer;
  AProxy : ITestProxy;
begin
  for idx := 0 to FTests.Count-1 do
  begin
    AProxy := (FTests[idx] as ITestProxy);
    AProxy.IsOverridden := False;
  end;
  FTotalTime := TestResult.TotalTime;
  UpdateStatus(True);
end;

procedure TGUITestRunner.StartSuite(Suite: ITestProxy);
begin
end;

procedure TGUITestRunner.EndSuite(Suite: ITestProxy);
begin
end;

procedure TGUITestRunner.UpdateNodeState(Node: TTreeNode);
var
  Test: ITestProxy;
begin
  assert(assigned(Node));
  Test := NodeToTest(Node);
  assert(assigned(Test));

  UpdateNodeImage(Node);

  if Node.HasChildren then
  begin
    Node := Node.getFirstChild;
    while Node <> nil do
    begin
      UpdateNodeState(Node);
      Node := Node.getNextSibling;
    end;
  end;
end;

procedure TGUITestRunner.RefreshTestCount;
begin
  TotalTestsCount := (FSuite as ITestProxy).CountEnabledTestCases;
  if Assigned(Suite) then
    ResultsView.Items[0].Caption := IntToStr(TotalTestsCount)
  else
    ResultsView.Items[0].Caption := '';
end;

procedure TGUITestRunner.SetNodeState(Node: TTreeNode; Enabled :boolean);
var
  MostSeniorChanged :TTReeNode;
begin
   assert(Node <> nil);

   if (NodeToTest(Node).Enabled <> Enabled) then
     NodeToTest(Node).Enabled := Enabled;

   MostSeniorChanged := Node;
   if Enabled then
   begin
     while Node.Parent <> nil do
     begin
       Node := Node.Parent;
       if not NodeToTest(Node).Enabled then
       begin // changed
          NodeToTest(Node).Enabled := true;
          MostSeniorChanged := Node;
          UpdateNodeImage(Node);
       end
     end;
   end;
   TestTree.Items.BeginUpdate;
   try
     UpdateNodeState(MostSeniorChanged);
   finally
     TestTree.Items.EndUpdate;
   end;
  RefreshTestCount;
end;

procedure TGUITestRunner.SwitchNodeState(Node: TTreeNode);
begin
   assert(Node <> nil);

   SetNodeState(Node, not NodeToTest(Node).Enabled);
end;

procedure TGUITestRunner.UpdateTestTreeState;
var
  Node :TTreeNode;
begin
  if TestTree.Items.Count > 0 then
  begin
    TestTree.Items.BeginUpdate;
    try
      Node := TestTree.Items.GetFirstNode;
      while Node <> nil do
      begin
        UpdateNodeState(Node);
        Node := Node.getNextSibling;
      end
    finally
      TestTree.Items.EndUpdate;
    end;
  end;
end;

procedure TGUITestRunner.UpdateStatus(const fullUpdate:Boolean);
var
  i: Integer;
  TestNumber: Integer;
  Results : TListItem;

   function FormatElapsedTime(milli: Int64):string;
   var
     H,nn,ss,zzz: Cardinal;
   begin
     H := milli div 3600000;
     milli := milli mod 3600000;
     nn := milli div 60000;
     milli := milli mod 60000;
     ss := milli div 1000;
     milli := milli mod 1000;
     zzz := milli;
     Result := Format('%d:%2.2d:%2.2d.%3.3d', [H, nn, ss, zzz]);
   end;
begin
  Assert(ResultsView.Items.Count > 0, 'ResultsView unpopulated from .dfm file');
  Results := ResultsView.Items[0];

  if fullUpdate then
    if Assigned(Suite) then
      Results.Caption := IntToStr(TotalTestsCount)
    else
      Results.Caption := '';

  if TestResult <> nil then
  begin
    // Save the test number as we use it a lot
    TestNumber := TestResult.RunCount;
    FTotalTime := TestResult.TotalTime;
    if fullUpdate or FTimerExpired or ((TestNumber and 15) = 0) or FTestFailed then
    begin
      Results.SubItems[siTestsRun] := IntToStr(TestNumber);
      Results.SubItems[siFailures] := IntToStr(TestResult.FailureCount);
      Results.SubItems[siErrors] := IntToStr(TestResult.ErrorCount);
      Results.SubItems[siWarnings] := IntToStr(TestResult.WarningCount + TestResult.Overrides);
      Results.SubItems[siTestTime] := FormatElapsedTime(TestResult.TotalTime);
      Results.SubItems[siTotalTestTime] := FormatElapsedTime(FTotalTime);
      with TestResult do
      begin
        ScoreBar.Position  := TestNumber - (FailureCount + ErrorCount);
        ProgressBar.Position := TestNumber;

        // There is a possibility for zero tests
        if (TestNumber = 0) and (TotalTestsCount = 0) then
          LbProgress.Caption := '100%'
        else
          LbProgress.Caption := IntToStr((100 * ScoreBar.Position) div ScoreBar.Max) + '%';
      end;
      if (TestNumber < TotalTestsCount) then
      begin
        FTimerExpired := False;
        FUpdateTimer.Enabled := True;
      end;
    end;
    // Allow the display to catch up and check for key strokes and Timer event
    ResultsPanel.Update;
  end
  else
  begin  {TestResult = nil}
    if (Results.Caption = '0') or (Results.Caption = '') then
    begin
      for i := siTestsRun to siTotalTestTime do
        Results.SubItems[i] := ''
    end
    else
    begin
      Results.SubItems[siTestTime] := FormatElapsedTime(SelectedTest.ElapsedTestTime);
      Results.SubItems[siTotalTestTime] := FormatElapsedTime(FTotalTime);
    end;

    ResetProgress;
  end;

  if fullUpdate then
    Update;
  Application.ProcessMessages;
end;

procedure TGUITestRunner.ResetProgress;
begin
  TProgressBarCrack(ScoreBar).ParentColor := True;
  TProgressBarCrack(ScoreBar).RecreateWnd;
  ScoreBar.Position := 0;
  ProgressBar.Position := 0;
  LbProgress.Caption := '';
end;

function DeControl(const AString: string): string;
var
  i: Integer;
  LChr: Char;
begin
  Result := '';
  if AString = '' then
    Exit;

  for i:= 1 to Length(AString) do
  begin
    LChr := AString[i];
    if Ord(LChr) > $1F then
      Result := Result + LChr;
  end;
end;

{$IFNDEF VER130}
  {$IFNDEF VER140}
    {$WARN UNSAFE_CAST OFF}
  {$ENDIF}
{$ENDIF}
function TGUITestRunner.AddFailureItem(Failure: TTestFailure): TListItem;
var
  Item : TListItem;
begin
  assert(assigned(Failure));
  Item := FailureListView.Items.Add;
  Result := Item;
  Item.data := Pointer(TestToNode(Failure.FailedTest));
  Item.Caption := Failure.FailedTest.Name;                      // Caption
  Item.SubItems.Add(Failure.thrownExceptionName);               // 0 exception type
  Item.SubItems.Add(DeControl(Failure.thrownExceptionMessage)); // 1 filtered errormessage
  Item.SubItems.Add(Failure.LocationInfo);                      // 2 unit name and line number
  // These are not shown in display
  Item.SubItems.Add(Failure.FailedTest.ParentPath + '.');       // 3 full path to test method
  Item.SubItems.Add(Failure.thrownExceptionMessage);            // 4 unfiltered errormessage
  {$IFDEF REPORT_STACK_TRACE}
    Item.SubItems.Add(Failure.StackTrace);                      // 5 stack trace if collected
  {$ENDIF}
end;

procedure TGUITestRunner.FillTestTree(RootNode: TTreeNode; ATest: ITestProxy);
var
  TestTests: IInterfaceList;
  i: Integer;
begin
  if ATest = nil then
    EXIT;

  RootNode := TestTree.Items.AddChild(RootNode, ATest.Name);
  RootNode.data := TObject(FTests.Add(ATest));

  TestTests := ATest.Tests;
  for i := 0 to TestTests.count - 1 do
  begin
    FillTestTree(RootNode, TestTests[i] as ITestProxy);
  end;
end;

procedure TGUITestRunner.FillTestTree(ATest: ITestProxy);
begin
  TestTree.Items.Clear;
  FTests.Clear;
  fillTestTree(nil, Suite);
end;

procedure TGUITestRunner.SetTreeNodeImage(Node :TTReeNode; imgIndex :Integer);
begin
  while Node <> nil do
  begin
    if imgIndex > Node.ImageIndex then
    begin
       Node.ImageIndex    := imgIndex;
       Node.SelectedIndex := imgIndex;
    end;
    if imgIndex = imgRUNNING then
      Node := nil
    else
      Node := Node.Parent;
  end;
end;

procedure TGUITestRunner.SetSuite(Value: ITestProxy);
begin
  if FSuite <> nil then
    FSuite.ReleaseTests;

  FSuite := Value;
  if FSuite <> nil then
  begin
    LoadSuiteConfiguration;
    EnableUI(True);
    InitTree;
  end
  else
    EnableUI(False)
end;

procedure TGUITestRunner.DisplayFailureMessage(Item: TListItem);
var
  hlColor :TColor;
  Test    :ITestProxy;
  Status  :string;
begin
  TestTree.Selected := TTreeNode(Item.data);
  Test := NodeToTest(TestTree.Selected);
  case Ord(Test.ExecutionStatus) of
    0 {_Ready}     : hlColor := clGray;
    1 {_Running}   : hlColor := clNavy;
    2 {_HaltTest}  : hlColor := clBlack;
    3 {_Passed}    : hlColor := clLime;
    4 {_Warning}   : hlColor := clGreen;
    5 {_Stopped}   : hlColor := clBlack ;
    6 {_Failed}    : hlColor := clFuchsia;
    7 {_Break}     : hlColor := clBlack;
    8 {_Error}     : hlColor := clRed;
    else
      hlColor := clPurple;
  end;

  with ErrorMessageRTF do
    begin
      Clear;
      SelAttributes.Size  := self.Font.Size;
      SelAttributes.Style := [fsBold];
      SelText := Item.SubItems[3] + Item.Caption + ': '; //ParentPath + Test name

      SelAttributes.Color := hlColor;
      SelAttributes.Style := [fsBold];
      SelText := Item.SubItems[0];        // Exception type

      Lines.Add('');
      SelAttributes.Size  := 11;
      SelAttributes.Color := clWindowText;
      SelAttributes.Style := [];
      SelText := 'at ' + Item.SubItems[2]; // Location info

      if Item.SubItems[1] <> '' then
      begin
        SelAttributes.Color := clWindowText;
        Lines.Add('');
        SelAttributes.Style := [];
        SelText := Item.SubItems[4]; // unfiltered error message
        SelAttributes.Size  := self.Font.Size;
      end;

      Status := Test.Status;
      if Status <> '' then
      begin
        Lines.Add('');
        Lines.Add('');
        SelAttributes.Style := [fsBold];
        Lines.Add('Status Messages');
        SelAttributes.Style := [];
        Lines.Add(Status);
      end;

      {$IFDEF REPORT_STACK_TRACE}
        if Item.SubItems[5] <> '' then
        begin
          Lines.Add('');
          SelAttributes.Style := [fsBold];
          Lines.Add('StackTrace');
          SelAttributes.Style := [];
          SelText := Item.SubItems[5];
        end;
      {$ENDIF}
    end
end;

procedure TGUITestRunner.ClearFailureMessage;
begin
  ErrorMessageRTF.Clear;
end;

procedure TGUITestRunner.ClearResult;
begin
  if FTestResult <> nil then
  begin
    FTestResult := nil;
    ClearFailureMessage;
  end;
end;

procedure TGUITestRunner.HoldOptions(const Value: boolean);
// Prevents selected options from being changed while executing tests
// but preserves enabled image.
begin
  FHoldOptions := Value;
end;

procedure TGUITestRunner.SetUp;
var
  i: Integer;
  Node: TTreeNode;
  Results: TListItem;

begin
  FailureListView.Items.Clear;
  ResetProgress;
  Update;
  Assert(ResultsView.Items.Count > 0, 'ResultsView unpopulated in .dfm file');
  Results := ResultsView.Items[0];
  Results.Caption := '';
  for i := siTestsRun to siTotalTestTime do
    Results.SubItems[i] := '';

  if Suite <> nil then
  begin
    TotalTestsCount := Suite.countEnabledTestCases;
    Results.Caption := IntToStr(TotalTestsCount);
    ProgressBar.Max := TotalTestsCount;
  end
  else
    ProgressBar.Max:= 10000;

  ScoreBar.Max := ProgressBar.Max;

  for i := 0 to TestTree.Items.Count - 1 do
  begin
    Node := TestTree.Items[i];
    Node.ImageIndex    := imgNONE;
    Node.SelectedIndex := imgNONE;
  end;
  UpdateTestTreeState;
end;

procedure TGUITestRunner.EnableUI(enable: Boolean);
begin
  SelectAllAction.Enabled    := enable;
  DeselectAllAction.Enabled  := enable;
  SelectFailedAction.Enabled := enable;
  SelectCurrentAction.Enabled := enable;
  DeselectCurrentAction.Enabled := enable;
  HideTestNodesAction.Enabled   := enable;
  ExpandAllNodesAction.Enabled  := enable;
end;

procedure TGUITestRunner.FormCreate(Sender: TObject);
begin
  inherited;
  CreateSearchPanel(SearchBasePanel);
  CreateSearchController(SP, VT);
  FTests := TInterfaceList.Create;
  LoadConfiguration;

  TimeSeparator := ':';
  SetUpStateImages;
  SetupCustomShortcuts;
  TestTree.Items.Clear;
  EnableUI(false);
  ClearFailureMessage;
  FUpdateTimer := TTimer.Create(Self);
  FUpdateTimer.Interval := 200;
  FUpdateTimer.Enabled := False;
  FUpdateTimer.OnTimer := OnUpdateTimer;
  InitResultsView;
  SetUp;
  HoldOptions(False);

  {$IFDEF FASTMM}
    FailTestCaseIfMemoryLeakedAction.Enabled := True;
    {$IFNDEF VER150} // ToDo: Make this hack to get Delphi 7 compiling more robust
      ReportMemoryLeaksOnShutdown := ReportMemoryLeakTypeOnShutdownAction.Checked;
    {$ENDIF}
  {$ELSE}
    FailTestCaseIfMemoryLeakedAction.Enabled := False;
    ReportMemoryLeakTypeOnShutdownAction.Checked := False;
    ReportMemoryLeakTypeOnShutdownAction.Enabled := False;
  {$ENDIF}

  if not FailTestCaseIfMemoryLeakedAction.Enabled then
    FailTestCaseIfMemoryLeakedAction.Checked := False;
  IgnoreMemoryLeakInSetUpTearDownAction.Enabled :=
    FailTestCaseIfMemoryLeakedAction.Checked;
  if not IgnoreMemoryLeakInSetUpTearDownAction.Enabled then
    IgnoreMemoryLeakInSetUpTearDownAction.Checked := False;
end;

procedure TGUITestRunner.FormDestroy(Sender: TObject);
begin
  ClearResult;
  AutoSaveConfiguration;
  FreeAndNil(FTests); // Note this is an object full of Interface refs
  Suite := nil;       // Take down the test proxys
  ClearRegistry;      // Take down the Registered tests
  FreeAndNil(FSearchController);
  inherited;
end;

procedure TGUITestRunner.FormShow(Sender: TObject);
begin
  { Set up the GUI nodes in the test nodes. We do it here because the form,
    the tree and all its tree nodes get recreated in TCustomForm.ShowModal
    in D8+ so we cannot do it sooner. }


  SetupGUINodes;
end;

procedure TGUITestRunner.TestTreeClick(Sender: TObject);
begin
  if FRunning then
    EXIT;

  ProcessClickOnStateIcon;
  TestTreeChange(Sender, TestTree.Selected);
end;

function TGUITestRunner.ShowNodeChildrenFailures(const ANode: TTreeNode): TTreeNode;
var
  idx: Integer;
  idy: Integer;
  LNode: TTreeNode;

begin
  Result := ANode;
  if ANode = nil then
    Exit;

  for idx := 0 to ANode.Count-1 do
  begin
    LNode := ANode.Item[idx];
    if LNode.HasChildren then
      ShowNodeChildrenFailures(LNode)
    else
    begin
      for idy := 0 to FailureListView.Items.Count-1 do
      begin
        if Pointer(TTreeNode(FailureListView.Items[idy].Data)) = Pointer(LNode) then
        begin
          ErrorMessageRTF.Lines.Add(FailureListView.Items[idy].SubItems[3] +
            FailureListView.Items[idy].Caption);  // ParentPath + Test Name
          ErrorMessageRTF.Lines.Add(FailureListView.Items[idy].SubItems[0]); //Exception
          ErrorMessageRTF.Lines.Add(FailureListView.Items[idy].SubItems[4]); //unfiltered error message
          ErrorMessageRTF.Lines.Add('at ' + FailureListView.Items[idy].SubItems[2]);
          {$IFDEF REPORT_STACK_TRACE}
            if (Trim(FailureListView.Items[idy].SubItems[5]) <> '') then
            begin
              ErrorMessageRTF.Lines.Add(FailureListView.Items[idy].SubItems[5]);
              ErrorMessageRTF.Lines.Add('');
            end;
          {$ENDIF}
        end;
      end;
    end;
  end;
end;

procedure TGUITestRunner.TestTreeChange(Sender: TObject; Node: TTreeNode);
var
  i: Integer;
begin
  if (Node <> nil) and (Node = TestTree.Selected) then
  begin
    if Node.HasChildren then
    begin  // Dont slow things down while executiong tests.
      if FHoldOptions then
        Exit;

      with ErrorMessageRTF do
      begin
        Clear;
        Font.Size  := 10;
        Font.Style := [];
      end;
      try
        ErrorMessageRTF.Hide;
        ShowNodeChildrenFailures(Node)
      finally
        ErrorMessageRTF.Show;
      end;
    end
    else
    begin
      FailureListView.Selected := nil;
      for i := 0 to FailureListView.Items.count - 1 do
      begin
        if TTreeNode(FailureListView.Items[i].Data) = Node then
        begin
          FailureListView.Selected := FailureListView.Items[i];
          break;
        end;
      end;
      UpdateStatus(True);
    end;
  end;
end;

procedure TGUITestRunner.FailureListViewClick(Sender: TObject);
begin
  if FailureListView.Selected <> nil then
  begin
    TestTree.Selected := TTreeNode(FailureListView.Selected.data);
  end;
end;

function TGUITestRunner.SplitPair(const APair: string;
  out AFirst, ASecond: string; const ASeparator: char): boolean;
var
  LSeparatorPos: integer;
begin
  LSeparatorPos := Pos(ASeparator, APair);

  if LSeparatorPos > 0 then
  begin
    Result := true;
    AFirst := Copy(APair, 1, LSeparatorPos - 1);
    ASecond := Copy(APair, LSeparatorPos + 1, Length(APair));
  end
  else
  begin
    Result := false;
    AFirst := APair;
    ASecond := '';
  end;
end;

{$WARN UNSAFE_CODE OFF}
function TGUITestRunner.StripAllCRLFs(const AString: string): string;
var
  Src, Dst: PChar;
begin
  SetLength(Result, Length(AString));
  Src := @AString[1];
  Dst := @Result[1];

  while Src^ <> #0 do
  begin

    if (Src^ <> #13) and (Src^ <> #10) then
    begin
      Dst^ := Src^;
      Inc(Dst);
    end;

    Inc(Src);
  end;

  // Add null terminator
  Dst^ :=  Src^;
  // re-sync string length with position of null terminator
  Result := PChar(Result);
end;
{$WARN UNSAFE_CODE ON}

procedure TGUITestRunner.FailureListViewDblClick(Sender: TObject);
var
  LFailureLocation: string;
  LFailureFileName, LFailureLineNumber: string;

begin
  if FailureListView.Selected <> nil then
  begin
    LFailureLocation := FailureListView.Selected.SubItems[2];

    if SplitPair(LFailureLocation, LFailureFileName, LFailureLineNumber, ':') and
      (StrToIntDef(LFailureLineNumber, 0) > 0) then
      WriteWatchFile(LFailureFileName, LFailureLineNumber);
      
  end;

end;

procedure TGUITestRunner.FailureListViewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if not Selected then
    ClearFailureMessage
  else
    DisplayFailureMessage(Item);
end;

function TGUITestRunner.DisableTest(Test: ITestProxy): boolean;
begin
  Test.Enabled := false;
  result := true;
end;

function TGUITestRunner.EnableTest(Test: ITestProxy): boolean;
begin
  Test.Enabled := true;
  result := true;
end;

function TGUITestRunner.IncludeTest(Test: ITestProxy): boolean;
begin
  Test.Excluded := False;
  result := true;
end;

function TGUITestRunner.ExcludeTest(Test: ITestProxy): boolean;
begin
  Test.Excluded := True;
  result := true;
end;

procedure TGUITestRunner.ApplyToTests(root :TTreeNode; const func :TTestFunc);

  procedure DoApply(RootNode :TTreeNode);
  var
    Test: ITestProxy;
    Node: TTreeNode;
  begin
    if RootNode <> nil then
    begin
      Test := NodeToTest(RootNode);
      if func(Test) then
      begin
        Node := RootNode.getFirstChild;
        while Node <> nil do
        begin
          DoApply(Node);
          Node := Node.getNextSibling;
        end;
      end;
    end;
  end;
begin
  TestTree.Items.BeginUpdate;
  try
    DoApply(root)
  finally
    TestTree.Items.EndUpdate
  end;
  TotalTestsCount := (FSuite as ITestProxy).CountEnabledTestCases;
  UpdateTestTreeState;
end;

procedure TGUITestRunner.TestTreeKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = ' ') and (TestTree.Selected <> nil) then
  begin
    SwitchNodeState(TestTree.Selected);
    UpdateStatus(True);
    Key := #0
  end;
end;

procedure TGUITestRunner.SelectAllActionExecute(Sender: TObject);
begin
  ApplyToTests(TestTree.Items.GetFirstNode, EnableTest);
  UpdateStatus(True);
end;

procedure TGUITestRunner.DeselectAllActionExecute(Sender: TObject);
begin
  ApplyToTests(TestTree.Items.GetFirstNode, DisableTest);
  UpdateStatus(True);
end;

procedure TGUITestRunner.SelectFailedActionExecute(Sender: TObject);
var
  i: Integer;
  ANode: TTreeNode;
begin
  { deselect all }
  ApplyToTests(TestTree.Items[0], DisableTest);

  { select failed }
  for i := 0 to FailureListView.Items.Count - 1 do
  begin
    ANode := TTreeNode(FailureListView.Items[i].Data);
    SetNodeState(ANode, true);
  end;
  UpdateStatus(True);
end;
{$IFNDEF VER130}
  {$IFNDEF VER140}
    {$WARN UNSAFE_CAST ON}
  {$ENDIF}
{$ENDIF}

procedure TGUITestRunner.SaveConfigurationActionExecute(Sender: TObject);
begin
  SaveConfiguration
end;

procedure TGUITestRunner.RestoreSavedActionExecute(Sender: TObject);
begin
  LoadConfiguration
end;

procedure TGUITestRunner.AutoSaveActionExecute(Sender: TObject);
begin
  with AutoSaveAction do
  begin
    Checked := not Checked
  end;
  AutoSaveConfiguration;
end;

procedure TGUITestRunner.ErrorBoxVisibleActionExecute(Sender: TObject);
begin
  if FHoldOptions then
    Exit;

   with ErrorBoxVisibleAction do
   begin
     Checked := not Checked;
     ErrorBoxSplitter.Visible := Checked;
     ErrorBoxPanel.Visible    := Checked;
     if Checked then
     begin
      // Solve bugs with Delphi4 resizing with constraints
       ErrorBoxSplitter.Top := ErrorBoxPanel.Top-8;
     end
   end;
end;

function TGUITestRunner.FindMultiErrorSourceReference(const AString: string;
  const AStartIndex: integer; out AFileName, ALineNumber: string): boolean;
var
  idx: integer;
  stopping: boolean;
  text: string;
  // Example from multi-error listing: filename.pas:number

const
  cTokenDelimiters = ' .:';
  cReferenceIdentifier = '.pas:';

  function GetNextDelimiter(var AIndex: integer; const AExpectedDelimiters: string): boolean;
  begin
    while  (AIndex >= 1) and (Pos(text[AIndex], cTokenDelimiters) = 0) do
      Dec(AIndex);
    Result := (AIndex > 0) and (Pos(text[AIndex], AExpectedDelimiters) > 0);
  end;

  function FindFileName(var AIndex: integer; const AExpectedDelimiters: string): boolean;
  begin
    if GetNextDelimiter(AIndex, AExpectedDelimiters) then
      case text[AIndex] of
        ' ':
          begin
            Result := true;
            Inc(AIndex);
          end;
        '.': Result := FindFileName(AIndex, ' ');
        ':': Result := FindFileName(AIndex, '.');
       else
         Result := false;
      end
    else
      Result := false;
  end;

begin
  text := LowerCase(AString);
  Result := false;
  idx := AStartIndex;

  if FindFileName(idx, cTokenDelimiters) then
  begin
    Delete(text, 1, idx - 1);
    text := StripAllCRLFs(text);
    stopping := false;
    idx := 1;

    while (idx < Length(text)) and (not stopping) do
      case text[idx] of
        'a'..'z','A'..'Z','0'..'9','_': Inc(idx);
      else
        stopping := true;
      end;

    if stopping and (Pos(cReferenceIdentifier, text) = idx) then
    begin
      AFileName := Copy(text, 1, idx + Length(cReferenceIdentifier) - 2);
      Delete(text, 1, idx + Length(cReferenceIdentifier) - 1);
      stopping := false;
      idx := 1;

      while (idx <= Length(text)) and (not stopping) do
        case text[idx] of
          '0'..'9': Inc(idx);
        else
          stopping := true;
        end;

       ALineNumber := Copy(text, 1, idx - 1);
       Result := Length(ALineNumber) > 0;
    end;

  end;

end;

function TGUITestRunner.FindStackTraceSourceReference(const AString: string;
  const AStartIndex: integer; out AFileName, ALineNumber: string): boolean;
var
  LAnchor: PChar;
  LStartIndex: integer;
  LReference: string;
// Example from stack trace: (Line 128, "MudpackLegacyModelDiagram_TST.pas")

const
  cFileInfoStartAnchor = '(Line ';
  cFileInfoEndAnchor = '")';
  cLineNameSeparator = ',';

begin
  Result := false;
  LStartIndex := AStartIndex;
  // search forwards from caret position for end anchor
  LAnchor := SearchBuf(Pointer(AString), Length(AString), LStartIndex,
    0, cFileInfoEndAnchor, [soDown]);

  if Assigned(LAnchor) then
  begin
    // search backwards from end anchor for start anchor
    LStartIndex := (integer(LAnchor) - integer(Pointer(AString))) div SizeOf(Char);
    LAnchor := SearchBuf(PChar(AString), Length(AString), LStartIndex,
      0, cFileInfoStartAnchor, []);

    if Assigned(LAnchor) then
    begin
      // strip leading text to start of start Anchor
      LReference := String(LAnchor);
      // trim off leading and trailing text inclusive of Anchors
      Delete(LReference, 1, Length(cFileInfoStartAnchor));
      Delete(LReference, Pos(cFileInfoEndAnchor, LReference), Length(LReference));
      // remove any linebreaks from wrapped lines
      LReference := StripAllCRLFs(LReference);

      if SplitPair(LReference, ALineNumber, AFileName, cLineNameSeparator) then
      begin
        // trim off whitespace
        AFileName := Trim(AFileName);
        // trim off (") char from start of file name
        Delete(AFileName, 1, 1);
        Result := true;
      end;

    end;

  end;

end;

procedure TGUITestRunner.ErrorMessageRTFDblClick(Sender: TObject);
var
  LRichEdit: TRichEdit;
  LText: string;
  LCursorPos: integer;
  LLineNumber: string;
  LFileName: string;

begin
  Assert(Sender is TRichEdit, 'Sender is not a TRichEdit');
  LRichEdit := Sender as TRichEdit;
  LText := LRichEdit.Lines.Text;
  LCursorPos := LRichEdit.SelStart + LRichEdit.SelLength;

  if FindStackTraceSourceReference(LText, LCursorPos, LFileName, LLineNumber) or
    FindMultiErrorSourceReference(LText, LCursorPos, LFileName, LLineNumber) then
    WriteWatchFile(LFileName, LLineNumber);

end;

procedure TGUITestRunner.ErrorBoxSplitterMoved(Sender: TObject);
begin
  // Solve bugs with Delphi4 resizing with constraints
  ErrorBoxSplitter.Top := ErrorBoxPanel.Top-8;
  self.Update;
end;

procedure TGUITestRunner.ErrorBoxPanelResize(Sender: TObject);
begin
  // Solve bugs with Delphi4 resizing with constraints
  ErrorBoxSplitter.Top := ErrorBoxPanel.Top-8;
end;

function TGUITestRunner.NodeIsGrandparent(ANode: TTreeNode): boolean;
var
  AChildNode: TTreeNode;
begin
  Result := false;
  if ANode.HasChildren then
  begin
    AChildNode := ANode.GetFirstChild;
    while AChildNode <> nil do
    begin
      Result := AChildNode.HasChildren or Result;
      AChildNode := ANode.GetNextChild(AChildNode);
    end;
  end;
end;

procedure TGUITestRunner.CollapseNonGrandparentNodes(RootNode: TTreeNode);
var
  AChildNode: TTreeNode;
begin
  if not NodeIsGrandparent(RootNode) then
    RootNode.Collapse(false);

  AChildNode := RootNode.GetFirstChild;
  while AChildNode <> nil do
  begin
    CollapseNonGrandparentNodes(AChildNode);
    AChildNode := RootNode.GetNextChild(AChildNode);
  end;
end;

procedure TGUITestRunner.HideTestNodesActionExecute(Sender: TObject);
var
  ANode: TTreeNode;
begin
  inherited;
  if TestTree.Items.Count = 0 then
    EXIT;

  TestTree.Items.BeginUpdate;
  try
    ANode := TestTree.Items[0];
    if ANode <> nil then
    begin
      ANode.Expand(true);
      CollapseNonGrandparentNodes(ANode);
      SelectNode(ANode);
    end;
  finally
    TestTree.Items.EndUpdate;
  end;
end;

procedure TGUITestRunner.HideTestNodesOnOpenActionExecute(Sender: TObject);
begin
  HideTestNodesOnOpenAction.Checked := not HideTestNodesOnOpenAction.Checked;
end;

procedure TGUITestRunner.ExpandAllNodesActionExecute(Sender: TObject);
begin
  TestTree.FullExpand;
  if (TestTree.Selected <> nil) then
    MakeNodeVisible(TestTree.Selected)
  else if(TestTree.Items.Count > 0) then
    TestTree.Selected := TestTree.Items[0];
end;

procedure TGUITestRunner.RunTheTest(ATest : ITestProxy);
begin
  if ATest = nil then
    EXIT;
  if FRunning then
  begin
    // warning: we're reentering this method if FRunning is true
    assert(FTestResult <> nil);
    TestResult.Stop;
    EXIT;
  end;

  FRunning := true;
  try
    RunAction.Enabled  := False;
    StopAction.Enabled := True;
    CopyMessageToClipboardAction.Enabled := false;
    EnableUI(false);
    AutoSaveConfiguration;
    ClearFailureMessage;
    TestResult := GetTestResult; // Replaces TTestResult.create
    try
      {$IFDEF XMLLISTENER}
      TestResult.AddListener(
        TXMLListener.Create(LocalAppDataPath + Suite.Name
          {, 'type="text/xsl" href="fpcunit2.xsl"'}));
      {$ENDIF}
      TestResult.addListener(self);
      TestResult.BreakOnFailures := BreakOnFailuresAction.Checked;
      LoadSuiteConfiguration;
      ATest.Run(TestResult);
    finally
      TestResult.ReleaseListeners;
      TestResult := nil;
    end;
  finally
    FRunning := false;
    EnableUI(true);
  end;
end;

procedure TGUITestRunner.RunActionExecute(Sender: TObject);
begin
  if Suite = nil then
    EXIT;

  HoldOptions(True);
  try
    SetUp;
    RunTheTest(Suite);
  finally
    HoldOptions(False);
  end;  
end;

procedure TGUITestRunner.ExitActionExecute(Sender: TObject);
begin
  if FTestResult <> nil then
     FTestResult.stop;
  self.ModalResult := mrCancel;
  Close;
end;

procedure TGUITestRunner.BreakOnFailuresActionExecute(Sender: TObject);
begin
  if FHoldOptions then
    Exit;
    
  with BreakOnFailuresAction do
    Checked := not Checked;
end;

procedure TGUITestRunner.FailIfNoChecksExecutedActionExecute(Sender: TObject);
begin
  if FHoldOptions then
    Exit;

  with FailIfNoChecksExecutedAction do
    Checked := not Checked;
end;

procedure TGUITestRunner.FailTestCaseIfMemoryLeakedActionExecute(Sender: TObject);
begin
  if FHoldOptions then
    Exit;

  with FailTestCaseIfMemoryLeakedAction do
    Checked := not Checked;
end;

procedure TGUITestRunner.ShowTestCasesWithRunTimePropertiesActionExecute(
  Sender: TObject);
begin
  if FHoldOptions then
    Exit;

  with ShowTestCasesWithRunTimePropertiesAction do
  begin
    Checked := not Checked;
    PropertyOverrideToolButton.Down := Checked;
    if Checked then
    begin
      ShowOverriddenFailuresAction.Checked := False;
      ShowEarlyExitedTestAction.Checked := False;
    end;
  end;
end;

procedure TGUITestRunner.ShowOverriddenFailuresActionExecute(
  Sender: TObject);
begin
  if FHoldOptions then
    Exit;

  with ShowOverriddenFailuresAction do
  begin
    Checked := not Checked;
    ShowOverriddenFailuresToolButton.Down := Checked;
    if Checked then
    begin
      ShowTestCasesWithRunTimePropertiesAction.Checked := False;
      ShowEarlyExitedTestAction.Checked := False;
    end;
  end;
end;

procedure TGUITestRunner.ShowOverriddenFailuresActionUpdate(Sender: TObject);
begin
  ShowOverriddenFailuresToolButton.Down := ShowOverriddenFailuresAction.Checked;
end;

procedure TGUITestRunner.ShowEarlyExitedTestActionUpdate(
  Sender: TObject);
begin
  ShowSummaryLevelExitsToolButton.Down := ShowEarlyExitedTestAction.Checked;
end;

procedure TGUITestRunner.ShowEarlyExitedTestActionExecute(
  Sender: TObject);
begin
  if FHoldOptions then
    Exit;

  with ShowEarlyExitedTestAction do
  begin
    Checked := not Checked;
    ShowEarlyExitedTestAction.Checked := Checked;
    if Checked then
    begin
      ShowOverriddenFailuresAction.Checked := False;
      ShowTestCasesWithRunTimePropertiesAction.Checked := False;
    end;
  end;
end;

procedure TGUITestRunner.ShowTestedNodeActionExecute(Sender: TObject);
begin
  with ShowTestedNodeAction do
    Checked := not Checked;
end;

procedure TGUITestRunner.SetUpStateImages;
begin
    TestTree.Images             := RunImages;
    TestTree.StateImages        := StateImages;
    FailureListView.SmallImages := RunImages;
end;

procedure TGUITestRunner.set_TestResult(const Value: TTestResult);
begin
  FTestResult := Value;
end;

procedure TGUITestRunner.LoadSuiteConfiguration;
begin
  if Suite <> nil then
    Suite.LoadConfiguration(IniFileName, UseRegistryAction.Checked, True);
end;

procedure TGUITestRunner.MakeNodeVisible(Node: TTreeNode);
begin
  Node.MakeVisible
end;

procedure TGUITestRunner.ProcessClickOnStateIcon;
var
  HitInfo: THitTests;
  Node: TTreeNode;
  PointPos: TPoint;
begin
  GetCursorPos(PointPos);
  PointPos := TestTree.ScreenToClient(PointPos);
  with PointPos do
  begin
    HitInfo := TestTree.GetHitTestInfoAt(X, Y);
    Node := TestTree.GetNodeAt(X, Y);
  end;
  if (Node <> nil) and (HtOnStateIcon in HitInfo) then
  begin
    SwitchNodeState(Node);
  end;
end;

procedure TGUITestRunner.UpdateNodeImage(Node: TTreeNode);
var
  Test :ITestProxy;
begin
  Test := NodeToTest(Node);
  if not Test.Enabled then
  begin
    Node.StateIndex := imgDISABLED;
  end
  else if (Node.Parent <> nil)
  and (Node.Parent.StateIndex <= imgPARENT_DISABLED) then
  begin
    Node.StateIndex := imgPARENT_DISABLED;
  end
  else
  begin
    Node.StateIndex := imgENABLED;
  end;

  if (Node.Parent <> nil) and
    (Node.Parent.StateIndex >= imgEXCLUDED) then
      Node.StateIndex := imgPARENT_EXCLUDED
  else
  if Test.Excluded then
    Node.StateIndex := imgEXCLUDED;
end;

procedure TGUITestRunner.CopyMessageToClipboardActionExecute(Sender: TObject);
begin
  ErrorMessageRTF.SelectAll;
  ErrorMessageRTF.CopyToClipboard;
end;

procedure TGUITestRunner.UseRegistryActionExecute(Sender: TObject);
begin
  if FHoldOptions then
    Exit;

  with UseRegistryAction do
    Checked := not Checked;
end;

function TGUITestRunner.GetIniFile(const FileName: string) : tCustomIniFile;
begin
  if UseRegistryAction.Checked then
    Result := tRegistryIniFile.Create(GetDUnitRegistryKey + FileName)
  else
    Result := tIniFile.Create(FileName);
end;

procedure TGUITestRunner.LoadRegistryAction;
begin
  with TIniFile.Create(IniFileName) do
  try
    UseRegistryAction.Checked := ReadBool(cnConfigIniSection,
      'UseRegistry', UseRegistryAction.Checked);
  finally
    Free;
  end;
end;

procedure TGUITestRunner.SaveRegistryAction;
begin
  if UseRegistryAction.Checked then
    DeleteFile(IniFileName);

  with TIniFile.Create(IniFileName) do
  try
    WriteBool(cnConfigIniSection, 'UseRegistry', UseRegistryAction.Checked);
  finally
    Free;
  end;
end;

procedure TGUITestRunner.RunActionUpdate(Sender: TObject);
begin
  RunAction.Enabled := not FRunning and assigned(Suite) and (TotalTestsCount > 0);
end;

procedure TGUITestRunner.CopyMessageToClipboardActionUpdate(Sender: TObject);
begin
  CopyMessageToClipboardAction.Enabled := FailureListView.Items.Count > 0;
end;

procedure TGUITestRunner.SelectCurrentActionExecute(Sender: TObject);
begin
  ApplyToTests(TestTree.Selected, EnableTest);
  SetNodeState(TestTree.Selected, true);
  UpdateStatus(True);
end;

procedure TGUITestRunner.DeselectCurrentActionExecute(Sender: TObject);
begin
  ApplyToTests(TestTree.Selected, DisableTest);
  SetNodeState(TestTree.Selected, false);
  UpdateStatus(True);
end;

procedure TGUITestRunner.IncludeCurrentActionExecute(Sender: TObject);
begin
  if FHoldOptions then
    Exit;

  ApplyToTests(TestTree.Selected, IncludeTest);
  UpdateStatus(True);
end;

procedure TGUITestRunner.ExcludeCurrentActionExecute(Sender: TObject);
begin
  if FHoldOptions then
    Exit;

  ApplyToTests(TestTree.Selected, ExcludeTest);
  UpdateStatus(True);
end;

procedure TGUITestRunner.StopActionExecute(Sender: TObject);
begin
  Suite.HaltTesting;
end;

procedure TGUITestRunner.StopActionUpdate(Sender: TObject);
begin
  StopAction.Enabled := FRunning and (FTestResult <> nil);
end;

procedure TGUITestRunner.Status(const ATest: ITestProxy; AMessage: string);
begin
  if ErrorMessageRTF.Lines.Count = 0 then
    ErrorMessageRTF.Lines.Add(ATest.Name + ':');

  ErrorMessageRTF.Lines.Add(AMessage);

  ErrorMessageRTF.Update;
end;

procedure TGUITestRunner.Warning(const ATest: ITestProxy; const AMessage: string);
begin
  if ErrorMessageRTF.Lines.Count = 0 then
    ErrorMessageRTF.Lines.Add(ATest.ParentPath + '.' +  ATest.Name + ':');

  ErrorMessageRTF.Lines.Add(AMessage);

  ErrorMessageRTF.Update;
end;

procedure TGUITestRunner.ClearStatusMessage;
begin
  ErrorMessageRTF.Lines.Clear;
end;

procedure TGUITestRunner.CopyProcnameToClipboardActionExecute(
  Sender: TObject);
begin
  CopyTestNametoClipboard(TestTree.Selected);
end;

procedure TGUITestRunner.CopyTestNametoClipboard(ANode: TTreeNode);
begin
  if Assigned(ANode) then
  begin
    Clipboard.AsText := ANode.Text;
  end;
end;

procedure TGUITestRunner.CreateSearchPanel(const AOwner: TWinControl);
begin
  FSP := TGUISearchPanel.Create(AOwner);
  FSP.Parent := AOwner;
  FSP.Images := SearchImages;
end;

procedure TGUITestRunner.CreateSearchController(
  const ASearchPanel: TGUISearchPanel; const ATreeView: TTreeView);
begin
  FSearchController := TGUISearchController.Create(ASearchPanel, ATreeView);
end;

procedure TGUITestRunner.CopyProcnameToClipboardActionUpdate(
  Sender: TObject);
begin
  (Sender as TAction).Enabled := Assigned(TestTree.Selected)
                                 and IsTestMethod(NodeToTest(TestTree.Selected));
end;

procedure TGUITestRunner.CopyQuotedSelectedMessageToClipboardActionExecute(
  Sender: TObject);
var
  LText: string;
  LSL: TStringList;
  i: integer;
begin
  LText:= '';
  LSL:= TStringList.Create;
  try
    LSL.Text:= ErrorMessageRTF.SelText;
    for i := 0 to LSL.Count - 1 do
    begin
      if i > 0 then
        LText:= LText + ' + #13 + #10 +' + #13 + #10;
      LText:= LText + QuotedStr(LSL.Strings[i]);
    end;
  finally
    LSL.Free;
  end;
  LText:= LText + ' + #13 + #10;' + #13 + #10;
  Clipboard.AsText:= LText;
end;

procedure TGUITestRunner.CopyQuotedSelectedMessageToClipboardActionUpdate(
  Sender: TObject);
begin
  CopyQuotedSelectedMessageToClipboardAction.Enabled := ErrorMessageRTF.SelText <> '';
end;

procedure TGUITestRunner.CopySelectedMessageToClipboardActionExecute(
  Sender: TObject);
begin
  ErrorMessageRTF.CopyToClipboard;
end;

procedure TGUITestRunner.CopySelectedMessageToClipboardActionUpdate(
  Sender: TObject);
begin
  CopySelectedMessageToClipboardAction.Enabled := ErrorMessageRTF.SelText <> '';
end;

function TGUITestRunner.SelectedTest: ITestProxy;
begin
  if TestTree.Selected = nil then
    Result := nil
  else
    Result := NodeToTest(TestTree.Selected);
end;

procedure TGUITestRunner.ListSelectedTests;
var
  ATest: ITestProxy;
  ANode: TTreeNode;
begin
  FSelectedTests.Free;
  FSelectedTests := nil;
  FSelectedTests := TInterfaceList.Create;
  FSelectedTestCount := 0;

  ANode := TestTree.Selected;
  if Assigned(ANode) then
  begin
    while Assigned(ANode) do
    begin
      ATest := NodeToTest(ANode);
      FSelectedTests.Add(ATest as ITestProxy);
      ANode := ANode.Parent;
    end;
    FSelectedTestCount := 1;
  end;
end;

procedure TGUITestRunner.RunSelectedTestActionExecute(Sender: TObject);
begin
  SetUp;
  ListSelectedTests;
  ProgressBar.Max := FSelectedTestCount;
  ScoreBar.Max    := FSelectedTestCount;
  HoldOptions(True);
  try
    RunTheTest(Suite);
  finally
    HoldOptions(False);
  {$IFDEF VER130}
    FreeAndNil(FSelectedTests);
  {$ELSE}
    FSelectedTests.Free;
    FSelectedTests := nil;
  {$ENDIF}
  end;
end;

procedure TGUITestRunner.RunSelectedTestActionUpdate(Sender: TObject);
var
  ATest :ITestProxy;
begin
  ATest := SelectedTest;
  RunSelectedTestAction.Enabled := (ATest <> nil) and (ATest.IsTestMethod);
end;

procedure TGUITestRunner.RecordSelectedTestActionExecute(Sender: TObject);
var
  I: Integer;
  LCommands: TStringList;
begin
  if RunSelectedTestAction.Enabled then
  begin
    GGUIActionRecorder.Initialize;
    GGUIActionRecorder.Active := true;
    try
      RunSelectedTestAction.Execute;
    finally
      GGUIActionRecorder.Active := false;
    end;

    ErrorMessageRTF.SelAttributes.Size  := self.Font.Size;
    ErrorMessageRTF.SelAttributes.Color := clWindowText;
    ErrorMessageRTF.SelAttributes.Style := [fsBold];
    ErrorMessageRTF.SelText := 'Recorded GUI Actions:';
    ErrorMessageRTF.SelAttributes.Style := [];

    LCommands := TStringList.Create;
    try
      LCommands.Add('  ThreadedExecute(procedure begin');
      for I := 0 to GGUIActionRecorder.Actions.Count - 1 do
        LCommands.Add('    ' + CGUIAutomationCommandPrefix + '.' +
            GGUIActionRecorder.Actions[I].AsString + ';');
      LCommands.Add('  end);');
      Clipbrd.Clipboard.AsText := LCommands.Text;
      ErrorMessageRTF.Lines.AddStrings(LCommands);
    finally
      LCommands.Free;
    end;
  end;
end;

procedure TGUITestRunner.RecordSelectedTestActionUpdate(Sender: TObject);
var
  ATest :ITestProxy;
begin
  ATest := SelectedTest;
  RecordSelectedTestAction.Enabled := (ATest <> nil) and (ATest.IsGUITestMethod);
end;

procedure TGUITestRunner.ListTestsFromHere;

  // Add test for the given node. Return true if it is a test method
  function _AddTestForNode(ANode: TTreeNode): boolean;
  var
    LTest: ITestProxy;
  begin
    result := false;
    if Assigned(ANode) then
    begin
      LTest := NodeToTest(ANode);
      if Assigned(LTest) and LTest.Enabled then
      begin
        if FSelectedTests.IndexOf(LTest) = -1 then
        begin
          FSelectedTests.Add(LTest);
          if LTest.IsTestMethod then
          begin
            Inc(FSelectedTestCount);
            result := true;
          end;
        end;
      end;
    end;
  end;

  // Must add all parent test nodes in the tree to execute a test method
  procedure _SelectParents(ANode: TTreeNode);
  var
    LNode: TTreeNode;
    LTest: ITestProxy;
  begin
    LNode := ANode;
    while Assigned(LNode) do
    begin
      LTest := NodeToTest(ANode);
      if (not Assigned(LTest)) or (not LTest.Enabled) then
        break;

      _AddTestForNode(LNode);
      LNode := LNode.Parent;
    end;
  end;

  // Add nodes children (and their children and so on) and the node itself
  function _SelectNode(ANode: TTreeNode): boolean;
  var
    LNode: TTreeNode;
  begin
    result := false;
    if not Assigned(ANode) then
      exit;
    LNode := ANode.getFirstChild;
    while Assigned(LNode) do
    begin
      result := _SelectNode(LNode) or result;
      LNode := LNode.getNextSibling;
    end;
    result := _AddTestForNode(ANode) or result;
  end;

  // Add the given node and all following nodes in the tree
  procedure _SelectFromNode(ANode: TTreeNode);
  var
    LNode: TTreeNode;
    LTestAdded: Boolean;
  begin
    if not Assigned(ANode) then
      Exit;

    // Add given node and following siblings, and their children
    LTestAdded := false;
    LNode := ANode;
    while Assigned(LNode) do
    begin
      if _SelectNode(LNode) then
        LTestAdded := true;
      LNode := LNode.getNextSibling;
    end;
    if LTestAdded then
      _SelectParents(ANode.Parent);

    // Add parent's following siblings and their children
    if Assigned(ANode.Parent) then
      _SelectFromNode(ANode.Parent.getNextSibling);
  end;

begin
  FSelectedTests.Free;
  FSelectedTests := nil;
  FSelectedTests := TInterfaceList.Create;
  FSelectedTestCount := 0;

  _SelectFromNode(TestTree.Selected);
end;

procedure TGUITestRunner.RunFromHereActionExecute(Sender: TObject);
begin
  SetUp;
  ListTestsFromHere;
  ProgressBar.Max := FSelectedTestCount;
  ScoreBar.Max    := FSelectedTestCount;
  HoldOptions(True);
  try
    RunTheTest(Suite);
  finally
    HoldOptions(False);
  {$IFDEF VER130}
    FreeAndNil(FSelectedTests);
  {$ELSE}
    FSelectedTests.Free;
    FSelectedTests := nil;
  {$ENDIF}
  end;
end;

procedure TGUITestRunner.RunFromHereActionUpdate(Sender: TObject);
begin
  RunFromHereAction.Enabled := SelectedTest <> nil;
end;

class procedure TGUITestRunner.RunTest(Test: ITestProxy);
var
  MyForm: TGUITestRunner;
begin
  Application.CreateForm(TGUITestRunner, MyForm);
  with MyForm do
  begin
    try
      Suite := Test;
      ShowModal;
    finally
      MyForm.Free;
    end;
  end;
end;

class procedure TGUITestRunner.RunRegisteredTests;
begin
  RunTest(RegisteredTests);
end;

procedure TGUITestRunner.TestTreeMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  NewNode: TTreeNode;
begin
  { a version of this code was in the pmTestTreePopup event, but it created
    an intermittent bug. OnPopup is executed if any of the ShortCut keys
    belonging to items on the popup menu are used. This caused weird behavior,
    with the selected node suddenly changing to whatever was under the mouse
    cursor (or AV-ing if the mouse cursor wasn't over the DUnit form) when
    the user executed one of the keyboard shortcuts.

    It was intermittent most likely because the ShortCuts belonged to
    Main Menu items as well (shared from the Action.ShortCut), and the bug
    dependended on the Popup menu items receiving the ShortCut Windows message
    first.

    This code ensures that node selection occurs prior to the popup menu
    appearing when the user right-clicks on a non-selected tree node. }

  if (Button = mbRight) and (htOnItem in TestTree.GetHitTestInfoAt(X, Y)) then
  begin
    NewNode := TestTree.GetNodeAt(X, Y);
    if TestTree.Selected <> NewNode then
      TestTree.Selected := NewNode;
  end;
end;

procedure TGUITestRunner.GoToNextSelectedTestActionExecute(
  Sender: TObject);
var
  ANode: TTreeNode;
begin
  if TestTree.Selected <> nil then
  begin
    ANode := TestTree.Selected.GetNext;
    while ANode <> nil do
    begin
      if SelectNodeIfTestEnabled(ANode) then
        break
      else
        ANode := ANode.GetNext;
    end;
  end;
end;

function TGUITestRunner.SelectNodeIfTestEnabled(ANode: TTreeNode): boolean;
var
  ATest: ITestProxy;
begin
  ATest := NodeToTest(ANode);
  if (ATest.Enabled) and (IsTestMethod(ATest)) then
  begin
    Result := true;
    SelectNode(ANode);
  end
  else
    Result := false;
end;

procedure TGUITestRunner.GoToPrevSelectedTestActionExecute(
  Sender: TObject);
var
  ANode: TTreeNode;
begin
  if TestTree.Selected <> nil then
  begin
    ANode := TestTree.Selected.GetPrev;
    while ANode <> nil do
    begin
      if SelectNodeIfTestEnabled(ANode) then
        break
      else
        ANode := ANode.GetPrev;
    end;
  end;
end;

procedure TGUITestRunner.SelectNode(Node: TTreeNode);
begin
  Node.Selected := true;
  MakeNodeVisible(Node);
end;

procedure TGUITestRunner.SetupCustomShortcuts;
begin
  { the following shortcuts are not offered as an option in the
    form designer, but can be set up here }
  GoToNextSelectedTestAction.ShortCut := ShortCut(VK_RIGHT, [ssCtrl]);
  GoToPrevSelectedTestAction.ShortCut := ShortCut(VK_LEFT, [ssCtrl]);
end;

procedure TGUITestRunner.SetupGUINodes;
var
  Node: TTreeNode;
  Test: ITestProxy;
begin
  { Set up the GUI nodes in the test nodes. We do it here because the form,
    the tree and all its tree nodes get recreated in TCustomForm.ShowModal
    in D8+ so we cannot do it sooner.
    This method is also called after loading test libraries }

  Node := TestTree.Items.GetFirstNode;
  while assigned(Node) do
  begin
    // Get and check the test for the tree node

    Test := NodeToTest(Node);
    assert(Assigned(Test));

    // Save the tree node in the test and get the next tree node

    Test.GUIObject := Node;

    Node := Node.GetNext;
  end;
end;

const
  PopupTitle   = 'TestCase Run-Time Applied Properties';
  PopupPrevious= ' Previous';
  PopupRun     = ' Run Selected Test';
  PopupRecord  = ' Record GUI Actions For Selected Test';
  PopupNext    = ' Next';
  NoChecksStrT = ' FailsOnNoChecksExecuted  := True ';
  NoChecksStrF = ' FailsOnNoChecksExecuted  := False';
  MemLeakStrT  = ' FailsOnMemoryLeak        := True ';
  MemLeakStrF  = ' FailsOnMemoryLeak        := False';
  MemBytesStr0 = ' AllowedMemoryLeakSize '           ;
  IgnoreStrT   = ' IgnoreSetUpTearDownLeaks := True ';
  IgnoreStrF   = ' IgnoreSetUpTearDownLeaks := False';

procedure TGUITestRunner.TestCasePropertiesActionExecute(Sender: TObject);
var
  ANode: TTreeNode;
  ATest: ITestProxy;

begin
  if TestTree.Selected <> nil then
  begin
    ANode := TestTree.Selected;
    if (ANode <> nil) then
    begin
      ATest := NodeToTest(ANode);
      if IsTestMethod(ATest) then
      begin
        if ATest.FailsOnNoChecksExecuted then
          FNoChecksStr := NoChecksStrT
        else
          FNoChecksStr := NoChecksStrF;
        FNoCheckExecutedPtyOverridden := FailIfNoChecksExecutedAction.Checked and
          (not ATest.FailsOnNoChecksExecuted);

        if ATest.FailsOnMemoryLeak then
          FMemLeakStr := MemLeakStrT
        else
          FMemLeakStr := MemLeakStrF;
        FMemLeakDetectedPtyOverridden := FailTestCaseIfMemoryLeakedAction.Checked and
          (not ATest.FailsOnMemoryLeak);

        if (ATest.IgnoreSetUpTearDownLeaks) and ATest.FailsOnMemoryLeak then
          FIgnoreLeakStr := IgnoreStrT
        else
          FIgnoreLeakStr := IgnoreStrF;
        FIgnoreSetUpTearDownLeakPtyOverridden := ATest.IgnoreSetUpTearDownLeaks and
          ATest.FailsOnMemoryLeak and (not IgnoreMemoryLeakInSetUpTearDownAction.Checked);

        FBytes := ':= ' + IntToStr(ATest.AllowedMemoryLeakSize) + ' Bytes';
        FMemBytesStr := MemBytesStr0 + FBytes;

        TestCaseProperty.Popup(Self.Left + FPopupX,Self.Top + FPopupY);
      end;
    end;
    ATest := nil;
  end;
end;

procedure TGUITestRunner.Previous1Click(Sender: TObject);
begin
  GoToPrevSelectedTestActionExecute(Self);
  TestCasePropertiesActionExecute(self);
end;

procedure TGUITestRunner.Next1Click(Sender: TObject);
begin
  GoToNextSelectedTestActionExecute(Self);
  TestCasePropertiesActionExecute(self);
end;

procedure TGUITestRunner.TestCasePropertiesMeasureItem(Sender: TObject;
  ACanvas: TCanvas; var Width, Height: Integer);
var
  ImageSize: TSize;
begin
  ACanvas.Font.Name := 'Courier New';
  ACanvas.Font.Size := 8;
  if GetTextExtentPoint32(ACanvas.Handle,
                          PChar(PopupTitle),
                          Length(PopupTitle),
                          ImageSize) then
  begin
    Width  := ImageSize.cx + 60;
    Height := ImageSize.cy + 4;
  end;
end;

procedure TGUITestRunner.MenuLooksInactive(ACanvas: TCanvas;
                                           ARect: TRect;
                                           Selected: Boolean;
                                           ATitle: string;
                                           TitlePosn: UINT;
                                           PtyOveridesGUI: boolean);
var
  Count: Integer;
  SecondPart: string;
  SecondRect: TRect;
begin
  ACanvas.Font.Name := 'Courier New';
  ACanvas.Font.Size := 8;
  if TitlePosn = DT_CENTER then
    ACanvas.Font.Style := [fsBold];
  if Selected then
    ACanvas.Font.Color := clBlack;
  if PtyOveridesGUI then
    ACanvas.Brush.Color := clYellow
  else
    ACanvas.Brush.Color := TColor($C0FCC0);  //Sort of Moneygreen
  ACanvas.FillRect(ARect);
  Count := Pos(':=', ATitle);
  if Count = 0 then
    DrawText(ACanvas.Handle,
             PChar(ATitle),
             Length(ATitle),
             ARect,
             DT_VCENTER or DT_SINGLELINE or DT_NOCLIP or DT_NOPREFIX or TitlePosn)
  else
  begin
    DrawText(ACanvas.Handle,
             PChar(ATitle),
             Count-1,
             ARect,
             DT_VCENTER or DT_SINGLELINE or DT_NOCLIP or DT_NOPREFIX or TitlePosn);

    SecondPart := Copy(ATitle, Count, Length(ATitle));
    SecondRect := ARect;
    SecondRect.Left := 5 * ((ARect.Right - ARect.Left) div 8);
    DrawText(ACanvas.Handle,
             PChar(SecondPart),
             Length(SecondPart),
             SecondRect,
             DT_VCENTER or DT_SINGLELINE or DT_NOCLIP or DT_NOPREFIX or TitlePosn)
  end;
end;

procedure TGUITestRunner.MenuLooksActive(ACanvas: TCanvas;
                                         ARect: TRect;
                                         Selected: Boolean;
                                         ATitle: string;
                                         TitlePosn: UINT);
begin
  ACanvas.Font.Name := 'Courier New';
  ACanvas.Font.Size := 8;
  ACanvas.FillRect(ARect);
  DrawText(ACanvas.Handle,
           PChar(ATitle),
           Length(ATitle),
           ARect,
           DT_VCENTER or DT_SINGLELINE or DT_NOCLIP or DT_NOPREFIX or TitlePosn);
end;

procedure TGUITestRunner.TestCasePropertiesDrawItem(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  MenuLooksInactive(ACanvas, ARect, Selected, PopupTitle, DT_CENTER, False);
end;

procedure TGUITestRunner.Previous1DrawItem(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  MenuLooksActive(ACanvas, ARect, Selected, PopupPrevious, DT_LEFT);
end;

procedure TGUITestRunner.RunSelectedTest1DrawItem(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  MenuLooksActive(ACanvas, ARect, Selected, PopupRun, DT_LEFT);
end;

procedure TGUITestRunner.RecordSelectedTestItem1DrawItem(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  MenuLooksActive(ACanvas, ARect, Selected, PopupRecord, DT_LEFT);
end;

procedure TGUITestRunner.Next1DrawItem(Sender: TObject; ACanvas: TCanvas;
  ARect: TRect; Selected: Boolean);
begin
  MenuLooksActive(ACanvas, ARect, Selected, PopupNext, DT_LEFT);
end;

procedure TGUITestRunner.FailNoCheckExecutedMenuItemDrawItem(
  Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  MenuLooksInactive(ACanvas, ARect, Selected, FNoChecksStr,
    DT_LEFT, FNoCheckExecutedPtyOverridden);
end;

procedure TGUITestRunner.FailsOnMemoryLeakMenuItemDrawItem(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  MenuLooksInactive(ACanvas, ARect, Selected, FMemLeakStr,
    DT_LEFT, FMemLeakDetectedPtyOverridden);
end;

procedure TGUITestRunner.AllowedLeakSizeMenuItemDrawItem(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  MenuLooksInactive(ACanvas, ARect, Selected, FMemBytesStr, DT_LEFT, False);
end;

procedure TGUITestRunner.TestCaseIgnoreSetUpTearDownLeaksMenuItemDrawItem(
  Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  MenuLooksInactive(ACanvas, ARect, Selected, FIgnoreLeakStr,
    DT_LEFT, FIgnoreSetUpTearDownLeakPtyOverridden);
end;

procedure TGUITestRunner.pmTestTreePopup(Sender: TObject);
var
  ANode: TTreeNode;
  ATest: ITestProxy;

begin
  if TestTree.Selected <> nil then
  begin
    ANode := TestTree.Selected;
    if (ANode <> nil) then
    begin
      ATest := NodeToTest(ANode);
      TestCasePopup.Enabled := IsTestMethod(ATest);
    end;
    ATest := nil;
  end;
end;

function TGUITestRunner.GetPropertyName(const Caption: string): string;
var
  TempStr: string;
  PosSpace: Integer;
begin
  TempStr := Trim(Caption);
  PosSpace := Pos(' ',TempStr);
  if (PosSpace > 1)  then
    Result := Copy(TempStr, 1, PosSpace-1)
  else
    Result := TempStr;
end;

function TGUITestRunner.get_TestResult: TTestResult;
begin
  Result := FTestResult;
end;

procedure TGUITestRunner.FailNoCheckExecutedMenuItemClick(Sender: TObject);
begin
  Clipboard.AsText := GetPropertyName(NoChecksStrT);
end;

procedure TGUITestRunner.FailsOnMemoryLeakMenuItemClick(Sender: TObject);
begin
  Clipboard.AsText := GetPropertyName(MemLeakStrT);
end;

procedure TGUITestRunner.AllowedLeakSizeMenuItemClick(Sender: TObject);
begin
  Clipboard.AsText := GetPropertyName(MemBytesStr0);
end;

procedure TGUITestRunner.TestCaseIgnoreSetUpTearDownLeaksMenuItemClick(
  Sender: TObject);
begin
  Clipboard.AsText := GetPropertyName(IgnoreStrT);
end;

procedure TGUITestRunner.RunSelectedTestAltActionExecute(Sender: TObject);
begin
  RunSelectedTestActionExecute(Self);
  TestCasePropertiesActionExecute(Self);
end;

procedure TGUITestRunner.RecordSelectedTestAltActionExecute(Sender: TObject);
begin
  RecordSelectedTestActionExecute(Self);
  TestCasePropertiesActionExecute(Self);
end;

procedure TGUITestRunner.IgnoreMemoryLeakInSetUpTearDownActionExecute(
  Sender: TObject);
begin
  if FHoldOptions then
    Exit;

  with IgnoreMemoryLeakInSetUpTearDownAction do
    Checked := not Checked;
end;

procedure TGUITestRunner.ReportMemoryLeakTypeOnShutdownActionExecute(
  Sender: TObject);
begin
  if FHoldOptions then
    Exit;

  with ReportMemoryLeakTypeOnShutdownAction do
  begin
  {$IFDEF FASTMM}
    Checked := not Checked;
    {$IFNDEF VER150}  //ToDo: Make this hack to get Delphi 7 compiling more robust
      ReportMemoryLeaksOnShutdown := Checked;
    {$ENDIF}
  {$ELSE}
    Checked := False;
  {$ENDIF}
  end;    // with
end;

procedure TGUITestRunner.FailIfNoChecksExecutedActionUpdate(
  Sender: TObject);
begin
  with CheckCheckedToolButton do
  begin
    if FailIfNoChecksExecutedAction.Checked then
    begin
      ImageIndex := 13;
      Hint := 'Checkless Test Detection enabled';
      Down := True;
    end
    else
    begin
      ImageIndex := 14;
      Hint := 'CheckLess Test Detection disabled';
      Down := False;
    end;
  end;
end;

procedure TGUITestRunner.FailTestCaseIfMemoryLeakedActionUpdate(
  Sender: TObject);
begin
  with CheckMemLeaksToolButton do
  begin
    if FailTestCaseIfMemoryLeakedAction.Checked then
    begin
      ImageIndex := 11;
      Hint := 'Memory Leak Detection enabled';
      Down := True;
      IgnoreMemoryLeakInSetUpTearDownAction.Enabled := True;
    end
    else
    begin
      ImageIndex := 12;
      Hint := 'Memory Leak Detection disabled';
      Down := False;
      IgnoreMemoryLeakInSetUpTearDownAction.Checked := False;
    end;
  end;
end;

procedure TGUITestRunner.ShowTestCasesWithRunTimePropertiesActionUpdate(
  Sender: TObject);
begin
  PropertyOverrideToolButton.Down := ShowTestCasesWithRunTimePropertiesAction.Checked;
end;

procedure TGUITestRunner.ShowTestCasesWithWarningsActionUpdate(
  Sender: TObject);
begin
  ShowWarnedTestToolButton.Down := ShowTestCasesWithWarningsAction.Checked;
end;

procedure TGUITestRunner.InhibitSummaryLevelChecksActionExecute(Sender: TObject);
begin
  if FHoldOptions then
    Exit;

  with InhibitSummaryLevelChecksAction do
    Checked := not Checked;
end;

procedure TGUITestRunner.EnableWarningsActionUpdate(Sender: TObject);
begin
  with ShowWarnedTestToolButton do
  begin
    if EnableWarningsAction.Checked then
    begin
      ImageIndex := 19;
      Hint := 'Warnings enabled';
      Down := True;
    end
    else
    begin
      ImageIndex := 18;
      Hint := 'Warnings disabled';
      Down := False;
    end;
  end;
end;

procedure TGUITestRunner.InhibitSummaryLevelChecksActionUpdate(Sender: TObject);
begin
  with InhibitSummaryLevelChecksToolButton do
  begin
    if InhibitSummaryLevelChecksAction.Checked then
    begin
      ImageIndex := 21;
      Hint := 'Inhibit Summary Level Checking. All Checks active';
      Down := True;
    end
    else
    begin
      ImageIndex := 20;
      Hint := 'Summary Level Checking enabled. Following Checks skipped on pass';
      Down := False;
    end;
  end;
end;

procedure TGUITestRunner.EnableWarningsActionExecute(
  Sender: TObject);
begin
  if FHoldOptions then
    Exit;

  with EnableWarningsAction do
    Checked := not Checked;
end;

end.
