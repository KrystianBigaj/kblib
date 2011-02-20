{-----------------------------------------------------------------------------
 Unit Name: uTypes_Old
 Author:    Krystian Bigaj
 Date:      20-02-2011
 License:   MPL 1.1/GPL 2.0/LGPL 3.0
 EMail:     krystian.bigaj@gmail.com
 WWW:       http://code.google.com/p/kblib/

 First version of record. Unit uTypes before modifications.

 Note: If you are using record streaming for example to do some IPC communication
 between your applications, then mostly likely you don't need
 'upgrade feature' (if your all execs are updated).
 Only what you need to do is increse TMyRecord.cVersion const
 after each modification of TMyRecord structure.
 After it, if TMyRecord.LoadFrom returns False, then record stream
 is in invalid version, so you can 'drop communication'.

 By IPC I mean for example:
 - communication by anonymus/named pipes
 - using shared memory
 - communication by TCP/UDP streams
 - etc.

-----------------------------------------------------------------------------}

unit uTypes_Old;

interface

uses
  uKBDynamic,

  Classes;

type

{ TMyStrings }

  TMyStrings = array of UnicodeString;

{ TMyRecord }

  TMyRecord = record
    Name: UnicodeString;
    Id: Integer;
    Strings: TMyStrings;

    function LoadFrom(AStream: TStream): Boolean;
    procedure SaveTo(AStream: TStream);

  const
    cVersion = 1;
    cDefaultOptions = [kdoAnsiStringCodePage, kdoUTF16ToUTF8];
  end;

implementation

{ TMyRecord }

function TMyRecord.LoadFrom(AStream: TStream): Boolean;
begin
  Result := TKBDynamic.ReadFrom(AStream, Self, TypeInfo(TMyRecord), cVersion);
end;

procedure TMyRecord.SaveTo(AStream: TStream);
begin
  TKBDynamic.WriteTo(AStream, Self, TypeInfo(TMyRecord), cVersion, cDefaultOptions);
end;

end.
