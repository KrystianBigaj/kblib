program RecordVersions;

uses
  Forms,
  uKBDynamic in '..\..\Sources\uKBDynamic.pas',
  uMainForm in 'uMainForm.pas' {frmMain},
  uTypes_Old in 'uTypes_Old.pas',
  uTypes_New in 'uTypes_New.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
