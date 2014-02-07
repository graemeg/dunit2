object frmHelp: TfrmHelp
  Left = 0
  Top = 0
  Caption = 'GUI Scripting Help'
  ClientHeight = 383
  ClientWidth = 715
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnCreate = FormCreate
  DesignSize = (
    715
    383)
  PixelsPerInch = 96
  TextHeight = 13
  object mmoHelp: TMemo
    Left = 8
    Top = 8
    Width = 699
    Height = 336
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object btnOK: TButton
    Left = 632
    Top = 350
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
end
