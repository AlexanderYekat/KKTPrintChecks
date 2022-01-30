object sfMF: TsfMF
  Left = 400
  Top = 269
  Width = 267
  Height = 255
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object neCash: TDBNumberEditEh
    Left = 8
    Top = 8
    Width = 121
    Height = 21
    DynProps = <>
    EditButtons = <>
    TabOrder = 0
    Visible = True
  end
  object neCode: TDBNumberEditEh
    Left = 8
    Top = 32
    Width = 121
    Height = 21
    DynProps = <>
    EditButtons = <>
    TabOrder = 1
    Visible = True
  end
  object eCode: TDBNumberEditEh
    Left = 8
    Top = 56
    Width = 121
    Height = 21
    DynProps = <>
    EditButtons = <>
    TabOrder = 2
    Visible = True
  end
  object ActionList1: TActionList
    Left = 168
    Top = 8
    object aSetDiscount: TAction
      Caption = 'aSetDiscount'
      OnExecute = aSetDiscountExecute
    end
  end
end
