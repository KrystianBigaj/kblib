{-----------------------------------------------------------------------------
 Unit Name: uMainForm
 Author:    Krystian Bigaj
 Date:      20-02-2011
 License:   MPL 1.1/GPL 2.0/LGPL 3.0
 EMail:     krystian.bigaj@gmail.com
 WWW:       http://code.google.com/p/kblib/
-----------------------------------------------------------------------------}

unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Spin, StdCtrls;

type

{ TfrmMain }

  TfrmMain = class(TForm)
    mText: TMemo;
    edtName: TEdit;
    seId: TSpinEdit;
    gbOld: TGroupBox;
    btnLoadV1: TButton;
    btnSaveV1: TButton;
    GroupBox1: TGroupBox;
    btnLoadV2: TButton;
    btnSaveV2: TButton;
    chkNewField: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure btnLoadV1Click(Sender: TObject);
    procedure btnSaveV1Click(Sender: TObject);
    procedure btnLoadV2Click(Sender: TObject);
    procedure btnSaveV2Click(Sender: TObject);
  private
    FFilename: String;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  uTypes_Old, uTypes_New;

{$R *.dfm}

procedure TfrmMain.btnLoadV1Click(Sender: TObject);
var
  lRec: uTypes_Old.TMyRecord;
  lFile: TFileStream;
  lIdx: Integer;
begin
  lFile := TFileStream.Create(FFilename, fmOpenRead or fmShareDenyWrite);
  try
    if not lRec.LoadFrom(lFile) then
      raise Exception.CreateFmt('Failed to load from file "%s". Incorrect stream version.', [FFilename]);
  finally
    lFile.Free;
  end;

  edtName.Text := lRec.Name;
  seId.Value := lRec.Id;
  chkNewField.Checked := False; // not used in V1

  mText.Lines.BeginUpdate;
  try
    mText.Lines.Clear;
    for lIdx := 0 to Length(lRec.Strings) - 1 do
      mText.Lines.Add(lRec.Strings[lIdx]);
  finally
    mText.Lines.EndUpdate;
  end;
end;

procedure TfrmMain.btnLoadV2Click(Sender: TObject);
var
  lRec: uTypes_New.TMyRecord;
  lFile: TFileStream;
  lIdx: Integer;
begin
  lFile := TFileStream.Create(FFilename, fmOpenRead or fmShareDenyWrite);
  try
    // Load (and upgrade if needed)
    if not lRec.LoadFrom(lFile) then
      raise Exception.CreateFmt('Failed to load from file "%s". Incorrect stream version.', [FFilename]);
  finally
    lFile.Free;
  end;

  edtName.Text := lRec.Name;
  seId.Value := lRec.Id;
  chkNewField.Checked := lRec.NewField; // new field used

  mText.Lines.BeginUpdate;
  try
    mText.Lines.Clear;
    for lIdx := 0 to Length(lRec.Strings) - 1 do
      mText.Lines.Add(lRec.Strings[lIdx]);
  finally
    mText.Lines.EndUpdate;
  end;
end;

procedure TfrmMain.btnSaveV1Click(Sender: TObject);
var
  lRec: uTypes_Old.TMyRecord;
  lFile: TFileStream;
  lIdx: Integer;
begin
  lRec.Name := edtName.Text;
  lRec.Id := seId.Value;
  mText.Lines.BeginUpdate;
  try
    SetLength(lRec.Strings, mText.Lines.Count);
    for lIdx := 0 to mText.Lines.Count - 1 do
      lRec.Strings[lIdx] := mText.Lines[lIdx];
  finally
    mText.Lines.EndUpdate;
  end;

  lFile := TFileStream.Create(FFilename, fmCreate);
  try
    lRec.SaveTo(lFile);
  finally
    lFile.Free;
  end;
end;

procedure TfrmMain.btnSaveV2Click(Sender: TObject);
var
  lRec: uTypes_New.TMyRecord;
  lFile: TFileStream;
  lIdx: Integer;
begin
  lRec.Name := edtName.Text;
  lRec.Id := seId.Value;
  lRec.NewField := chkNewField.Checked;

  mText.Lines.BeginUpdate;
  try
    SetLength(lRec.Strings, mText.Lines.Count);
    for lIdx := 0 to mText.Lines.Count - 1 do
      lRec.Strings[lIdx] := mText.Lines[lIdx];
  finally
    mText.Lines.EndUpdate;
  end;

  lFile := TFileStream.Create(FFilename, fmCreate);
  try
    lRec.SaveTo(lFile);
  finally
    lFile.Free;
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FFilename := ChangeFileExt(Application.ExeName, '.bin');
end;

end.
