{-----------------------------------------------------------------------------
 Unit Name: uTypes_New
 Author:    Krystian Bigaj
 Date:      20-02-2011
 License:   MPL 1.1/GPL 2.0/LGPL 3.0
 EMail:     krystian.bigaj@gmail.com
 WWW:       http://code.google.com/p/kblib/

 Second version of record. Unit uTypes after modifications.
 In most cases you won't need to have two units, here in this demo there
 are two, only to show unit before and after modifications.

 1. TMyRecord type has been *copied* to implementation and renamed to TMyRecord_v1.
    Because declaration was moved to implemnetation section, it's not
    accessible to other units (not needed, as you need use only latest version
    outside of this unit).
 2. TMyRecord_v1.SaveTo procedure has been removed, because you don't need to
    save in old format anymore, only LoadFrom will be used.
 3. Added TMyRecord_v1.UpgradeTo procedure, which upgrades record to *latest*
    version. Manual copy of fields must be performed.
 4. Added new field to TMyRecord, and incresed version TMyRecord.cVersion
 5. Modified TMyRecord.LoadFrom code, to upgrade from older versions.
    First function try to load from latest version, if fails (version mismatch),
    then it tries to load from older versions.
    Upgrade functions is called in reverse order, because in most cases, you will
    need to upgrade from previous to latest version. Order is not much important,
    it's only for small optimization.
    You need to remember in case of addding new version, you will need also
    change TMyRecord_v1.UpgradeTo, because in that case, UpgradeTo must perform
    upgrade always to *latest* version.

 Note:
 In this example there is assumed that you need to do upgrade always
 to latest version:
 - V1->V3
 - V2->V3

 In addition to 5), in future you could make incremental upgrade, for example
 - V1->V2, and then V2->V3(latest)

 It's up to you how you would like to perform upgrade (as it need to be done
 manually). You need only know that if TKBDynamic.ReadFrom returns False,
 then stream is invalid (stream version or your type version is mismatch)
 and you can try to load it in other (older) version and then perform upgrade.

 TKBDynamic.ReadFrom reads only 4 bytes (size of TKBDynamicHeader), and if
 version is not valid, then it moves back to previous position and
 returns False, so you can test older versions.

-----------------------------------------------------------------------------}

unit uTypes_New;

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
    NewField: Boolean;  // <- added new field

    function LoadFrom(AStream: TStream): Boolean; // <- modified code to load from older versions
    procedure SaveTo(AStream: TStream);

  const
    cVersion = 2;  // <- incresed version number
    cDefaultOptions = [kdoAnsiStringCodePage, kdoUTF16ToUTF8]; // Save UnicodeString as UTF8 to save space
  end;

implementation

type

{ TMyRecord_v1 }

  TMyRecord_v1 = record
    Name: UnicodeString;
    Id: Integer;
    Strings: TMyStrings;

    function LoadFrom(AStream: TStream): Boolean;
    procedure UpgradeTo(var ALatest: TMyRecord); // <- added new procedure, but removed SaveTo
  const
    cVersion = 1;  // <- version remains same
  end;

function TMyRecord_v1.LoadFrom(AStream: TStream): Boolean;
begin
  // Changed TypeInfo(TMyRecord) -> TypeInfo(TMyRecord_v1)
  Result := TKBDynamic.ReadFrom(AStream, Self, TypeInfo(TMyRecord_v1), cVersion);
end;

procedure TMyRecord_v1.UpgradeTo(var ALatest: TMyRecord);
begin
  // Manual copy from V1 to latest version
  ALatest.Name := Self.Name;
  ALatest.Id := Self.Id;
  ALatest.Strings := Self.Strings; // copy by ref, so no real strings duplication

  // New fields initialized to some default values
  ALatest.NewField := True; // <- some default value for new field
end;

{ Upgrade code }

function UpgradeFromV1(AStream: TStream; var ARec: TMyRecord): Boolean;
var
  lV1: TMyRecord_v1;
begin
  Result := lV1.LoadFrom(AStream);
  if Result then
    lV1.UpgradeTo(ARec);
end;

{ TMyRecord }

function TMyRecord.LoadFrom(AStream: TStream): Boolean;
begin
  Result :=
    // Try to load from latest version first
    TKBDynamic.ReadFrom(AStream, Self, TypeInfo(TMyRecord), cVersion) or
    // In future you can add upgrades from other versions, like:
    // UpgradeFromV4(AStream, Self) or
    // UpgradeFromV3(AStream, Self) or
    // UpgradeFromV2(AStream, Self) or
    UpgradeFromV1(AStream, Self);
end;

procedure TMyRecord.SaveTo(AStream: TStream);
begin
  // Save always in latest version
  TKBDynamic.WriteTo(AStream, Self, TypeInfo(TMyRecord), cVersion, cDefaultOptions);
end;

end.
