object frmStorage: TfrmStorage
  Left = 0
  Top = 0
  Caption = 'Create storage'
  ClientHeight = 153
  ClientWidth = 508
  Color = clBtnFace
  Constraints.MaxHeight = 191
  Constraints.MinHeight = 191
  Constraints.MinWidth = 320
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    508
    153)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 119
    Width = 330
    Height = 29
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'Note: If total file size will be above 100MB, then next file con' +
      'tents won'#39't be stored'
    WordWrap = True
  end
  object gbCreate: TGroupBox
    Left = 8
    Top = 8
    Width = 492
    Height = 105
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    DesignSize = (
      492
      105)
    object lblStorageName: TLabel
      Left = 16
      Top = 20
      Width = 129
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Storage display name:'
    end
    object lblDirIn: TLabel
      Left = 16
      Top = 47
      Width = 129
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Source directory:'
    end
    object lblFileOut: TLabel
      Left = 16
      Top = 74
      Width = 129
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Storage file name:'
    end
    object edtDirIn: TEdit
      Left = 151
      Top = 44
      Width = 324
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
    object edtFileOut: TEdit
      Left = 151
      Top = 71
      Width = 324
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
    end
    object edtStorageName: TEdit
      Left = 151
      Top = 17
      Width = 324
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
      Text = 'My storage name'
    end
  end
  object btnCreate: TButton
    Left = 344
    Top = 120
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Create'
    Default = True
    TabOrder = 1
    OnClick = btnCreateClick
  end
  object btnCancel: TButton
    Left = 425
    Top = 120
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
