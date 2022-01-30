unit UnitTestClienta;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComObj;

type
  TTestForm = class(TForm)
    CreateObjButton: TButton;
    ConnectButton: TButton;
    BeginDocButton: TButton;
    TextButton: TButton;
    EndTranzButton: TButton;
    SaleButton: TButton;
    CloseCheckButton: TButton;
    OneMethodButton: TButton;
    SendBufferButton: TButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    CloseServerButton: TButton;
    ParseButton: TButton;
    MarkaEdit: TEdit;
    GtinLabel: TLabel;
    SerialLabel: TLabel;
    TailLabel: TLabel;
    Button6: TButton;
    MarkEdit: TEdit;
    procedure CreateObjButtonClick(Sender: TObject);
    procedure ConnectButtonClick(Sender: TObject);
    procedure BeginDocButtonClick(Sender: TObject);
    procedure TextButtonClick(Sender: TObject);
    procedure EndTranzButtonClick(Sender: TObject);
    procedure SaleButtonClick(Sender: TObject);
    procedure CloseCheckButtonClick(Sender: TObject);
    procedure OneMethodButtonClick(Sender: TObject);
    procedure SendBufferButtonClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure CloseServerButtonClick(Sender: TObject);
    procedure ParseButtonClick(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TestForm: TTestForm;
  MyCashObject:OLEVariant;

implementation

{$R *.dfm}

procedure TTestForm.CreateObjButtonClick(Sender: TObject);
begin
 MyCashObject:=CreateOLEObject('RemoteCashClient.CRemoteCashClient');
end;

procedure TTestForm.ConnectButtonClick(Sender: TObject);
begin
  // Установка начальных параметров
  MyCashObject.OwnerWnd:=handle;
  MyCashObject.SenderId:=1;
  //MyCashObject.RemoteIP:='192.168.0.101';
  MyCashObject.RemoteIP:='10.0.29.33';
  //MyCashObject.RemoteIP:='192.168.172.203';
  MyCashObject.RemotePort:=9514;
  MyCashObject.KeepAlive:=1;

end;

procedure TTestForm.BeginDocButtonClick(Sender: TObject);
begin
//				начало документа
  MyCashObject.CmdId:= 0;
  MyCashObject.Font:= 0;
  MyCashObject.SendCmd;

  if MyCashObject.SendRes = 0 then begin
  	ShowMessage('Ошибка при отсылке данных на сервер');
  End;
end;

procedure TTestForm.TextButtonClick(Sender: TObject);
begin
//				дополнительный заголовок в документе
  MyCashObject.Text:='Тестирование кассового моста';
  MyCashObject.CmdId:=1;					// печать строки
  MyCashObject.SendCmd;
  MyCashObject.Text:='Оператор:' + 'Администратор';
  MyCashObject.CmdId:=1;					// печать строки
  MyCashObject.SendCmd;
end;

procedure TTestForm.EndTranzButtonClick(Sender: TObject);
begin
//				Завершить передачу документа
  MyCashObject.CmdId:=255;
  MyCashObject.SendCmd;
end;

function ItIsRus(s:string):boolean;
begin
 result:=false;
 if Pos('й', s) > 0 then result:=true
 else if Pos('ц', s) > 0 then result:=true
 else if Pos('у', s) > 0 then result:=true
 else if Pos('к', s) > 0 then result:=true
 else if Pos('е', s) > 0 then result:=true
 else if Pos('н', s) > 0 then result:=true
 else if Pos('г', s) > 0 then result:=true
 else if Pos('ш', s) > 0 then result:=true
 else if Pos('щ', s) > 0 then result:=true
 else if Pos('з', s) > 0 then result:=true
 else if Pos('х', s) > 0 then result:=true
 else if Pos('ъ', s) > 0 then result:=true
 else if Pos('ф', s) > 0 then result:=true
 else if Pos('ы', s) > 0 then result:=true
 else if Pos('в', s) > 0 then result:=true
 else if Pos('а', s) > 0 then result:=true
 else if Pos('п', s) > 0 then result:=true
 else if Pos('р', s) > 0 then result:=true
 else if Pos('о', s) > 0 then result:=true
 else if Pos('л', s) > 0 then result:=true
 else if Pos('д', s) > 0 then result:=true
 else if Pos('ж', s) > 0 then result:=true
 else if Pos('э', s) > 0 then result:=true
 else if Pos('я', s) > 0 then result:=true
 else if Pos('ч', s) > 0 then result:=true
 else if Pos('с', s) > 0 then result:=true
 else if Pos('м', s) > 0 then result:=true
 else if Pos('и', s) > 0 then result:=true
 else if Pos('т', s) > 0 then result:=true
 else if Pos('ь', s) > 0 then result:=true
 else if Pos('б', s) > 0 then result:=true
 else if Pos('ю', s) > 0 then result:=true
 else if Pos('Й', s) > 0 then result:=true
 else if Pos('Ц', s) > 0 then result:=true
 else if Pos('У', s) > 0 then result:=true
 else if Pos('К', s) > 0 then result:=true
 else if Pos('Е', s) > 0 then result:=true
 else if Pos('Н', s) > 0 then result:=true
 else if Pos('Г', s) > 0 then result:=true
 else if Pos('Ш', s) > 0 then result:=true
 else if Pos('Щ', s) > 0 then result:=true
 else if Pos('З', s) > 0 then result:=true
 else if Pos('Х', s) > 0 then result:=true
 else if Pos('Ъ', s) > 0 then result:=true
 else if Pos('Ф', s) > 0 then result:=true
 else if Pos('Ы', s) > 0 then result:=true
 else if Pos('В', s) > 0 then result:=true
 else if Pos('А', s) > 0 then result:=true
 else if Pos('П', s) > 0 then result:=true
 else if Pos('Р', s) > 0 then result:=true
 else if Pos('О', s) > 0 then result:=true
 else if Pos('Л', s) > 0 then result:=true
 else if Pos('Д', s) > 0 then result:=true
 else if Pos('Ж', s) > 0 then result:=true
 else if Pos('Э', s) > 0 then result:=true
 else if Pos('Я', s) > 0 then result:=true
 else if Pos('Ч', s) > 0 then result:=true
 else if Pos('С', s) > 0 then result:=true
 else if Pos('М', s) > 0 then result:=true
 else if Pos('И', s) > 0 then result:=true
 else if Pos('Т', s) > 0 then result:=true
 else if Pos('Ь', s) > 0 then result:=true
 else if Pos('Б', s) > 0 then result:=true
 else if Pos('Ю', s) > 0 then result:=true
 else if Pos('ё', s) > 0 then result:=true
 else if Pos('Ё', s) > 0 then result:=true
 else if Pos('№', s) > 0 then result:=true;
end; //ItIsRus

function TranslateSym(s:string):string;
begin
 result:=s;
 if s='a' then result:='f'
 else if s='a' then result:=','
 else if s='a' then result:='d'
 else if s='a' then result:='u'
 else if s='a' then result:='l'
 else if s='a' then result:='t'
 else if s='?' then result:=';'
 else if s='c' then result:='p'
 else if s='e' then result:='b'
 else if s='e' then result:='q'
 else if s='e' then result:='r'
 else if s='e' then result:='k'
 else if s='i' then result:='v'
 else if s='i' then result:='y'
 else if s='i' then result:='j'
 else if s='i' then result:='g'
 else if s='?' then result:='h'
 else if s='n' then result:='c'
 else if s='o' then result:='n'
 else if s='o' then result:='e'
 else if s='o' then result:='a'
 else if s='o' then result:='['
 else if s='o' then result:='w'
 else if s='?' then result:='x'
 else if s='o' then result:='i'
 else if s='u' then result:='o'
 else if s='u' then result:=']'
 else if s='u' then result:='s'
 else if s='u' then result:='m'
 else if s='y' then result:=''''
 else if s='?' then result:='.'
 else if s='y' then result:='z'
 else if s='A' then result:='F'
 else if s='A' then result:='<'
 else if s='A' then result:='D'
 else if s='A' then result:='U'
 else if s='A' then result:='L'
 else if s='A' then result:='T'
 else if s='?' then result:=':'
 else if s='C' then result:='P'
 else if s='E' then result:='B'
 else if s='E' then result:='Q'
 else if s='E' then result:='R'
 else if s='E' then result:='K'
 else if s='I' then result:='V'
 else if s='I' then result:='Y'
 else if s='I' then result:='J'
 else if s='I' then result:='G'
 else if s='?' then result:='H'
 else if s='N' then result:='C'
 else if s='O' then result:='N'
 else if s='O' then result:='E'
 else if s='O' then result:='A'
 else if s='O' then result:='{'
 else if s='O' then result:='W'
 else if s='?' then result:='X'
 else if s='O' then result:='I'
 else if s='U' then result:='O'
 else if s='U' then result:='}'
 else if s='U' then result:='S'
 else if s='U' then result:='M'
 else if s='Y' then result:='"'
 else if s='?' then result:='>'
 else if s='?' then result:='Z'
 else if s='.' then result:='/'
 else if s=',' then result:='?'
 else if s='/' then result:='|'
 else if s='?' then result:='`'
 else if s='?' then result:='~'
 else if s='"' then result:='@'
 else if s='?' then result:='#'
 else if s=';' then result:='$'
 else if s=':' then result:='^'
 else if s='?' then result:='&';
end; //TranslateSym

function TranslateLatinica(str:string):string;
var
 i,l:integer;
 sCur, sCurTr:string;
begin
 result:=str;
 if ItIsRus(str) then begin
  result:='';
  l:=Length(str);
  for i:=1 to l do begin
   sCur:=copy(str, i, 1);
   sCurTr:=TranslateSym(sCur);
   result:=result+sCurTr;
  end;
 end;
end; //TranslateLatinica

function ParsMarka(marka:string; var gtin:string; var serial:string; var tail:string):boolean;
var
 str:string;
 dl, nomSymbDev91, nomSymbDev92, nomSymbDevSl, nomSymbGS, Prom1, Prom2, Prom21, Prom22, Prom33, nomSymbDev:integer;
 strSSeriey:string;
begin
 tail:='';
 result:=false;
 if Length(marka) < 16 then exit;
 result:=true;
 str:=marka;
 str:=TranslateLatinica(str);
 //str:='fffff';
 if copy(str, 1, 1) <> '0' then begin
  str:=copy(str, 2, 1000);
 end;
 gtin:=copy(str, 3, 14);
 dl:=Length(str);
 strSSeriey:=copy(str, dl - (dl - (3+14+2-1)) + 1, dl - (3+14+2-1));
 nomSymbDev91:=Pos('91', strSSeriey);
 nomSymbDev92:=Pos('92', strSSeriey);
 nomSymbDevSl:=0;
 //nomSymbDevSl:=Pos('\', strSSeriey);
 nomSymbGS:=Pos(Chr(29), strSSeriey);
 nomSymbDev:=0;
 //WriteAdvancedLogFile('91', IntToStr(nomSymbDev91));
 //WriteAdvancedLogFile('92', IntToStr(nomSymbDev92));
 //WriteAdvancedLogFile('Neao', IntToStr(nomSymbDevSl));
 if nomSymbDev91=0 then Prom1:=1000 else Prom1:=nomSymbDev91;
 if nomSymbDev92=0 then Prom21:=1000 else Prom21:=nomSymbDev92;
 if nomSymbDevSl=0 then Prom22:=1000 else Prom22:=nomSymbDevSl;
 if nomSymbGS=0 then Prom33:=1000 else Prom33:=nomSymbGS;
 Prom2:=Prom21;
 //WriteAdvancedLogFile('Prom21', IntToStr(Prom21));
 //WriteAdvancedLogFile('Prom22', IntToStr(Prom22));
 //WriteAdvancedLogFile('Promc2', IntToStr(Prom2));
 if Prom21>Prom22 then Prom2:=Prom22;
 //WriteAdvancedLogFile('Prom2', IntToStr(Prom2));
 nomSymbDev:=Prom1;
 if Prom1>Prom2 then nomSymbDev:=Prom2;
 if nomSymbDev>nomSymbGS then nomSymbDev:=nomSymbGS;
 //nomSymbDev:=Prom2;
 if nomSymbDev = 1000 then nomSymbDev:=0;
 if nomSymbDev=0 then serial:=strSSeriey else serial:=copy(strSSeriey, 1, nomSymbDev - 1);
 //if Length(serial) > 13 then serial:=copy(serial, 1, 13);
 dl:=Length(serial);
 tail:=copy(strSSeriey, dl+1, 1000);
end; //ParsMarka


procedure TTestForm.SaleButtonClick(Sender: TObject);
var
 i:integer;
begin
//				Продажа
 //for i:=1 to 100 do begin
  //MyCashObject.Text:= 'тестовый ' + IntToStr(i) + ' товар';
  MyCashObject.Qty:= 1;
  MyCashObject.Price:= 10;
  try
   MyCashObject.Matrix:='010460043993125621JgXJ5.T\u001d8005112000\u001d930001\u001d923zbrLA==\u001d24014276281';
   //MyCashObject.Matrix:='';
  except
  end;
  //MyCashObject.Matrix:='010460043993125621JgXJ5.T';
  MyCashObject.CmdId:= 2;
  MyCashObject.SendCmd;
 //end;
{//				Продажа
  MyCashObject.Text:= 'тестовый товар';
  MyCashObject.Qty:= 1;
  MyCashObject.Price:= 10;
  try
   MyCashObject.Matrix:='010290002605008021;oU1Q,46JMHu!';
   //MyCashObject.Matrix:='';
  except
  end;
  //MyCashObject.Matrix:='010460043993125621JgXJ5.T';
  MyCashObject.CmdId:= 2;
  MyCashObject.SendCmd;

 //				Продажа
  MyCashObject.Text:= 'тестовый товар';
  MyCashObject.Qty:= 1;
  MyCashObject.Price:= 10;
  try
   MyCashObject.Matrix:='010290000948226621ЕНсБАнЕ8СбВчА9202ЬчДоаУщЫЩ5ц6Фдфь1еВЩяЛафВйЦпзШФЙ62клПЦГдН=';
   //MyCashObject.Matrix:='';
  except
  end;
  //MyCashObject.Matrix:='010460043993125621JgXJ5.T';
  MyCashObject.CmdId:= 2;
  MyCashObject.SendCmd;}
end;

procedure TTestForm.CloseCheckButtonClick(Sender: TObject);
begin
//				Закрыть чек
  MyCashObject.Text:= 'спасибо за покупку';
  MyCashObject.CmdId:= 4;
  MyCashObject.SendCmd;
end;

procedure TTestForm.OneMethodButtonClick(Sender: TObject);
var
 i:integer;
begin
 //MyCashObject.AddLine(1, 2, 1, 'ееееее рррр', 1000, 2000, 1, 1, 0, '010460043993125621JgXJ5.T\u001d8005112000\u001d930001\u001d923zbrLA==\u001d24014276281');
 MyCashObject.AddLine(1, 1, 1, 'Оператор 1', 1000, 3000, 0, 1, 0, '');
 for i:=1 to 1 do begin
  //MyCashObject.AddLine(1, 2, 1, 'жжжжжжж рррр (' + IntToStr(i) + ')', 1000, 3000, 0, 1, 0, '');
  if i mod 5 = 0 then begin
   MyCashObject.SendBuff;
   sleep(2000);
  end;
  //MyCashObject.AddLine(1, 2, 1, 'жжжжжжж рррр (' + IntToStr(i) + ')', 1000, 3000, 0, 1, 0, '010460043993125621JgXJ5.T\u001d8005112000\u001d930001\u001d923zbrLA==\u001d24014276281');
  MyCashObject.AddLine(1, 2, 1, 'жжжжжжж рррр (' + IntToStr(i) + ')', 1000, 3000, 0, 1, 0,
  //                     '010290000226319021g/4LgQ&k.HYit91EE0692D2XzyTJSEP/RFwDOWEbN38rXYMZRAnAFLNX2HOQtofg=');
  '010290000226319021g/4LgQ&k.HYit91EE0692D2XzyTJSEP/RFwDOWEbN38rXYMZRAnAFLNX2HOQtofg=');
 end;
 {MyCashObject.AddLine(1, 3, 1, 'жжжжжжж рррр', 1000, 3000, 0, 1, 0, '010290000282810821Rw"(:y5D=th1k91EE0692qS6VMDNZGBw7sjCfeuRjGPaNV9fzI0MaCc65PEadmgE=');
 MyCashObject.AddLine(1, 3, 1, 'жжжжжжж рррр', 1000, 3000, 0, 1, 0, '');}
end;

procedure TTestForm.SendBufferButtonClick(Sender: TObject);
begin
 MyCashObject.SendBuff;
end;

procedure TTestForm.Button1Click(Sender: TObject);
begin
 MyCashObject.AddLine(1, 3, 1, 'ееееее рррр', 2000, 10000, 0, 1, 0, '');
end;

procedure TTestForm.Button2Click(Sender: TObject);
begin
 //MyCashObject.AddLine(1, 4, 1, 'СПАСИБО за ПОКУПКА', 0, 0, 1, 1, 0, '010460043993125621JgXJ5.T\u001d8005112000\u001d930001\u001d923zbrLA==\u001d24014276281');
 //MyCashObject.AddLine(1, 4, 1, 'СПАСИБО за ПОКУПКА', 0, 0, 1, 2, 0, '010460043993125621JgXJ5.T\u001d8005112000\u001d930001\u001d923zbrLA==\u001d24014276281');
 MyCashObject.AddLine(1, 4, 1, 'СПАСИБО за ПОКУПКА', 0, 0, 1, 2, 0, '');
end;

procedure TTestForm.Button3Click(Sender: TObject);
begin
 MyCashObject.AddLine(1, 4, 1, 'СПАСИБО за ПОКУПКА', 0, 0, 1, 2, 0, '');
end;

procedure TTestForm.Button4Click(Sender: TObject);
begin
 MyCashObject.AddLine(1, 1021, 1, 'Имя кассира', 0, 0, 1, 1, 0, '');
end;

procedure TTestForm.Button5Click(Sender: TObject);
begin
 MyCashObject.Text:= 'Имя кассира';
 MyCashObject.CmdId:= 1021;
 MyCashObject.SendCmd;
end;

procedure TTestForm.Button6Click(Sender: TObject);
begin
  MyCashObject.Qty:= 1;
  MyCashObject.Price:= 10;
  try
   MyCashObject.Matrix:=MarkEdit.Text;
  except
  end;
  MyCashObject.CmdId:= 2;
  MyCashObject.SendCmd;
end;

procedure TTestForm.CloseServerButtonClick(Sender: TObject);
begin
//				начало документа
  MyCashObject.CmdId:= 99;
  MyCashObject.Font:= 0;
  MyCashObject.KeepAlive:=0;
  MyCashObject.SendCmd;

  if MyCashObject.SendRes = 0 then begin
  	ShowMessage('Ошибка при отсылке данных на сервер');
  End;
end;

procedure TTestForm.ParseButtonClick(Sender: TObject);
var
 marka, gtin, serial, tail:string;
begin
 marka:=MarkaEdit.Text;
 ParsMarka(marka, gtin, serial, tail);
 GtinLabel.Caption:=gtin;
 SerialLabel.Caption:=serial;
 TailLabel.Caption:=tail;
end;

end.
