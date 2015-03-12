Currently there is only one unit in lib - [uKBDynamic](http://code.google.com/p/kblib/source/browse/trunk/Sources/uKBDynamic.pas).

Tested on Delphi 2006/2009/XE/**XE4**/**XE5**/**XE6**(x86, **x64** and **ARM**). Extended RTTI (added in D2010) is **NOT** used at all (no need for this case). **OSX/iOS/Android/NextGen** compiler support in svn ([r20](https://code.google.com/p/kblib/source/detail?r=20)).

[TKBDynamic](http://code.google.com/p/kblib/source/browse/trunk/Sources/uKBDynamic.pas) allows to save/load/get(binary)size/compare any dynamic type with only one line of code. This can be used for example to share data by any IPC mechanism.

Dynamic types can be for example:
  * String
  * array of String (or any type)
  * dynamic record (must contain at least one dynamic type)

In [TestCase](http://code.google.com/p/kblib/source/browse/trunk/Tests/TestuKBDynamic.pas) there is used type [TTestRecord](http://code.google.com/p/kblib/source/browse/trunk/Tests/TestuKBDynamic.pas#36) defined as:
```
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
```
To save whole TTestRecord:
```
TKBDynamic.WriteTo(lStream, lTestRecord, TypeInfo(TTestRecord));
```

To load it back:
```
TKBDynamic.ReadFrom(lStream, lTestRecord, TypeInfo(TTestRecord));
```

See [TestuKBDynamic.pas](http://code.google.com/p/kblib/source/browse/trunk/Tests/TestuKBDynamic.pas) for more examples of usage.

---
**Note:**
You might want to have a look also at http://blog.synopse.info/post/2011/03/12/TDynArray-and-Record-compare/load/save-using-fast-RTTI