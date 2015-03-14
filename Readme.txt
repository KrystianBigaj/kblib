TKBDynamic allows to save/load/get(binary)size/compare any dynamic type with only one line of code. 
This can be used for example to share data by any IPC mechanism.  
Tested on Delphi 2006/2009/XE. Extended RTTI (added in D2010) is NOT used at all (no need for this case).
It should work also with Delphi 7.

Dynamic types can be for example:
- String
- array of String (or any type)
- dynamic record (must contain at least one dynamic type)

In TestCase there is used type TTestRecord defined as:
  TTestRecord = record
    I: Integer;
    D: Double;
    U: UnicodeString;
    W: WideString;
    A: AnsiString;
    Options: TKBDynamicOptions;

    IA: array[0..2] of Integer;

    AI: TIntegerDynArray;
    AD: TDoubleDynArray;
    AU: array of UnicodeString;
    AW: TWideStringDynArray;
    AA: array of AnsiString;

    R: array of TTestRecord;
  end;

To save whole TTestRecord:
  TKBDynamic.WriteTo(lStream, lTestRecord, TypeInfo(TTestRecord));

To load it back:
  TKBDynamic.ReadFrom(lStream, lTestRecord, TypeInfo(TTestRecord));

See TestuKBDynamic.pas and Demos for some examples of usage.

License:   MPL 1.1/GPL 2.0/LGPL 3.0
EMail:     krystian.bigaj@gmail.com
WWW:       http://github.com/Krystian-Bigaj/kblib/
