program SpeedDemo;

uses
  Forms,
  uKBDynamic in '..\..\Sources\uKBDynamic.pas',
  uMainForm in 'uMainForm.pas' {frmMain};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
