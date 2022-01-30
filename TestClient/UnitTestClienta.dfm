object TestForm: TTestForm
  Left = 186
  Top = 161
  Caption = 'TestForm'
  ClientHeight = 489
  ClientWidth = 865
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object GtinLabel: TLabel
    Left = 88
    Top = 384
    Width = 45
    Height = 13
    Caption = 'GtinLabel'
  end
  object SerialLabel: TLabel
    Left = 88
    Top = 400
    Width = 52
    Height = 13
    Caption = 'SerialLabel'
  end
  object TailLabel: TLabel
    Left = 88
    Top = 416
    Width = 43
    Height = 13
    Caption = 'TailLabel'
  end
  object CreateObjButton: TButton
    Left = 56
    Top = 112
    Width = 113
    Height = 25
    Caption = 'CreateObjButton'
    TabOrder = 0
    OnClick = CreateObjButtonClick
  end
  object ConnectButton: TButton
    Left = 176
    Top = 112
    Width = 105
    Height = 25
    Caption = 'ConnectButton'
    TabOrder = 1
    OnClick = ConnectButtonClick
  end
  object BeginDocButton: TButton
    Left = 296
    Top = 112
    Width = 137
    Height = 25
    Caption = 'BeginDocButton'
    TabOrder = 2
    OnClick = BeginDocButtonClick
  end
  object TextButton: TButton
    Left = 336
    Top = 320
    Width = 75
    Height = 25
    Caption = 'TextButton'
    TabOrder = 3
    OnClick = TextButtonClick
  end
  object EndTranzButton: TButton
    Left = 728
    Top = 112
    Width = 107
    Height = 25
    Caption = 'EndTranzButton'
    TabOrder = 4
    OnClick = EndTranzButtonClick
  end
  object SaleButton: TButton
    Left = 520
    Top = 152
    Width = 75
    Height = 25
    Caption = 'SaleButton'
    TabOrder = 5
    OnClick = SaleButtonClick
  end
  object CloseCheckButton: TButton
    Left = 608
    Top = 152
    Width = 89
    Height = 25
    Caption = 'CloseCheckButton'
    TabOrder = 6
    OnClick = CloseCheckButtonClick
  end
  object OneMethodButton: TButton
    Left = 488
    Top = 248
    Width = 105
    Height = 25
    Caption = 'OneMethodButton'
    TabOrder = 7
    OnClick = OneMethodButtonClick
  end
  object SendBufferButton: TButton
    Left = 704
    Top = 248
    Width = 75
    Height = 25
    Caption = 'SendBufferButton'
    TabOrder = 8
    OnClick = SendBufferButtonClick
  end
  object Button1: TButton
    Left = 488
    Top = 280
    Width = 105
    Height = 25
    Caption = 'Button1'
    TabOrder = 9
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 608
    Top = 248
    Width = 75
    Height = 25
    Caption = 'Button2'
    TabOrder = 10
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 608
    Top = 280
    Width = 75
    Height = 25
    Caption = 'Button2'
    TabOrder = 11
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 408
    Top = 248
    Width = 75
    Height = 25
    Caption = 'Button4'
    TabOrder = 12
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 432
    Top = 152
    Width = 75
    Height = 25
    Caption = 'Button5'
    TabOrder = 13
    OnClick = Button5Click
  end
  object CloseServerButton: TButton
    Left = 296
    Top = 80
    Width = 137
    Height = 25
    Caption = 'CloseServerButton'
    TabOrder = 14
    OnClick = CloseServerButtonClick
  end
  object ParseButton: TButton
    Left = 248
    Top = 320
    Width = 75
    Height = 25
    Caption = 'ParseButton'
    TabOrder = 15
    OnClick = ParseButtonClick
  end
  object MarkaEdit: TEdit
    Left = 88
    Top = 352
    Width = 777
    Height = 21
    TabOrder = 16
    Text = 'MarkaEdit'
  end
  object Button6: TButton
    Left = 518
    Top = 112
    Width = 75
    Height = 25
    Caption = 'SaleEidtMarkButton'
    TabOrder = 17
    OnClick = Button6Click
  end
  object MarkEdit: TEdit
    Left = 224
    Top = 24
    Width = 593
    Height = 21
    TabOrder = 18
    Text = 'MarkEdit'
  end
end
