program TestClieantaProject;

uses
  Forms,
  UnitTestClienta in 'UnitTestClienta.pas' {TestForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TTestForm, TestForm);
  Application.Run;
end.
