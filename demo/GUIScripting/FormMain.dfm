object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'GUI Script Demo'
  ClientHeight = 574
  ClientWidth = 602
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    602
    574)
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 8
    Top = 377
    Width = 225
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Mock UI to test recording and playback:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    ExplicitTop = 507
  end
  object Label3: TLabel
    Left = 8
    Top = 39
    Width = 36
    Height = 13
    Caption = 'Script:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label4: TLabel
    Left = 8
    Top = 195
    Width = 70
    Height = 13
    Caption = 'Test Output:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object btnRecord: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Record'
    TabOrder = 0
    OnClick = btnRecordClick
  end
  object btnRun: TButton
    Left = 92
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Run'
    TabOrder = 1
    OnClick = btnRunClick
  end
  object mmoScript: TMemo
    Left = 8
    Top = 58
    Width = 586
    Height = 131
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 5
  end
  object mmoOutput: TMemo
    Left = 8
    Top = 214
    Width = 586
    Height = 157
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 6
  end
  object pnlTestUI: TPanel
    Left = 8
    Top = 396
    Width = 586
    Height = 170
    Anchors = [akLeft, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 7
    object Label1: TLabel
      Left = 315
      Top = 36
      Width = 31
      Height = 13
      Caption = 'TLabel'
    end
    object SpeedButton1: TSpeedButton
      Left = 204
      Top = 93
      Width = 85
      Height = 25
      Caption = 'TSpeedButton'
    end
    object Label5: TLabel
      Left = 454
      Top = 12
      Width = 44
      Height = 13
      Caption = 'TListBox:'
    end
    object edtSource: TEdit
      Left = 44
      Top = 4
      Width = 121
      Height = 21
      TabOrder = 0
    end
    object btnAdd: TButton
      Left = 44
      Top = 31
      Width = 75
      Height = 25
      Caption = 'Add'
      TabOrder = 1
      OnClick = btnAddClick
    end
    object lbDest: TListBox
      Left = 44
      Top = 62
      Width = 121
      Height = 104
      ItemHeight = 13
      TabOrder = 2
    end
    object btnDisable: TButton
      Left = 204
      Top = 31
      Width = 85
      Height = 25
      Caption = 'TButton'
      TabOrder = 3
      OnClick = btnDisableClick
    end
    object btnModal: TButton
      Left = 315
      Top = 62
      Width = 75
      Height = 25
      Caption = 'Modal Test'
      TabOrder = 5
      OnClick = btnModalClick
    end
    object CheckBox1: TCheckBox
      Left = 315
      Top = 99
      Width = 113
      Height = 17
      Caption = 'TCheckBox'
      TabOrder = 6
    end
    object RadioButton1: TRadioButton
      Left = 315
      Top = 122
      Width = 113
      Height = 17
      Caption = 'TRadioButton'
      TabOrder = 7
    end
    object ComboBox1: TComboBox
      Left = 315
      Top = 145
      Width = 113
      Height = 21
      TabOrder = 8
      Items.Strings = (
        'one'
        'two'
        'three')
    end
    object ListBox1: TListBox
      Left = 454
      Top = 31
      Width = 121
      Height = 53
      ItemHeight = 13
      TabOrder = 9
    end
    object BitBtn1: TBitBtn
      Left = 204
      Top = 62
      Width = 85
      Height = 25
      Caption = 'TBitBtn'
      TabOrder = 4
    end
    object Memo1: TMemo
      Left = 454
      Top = 90
      Width = 121
      Height = 76
      TabOrder = 10
    end
  end
  object btnLoad: TButton
    Left = 438
    Top = 8
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Load...'
    TabOrder = 3
    OnClick = btnLoadClick
  end
  object btnSave: TButton
    Left = 519
    Top = 8
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Save...'
    TabOrder = 4
    OnClick = btnSaveClick
  end
  object btnHelp: TButton
    Left = 201
    Top = 8
    Width = 96
    Height = 25
    Caption = 'Script Help...'
    TabOrder = 2
    OnClick = btnHelpClick
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'pas'
    Filter = 'Delphi Script Files (*.pas)|*.pas|All Files (*.*)|*.*'
    Left = 316
    Top = 272
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'pas'
    Filter = 'Delphi Script Files (*.pas)|*.pas|All Files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 412
    Top = 272
  end
end
