Speed demo - shows how fast can be load/save million(s) of dynamic records

Record/db-like structure is declared at top of uMainForm.pas unit.

Disk access time is not measured, because all operations are made in memory.
When saving, whole record structure is saved to TMemoryStream with
single allocation, because TKBDynamic.WriteTo has APreAllocSize=True,
so no reallocations are made at all. After saving structure to memory,
whole content are save directly to TFileStream.
Similar with Load, first whole file is loaded to TMemoryStream, and then
loaded to dynamic record.
Of course you can save/load directly from TFileStream, but it could be
inefficient.
Best would be use for example some file memory mapping streams, then you could
probably get better performance when taking disk-io access.

Log from my laptop saving/loading 10M (by default it's 1M in spin edit) of records:

	--- Save
	Record count: 10000000
	Allocating DB took 0,0236s
	Fill DB took 2,2998s
	Saving DB to TMemoryStream took 0,8902s
	DB size 360,28MB
	--- Load
	Loading DB from TMemoryStream took 0,8107s
	Record count: 10000000

When UTF8 checkbox is checked, then log looks like this:

	--- Save
	Record count: 10000000
	Allocating DB took 0,0242s
	Fill DB took 2,3502s
	Saving DB to TMemoryStream took 2,1312s
	DB size 218,29MB
	--- Load
	Loading DB from TMemoryStream took 1,5473s
	Record count: 10000000

In UTF8 mode, saving is 2.5x longer, because of conversion UnicodeString->UTF8String,
but DB size dropped about 30%.
Keep in mind that it's only 2,5s to store 10M dynamic-records in this case!

Please also note that this demo is not to show how build/replace your DB.		
There is not indexing, searching, etc. You can only save/load any (big)
dynamic record structure, and have direct native access to it.
But it's possible to build 'real' DB-like on top of TKBDynamic.

License:   MPL 1.1/GPL 2.0/LGPL 3.0
EMail:     krystian.bigaj@gmail.com
WWW:       http://code.google.com/p/kblib/