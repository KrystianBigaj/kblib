program SimpleStorage;

uses
  Forms,
  uKBDynamic in '..\..\Sources\uKBDynamic.pas',
  uTypes in 'uTypes.pas',
  uMainForm in 'uMainForm.pas' {frmMain},
  uStorageForm in 'uStorageForm.pas' {frmStorage};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
