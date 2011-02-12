object frmMain: TfrmMain
  Left = 117
  Top = 87
  ActiveControl = btnCreate
  Caption = 'TKBDynamic - Simple tree storage'
  ClientHeight = 502
  ClientWidth = 382
  Color = clBtnFace
  Constraints.MinHeight = 183
  Constraints.MinWidth = 320
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  DesignSize = (
    382
    502)
  PixelsPerInch = 96
  TextHeight = 13
  object gbStorage: TGroupBox
    Left = 8
    Top = 8
    Width = 366
    Height = 455
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'FileSystem storage'
    TabOrder = 0
    DesignSize = (
      366
      455)
    object Label1: TLabel
      Left = 16
      Top = 20
      Width = 129
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Storage display name:'
    end
    object edtStorageName: TEdit
      Left = 151
      Top = 17
      Width = 198
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ReadOnly = True
      TabOrder = 0
    end
    object tvStorage: TTreeView
      Left = 16
      Top = 44
      Width = 333
      Height = 365
      Anchors = [akLeft, akTop, akRight, akBottom]
      Indent = 19
      TabOrder = 1
    end
    object btnCreate: TButton
      Left = 193
      Top = 415
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Create...'
      TabOrder = 2
      OnClick = btnCreateClick
    end
    object btnLoad: TButton
      Left = 274
      Top = 415
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Load'
      TabOrder = 3
      OnClick = btnLoadClick
    end
  end
  object btnClose: TButton
    Left = 299
    Top = 469
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Close'
    TabOrder = 1
    OnClick = btnCloseClick
  end
  object dlgOpen: TOpenDialog
    Left = 128
    Top = 368
  end
end
