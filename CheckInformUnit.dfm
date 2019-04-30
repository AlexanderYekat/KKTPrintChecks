object CheckInformationForm: TCheckInformationForm
  Left = 284
  Top = 173
  Width = 817
  Height = 488
  Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1103' '#1086' '#1095#1077#1082#1077
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label11: TLabel
    Left = 150
    Top = 123
    Width = 39
    Height = 13
    Caption = #1050#1083#1080#1077#1085#1090':'
  end
  object Label12: TLabel
    Left = 110
    Top = 155
    Width = 87
    Height = 13
    Caption = #1053#1086#1084#1077#1088' '#1076#1086#1075#1086#1074#1086#1088#1072':'
  end
  object Label13: TLabel
    Left = 158
    Top = 187
    Width = 37
    Height = 13
    Caption = #1057#1091#1084#1084#1072':'
  end
  object Label14: TLabel
    Left = 118
    Top = 219
    Width = 77
    Height = 13
    Caption = 'Payment centre:'
  end
  object Label1: TLabel
    Left = 288
    Top = 67
    Width = 174
    Height = 23
    Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1103' '#1086' '#1095#1077#1082#1077
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
  end
  object InforamtionLabel: TLabel
    Left = 128
    Top = 24
    Width = 552
    Height = 21
    Alignment = taCenter
    Caption = 
      #1044#1072#1090#1072' '#1095#1077#1082#1072' '#1086#1090#1083#1080#1095#1072#1077#1090#1089#1103' '#1086#1090' '#1089#1077#1075#1086#1076#1085#1103#1096#1085#1077#1081' '#1076#1072#1090#1099' '#1073#1086#1083#1077#1077', '#1095#1077#1084' '#1085#1072' '#1086#1076#1080#1085' '#1076#1077#1085#1100 +
      '.'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clRed
    Font.Height = -19
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    Visible = False
  end
  object Label2: TLabel
    Left = 136
    Top = 291
    Width = 55
    Height = 13
    Caption = #1044#1072#1090#1072' '#1095#1077#1082#1072':'
  end
  object Label3: TLabel
    Left = 120
    Top = 320
    Width = 76
    Height = 13
    Caption = #1048#1084#1103' '#1087#1088#1086#1076#1072#1074#1094#1072':'
  end
  object Label10: TLabel
    Left = 8
    Top = 432
    Width = 224
    Height = 13
    Caption = 'Ver.: '#1045#1082#1072#1090#1077#1088#1080#1085#1073#1091#1088#1075' '#1058#1102#1084#1077#1085#1100' '#1050'2 20170804_03'
  end
  object Label4: TLabel
    Left = 80
    Top = 248
    Width = 48
    Height = 13
    Caption = #1058#1077#1083#1077#1092#1086#1085':'
  end
  object Label5: TLabel
    Left = 288
    Top = 248
    Width = 30
    Height = 13
    Caption = 'e-mail:'
  end
  object ClientEdit: TEdit
    Left = 334
    Top = 115
    Width = 121
    Height = 21
    TabOrder = 0
    Text = 'ClientEdit'
  end
  object NumDogEdit: TEdit
    Left = 334
    Top = 147
    Width = 121
    Height = 21
    TabOrder = 1
    Text = 'NumDogEdit'
  end
  object SummEdit: TEdit
    Left = 334
    Top = 179
    Width = 121
    Height = 21
    TabOrder = 2
    Text = 'SummEdit'
  end
  object PaymentCentrEdit: TEdit
    Left = 334
    Top = 211
    Width = 121
    Height = 21
    TabOrder = 3
    Text = 'PaymentCentrEdit'
  end
  object Button2: TButton
    Left = 478
    Top = 211
    Width = 25
    Height = 25
    Caption = 'Button2'
    TabOrder = 4
  end
  object Button6: TButton
    Left = 518
    Top = 211
    Width = 25
    Height = 25
    Caption = 'Button6'
    TabOrder = 5
  end
  object Button7: TButton
    Left = 550
    Top = 211
    Width = 25
    Height = 25
    Caption = 'Button7'
    TabOrder = 6
  end
  object NoPrintCheckBitBtn: TBitBtn
    Left = 176
    Top = 360
    Width = 121
    Height = 25
    Caption = #1053#1077' '#1087#1077#1095#1072#1090#1072#1090#1100' '#1095#1077#1082
    TabOrder = 7
    OnClick = NoPrintCheckBitBtnClick
    Kind = bkCancel
  end
  object PrintCheckBitBtn: TBitBtn
    Left = 488
    Top = 360
    Width = 121
    Height = 25
    Caption = #1055#1077#1095#1072#1090#1072#1090#1100' '#1095#1077#1082
    TabOrder = 8
    OnClick = PrintCheckBitBtnClick
    Kind = bkOK
  end
  object DateOfChekaEdit: TEdit
    Left = 336
    Top = 291
    Width = 119
    Height = 21
    TabOrder = 9
    Text = 'DateOfChekaEdit'
  end
  object NameOfProdavcaEdit: TEdit
    Left = 336
    Top = 320
    Width = 121
    Height = 21
    TabOrder = 10
    Text = 'NameOfProdavcaEdit'
  end
  object PhoneEdit: TEdit
    Left = 136
    Top = 248
    Width = 121
    Height = 21
    TabOrder = 11
    Text = 'PhoneEdit'
  end
  object emailEdit: TEdit
    Left = 336
    Top = 248
    Width = 121
    Height = 21
    TabOrder = 12
    Text = 'emailEdit'
  end
end
