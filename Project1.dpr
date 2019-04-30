program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {DriverSlugbaForm},
  CheckInformUnit in 'CheckInformUnit.pas' {CheckInformationForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDriverSlugbaForm, DriverSlugbaForm);
  Application.CreateForm(TCheckInformationForm, CheckInformationForm);
  Application.Run;
end.
