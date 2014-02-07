unit FormMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.Buttons, Vcl.StdCtrls, Vcl.ExtCtrls,
  GUIScript, GUIActionRecorder;

type
  TfrmMain = class(TForm)
    btnRecord: TButton;
    btnRun: TButton;
    mmoScript: TMemo;
    mmoOutput: TMemo;
    pnlTestUI: TPanel;
    Label1: TLabel;
    SpeedButton1: TSpeedButton;
    edtSource: TEdit;
    btnAdd: TButton;
    lbDest: TListBox;
    btnDisable: TButton;
    btnModal: TButton;
    CheckBox1: TCheckBox;
    RadioButton1: TRadioButton;
    ComboBox1: TComboBox;
    ListBox1: TListBox;
    BitBtn1: TBitBtn;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    btnLoad: TButton;
    btnSave: TButton;
    Memo1: TMemo;
    btnHelp: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnRecordClick(Sender: TObject);
    procedure btnRunClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnModalClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnDisableClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
  private
    FGUIScript: TGUIScript;
    procedure ResetControls;
  end;

var
  frmMain: TfrmMain;

implementation

uses
  FormHelp;

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FGUIScript := TGUIScript.Create;

  // Don't record the click on the record button (to stop the recording)
  GGUIActionRecorder.AddControlToIgnore(btnRecord);

  // Default to demo scripts dir
  OpenDialog1.InitialDir := ExtractFilePath(ParamStr(0)) + '..\..\..\demo\GUIScripting\scripts';
  SaveDialog1.InitialDir := OpenDialog1.InitialDir;

  ResetControls;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FGUIScript.Free;
end;

procedure TfrmMain.btnAddClick(Sender: TObject);
begin
  lbDest.Items.Add(edtSource.Text);
end;

procedure TfrmMain.btnDisableClick(Sender: TObject);
begin
  btnDisable.Enabled := false;
end;

procedure TfrmMain.btnModalClick(Sender: TObject);
begin
  ShowMessage('Modal Test');
end;

procedure TfrmMain.ResetControls;
begin
  edtSource.Text := 'Script Demo';
  lbDest.Clear;
  btnDisable.Enabled := true;
  CheckBox1.Checked := false;
  RadioButton1.Checked := false;
  ComboBox1.Text := 'TComboBox';
  ListBox1.Clear;
  ListBox1.Items.Add('one');
  ListBox1.Items.Add('two');
  ListBox1.Items.Add('three');
  Memo1.Text := 'TMemo';
end;

procedure TfrmMain.btnRunClick(Sender: TObject);
begin
  ResetControls;
  mmoOutput.Clear;

  if FGUIScript.Execute(mmoScript.Lines.Text) then
    mmoOutput.Lines.Add('Execute: succeeded')
  else
    mmoOutput.Lines.Add('Execute: failed');

  mmoOutput.Lines.Add('');
  mmoOutput.Lines.Add('ScriptResult:');
  mmoOutput.Lines.Add(FGUIScript.ScriptResult);
end;

procedure TfrmMain.btnRecordClick(Sender: TObject);
begin
  ResetControls;
  if GGUIActionRecorder.Active then
  begin
    btnRecord.Caption := 'Record';
    GGUIActionRecorder.Active := false;
    GGUIActionRecorder.Finalize;
    mmoScript.Lines.Text := FGUIScript.RecordedScript;
  end
  else
  begin
    btnRecord.Caption := 'Stop';
    GGUIActionRecorder.Initialize;
    GGUIActionRecorder.Active := true;
  end;
end;

procedure TfrmMain.btnHelpClick(Sender: TObject);
begin
  frmHelp.ShowModal;
end;

procedure TfrmMain.btnLoadClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    mmoScript.Lines.LoadFromFile(OpenDialog1.FileName);
    SaveDialog1.FileName := OpenDialog1.FileName;
  end;
end;

procedure TfrmMain.btnSaveClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
    mmoScript.Lines.SaveToFile(SaveDialog1.FileName);
end;

end.

