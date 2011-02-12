{-----------------------------------------------------------------------------
 Unit Name: uStorageForm
 Author:    Krystian Bigaj
 Date:      12-02-2011
-----------------------------------------------------------------------------}

unit uStorageForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uTypes;

type

{ TfrmStorage }

  TfrmStorage = class(TForm)
    gbCreate: TGroupBox;
    lblStorageName: TLabel;
    lblDirIn: TLabel;
    lblFileOut: TLabel;
    edtDirIn: TEdit;
    edtFileOut: TEdit;
    edtStorageName: TEdit;
    btnCreate: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    procedure btnCreateClick(Sender: TObject);
  private
    FTotalFileSize: Int64;
    function LoadFileContent(AFilePath: String; var ASkipped: Boolean): TFileContent;

    // APath must ends with "Trailing Path Delimiter"
    procedure CreateSubDirStorage(APath: String; var ADirNode: TDirectoryNode);

  public
    function CreateStorage(AStorageName: String; ADir: String): TSimpleTreeStorage;

    class function NewStorage(var ADir, AOutFile: String): Boolean;
  end;

implementation

{$R *.dfm}

{ TfrmStorage }

class function TfrmStorage.NewStorage(var ADir, AOutFile: String): Boolean;
var
  lFrm: TfrmStorage;
begin
  lFrm := TfrmStorage.Create(nil);
  try
    lFrm.edtDirIn.Text := ADir;
    lFrm.edtFileOut.Text := AOutFile;

    Result := lFrm.ShowModal = mrOk;
    if Result then
    begin
      ADir := lFrm.edtDirIn.Text;
      AOutFile := lFrm.edtFileOut.Text;
    end;
  finally
    lFrm.Free;
  end;
end;

procedure TfrmStorage.CreateSubDirStorage(APath: String;
  var ADirNode: TDirectoryNode);
var
  lSR: TSearchRec;

  procedure DoAddDir;
  var
    lIdx: Integer;
  begin
    lIdx := Length(ADirNode.Directories);
    // Do not ever write code like this in production !!! It can be slow in case
    // of many directories
    SetLength(ADirNode.Directories, lIdx + 1);

    ADirNode.Directories[lIdx].Name := lSR.Name;
    CreateSubDirStorage(APath + lSR.Name + '\', ADirNode.Directories[lIdx]);
  end;

  procedure DoAddFile;
  var
    lIdx: Integer;
    lFilePath: String;
  begin
    lFilePath := APath + lSR.Name;
    // Skip output file
    if SameFileName(lFilePath, edtFileOut.Text) then
      Exit;

    lIdx := Length(ADirNode.Files);
    // Do not ever write code like this in production !!! It can be slow in case
    // of many file
    SetLength(ADirNode.Files, lIdx + 1);

    ADirNode.Files[lIdx].Name := lSR.Name;
    ADirNode.Files[lIdx].FileDate := FileDateToDateTime(lSR.Time);
    ADirNode.Files[lIdx].Content := LoadFileContent(lFilePath, ADirNode.Files[lIdx].FileContentSkipped);
  end;

begin
  SetLength(ADirNode.Files, 0);
  SetLength(ADirNode.Directories, 0);

  if FindFirst(APath + '*.*', faAnyFile, lSR) = 0 then
  try
    repeat
      if (lSR.Name = '.') or (lSR.Name = '..') then
        Continue;

      if lSR.Attr and faDirectory = faDirectory then
        DoAddDir
      else
        DoAddFile;

    until FindNext(lSR) <> 0;
  finally
    FindClose(lSR);
  end;
end;

function TfrmStorage.LoadFileContent(AFilePath: String; var ASkipped: Boolean): TFileContent;
const
  cLimitTotalFileSize = 100 * 1024 * 1024;
var
  lFile: TFileStream;
begin
  lFile := TFileStream.Create(AFilePath, fmOpenRead or fmShareDenyWrite);
  try
    ASkipped := FTotalFileSize + lFile.Size > cLimitTotalFileSize;

    if ASkipped then
      SetLength(Result, 0)
    else
    begin
      SetLength(Result, lFile.Size);
      if Length(Result) > 0 then
        lFile.ReadBuffer(Result[0], Length(Result));

      Inc(FTotalFileSize, lFile.Size);
    end;
  finally
    lFile.Free;
  end;
end;

procedure TfrmStorage.btnCreateClick(Sender: TObject);
var
  lStorage: TSimpleTreeStorage;
  lFile: TFileStream;
begin
  lFile := TFileStream.Create(edtFileOut.Text, fmCreate);
  try
    lStorage := CreateStorage(edtStorageName.Text, edtDirIn.Text);
    lStorage.SaveTo(lFile);
  finally
    lFile.Free;
  end;

  ModalResult := mrOk;
end;

function TfrmStorage.CreateStorage(AStorageName, ADir: String): TSimpleTreeStorage;
begin
  FTotalFileSize := 0;

  Result.StorageName := AStorageName;

  Result.RootDir.Name := ExtractFileName(ExcludeTrailingPathDelimiter(ADir));
  CreateSubDirStorage(IncludeTrailingPathDelimiter(ADir), Result.RootDir);
end;

end.
