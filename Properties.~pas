unit Properties;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ScktComp, ToolWin, ComCtrls, ImgList, IniFiles, Mask,
  DBCtrlsEh, ComObj, ShellApi, Menus, sEquipment;

const
  soh = #01;
  stx = #02;
  etx = #03;
  eot = #04;
  ack = #06;
  nak = #15;
  busy = #17;
  rs  = #30;
  us  = #31;
  alive = #255;

  WM_MYICONNOTIFY = WM_USER + 100;

type
  rFRSingle = record
    SenderId: Integer;
    PosId: Integer;
    CmdId: Integer;
    Font: Integer;
    Depart: Integer;
    Text:  string[36];
    Qty:   Currency;
    Price: Currency;
    Tax1: Integer;
    TPayment: Integer;
    matrixBarcod:string[100];
    GTIN:string[100];
    Serial:string[100];
    excise:boolean;
    SNO:integer;
    tail:string[100];
    CS: Byte;
  end;

  TPosition = class
  protected
   FReturnCheck:boolean;
   FPosition:rFRSingle;
   FOwnerList:TList;
   VALIDATION_RESULT:integer;
  public
   constructor Create(list:TList);
   destructor Destroy; override;
  end;

  TfProps = class(TForm)
    svsctMain: TServerSocket;
    Splitter1: TSplitter;
    tbSvrEvents: TToolBar;
    mSvrEvents: TMemo;
    ToolBar2: TToolBar;
    mEcrEvents: TMemo;
    tbContPrint: TToolButton;
    ToolButton3: TToolButton;
    ToolButton1: TToolButton;
    neLines: TDBNumberEditEh;
    ToolButton6: TToolButton;
    tmNextDoc: TTimer;
    tbCancelDoc: TToolButton;
    tbXReport: TToolButton;
    ToolButton8: TToolButton;
    tbZReport: TToolButton;
    tbFindNextDoc: TToolButton;
    ToolButton11: TToolButton;
    tbClear: TToolButton;
    ilChilds24: TImageList;
    tbDrawer: TToolButton;
    ToolButton4: TToolButton;
    tbDepartReport: TToolButton;
    ToolButton2: TToolButton;
    pmTools: TPopupMenu;
    pmSearchDevice: TMenuItem;
    pmSetMode: TMenuItem;
    pmSetDateTime: TMenuItem;
    pmSetOptions: TMenuItem;
    pmSetHdr: TMenuItem;
    pmSetNDS: TMenuItem;
    N8: TMenuItem;
    tbOpenDay: TToolButton;
    dbehAmt: TDBNumberEditEh;
    Label1: TLabel;
    dbeSysOpNm: TDBEditEh;
    Label2: TLabel;
    VerLabel: TLabel;
    dbeSysOpNmComboBox: TComboBox;
    Label3: TLabel;
    CurrCheckMemo: TMemo;
    ModeFFD12CheckBox: TCheckBox;
    procedure AppException(Sender: TObject; E: Exception);
    procedure pAlertMSG(sText: string);
    function  fnQuestMSG(sText: string): Bool;
    procedure FormCreate(Sender: TObject);
    procedure WriteLogFile(sMsg: string);
    procedure WriteAdvancedLogFile(Direction, sMsg: string);
    function  CalcCSum(Value: string): Byte;
    procedure svsctMainClientConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure svsctMainClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure svsctMainClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure svsctMainClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure AddSingleResultEvent(iId, iMsgCode: Integer; sMessage, sDescription: string);
    procedure PrintQueue;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tbFindNextDocClick(Sender: TObject);
    procedure tmNextDocTimer(Sender: TObject);
    procedure tbClearClick(Sender: TObject);
    procedure tbContPrintClick(Sender: TObject);
    procedure tbCancelDocClick(Sender: TObject);
    procedure tbXReportClick(Sender: TObject);
    procedure tbZReportClick(Sender: TObject);
    procedure tbDrawerClick(Sender: TObject);
    procedure tbDepartReportClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure pmToolsItemClick(Sender: TObject);
    procedure tbOpenDayClick(Sender: TObject);
    procedure dbeSysOpNmComboBoxChange(Sender: TObject);
  private
    ifMain: TIniFile;
    aFRCmdBuf: array[0..9] of array of rFRSingle;
    sFRQueue: string;
    bFRBusy: Bool;
    sFRType: string;
    dilin: Integer;
    iRetNDoc: Integer;
    vpCashReg: TVariantPrint;
    RunFlag: Bool;
    sLDocId: string;
    closeWithOutMessage:boolean;
    ListOfPositions:TList;
    function GetLastMessage: string;
    procedure SetLastMessage(sValue: string);
    property sLastMessage: string read GetLastMessage write SetLastMessage;
    function GetLastMessage1: string;
    procedure SetLastMessage1(sValue: string);
    property sLastMessage1: string read GetLastMessage1 write SetLastMessage1;
    procedure CreateTrayIcon(n:Integer);
    procedure DeleteTrayIcon(n:Integer);
    procedure HideMainForm;
    procedure RestoreMainForm;
  public
    procedure WMICON(var msg: TMessage); message WM_MYICONNOTIFY;
    procedure WMSYSCOMMAND(var msg: TMessage); message WM_SYSCOMMAND;
    { Public declarations }
  end;

var
  fProps: TfProps;

  pvwritelogfile: procedure(sText: string) of object;
  pvAddSingleResultEvent: procedure(iId, iMsgCode: Integer; sMessage, sDescription: string) of object;
  pvumsgAlert: procedure(mesg: string) of object;
  pvumsgQuery: function(mesg: string): Bool of object;


implementation

uses AlertMSG, QuestMsg;

{$R *.DFM}

constructor TPosition.Create(list:TList);
begin
 inherited Create;
 //
 FOwnerList:=list;
 FReturnCheck:=false;
end; //

destructor TPosition.Destroy;
begin

 inherited Destroy;
end;

procedure TfProps.AppException(Sender: TObject; E: Exception);
var oTemp: TObject;
    sComponentName: string;
begin
  oTemp := Sender;
  sComponentName := TComponent(Sender).ClassName + ' : ' + TComponent(Sender).Name;
  while TComponent(oTemp).Owner <> nil do begin
    sComponentName := TComponent(oTemp).Owner.Name + '.' + sComponentName;
    oTemp := TComponent(oTemp).Owner;
  end;

  WriteLogFile(sComponentName + ': ' + E.Message);
  Application.ShowException(E);
end;

procedure TfProps.pAlertMSG(sText: string);
begin
  fAlertMSG.Text.Caption := sText;
  fAlertMSG.FormStyle := fsStayOnTop;
  fAlertMSG.ShowModal;
end;

function TfProps.fnQuestMSG(sText: string): Bool;
begin
  fQuestMSG.Text.Caption := sText;
  fQuestMSG.FormStyle := fsStayOnTop;
  fQuestMSG.ShowModal;
  fnQuestMsg := (fQuestMSG.ModalResult = id_Ok);
end;

procedure TfProps.WriteLogFile(sMsg: string);
var stDateTime: TSystemTime;
    sMsgLine: string;
    pcBuf: PChar;
    fsExternal: TFileStream;
