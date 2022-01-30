object hfUsrAuth: ThfUsrAuth
  Left = 428
  Top = 311
  Width = 219
  Height = 208
  Caption = 'hfUsrAuth'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ActionList1: TActionList
    Left = 24
    Top = 8
    object aBarCodeSend: TAction
      Caption = 'aBarCodeSend'
      OnExecute = aBarCodeSendExecute
    end
  end
end
