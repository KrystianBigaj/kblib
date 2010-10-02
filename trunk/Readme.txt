
TKBDynamic allows to save/load/get(binary)size/compare any dynamic type with only one line of code. 
This can be used for example to share data by any IPC mechanism.  
Tested on Delphi 2006/2009/XE.

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
    TODO: make example of handling version compatibility.
  - Don't store interfaces in types, because you will get exception.
    In future there is a plan to add (or use generic one) interface type
    with Load/Save methods. So any interface that implements that one
    could be added to for example to record with store/restore functionality.

  * DU - Delphi Unicode (Delphi D2009+)
  * DNU - Delphi non-Unicode (older than D2009)

See TestuKBDynamic.pas for more examples of usage.


License:   MPL 1.1/GPL 2.0/LGPL 3.0
EMail:     krystian.bigaj@gmail.com
WWW:       http://code.google.com/p/kblib/
