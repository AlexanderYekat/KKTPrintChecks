unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComObj, ExtCtrls, ComCtrls, Mask, DateUtils;

type   
  TDriverSlugbaForm = class(TForm)
    Button1: TButton;
    ConnectButton: TButton;
    Button3: TButton;
    Button4: TButton;
    Label1: TLabel;
    PrintAllChecks: TButton;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    TimerpPintChecks: TTimer;
    ButtonStart: TButton;
    StopButton: TButton;
    NextButtonCheck: TButton;
    Label7: TLabel;
    PathToFilesEdit: TEdit;
    CheckBoxTest: TCheckBox;
    PrintXButton: TButton;
    ZButton: TButton;
    CattionLabel: TLabel;
    Label8: TLabel;
    MinimizeFormTimer: TTimer;
    ProdavecCassirEdit: TEdit;
    Label9: TLabel;
    Button5: TButton;
    ReturnCheckBox: TCheckBox;
    Label10: TLabel;
    Line1CheckBox: TCheckBox;
    ClientEdit: TEdit;
    NumDogEdit: TEdit;
    SummEdit: TEdit;
    PaymentCentrEdit: TEdit;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    PrintCheckManualButton: TButton;
    Label15: TLabel;
    PochtaProdavcaEdit: TEdit;
    EkaterinburgCheckBox: TCheckBox;
    Button2: TButton;
    Button6: TButton;
    Button7: TButton;
    VerifyDateOfCheksCheckBox: TCheckBox;
    AsusCheckBox: TCheckBox;
    NameCheckFileLabel: TLabel;
    DialogBoxShowCheckBox: TCheckBox;
    Edit1: TEdit;
    Panel1: TPanel;
    Label16: TLabel;
    NumCheckOsnLabel: TLabel;
    NumOfChekaEdit: TEdit;
    CheckCorrectionButton: TButton;
    CaptionOfOsnovanEdit: TEdit;
    Label17: TLabel;
    Label18: TLabel;
    DateFileCheckLabel: TLabel;
    SimulationCheckBox: TCheckBox;
    LabelComPort: TLabel;
    CorrectionTypeComboBox: TComboBox;
    DateOfCheckOsnovMaskEdit: TMaskEdit;
    Label19: TLabel;
    LabelInfConnect: TLabel;
    ParamMemo: TMemo;
    ButtonCheckPrint: TButton;
    ShablonPoiskaLabel: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ConnectButtonClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure PrintAllChecksClick(Sender: TObject);
    procedure NextButtonCheckClick(Sender: TObject);
    procedure TimerpPintChecksTimer(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure PrintXButtonClick(Sender: TObject);
    procedure ZButtonClick(Sender: TObject);
    procedure MinimizeFormTimerTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PrintCheckManualButtonClick(Sender: TObject);
    procedure CheckCorrectionButtonClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure ButtonCheckPrintClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TPrintCheck = class
   private
    FDirOfCheck, FNameFileOfCheck:string;
    FSummaString, FSummBaznal:string;
    FDateOfCheckFile:TDateTime;
    FNumberCekVozvrata:Integer;
    FDifferentDayFromToday:integer;
    FShablonPoiska:string;
    FNameOfClienta:WideString;
    FBeznal:boolean; FNumOfDogAsString:string;
    FNamePrdavca:string;
    FIdPole:string; //какое-то id
    FCode:string; //какой-то код
    FPaymentCenter:string; //если равен 'Касса ЦОК Радищева (автомат)', то нал, если равен 'POS terminal', то безнал в других случаях не печатать чек
    FCheckCorrection:boolean;
    FResUserDialog:boolean;
    FCancelPrintCheck:boolean;
    FVerifyDateOfChecks:boolean;
    FShowDialogCheckPrint:boolean;
    FCheckReturn:boolean;
    FcustEMail, FcustPhone:string;
   protected
    function GetSumByString:string;
    function GetNumOfDogByString:string;
    procedure SetSummaBeznala(val:string);
    function ReadCheckFromFile():boolean;
    function DeleteLastFileOfCheka:boolean; //удаляем файл чека из папки
    function GetNameOfClienta:string;
    function GetNameOfKassira:string;
    function GetPaymentCenter():string;
    function getDateOfCheckFile:TDateTime;
    procedure SetCustPhone(val:string);
    property custPhone:string read FcustPhone write SetCustPhone;
   public
    constructor Create();
    destructor Destroy(); override;
    function printCheck:boolean;
    function printCheckCorrection:boolean;
    function printCheckNoFiskal:boolean;
    property SummAsString:String read GetSumByString;
    property NumOfDogAsString:string read GetNumOfDogByString;
    property SummBaznal:string read FSummBaznal write SetSummaBeznala;
    property ResUserDialog:boolean read FResUserDialog write FResUserDialog;
    property NameOfClienta:string read GetNameOfClienta;
    property NamePrdavca:string read GetNameOfKassira;
    property PaymentCenter:string read GetPaymentCenter;
    property DateOfCheckFile:TDateTime read getDateOfCheckFile;
    property CustomerPhone:string read FcustPhone;
    property CustomerEMail:string read FcustEMail;
    function GetNextCheck:boolean;
  end;

var
  DriverSlugbaForm: TDriverSlugbaForm;
  ECR, AdoDBStream: OleVariant;
  gDeviceID:WideString;
  opis, demoreg:WideString;
  NameOfKassira:WideString;
  glcObPrCheka:TPrintCheck;

implementation uses CheckInformUnit;

{$R *.dfm}

constructor TPrintCheck.Create;
begin
 inherited Create();
 FCheckCorrection:=false;
 FDifferentDayFromToday:=0;
 FVerifyDateOfChecks:=true;
 FShowDialogCheckPrint:=false;
 FCheckReturn:=false;
 //
end; //TPrintCheck.Create;

function TPrintCheck.GetNameOfClienta():string;
begin
 result:=Trim(UTF8ToAnsi(Trim(FNameOfClienta)));
end; //GetNameOfClienta

function TPrintCheck.GetNameOfKassira():string;
begin
 result:=Trim(UTF8ToAnsi(Trim(FNamePrdavca)));
end; //GetNameOfClienta

function TPrintCheck.GetPaymentCenter():string;
begin
 result:=Trim(UTF8ToAnsi(FPaymentCenter));
end;

function TPrintCheck.getDateOfCheckFile:TDateTime;
begin
 result:=FDateOfCheckFile;
end; //

function ReplaceSub(str, sub1, sub2: WideString): WideString;
var
  aPos: Integer;
  rslt: string;
begin
  aPos := Pos(sub1, str);
  rslt := '';
  while (aPos <> 0) do
  begin
    rslt := rslt + Copy(str, 1, aPos - 1) + sub2;
    Delete(str, 1, aPos + Length(sub1) - 1);
    aPos := Pos(sub1, str);
  end;
  Result := rslt + str;
end;

function TPrintCheck.ReadCheckFromFile():boolean;
var
 f:Textfile;
 sn, command:string;
 strClienAnsi:WideString;
 //sStr, sCapt:PAnsiChar;
begin
 result:=false;
 AssignFile(f, FDirOfCheck + FNameFileOfCheck);
 try
  reset(f);
 except
  //sStr:='Ошибка'; sCapt:='Ошибка';
  //MessageBox(DriverSlugbaForm.Handle, sStr, sCapt, 0);
  exit;
 end;
 FcustEMail:=''; FcustPhone:='';
 command:=''; FCheckReturn:=false;
 FNamePrdavca:=AnsiToUTF8(Trim(DriverSlugbaForm.ProdavecCassirEdit.Text));
 while not(EOF(f)) do begin
  readln(f, sn);
  if Trim(sn) = '' then continue;
  if Pos('##', sn) > 0 then begin
   command:=sn;
   //readln(f, sn);
   continue;
  end;
  if command='##name' then
   FNameOfClienta:=Trim(sn)
  else if command='##number' then
   FNumOfDogAsString:=sn
  else if command='##summnal' then
   FSummaString:=sn
  else if command='##sumbeznal' then
   SummBaznal:=sn
  else if command='##id' then
   FIdPole:=sn
  else if command='##code' then
   FCode:=sn
  else if command='##payment_center' then begin
   result:=true;
   FPaymentCenter:=sn;
  end
  else if command='##user' then
   FNamePrdavca:=sn
  else if command='##email' then
   FcustEMail:=sn
  else if command='##phone' then
   custPhone:=sn
  else if command='##type' then begin
   FCheckReturn:=false;
   if sn = '1' then
    FCheckReturn:=true;
  end;
  //readln(f, sn);
 end; //
 closefile(f);
 strClienAnsi:=UTF8ToAnsi(FNameOfClienta);
 FNameOfClienta:=AnsiToUTF8(ReplaceSub(strClienAnsi, '"', ''));
 //DriverSlugbaForm.PaymentCentrEdit.Text:=UTF8ToAnsi(FPaymentCenter);
 //DriverSlugbaForm.LogMemo.Lines.Add('file readed');
 //DriverSlugbaForm.LogMemo.Lines.Add(FDirOfCheck + FNameFileOfCheck);
 //DriverSlugbaForm.LogMemo.Lines.Add(UTF8ToAnsi(FPaymentCenter));
 if (UTF8ToAnsi(FPaymentCenter)='POS terminal Сбербанк') or
    (UTF8ToAnsi(FPaymentCenter)='POS terminal') or
    (UTF8ToAnsi(FPaymentCenter)='POS terminal Сбербанк Линия 2')
 then begin
  if FSummBaznal='0' then begin
   SummBaznal:=FSummaString;
   FSummaString:='0';
  end;
 end;
end; //ReadCheckFromFile

function CreationTime ( f: TSearchRec ): TDateTime;
var
  LTime: TFileTime;
  Systemtime: TSystemtime;
begin
  //FileTimeToLocalFileTime( f.FindData.ftCreationTime, LTime);
  FileTimeToLocalFileTime( f.FindData.ftLastWriteTime, LTime);
  FileTimeToSystemTime( LTime, SystemTime );
  result := SystemTimeToDateTime( SystemTime);
end;

//
//
function TPrintCheck.GetNextCheck():boolean;
var
 serchRec:TSearchRec;
 dirOfSearch:string;
 checkNalBezNalFinded:boolean;
 NneUdalytFile:boolean;
 dateOfCreateFile:TDateTime;
 differDay:Double;
 RaznDney:integer;
 sh_files, yearstr, monthstr, daystr, str_date_poisk:string;
begin
 result:=false;
 dirOfSearch:='c:\share\';
 dirOfSearch:=Trim(DriverSlugbaForm.PathToFilesEdit.Text);
 //dirOfSearch:='y:\';
 //ChDir(dirOfSearch);
 checkNalBezNalFinded:=false;
 sh_files:='paymentCash_'; //paymentCash_2017_04_27_17_01_17.txt
 yearstr:=IntToStr(CurrentYear);
 monthstr:=IntToStr(MonthOf(Date));
 daystr:=IntToStr(DayOf(Date));
 if Length(daystr) = 1 then daystr:='0' + daystr;
 if Length(monthstr) = 1 then monthstr:='0' + monthstr;
 str_date_poisk:='';
 str_date_poisk:=yearstr+'_'+monthstr+'_'+daystr;
 sh_files:=sh_files+str_date_poisk  +'*.txt';
 FShablonPoiska:=sh_files;
 if FindFirst(dirOfSearch + sh_files, faAnyFile, serchRec) = 0 then
 //if FindFirst(dirOfSearch + '*.*', faAnyFile, serchRec) = 0 then
 begin
  try
   repeat
    FDirOfCheck:=dirOfSearch;
    FNameFileOfCheck:=serchRec.Name;
    dateOfCreateFile:=CreationTime(serchRec);
    FDateOfCheckFile:=dateOfCreateFile;
    differDay:=Date-dateOfCreateFile;
    RaznDney:=Trunc(differDay);
    FDifferentDayFromToday:=RaznDney;
    if FDifferentDayFromToday<1 then
    if ReadCheckFromFile() then begin
     //if (FPaymentCenter=AnsiToUTF8('Касса ЦОК Радищева (автомат)')) or (FPaymentCenter=AnsiToUTF8('POS terminal')) then
     //if (FPaymentCenter=AnsiToUTF8('Касса линия 2')) or (FPaymentCenter=AnsiToUTF8('POS terminal')) then
     NneUdalytFile:=false;
     {if (FPaymentCenter=AnsiToUTF8('Касса линия 1')) or
         (FPaymentCenter=AnsiToUTF8('Касса линия 2')) or
          (FPaymentCenter=AnsiToUTF8('POS terminal Сбербанк')) or
           (FPaymentCenter=AnsiToUTF8('Касса ЦОК Радищева (автомат)')) or
            (FPaymentCenter=AnsiToUTF8('POS terminal')) or
             (FPaymentCenter=AnsiToUTF8('POS terminal Сбербанк Линия 2'))
     then}
       NneUdalytFile:=true; //не удаляем чеки для других касс
     if not(DriverSlugbaForm.EkaterinburgCheckBox.Checked) then begin
      if DriverSlugbaForm.Line1CheckBox.Checked then begin //печатаем чеки для первой кассы
       if FPaymentCenter=AnsiToUTF8('Касса линия 1') then
        checkNalBezNalFinded:=true;
       if FPaymentCenter=AnsiToUTF8('POS terminal Сбербанк') then
        checkNalBezNalFinded:=true;
      end else begin //печатаем чеки для второй кассы
       if FPaymentCenter=AnsiToUTF8('Касса линия 2') then
        checkNalBezNalFinded:=true;
       if FPaymentCenter=AnsiToUTF8('POS terminal Сбербанк Линия 2') then
        checkNalBezNalFinded:=true;
      end;
     end
     else begin
      if (FPaymentCenter=AnsiToUTF8('Касса ЦОК Радищева (автомат)')) or (FPaymentCenter=AnsiToUTF8('POS terminal')) then
       checkNalBezNalFinded:=true;
     end;
     if not(NneUdalytFile) then //не удаляем чеки для других и этой кассы
      DeleteLastFileOfCheka;
    end; //смогли прочитать информацию о чеке из файла
   until (FindNext(serchRec) <> 0) or (checkNalBezNalFinded=true);
  finally
   FindClose(serchRec);
  end;
 end;
 result:=checkNalBezNalFinded;
end; //GetNextCheck

function TPrintCheck.printCheckNoFiskal:boolean;
var XMLDateOfCheka:WideString;
    Doc:TextFile; //
    NumbOfCheka, NumbOfSmena:integer;
    FiskalniyPriznak, AddressSiteInspections:WideString;
    OpisaniyOshibki:WideString; KodOshibki:integer;
    custEMail:string;
    //sss:UTF8String; st:Ansistring;
begin //
//sss:='п»їРЈСЃР»СѓРіРё СЃРІСЏР·Рё';
//0 - Общая
//1 - Упрощенная Доход
//2 - Упрощенная Доход минус Расход
//3 - Единый налог на вмененный доход
//4 - Единый сельскохозяйственный налог
//5 - Патентная система налогообложения
 result:=false;
 AssignFile(Doc, 'c:\share\checkXMLNoFiskal.xml');
 Rewrite(Doc);
 WriteLn(Doc, '<?xml version="1.0" encoding="UTF-8"?>');
 WriteLn(Doc, '<Document>');
 WriteLn(Doc, '<Positions>');
 WriteLn(Doc, '<TextString Text="' + AnsiToUTF8('Услуги связи') + ' 1 * ' + SummAsString + ' == ' + SummAsString + '"/>');
 //WriteLn(Doc, '<TextString Text="' + AnsiToUTF8('Договор №:') + NumOfDogAsString + '; ' + AnsiToUTF8(FNameOfClienta) + '"/>');
 WriteLn(Doc, '<TextString Text="' + AnsiToUTF8('Договор №:') + NumOfDogAsString + '; ' + FNameOfClienta + '"/>');
 if FBeznal then
  WriteLn(Doc, '<TextString Text="' + AnsiToUTF8('ИТОГО БЕЗНАЛОМ:') + ' ' + SummAsString + '"/>')
 else
  WriteLn(Doc, '<TextString Text="' + AnsiToUTF8('ИТОГО НАЛИЧНЫМИ:') + ' ' + SummAsString + '"/>');
 WriteLn(Doc, '</Positions>');
 WriteLn(Doc, '</Document>');
 CloseFile(Doc);
 AdoDBStream.Open();
 AdoDBStream.LoadFromFile('c:\share\checkXMLNoFiskal.xml');
 XMLDateOfCheka:=AdoDBStream.ReadText();
 AdoDBStream.Close;
 NameOfKassira:=UTF8ToAnsi(FNamePrdavca);
 ECR.PrintTextDocument(gDeviceID, XMLDateOfCheka);
 OpisaniyOshibki:='';
 KodOshibki:=ECR.GetLastError(OpisaniyOshibki);
 if KodOshibki = 0 then
  result:=true;
 //Label2.Caption:=OpisaniyOshibki;
 //AdoDBStream.Close();
end; //TPrintCheck.printCheckNoFiskal;

function TPrintCheck.printCheck:boolean;
var XMLDateOfCheka:WideString;
    Doc:TextFile; //
    NumbOfCheka, NumbOfSmena:integer;
    FiskalniyPriznak, AddressSiteInspections:WideString;
    OpisaniyOshibki:WideString; KodOshibki:integer;
    custEMail, custPhone:string;
    //sss:UTF8String; st:Ansistring;
    currNemeFileOfCheck:string;
    oshikaOtrkst:boolean;
    countCicl:integer;
    TimerVkluchit:boolean;
    SystNalog:integer;
    code:integer;
begin //
//sss:='п»їРЈСЃР»СѓРіРё СЃРІСЏР·Рё';
//0 - Общая
//1 - Упрощенная Доход
//2 - Упрощенная Доход минус Расход
//3 - Единый налог на вмененный доход
//4 - Единый сельскохозяйственный налог
//5 - Патентная система налогообложения
 result:=false;
 CheckInformationForm.FormStyle:=fsStayOnTop;
 glcObPrCheka.FCancelPrintCheck:=false;
 if (glcObPrCheka.FVerifyDateOfChecks) or (glcObPrCheka.FShowDialogCheckPrint) then
  if (FDifferentDayFromToday > 1) or (glcObPrCheka.FShowDialogCheckPrint) then begin
   glcObPrCheka.ResUserDialog:=true;
   if not(CheckInformationForm.Showing) then begin
    TimerVkluchit:=DriverSlugbaForm.TimerpPintChecks.Enabled;
    DriverSlugbaForm.TimerpPintChecks.Enabled:=false;
    CheckInformationForm.ShowModal();
    FcustPhone:=Trim(CheckInformationForm.PhoneEdit.Text);
    FcustEMail:=Trim(CheckInformationForm.emailEdit.Text);
    if TimerVkluchit then
     DriverSlugbaForm.TimerpPintChecks.Enabled:=true;
   end;
   if not (glcObPrCheka.ResUserDialog) then
    //печать чека отменена пользователем
    glcObPrCheka.FCancelPrintCheck:=true;
  end; //если дата файла чека очень старая
 //end; //првекра даты чека
 currNemeFileOfCheck:='c:\share\checkXML.xml';
 AssignFile(Doc, currNemeFileOfCheck);
 oshikaOtrkst:=false; countCicl:=0;
 repeat
  Inc(countCicl);
  if oshikaOtrkst then begin
   oshikaOtrkst:=false;
  end;
  try
   Rewrite(Doc);
  except
   oshikaOtrkst:=true;
  end;
  if oshikaOtrkst then begin
   currNemeFileOfCheck:='c:\share\checkXML' + IntToStr(countCicl) + '.xml';
   AssignFile(Doc, currNemeFileOfCheck);
  end;
 until not(oshikaOtrkst) or (countCicl > 20);
 //while (oshikaOtrkst) and (countCicl < 20);
 WriteLn(Doc, '<?xml version="1.0" encoding="UTF-8"?>');
 WriteLn(Doc, '<CheckPackage>');
 //WriteLn(Doc, '<Parameters PaymentType="1" TaxVariant="2" SenderEmail="info@1c.ru" CustomerEmail="alex2000@mail.ru" CustomerPhone="" AgentCompensation="" AgentPhone=""/>');
 //custEMail:='lap-lena@yandex.ru';
 custEMail:=''; custPhone:='';
 //NameOfKassira:=UTF8ToAnsi(FNamePrdavca);
 //NameOfKassira:=AnsiToUTF8(Trim(FNamePrdavca));
 NameOfKassira:=FNamePrdavca;
 //NameOfKassira:=AnsiToUTF8(Trim(DriverSlugbaForm.ProdavecCassirEdit.Text));
 //if NameOfKassira='' then begin
 // NameOfKassira:=AnsiToUTF8(Trim(DriverSlugbaForm.ProdavecCassirEdit.Text))
 //end;
 custEMail:=FcustEMail; custPhone:=FcustPhone;
 if custPhone <> '' then custEMail:='';
 SystNalog:=0;
 //Val(Val(DriverSlugbaForm.Edit1.Text, SystNalog, Code);
 //WriteLn(Doc, '<Parameters PaymentType="1" TaxVariant="2" SenderEmail="lap-lena@yandex.ru" CustomerEmail="' + Trim(custEMail) + '" CustomerPhone="" AgentCompensation="" AgentPhone=""/>');
 if (DriverSlugbaForm.ReturnCheckBox.Checked) or (FCheckReturn) then //чек вовзарат
  //WriteLn(Doc, '<Parameters PaymentType="2" TaxVariant="' + Trim(DriverSlugbaForm.Edit1.Text) + '" SenderEmail="' + Trim(DriverSlugbaForm.PochtaProdavcaEdit.Text) + '" CustomerEmail="' + Trim(custEMail) + '" CustomerPhone="' + Trim(custPhone) + '" AgentCompensation="" AgentPhone=""/>')
  WriteLn(Doc, '<Parameters PaymentType="2" TaxVariant="' + Trim(DriverSlugbaForm.Edit1.Text) + '" ' +
                            'SenderEmail="' + Trim(DriverSlugbaForm.PochtaProdavcaEdit.Text) + '" ' +
                            'CustomerEmail="' + Trim(custEMail) + '" CustomerPhone="' + Trim(custPhone) + '" ' +
                            'CashierName="'+ NameOfKassira +'" AgentCompensation="" AgentPhone="" AddressSettle="" PlaceSettle="">')
 else
  WriteLn(Doc, '<Parameters PaymentType="1" TaxVariant="' + Trim(DriverSlugbaForm.Edit1.Text) + '" ' +
                            'SenderEmail="' + Trim(DriverSlugbaForm.PochtaProdavcaEdit.Text) + '" ' +
                            'CustomerEmail="' + Trim(custEMail) + '" CustomerPhone="' + Trim(custPhone) + '" ' +
                            'CashierName="'+ NameOfKassira +'" CashierVATIN="" AgentCompensation="" AgentPhone="" AddressSettle="" PlaceSettle="">');
 WriteLn(Doc, '<AgentData/>');
 WriteLn(Doc, '<PurveyorData/>');
 WriteLn(Doc, '</Parameters>');
 WriteLn(Doc, '<Positions>');
 //WriteLn(Doc, '<FiscalString Name="Услуги связи" Quantity="1" Price="' + SummAsString + '" Amount="' + SummAsString + '" Tax="none"/>');
 //ОФД 1.0
 //WriteLn(Doc, '<FiscalString Name="' + AnsiToUTF8('Услуги связи') + '" Quantity="1" Price="' + SummAsString + '" Amount="' + SummAsString + '" Tax="none"/>');
 //ОФД 1.05
 WriteLn(Doc, '<FiscalString Name="' + AnsiToUTF8('Услуги связи') + '" Quantity="1" PriceWithDiscount="' + SummAsString + '" ' +
              'SumWithDiscount="' + SummAsString + '" DiscountSum="0" Department="0" Tax="none" TaxSum="0" ' +
              'SignMethodCalculation="' + '4' + '"' + ' SignCalculationObject="' + '4' + '"' + '>');
 WriteLn(Doc, '<AgentData/>');
 WriteLn(Doc, '<PurveyorData/>');
 WriteLn(Doc, '</FiscalString>');
 //WriteLn(Doc, '<TextString Text="' + AnsiToUTF8('Договор №:') + NumOfDogAsString + '; ' + AnsiToUTF8(FNameOfClienta) + '"/>');
 WriteLn(Doc, '<TextString Text="' + AnsiToUTF8('Договор №:') + NumOfDogAsString + '; ' + FNameOfClienta + '"/>');
 //WriteLn(Doc, '<FiscalString Name="Услуги связи" Quantity="1" Price="16.75" Amount="16.75" Tax="10"/>');
 //WriteLn(Doc, '<FiscalString Name="Томатный сок" Quantity="1" Price="200" Amount="200" Tax="18"/>');
 //WriteLn(Doc, '<FiscalString Name="Алкоголь Шампрео 0.7" Quantity="1" Price="455" Amount="455" Tax="18"/>');
 //WriteLn(Doc, '<TextString Text="Дисконтная карта: 00002345"/>');
 //WriteLn(Doc, '<Barcode BarcodeType="EAN13" Barcode="2000021262157"/>');
 WriteLn(Doc, '</Positions>');
 if FBeznal then
  //WriteLn(Doc, '<Payments Cash="0" CashLessType1="0" CashLessType2="0" CashLessType3="' + SummAsString + '"/>')
  //WriteLn(Doc, '<Payments Cash="0" CashLessType1="0" CashLessType2="' + SummAsString + '" CashLessType3="0"/>')
  //ОФД 1.0
  //WriteLn(Doc, '<Payments Cash="0" CashLessType1="' + SummAsString + '" CashLessType2="0" CashLessType3="0"/>')
  //ОФД 1.05
  WriteLn(Doc, '<Payments Cash="0" ElectronicPayment="' + SummAsString + '" AdvancePayment="0" Credit="0" CashProvision="0"/>')
 else
  //ОФД 1.0
  //WriteLn(Doc, '<Payments Cash="' + SummAsString + '" CashLessType1="0" CashLessType2="0" CashLessType3="0"/>');
  //ОФД 1.05
  WriteLn(Doc, '<Payments Cash="' + SummAsString + '" ElectronicPayment="0" AdvancePayment="0" Credit="0" CashProvision="0"/>');
 WriteLn(Doc, '</CheckPackage>');
 CloseFile(Doc);
 AdoDBStream.Open();
 AdoDBStream.LoadFromFile(currNemeFileOfCheck);
 XMLDateOfCheka:=AdoDBStream.ReadText();
 AdoDBStream.Close;
 //NameOfKassira:=UTF8ToAnsi(FNamePrdavca);
 KodOshibki:=0; OpisaniyOshibki:='';
 if not(glcObPrCheka.FCancelPrintCheck) then begin
  //ECR.ProcessCheck(gDeviceID, NameOfKassira, 0, XMLDateOfCheka, NumbOfCheka, NumbOfSmena, FiskalniyPriznak, AddressSiteInspections);
  ECR.ProcessCheck(gDeviceID, 0, XMLDateOfCheka, NumbOfCheka, NumbOfSmena, FiskalniyPriznak, AddressSiteInspections);
  //ECR.ProcessCheck(gDeviceID, NameOfKassira, XMLDateOfCheka, NumbOfCheka, NumbOfSmena, FiskalniyPriznak, AddressSiteInspections);
  OpisaniyOshibki:='';
  KodOshibki:=ECR.GetLastError(OpisaniyOshibki);
  DriverSlugbaForm.Label4.Caption:=OpisaniyOshibki;
 end else begin
  KodOshibki:=6;
  DriverSlugbaForm.Label4.Caption:='Печать чека отменена пользователем';
 end;
 if KodOshibki = 0 then
  result:=true;
 //AdoDBStream.Close();
end; //TPrintCheck.printCheck;

function TPrintCheck.printCheckCorrection:boolean;
var XMLDateOfCheka:WideString;
    Doc:TextFile; //
    NumbOfCheka, NumbOfSmena:integer;
    FiskalniyPriznak, AddressSiteInspections:WideString;
    OpisaniyOshibki:WideString; KodOshibki:integer;
    custEMail:string;
    //sss:UTF8String; st:Ansistring;
    currNemeFileOfCheck:string;
    oshikaOtrkst:boolean;
    countCicl:integer;
begin //
//sss:='п»їРЈСЃР»СѓРіРё СЃРІСЏР·Рё';
//0 - Общая
//1 - Упрощенная Доход
//2 - Упрощенная Доход минус Расход
//3 - Единый налог на вмененный доход
//4 - Единый сельскохозяйственный налог
//5 - Патентная система налогообложения
 result:=false;
 currNemeFileOfCheck:='c:\share\checkXML.xml';
 AssignFile(Doc, currNemeFileOfCheck);
 oshikaOtrkst:=false; countCicl:=0;
 repeat
  Inc(countCicl);
  if oshikaOtrkst then begin
   oshikaOtrkst:=false;
  end;
  try
   Rewrite(Doc);
  except
   oshikaOtrkst:=true;
  end;
  if oshikaOtrkst then begin
   currNemeFileOfCheck:='c:\share\checkXML' + IntToStr(countCicl) + '.xml';
   AssignFile(Doc, currNemeFileOfCheck);
  end;
 until not(oshikaOtrkst) or (countCicl > 20);
 //while (oshikaOtrkst) and (countCicl < 20);
 WriteLn(Doc, '<?xml version="1.0" encoding="UTF-8"?>');
 WriteLn(Doc, '<CheckCorrectionPackage>');
 custEMail:='';
 if DriverSlugbaForm.ReturnCheckBox.Checked then //чек вовзарат
  WriteLn(Doc, '<Parameters PaymentType="2" TaxVariant="2" CorrectionType="0" CorrectionBaseName="" CorrectionBaseDate="" CorrectionBaseNumber=""/>')
 else
  WriteLn(Doc, '<Parameters PaymentType="1" TaxVariant="2" CorrectionType="0" CorrectionBaseName="" CorrectionBaseDate="" CorrectionBaseNumber=""/>');
 if FBeznal then
  //WriteLn(Doc, '<Payments Cash="0" CashLessType1="' + SummAsString + '" CashLessType2="0" CashLessType3="0"/>')
  WriteLn(Doc, '<Payments Cash="0" ElectronicPayment="' + SummAsString + '" AdvancePayment="0" Credit="0" CashProvision="0"/>')
 else
  //WriteLn(Doc, '<Payments Cash="' + SummAsString + '" CashLessType1="0" CashLessType2="0" CashLessType3="0"/>');
  WriteLn(Doc, '<Payments Cash="' + SummAsString + '" ElectronicPayment="0" AdvancePayment="0" Credit="0" CashProvision="0"/>');
 WriteLn(Doc, '</CheckCorrectionPackage>');
 CloseFile(Doc);
 AdoDBStream.Open();
 AdoDBStream.LoadFromFile(currNemeFileOfCheck);
 XMLDateOfCheka:=AdoDBStream.ReadText();
 AdoDBStream.Close;
 NameOfKassira:=UTF8ToAnsi(FNamePrdavca);
 NumbOfCheka:=FNumberCekVozvrata;
 ECR.ProcessCorrectionCheck(gDeviceID, NameOfKassira, XMLDateOfCheka, NumbOfCheka, NumbOfSmena, FiskalniyPriznak, AddressSiteInspections);
 OpisaniyOshibki:='';
 KodOshibki:=ECR.GetLastError(OpisaniyOshibki);
 if KodOshibki = 0 then
  result:=true;
 //Label2.Caption:=OpisaniyOshibki;
 //AdoDBStream.Close();
end; //TPrintCheck.printCheckCorrection;

function TPrintCheck.DeleteLastFileOfCheka:boolean;
begin
 result:=false;
 try
  CopyFile(PAnsiChar(FDirOfCheck + FNameFileOfCheck), PAnsiChar(FDirOfCheck + 'imported\' + FNameFileOfCheck), true);
  DeleteFile(FDirOfCheck + FNameFileOfCheck);
  result:=true;
 except
 end;
end; //DeleteLastFileOfCheka

function TPrintCheck.GetSumByString:string;
begin
 if not(FBeznal) then
  result:=FSummaString
 else
  result:=FSummBaznal;
end;

procedure TPrintCheck.SetSummaBeznala(val:string);
begin
 FSummBaznal:=val;
 FBeznal:=false;
 if val<>'0' then
  FBeznal:=true;
end;

procedure TPrintCheck.SetCustPhone(val:string);
var
 s:string; l:integer;
begin
 //89504910279
 s:=Trim(val);
 l:=Length(s);
 if l=11 then begin
  s:='+7' + copy(s, 2, l-1);
 end;
 FcustPhone:=s;
end;

function TPrintCheck.GetNumOfDogByString:string;
begin
 result:=FNumOfDogAsString;
end;

destructor TPrintCheck.Destroy;
begin
 //
 inherited Destroy;
end; //TPrintCheck.Destroy

procedure TDriverSlugbaForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 if not(SimulationCheckBox.Checked) then begin
  ECR.Close(gDeviceID);
 end;
 glcObPrCheka.Destroy;
 ECR:=0;
 AdoDBStream:=0;
end;

procedure TDriverSlugbaForm.ConnectButtonClick(Sender: TObject);
var OpisaniyOshibki:WideString; KodOshibki:integer;
begin
  gDeviceID:='';
  //TCP
  if not(AsusCheckBox.Checked) then begin
   if EkaterinburgCheckBox.Checked then begin
    ECR.SetParameter('ConnectionType', 6); //TCP протокол
    ECR.SetParameter('IPAddress', '192.168.137.111');
    ECR.SetParameter('TCPPort', '7778');
   end;
   //COM
   if not(EkaterinburgCheckBox.Checked) then begin
    ECR.SetParameter('Port', '1');
    ECR.SetParameter('ConnectionType', 0);
   end;
  end else begin
   ECR.SetParameter('ConnectionType', 6); //TCP протокол
   ECR.SetParameter('IPAddress', '192.168.137.111');
   ECR.SetParameter('TCPPort', '7778');
  end;
  ECR.SetParameter('Baudrate', 115200);
  //ECR.SetParameter('Baudrate', 2400);
  ECR.SetParameter('Timeout', '1000');
  {ECR.SetParameter('ComputerName', FConnectionParams.ComputerName);
  ECR.SetParameter('IPAddress', FConnectionParams.IPAddress);
  ECR.SetParameter('TCPPort', FConnectionParams.TCPPort);}
  ECR.SetParameter('UserPassword', '1');
  ECR.SetParameter('AdminPassword', '30');
  {FDriver.SetParameter('EnableLog', FConnectionParams.EnableLog);
  FDriver.SetParameter('CloseSession', FConnectionParams.CloseSession);
  FDriver.SetParameter('Tax1', FConnectionParams.Tax1);
  FDriver.SetParameter('Tax2', FConnectionParams.Tax2);
  FDriver.SetParameter('Tax3', FConnectionParams.Tax3);
  FDriver.SetParameter('Tax4', FConnectionParams.Tax4);
  FDriver.SetParameter('PayName1', FConnectionParams.PayName1);
  FDriver.SetParameter('PayName2', FConnectionParams.PayName2);
  FDriver.SetParameter('PayName3', FConnectionParams.PayName3);}

  ECR.Open(gDeviceID);
  OpisaniyOshibki:='';
  KodOshibki:=ECR.GetLastError(OpisaniyOshibki);
  Label3.Caption:=IntToStr(KodOshibki);
  Label4.Caption:=Trim(OpisaniyOshibki);
end;

procedure TDriverSlugbaForm.Button3Click(Sender: TObject);
begin
 ECR.Close(gDeviceID);
end;

procedure TDriverSlugbaForm.Button4Click(Sender: TObject);
begin
 opis:=''; demoreg:='';
 ECR.DeviceTest(opis, demoreg);
 Label1.Caption:=opis;
end;

procedure TDriverSlugbaForm.PrintAllChecksClick(Sender: TObject);
var cObPrCheka:TPrintCheck;
    breakeFromCycle:boolean;
    countOfCkekov:integer;
begin
 cObPrCheka:=TPrintCheck.Create;
 breakeFromCycle:=false; countOfCkekov:=1;
 glcObPrCheka.FVerifyDateOfChecks:=VerifyDateOfCheksCheckBox.Checked;
 glcObPrCheka.FShowDialogCheckPrint:=DialogBoxShowCheckBox.Checked;
 while (cObPrCheka.GetNextCheck) and not(breakeFromCycle) do
 begin
  //cObPrCheka.printCheck;
  NameCheckFileLabel.Caption:=glcObPrCheka.FNameFileOfCheck;
  DateFileCheckLabel.Caption:=DateTimeToStr(glcObPrCheka.FDateOfCheckFile);
  if CheckBoxTest.Checked then
   if cObPrCheka.printCheckNoFiskal then
    cObPrCheka.DeleteLastFileOfCheka();
  if not(CheckBoxTest.Checked) then
   if cObPrCheka.printCheck then
    cObPrCheka.DeleteLastFileOfCheka();
  Inc(countOfCkekov);
  if countOfCkekov > 30 then begin
   breakeFromCycle:=true;
  end;
 end;  //перебор чеков
 cObPrCheka.Destroy;
 //ECR.ProcessCheck(gDeviceID, );
end; //print cheka

procedure TDriverSlugbaForm.NextButtonCheckClick(Sender: TObject);
var breakeFromCycle:boolean;
    countOfCkekov:integer;
begin
 breakeFromCycle:=false; countOfCkekov:=1;
 glcObPrCheka.FVerifyDateOfChecks:=VerifyDateOfCheksCheckBox.Checked;
 glcObPrCheka.FShowDialogCheckPrint:=DialogBoxShowCheckBox.Checked;
 while (glcObPrCheka.GetNextCheck) and not(breakeFromCycle) do
 begin
  //cObPrCheka.printCheck;
  NameCheckFileLabel.Caption:=glcObPrCheka.FNameFileOfCheck;
  DateFileCheckLabel.Caption:=DateTimeToStr(glcObPrCheka.FDateOfCheckFile);
  if CheckBoxTest.Checked then
   if glcObPrCheka.printCheckNoFiskal then
    glcObPrCheka.DeleteLastFileOfCheka();
  if not(CheckBoxTest.Checked) then
   if glcObPrCheka.printCheck then begin
    glcObPrCheka.DeleteLastFileOfCheka();
    ClientEdit.Text:=UTF8ToAnsi(glcObPrCheka.FNameOfClienta);
    NumDogEdit.Text:=glcObPrCheka.NumOfDogAsString;
    SummEdit.Text:=glcObPrCheka.SummAsString;
    PaymentCentrEdit.Text:=glcObPrCheka.FPaymentCenter;
   end;
  Inc(countOfCkekov);
  if countOfCkekov > 1 then begin
   breakeFromCycle:=true;
  end;
 end;  //перебор чеков
 //ECR.ProcessCheck(gDeviceID, );
end; //NextButtonCheckClick

procedure TDriverSlugbaForm.TimerpPintChecksTimer(Sender: TObject);
var breakeFromCycle:boolean;
    countOfCkekov:integer;
begin
 breakeFromCycle:=false; countOfCkekov:=1;
 glcObPrCheka.FVerifyDateOfChecks:=VerifyDateOfCheksCheckBox.Checked;
 glcObPrCheka.FShowDialogCheckPrint:=DialogBoxShowCheckBox.Checked;
 ShablonPoiskaLabel.Caption:=glcObPrCheka.FShablonPoiska;
 while (glcObPrCheka.GetNextCheck) and not(breakeFromCycle) do
 begin
  //cObPrCheka.printCheck;
  NameCheckFileLabel.Caption:=glcObPrCheka.FNameFileOfCheck;
  DateFileCheckLabel.Caption:=DateTimeToStr(glcObPrCheka.FDateOfCheckFile);
  if CheckBoxTest.Checked then
   if glcObPrCheka.printCheckNoFiskal then
    glcObPrCheka.DeleteLastFileOfCheka();
  if not(CheckBoxTest.Checked) then
   if glcObPrCheka.printCheck then begin
    ClientEdit.Text:=UTF8ToAnsi(glcObPrCheka.FNameOfClienta);
    NumDogEdit.Text:=glcObPrCheka.NumOfDogAsString;
    SummEdit.Text:=glcObPrCheka.SummAsString;
    PaymentCentrEdit.Text:=UTF8ToAnsi(glcObPrCheka.FPaymentCenter);
    glcObPrCheka.DeleteLastFileOfCheka();
   end;
  Inc(countOfCkekov);
  if countOfCkekov > 1 then begin
   breakeFromCycle:=true;
  end;
 end;  //перебор чеков
 //CheckInformationForm.FormStyle:=fsStayOnTop;
 //if not(CheckInformationForm.Showing) then
 // CheckInformationForm.ShowModal();
end; //TimerpPintChecksTimer

procedure TDriverSlugbaForm.ButtonStartClick(Sender: TObject);
begin
 TimerpPintChecks.Enabled:=true;
end;

procedure TDriverSlugbaForm.StopButtonClick(Sender: TObject);
begin
 TimerpPintChecks.Enabled:=false;
end;

procedure TDriverSlugbaForm.FormCreate(Sender: TObject);
var OpisaniyOshibki:WideString; KodOshibki:integer;
    f:Textfile;
    sn, command, oshstr:string;
    existFileIni:boolean;
    countCom, comPortInt, codeVal:integer;
    XMLDateOfParametrs:WideString;
begin
 PathToFilesEdit.Text:='z:\';
 if EkaterinburgCheckBox.Checked then
  PathToFilesEdit.Text:='y:\';
  //PathToFilesEdit.Text:='w:\';
 if AsusCheckBox.Checked then begin
  PathToFilesEdit.Text:='d:\share\test\';
  TimerpPintChecks.Enabled:=false;
 end;

 //читаем натройки по умолчанию
 LabelComPort.Caption:='';
 Line1CheckBox.Checked:=false;
 existFileIni:=true;
 AssignFile(f, 'c:\share\' + 'default.ini');
 try
  reset(f);
 except
  existFileIni:=false;
 end;
 if existFileIni then begin
  countCom:=1;
  while not(EOF(f)) do begin
   readln(f, sn);
   if countCom=1 then
    if sn='Kassa 1' then Line1CheckBox.Checked:=true;
   if countCom=2 then
    ProdavecCassirEdit.Text:=sn;
   if countCom=3 then
    PochtaProdavcaEdit.Text:=sn;
   if countCom=4 then //COM PORT
    LabelComPort.Caption:=sn;
   Inc(countCom);
  end;
 end;

 if not(SimulationCheckBox.Checked) then begin
  //ECR := CreateOleObject('AddIn.SMDrvFR1C20');
  //ECR := CreateOleObject('AddIn.SMDrvFR1C22');
  ECR := CreateOleObject('AddIn.SMDrvFR1C22');
 end;
 ParamMemo.Lines.Add(ECR.GetVersion);
 oshstr:=''; ECR.GetLastError(oshstr);
 ParamMemo.Lines.Add(oshstr);
 //ECR.GetParameters(XMLDateOfParametrs);
 AdoDBStream:=CreateOleObject('Adodb.Stream');
 AdoDBStream.Charset:='utf-8';
 AdoDBStream.Type:=2;
 AdoDBStream.Mode:=3;

 AdoDBStream.Open();
 //AdoDBStream.WriteText(XMLDateOfParametrs);
 //AdoDBStream.SaveToFile('c:\share\par.txt', 1);
 AdoDBStream.Close;

 //ECR := CreateOleObject('AddIn.ATOL_KKM_1C82_54FZ');
 //ECR := CreateOleObject('AddIn.ATOL_KKM_1C82_54FZ');
 glcObPrCheka:=TPrintCheck.Create;
 glcObPrCheka.FVerifyDateOfChecks:=VerifyDateOfCheksCheckBox.Checked;
 glcObPrCheka.FShowDialogCheckPrint:=DialogBoxShowCheckBox.Checked;

 gDeviceID:='';
 if not(SimulationCheckBox.Checked) then begin
  //TCP
  if not(AsusCheckBox.Checked) then begin
   if EkaterinburgCheckBox.Checked then begin
    ECR.SetParameter('ConnectionType', 6); //TCP протокол
    ECR.SetParameter('IPAddress', '192.168.137.111');
    ECR.SetParameter('TCPPort', '7778');
   end;
   if not(EkaterinburgCheckBox.Checked) then begin
    //COM - порт
    if LabelComPort.Caption<>'' then begin
     //ECR.SetParameter('ConnectionType', 0); //Local
     ECR.SetParameter('ProtocolType', 0); //
     ECR.SetParameter('Port', Trim(LabelComPort.Caption));
     {Val(LabelComPort.Caption, comPortInt, codeVal);
     comPortInt:=comPortInt-1;
     IntToStr(comPortInt);
     ECR.SetParameter('ComNumber', IntToStr(comPortInt));
     LabelInfConnect.Caption:='IntToStr(comPortInt)='+IntToStr(comPortInt);}
    end else begin
     LabelComPort.Caption:='4';
     ECR.SetParameter('Port', '4');
    end;
    //ECR.SetParameter('Port', '4');
    ECR.SetParameter('ConnectionType', 0);
   end
  end else begin
   //ECR.SetParameter('ConnectionType', 6); //TCP протокол
   //ECR.SetParameter('IPAddress', '192.168.137.111');
   //ECR.SetParameter('TCPPort', '7778');
   ECR.SetParameter('Port', '3');
   ECR.SetParameter('ConnectionType', 0);
  end;
   //ECR.SetParameter('Baudrate', 2400);
  ECR.SetParameter('Baudrate', 115200);
  //ECR.SetParameter('Speed', 6);
  LabelInfConnect.Caption:='Speed_N8='+'115200';
  //ECR.SetParameter('Baudrate', 4800);
  ECR.SetParameter('Timeout', '1000');
  //ECR.SetParameter('Timeout', '100');
  ECR.SetParameter('ComputerName', '');
  //ECR.SetParameter('IPAddress', FConnectionParams.IPAddress);
  ECR.SetParameter('TCPPort', 211);
  ECR.SetParameter('UserPassword', '1');
  ECR.SetParameter('AdminPassword', '30');

  ECR.SetParameter('CheckFontNumber', 1);

  ECR.SetParameter('Tax1', 20);
  ECR.SetParameter('Tax2', 10);
  ECR.SetParameter('Tax3', 0);
  ECR.SetParameter('Tax4', 0); 

  {ECR.SetParameter('Tax1', 12.3199996948242);
  ECR.SetParameter('Tax2', 15.3999996185303);
  ECR.SetParameter('Tax3', 0.449999988079071);
  ECR.SetParameter('Tax4', 1.3400000333786);

  ECR.SetParameter('PayName1', 'ПЛАТ.КАРТОЙ');
  ECR.SetParameter('PayName2', 'КРЕДИТОМ');
  ECR.SetParameter('PayName3', 'СЕРТИФИКАТ');}

  //FDriver.SetParameter('EnableLog', FConnectionParams.EnableLog);
  //FDriver.SetParameter('CloseSession', FConnectionParams.CloseSession);
  //FDriver.SetParameter('Tax1', FConnectionParams.Tax1);
  //FDriver.SetParameter('Tax2', FConnectionParams.Tax2);
  //FDriver.SetParameter('Tax3', FConnectionParams.Tax3);
  //FDriver.SetParameter('Tax4', FConnectionParams.Tax4);
  //FDriver.SetParameter('PayName1', FConnectionParams.PayName1);
  //FDriver.SetParameter('PayName2', FConnectionParams.PayName2);
  //FDriver.SetParameter('PayName3', FConnectionParams.PayName3);
  ECR.Open(gDeviceID);
  //ECR.Open(gDeviceID);
  //ECR.GetDataKKT(gDeviceID, XMLDateOfParametrs);
  //AdoDBStream.Open();
  //AdoDBStream.WriteText(XMLDateOfParametrs);
  //AdoDBStream.SaveToFile('c:\share\regpar.txt', 1);
  //AdoDBStream.Close;

  OpisaniyOshibki:='';
  KodOshibki:=ECR.GetLastError(OpisaniyOshibki);
  Label3.Caption:=IntToStr(KodOshibki);
  Label4.Caption:=Trim(OpisaniyOshibki)
 end else begin
  Label3.Caption:='Режим эмуляции';
  Label4.Caption:='Режим эмуляции'
 end;

  try
  except
   CloseFile(f);
  end;
end; //FormCreate

procedure TDriverSlugbaForm.Button1Click(Sender: TObject);
begin
 ECR := CreateOleObject('AddIn.SMDrvFR1C20');
 //ECR := CreateOleObject('AddIn.ATOL_KKM_1C82_54FZ');
 //ECR := CreateOleObject('AddIn.ATOL_KKM_1C82_54FZ');
 AdoDBStream:=CreateOleObject('Adodb.Stream');
 AdoDBStream.Charset:='utf-8';
 AdoDBStream.Type:=2;
 AdoDBStream.Mode:=3;
 glcObPrCheka:=TPrintCheck.Create;
end;

procedure TDriverSlugbaForm.PrintXButtonClick(Sender: TObject);
var
 OpisaniyOshibki:WideString; KodOshibki:integer;

 kassirName:WideString;
 ParametryStatus:WideString;
 currNemeFileOfCloseShift:string;
 DocX:TextFile;
 ParametrOperetions:WideString;
begin
 kassirName:=AnsiToUTF8(Trim(ProdavecCassirEdit.Text));

 currNemeFileOfCloseShift:='c:\share\XOtchetXML.xml';
 AssignFile(DocX, currNemeFileOfCloseShift);
 rewrite(DocX);
 WriteLn(DocX, '<?xml version="1.0" encoding="UTF-8"?>');
 WriteLn(DocX, '<InputParameters>');
 WriteLn(DocX, '<Parameters CashierName="' + kassirName + '" CashierVATIN=""/>');
 //WriteLn(DocX, '</Parameters>');
 WriteLn(DocX, '</InputParameters>');
 CloseFile(DocX);
 AdoDBStream.Open();
 AdoDBStream.LoadFromFile(currNemeFileOfCloseShift);
 ParametrOperetions:=AdoDBStream.ReadText();
 AdoDBStream.Close;

 //try
  ECR.PrintXReport(gDeviceID, ParametrOperetions);
 //except
 //end;
 KodOshibki:=ECR.GetLastError(OpisaniyOshibki);
 Label3.Caption:=IntToStr(KodOshibki);
 Label4.Caption:=Trim(OpisaniyOshibki);
end;

procedure TDriverSlugbaForm.ZButtonClick(Sender: TObject);
var
 kassirName:WideString;
 NumbOfCheka, NumbOfSmena:integer;
 OpisaniyOshibki:WideString; KodOshibki:integer;

 //ParametryStatus:variant;
 ParametryStatus:WideString;
 currNemeFileOfCloseShift:string;
 DocZ:TextFile;
 ParametrOperetions:WideString;
begin
 //ECR.PrintZReport(gDeviceID);
 kassirName:=AnsiToUTF8(Trim(ProdavecCassirEdit.Text));
 //ECR.CloseShift(gDeviceID, kassirName, NumbOfSmena, NumbOfCheka);
 //ECR.CloseShift(gDeviceID, ParametryStatus, , NumbOfSmena, NumbOfCheka);

 currNemeFileOfCloseShift:='c:\share\ZOtchetXML.xml';
 AssignFile(DocZ, currNemeFileOfCloseShift);
 rewrite(DocZ);
 WriteLn(DocZ, '<?xml version="1.0" encoding="UTF-8"?>');
 WriteLn(DocZ, '<InputParameters>');
 WriteLn(DocZ, '<Parameters CashierName="' + kassirName + '" CashierVATIN=""/>');
 //WriteLn(DocZ, '</Parameters>');
 WriteLn(DocZ, '</InputParameters>');
 CloseFile(DocZ);
 AdoDBStream.Open();
 AdoDBStream.LoadFromFile(currNemeFileOfCloseShift);
 ParametrOperetions:=AdoDBStream.ReadText();
 AdoDBStream.Close;

 ECR.CloseShift(gDeviceID, ParametrOperetions, ParametryStatus, NumbOfSmena, NumbOfCheka);
 KodOshibki:=ECR.GetLastError(OpisaniyOshibki);
 Label3.Caption:=IntToStr(KodOshibki);
 Label4.Caption:=Trim(OpisaniyOshibki);

end;

procedure TDriverSlugbaForm.MinimizeFormTimerTimer(Sender: TObject);
begin
 //DriverSlugbaForm.Hide;
 DriverSlugbaForm.WindowState:=wsMinimized;
 //DriverSlugbaForm.WindowState:=wsMaximized;
 MinimizeFormTimer.Enabled:=false;
end;

procedure TDriverSlugbaForm.FormShow(Sender: TObject);
begin
  //MinimizeFormTimer.Enabled:=true;
end;

//ручная печать чека
//
procedure TDriverSlugbaForm.PrintCheckManualButtonClick(Sender: TObject);
begin
 glcObPrCheka.FNameOfClienta:=AnsiToUTF8(ClientEdit.Text);
 glcObPrCheka.FNumOfDogAsString:=NumDogEdit.Text;
 glcObPrCheka.FSummaString:=SummEdit.Text;
 glcObPrCheka.FPaymentCenter:=AnsiToUTF8(PaymentCentrEdit.Text);
 glcObPrCheka.SummBaznal:='0';
 glcObPrCheka.FDifferentDayFromToday:=0;
 if (glcObPrCheka.FPaymentCenter=AnsiToUTF8('POS terminal Сбербанк')) or
     (glcObPrCheka.FPaymentCenter=AnsiToUTF8('POS terminal')) or
      (glcObPrCheka.FPaymentCenter=AnsiToUTF8('POS terminal Сбербанк Линия 2'))
 then
 begin
  glcObPrCheka.SummBaznal:=glcObPrCheka.FSummaString;
  glcObPrCheka.FSummaString:='0';
 end;
 glcObPrCheka.printCheck();
end; //PrintCheckManualButtonClick

procedure TDriverSlugbaForm.CheckCorrectionButtonClick(Sender: TObject);
begin
 glcObPrCheka.FNameOfClienta:=AnsiToUTF8(ClientEdit.Text);
 glcObPrCheka.FNumOfDogAsString:=NumDogEdit.Text;
 glcObPrCheka.FSummaString:=SummEdit.Text;
 glcObPrCheka.FPaymentCenter:=AnsiToUTF8(PaymentCentrEdit.Text);
 glcObPrCheka.FCheckCorrection:=true;
 glcObPrCheka.FDifferentDayFromToday:=0;
 glcObPrCheka.FNumberCekVozvrata:=StrToInt(NumOfChekaEdit.Text);
 if (glcObPrCheka.FPaymentCenter=AnsiToUTF8('POS terminal Сбербанк')) or
     (glcObPrCheka.FPaymentCenter=AnsiToUTF8('POS terminal')) or
      (glcObPrCheka.FPaymentCenter=AnsiToUTF8('POS terminal Сбербанк Линия 2'))
 then
 begin
  glcObPrCheka.SummBaznal:=glcObPrCheka.FSummaString;
  glcObPrCheka.FSummaString:='0';
 end;
 glcObPrCheka.printCheckCorrection;
 glcObPrCheka.FCheckCorrection:=false;
end;

procedure TDriverSlugbaForm.Button2Click(Sender: TObject);
begin
 if DriverSlugbaForm.Line1CheckBox.Checked then
  PaymentCentrEdit.Text:='POS terminal Сбербанк'
 else
  PaymentCentrEdit.Text:='POS terminal Сбербанк Линия 2';
end;

procedure TDriverSlugbaForm.Button6Click(Sender: TObject);
begin
 PaymentCentrEdit.Text:='POS terminal';
end;

procedure TDriverSlugbaForm.Button7Click(Sender: TObject);
begin
 if EkaterinburgCheckBox.Checked then
  PaymentCentrEdit.Text:='Касса ЦОК Радищева (автомат)'
 else begin
  if Line1CheckBox.Checked then
   PaymentCentrEdit.Text:='Касса линия 1'
  else
   PaymentCentrEdit.Text:='Касса линия 2';
 end;

end;

procedure TDriverSlugbaForm.Button8Click(Sender: TObject);
var
 OpisaniyOshibki:WideString; KodOshibki:integer;
begin
 //try
  ECR.PrintReportWithoutCleaning();
 //except
 //end;
 KodOshibki:=ECR.GetLastError(OpisaniyOshibki);
 Label3.Caption:=IntToStr(KodOshibki);
 Label4.Caption:=Trim(OpisaniyOshibki);
end;

procedure TDriverSlugbaForm.ButtonCheckPrintClick(Sender: TObject);
var XMLDateOfCheka:WideString;
    Doc:TextFile; //
    NumbOfCheka, NumbOfSmena:integer;
    FiskalniyPriznak, AddressSiteInspections:WideString;
    OpisaniyOshibki:WideString; KodOshibki:integer;
    custEMail, custPhone:string;
    //sss:UTF8String; st:Ansistring;
    currNemeFileOfCheck:string;
    oshikaOtrkst:boolean;
    countCicl:integer;
    TimerVkluchit:boolean;
    SystNalog:integer;
    code:integer;
begin
 currNemeFileOfCheck:='c:\share\checkXML.xml';
 AdoDBStream.Open();
 AdoDBStream.LoadFromFile(currNemeFileOfCheck);
 XMLDateOfCheka:=AdoDBStream.ReadText();
 AdoDBStream.Close;
 KodOshibki:=0; OpisaniyOshibki:='';
 ECR.ProcessCheck(gDeviceID, 0, XMLDateOfCheka, NumbOfCheka, NumbOfSmena, FiskalniyPriznak, AddressSiteInspections);
 OpisaniyOshibki:='';
 KodOshibki:=ECR.GetLastError(OpisaniyOshibki);
 DriverSlugbaForm.Label4.Caption:=OpisaniyOshibki;
 //if KodOshibki = 0 then
 // result:=true;
end;

end.
