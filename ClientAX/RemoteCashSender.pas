unit RemoteCashSender;

interface

uses
  Windows, Classes, ComObj, ActiveX, AspTlb, ScktComp,
  RemoteCashClient_TLB, StdVcl, SysUtils, ExtCtrls;

const
  soh = #01;
  stx = #02;
  etx = #03;
  eot = #04;
  ack = #06;
  rs  = #30;
  us  = #31;
  nak = #15;
  busy = #17;
  alive = #255;

type
  ErrColl = record
    Code: Integer;
    Descr: string;
  end;

  TRemoteCashClient = class(TASPObject, IRemoteCashClient)
  private
    FLogEvents : Integer;
    FOwnerWnd  : THandle;
    FRemoteIP  : string;
    FRemotePort: Integer;
    FTimeOut   : Integer;
    FSenderId  : Integer;
    FCmdId     : Integer;
    FFont      : Integer;
    FDepart    : Integer;
    FText      : string;
    FQty       : Double;
    FPrice     : Double;
    FTPayment  : Integer;
    FMatrix    : string;
    FGTIN, FSerial, FTail: string;
    FExcise:boolean; //���������� ������
    FSNO:integer;
    FTax1      : Integer;
    FSendRes   : Integer;
    FKeepAlive : Integer;
    FInternalMSGs: Integer;
    FWaitNDoc  : Integer;
    FLastNDoc  : Integer;
    FErrorCode : Integer;
    FPosId :Integer;
    FInformMessage:string;
  protected
    MySocket: TCustomWinSocket;
    csSender: TClientSocket;
    Timer1: TTimer;
    Timer2: TTimer;
    sLastReply: string;
    TimeoutOccurs: Bool;
    sDocBuff: string;
    function Get_LogEvents: SYSINT; safecall;
    function Get_CmdId: SYSINT; safecall;
    function Get_Font: SYSINT; safecall;
    function Get_Tax1: SYSINT; safecall;
    function Get_TimeOut: SYSINT; safecall;
    function Get_Price: Double; safecall;
    function Get_Qty: Double; safecall;
    function Get_RemoteIP: WideString; safecall;
    function Get_RemotePort: SYSINT; safecall;
    function Get_SenderId: SYSINT; safecall;
    function Get_Text: WideString; safecall;
    function Get_Matrix: WideString; safecall;
    function Get_GTIN: WideString; safecall;
    function Get_Serial: WideString; safecall;
    function Get_Excise: SYSINT; safecall;
    function Get_OwnerWnd: SYSUINT; safecall;
    function Get_SendRes: SYSINT; safecall;
    function Get_Depart: SYSINT; safecall;
    function Get_KeepAlive: SYSINT; safecall;
    function Get_InternalMSGs: SYSINT; safecall;
    function Get_WaitNDoc: SYSINT; safecall;
    function Get_LastNDoc: SYSINT; safecall;
    function Get_TPayment: SYSINT; safecall;
    function Get_SNO: SYSINT; safecall;
    function Get_tail: WideString; safecall;
    procedure Set_LogEvents(Value: SYSINT); safecall;
    procedure Set_CmdId(Value: SYSINT); safecall;
    procedure Set_Font(Value: SYSINT); safecall;
    procedure Set_Tax1(Value: SYSINT); safecall;
    procedure Set_TimeOut(Value: SYSINT); safecall;
    procedure Set_Price(Value: Double); safecall;
    procedure Set_Qty(Value: Double); safecall;
    procedure Set_RemoteIP(const Value: WideString); safecall;
    procedure Set_RemotePort(Value: SYSINT); safecall;
    procedure Set_SenderId(Value: SYSINT); safecall;
    procedure Set_Text(const Value: WideString); safecall;
    procedure Set_Matrix(const Value: WideString); safecall;
    procedure Set_GTIN(const Value: WideString); safecall;
    procedure Set_Serial(const Value: WideString); safecall;
    procedure Set_Excise(Value: SYSINT); safecall;
    procedure Set_OwnerWnd(Value: SYSUINT); safecall;
    procedure Set_Depart(Value: SYSINT); safecall;
    procedure Set_KeepAlive(Value: SYSINT); safecall;
    procedure Set_InternalMSGs(Value: SYSINT); safecall;
    procedure Set_WaitNDoc(Value: SYSINT); safecall;
    procedure Set_LastNDoc(Value: SYSINT); safecall;
    procedure Set_TPayment(Value: SYSINT); safecall;
    procedure Set_SNO(Value: SYSINT); safecall;
    procedure Set_tail(const Value: WideString); safecall;
    procedure csSenderConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure csSenderDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure csSenderRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure csSenderError(Sender: TObject; Socket: TCustomWinSocket;
                            ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure SendCmd; safecall;
    procedure AddLine(SenderId: SYSINT; CmdId: SYSINT; Depart: SYSINT;
                const Text: WideString; Qty100x: SYSINT; Price100x: SYSINT;
                      Tax1: SYSINT; TPayment: SYSINT; NFont: SYSINT; const matrix: WideString; excise: SYSINT; SNO:SYSINT); safecall;
    procedure SendBuff; safecall;
    procedure ShowSendMsg(iSendMsgId: Integer);
    function ParsMarka(marka:string; var gtin:string; var serial:string; var tail:string):boolean;
  public
    procedure Initialize; override;
    destructor Destroy; override;
    procedure pAlertMSG(sText: string);
  end;

implementation

uses ComServ, AlertMsg;

function WideStringToString(const ws: WideString; codePage: Word): AnsiString;
var
  l: integer;
begin
  if ws = '' then
    Result := ''
  else
  begin
    l := WideCharToMultiByte(codePage,
      WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR,
      @ws[1], - 1, nil, 0, nil, nil);
    SetLength(Result, l - 1);
    if l > 1 then
      WideCharToMultiByte(codePage,
        WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR,
        @ws[1], - 1, @Result[1], l - 1, nil, nil);
  end;
end; { WideStringToString }


{:Converts Ansi string to Unicode string using specified code page.
  @param   s        Ansi string.
  @param   codePage Code page to be used in conversion.
  @returns Converted wide string.
}
function StringToWideString(const s: AnsiString; codePage: Word): WideString;
var
  l: integer;
begin
  if s = '' then
    Result := ''
  else begin
    l := MultiByteToWideChar(codePage, MB_PRECOMPOSED, PChar(@s[1]), - 1, nil, 0);
    SetLength(Result, l - 1);
    if l > 1 then
      MultiByteToWideChar(CodePage, MB_PRECOMPOSED, PChar(@s[1]),
                          - 1, PWideChar(@Result[1]), l - 1);
  end;
end; { StringToWideString }

function CalcCSum(Value: string): Byte;
var iCounter: Integer;
    wCSum: DWord;
begin
  wCSum := 0;
  for iCounter := 1 to Length(Value) do
    wCSum := wCSum + Ord(Value[iCounter]);
  Result := Lo(wCSum);
end;

const CodeColl: array[0..35] of ErrColl = (
      (Code:10004; Descr:'�������� ��������'),
      (Code:10013; Descr:'����������� ����� �������� �����������������, ��������� ���������� ����.'),
      (Code:10014; Descr:'�������� ��������.'),
      (Code:10022; Descr:'����� �� ��������, invalid address or listen is not invoked prior to accept.'),
      (Code:10024; Descr:'��� ��������� �������� ������������.'),
      (Code:10035; Descr:'������ ������������� �����, ������� �������� ������� ����������.'),
      (Code:10036; Descr:'����������� ����������� �������� Winsock.'),
      (Code:10037; Descr:'�������� ���������. ������������� ���������� �����������.'),
      (Code:10038; Descr:'���������� �� �������� �������.'),
      (Code:10039; Descr:'��������� �������� �����.'),
      (Code:10040; Descr:'���������� �� ����� ���� ��������� � ������ � ����� �������.'),
      (Code:10041; Descr:'��� ���������� ����� �� ������� ��� ����� ������.'),
      (Code:10042; Descr:'���������������� �����'),
      (Code:10043; Descr:'��������� ���� �� ��������������.'),
      (Code:10044; Descr:'��� ������ �� �������������� � ������ ��������� �������.'),
      (Code:10045; Descr:'��� ������ �� ������������� �������������� �������.'),
      (Code:10047; Descr:'��������� ������� �� ��������������.'),
      (Code:10048; Descr:'����� ��� ������������.'),
      (Code:10049; Descr:'����� ���������� � ����� ����������.'),
      (Code:10050; Descr:'���������� ���� �������.'),
      (Code:10051; Descr:'���� �� ����� ���� ���������� � ������� ���� � ��������� ������.'),
      (Code:10052; Descr:'���������� ������� �� �������� ��� ������������� SO_KEEPALIVE.'),
      (Code:10053; Descr:'���������� �������� �� �������� ��� ������ �������.'),
      (Code:10054; Descr:'���������� ������� ��������� �����.'),
      (Code:10055; Descr:'������������ ������� ������.'),
      (Code:10056; Descr:'����� ��� ���������.'),
      (Code:10057; Descr:'����� �� ���������.'),
      (Code:10058; Descr:'����� ��� ��������.'),
      (Code:10060; Descr:'������� ����� �������� ������� ����������.'),
      (Code:10061; Descr:'���������� ���������� ��������� �����.'),
      (Code:10201; Descr:'��� ������� ������� ��� ������ �����.'),
      (Code:10202; Descr:'����� ��� ������� ������� �� ��� ������.'),
      (Code:11001; Descr:'��: ��������� ���� �� ������.'),
      (Code:11002; Descr:'NA�: ��������� ���� �� ������.'),
      (Code:11003; Descr:'��������������� ������.'),
      (Code:11004; Descr:'��� ������ �������������� ����.'));

function DecodeWSErr(ErrCode: Integer): string;
var iC: Integer;
begin
  DecodeWSErr := IntToStr(ErrCode) + ': ';
  for iC := 0 to 35 do
     if CodeColl[iC].Code = ErrCode then begin
        DecodeWSErr := Result + CodeColl[iC].Descr;
        Break;
     end;
end;

procedure TRemoteCashClient.Initialize;
begin
  inherited Initialize;

  fAlertMSG := TfAlertMSG.Create(nil);

  // DefaultValues
  FLogEvents := 1;
  FRemoteIP := '31.25.25.240';
  FRemotePort := 9514;
  FOwnerWnd := 0;
  FTimeOut := 5000;
  FSenderId := 0;
  FSendRes := 0;
  FKeepAlive := 1;
  FInternalMSGs := 1;
  FWaitNDoc := 0;
  FLastNDoc := 0;
  FMatrix:='';
  FExcise:=false;
  FTail:='';
  FSerial:='';
  FGTIN:='';
  FSNO:=0; //������� �� ����� �� ���������

  if csSender = nil then begin
    csSender := TClientSocket.Create(nil);
    csSender.ClientType := ctNonBlocking;
    csSender.OnConnect := csSenderConnect;
    csSender.OnDisconnect := csSenderDisconnect;
    csSender.OnRead := csSenderRead;
    csSender.OnError := csSenderError;
  end;

  if Timer1 = nil then begin
    Timer1 := TTimer.Create(nil);
    Timer1.Enabled := False;
    Timer1.Interval := 3000;
    Timer1.OnTimer := Timer1Timer;
  end;

  if Timer2 = nil then begin
    Timer2 := TTimer.Create(nil);
    Timer2.Enabled := False;
    Timer2.Interval := 60000;
    Timer2.OnTimer := Timer2Timer;
  end;

end;

destructor TRemoteCashClient.Destroy;
begin

  if csSender <> nil then begin
//    messagebox(FOwnerWnd, 'Socket Freed...', 'DEBUG', $40);
    csSender.Close;
    csSender.Free;
  end;

  if Timer1 <> nil then
    Timer1.Free;

  if Timer2 <> nil then
    Timer2.Free;

  inherited Destroy;
end;

procedure TRemoteCashClient.pAlertMSG(sText: string);
begin
  fAlertMSG.Text.Caption := sText;
  fAlertMSG.ShowModal;
end;

procedure TRemoteCashClient.csSenderConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  MySocket := Socket;
end;

procedure TRemoteCashClient.csSenderDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  if MySocket = Socket then
    MySocket := nil;
end;

procedure TRemoteCashClient.csSenderRead(Sender: TObject; Socket: TCustomWinSocket);
begin
  sLastReply := Socket.ReceiveText;
end;

procedure TRemoteCashClient.csSenderError(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
//  if (FInternalMSGs > 0) then begin
//     AlertMsg(IntToStr(ErrorCode) + ': ��������� ������ ��� �������� ������ ���'#$D#$A +
//              '��������� ����. ������ ���������� � ��������');
//    messagebox(FOwnerWnd,'10061: ��������� ������ ��� �������� ������ ���'#$D#$A +
//                         '��������� ����. ������ ���������� � ��������', '������ ������ ����', $10);
//  end;
  FErrorCode := ErrorCode;
  ErrorCode := 0;
end;

procedure TRemoteCashClient.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  TimeoutOccurs := True;
end;

procedure TRemoteCashClient.Timer2Timer(Sender: TObject);
var iRg: Integer;
begin
  iRg := FCmdId;
  FCmdId := 254;
  SendCmd;
  FCmdId := iRg;
end;

  procedure TRemoteCashClient.ShowSendMsg(iSendMsgId: Integer);
  begin
    if FInternalMSGs > 0 then begin
       case iSendMsgId of
         1: if FCmdId = 254 then
               pAlertMSG('���������� � �������� �� ���������. �������������� ' +
                        '������� ���������� ����������� ����� ����������� ����� 2 ���. ' +
                        DecodeWSErr(FErrorCode))
//               messagebox(FOwnerWnd,'���������� � �������� �� ���������. ��������������'#$D#$A +
//                                    '������� ���������� ����������� ����� ����������� ����� 2 ���.',
//                                    'KeepAlive', $10)
            else
               pAlertMSG('��������� ������ ��� �������� ������ ��� ������ ' +
                        '��������� ����. ������ ���������� � ��������. ' +
                        DecodeWSErr(FErrorCode));
//               messagebox(FOwnerWnd,'��������� ������ ��� �������� ������ ��� ������'#$D#$A +
//                                    '��������� ����. ������ ���������� � ��������', '������ ������ ����', $10);
         2: if FCmdId = 254 then
               pAlertMSG('��������� ������ ��� �������� ��������� KeepAlive. ' +
                        '�������� �������� ��������. ')
//               messagebox(FOwnerWnd, '��������� ������ ��� �������� ��������� KeepAlive.'#$D#$A +
//                                     '�������� �������� ��������', '������ ������ ����', $10)
            else
               pAlertMSG('��������� ������ ��� �������� ������ ��� ������ ' +
                        '��������� ����. �������� �������� ��������. ');
//               messagebox(FOwnerWnd, '��������� ������ ��� �������� ������ ��� ������'#$D#$A +
//                                     '��������� ����. �������� �������� ��������', '������ ������ ����', $10);
         3: if FCmdId = 254 then
               Sleep(1) // no user message required
            else
               pAlertMSG('��������� ������ ��� �������� ������ ��� ������ ��������� ����. ' +
                         '������� ����� �� ������ � ������� ���������. ��������� �����. ');
//               messagebox(FOwnerWnd, '��������� ������ ��� �������� ������ ��� ������ ��������� ����.'#$D#$A +
//                                     '������� ����� �� ������ � ������� ���������. ��������� �����.', '������ ������ ����', $10);
         4: if FCmdId = 254 then
               pAlertMSG('��������� ������ ��� �������� ��������� KeepAlive. ' +
                        '������ ����������� �����. ')
//               messagebox(FOwnerWnd, '��������� ������ ��� �������� ��������� KeepAlive.'#$D#$A +
//                                     '������ ����������� �����', 'KeepAlive', $10)
            else
               pAlertMSG('��������� ������ ��� �������� ������ ��� ������. ' +
                        '��������� ����. ������ ����������� �����. ');
//               messagebox(FOwnerWnd, '��������� ������ ��� �������� ������ ��� ������'#$D#$A +
//                                     '��������� ����. ������ ����������� �����', '������ ������ ����', $10);
         5:
               pAlertMSG('��������� ������ ��� ��������� ������ ��������� �� ' +
                        '��������� ����. �������� �������� ��������. ');
//           messagebox(FOwnerWnd, '��������� ������ ��� ��������� ������ ��������� ��'#$D#$A +
//                                 '��������� ����. �������� �������� ��������', '������ ��������� ������', $10);
          200:
               pAlertMSG(FInformMessage);
//           messagebox(FOwnerWnd, '��������� ������ ��� ��������� ������ ��������� ��'#$D#$A +
//                                 '��������� ����. �������� �������� ��������', '������ ��������� ������', $10);
       else
       end; // case
    end; // if
  end;

procedure TRemoteCashClient.SendCmd;
  var slTmpRList: TStringList;
      iRetryCount: Integer;
      Msg: TMSG;
begin
  Timer2.Enabled := False;

  FSendRes := 0;

//  messagebox(FOwnerWnd, 'Trying to set parameters & connect...', 'DEBUG', $40);

  if (MySocket = nil) or (not MySocket.Connected) then begin
     if Length(FRemoteIP) > 6 then begin
        csSender.Address := FRemoteIP;
     end else begin
        csSender.Address := '31.25.25.240';
        FRemoteIP := csSender.Address;
     end;
     csSender.Port := FRemotePort;
     csSender.Active := True;
  end;

  if FCmdId = 0 then begin
     FPosId := 0;
  end else
     Inc(FPosId);
//     sleep(0);

  slTmpRList := TStringList.Create;
  slTmpRList.Add(IntToStr(FSenderId)); //1
  slTmpRList.Add(IntToStr(FPosId)); //2
  slTmpRList.Add(IntToStr(FCmdId)); //3
  slTmpRList.Add(IntToStr(FFont)); //4
  slTmpRList.Add(IntToStr(FDepart));//5
  slTmpRList.Add(FText); //6
  slTmpRList.Add(FormatFloat('0.000', FQty)); //7
  slTmpRList.Add(FormatFloat('0.00', FPrice)); //8
  slTmpRList.Add(IntToStr(FTax1)); //9
  slTmpRList.Add(IntToStr(FTPayment)); //10
  slTmpRList.Add(FMatrix); //11
  slTmpRList.Add(FGTIN); //12
  slTmpRList.Add(FSerial); //13
  if FExcise then //14
   slTmpRList.Add('true')
  else
   slTmpRList.Add('false');
  slTmpRList.Add(IntToStr(FSNO)); //15
  slTmpRList.Add(FTail); //16

//  messagebox(FOwnerWnd, 'Trying to SC calc...', 'DEBUG', $40);

  slTmpRList.Add(FormatFloat('00000', CalcCSum(slTmpRList.Text)));

//  messagebox(FOwnerWnd, 'awaiting connection ...', 'DEBUG', $40);

  iRetryCount := 0;
  while (iRetryCount < 30) do begin
    if (MySocket <> nil) then
       if (MySocket.Connected) then
           iRetryCount := 30;
    sleep(50);
    GetMessage(Msg, 0, 0, 0);
    TranslateMessage(Msg);
    DispatchMessage(Msg);
    inc(iRetryCount);
  end;

  if (MySocket = nil) or (not MySocket.Connected) then begin
     ShowSendMSG(1);
     Exit;
  end;

  // Connection established

//  messagebox(FOwnerWnd, 'activate Send cycle...', 'DEBUG', $40);

  sLastReply := #0;
  iRetryCount := 0;
  while not (sLastReply[1] in [ack, alive]) do begin

    sLastReply := #0;
    MySocket.SendText(stx + slTmpRList.Text + etx);
    TimeoutOccurs := False;
    Timer1.Interval := FTimeOut;
    Timer1.Enabled := True;

    // awaiting reply

    while (sLastReply = #0) and (GetMessage(Msg, 0, 0, 0)) do begin
      TranslateMessage(Msg);
      DispatchMessage(Msg);
      if TimeoutOccurs then
        Break;
    end;

    if sLastReply[1] in [ack, alive] then
       FSendRes := 1;

    if (sLastReply[1] = #0) and TimeoutOccurs then
       if (iRetryCount < 5) then begin
          Sleep(100);
          inc(iRetryCount);
          Continue;
       end else begin
          ShowSendMsg(2);
          Break;
       end;

    if (sLastReply[1] = busy) then
       if (iRetryCount < 5) then begin
          Sleep(100);
          inc(iRetryCount);
          Continue;
       end else begin
          ShowSendMsg(3);
          Break;
       end;

    if (sLastReply[1] = nak) then
       if (iRetryCount < 5) then begin
          inc(iRetryCount);
          Continue;
       end else begin
          ShowSendMsg(4);
          Break;
       end;

  end;

  if ((FCmdId = 255)or(FCmdId=99)) and (FSendRes = 1) then begin

     if FWaitNDoc = 1 then begin     // awaiting NDoc
        FLastNDoc := 0;
        sLastReply := #0;
        TimeoutOccurs := False;
        Timer1.Interval := FTimeOut;
        Timer1.Enabled := True;

        while (sLastReply[1] = #0) and (GetMessage(Msg, 0, 0, 0)) do begin
          TranslateMessage(Msg);
          DispatchMessage(Msg);
          if TimeoutOccurs then     // TimeOut must be more than for awiting simple reply
             Break;
        end;

        if (sLastReply[1] = #0) or (TimeoutOccurs) then begin
           ShowSendMsg(5);
        end else begin
           try
             FLastNDoc := StrToInt(sLastReply);
           except
             FLastNDoc := -1;
           end;
        end;

     end;

     if (FKeepAlive = 0) then
        csSender.Close;

  end;

  if FKeepAlive > 0 then begin
     Timer2.Enabled := True;
//     messagebox(FOwnerWnd, 'KeepAliveTimer started...', 'DEBUG', $40);
  end;

  if (slTmpRList <> nil) then
     FreeAndNil(slTmpRList);
end; //TRemoteCashClient.SendCmd;

function ItIsRus(s:string):boolean;
begin
 result:=false;
 if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true
 else if Pos('�', s) > 0 then result:=true;
end; //ItIsRus

function TranslateSym(s:string):string;
begin
 result:=s;
 if s='�' then result:='f'
 else if s='�' then result:=','
 else if s='�' then result:='d'
 else if s='�' then result:='u'
 else if s='�' then result:='l'
 else if s='�' then result:='t'
 else if s='�' then result:=';'
 else if s='�' then result:='p'
 else if s='�' then result:='b'
 else if s='�' then result:='q'
 else if s='�' then result:='r'
 else if s='�' then result:='k'
 else if s='�' then result:='v'
 else if s='�' then result:='y'
 else if s='�' then result:='j'
 else if s='�' then result:='g'
 else if s='�' then result:='h'
 else if s='�' then result:='c'
 else if s='�' then result:='n'
 else if s='�' then result:='e'
 else if s='�' then result:='a'
 else if s='�' then result:='['
 else if s='�' then result:='w'
 else if s='�' then result:='x'
 else if s='�' then result:='i'
 else if s='�' then result:='o'
 else if s='�' then result:=']'
 else if s='�' then result:='s'
 else if s='�' then result:='m'
 else if s='�' then result:=''''
 else if s='�' then result:='.'
 else if s='�' then result:='z'
 else if s='�' then result:='F'
 else if s='�' then result:='<'
 else if s='�' then result:='D'
 else if s='�' then result:='U'
 else if s='�' then result:='L'
 else if s='�' then result:='T'
 else if s='�' then result:=':'
 else if s='�' then result:='P'
 else if s='�' then result:='B'
 else if s='�' then result:='Q'
 else if s='�' then result:='R'
 else if s='�' then result:='K'
 else if s='�' then result:='V'
 else if s='�' then result:='Y'
 else if s='�' then result:='J'
 else if s='�' then result:='G'
 else if s='�' then result:='H'
 else if s='�' then result:='C'
 else if s='�' then result:='N'
 else if s='�' then result:='E'
 else if s='�' then result:='A'
 else if s='�' then result:='{'
 else if s='�' then result:='W'
 else if s='�' then result:='X'
 else if s='�' then result:='I'
 else if s='�' then result:='O'
 else if s='�' then result:='}'
 else if s='�' then result:='S'
 else if s='�' then result:='M'
 else if s='�' then result:='"'
 else if s='�' then result:='>'
 else if s='�' then result:='Z'
 else if s='.' then result:='/'
 else if s=',' then result:='?'
 else if s='/' then result:='|'
 else if s='�' then result:='`'
 else if s='�' then result:='~'
 else if s='"' then result:='@'
 else if s='�' then result:='#'
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

function TRemoteCashClient.ParsMarka(marka:string; var gtin:string; var serial:string; var tail:string):boolean;
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
 //WriteAdvancedLogFile('����', IntToStr(nomSymbDevSl));
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
 if nomSymbDev>Prom33 then nomSymbDev:=Prom33;
 //nomSymbDev:=Prom2;
 if nomSymbDev = 1000 then nomSymbDev:=0;
 if nomSymbDev=0 then serial:=strSSeriey else serial:=copy(strSSeriey, 1, nomSymbDev - 1);
 //if Length(serial) > 13 then serial:=copy(serial, 1, 13);
 dl:=Length(serial);
 tail:=copy(strSSeriey, dl+1, 1000);
 nomSymbGS:=Pos(Chr(29), strSSeriey);
 if nomSymbGS = 0 then begin
  tail:=Chr(29)+tail;
  nomSymbDev92:=Pos('92', tail);
  tail:=copy(tail, 1, nomSymbDev92-1)+Chr(29)+copy(tail, nomSymbDev92, 300);
 end;
end; //ParsMarka    ;

procedure TRemoteCashClient.AddLine(SenderId: SYSINT; CmdId: SYSINT; Depart: SYSINT;
                                    const Text: WideString; Qty100x: SYSINT; Price100x: SYSINT;
                                    Tax1: SYSINT; TPayment: SYSINT; NFont: SYSINT; const matrix: WideString;
                                    excise: SYSINT; SNO:SYSINT);
var
 gtin, serial, tail:string;
 excisestr:string;
begin
{
  pAlertMSG('4:' + Text);
  pAlertMSG('5:' + IntToStr(Qty100x));
  pAlertMSG('6:' + IntToStr(Price100x));
}
  //self.fGTIN
  gtin:=''; serial:=''; tail:=''; excisestr:='false';
  if excise <> 0 then excisestr:='true';
  FInformMessage:='excise="' + IntToStr(excise) + '"';
  //ShowSendMsg(200);
  ParsMarka(WideStringToString(matrix, 1251), gtin, serial, tail);
  if serial = '' then serial:='xxxx';
  sDocBuff := sDocBuff + IntToStr(SenderId) + us + IntToStr(CmdId) + us + IntToStr(Depart) + us + Text + us +
                         IntToStr(Qty100x) + us + IntToStr(Price100x) + us +
                         IntToStr(Tax1) + us + IntToStr(TPayment) + us + IntToStr(NFont) + us + matrix + us +
                         gtin + us + serial + us + excisestr + us + IntToStr(SNO) + us + tail + rs;
  FInformMessage:='excise="' + excisestr + '"';
  //ShowSendMsg(200);
end; //TRemoteCashClient.AddLine

procedure TRemoteCashClient.SendBuff;
  var iRetryCount: Integer;
      Msg: TMSG;
begin
  Timer2.Enabled := False;

  FSendRes := 0;

  if (MySocket = nil) or (not MySocket.Connected) then begin
     if Length(FRemoteIP) > 6 then begin
        csSender.Address := FRemoteIP;
     end else begin
        csSender.Address := '31.25.25.240';
        FRemoteIP := csSender.Address;
     end;
     csSender.Port := FRemotePort;
     csSender.Active := True;
  end;

  if FCmdId = 0 then begin
     FPosId := 0;
  end else
     Inc(FPosId);
//     sleep(0);

  sDocBuff := sDocBuff + FormatFloat('00000', random(99999)) + rs + FormatFloat('00000', CalcCSum(sDocBuff));

//  messagebox(FOwnerWnd, 'awaiting connection ...', 'DEBUG', $40);

  iRetryCount := 0;
  while (iRetryCount < 30) do begin
    if (MySocket <> nil) then
       if (MySocket.Connected) then
           iRetryCount := 30;
    sleep(50);
    GetMessage(Msg, 0, 0, 0);
    TranslateMessage(Msg);
    DispatchMessage(Msg);
    inc(iRetryCount);
  end;

  if (MySocket = nil) or (not MySocket.Connected) then begin
     ShowSendMSG(1);
     Exit;
  end;

// Connection established

//  messagebox(FOwnerWnd, 'activate Send cycle...', 'DEBUG', $40);

  sLastReply := #0;
  iRetryCount := 0;
  while not (sLastReply[1] in [ack, alive]) do begin

    sLastReply := #0;
    MySocket.SendText(soh + sDocBuff + eot);
    TimeoutOccurs := False;
    Timer1.Interval := FTimeOut;
    Timer1.Enabled := True;

    // awaiting reply

    while (sLastReply = #0) and (GetMessage(Msg, 0, 0, 0)) do begin
      TranslateMessage(Msg);
      DispatchMessage(Msg);
      if TimeoutOccurs then
        Break;
    end;

    if sLastReply[1] in [ack, alive] then
       FSendRes := 1;

    if (sLastReply[1] = #0) and TimeoutOccurs then
       if (iRetryCount < 2) then begin
          Sleep(100);
          inc(iRetryCount);
          Continue;
       end else begin
          ShowSendMsg(2);
          Break;
       end;

    if (sLastReply[1] = busy) then
       if (iRetryCount < 5) then begin
          Sleep(100);
          inc(iRetryCount);
          Continue;
       end else begin
          ShowSendMsg(3);
          Break;
       end;

    if (sLastReply[1] = nak) then
       if (iRetryCount < 2) then begin
          inc(iRetryCount);
          Continue;
       end else begin
          ShowSendMsg(4);
          Break;
       end;

  end;

  if ((FCmdId = 255) or (FCmdId = 99)) and (FSendRes = 1) then begin

     if FWaitNDoc = 1 then begin     // awaiting NDoc
        FLastNDoc := 0;
        sLastReply := #0;
        TimeoutOccurs := False;
        Timer1.Interval := FTimeOut;
        Timer1.Enabled := True;

        while (sLastReply[1] = #0) and (GetMessage(Msg, 0, 0, 0)) do begin
          TranslateMessage(Msg);
          DispatchMessage(Msg);
          if TimeoutOccurs then     // TimeOut must be more than for awiting simple reply
             Break;
        end;

        if (sLastReply[1] = #0) or (TimeoutOccurs) then begin
           ShowSendMsg(5);
        end else begin
           try
             FLastNDoc := StrToInt(sLastReply);
           except
             FLastNDoc := -1;
           end;
        end;

     end;

     if (FKeepAlive = 0) then
        csSender.Close;

  end;

  if FKeepAlive > 0 then begin
     Timer2.Enabled := True;
//     messagebox(FOwnerWnd, 'KeepAliveTimer started...', 'DEBUG', $40);
  end;

  sDocBuff := '';
//  pAlertMSG('!!!');
end;

function TRemoteCashClient.Get_LogEvents: SYSINT;
begin
  Result := FLogEvents;
end;

function TRemoteCashClient.Get_CmdId: SYSINT;
begin
  Result := FCmdId;
end;

function TRemoteCashClient.Get_Font: SYSINT;
begin
  Result := FFont;
end;

function TRemoteCashClient.Get_Tax1: SYSINT;
begin
  Result := FTax1;
end;

function TRemoteCashClient.Get_TimeOut: SYSINT;
begin
  Result := Trunc(FTimeOut / 1000);
end;

function TRemoteCashClient.Get_Price: Double;
begin
  Result := FPrice;
end;

function TRemoteCashClient.Get_Qty: Double;
begin
  Result := FQty;
end;

function TRemoteCashClient.Get_RemoteIP: WideString;
begin
  Result := StringToWideString(FRemoteIP, 1251);
end;

function TRemoteCashClient.Get_RemotePort: SYSINT;
begin
  Result := FRemotePort;
end;

function TRemoteCashClient.Get_SenderId: SYSINT;
begin
  Result := FSenderId;
end;

function TRemoteCashClient.Get_Text: WideString;
begin
  Result := StringToWideString(FText, 1251);
end;

function TRemoteCashClient.Get_Matrix: WideString;
begin
  Result := StringToWideString(FMatrix, 1251);
end;

function TRemoteCashClient.Get_GTIN: WideString;
begin
  Result := StringToWideString(FGTIN, 1251);
end;

function TRemoteCashClient.Get_Serial: WideString;
begin
  Result := StringToWideString(FSerial, 1251);
end;

function TRemoteCashClient.Get_tail: WideString;
begin
  Result := StringToWideString(FTail, 1251);
end;

function TRemoteCashClient.Get_Excise: SYSINT;
begin
  if FExcise then Result:=1 else Result:=0;
end;

function TRemoteCashClient.Get_Depart: SYSINT;
begin
  Result := FDepart;
end;

procedure TRemoteCashClient.Set_Depart(Value: SYSINT);
var sMsgStr: string;
begin
  sMsgStr := '������� ������������ �������������� ����� "' + IntToStr(Value) +
             '"'#$D#$A'�������� ����� ��������� ��� ������ �1.';
  if (0 < Value) and (Value < 17) then
     FDepart := Value
  else begin
     if (FInternalMSGs > 0) then
        messagebox(FOwnerWnd, PChar(sMsgStr), '�������� ����� �������', $30);
     FDepart := 1;
  end;
end;

function TRemoteCashClient.Get_InternalMSGs: SYSINT;
begin
  Result := FInternalMSGs;
end;

function TRemoteCashClient.Get_WaitNDoc: SYSINT;
begin
  Result := FWaitNDoc;
end;

function TRemoteCashClient.Get_LastNDoc: SYSINT;
begin
  Result := FLastNDoc;
end;

function TRemoteCashClient.Get_SNO: SYSINT;
begin
  Result := FSNO;
end;

function TRemoteCashClient.Get_TPayment: SYSINT;
begin
  Result := FTPayment;
end;

procedure TRemoteCashClient.Set_InternalMSGs(Value: SYSINT);
begin
  if (Value > 0) then
     FInternalMSGs := 1
  else
     FInternalMSGs := 0;
end;

procedure TRemoteCashClient.Set_WaitNDoc(Value: SYSINT);
begin
  if (Value > 0) then
     FWaitNDoc := 1
  else
     FWaitNDoc := 0;
end;

procedure TRemoteCashClient.Set_LastNDoc(Value: SYSINT);
begin
  FLastNDoc := Value;
end;

procedure TRemoteCashClient.Set_TPayment(Value: SYSINT);
begin
  if (0 < Value) and (Value < 5) then
     FTPayment := Value
  else begin
     messagebox(FOwnerWnd, '��� ������ ����� �������. ����� ������������ ������ ���������.', '�������� ����� �������', $30);
     FTPayment := 1;
  end;
end;

function TRemoteCashClient.Get_KeepAlive: SYSINT;
begin
  Result := FKeepAlive;
end;

procedure TRemoteCashClient.Set_KeepAlive(Value: SYSINT);
begin
  if Value > 0 then begin
     Timer2.Enabled := True;
     FKeepAlive := 1;
  end else begin
     Timer2.Enabled := False;
     FKeepAlive := 0;
  end;
end;

procedure TRemoteCashClient.Set_LogEvents(Value: SYSINT);
begin
  if Value > 0 then
     FLogEvents := 1
  else
     FLogEvents := 0;
end;

procedure TRemoteCashClient.Set_CmdId(Value: SYSINT);
begin
  FCmdId := Value;
end;

procedure TRemoteCashClient.Set_Font(Value: SYSINT);
begin
  FFont := Value;
end;

procedure TRemoteCashClient.Set_Tax1(Value: SYSINT);
begin
  FTax1 := Value;
end;

procedure TRemoteCashClient.Set_TimeOut(Value: SYSINT);
begin
  FTimeOut := Value * 1000;
end;

procedure TRemoteCashClient.Set_Price(Value: Double);
begin
  FPrice := Value;
end;

procedure TRemoteCashClient.Set_Qty(Value: Double);
begin
  FQty := Value;
end;

procedure TRemoteCashClient.Set_RemoteIP(const Value: WideString);
begin
  FRemoteIp := Trim(WideStringToString(Value, 1251));
end;

procedure TRemoteCashClient.Set_RemotePort(Value: SYSINT);
begin
  FRemotePort := Value;
end;

procedure TRemoteCashClient.Set_SenderId(Value: SYSINT);
begin
  FSenderId := Value;
end;

procedure TRemoteCashClient.Set_Text(const Value: WideString);
begin
  FText := WideStringToString(Value, 1251);
end;

procedure TRemoteCashClient.Set_Matrix(const Value: WideString);
begin
  FMatrix := WideStringToString(Value, 1251);
  FSerial:='';
  FGTIN:='';
  FTail:='';
  ParsMarka(FMatrix, FGTIN, FSerial, FTail);
end;

procedure TRemoteCashClient.Set_Excise(Value: SYSINT);
begin
  if Value = 0 then
   FExcise := false
  else
   FExcise:=true;
end;

procedure TRemoteCashClient.Set_SNO(Value: SYSINT);
begin
 FSNO:=Value;
end;

procedure TRemoteCashClient.Set_GTIN(const Value: WideString);
begin
  FGTIN := WideStringToString(Value, 1251);
end;

procedure TRemoteCashClient.Set_Serial(const Value: WideString);
begin
  FSerial := WideStringToString(Value, 1251);
end;

procedure TRemoteCashClient.Set_tail(const Value: WideString);
begin
  FTail := WideStringToString(Value, 1251);
end;

function TRemoteCashClient.Get_OwnerWnd: SYSUINT;
begin
  Result := FOwnerWnd;
end;

function TRemoteCashClient.Get_SendRes: SYSINT;
begin
  Result := FSendRes;
end;

procedure TRemoteCashClient.Set_OwnerWnd(Value: SYSUINT);
begin
  FInternalMSGs := 1;
  FOwnerWnd := Value;
  if FOwnerWnd = THandle(-1) then
     FOwnerWnd := 0;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TRemoteCashClient, Class_CRemoteCashClient, ciMultiInstance, tmApartment);
  Randomize;
finalization

end.
