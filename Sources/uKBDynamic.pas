{-------------------------------------------------------------------------------
 Unit Name: uKBDynamic
 Author:    Krystian Bigaj
 Date:      02-10-2010
 License:   MPL 1.1/GPL 2.0/LGPL 3.0
 EMail:     krystian.bigaj@gmail.com
 WWW:       http://code.google.com/p/kblib/

 Tested on Delphi 2006/2009/XE.

 See TestuKBDynamic.pas for some examples of usage.

 Notes:
  - Streams are not fully compatibile DU* vs. DNU*
    (only if you are using AnsiString).
  - If you care about stream compatibility (DU vs. DNU),
    as String type use always UnicodeString (for DNU it's defined as WideString).
    If you don't need Unicode then use AnsiString.
  - In DNU CodePage for AnsiString is stored as Windows.GetACP
    (it should be System.DefaultSystemCodePage, but I cannot get this under D2006).
    CodePage currently is not used in DNU at all. It's only to make binary
    stream comatibile DN vs. DNU. It will probably change in future.
  - In DU CodePage for AnsiString is used as is should be.
  - To speed-up writing to stream, APreAllocSize is by default set to True.
  - For obvious reason, any pointers or pointer types
    are stored directly as in memory (like Pointer, PAnsiChar, TForm, etc.)
  - Because streams are storead as binary, after change in any type you must provide
    version compatibility. If TKBDynamic.ReadFrom returns False, then
    expected version AVersion doesn't match with one stored in stream.
  - Don't store interfaces in types, because you will get exception.
    In future there is a plan to add (or use generic one) interface type
    with Load/Save methods. So any interface that implements that one
    could be added to for example to record with store/restore functionality.
  - Don't store Variant type, you will get an exception
    This could be handled in future (for of course only simple types)
  - ReadFrom can raise exceptions for example in case of invalid stream
    or in out of memory condition
  * DU - Delphi Unicode (Delphi D2009+)
  * DNU - Delphi non-Unicode (older than D2009)

-------------------------------------------------------------------------------}

unit uKBDynamic;

interface

uses
  Windows, SysUtils, Classes, TypInfo;

type

{$IF CompilerVersion >= 20.0}
  {$DEFINE KBDYNAMIC_UNICODE}
{$IFEND}

{$IFNDEF KBDYNAMIC_UNICODE}
  UnicodeString = WideString;
{$ENDIF}

{ TKBDynamicOption }

  TKBDynamicOption = (
    kdoAnsiStringCodePage,    // Stores CodePage for AnsiString. Adds 2 bytes for each AnsiString.
                              // Only for D2009+. For older versions currently doesn't take any effect.
                              // If you are using non-Unicode delphi and dont care about compatibility
                              // then
                              //
                              // Default: On

    kdoUTF16ToUTF8,           // WideString/UnicodeString will be stored as UTF8.
                              // This saves space in output buffer, but a little slower operations (read/write/sizeof).
                              // Useful especially when stream size if important (like transfer streams over internet)
                              //
                              // Default: Off (unless KBDYNAMIC_DEFAULT_UTF8 is defined)

    kdoLimitToWordSize,       // Limits strings/DynArray sizes to Word (65535).
                              // If it exceeds limit then exception EKBDynamicWordLimit is raised
                              // (unless kdoLimitToWordSizeForce is set).
                              // Useful especially when stream size if important (like transfer streams over internet)
                              //
                              // Default: Off (unless KBDYNAMIC_DEFAULT_WORDSIZE is defined)

    kdoLimitToWordSizeForce   // If kdoLimitToWordSize is set and String/DynArray exceeds 65535 limit,
                              // then String/DynArray is limited (cut-off) to 65535 elements.
                              // No exception is raised.
                              //
                              // NOTE: this option doesn't take any effect in ReadDynamicFromStreamNH
                              //
                              // WARNING: unasfe
                              //   as UTF8/UTF16-result-string might be cut-off in the middle of charater -
                              //   for UTF8 non-ANSI characters more than 1 byte length,
                              //   or like surrogate UTF16 chars).
                              //
                              // Default: Off (unless KBDYNAMIC_DEFAULT_WORDSIZEFORCE is defined)
  );

  TKBDynamicOptions = set of TKBDynamicOption;

const
  // Default optons set
  TKBDynamicDefaultOptions = [
    kdoAnsiStringCodePage

{$IFDEF KBDYNAMIC_DEFAULT_UTF8}
    ,kdoUTF16ToUTF8
{$ENDIF}

{$IFDEF KBDYNAMIC_DEFAULT_WORDSIZE}
    ,kdoLimitToWordSize
{$ENDIF}

{$IFDEF KBDYNAMIC_DEFAULT_WORDSIZEFORCE}
    ,kdoLimitToWordSizeForce
{$ENDIF}
  ];

  // Useful options set for transfering streams over internet (safe)
  TKBDynamicNetworkSafeOptions = [
    kdoAnsiStringCodePage,
    kdoUTF16ToUTF8
  ];

  // Useful options set for transfering streams over internet (less space, but unsafe in some cases)
  // Use less space than TKBDynamicNetworkSafeOptions, but:
  // - kdoAnsiStringCodePage is NOT set, so doesn't store CodePage for AnsiString
  //     2 bytes less for each AnsiString
  // - kdoLimitToWordSize is set, so Strings/DynArray size is limited to 65535 elements
  //     2 bytes less for each String/AnsiString/WideString/DynArray)
  TKBDynamicNetworkUnsafeOptions = [
    kdoUTF16ToUTF8,
    kdoLimitToWordSize
  ];

type

{ EKBDynamic }

  EKBDynamic = class(Exception);

{ EKBDynamicInvalidType }

  EKBDynamicInvalidType = class(EKBDynamic)
  private
    FTypeKind: TTypeKind;
  public
    constructor Create(ATypeKind: TTypeKind);

    property TypeKind: TTypeKind read FTypeKind;
  end;

{ EKBDynamicWordLimit }

  EKBDynamicWordLimit = class(EKBDynamic)
  public
    constructor Create(ALen: Cardinal); reintroduce;
  end;

{ TKBDynamic }

  TKBDynamic = class
    class function Compare(const ADynamicType1, ADynamicType2;
      ATypeInfo: PTypeInfo): Boolean;

    class function GetSize(const ADynamicType; ATypeInfo: PTypeInfo;
      const AOptions: TKBDynamicOptions = TKBDynamicDefaultOptions): Cardinal;

    class procedure WriteTo(AStream: TStream; const ADynamicType;
      ATypeInfo: PTypeInfo; AVersion: Word = 1;
      const AOptions: TKBDynamicOptions = TKBDynamicDefaultOptions;
      APreAllocSize: Boolean = True);

    class function ReadFrom(AStream: TStream; const ADynamicType;
      ATypeInfo: PTypeInfo; AVersion: Word = 1): Boolean;

    // "No Header" version of methods
    // (4 bytes less, but you need take care of of version/compatibility and options)

    class function GetSizeNH(const ADynamicType; ATypeInfo: PTypeInfo;
      const AOptions: TKBDynamicOptions = TKBDynamicDefaultOptions): Cardinal;

    class procedure WriteToNH(AStream: TStream; const ADynamicType;
      ATypeInfo: PTypeInfo;
      const AOptions: TKBDynamicOptions = TKBDynamicDefaultOptions);

    class procedure ReadFromNH(AStream: TStream; const ADynamicType;
      ATypeInfo: PTypeInfo;
      const AOptions: TKBDynamicOptions = TKBDynamicDefaultOptions);
  end;

{ TKBDynamicHeader }

  TKBDynamicHeader = packed record
    Stream: record
      Version: Byte;
      Options: Byte;
    end;
    TypeVersion: Word;
  end;

// -----------------------------------------------------------------------------
// --- Config header options
// -----------------------------------------------------------------------------

const
  // Version (1 Byte)
  cKBDYNAMIC_STREAM_VERSION                 = $01;

  // CFG (1 Byte)
  cKBDYNAMIC_STREAM_CFG_UNICODE             = $01;  // Stream created in UNICODE version of delphi (D2009+),
                                                    // older versions doesn't support UnicodeString type,
                                                    // and CodePage for AnsiString/UTF8String

  cKBDYNAMIC_STREAM_CFG_UTF8                = $02;  // kdoUTF16ToUTF8

  cKBDYNAMIC_STREAM_CFG_WORDSIZE            = $04;  // kdoLimitToWordSize

  cKBDYNAMIC_STREAM_CFG_CODEPAGE            = $08;  // kdoAnsiStringCodePage

//cKBDYNAMIC_STREAM_CFG_XXX                 = $10;
//cKBDYNAMIC_STREAM_CFG_XXX                 = $20;
//cKBDYNAMIC_STREAM_CFG_XXX                 = $40;
//cKBDYNAMIC_STREAM_CFG_XXX                 = $80;

implementation

// -----------------------------------------------------------------------------
// --- Some RTTI info types (from System.pas)
// -----------------------------------------------------------------------------

type

{ TFieldInfo }

  PPTypeInfo = ^PTypeInfo;
  TFieldInfo = packed record
    TypeInfo: PPTypeInfo;
    Offset: Cardinal;
  end;

{ TFieldTable }

  PFieldTable = ^TFieldTable;
  TFieldTable = packed record
    X: Word;
    Size: Cardinal;
    Count: Cardinal;
    Fields: array [0..65535] of TFieldInfo;
  end;

{ TDynArrayTypeInfo }

  PDynArrayTypeInfo = ^TDynArrayTypeInfo;
  TDynArrayTypeInfo = packed record
    kind: Byte;
    name: string[0];
    elSize: Cardinal;
    elType: ^PDynArrayTypeInfo;
    varType: Integer;
  end;

// -----------------------------------------------------------------------------
// --- Compare
// -----------------------------------------------------------------------------

function DynamicCompare_Array(ADynamic1, ADynamic2: Pointer;
  ATypeInfo: PTypeInfo; ALength: Cardinal): Boolean; forward;

function DynamicCompare_Record(ADynamic1, ADynamic2: Pointer;
  ATypeInfo: PTypeInfo): Boolean;
var
  lFieldTable: PFieldTable;
  lCompare: Cardinal;
  lOffset: Cardinal;
  lIdx: Cardinal;
  lTypeInfo: PTypeInfo;
begin
  lFieldTable := PFieldTable(Cardinal(ATypeInfo) + Byte(ATypeInfo^.Name[0]));

  if lFieldTable^.Count = 0 then
  begin
    Result := CompareMem(ADynamic1, ADynamic2, lFieldTable^.Size);
    Exit;
  end;

  Result := False;
  lCompare := 0;
  lIdx := 0;

  while (lCompare < lFieldTable^.Size) and (lIdx < lFieldTable^.Count) do
  begin
    lOffset := lFieldTable^.Fields[lIdx].Offset;

    if lCompare < lOffset then
      if CompareMem(
        Pointer(Cardinal(ADynamic1) + lCompare),
        Pointer(Cardinal(ADynamic2) + lCompare),
        lOffset - lCompare
      ) then
        Inc(lCompare, lOffset - lCompare)
      else
        Exit;

    lTypeInfo := lFieldTable^.Fields[lIdx].TypeInfo^;

    if DynamicCompare_Array(
      Pointer(Cardinal(ADynamic1) + lOffset),
      Pointer(Cardinal(ADynamic2) + lOffset),
      lTypeInfo,
      1
    ) then
    begin
      case lTypeInfo^.Kind of
      tkArray, tkRecord:
        Inc(lCompare, PFieldTable(Cardinal(lTypeInfo) + Byte(lTypeInfo^.Name[0]))^.Size);
      else
        Inc(lCompare, SizeOf(Pointer));
      end;
    end else
      Exit;

    Inc(lIdx);
  end;

  if lCompare < lFieldTable^.Size then
    if not CompareMem(
      Pointer(Cardinal(ADynamic1) + lCompare),
      Pointer(Cardinal(ADynamic2) + lCompare),
      lFieldTable^.Size - lCompare
    ) then
      Exit;

  Result := True;
end;

function DynamicCompare_DynArray(ADynamic1, ADynamic2: Pointer;
  ATypeInfo: PTypeInfo): Boolean;
var
  lDyn: PDynArrayTypeInfo;
  lLen, lLen2: Cardinal;
begin
  if PPointer(ADynamic1)^ = nil then
    lLen := 0
  else
    lLen := PCardinal(PCardinal(ADynamic1)^ - SizeOf(Cardinal))^;

  if PPointer(ADynamic2)^ = nil then
    lLen2 := 0
  else
    lLen2 := PCardinal(PCardinal(ADynamic2)^ - SizeOf(Cardinal))^;

  Result := lLen = lLen2;

  if (not Result) or (lLen = 0) then
    Exit;

  lDyn := PDynArrayTypeInfo(Cardinal(ATypeInfo) + Byte(ATypeInfo^.Name[0]));

  if lDyn^.elType = nil then
    Result := CompareMem(PPointer(ADynamic1)^, PPointer(ADynamic2)^, lLen * lDyn^.elSize)
  else
    Result := DynamicCompare_Array(
      PPointer(ADynamic1)^,
      PPointer(ADynamic2)^,
      PTypeInfo(lDyn^.elType^),
      lLen
    );
end;

function DynamicCompare_Array(ADynamic1, ADynamic2: Pointer;
  ATypeInfo: PTypeInfo; ALength: Cardinal): Boolean;
var
  lFieldTable: PFieldTable;
begin
  Result := ALength = 0;

  if Result then
    Exit;

  case ATypeInfo^.Kind of
  tkLString:
    while ALength > 0 do
    begin
      if PAnsiString(ADynamic1)^ <> PAnsiString(ADynamic2)^ then
        Exit;

      Inc(PPointer(ADynamic1));
      Inc(PPointer(ADynamic2));
      Dec(ALength);
    end;

  tkWString:
    while ALength > 0 do
    begin
      if PWideString(ADynamic1)^ <> PWideString(ADynamic2)^ then
        Exit;

      Inc(PPointer(ADynamic1));
      Inc(PPointer(ADynamic2));
      Dec(ALength);
    end;

{$IFDEF KBDYNAMIC_UNICODE}
  tkUString:
    while ALength > 0 do
    begin
      if PUnicodeString(ADynamic1)^ <> PUnicodeString(ADynamic2)^ then
        Exit;

      Inc(PPointer(ADynamic1));
      Inc(PPointer(ADynamic2));
      Dec(ALength);
    end;
{$ENDIF}

  tkArray:
    begin
      lFieldTable := PFieldTable(Cardinal(ATypeInfo) + Byte(PTypeInfo(ATypeInfo).Name[0]));
      while ALength > 0 do
      begin
        if not DynamicCompare_Array(ADynamic1, ADynamic2, lFieldTable.Fields[0].TypeInfo^, lFieldTable.Count) then
          Exit;

        Inc(Integer(ADynamic1), lFieldTable.Size);
        Inc(Integer(ADynamic2), lFieldTable.Size);
        Dec(ALength);
      end;
    end;

  tkRecord:
    begin
      lFieldTable := PFieldTable(Integer(ATypeInfo) + Byte(PTypeInfo(ATypeInfo).Name[0]));
      while ALength > 0 do
      begin
        if not DynamicCompare_Record(ADynamic1, ADynamic2, ATypeInfo) then
          Exit;

        Inc(Integer(ADynamic1), lFieldTable.Size);
        Inc(Integer(ADynamic2), lFieldTable.Size);
        Dec(ALength);
      end;
    end;

  tkDynArray:
    while ALength > 0 do
    begin
      if not DynamicCompare_DynArray(ADynamic1, ADynamic2, ATypeInfo) then
        Exit;

      Inc(PPointer(ADynamic1));
      Inc(PPointer(ADynamic2));
      Dec(ALength);
    end;
  else
    raise EKBDynamicInvalidType.Create(ATypeInfo^.Kind);
  end;

  Result := True;
end;

// -----------------------------------------------------------------------------
// --- GetSize
// -----------------------------------------------------------------------------

function DynamicGetSize_Array(ADynamic: Pointer; ATypeInfo: PTypeInfo;
  ALength: Cardinal; const AOptions: TKBDynamicOptions): Cardinal; forward;

function DynamicGetSize_Record(ADynamic: Pointer; ATypeInfo: PTypeInfo;
  const AOptions: TKBDynamicOptions): Cardinal;
var
  lFieldTable: PFieldTable;
  lCompare: Cardinal;
  lOffset: Cardinal;
  lIdx: Cardinal;
  lTypeInfo: PTypeInfo;
begin
  lFieldTable := PFieldTable(Cardinal(ATypeInfo) + Byte(ATypeInfo^.Name[0]));

  if lFieldTable^.Count = 0 then
  begin
    Result := lFieldTable^.Size;
    Exit;
  end;

  lCompare := 0;
  lIdx := 0;
  Result := 0;

  while (lCompare < lFieldTable^.Size) and (lIdx < lFieldTable^.Count) do
  begin
    lOffset := lFieldTable^.Fields[lIdx].Offset;

    if lCompare < lOffset then
    begin
      Inc(Result, lOffset - lCompare);

      Inc(lCompare, lOffset - lCompare)
    end;

    lTypeInfo := lFieldTable^.Fields[lIdx].TypeInfo^;

    Inc(Result, DynamicGetSize_Array(
      Pointer(Cardinal(ADynamic) + lOffset),
      lTypeInfo,
      1,
      AOptions
    ));

    case lTypeInfo^.Kind of
    tkArray, tkRecord:
      Inc(lCompare, PFieldTable(Cardinal(lTypeInfo) + Byte(lTypeInfo^.Name[0]))^.Size);
    else
      Inc(lCompare, SizeOf(Pointer));
    end;

    Inc(lIdx);
  end;

  if lCompare < lFieldTable^.Size then
    Inc(Result, lFieldTable^.Size - lCompare);
end;

function DynamicGetSize_DynArray(ADynamic: Pointer; ATypeInfo: PTypeInfo;
  const AOptions: TKBDynamicOptions): Cardinal;
var
  lDyn: PDynArrayTypeInfo;
  lLen: Cardinal;
begin
  if kdoLimitToWordSize in AOptions then
    Result := SizeOf(Word)
  else
    Result := SizeOf(Cardinal); // dynamic array length

  if PPointer(ADynamic)^ = nil then
    Exit;

  lLen := PCardinal(PCardinal(ADynamic)^ - 4)^;

  if (kdoLimitToWordSize in AOptions) and (lLen > MAXWORD) then
    if kdoLimitToWordSizeForce in AOptions then
      lLen := MAXWORD
    else
      raise EKBDynamicWordLimit.Create(lLen);

  lDyn := PDynArrayTypeInfo(Cardinal(ATypeInfo) + Byte(ATypeInfo^.Name[0]));

  if lDyn^.elType = nil then
    Inc(Result, lLen * lDyn^.elSize)
  else
    Inc(Result, DynamicGetSize_Array(
      PPointer(ADynamic)^,
      PTypeInfo(lDyn^.elType^),
      lLen,
      AOptions
    ));
end;

function DynamicGetSize_Array(ADynamic: Pointer; ATypeInfo: PTypeInfo;
  ALength: Cardinal; const AOptions: TKBDynamicOptions): Cardinal;
var
  lFieldTable: PFieldTable;
  lLen: Cardinal;
begin
  Result := 0;

  if ALength = 0 then
    Exit;

  case ATypeInfo^.Kind of
  tkLString:
    while ALength > 0 do
    begin
      if kdoLimitToWordSize in AOptions then
        Inc(Result, SizeOf(Word))  // string length
      else
        Inc(Result, SizeOf(Integer)); // string length

      if PPointer(ADynamic)^ <> nil then
      begin
        lLen := Length(PAnsiString(ADynamic)^);

        if lLen > 0 then
        begin
          if (kdoLimitToWordSize in AOptions) and (lLen > MAXWORD) then
            if kdoLimitToWordSizeForce in AOptions then
              lLen := MAXWORD
            else
              raise EKBDynamicWordLimit.Create(lLen);

          Inc(Result, lLen * SizeOf(AnsiChar));
          if kdoAnsiStringCodePage in AOptions then
            Inc(Result, SizeOf(Word) {CodePage});
        end;
      end;

      Inc(PPointer(ADynamic));
      Dec(ALength);
    end;

  tkWString:
    while ALength > 0 do
    begin
      if kdoLimitToWordSize in AOptions then
        Inc(Result, SizeOf(Word))  // string length
      else
        Inc(Result, SizeOf(Integer)); // string length

      if PPointer(ADynamic)^ <> nil then
      begin
        lLen := Length(PWideString(ADynamic)^);

        if lLen > 0 then
        begin
          if kdoUTF16ToUTF8 in AOptions then
            lLen := WideCharToMultiByte(
              CP_UTF8,
              0,
              PWideChar(ADynamic^),
              lLen,
              nil,
              0,
              nil,
              nil);

          if (kdoLimitToWordSize in AOptions) and (lLen > MAXWORD) then
            if kdoLimitToWordSizeForce in AOptions then
              lLen := MAXWORD
            else
              raise EKBDynamicWordLimit.Create(lLen);

          if kdoUTF16ToUTF8 in AOptions then
            Inc(Result, lLen)
          else
            Inc(Result, lLen * SizeOf(WideChar));
        end;
      end;

      Inc(PPointer(ADynamic));
      Dec(ALength);
    end;

{$IFDEF KBDYNAMIC_UNICODE}
  tkUString:
    while ALength > 0 do
    begin
      if kdoLimitToWordSize in AOptions then
        Inc(Result, SizeOf(Word))  // string length
      else
        Inc(Result, SizeOf(Integer)); // string length

      if PPointer(ADynamic)^ <> nil then
      begin
        lLen := Length(PUnicodeString(ADynamic)^);

        if lLen > 0 then
        begin
          if kdoUTF16ToUTF8 in AOptions then
            lLen := WideCharToMultiByte(
              CP_UTF8,
              0,
              PWideChar(ADynamic^),
              lLen,
              nil,
              0,
              nil,
              nil);

          if (kdoLimitToWordSize in AOptions) and (lLen > MAXWORD) then
            if kdoLimitToWordSizeForce in AOptions then
              lLen := MAXWORD
            else
              raise EKBDynamicWordLimit.Create(lLen);

          if kdoUTF16ToUTF8 in AOptions then
            Inc(Result, lLen)
          else
            Inc(Result, lLen * SizeOf(WideChar));
        end;
      end;

      Inc(PPointer(ADynamic));
      Dec(ALength);
    end;
{$ENDIF}

  tkArray:
    begin
      lFieldTable := PFieldTable(Cardinal(ATypeInfo) + Byte(PTypeInfo(ATypeInfo).Name[0]));
      while ALength > 0 do
      begin
        Inc(Result, DynamicGetSize_Array(
          ADynamic,
          lFieldTable.Fields[0].TypeInfo^,
          lFieldTable.Count,
          AOptions
        ));

        Inc(Integer(ADynamic), lFieldTable.Size);
        Dec(ALength);
      end;
    end;

  tkRecord:
    begin
      lFieldTable := PFieldTable(Integer(ATypeInfo) + Byte(PTypeInfo(ATypeInfo).Name[0]));
      while ALength > 0 do
      begin
        Inc(Result, DynamicGetSize_Record(ADynamic, ATypeInfo, AOptions));
        Inc(Integer(ADynamic), lFieldTable.Size);
        Dec(ALength);
      end;
    end;

  tkDynArray:
    while ALength > 0 do
    begin
      Inc(Result, DynamicGetSize_DynArray(ADynamic, ATypeInfo, AOptions));
      Inc(Integer(ADynamic), SizeOf(Integer));
      Dec(ALength);
    end;
  else
    raise EKBDynamicInvalidType.Create(ATypeInfo^.Kind);
  end;
end;

// -----------------------------------------------------------------------------
// --- Write
// -----------------------------------------------------------------------------

procedure DynamicWrite_Array(AStream: TStream; ADynamic: Pointer;
  ATypeInfo: PTypeInfo; ALength: Cardinal; const AOptions: TKBDynamicOptions); forward;

procedure DynamicWrite_Record(AStream: TStream; ADynamic: Pointer;
  ATypeInfo: PTypeInfo; const AOptions: TKBDynamicOptions);
var
  lFieldTable: PFieldTable;
  lCompare: Cardinal;
  lOffset: Cardinal;
  lIdx: Cardinal;
  lTypeInfo: PTypeInfo;
begin
  lFieldTable := PFieldTable(Cardinal(ATypeInfo) + Byte(ATypeInfo^.Name[0]));

  if lFieldTable^.Count = 0 then
  begin
    AStream.WriteBuffer(PByte(ADynamic)^, lFieldTable.Size);
    Exit;
  end;

  lCompare := 0;
  lIdx := 0;

  while (lCompare < lFieldTable^.Size) and (lIdx < lFieldTable^.Count) do
  begin
    lOffset := lFieldTable^.Fields[lIdx].Offset;

    if lCompare < lOffset then
    begin
      AStream.WriteBuffer(PByte((Cardinal(ADynamic) + lCompare))^, lOffset - lCompare);

      Inc(lCompare, lOffset - lCompare);
    end;

    lTypeInfo := lFieldTable^.Fields[lIdx].TypeInfo^;

    DynamicWrite_Array(
      AStream,
      Pointer(Cardinal(ADynamic) + lOffset),
      lTypeInfo,
      1,
      AOptions
    );

    case lTypeInfo^.Kind of
    tkArray, tkRecord:
      Inc(lCompare, PFieldTable(Cardinal(lTypeInfo) + Byte(lTypeInfo^.Name[0]))^.Size);
    else
      Inc(lCompare, SizeOf(Pointer));
    end;

    Inc(lIdx);
  end;

  if lCompare < lFieldTable^.Size then
    AStream.WriteBuffer(PByte(Cardinal(ADynamic) + lCompare)^, lFieldTable^.Size - lCompare);
end;

procedure DynamicWrite_DynArray(AStream: TStream; ADynamic: Pointer;
  ATypeInfo: PTypeInfo; const AOptions: TKBDynamicOptions);
var
  lDyn: PDynArrayTypeInfo;
  lLen: Cardinal;
begin
  if PPointer(ADynamic)^ = nil then
    lLen := 0
  else
    lLen := PCardinal(PCardinal(ADynamic)^ - SizeOf(Cardinal))^;

  if kdoLimitToWordSize in AOptions then
  begin
    if lLen > MAXWORD then
      if kdoLimitToWordSizeForce in AOptions then
        lLen := MAXWORD
      else
        raise EKBDynamicWordLimit.Create(lLen);

    AStream.WriteBuffer(lLen, SizeOf(Word));
  end else
    AStream.WriteBuffer(lLen, SizeOf(Cardinal));

  if lLen = 0 then
    Exit;

  lDyn := PDynArrayTypeInfo(Cardinal(ATypeInfo) + Byte(ATypeInfo^.Name[0]));

  if lDyn^.elType = nil then
    AStream.WriteBuffer(PByte(ADynamic^)^, lLen * lDyn^.elSize)
  else
    DynamicWrite_Array(
      AStream,
      PPointer(ADynamic)^,
      PTypeInfo(lDyn^.elType^),
      lLen,
      AOptions
    );
end;

procedure DynamicWrite_WideStringAsUFT8(AStream: TStream; APWideChar: PPWideChar;
  ALen: Cardinal; const AOptions: TKBDynamicOptions);
var
  lUTF8: PAnsiChar;
  lLen: Cardinal;
begin
  if ALen = 0 then
  begin
    if kdoLimitToWordSize in AOptions then
      AStream.WriteBuffer(ALen, SizeOf(Word))
    else
      AStream.WriteBuffer(ALen, SizeOf(Cardinal));

    Exit;
  end;

  GetMem(lUTF8, ALen * 3);
  try
    lLen := WideCharToMultiByte(
      CP_UTF8,
      0,
      APWideChar^,
      ALen,
      lUTF8,
      ALen * 3,
      nil,
      nil);

    if kdoLimitToWordSize in AOptions then
    begin
      if lLen > MAXWORD then
        if kdoLimitToWordSizeForce in AOptions then
          lLen := MAXWORD // FIXME: UNSAFE - UTF8 string might be cut-off in the middle of character!
        else
          raise EKBDynamicWordLimit.Create(lLen);

      AStream.WriteBuffer(lLen, SizeOf(Word));
    end else
      AStream.WriteBuffer(lLen, SizeOf(Cardinal));

    if lLen > 0 then
      AStream.WriteBuffer(lUTF8^, lLen);
  finally
    FreeMem(lUTF8);
  end;
end;

procedure DynamicWrite_Array(AStream: TStream; ADynamic: Pointer;
  ATypeInfo: PTypeInfo; ALength: Cardinal; const AOptions: TKBDynamicOptions);
var
  lFieldTable: PFieldTable;
  lLen: Cardinal;
  lCP: Word;
begin
  if ALength = 0 then
    Exit;

  case ATypeInfo^.Kind of
  tkLString:
    while ALength > 0 do
    begin
      if PPointer(ADynamic)^ = nil then
        lLen := 0
      else
        lLen := Length(PAnsiString(ADynamic)^);

      if kdoLimitToWordSize in AOptions then
      begin
        if lLen > MAXWORD then
          if kdoLimitToWordSizeForce in AOptions then
            lLen := MAXWORD
          else
            raise EKBDynamicWordLimit.Create(lLen);

        AStream.WriteBuffer(lLen, SizeOf(Word));
      end else
        AStream.WriteBuffer(lLen, SizeOf(Cardinal));;

      if lLen > 0 then
      begin
        AStream.WriteBuffer(PByte(ADynamic^)^, lLen * SizeOf(AnsiChar));

        if kdoAnsiStringCodePage in AOptions then
        begin
{$IFDEF KBDYNAMIC_UNICODE}
          lCP := PWord(PCardinal(ADynamic)^ - 12)^; // StrRec.codePage
{$ELSE}
          lCP := GetACP; // TODO: System.DefaultSystemCodePage
{$ENDIF}
          AStream.Write(lCP, SizeOf(Word));
        end;
      end;

      Inc(PPointer(ADynamic));
      Dec(ALength);
    end;

  tkWString:
    while ALength > 0 do
    begin
      if PPointer(ADynamic)^ = nil then
        lLen := 0
      else
        lLen := Length(PWideString(ADynamic)^);

      if kdoUTF16ToUTF8 in AOptions then
        DynamicWrite_WideStringAsUFT8(AStream, ADynamic, lLen, AOptions)
      else
      begin
        if kdoLimitToWordSize in AOptions then
        begin
          if lLen > MAXWORD then
            if kdoLimitToWordSizeForce in AOptions then
              lLen := MAXWORD
            else
              raise EKBDynamicWordLimit.Create(lLen);

          AStream.WriteBuffer(lLen, SizeOf(Word));
        end else
          AStream.WriteBuffer(lLen, SizeOf(Cardinal));;

        if lLen > 0 then
          AStream.WriteBuffer(PByte(ADynamic^)^, lLen * SizeOf(WideChar));
      end;

      Inc(PPointer(ADynamic));
      Dec(ALength);
    end;

{$IFDEF KBDYNAMIC_UNICODE}
  tkUString:
    while ALength > 0 do
    begin
      if PPointer(ADynamic)^ = nil then
        lLen := 0
      else
        lLen := Length(PUnicodeString(ADynamic)^);

      if kdoUTF16ToUTF8 in AOptions then
        DynamicWrite_WideStringAsUFT8(AStream, ADynamic, lLen, AOptions)
      else
      begin
        if kdoLimitToWordSize in AOptions then
        begin
          if lLen > MAXWORD then
            if kdoLimitToWordSizeForce in AOptions then
              lLen := MAXWORD
            else
              raise EKBDynamicWordLimit.Create(lLen);

          AStream.WriteBuffer(lLen, SizeOf(Word));
        end else
          AStream.WriteBuffer(lLen, SizeOf(Cardinal));;

        if lLen > 0 then
          AStream.WriteBuffer(PByte(ADynamic^)^, lLen * SizeOf(WideChar));
      end;

      Inc(PPointer(ADynamic));
      Dec(ALength);
    end;
{$ENDIF}

  tkArray:
    begin
      lFieldTable := PFieldTable(Cardinal(ATypeInfo) + Byte(PTypeInfo(ATypeInfo).Name[0]));
      while ALength > 0 do
      begin
        DynamicWrite_Array(AStream, ADynamic, lFieldTable.Fields[0].TypeInfo^,
          lFieldTable.Count, AOptions);
        Inc(Integer(ADynamic), lFieldTable.Size);
        Dec(ALength);
      end;
    end;

  tkRecord:
    begin
      lFieldTable := PFieldTable(Integer(ATypeInfo) + Byte(PTypeInfo(ATypeInfo).Name[0]));
      while ALength > 0 do
      begin
        DynamicWrite_Record(AStream, ADynamic, ATypeInfo, AOptions);
        Inc(Integer(ADynamic), lFieldTable.Size);
        Dec(ALength);
      end;
    end;

  tkDynArray:
    while ALength > 0 do
    begin
      DynamicWrite_DynArray(AStream, ADynamic, ATypeInfo, AOptions);
      Inc(Integer(ADynamic), SizeOf(Integer));
      Dec(ALength);
    end;
  else
    raise EKBDynamicInvalidType.Create(ATypeInfo^.Kind);
  end;
end;

// -----------------------------------------------------------------------------
// --- Read
// -----------------------------------------------------------------------------

procedure DynamicRead_Array(AStream: TStream; ADynamic: Pointer;
  ATypeInfo: PTypeInfo; ALength: Cardinal; const AOptions: TKBDynamicOptions); forward;

procedure DynamicRead_Record(AStream: TStream; ADynamic: Pointer;
  ATypeInfo: PTypeInfo; const AOptions: TKBDynamicOptions);
var
  lFieldTable: PFieldTable;
  lCompare: Cardinal;
  lOffset: Cardinal;
  lIdx: Cardinal;
  lTypeInfo: PTypeInfo;
begin
  lFieldTable := PFieldTable(Cardinal(ATypeInfo) + Byte(ATypeInfo^.Name[0]));

  if lFieldTable^.Count = 0 then
  begin
    AStream.ReadBuffer(PByte(ADynamic)^, lFieldTable.Size);
    Exit;
  end;

  lCompare := 0;
  lIdx := 0;

  while (lCompare < lFieldTable^.Size) and (lIdx < lFieldTable^.Count) do
  begin
    lOffset := lFieldTable^.Fields[lIdx].Offset;

    if lCompare < lOffset then
    begin
      AStream.ReadBuffer(PByte(Cardinal(ADynamic) + lCompare)^, lOffset - lCompare);
      Inc(lCompare, lOffset - lCompare);
    end;

    lTypeInfo := lFieldTable^.Fields[lIdx].TypeInfo^;

    DynamicRead_Array(
      AStream,
      Pointer(Cardinal(ADynamic) + lOffset),
      lTypeInfo,
      1,
      AOptions
    );

    case lTypeInfo^.Kind of
    tkArray, tkRecord:
      Inc(lCompare, PFieldTable(Cardinal(lTypeInfo) + Byte(lTypeInfo^.Name[0]))^.Size);
    else
      Inc(lCompare, SizeOf(Pointer));
    end;

    Inc(lIdx);
  end;

  if lCompare < lFieldTable^.Size then
    AStream.ReadBuffer(PByte(Cardinal(ADynamic) + lCompare)^, lFieldTable^.Size - lCompare);
end;

procedure DynamicRead_DynArray(AStream: TStream; ADynamic: Pointer;
  ATypeInfo: PTypeInfo; const AOptions: TKBDynamicOptions);
var
  lDyn: PDynArrayTypeInfo;
  lLen: Cardinal;
begin
  if kdoLimitToWordSize in AOptions then
  begin
    lLen := 0;
    AStream.ReadBuffer(lLen, SizeOf(Word));
  end else
    AStream.ReadBuffer(lLen, SizeOf(Cardinal));

  DynArraySetLength(PPointer(ADynamic)^, ATypeInfo, 1, @lLen);

  if lLen = 0 then
    Exit;

  lDyn := PDynArrayTypeInfo(Cardinal(ATypeInfo) + Byte(ATypeInfo^.Name[0]));

  if lDyn^.elType = nil then
    AStream.ReadBuffer(PByte(ADynamic^)^, lLen * lDyn^.elSize)
  else
    DynamicRead_Array(
      AStream,
      PPointer(ADynamic)^,
      PTypeInfo(lDyn^.elType^),
      lLen,
      AOptions
    );
end;

procedure DynamicRead_Array(AStream: TStream; ADynamic: Pointer;
  ATypeInfo: PTypeInfo; ALength: Cardinal; const AOptions: TKBDynamicOptions);
var
  lFieldTable: PFieldTable;
  lLen: Cardinal;
  lUTF8: PAnsiChar;
begin
  if ALength = 0 then
    Exit;

  case ATypeInfo^.Kind of
  tkLString:
    while ALength > 0 do
    begin
      if kdoLimitToWordSize in AOptions then
      begin
        lLen := 0;
        AStream.ReadBuffer(lLen, SizeOf(Word));
      end else
        AStream.ReadBuffer(lLen, SizeOf(Cardinal));

      SetLength(PAnsiString(ADynamic)^, lLen);

      if lLen > 0 then
      begin
        AStream.ReadBuffer(PByte(ADynamic^)^, lLen * SizeOf(AnsiChar));
        if kdoAnsiStringCodePage in AOptions then
{$IFDEF KBDYNAMIC_UNICODE}
          AStream.ReadBuffer(PWord(PCardinal(ADynamic)^ - 12)^, SizeOf(Word));   // StrRec.codePage
{$ELSE}
          AStream.Seek(SizeOf(Word), soFromCurrent); // TODO: try to convert from one codepage to another
{$ENDIF}
      end;

      Inc(PPointer(ADynamic));
      Dec(ALength);
    end;

  tkWString:
    while ALength > 0 do
    begin
      if kdoLimitToWordSize in AOptions then
      begin
        lLen := 0;
        AStream.ReadBuffer(lLen, SizeOf(Word));
      end else
        AStream.ReadBuffer(lLen, SizeOf(Cardinal));

      if lLen = 0 then
        SetLength(PWideString(ADynamic)^, 0)
      else
        if kdoUTF16ToUTF8 in AOptions then
        begin
          GetMem(lUTF8, lLen);
          try
            SetLength(PWideString(ADynamic)^, lLen);
            AStream.Read(lUTF8^, lLen);

            lLen := MultiByteToWideChar(
              CP_UTF8,
              0,
              lUTF8,
              lLen,
              PPWideChar(ADynamic)^,
              lLen
            );

            SetLength(PWideString(ADynamic)^, lLen);
          finally
            FreeMem(lUTF8);
          end;
        end else
        begin
          SetLength(PWideString(ADynamic)^, lLen);

          AStream.ReadBuffer(PByte(ADynamic^)^, lLen * SizeOf(WideChar));
        end;

      Inc(PPointer(ADynamic));
      Dec(ALength);
    end;

{$IFDEF KBDYNAMIC_UNICODE}
  tkUString:
    while ALength > 0 do
    begin
      if kdoLimitToWordSize in AOptions then
      begin
        lLen := 0;
        AStream.ReadBuffer(lLen, SizeOf(Word));
      end else
        AStream.ReadBuffer(lLen, SizeOf(Cardinal));

      if lLen = 0 then
        SetLength(PUnicodeString(ADynamic)^, 0)
      else
        if kdoUTF16ToUTF8 in AOptions then
        begin
          GetMem(lUTF8, lLen);
          try
            SetLength(PUnicodeString(ADynamic)^, lLen);
            AStream.Read(lUTF8^, lLen);

            lLen := MultiByteToWideChar(
              CP_UTF8,
              0,
              lUTF8,
              lLen,
              PPWideChar(ADynamic)^,
              lLen
            );

            SetLength(PUnicodeString(ADynamic)^, lLen);
          finally
            FreeMem(lUTF8);
          end;
        end else
        begin
          SetLength(PUnicodeString(ADynamic)^, lLen);

          AStream.ReadBuffer(PByte(ADynamic^)^, lLen * SizeOf(WideChar));
        end;

      Inc(PPointer(ADynamic));
      Dec(ALength);
    end;
{$ENDIF}

  tkArray:
    begin
      lFieldTable := PFieldTable(Cardinal(ATypeInfo) + Byte(PTypeInfo(ATypeInfo).Name[0]));
      while ALength > 0 do
      begin
        DynamicRead_Array(
          AStream,
          ADynamic,
          lFieldTable.Fields[0].TypeInfo^,
          lFieldTable.Count,
          AOptions);

        Inc(Integer(ADynamic), lFieldTable.Size);
        Dec(ALength);
      end;
    end;

  tkRecord:
    begin
      lFieldTable := PFieldTable(Integer(ATypeInfo) + Byte(PTypeInfo(ATypeInfo).Name[0]));
      while ALength > 0 do
      begin
        DynamicRead_Record(AStream, ADynamic, ATypeInfo, AOptions);
        Inc(Integer(ADynamic), lFieldTable.Size);
        Dec(ALength);
      end;
    end;

  tkDynArray:
    while ALength > 0 do
    begin
      DynamicRead_DynArray(AStream, ADynamic, ATypeInfo, AOptions);
      Inc(Integer(ADynamic), SizeOf(Integer));
      Dec(ALength);
    end;
  else
    raise EKBDynamicInvalidType.Create(ATypeInfo^.Kind);
  end;
end;

{ TKBDynamic }

class function TKBDynamic.Compare(const ADynamicType1,
  ADynamicType2; ATypeInfo: PTypeInfo): Boolean;
begin
  Result := DynamicCompare_Array(@ADynamicType1, @ADynamicType2, ATypeInfo, 1);
end;

class function TKBDynamic.GetSize(const ADynamicType;
  ATypeInfo: PTypeInfo; const AOptions: TKBDynamicOptions): Cardinal;
begin
  Result := SizeOf(TKBDynamicHeader) + GetSizeNH(ADynamicType, ATypeInfo, AOptions);
end;

class function TKBDynamic.GetSizeNH(const ADynamicType;
  ATypeInfo: PTypeInfo; const AOptions: TKBDynamicOptions): Cardinal;
begin
  Result := DynamicGetSize_Array(@ADynamicType, ATypeInfo, 1, AOptions);
end;

class procedure TKBDynamic.WriteTo(AStream: TStream; const ADynamicType;
  ATypeInfo: PTypeInfo; AVersion: Word; const AOptions: TKBDynamicOptions; APreAllocSize: Boolean);
var
  lHeader: TKBDynamicHeader;
  lNewSize: Int64;
  lOldPos: Int64;
begin
  if APreAllocSize then
  begin
    lNewSize := AStream.Position + TKBDynamic.GetSize(ADynamicType, ATypeInfo, AOptions);
    if lNewSize > AStream.Size then
    begin
      lOldPos := AStream.Position;
      AStream.Size := lNewSize;
      AStream.Position := lOldPos;
    end;
  end;

  lHeader.Stream.Version := cKBDYNAMIC_STREAM_VERSION;
  lHeader.Stream.Options := 0;
  lHeader.TypeVersion := AVersion;

{$IFDEF KBDYNAMIC_UNICODE}
  lHeader.Stream.Options := lHeader.Stream.Options or cKBDYNAMIC_STREAM_CFG_UNICODE;
{$ENDIF}

  if kdoUTF16ToUTF8 in AOptions then
    lHeader.Stream.Options := lHeader.Stream.Options or cKBDYNAMIC_STREAM_CFG_UTF8;

  if kdoLimitToWordSize in AOptions then
    lHeader.Stream.Options := lHeader.Stream.Options or cKBDYNAMIC_STREAM_CFG_WORDSIZE;

  if kdoAnsiStringCodePage in AOptions then
    lHeader.Stream.Options := lHeader.Stream.Options or cKBDYNAMIC_STREAM_CFG_CODEPAGE;

  AStream.WriteBuffer(lHeader, SizeOf(lHeader));

  WriteToNH(AStream, ADynamicType, ATypeInfo, AOptions);
end;

class procedure TKBDynamic.WriteToNH(AStream: TStream;
  const ADynamicType; ATypeInfo: PTypeInfo; const AOptions: TKBDynamicOptions);
begin
  DynamicWrite_Array(AStream, @ADynamicType, ATypeInfo, 1, AOptions);
end;

class function TKBDynamic.ReadFrom(AStream: TStream; const ADynamicType;
  ATypeInfo: PTypeInfo; AVersion: Word): Boolean;
var
  lHeader: TKBDynamicHeader;
  lOptions: TKBDynamicOptions;
begin
  AStream.ReadBuffer(lHeader, SizeOf(lHeader));
  Result := (lHeader.TypeVersion = AVersion) and (lHeader.Stream.Version = cKBDYNAMIC_STREAM_VERSION);
  if not Result then
  begin
    AStream.Seek(-SizeOf(lHeader), soCurrent);
    Exit;
  end;

  lOptions := [];
  if cKBDYNAMIC_STREAM_CFG_UTF8 and lHeader.Stream.Options = cKBDYNAMIC_STREAM_CFG_UTF8 then
    Include(lOptions, kdoUTF16ToUTF8);

  if cKBDYNAMIC_STREAM_CFG_WORDSIZE and lHeader.Stream.Options = cKBDYNAMIC_STREAM_CFG_WORDSIZE then
    Include(lOptions, kdoLimitToWordSize);

  if cKBDYNAMIC_STREAM_CFG_CODEPAGE and lHeader.Stream.Options = cKBDYNAMIC_STREAM_CFG_CODEPAGE then
    Include(lOptions, kdoAnsiStringCodePage);

  ReadFromNH(AStream, ADynamicType, ATypeInfo, lOptions)
end;

class procedure TKBDynamic.ReadFromNH(AStream: TStream;
  const ADynamicType; ATypeInfo: PTypeInfo;
  const AOptions: TKBDynamicOptions);
begin
  DynamicRead_Array(AStream, @ADynamicType, ATypeInfo, 1, AOptions);
end;

{ EKBDynamicInvalidType }

constructor EKBDynamicInvalidType.Create(ATypeKind: TTypeKind);
begin
  FTypeKind := ATypeKind;

  inherited CreateFmt('Unsupported field type %s', [
    GetEnumName(TypeInfo(TTypeKind), Ord(ATypeKind))
  ]);
end;

{ EKBDynamicWordLimit }

constructor EKBDynamicWordLimit.Create(ALen: Cardinal);
begin
  inherited CreateFmt('Invalid dynamic array size %d (max 65535)', [ALen]);
end;

end.
