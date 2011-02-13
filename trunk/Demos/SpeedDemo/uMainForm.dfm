object frmMain: TfrmMain
  Left = 167
  Top = 138
  Caption = 'TKBDynamic - Speed demo'
  ClientHeight = 243
  ClientWidth = 527
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  DesignSize = (
    527
    243)
  PixelsPerInch = 96
  TextHeight = 13
  object btnSave: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Save'
    TabOrder = 0
    OnClick = btnSaveClick
  end
  object btnLoad: TButton
    Left = 89
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Load'
    TabOrder = 1
    OnClick = btnLoadClick
  end
  object mLog: TMemo
    Left = 8
    Top = 39
    Width = 511
    Height = 196
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
  end
  object seRecordCount: TSpinEdit
    Left = 170
    Top = 11
    Width = 121
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 3
    Value = 1000000
  end
  object chkUTF8: TCheckBox
    Left = 297
    Top = 16
    Width = 97
    Height = 17
    Caption = 'UTF8'
    TabOrder = 4
  end
end
