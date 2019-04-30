unit CheckInformUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TCheckInformationForm = class(TForm)
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    ClientEdit: TEdit;
    NumDogEdit: TEdit;
    SummEdit: TEdit;
    PaymentCentrEdit: TEdit;
    Button2: TButton;
    Button6: TButton;
    Button7: TButton;
    Label1: TLabel;
    InforamtionLabel: TLabel;
    NoPrintCheckBitBtn: TBitBtn;
    PrintCheckBitBtn: TBitBtn;
    Label2: TLabel;
    DateOfChekaEdit: TEdit;
    Label3: TLabel;
    NameOfProdavcaEdit: TEdit;
    Label10: TLabel;
    Label4: TLabel;
    PhoneEdit: TEdit;
    Label5: TLabel;
    emailEdit: TEdit;
    procedure NoPrintCheckBitBtnClick(Sender: TObject);
    procedure PrintCheckBitBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CheckInformationForm: TCheckInformationForm;

implementation uses Unit1;

{$R *.dfm}

procedure TCheckInformationForm.NoPrintCheckBitBtnClick(Sender: TObject);
begin
 glcObPrCheka.ResUserDialog:=false;
 Close;
end;

procedure TCheckInformationForm.PrintCheckBitBtnClick(Sender: TObject);
begin
 glcObPrCheka.ResUserDialog:=true;
 Close;
end;

procedure TCheckInformationForm.FormShow(Sender: TObject);
begin
 InforamtionLabel.Caption:='';
 ClientEdit.Text:=glcObPrCheka.NameOfClienta;
 NumDogEdit.Text:=glcObPrCheka.NumOfDogAsString;
 SummEdit.Text:=glcObPrCheka.SummAsString;
 PaymentCentrEdit.Text:=glcObPrCheka.PaymentCenter;
 DateOfChekaEdit.Text:=DateToStr(glcObPrCheka.DateOfCheckFile);
 NameOfProdavcaEdit.Text:=glcObPrCheka.NamePrdavca;
 PhoneEdit.Text:=glcObPrCheka.CustomerPhone;
 emailEdit.Text:=glcObPrCheka.CustomerEMail;
 if (Pos(NameOfProdavcaEdit.Text, 'Еловенка') > 0) or
    (Pos(NameOfProdavcaEdit.Text, 'Талова') > 0) then
 begin
  InforamtionLabel.Caption:='Проверьте чек!!!!!';
 end;
end;

end.
