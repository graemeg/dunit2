program DemoGUIScripting;

uses
  Vcl.Forms,
  FormMain in '..\..\demo\GUIScripting\FormMain.pas' {frmMain},
  FormHelp in '..\..\demo\GUIScripting\FormHelp.pas' {frmHelp};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmHelp, frmHelp);
  Application.Run;
end.
