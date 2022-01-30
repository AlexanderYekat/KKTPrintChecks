unit QuestMSG;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TfQuestMSG = class(TForm)
    Timer1: TTimer;
    Image1: TImage;
    Text: TLabel;
    Image2: TImage;
    Shape1: TShape;
    Label2: TLabel;
    Shape2: TShape;
    Label1: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure Shape1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Shape2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    bExit: Bool;
  end;

var
  fQuestMSG: TfQuestMSG;

implementation

{$R *.DFM}

procedure TfQuestMSG.FormActivate(Sender: TObject);
begin
  Self.
  Timer1.Enabled := True;
  Timer1Timer(Sender);
end;

procedure TfQuestMSG.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
  Timer1.Enabled := False;
end;

procedure TfQuestMSG.Timer1Timer(Sender: TObject);
begin
  windows.Beep(2200, 50);
  windows.Beep(2640, 50);
  windows.Beep(2200, 50);
end;

procedure TfQuestMSG.Shape1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ModalResult := mrOk;
end;

procedure TfQuestMSG.Shape2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ModalResult := mrCancel;
end;

procedure TfQuestMSG.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_Return) or (Key = VK_Space) then
     ModalResult := mrOk;
  if (Key = VK_Escape) then
     ModalResult := mrCancel;
end;

end.
