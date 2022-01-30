unit AlertMSG;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TfAlertMSG = class(TForm)
    Timer1: TTimer;
    Image1: TImage;
    Text: TLabel;
    Image2: TImage;
    Shape1: TShape;
    Label2: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure Shape1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    bExit: Bool;
  end;

var
  fAlertMSG: TfAlertMSG;

implementation

{$R *.DFM}

procedure TfAlertMSG.FormActivate(Sender: TObject);
begin
  Timer1.Enabled := True;
  Timer1Timer(Sender);
end;

procedure TfAlertMSG.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
  Timer1.Enabled := False;
end;

procedure TfAlertMSG.Timer1Timer(Sender: TObject);
begin
  windows.Beep(2200, 50);
  windows.Beep(2640, 50);
  windows.Beep(2200, 50);
end;

procedure TfAlertMSG.Shape1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ModalResult := mrOk;
end;

procedure TfAlertMSG.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_Return) or (Key = VK_Space) or (Key = VK_Escape) then
     ModalResult := mrOk;
end;

end.
