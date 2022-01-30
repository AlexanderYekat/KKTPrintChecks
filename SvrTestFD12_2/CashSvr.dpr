program CashSvr;

uses
  Forms,
  Properties in 'Properties.pas' {fProps},
  AlertMSG in '..\AlertMSG.pas' {fAlertMSG},
  QuestMSG in '..\QuestMSG.pas' {fQuestMSG},
  sEquipment in 'sEquipment.pas',
  sDM in 'sDM.pas',
  sSF in 'sSF.pas',
  sMF in 'sMF.pas' {sfMF},
  hUsrAuth in 'hUsrAuth.pas' {hfUsrAuth};

{$R *.RES}
//версия 2020 года июль изменённая под Маркировку программистом Чемерисом А.В. cto-ksm@mail.ru
begin
  Application.Initialize;
  sfMF := TsfMF.Create(Application);
  Application.CreateForm(TfProps, fProps);
  Application.CreateForm(TfAlertMSG, fAlertMSG);
  Application.CreateForm(TfQuestMSG, fQuestMSG);
  Application.Run;
end.
