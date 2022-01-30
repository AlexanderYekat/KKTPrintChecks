library RemoteCashClient;

uses
  ComServ,
  RemoteCashClient_TLB in 'RemoteCashClient_TLB.pas',
  RemoteCashSender in 'RemoteCashSender.pas' {RemoteCashClient: CoClass},
  AlertMSG in '..\AlertMSG.pas' {fAlertMSG};

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}

{$R *.RES}

begin
end.
