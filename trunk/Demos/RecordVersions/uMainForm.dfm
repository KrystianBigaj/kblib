object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'TKBDynamic - example of record versioning'
  ClientHeight = 435
  ClientWidth = 718
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    718
    435)
  PixelsPerInch = 96
  TextHeight = 13
  object mText: TMemo
    Left = 8
    Top = 107
    Width = 702
    Height = 320
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      '(Click "Load V1" or "Load V2")')
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object edtName: TEdit
    Left = 8
    Top = 79
    Width = 341
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
  end
  object seId: TSpinEdit
    Left = 355
    Top = 79
    Width = 121
    Height = 22
    Anchors = [akTop, akRight]
    MaxValue = 0
    MinValue = 0
    TabOrder = 2
    Value = 0
  end
  object gbOld: TGroupBox
    Left = 8
    Top = 8
    Width = 185
    Height = 65
    Caption = 'First version of record'
    TabOrder = 3
    object btnLoadV1: TButton
      Left = 16
      Top = 24
      Width = 75
      Height = 25
      Caption = 'Load V1'
      TabOrder = 0
      OnClick = btnLoadV1Click
    end
    object btnSaveV1: TButton
      Left = 97
      Top = 24
      Width = 75
      Height = 25
      Caption = 'Save V1'
      TabOrder = 1
      OnClick = btnSaveV1Click
    end
  end
  object GroupBox1: TGroupBox
    Left = 199
    Top = 8
    Width = 185
    Height = 65
    Caption = 'Second version of record'
    TabOrder = 4
    object btnLoadV2: TButton
      Left = 16
      Top = 24
      Width = 75
      Height = 25
      Caption = 'Load V1/V2'
      TabOrder = 0
      OnClick = btnLoadV2Click
    end
    object btnSaveV2: TButton
      Left = 97
      Top = 24
      Width = 75
      Height = 25
      Caption = 'Save V2'
      TabOrder = 1
      OnClick = btnSaveV2Click
    end
  end
  object chkNewField: TCheckBox
    Left = 482
    Top = 81
    Width = 228
    Height = 17
    Anchors = [akTop, akRight]
    Caption = 'NewField (only in second version of record)'
    TabOrder = 5
  end
end
