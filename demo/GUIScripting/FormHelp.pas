unit FormHelp;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmHelp = class(TForm)
    mmoHelp: TMemo;
    btnOK: TButton;
    procedure FormCreate(Sender: TObject);
  end;

var
  frmHelp: TfrmHelp;

implementation

{$R *.dfm}

procedure TfrmHelp.FormCreate(Sender: TObject);
begin
  mmoHelp.Lines.Add('The GUI scripting feature allows you to automate the UI and test the results.');
  mmoHelp.Lines.Add('The scripts can be simple or complex.');
  mmoHelp.Lines.Add('');
  mmoHelp.Lines.Add('Script Language');
  mmoHelp.Lines.Add('The scripting language is based on dwScript: http://code.google.com/p/dwscript/wiki/Language');
  mmoHelp.Lines.Add('It is an Object Pascal dialect like Delphi with some differences and limitations.');
  mmoHelp.Lines.Add('');
  mmoHelp.Lines.Add('In addition to the standard methods supported in dwScript the following automation and testing methods are provided.');
  mmoHelp.Lines.Add('You can also create your own methods.');
  mmoHelp.Lines.Add('');
  mmoHelp.Lines.Add('Script Control');
  mmoHelp.Lines.Add('RunScript(''FileName''); // Load and run an external script');
  mmoHelp.Lines.Add('TerminateScript; // Halt execution of the script');
  mmoHelp.Lines.Add('');
  mmoHelp.Lines.Add('Entering Text');
  mmoHelp.Lines.Add('EnterTextInto(''ControlName'', ''Text''); // Enter basic text');
  mmoHelp.Lines.Add('EnterKeyInto(''ControlName'', Key, ''[TShiftState, ...]''); // Keypress such as ctrl-shift-home: VK_HOME, ''[ssCtrl, ssShift]''');
  mmoHelp.Lines.Add('EnterKey(Key, ''[TShiftState, ...]''); // Into focused control');
  mmoHelp.Lines.Add('');
  mmoHelp.Lines.Add('Mouse Control');
  mmoHelp.Lines.Add('LeftClick(''ControlName'', X, Y); // Control co-ords');
  mmoHelp.Lines.Add('LeftClickAt(X, Y); // Window co-ords');
  mmoHelp.Lines.Add('LeftClickControl(''ControlName'');');
  mmoHelp.Lines.Add('LeftDoubleClick(''ControlName'', X, Y);');
  mmoHelp.Lines.Add('LeftDoubleClickAt(X, Y);');
  mmoHelp.Lines.Add('LeftDoubleClickControl(''ControlName'');');
  mmoHelp.Lines.Add('RightClick(''ControlName'', X, Y);');
  mmoHelp.Lines.Add('RightClickAt(X, Y);');
  mmoHelp.Lines.Add('RightClickControl(''ControlName'');');
  mmoHelp.Lines.Add('RightDoubleClick(''ControlName'', X, Y);');
  mmoHelp.Lines.Add('RightDoubleClickAt(X, Y);');
  mmoHelp.Lines.Add('RightDoubleClickControl(''ControlName'');');
  mmoHelp.Lines.Add('');
  mmoHelp.Lines.Add('General Testing');
  mmoHelp.Lines.Add('Fail(''ErrorMessage''); // Mark the test as failed');
  mmoHelp.Lines.Add('CheckEquals(''ExpectedValue'', ''ActualValue'');');
  mmoHelp.Lines.Add('CheckNotEquals(''NotExpectedValue'', ''ActualValue'');');
  mmoHelp.Lines.Add('');
  mmoHelp.Lines.Add('UI Testing');
  mmoHelp.Lines.Add('ControlText(''ControlName''): string; // Retrieve text representation of control "value"');
  mmoHelp.Lines.Add('CheckEnabled(''ControlName'');');
  mmoHelp.Lines.Add('CheckNotEnabled(''ControlName'');');
  mmoHelp.Lines.Add('CheckVisible(''ControlName'');');
  mmoHelp.Lines.Add('CheckNotVisible(''ControlName'');');
  mmoHelp.Lines.Add('CheckFocused(''ControlName'');');
  mmoHelp.Lines.Add('CheckControlTextEqual(''ControlName'', ''Text'');');
end;

end.