begin
  if FileExists(GetCurrentDir+'\errors.log') then
    fsExternal:=TFileStream.Create(GetCurrentDir+'\errors.log',fmOpenWrite)
  else
    fsExternal:=TFileStream.Create(GetCurrentDir+'\errors.log',fmCreate);

  fsExternal.Seek(-1, soFromEnd);
  GetLocalTime(stDateTime);

  sMsgLine := ' ' + FormatFloat('00', stDateTime.wDay) + '/' +
                    FormatFloat('00', stDateTime.wMonth) + ' | ' +
                    FormatFloat('00', stDateTime.wHour) + ':' +
                    FormatFloat('00', stDateTime.wMinute) + ' | ' +
                    sMsg + #$0D#$0A#$00;
  StringReplace(sMsgLine, #$D#$A, '                 '#$D#$A, [rfReplaceAll]);
  pcBuf := PChar(sMsgLine);
  fsExternal.Write(pcBuf^, Length(sMsgLine));

  fsExternal.Destroy;
end;

procedure TfProps.WriteAdvancedLogFile(Direction, sMsg: string);
var stDateTime: TSystemTime;
    sMsgLine: string;
    pcBuf: PChar;
    fsExternal: TFileStream;
begin
  if FileExists(GetCurrentDir+'\Logs\' + Direction + DateToStr(Date()) + '.log') then
    fsExternal:=TFileStream.Create(GetCurrentDir+'\Logs\' + Direction + DateToStr(Date()) + '.log',fmOpenWrite)
  else
    fsExternal:=TFileStream.Create(GetCurrentDir+'\Logs\' + Direction + DateToStr(Date()) + '.log',fmCreate);

  fsExternal.Seek(-1, soFromEnd);
  GetLocalTime(stDateTime);

  sMsgLine := FormatFloat('00', stDateTime.wHour) + ':' +
              FormatFloat('00', stDateTime.wMinute) + ' | ' +
              sMsg + #$0D#$0A#$00;
  StringReplace(sMsgLine, #$D#$A, '        '#$D#$A, [rfReplaceAll]);
  pcBuf := PChar(sMsgLine);
  fsExternal.Write(pcBuf^, Length(sMsgLine));

  fsExternal.Destroy;
end;

function TfProps.GetLastMessage: string;
begin
  Result := mSvrEvents.Text;
end;

procedure TfProps.SetLastMessage(sValue: string);
begin
  mSvrEvents.Lines.Add(sValue);
  if mSvrEvents.Lines.Count > neLines.Value then
    while mSvrEvents.Lines.Count > neLines.Value do
      mSvrEvents.Lines.Delete(0);
end;

function TfProps.GetLastMessage1: string;
begin
  Result := mEcrEvents.Text;
end;

procedure TfProps.SetLastMessage1(sValue: string);
begin
  mEcrEvents.Lines.Add(sValue);
  if mEcrEvents.Lines.Count > neLines.Value then
    while mEcrEvents.Lines.Count > neLines.Value do
      mEcrEvents.Lines.Delete(0);
end;

procedure TfProps.CreateTrayIcon(n:Integer);
var niData : _NOTIFYICONDATA;
begin
 with niData do
  begin
   cbSize := SizeOf(_NOTIFYICONDATA);
   Wnd := Self.Handle; //HWND вашего окна (окна принимающего обратные сообщения)
   uID := 0;          // номер значка
   uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP; //обрабатываемые флаги
//   dwState := NIS_SHAREDICON;
   uCallBackMessage := WM_MYICONNOTIFY;
   hIcon := Application.Icon.Handle;
   szTip := 'Кассовый сервер'#$D#$A'Управление';
//   uTimeoutAndVersion := NOTIFYICON_VERSION;
  end;
  Shell_NotifyIcon(NIM_ADD, @nidata);    // добавление значка
//  Shell_NotifyIcon(NIM_SETVERSION, @nidata);
end;

procedure TfProps.DeleteTrayIcon(n:Integer);
var niData : _NOTIFYICONDATA;
begin
 with nidata do
  begin
   cbSize := SizeOf(_NOTIFYICONDATA);
   Wnd := Self.Handle;
   uID := 0;
  end;
  Shell_NotifyIcon(NIM_DELETE, @nidata);
end;

procedure TfProps.HideMainForm;
begin
//при сокрытии окна
  Application.ShowMainForm := False;
  ShowWindow(Application.Handle, SW_HIDE);
  ShowWindow(Self.Handle, SW_HIDE);
  Self.Visible := False;
end;

procedure TfProps.RestoreMainForm;
begin
  Self.Visible := True;
  Application.ShowMainForm := True;
  ShowWindow(Application.Handle, SW_RESTORE);
  ShowWindow(Self.Handle, SW_RESTORE);
  SetForegroundWindow(Self.Handle);
end;

procedure TfProps.WMSYSCOMMAND(var msg: TMessage);
begin
 inherited;
 if (Msg.wParam = SC_MINIMIZE) or (Msg.wParam = SC_ICON) then begin
   HideMainForm;
 end;
end;

procedure TfProps.WMICON(var msg: TMessage);
begin
 if msg.LParam = WM_LBUTTONUP then begin
    if Self.Visible then
       HideMainForm
    else
       RestoreMainForm;
 end;
end;

{********************************************************************************************************************************************************}

procedure TfProps.FormCreate(Sender: TObject);
var sIniFName, sCashierName: string;
    cashiersStrList:TStringList;
    kassName:string;
    i:integer;
begin
  closeWithOutMessage:=true;
  ListOfPositions:=TList.Create;
  fAlertMsg := TfAlertMsg.Create(Self);
  fQuestMsg := TfQuestMsg.Create(Self);

  Application.OnException := AppException;

  sIniFName := ChangeFileExt(Application.ExeName, '.ini');
  if not FileExists(sIniFName) then begin
     pAlertMsg('Кассовый сервер - Инициализация'#$D#$A'Отсутствует файл настроек');
     Exit;
  end;

  ifMain := TIniFile.Create(sIniFName);

  svsctMain.Port := ifMain.ReadInteger('Local', 'Port', 9514);
  dilin := ifMain.ReadInteger('Local', 'SndAlert', 1);

  try
    svsctMain.Active := True;
  except
    pAlertMsg('Кассовый сервер - Инициализация'#$D#$A +
              'Не удается открыть порт (listener)'#$D#$A +
              'Вероятно, модуль уже выполняется.');
    Application.Terminate;
    Exit;
  end;

  pvwritelogfile := WriteLogFile;
  pvAddSingleResultEvent := AddSingleResultEvent;
  pvumsgAlert := pAlertMSG;
  pvumsgQuery := fnQuestMSG;

  CreateTrayIcon(1);
  PostMessage(Self.Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);

  sFRType := ifMain.ReadString('FRCash', 'Type', '*');
  sCashierName := ifMain.ReadString('CashierName', 'CashierName', dbeSysOpNm.Text);
  if sCashierName='' then
   sCashierName:=dbeSysOpNm.Text;
  cashiersStrList:=TStringList.Create;
  ifMain.ReadSection('CashierName', cashiersStrList);
  for i:=0 to cashiersStrList.Count - 1 do begin
   kassName:=ifMain.ReadString('CashierName', cashiersStrList[i], '');
   if kassName <> '' then
    dbeSysOpNmComboBox.Items.Add(kassName);
  end;
  cashiersStrList.Destroy;
  if dbeSysOpNmComboBox.Items.Count = 0 then begin
   dbeSysOpNmComboBox.Items.Add(sCashierName);
  end;
  dbeSysOpNmComboBox.ItemIndex:=0;
  sCashierName:=dbeSysOpNmComboBox.Text;
  if sCashierName<>'' then
   if (sCashierName <> dbeSysOpNm.Text) then
    dbeSysOpNm.Text:=sCashierName;

  vpCashReg := TVariantPrint.Create(Self, sFRType);
  if not vpCashReg.InitOk then begin
//     MessageBox(Handle, 'Драйвер ФР не установлен. Формирование'#13#10'формальных документов недоступно.', 'Внимание', $10);
     pAlertMsg('Кассовый сервер - Инициализация '#$D#$A +
               'Драйвер ФР не установлен. '#$D#$A +
               'Работа с регистратором невозможна');
     Application.Terminate;
     Exit;
  end else

     if not vpCashReg.Setup(ifMain) then begin
        pAlertMsg('Кассовый сервер - Инициализация'#$D#$A +
                  'Не удается установить соединение с регистратором.');
     end;

end;

procedure TfProps.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 CanClose:=closeWithOutMessage;
 if not closeWithOutMessage then
  CanClose := fnQuestMsg('Печать кассовых чеков будет недоступна!'#$D#$A'       Всё равно выйти ?');
 closeWithOutMessage:=false;
end;

procedure TfProps.FormClose(Sender: TObject; var Action: TCloseAction);
var
 i:integer;
begin
  for i:=0 to ListOfPositions.Count-1 do begin
   TPosition(ListOfPositions[i]).Destroy;
  end;
  ListOfPositions.Clear;
  ListOfPositions.Destroy;
  if (vpCashReg <> nil) then
     vpCashReg.Destroy;
  DeleteTrayIcon(1);
end;

function TfProps.CalcCSum(Value: string): Byte;
var iCounter: Integer;
    wCSum: DWord;
begin
  wCSum := 0;
  for iCounter := 1 to Length(Value) do
    wCSum := wCSum + Ord(Value[iCounter]);
  if wCSum = 0 then
    Sleep(1);
  Result := Lo(wCSum);
end;

{******************************************************************************* socket events }

procedure TfProps.svsctMainClientConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  sLastMessage := 'Connected:' + Socket.RemoteAddress;
//  if (dilin > 0) then
//     if not vpCashReg.Beep then
//       pAlertMSG('... ::: Кассовый сервер - Подключение ::: ...'#$D#$A +
//                 'Не удается установить соединение с регистратором.');
end;

procedure TfProps.svsctMainClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  sLastMessage := 'Disconnected:' + Socket.RemoteAddress;
end;

procedure TfProps.svsctMainClientError(Sender: TObject; Socket: TCustomWinSocket;
                                     ErrorEvent: TErrorEvent; var ErrorCode: Integer);
var evt:String;
begin
  Case ErrorEvent of
       eeGeneral:    evt := ' General fault on ';
       eeSend:       evt := ' Send fault on ';
       eeReceive:    evt := ' Receive fault on ';
       eeConnect:    evt := ' Connect fault on ';
       eeDisconnect: evt := ' Disconnect fault on ';
       eeAccept:     evt := ' Accept fault on ' end;
  sLastMessage := 'Error:' + IntToStr(ErrorCode) + evt + Socket.RemoteAddress;
  ErrorCode := 0;
end;

procedure TfProps.svsctMainClientRead(Sender: TObject; Socket: TCustomWinSocket);
var sTmpRT, sCsTmp, sDocId: string;
    slTmpRList, slTmpRSList: TStringList;
    rtFRSingle: rFRSingle;
    iC, iC2, iCS: Integer;
    fAdd, fPckt: Bool;
    gtinLoc, serialLoc:string;
    excisegood:string; countOfElements:integer;
    bResFR, canClose:boolean;
    actClose:TCloseAction;
    i:integer;
begin
  sTmpRT := Socket.ReceiveText;
  fPckt := false;
  if (sTmpRT[1] = STX) and (sTmpRT[Length(sTmpRT)] = ETX) then begin
    Delete(sTmpRT, 1, 1);
    Delete(sTmpRT, Length(sTmpRT), 1);
    fPckt := True;
  end;

  if (sTmpRT[1] = SOH) and (sTmpRT[Length(sTmpRT)] = EOT) then begin // Entire document
    slTmpRList := TStringList.Create;
    slTmpRSList := TStringList.Create;
    Delete(sTmpRT, 1, 1);
    Delete(sTmpRT, Length(sTmpRT), 1);
    sCsTmp := Copy(sTmpRT, Length(sTmpRT) - 4, 5);
    iCS := StrToInt(sCsTmp);
    Delete(sTmpRT, Length(sTmpRT) - 5, 6);

    sDocId := Copy(sTmpRT, Length(sTmpRT) - 4, 5);
    Delete(sTmpRT, Length(sTmpRT) - 5, 6);

    rtFRSingle.SenderId := StrToInt(sTmpRT[1]);
    if iCS = CalcCSum(sTmpRT + rs) then begin
       Socket.SendText(ack);
       if (sDocId = sLDocId) then begin
          sLastMessage := 'Повторный документ по тайм-ауту';
          Exit;
       end;
       SetLength(aFRCmdBuf[rtFRSingle.SenderId], 0);
       iRetNDoc := 0;
       slTmpRList.Text := StringReplace(sTmpRT, rs, #$0D#$0A, [rfReplaceAll]);
       WriteAdvancedLogFile('In', 'parse ' + IntToStr(slTmpRList.Count) + ' blocks');
       for iC := 0 to slTmpRList.Count - 1 do begin
//       SenderId: SYSINT; CmdId: SYSINT; Depart: SYSINT; const Text: WideString; Qty: SYSINT; Price: Currency
          slTmpRSList.Text := StringReplace(slTmpRList[iC], us, #$0D#$0A, [rfReplaceAll]);
          rtFRSingle.SenderId := StrToInt(slTmpRSList[0]);
          rtFRSingle.CmdId := StrToInt(slTmpRSList[1]);
          rtFRSingle.Depart := StrToInt(slTmpRSList[2]);
          rtFRSingle.Text := slTmpRSList[3];
          rtFRSingle.Qty := StrToFloat(slTmpRSList[4]) / 1000;
          rtFRSingle.Price := StrToFloat(slTmpRSList[5]) / 100;
          rtFRSingle.Tax1 := StrToInt(slTmpRSList[6]);
          rtFRSingle.TPayment := StrToInt(slTmpRSList[7]);
          rtFRSingle.Font := StrToInt(slTmpRSList[8]);
          rtFRSingle.matrixBarcod := slTmpRSList[9]; //
          //WriteAdvancedLogFile('slTmpRSList[9]=', slTmpRSList[9]);
          rtFRSingle.GTIN:=slTmpRSList[10];
          //WriteAdvancedLogFile('slTmpRSList[10]=', slTmpRSList[10]);
          rtFRSingle.Serial:=slTmpRSList[11];
          rtFRSingle.excise:=false;
          rtFRSingle.SNO:=0;
          if  slTmpRSList.Count>12 then begin //ещё есть хвост
            if slTmpRSList[12]='true' then
             rtFRSingle.excise:=true;
          end;
          rtFRSingle.SNO:=0;
          if  slTmpRSList.Count>13 then begin //ещё есть хвост
            rtFRSingle.SNO:=StrToInt(slTmpRSList[13]);
          end;
          rtFRSingle.tail:='';
          if  slTmpRSList.Count>14 then begin //ещё есть хвос
            rtFRSingle.tail:=slTmpRSList[14]; //хвост марки
          end;
          //WriteAdvancedLogFile('slTmpRSList[11]=', slTmpRSList[11]);
//          rtFRSingle.PosId := StrToInt(slTmpRList[9]); // docid!!!
//          for iC2 := 0 to slTmpRSList.Count - 1 do
//              sLastMessage := slTmpRSList[iC2];

         SetLength(aFRCmdBuf[rtFRSingle.SenderId], Length(aFRCmdBuf[rtFRSingle.SenderId]) + 1);
         aFRCmdBuf[rtFRSingle.SenderId][Length(aFRCmdBuf[rtFRSingle.SenderId]) - 1] := rtFRSingle;

         excisegood:='нет';
         if rtFRSingle.excise then excisegood:='да';
         sLastMessage := 'Команда #' + IntToStr(rtFRSingle.CmdId) + ' (' + IntToStr(rtFRSingle.SenderId) +
                         ') :: ' + rtFRSingle.Text + ' Отд: ' + FormatFloat('0', rtFRSingle.Depart) +
                         ' НГ: ' + FormatFloat('0.00', rtFRSingle.Tax1) +
                         ' Кол: ' + FormatFloat('0.000', rtFRSingle.Qty) +
                         ' Цена: ' + FormatFloat('0.00', rtFRSingle.Price) +
                         ' Марка: ' + rtFRSingle.matrixBarcod +
                         ' GTIN: ' + rtFRSingle.GTIN +
                         ' Serial: ' + rtFRSingle.Serial +
                         ' SignMark: ' + rtFRSingle.tail +
                         ' Акзицный: ' + excisegood +
                         'СНО: ' + IntToStr(rtFRSingle.SNO);
         WriteAdvancedLogFile('In', '>cmd#' + IntToStr(rtFRSingle.CmdId) + ' (' + IntToStr(rtFRSingle.SenderId) +
                         ') :: ' + rtFRSingle.Text + ' Отд: ' + FormatFloat('0', rtFRSingle.Depart) +
                         ' НГ: ' + FormatFloat('0.00', rtFRSingle.Tax1) +
                         ' Кол: ' + FormatFloat('0.000', rtFRSingle.Qty) +
                         ' Цена: ' + FormatFloat('0.00', rtFRSingle.Price) +
                         ' Марка: ' + rtFRSingle.matrixBarcod +
                         ' GTIN: ' + rtFRSingle.GTIN +
                         ' Serial: ' + rtFRSingle.Serial +
                         ' SignMark: ' + rtFRSingle.tail +
                         ' Акцизный: ' + excisegood +
                         'СНО: ' + IntToStr(rtFRSingle.SNO));
         WriteAdvancedLogFile('In', 'ok:' + inttostr(iC));
       end; //for

       WriteAdvancedLogFile('In', 'parse completed');

       WriteAdvancedLogFile('In', 'Запрос печати (' + IntToStr(rtFRSingle.SenderId) + ')');
       sLastMessage := 'PrintRequest from ' + IntToStr(rtFRSingle.SenderId);

       Application.ProcessMessages;

       sFRQueue := sFRQueue + IntToStr(rtFRSingle.SenderId);
       if (not bFRBusy) then begin
         WriteAdvancedLogFile('Out', 'Инициализация печати (' + IntToStr(rtFRSingle.SenderId) + ')');
         PrintQueue;
         if (Socket.Connected) then begin
            Socket.SendText(IntToStr(iRetNDoc));
         end else begin
            pAlertMsg('Номер документа (' + IntToStr(iRetNDoc) + ') не может быть передан вызывающему модулю, поскольку не указан параметр KeepAlive');
            WriteAdvancedLogFile('In', 'Номер документа (' + IntToStr(iRetNDoc) + ') не может быть передан вызывающему модулю, поскольку не указан параметр KeepAlive');
         end;
       end;

       fPckt := true;
    end else begin
       sLastMessage := 'Bad data: CSum';
       Socket.SendText(nak);
    end;
    slTmpRSList.Free;
    slTmpRList.Free;
    Exit;
  end;
  if not fPckt then begin
    sLastMessage := 'Bad data: no stx/etx/soh/eot';
    Socket.SendText(nak);
    Exit;
  end;
  DecimalSeparator := #$2E;
  slTmpRList := TStringList.Create;
  slTmpRList.Text := sTmpRT;
  rtFRSingle.SenderId := StrToInt(StringReplace(slTmpRList[0], ',', '.', [rfReplaceAll]));
  rtFRSingle.PosId :=    StrToInt(StringReplace(slTmpRList[1], ',', '.', [rfReplaceAll]));
  rtFRSingle.CmdId :=    StrToInt(StringReplace(slTmpRList[2], ',', '.', [rfReplaceAll]));
  rtFRSingle.Font :=     StrToInt(StringReplace(slTmpRList[3], ',', '.', [rfReplaceAll]));
  rtFRSingle.Depart :=   StrToInt(StringReplace(slTmpRList[4], ',', '.', [rfReplaceAll]));
  rtFRSingle.Text :=     slTmpRList[5];
  rtFRSingle.Qty :=      StrToFloat(StringReplace(slTmpRList[6], ',', '.', [rfReplaceAll]));
  rtFRSingle.Price :=    StrToFloat(StringReplace(slTmpRList[7], ',', '.', [rfReplaceAll]));
  rtFRSingle.Tax1 :=     StrToInt(StringReplace(slTmpRList[8], ',', '.', [rfReplaceAll]));
  rtFRSingle.TPayment := StrToInt(StringReplace(slTmpRList[9], ',', '.', [rfReplaceAll]));
  rtFRSingle.matrixBarcod:=slTmpRList[10];
  //WriteAdvancedLogFile('slTmpRList[10]', slTmpRList[10]);
  rtFRSingle.GTIN:=slTmpRList[11];
  //WriteAdvancedLogFile('slTmpRList[11]', slTmpRList[11]);
  rtFRSingle.Serial:=slTmpRList[12];
  rtFRSingle.excise:=false;
  if slTmpRList.Count > 14 then begin
   if slTmpRList[13]='true' then
     rtFRSingle.excise:=true;
  end;
  rtFRSingle.SNO:=0;
  if slTmpRList.Count > 15 then begin
   rtFRSingle.SNO:=StrToInt(slTmpRList[14]);
  end;
  rtFRSingle.tail:='';
  if slTmpRList.Count > 16 then begin
   rtFRSingle.tail:=slTmpRList[15];
  end;
  ////WriteAdvancedLogFile('slTmpRList[12]', slTmpRList[12]);
  //rtFRSingle.CS :=       StrToInt(StringReplace(slTmpRList[13], ',', '.', [rfReplaceAll]));
  //slTmpRList.Delete(13);
  countOfElements:=slTmpRList.Count;
  rtFRSingle.CS :=       StrToInt(StringReplace(slTmpRList[countOfElements-1], ',', '.', [rfReplaceAll]));
  slTmpRList.Delete(countOfElements-1);
  iCS := CalcCSum(slTmpRList.Text);
  slTmpRList.Free;

  if rtFRSingle.CS = iCS then begin
    if not rtFRSingle.SenderId in [0..9] then begin
       sLastMessage := 'CmdRequest from ' + IntToStr(rtFRSingle.SenderId) + ' - Point out of range';
       WriteAdvancedLogFile('In', 'Запрос от точки (' + IntToStr(rtFRSingle.SenderId) + '). Параметр вне диапазона.');
       Socket.SendText(nak);
       Exit;
    end;

    if (rtFRSingle.CmdId <> 254) and (Length(sFRQueue) <> 0) and (sFRQueue[1] = IntToStr(rtFRSingle.SenderId)) then begin
       sLastMessage := 'Запрос печати (' + IntToStr(rtFRSingle.SenderId) + '). Выполняется печать предыдущего документа.';
       WriteAdvancedLogFile('In', 'Запрос печати (' + IntToStr(rtFRSingle.SenderId) + '). Выполняется печать предыдущего документа.');
       Socket.SendText(Busy);
       Exit;
    end;

    case rtFRSingle.CmdId of
      0: begin
           for i:=0 to ListOfPositions.Count-1 do begin
            TPosition(ListOfPositions[i]).Destroy;
           end;
           ListOfPositions.Clear;
           Socket.SendText(ack);
           sLastMessage := 'NewDocument from ' + IntToStr(rtFRSingle.SenderId);
           SetLength(aFRCmdBuf[rtFRSingle.SenderId], 0);
           WriteAdvancedLogFile('In', 'Новый документ (' + IntToStr(rtFRSingle.SenderId) + ')');
           iRetNDoc := 0;
         end;
    254: begin
           sLastMessage := 'KeepAliveMessage From ' + IntToStr(rtFRSingle.SenderId);
           WriteAdvancedLogFile('In', 'KeepAliveMessage (' + IntToStr(rtFRSingle.SenderId) + ')');
           Socket.SendText(alive);
         end;
    255: begin
           Socket.SendText(ack);
           sLastMessage := 'PrintRequest from ' + IntToStr(rtFRSingle.SenderId);
           sFRQueue := sFRQueue + IntToStr(rtFRSingle.SenderId);
           WriteAdvancedLogFile('In', 'Запрос печати (' + IntToStr(rtFRSingle.SenderId) + ')');
           if (not bFRBusy) then begin
             WriteAdvancedLogFile('Out', 'Инициализация печати (' + IntToStr(rtFRSingle.SenderId) + ')');
             PrintQueue;
             if (Socket.Connected) then begin
                Socket.SendText(IntToStr(iRetNDoc));
             end else begin
                pAlertMsg('Номер документа (' + IntToStr(iRetNDoc) + ') не может быть передан вызывающему модулю, поскольку не указан параметр KeepAlive');
                WriteAdvancedLogFile('In', 'Номер документа (' + IntToStr(iRetNDoc) + ') не может быть передан вызывающему модулю, поскольку не указан параметр KeepAlive');
             end;
           end;
           for i:=0 to ListOfPositions.Count-1 do begin
            TPosition(ListOfPositions[i]).Destroy;
           end;
           ListOfPositions.Clear;
         end;
    11: begin
             Socket.SendText(ack);
             sFRQueue := sFRQueue + IntToStr(rtFRSingle.SenderId);
             sLastMessage := 'Открытие смены';
             WriteAdvancedLogFile('Out', 'OpSm: (' + IntToStr(rtFRSingle.SenderId) + ')');
             bResFR := vpCashReg.OpenSession(rtFRSingle.Text);
             //if not bResFR then
             //   Break;
        end;
    12: begin
             Socket.SendText(ack);
             sFRQueue := sFRQueue + IntToStr(rtFRSingle.SenderId);
             sLastMessage := 'Внесение';
             WriteAdvancedLogFile('Out', 'InCum: (' + IntToStr(rtFRSingle.SenderId) + ')');
             bResFR := vpCashReg.CashIncome(rtFRSingle.Text, rtFRSingle.Price);
             //if not bResFR then
             //   Break;
        end;
    13: begin
             Socket.SendText(ack);
             sFRQueue := sFRQueue + IntToStr(rtFRSingle.SenderId);
             sLastMessage := 'X-отчет';
             WriteAdvancedLogFile('Out', 'X-отч: (' + IntToStr(rtFRSingle.SenderId) + ')');
             bResFR := vpCashReg.Report(false);
             //if not bResFR then
             //   Break;
        end;
    14: begin
             Socket.SendText(ack);
             sFRQueue := sFRQueue + IntToStr(rtFRSingle.SenderId);
             sLastMessage := 'Z-отчет';
             WriteAdvancedLogFile('Out', 'Z-отч: (' + IntToStr(rtFRSingle.SenderId) + ')');
             vpCashReg.CashOutcome('Инкассация наличных', rtFRSingle.Price);
             vpCashReg.WaitForPrinting();
             bResFR := vpCashReg.Report(true);
             //if not bResFR then
             //   Break;
        end;
    99: begin
             Socket.SendText(ack);
             sFRQueue := sFRQueue + IntToStr(rtFRSingle.SenderId);
             sLastMessage := 'Закрытие срервера';
             canClose:=true;
             WriteAdvancedLogFile('Out', 'Закрытие сервера: (' + IntToStr(rtFRSingle.SenderId) + ')');
             //fProps.OnCloseQuery(self, canClose);
             closeWithOutMessage:=true;
             fProps.Close;
             //if not canClose then
             //   Break;
        end;
    else
      Socket.SendText(ack);

      fAdd := True;
      if Length(aFRCmdBuf[rtFRSingle.SenderId]) > 0 then
         if aFRCmdBuf[rtFRSingle.SenderId][Length(aFRCmdBuf[rtFRSingle.SenderId])-1].PosId = rtFRSingle.PosId then begin
            sLastMessage := 'Повторная команда по таймауту';
            WriteAdvancedLogFile('In', 'Повторная команда по таймауту');
            fAdd := False;
         end;

      if fAdd then begin
         SetLength(aFRCmdBuf[rtFRSingle.SenderId], Length(aFRCmdBuf[rtFRSingle.SenderId]) + 1);
         aFRCmdBuf[rtFRSingle.SenderId][Length(aFRCmdBuf[rtFRSingle.SenderId]) - 1] := rtFRSingle;

         excisegood:='нет';
         if rtFRSingle.excise then excisegood:='да';
         sLastMessage := 'Команда #' + IntToStr(rtFRSingle.CmdId) + ' (' + IntToStr(rtFRSingle.SenderId) +
                         ') :: ' + rtFRSingle.Text + ' Отд: ' + FormatFloat('0', rtFRSingle.Depart) +
                         ' НГ: ' + FormatFloat('0.00', rtFRSingle.Tax1) +
                         ' Кол: ' + FormatFloat('0.000', rtFRSingle.Qty) +
                         ' Цена: ' + FormatFloat('0.00', rtFRSingle.Price)+
                         ' Марка: ' + rtFRSingle.matrixBarcod +
                         ' GTIN: ' + rtFRSingle.GTIN +
                         ' Serial: ' + rtFRSingle.Serial +
                         ' SignMark: ' + rtFRSingle.tail +
                         ' Акцизный: ' + excisegood +
                         ' СНО: ' + IntToStr(rtFRSingle.SNO);
         WriteAdvancedLogFile('In', 'Команда #' + IntToStr(rtFRSingle.CmdId) + ' (' + IntToStr(rtFRSingle.SenderId) +
                         ') :: ' + rtFRSingle.Text + ' Отд: ' + FormatFloat('0', rtFRSingle.Depart) +
                         ' НГ: ' + FormatFloat('0.00', rtFRSingle.Tax1) +
                         ' Кол: ' + FormatFloat('0.000', rtFRSingle.Qty) +
                         ' Цена: ' + FormatFloat('0.00', rtFRSingle.Price) +
                         ' Марка: ' + rtFRSingle.matrixBarcod +
                         ' GTIN: ' + rtFRSingle.GTIN +
                         ' Serial: ' + rtFRSingle.Serial +
                         ' SignMark: ' + rtFRSingle.tail +
                         ' Акцизный: ' + excisegood+
                         ' СНО: ' + IntToStr(rtFRSingle.SNO));
      end;
    end;
//    ***1
  end else begin
    Socket.SendText(nak);
    sLastMessage := 'Bad request data. CSum error.';
    WriteAdvancedLogFile('In', 'Ошибка контрольной суммы (' + IntToStr(rtFRSingle.SenderId) + ')');
    Exit;
  end;

end;

// *************************************************************************************************** ШТРИХ

procedure TfProps.AddSingleResultEvent(iId, iMsgCode: Integer; sMessage, sDescription: string);
begin
  // IntToStr(iId) + '|' IntToStr(iMsgCode)
  SetLastMessage(sMessage + '|' + sDescription);
end;

procedure TfProps.PrintQueue;
var iUserId: Integer;
    iCounter: Integer;
    iLengthDoc: Integer;
    cuSumDoc: Currency;
    bResFR: Bool;
    iMDocType: Integer; // mercury opendocument type
    gtinLoc, serialLoc:string;
    excisegood:string;
    canClose:boolean;
    actClose:TCloseAction;
    i:integer;
    PositionObj:TPosition;
    VersFFD12:boolean;
begin

  bResFR := True;
  bFRBusy := True;

  vpCashReg.CashierName:=dbeSysOpNm.Text;
  WriteAdvancedLogFile('Out', 'Запрос на печать очереди (' + sFRQueue + ')');
  sLastMessage1 := 'Запрос на печать очереди (' + sFRQueue + ')';

  if Length(sFRQueue) = 0 then begin
     sLastMessage1 := 'Нет больше данных для печати';
     WriteAdvancedLogFile('Out', 'Печать документа: Нет больше данных для печати');
     bFRBusy := False;
     Exit;
  end;

  if not vpCashReg.CheckFRStateBegin() then begin                              // Готовность регистратора
     sLastMessage1 := 'Проблема с печатью. Отменено пользователем.';
     WriteAdvancedLogFile('Out', 'Проблема с печатью. Отменено пользователем.');
     bFRBusy := False;
     sFRQueue := '';
     Exit;
  end;

  if not vpCashReg.CheckFRAdvancedMode(100, 'CancelPreviousDocument') then begin
     Exit;
  end;

  cuSumDoc := 0;
  iUserId := StrToInt(sFRQueue[1]);
  iLengthDoc := Length(aFRCmdBuf[iUserId]) - 1;


  if vpCashReg.FsModel = 'Mercury' then begin                                  // МЕРКУРИЙ

     iMDocType := -1;
     for iCounter := 0 to iLengthDoc do begin
        if aFRCmdBuf[iUserId][iCounter].CmdId = 2 then
           iMDocType := 0;
        if aFRCmdBuf[iUserId][iCounter].CmdId = 3 then
           iMDocType := 1;
     end;

     if iMDocType >= 0 then                                                    // prerequisites
        vpCashReg.MMSKPrintTitle('', iMDocType);

  end;

  if vpCashReg.FsModel = 'MercuryVCL' then begin                               // МЕРКУРИЙ

     iMDocType := -1;
     for iCounter := 0 to iLengthDoc do begin
        if aFRCmdBuf[iUserId][iCounter].CmdId = 2 then
           iMDocType := 0;
        if aFRCmdBuf[iUserId][iCounter].CmdId = 3 then
           iMDocType := 1;
     end;

     if iMDocType >= 0 then                                                    // prerequisites
        vpCashReg.MSPrintTitle('', iMDocType);

  end;

    for iCounter := 0 to iLengthDoc do begin
      case aFRCmdBuf[iUserId][iCounter].CmdId of
        1: begin
             sLastMessage1 := 'Строка: ' + aFRCmdBuf[iUserId][iCounter].Text;
             WriteAdvancedLogFile('Out', 'str: (' + sFRQueue[1] + ') ' + aFRCmdBuf[iUserId][iCounter].Text);
             if aFRCmdBuf[iUserId][iCounter].Font = 0 then
                bResFR := vpCashReg.PrintString(aFRCmdBuf[iUserId][iCounter].Text)
             else
                bResFR := vpCashReg.PrintWideString(aFRCmdBuf[iUserId][iCounter].Text);

             if not bResFR then
                Break;
           end;
        2: begin //
             sLastMessage1 := 'Продажа: ' + aFRCmdBuf[iUserId][iCounter].Text;
             excisegood:='нет';
             if aFRCmdBuf[iUserId][iCounter].excise then excisegood:='да';
             WriteAdvancedLogFile('Out', 'Sale: (' + sFRQueue[1] + ') ' +
                                         aFRCmdBuf[iUserId][iCounter].Text + ' (' +
                                         ' Отд: ' + IntToStr(aFRCmdBuf[iUserId][iCounter].Depart) +
                                         ' НГ: ' + IntToStr(aFRCmdBuf[iUserId][iCounter].Tax1) +
                                         ' Кол: ' + FormatFloat(',0.000',aFRCmdBuf[iUserId][iCounter].Qty) +
                                         ' Цена: ' + FormatFloat(',0.00',aFRCmdBuf[iUserId][iCounter].Price) +
                                         ' Марка: ' + aFRCmdBuf[iUserId][iCounter].matrixBarcod +
                                         ' GTIN: ' + aFRCmdBuf[iUserId][iCounter].GTIN +
                                         ' Serial: ' + aFRCmdBuf[iUserId][iCounter].Serial +
                                         ' SignMark: ' + aFRCmdBuf[iUserId][iCounter].tail +
                                         ' Акцизный: ' + excisegood +
                                         ' СНО: ' + IntToStr(aFRCmdBuf[iUserId][iCounter].SNO) + ')');
             PositionObj:=TPosition.Create(ListOfPositions);
             PositionObj.FReturnCheck:=false;
             PositionObj.FPosition.Text:=aFRCmdBuf[iUserId][iCounter].Text;
             PositionObj.FPosition.Qty:=aFRCmdBuf[iUserId][iCounter].Qty;
             PositionObj.FPosition.Price:=aFRCmdBuf[iUserId][iCounter].Price;
             PositionObj.FPosition.Depart:=aFRCmdBuf[iUserId][iCounter].Depart;
             PositionObj.FPosition.Tax1:=aFRCmdBuf[iUserId][iCounter].Tax1;
             PositionObj.FPosition.matrixBarcod:=aFRCmdBuf[iUserId][iCounter].matrixBarcod;
             PositionObj.FPosition.GTIN:=aFRCmdBuf[iUserId][iCounter].GTIN;
             PositionObj.FPosition.Serial:=aFRCmdBuf[iUserId][iCounter].Serial;
             PositionObj.FPosition.tail:=aFRCmdBuf[iUserId][iCounter].tail;
             PositionObj.FPosition.excise:=aFRCmdBuf[iUserId][iCounter].excise;
             PositionObj.FPosition.SNO:=aFRCmdBuf[iUserId][iCounter].SNO;
             ListOfPositions.Add(PositionObj);
             if not(ModeFFD12CheckBox.Checked) then
              bResFR := vpCashReg.Sale(false, aFRCmdBuf[iUserId][iCounter].Text,
                                       aFRCmdBuf[iUserId][iCounter].Qty,
                                       aFRCmdBuf[iUserId][iCounter].Price,
                                       aFRCmdBuf[iUserId][iCounter].Depart,
                                       aFRCmdBuf[iUserId][iCounter].Tax1,
                                       aFRCmdBuf[iUserId][iCounter].matrixBarcod,
                                       aFRCmdBuf[iUserId][iCounter].GTIN,
                                       aFRCmdBuf[iUserId][iCounter].Serial,
                                       aFRCmdBuf[iUserId][iCounter].tail,
                                       aFRCmdBuf[iUserId][iCounter].excise,
                                       aFRCmdBuf[iUserId][iCounter].SNO, 0, false);
             if not bResFR then begin
              Break;
             end;
           end;
        3: begin
             sLastMessage1 := 'Возврат: ' + aFRCmdBuf[iUserId][iCounter].Text;
             excisegood:='нет';
             if aFRCmdBuf[iUserId][iCounter].excise then excisegood:='да';
             WriteAdvancedLogFile('Out', 'Ret: (' + sFRQueue[1] + ') ' +
                                         aFRCmdBuf[iUserId][iCounter].Text + ' (' +
                                         ' Отд: ' + IntToStr(aFRCmdBuf[iUserId][iCounter].Depart) +
                                         ' НГ: ' + IntToStr(aFRCmdBuf[iUserId][iCounter].Tax1) +
                                         ' Кол: ' + FormatFloat(',0.000',aFRCmdBuf[iUserId][iCounter].Qty) +
                                         ' Цена: ' + FormatFloat(',0.00',aFRCmdBuf[iUserId][iCounter].Price) +
                                         ' Марка: ' + aFRCmdBuf[iUserId][iCounter].matrixBarcod +
                                         ' GTIN: ' + aFRCmdBuf[iUserId][iCounter].GTIN +
                                         ' Serial: ' + aFRCmdBuf[iUserId][iCounter].Serial +
                                         ' SignMark: ' + aFRCmdBuf[iUserId][iCounter].tail +
                                         ' Акцизный: ' + excisegood +
                                         ' СНО: ' + IntToStr(aFRCmdBuf[iUserId][iCounter].SNO) + ')');
             PositionObj:=TPosition.Create(ListOfPositions);
             PositionObj.FReturnCheck:=true;
             PositionObj.FPosition.Text:=aFRCmdBuf[iUserId][iCounter].Text;
             PositionObj.FPosition.Qty:=aFRCmdBuf[iUserId][iCounter].Qty;
             PositionObj.FPosition.Price:=aFRCmdBuf[iUserId][iCounter].Price;
             PositionObj.FPosition.Depart:=aFRCmdBuf[iUserId][iCounter].Depart;
             PositionObj.FPosition.Tax1:=aFRCmdBuf[iUserId][iCounter].Tax1;
             PositionObj.FPosition.matrixBarcod:=aFRCmdBuf[iUserId][iCounter].matrixBarcod;
             PositionObj.FPosition.GTIN:=aFRCmdBuf[iUserId][iCounter].GTIN;
             PositionObj.FPosition.Serial:=aFRCmdBuf[iUserId][iCounter].Serial;
             PositionObj.FPosition.tail:=aFRCmdBuf[iUserId][iCounter].tail;
             PositionObj.FPosition.excise:=aFRCmdBuf[iUserId][iCounter].excise;
             PositionObj.FPosition.SNO:=aFRCmdBuf[iUserId][iCounter].SNO;
             ListOfPositions.Add(PositionObj);
             if not(ModeFFD12CheckBox.Checked) then
              bResFR := vpCashReg.ReturnSale(aFRCmdBuf[iUserId][iCounter].Text,
                                            aFRCmdBuf[iUserId][iCounter].Qty,
                                            aFRCmdBuf[iUserId][iCounter].Price,
                                            aFRCmdBuf[iUserId][iCounter].Depart,
                                            aFRCmdBuf[iUserId][iCounter].Tax1,
                                            aFRCmdBuf[iUserId][iCounter].matrixBarcod,
                                            aFRCmdBuf[iUserId][iCounter].GTIN,
                                            aFRCmdBuf[iUserId][iCounter].Serial,
                                            aFRCmdBuf[iUserId][iCounter].tail,
                                            aFRCmdBuf[iUserId][iCounter].excise,
                                            aFRCmdBuf[iUserId][iCounter].SNO);
             if not bResFR then
              Break;
           end;
        4: begin
             if ModeFFD12CheckBox.Checked then begin
              VersFFD12:=vpCashReg.IsFFD12();
              if VersFFD12 then begin
               for i:=0 to ListOfPositions.Count-1 do begin
                TPosition(ListOfPositions[i]).Validation_result:=vpCashReg.CheckMarkOnServer(TPosition(ListOfPositions[i]).FReturnCheck,
                                                                                             TPosition(ListOfPositions[i]).FPosition.matrixBarcod,
                                                                                             TPosition(ListOfPositions[i]).FPosition.GTIN,
                                                                                             TPosition(ListOfPositions[i]).FPosition.Serial,
                                                                                             TPosition(ListOfPositions[i]).FPosition.tail);
               end;
              end;
              for i:=0 to ListOfPositions.Count-1 do begin
               with TPosition(ListOfPositions[i]).FPosition do begin
                bResFR:=vpCashReg.Sale(TPosition(ListOfPositions[i]).FReturnCheck, Text, Qty, Price, Depart, Tax1, matrixBarcod, GTIN,
                                       Serial, tail, excise, SNO,  TPosition(ListOfPositions[i]).Validation_result, VersFFD12);
               end;
              end;
             end;
             //очищаем строчки буфкра позиций
             for i:=0 to ListOfPositions.Count-1 do begin
              TPosition(ListOfPositions[i]).Destroy;
             end;
             ListOfPositions.Clear;
             if (aFRCmdBuf[iUserId][iCounter].Price > 0) then begin
              cuSumDoc := aFRCmdBuf[iUserId][iCounter].Price;
             end;
             sLastMessage1 := 'Закрыть чек: ' + aFRCmdBuf[iUserId][iCounter].Text + '(' + FormatFloat(',0.00',cuSumDoc) + ')';
             WriteAdvancedLogFile('Out', 'Rcpt: (' + sFRQueue[1] + ') ' +
                                         aFRCmdBuf[iUserId][iCounter].Text + ' (' +
                                         ' НГ: ' + IntToStr(aFRCmdBuf[iUserId][iCounter].Tax1) +
                                         ' Сум: ' + FormatFloat(',0.00',cuSumDoc) +
                                         ')');
             bResFR := vpCashReg.CloseCheck(aFRCmdBuf[iUserId][iCounter].Text,
                                            cuSumDoc, cuSumDoc,                // add to sender new field = <cash value> for odd-money
                                            aFRCmdBuf[iUserId][iCounter].TPayment,
                                            aFRCmdBuf[iUserId][iCounter].Tax1);
             if not bResFR then
              Break;
           end;
        5: begin
             sLastMessage1 := 'Отрезка ';
             WriteAdvancedLogFile('Out', 'Cut: (' + sFRQueue[1] + ')');
             bResFR := vpCashReg.Cut;
             if not bResFR then
                Break;
           end;
        6: begin
             sLastMessage1 := 'Ящик ';
             WriteAdvancedLogFile('Out', 'MBox: (' + sFRQueue[1] + ')');
             bResFR := vpCashReg.OpenDrawer;
             if not bResFR then
                Break;
           end;
        7: begin
             sLastMessage := 'Тел. покупателя';
             WriteAdvancedLogFile('Out', 'Tel: (' + sFRQueue[1] + ')');
             bResFR := vpCashReg.FNSendCustomerTel(aFRCmdBuf[iUserId][iCounter].Text);
             if not bResFR then
                Break;
           end;
        8: begin
             sLastMessage := 'E-mail покупателя';
             WriteAdvancedLogFile('Out', 'Eml: (' + sFRQueue[1] + ')');
             bResFR := vpCashReg.FNSendCustomerEml(aFRCmdBuf[iUserId][iCounter].Text);
             if not bResFR then
                Break;
           end;
        9: begin
             sLastMessage := 'ИНН покупателя';
             WriteAdvancedLogFile('Out', 'Tel: (' + sFRQueue[1] + ')');
             bResFR := vpCashReg.FNSendCustomerINN(aFRCmdBuf[iUserId][iCounter].Text);
             if not bResFR then
                Break;
           end;
        1021: begin
             sLastMessage := 'Фамилия и имя кассира';
             WriteAdvancedLogFile('Out', 'Cash: (' + sFRQueue[1] + ')');
             bResFR := vpCashReg.FNSendCashFam(aFRCmdBuf[iUserId][iCounter].Text);
             if not bResFR then
                Break;
           end;
       10: begin
             sLastMessage := 'Наименование покупателя';
             WriteAdvancedLogFile('Out', 'Eml: (' + sFRQueue[1] + ')');
             bResFR := vpCashReg.FNSendCustomerNm(aFRCmdBuf[iUserId][iCounter].Text);
             if not bResFR then
                Break;
           end;
       11: begin
             sLastMessage := 'Открытие смены';
             WriteAdvancedLogFile('Out', 'OpSm: (' + sFRQueue[1] + ')');
             bResFR := vpCashReg.OpenSession(aFRCmdBuf[iUserId][iCounter].Text);
             if not bResFR then
                Break;
           end;
       12: begin
             sLastMessage := 'Внесение';
             WriteAdvancedLogFile('Out', 'InCum: (' + sFRQueue[1] + ')');
             bResFR := vpCashReg.CashIncome(aFRCmdBuf[iUserId][iCounter].Text, aFRCmdBuf[iUserId][iCounter].Price);
             if not bResFR then
                Break;
           end;
       13: begin
             sLastMessage := 'X-отчет';
             WriteAdvancedLogFile('Out', 'X-отч: (' + sFRQueue[1] + ')');
             bResFR := vpCashReg.Report(false);
             if not bResFR then
                Break;
           end;
       14: begin
             sLastMessage := 'Z-отчет';
             WriteAdvancedLogFile('Out', 'Z-отч: (' + sFRQueue[1] + ')');
             vpCashReg.CashOutcome('Инкассация наличных', aFRCmdBuf[iUserId][iCounter].Price);
             vpCashReg.WaitForPrinting();
             bResFR := vpCashReg.Report(true);
             if not bResFR then
                Break;
           end;
       99: begin
             sLastMessage := 'Закрытие срервера';
             canClose:=true;
             WriteAdvancedLogFile('Out', 'Закрытие сервера: (' + sFRQueue[1] + ')');
             //fProps.OnCloseQuery(self, canClose);
             fProps.Close;
             if not canClose then
                Break;
           end;

      end; //case

      Application.ProcessMessages;

      if not vpCashReg.CheckFRAdvancedMode(100, 'CancelPreviousDocument') then begin                     // проверка обрыв бумаги
         WriteAdvancedLogFile('Out', 'Cancelled. FRState: ' + vpCashReg.ovObject.ResultCodeDescription + '/' + vpCashReg.ovObject.ECRModeDescription + '/' + vpCashReg.ovObject.ECRAdvancedModeDescription);
         sLastMessage1 := 'Проблема с печатью. Отменено пользователем.';
         bFRBusy := False;
         sFRQueue := '';
         Exit;
      end else begin
         if aFRCmdBuf[iUserId][iCounter].CmdId in [2,3] then begin
           iRetNDoc := vpCashReg.iLastNDoc;
           WriteAdvancedLogFile('Out', 'Запрос номера документа ФР =' + IntToStr(iRetNDoc));
         end;
      end;

      if aFRCmdBuf[iUserId][iCounter].CmdId in [2,3] then begin
         cuSumDoc := cuSumDoc + aFRCmdBuf[iUserId][iCounter].Qty * aFRCmdBuf[iUserId][iCounter].Price;
      end;

    end; // for

  Delete(sFRQueue, 1, 1);
  bFRBusy := False;

  if Length(sFRQueue) > 0 then
     tmNextDoc.Enabled := True;

end;

// ***************************************************************************************************** ^^^^ ШТРИХ

procedure TfProps.tmNextDocTimer(Sender: TObject);
begin
  tmNextDoc.Enabled := False;
  PrintQueue;
end;

procedure TfProps.tbFindNextDocClick(Sender: TObject);
begin
  if Length(sFRQueue) > 0 then
     PrintQueue
  else
     sLastMessage1 := 'Нет больше данных для печати';
// посмотреть sFRQueue. Если никого -
// Посмотреть массив на предмет наличия записей
end;

procedure TfProps.tbClearClick(Sender: TObject);
begin
  mSvrEvents.Clear;
  mEcrEvents.Clear;
end;

procedure TfProps.tbContPrintClick(Sender: TObject);
begin
  vpCashReg.Continue;
end;

procedure TfProps.tbCancelDocClick(Sender: TObject);
var iTemp: Integer;
begin
  vpCashReg.CancelDoc;
  for iTemp := 0 to 9 do begin
    SetLength(aFRCmdBuf[iTemp], 0);
  end;
  sFRQueue := '';
end;

procedure TfProps.tbXReportClick(Sender: TObject);
begin
  vpCashReg.Report(False);
end;

procedure TfProps.tbDepartReportClick(Sender: TObject);
begin
  vpCashReg.DepartReport;
end;

procedure TfProps.tbZReportClick(Sender: TObject);
begin
 if dbehAmt.Value > 0 then begin
  vpCashReg.CashOutcome('Инкассация наличных', dbehAmt.Value);
  vpCashReg.WaitForPrinting();
 end;
 vpCashReg.Report(True);
end;

procedure TfProps.tbDrawerClick(Sender: TObject);
begin
  vpCashReg.OpenDrawer;
end;

procedure TfProps.pmToolsItemClick(Sender: TObject);
begin
  TMenuItem(Sender).Checked := not TMenuItem(Sender).Checked;
end;

procedure TfProps.tbOpenDayClick(Sender: TObject);
begin
//  if sFRType = 'MStar' then begin
//     vMStarFRF.OpenDay(0, 'Кассир1', True, 0);
//  end else begin
//  end;
//  vpCashReg.setSysOpName(dbeSysOpNm.Text);
  vpCashReg.OpenSession(dbeSysOpNm.Text);
  vpCashReg.WaitForPrinting();
  vpCashReg.CashIncome('Внесение наличных в кассу', dbehAmt.Value);
end;

procedure TfProps.dbeSysOpNmComboBoxChange(Sender: TObject);
begin
 dbeSysOpNm.Text:=dbeSysOpNmComboBox.Text;
end;

end.
