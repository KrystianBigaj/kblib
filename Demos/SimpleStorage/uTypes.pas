{-----------------------------------------------------------------------------
 Unit Name: uTypes
 Author:    Krystian Bigaj
 Date:      12-02-2011

 D2009+ example
 It doesn't work in D2006 (but might work in D2007 - not tested):
  TDirectoryNode = record
    ...
    Directories: array of TDirectoryNode; <- D2006 (and probably earlier doesn't support this)
  end;

 See Readme.txt
-----------------------------------------------------------------------------}

unit uTypes;

interface

uses
  Classes, uKBDynamic;

const
  cSimpleStorageVersion = 1;

type

{ TFileContent }

  TFileContent = array of Byte;

{ TFileNode }

  TFileNode = record
    Name: String;
    FileDate: TDateTime;
    FileContentSkipped: Boolean;
    Content: TFileContent;

    function ContentLen: Integer;
  end;

{ TDirectoryNode }

  TDirectoryNode = record
    Name: String;
    Files: array of TFileNode;
    Directories: array of TDirectoryNode;
  end;

{ TSimpleTreeStorage }

  TSimpleTreeStorage = record
    StorageName: UnicodeString;
    RootDir: TDirectoryNode;

    function LoadFrom(AStream: TStream): Boolean;
    procedure SaveTo(AStream: TStream);
  end;

implementation

{ TSimpleTreeStorage }

function TSimpleTreeStorage.LoadFrom(AStream: TStream): Boolean;
begin
  Result := TKBDynamic.ReadFrom(AStream, Self, TypeInfo(TSimpleTreeStorage), cSimpleStorageVersion);
end;

procedure TSimpleTreeStorage.SaveTo(AStream: TStream);
begin
  TKBDynamic.WriteTo(AStream, Self, TypeInfo(TSimpleTreeStorage), cSimpleStorageVersion);
end;

{ TFileNode }

function TFileNode.ContentLen: Integer;
begin
  Result := Length(Content);
end;

end.
