{-----------------------------------------------------------------------------
 Unit Name: uMainForm
 Author:    Krystian Bigaj
 Date:      13-02-2011

 Simple DB-like storage:
-----------------------------------------------------------------------------}

unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uKBDynamic, StdCtrls, Spin;

type

{ TTestRecord }

  TTestRecord = record
    Id: Integer;
    Value: UnicodeString;
  end;

{ TTestTable }

  TTestTable = array of TTestRecord;

{ TTestDB }

  TTestDB = record
    TestTable: TTestTable;
  end;

{ TfrmMain }

  TfrmMain = class(TForm)
    btnSave: TButton;
    btnLoad: TButton;
    mLog: TMemo;
    seRecordCount: TSpinEdit;
    chkUTF8: TCheckBox;
    procedure btnSaveClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
  private
    FQPC, FQPCFreq: Int64;

    procedure QPCReset(S: String = '');
    procedure QPCLog(S: String);
    procedure Log(S: String; const A: array of const);
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.btnSaveClick(Sender: TObject);
var
  lDB: TTestDB;
  lIdx: Integer;
  lFile: TFileStream;
  lMemory: TMemoryStream;
  lOptions: TKBDynamicOptions;
begin
  Log('--- Save', []);
  lOptions := [];
  if chkUTF8.Checked then
    Include(lOptions, kdoUTF16ToUTF8);

  Log('Record count: %d', [seRecordCount.Value]);
  QPCReset;
  SetLength(lDB.TestTable, seRecordCount.Value);
  QPCLog('Allocating DB took');

  QPCReset;
  for lIdx := 0 to Length(lDB.TestTable) - 1 do
    with lDB.TestTable[lIdx] do
    begin
      Id := lIdx + 1;
      Value := 'test id ' + IntToStr(lIdx);
    end;
  QPCLog('Fill DB took');

  lMemory := TMemoryStream.Create;
  try
    QPCReset;
    TKBDynamic.WriteTo(lMemory, lDB, TypeInfo(TTestDB), 1, lOptions);
    QPCLog('Saving DB to TMemoryStream took');
    Log('DB size %.2fMB', [lMemory.Size / 1024 / 1024]);

    lFile := TFileStream.Create('test.db', fmCreate);
    try
      lFile.CopyFrom(lMemory, 0);
    finally
      lFile.Free;
    end;
  finally
    lMemory.Free;
  end;

end;

procedure TfrmMain.btnLoadClick(Sender: TObject);
var
  lDB: TTestDB;
  lFile: TFileStream;
  lMemory: TMemoryStream;
begin
  Log('--- Load', []);

  lMemory := TMemoryStream.Create;
  try
    lFile := TFileStream.Create('test.db', fmOpenRead or fmShareDenyWrite);
    try
      lMemory.CopyFrom(lFile, 0);
    finally
      lFile.Free;
    end;
    lMemory.Position := 0;

    QPCReset;
    TKBDynamic.ReadFrom(lMemory, lDB, TypeInfo(TTestDB), 1);
    QPCLog('Loading DB from TMemoryStream took');
    Log('Record count: %d', [Length(lDB.TestTable)]);
  finally
    lMemory.Free;
  end;
end;

procedure TfrmMain.Log(S: String; const A: array of const);
begin
  mLog.Lines.Add(Format(S, A));
end;

procedure TfrmMain.QPCLog(S: String);
var
  lQPC, lQPCFreq: Int64;
begin
  QueryPerformanceCounter(lQPC);
  QueryPerformanceFrequency(lQPCFreq);
  if FQPCFreq <> lQPCFreq then
    Log('%d <> %d', [FQPCFreq, lQPCFreq]);

  Log('%s %.4fs', [s, (lQPC - FQPC)/FQPCFreq]);

end;

procedure TfrmMain.QPCReset(S: String);
begin
  if S <> '' then
    Log(s, []);

  QueryPerformanceFrequency(FQPCFreq);
  QueryPerformanceCounter(FQPC);
end;

end.
