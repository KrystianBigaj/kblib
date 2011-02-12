{-----------------------------------------------------------------------------
 Unit Name: uMain
 Author:    Krystian Bigaj
 Date:      12-02-2011

 Note: ub uTypes.pas you can how TSimpleTreeStorage is defined
-----------------------------------------------------------------------------}

unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uTypes, StdCtrls, ComCtrls;

type

{ TfrmMain }

  TfrmMain = class(TForm)
    gbStorage: TGroupBox;
    Label1: TLabel;
    edtStorageName: TEdit;
    btnClose: TButton;
    tvStorage: TTreeView;
    dlgOpen: TOpenDialog;
    btnCreate: TButton;
    btnLoad: TButton;
    procedure btnCloseClick(Sender: TObject);
    procedure btnCreateClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  protected
    function GetDisplayFileContent(AFileContent: TFileContent; APreviewBytes: Integer = 30): String;
    procedure LoadFile(AParent: TTreeNode; AFile: TFileNode);
    procedure LoadDir(AParent: TTreeNode; ADir: TDirectoryNode);

    procedure LoadStorage(AFileName: String); overload;
    procedure LoadStorage(AStream: TStream); overload;

  public
    function GetDefaultStorage: String;
  end;

var
  frmMain: TfrmMain;

implementation

uses
  uStorageForm, Math;

{$R *.dfm}

procedure TfrmMain.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.btnCreateClick(Sender: TObject);
var
  lDir: String;
  lFileName: String;
begin
  lDir := ExpandFileName(ExtractFilePath(Application.ExeName) + '..\..\..\');
  lFileName := GetDefaultStorage;

  if not TfrmStorage.NewStorage(lDir, lFileName) then
    Exit;

  dlgOpen.FileName := lFileName;

  if Application.MessageBox('Storage has been created. Do you want to load it?',
    PChar(Application.Title), MB_ICONQUESTION or MB_YESNO) <> IDYES
  then
    Exit;

  LoadStorage(lFileName);
end;

procedure TfrmMain.btnLoadClick(Sender: TObject);
begin
  if dlgOpen.Execute then
    LoadStorage(dlgOpen.FileName);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  dlgOpen.FileName := GetDefaultStorage;
end;

function TfrmMain.GetDefaultStorage: String;
begin
  Result := ChangeFileExt(Application.ExeName, '.bin');
end;

function TfrmMain.GetDisplayFileContent(AFileContent: TFileContent; APreviewBytes: Integer): String;
var
  lIdx: Integer;
begin
  if Length(AFileContent) = 0 then
    Result := '(empty file)'
  else
  begin
    SetLength(Result, Min(Length(AFileContent), APreviewBytes));
    for lIdx := 0 to Length(Result) - 1 do
      if AFileContent[lIdx] < 32 then
        Result[lIdx + 1] := '.'
      else
        // Not reliable conversion form AnsiChar to WideChar
        // but it's just demo, so who cares?
        Result[lIdx + 1] := WideChar(AnsiChar(AFileContent[lIdx]));

    if APreviewBytes < Length(AFileContent) then
      Result := Result + ' ...';
  end;
end;

procedure TfrmMain.LoadStorage(AFileName: String);
var
  lFile: TFileStream;
begin
  lFile := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadStorage(lFile);
  finally
    lFile.Free;
  end;
end;

procedure TfrmMain.LoadStorage(AStream: TStream);
var
  lStorage: TSimpleTreeStorage;
begin
  if not lStorage.LoadFrom(AStream) then
    raise Exception.Create('Failed to load storage (invalid file version/header)!');

  edtStorageName.Text := lStorage.StorageName;
  tvStorage.Items.BeginUpdate;
  try
    tvStorage.Items.Clear;

    LoadDir(nil, lStorage.RootDir);
  finally
    tvStorage.Items.EndUpdate;
  end;
end;

procedure TfrmMain.LoadDir(AParent: TTreeNode; ADir: TDirectoryNode);
var
  lChild: TTreeNode;
  lIdx: Integer;
begin
  lChild := tvStorage.Items.AddChild(AParent, Format('[%s]', [ADir.Name]));

  for lIdx := 0 to Length(ADir.Directories) - 1 do
    LoadDir(lChild, ADir.Directories[lIdx]);

  for lIdx := 0 to Length(ADir.Files) - 1 do
    LoadFile(lChild, ADir.Files[lIdx]);
end;

procedure TfrmMain.LoadFile(AParent: TTreeNode; AFile: TFileNode);
var
  lChild: TTreeNode;
begin
  lChild := tvStorage.Items.AddChild(AParent, AFile.Name);
  tvStorage.Items.AddChild(lChild, Format('FileSize: %d', [AFile.ContentLen]));
  tvStorage.Items.AddChild(lChild, Format('FileDate: %s', [DateTimeToStR(AFile.FileDate)]));
  if AFile.FileContentSkipped then
    tvStorage.Items.AddChild(lChild, 'Content preview: (file content not stored: FileContentSkipped=True)')
  else
    tvStorage.Items.AddChild(lChild, Format('Content preview: %s', [GetDisplayFileContent(AFile.Content)]));
end;

end.
