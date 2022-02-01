unit sEquipment;
                                      
interface

uses
  Windows, Forms, ComObj, IniFiles, Classes, SysUtils, CPort, libmerc;

type

  Trs232ScanBar = class(TComponent)
    public
      sc1Prefix: string;
      sc1Suffix: string;
      sc1Data: string;
      cpCom1: TComPort;
      cfcCom1: TComFlowControl;
      InitOk: Bool;
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
      procedure ComPortRxChar(Sender: TObject; Count: Integer);
  end;

  TServicePrint = class(TComponent)
    public
      ovObject: OLEVariant;
      LineLength: Byte;
      WideLineLen: Byte;
      InitOk: Bool;
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
      function Setup(SvrIP:string; SvrPort, Port, Baud: Word; Beep: Bool): Bool;
      function CheckFRResult(sOption: string): Bool;
      function FeedPaper(iLines: Byte): Bool;
      function PrintString(sLine: string): Bool;
      function PrintWideString(sLine: string): Bool;
  end;

  TVariantPrint = class(TComponent)
    private
      FCashierName:string; //������� �������
    public
      ovObject: OLEVariant;
      ocObject: TocMercury;
      FsModel: string;
      LineLength: Byte;
      WideLineLen: Byte;
      Tax1: Byte;
      InitOk: Bool;
      iLastNDoc: Integer;
      Change: Currency;
      ifSetup: TIniFile;
      IV: Integer;   // Mercury ONLY
      bIsFisc: Bool; // Mercury ONLY
      iLastDepartment: Integer;
//      slDepart2Tax: TStrings;
//      baTaxType: array of byte;
      //DocIsActive: Bool;
      constructor Create(AOwner: TComponent; sModel: string); virtual;
      destructor Destroy; override;
      function Setup(ifMain: TIniFile): Bool;
      function CheckFRResult(sOption: string): Bool;
      function CheckFRStateBegin: Bool;
      function CheckFRAdvancedMode(wTimeOut: Word; sCheckSection: string): Bool;
      procedure CancelDoc;
      function DrawImage: Bool;
      function OpenDrawer: Bool;
      function Cut: Bool;
      function FeedPaper(iLines: Byte): Bool;
      function Continue: Bool;
      function OpenSession(sSysOpNm: string): Bool;
      function MSPrintTitle(sLine: string; bSubType: Byte): Bool;
      function MMSKPrintTitle(sLine: string; SubType: Byte): Bool;
      property CashierName:string read FCashierName write FCashierName;
      function PrintString(sLine: string): Bool;
      function PrintWideString(sLine: string): Bool;
      function IsFFD12():boolean;
      function CheckMarkOnServer(returnCheck:boolean; matrix, gtin, serial, tail:string):integer;
      function Sale(returnCheck:boolean; sLine: string; cQty: Currency; cPrice: Currency; iDepartment, iTaxIx: Integer;
                    datamatrix, gtin, serial, tail:string; excise:boolean; sno:integer; Validation_result:integer;
                    VersFFD12:boolean): Bool;
      function SaleCredit(sLine: string; cQty: Currency; cPrice: Currency): Bool;
      function ReturnSale(sLine: string; cQty: Currency; cPrice: Currency; iDepartment,
                          iTaxIx: Integer; datamatrix, gtin, serial, tail:string; excise:boolean; sno:integer): Bool;
      function CloseCheck(sLine: string; cSum: Currency; cExact: Currency; TPayment, Tax: Integer): Bool;
//      function CloseCheck(sLine: string; cSum: Currency; cExact: Currency; bSaleCredit: Bool): Bool;
      function CashIncome(sLine: string; cSum: Currency): Bool;
      function CashOutcome(sLine: string; cSum: Currency): Bool;
      function Report(bClearing:Bool): Bool;
      function DReport(bClearing:Bool): Bool;
      function GetDocIsActive: Bool; // MMSKVCL ONLY, all another is always true
      function DepartReport(): Bool;
      function FNSendCustomerTel(sLine: string): Bool;
      function FNSendCustomerEml(sLine: string): Bool;
      function FNSendCustomerINN(sLine: string): Bool;
      function FNSendCashFam(sLine: string): Bool;
      function FNSendCustomerNm(sLine: string): Bool;
      function WaitForPrinting(): Bool;
  end;

implementation

uses sMF, sDM, hUsrAuth, sSF;

{*******************************************************************************}
{                                SCAN EQUIPMENT                                 }
{*******************************************************************************}

constructor Trs232ScanBar.Create(AOwner: TComponent);
var sPortName: string;

  procedure SetComFlowControl;
  begin
    //FcpCom1.TriggersOnRxChar := False;
    //FcpCom1.
    with cpCom1 do begin
             //  evRxChar, evTxEmpty, evRxFlag, evRing, evBreak, evCTS, evDSR, evError, evRLSD, evRx80Full
      Events := [evRxChar, evError]; //, evTxEmpty
      //SyncMethod := smWindowSync;
      //SyncMethod := smNone;
      FlowControl.ControlDTR := dtrDisable;
      FlowControl.ControlRTS := rtsDisable;
      FlowControl.OutCTSFlow := False;
      FlowControl.OutDSRFlow := False;
      FlowControl.XonXoffOut := False;
      FlowControl.XonXoffIn := False;
      OnRxChar := ComPortRxChar;
    end;
  end;

begin
  inherited Create(AOwner);
  initOk := False;
  sc1Prefix := hstr2str(TsfMF(AOwner).ifMain.ReadString('BarCode','Prefix',''));
  sc1Suffix := hstr2str(TsfMF(AOwner).ifMain.ReadString('BarCode','Suffix','0x000D 0x000A'));
  sPortName := TsfMF(AOwner).ifMain.ReadString('BarCode','Port','');
  if Length(sPortName) > 0 then begin
     cpCom1 := TComPort.Create(Self);
     with cpCom1 do begin
        Port := sPortName;
        case TsfMF(AOwner).ifMain.ReadInteger('BarCode','Baud',1) of
           0: BaudRate := br110;
           1: BaudRate := br300;
           2: BaudRate := br600;
           3: BaudRate := br1200;
           4: BaudRate := br2400;
           5: BaudRate := br4800;
           6: BaudRate := br9600;
           7: BaudRate := br14400;
           8: BaudRate := br19200;
           9: BaudRate := br38400;
          10: BaudRate := br56000;
          11: BaudRate := br57600;
          12: BaudRate := br115200;
        end;
        SetComFlowControl;
        try
          Open;
        finally
        end;
        if Connected then
           initOk := True;
     end;
  end else
     initOk := True;
end;

destructor Trs232ScanBar.Destroy;
begin
  if Assigned(cpCom1) then
     FreeAndNil(cpCom1);
  inherited Destroy;
end;

procedure Trs232ScanBar.ComPortRxChar(Sender: TObject; Count: Integer);
var
  sData: String;
  sBCString: string;
  bBOPkt, bEOPkt: Bool;
  wVirtKey: Word;
  bMgrAuthFlag: Bool;

begin
  bEOPkt := False; bBOPkt := False; sBCString := '';

  if Count = 0 then
    Exit;

  cpCom1.ReadStr(sData, Count);

  sC1Data := sC1Data + sData;

  if (sC1Prefix='') or (Pos(sC1Prefix, sC1Data)<>0) then
     bBOPkt:=True;
  if (sC1Suffix='') or (Pos(sC1Suffix, sC1Data)<>0) then
     bEOPkt:=True;

  if bBOPkt and bEOPkt then begin
     sBCString := Copy(sC1Data, Pos(sC1Prefix, sC1Data) + Length(sC1Prefix), Pos(sC1Suffix, sC1Data) - Length(sC1Prefix) - 1);
//        Delete(sC1Data, 1, Pos(sC1Suffix, sC1Data) + Length(sC1Suffix) - 1);

     if Length(sBCString) <> 0 then begin

        if (hfUsrAuth <> nil) then                                             // ����������� ���������
           if hfUsrAuth.Visible then begin
              hfUsrAuth.sBarcode := sBCString;
              hfUsrAuth.aBarCodeSend.Execute;
              sData := '';
              sC1Data := '';
              Exit;
           end;

        if sfMF.neCash.Focused then                                            // ���������� �����
           with sfMF do begin
             sDCNumber := sBCString;
             aSetDiscountExecute(nil);
             sC1Data := '';
             sData := '';
             Exit;
           end;

        if sfMF.dsItemBuf.Active then                                               // ��������
           sfMF.udpFillDocument(False);
        sfMF.eCode.Value := sBCString;
        sfMF.udpFillBuffer(imfBarCode);
        sfMF.iItemMethodSelect := 0;

     end;

     sC1Data := '';

  end;

  if Length(sC1Data) > $7F then
     sC1Data := '';

end;

{*******************************************************************************}
{                            ServicePRINT EQUIPMENT                             }
{*******************************************************************************}

constructor TServicePrint.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  InitOk := False;

  try
    ovObject := CreateOleObject('AddIn.S500Drv');
  finally
    InitOk := True;
  end;

end;

destructor TServicePrint.Destroy;
begin
  ovObject := 0;
  inherited Destroy;
end;

function TServicePrint.Setup(SvrIP:string; SvrPort, Port, Baud: Word; Beep: Bool): Bool;
const sOption: string = ':: ServiceSetup ::';
begin
  Setup := False;
  LineLength := 32;
  WideLineLen := 16;
  try
    ovObject.ComNumber := Port;
    ovObject.BaudRate  := Baud;
    ovObject.ConnectionType := 1;
    ovObject.ComputerName := SvrIP;
    ovObject.TCPPort := SvrPort;
    ovObject.ServerConnect;
    ovObject.Connect;
    if Beep then
      ovObject.Beep;
  finally
    if CheckFRResult(sOption) then
       Setup := True;
  end;
end;

function TServicePrint.CheckFRResult(sOption: string): Bool;
var sResMsg, sResMsg2: string;
begin

  CheckFRResult := True;
  exit;
  if (ovObject.ResultCode <> 0) then begin

     sResMsg := IntToStr(ovObject.ResultCode) + sOption;

     sResMsg := sResMsg + ovObject.ResultCodeDescription;
     sResMsg2 := ovObject.ECRModeDescription;

     WriteLogFile(sResMsg + ' :: ' + sResMsg2);
     sfMF.AddSingleResultEvent(57, 41, sResMsg, sResMsg2);
  end;

end;

function TServicePrint.FeedPaper(iLines: Byte): Bool;
begin
  FeedPaper := False;
  ovObject.StringQuantity := iLines;
  try
    ovObject.FeedDocument;
  finally
    Sleep(100);
    FeedPaper := True;
  end;

end;

function TServicePrint.PrintString(sLine: string): Bool;
const sOption: string = ':: PrintString ::';
begin
  PrintString := true;
  exit;
  try
    ovObject.StringForPrinting := sLine;
    ovObject.PrintString;
  finally
    if CheckFRResult(sOption) then
       PrintString := True;
  end;
end;

function TServicePrint.PrintWideString(sLine: string): Bool;
const sOption: string = ':: PrintWideString ::';
begin
  PrintWideString := False;
  try
    ovObject.StringForPrinting := sLine;
    ovObject.PrintWideString;
  finally
    if CheckFRResult(sOption) then
       PrintWideString := True;
  end;

end;


{*******************************************************************************}
{                               PRINT EQUIPMENT                                 }
{*******************************************************************************}

constructor TVariantPrint.Create(AOwner: TComponent; sModel: string);
begin
  inherited Create(AOwner);

  InitOk := False;
  FsModel := sModel;

  if sModel = 'Atol10' then begin
     try
       ovObject := CreateOleObject('AddIn.Fptr10');
     finally
       //ovObject.UseJournalRibbon := 0;
       //ovObject.UseSlipDocument  := 0;
       //ovObject.UseReceiptRibbon := 1;
       InitOk := True;
     end;
  end;

  if sModel = 'Shtrih' then begin
     try
       ovObject := CreateOleObject('AddIn.DrvFR');
     finally
       ovObject.UseJournalRibbon := 0;
       ovObject.UseSlipDocument  := 0;
       ovObject.UseReceiptRibbon := 1;
       InitOk := True;
     end;
  end;

  if sModel = 'MStar' then begin
     try
       ovObject := CreateOleObject('mstar.DrvMStar');
     finally
       InitOk := True;
     end;
  end;

  if sModel = 'Felix02' then begin
     try
       ovObject := CreateOleObject('AddIn.FprnM45');
     finally
       InitOk := True;
     end;
  end;

  if sModel = 'Mercury' then begin
     try
       ovObject := CreateOleObject('AddIn.MercuryFPrt1C');
     finally
       InitOk := True;
     end;
  end;

  if sModel = 'S500N' then begin
     try
       ovObject := CreateOleObject('AddIn.S500Drv');
     finally
       InitOk := True;
     end;
  end;

  if sModel = 'MercuryVCL' then begin
     ocObject := TocMercury.Create(Self);
     InitOk := True;
  end;

end;

destructor TVariantPrint.Destroy;
begin

  if FsModel = 'Felix02' then begin
     ovObject := 0;
  end;


  if FsModel = 'MStar' then begin
     try
       ovObject.Disconnect;
     finally

     end;
     ovObject := 0;
  end;

  if Assigned(ocObject) then
     ocObject.Free;

  inherited Destroy;
end;

function TVariantPrint.CheckFRResult(sOption: string): Bool;
var sResMsg, sResMsg2: string;
    //receiptType:integer;
begin

  CheckFRResult := False;
  CheckFRResult:=true;
  exit;

  if Assigned(ocObject) then begin
     if (ocObject.ResultCode <> 0) then begin
        sResMsg := IntToStr(ocObject.ResultCode) + sOption + ocObject.ResultCodeDescription;
        sResMsg2 := '';
        WriteLogFile(sResMsg + ' :: ' + sResMsg2);
        sfMF.AddSingleResultEvent(57, 41, sResMsg, sResMsg2);
     end else
        CheckFRResult := True;
     Exit;
  end;

  if (FsModel = 'Mercury') then begin
     if (ovObject.ErrCode <> 0) then begin
       sResMsg := IntToStr(ovObject.ErrCode) + sOption + ovObject.ErrMessage;
       sResMsg2 := '';
       WriteLogFile(sResMsg + ' :: ' + sResMsg2);
       sfMF.AddSingleResultEvent(57, 41, sResMsg, sResMsg2);
     end else
       CheckFRResult := True;
     Exit;
  end;

  if (FsModel = 'Atol10') then begin
    if ovObject.errorCode <> ovObject.LIBFPTR_OK then begin
      sResMsg := sResMsg + IntToStr(ovObject.errorCode);
      sResMsg := sResMsg + ovObject.errorDescription;

    	//ovObject.setParam(ovObject.LIBFPTR_PARAM_DATA_TYPE, ovObject.LIBFPTR_DT_RECEIPT_STATE);
  	  //ovObject.queryData;
    	//receiptType:=ovObject.getParamInt(ovObject.LIBFPTR_PARAM_RECEIPT_TYPE);
    	//if receiptType <> ovObject.LIBFPTR_RT_CLOSED then
  	  //	ovObject.cancelReceipt();
      //sResMsg2 := ovObject.ECRModeDescription + ' :: ' + ovObject.ECRAdvancedModeDescription;
      sResMsg2 := '';
      WriteLogFile(sResMsg + ' :: ' + sResMsg2);
      sfMF.AddSingleResultEvent(57, 41, sResMsg, sResMsg2);
    end else
      CheckFRResult := True;
    exit;
  end;

  if (ovObject.ResultCode <> 0) then begin

     sResMsg := IntToStr(ovObject.ResultCode) + sOption;

     if (FsModel = 'Shtrih') then begin
       sResMsg := sResMsg + ovObject.ResultCodeDescription;
       sResMsg2 := ovObject.ECRModeDescription + ' :: ' + ovObject.ECRAdvancedModeDescription;
     end;

     if (FsModel = 'MStar') then begin
       sResMsg := sResMsg + ovObject.ResultCodeDescription;
       sResMsg2 := '';
     end;

     if (FsModel = 'Felix02') then begin
       sResMsg := sResMsg + ovObject.ResultCodeDescription;
       sResMsg2 := '';
     end;

     if (FsModel = 'S500N') then begin
       sResMsg := sResMsg + ovObject.ResultCodeDescription;
       sResMsg2 := ovObject.ECRModeDescription;
     end;

     WriteLogFile(sResMsg + ' :: ' + sResMsg2);
     sfMF.AddSingleResultEvent(57, 41, sResMsg, sResMsg2);
  end else
     CheckFRResult := True;
end;

function TVariantPrint.Setup(ifMain: TIniFile): Bool;
  const sOption: string = ':: FRSetup ::';
  var i: Integer;
      ComIsIP:boolean;
      baudRate, resBoudRate:integer;
begin
  Setup := False;
  ifSetup := ifMain;
  bIsFisc := False;
  ComIsIP:=false;

  if (FsModel = 'Atol10') then begin
     LineLength := 36;
     WideLineLen := 18;
     if Pos('.', ifMain.ReadString('FRCash', 'Port', 'localhost')) > 0 then
      ComIsIP:=true;
     try
 	     ovObject.setSingleSetting(ovObject.LIBFPTR_SETTING_MODEL, ovObject.LIBFPTR_MODEL_ATOL_AUTO);
       if ComIsIP then begin
		    ovObject.setSingleSetting(ovObject.LIBFPTR_SETTING_PORT, ovObject.LIBFPTR_PORT_TCPIP);
       	ovObject.setSingleSetting(ovObject.LIBFPTR_SETTING_IPADDRESS, ifMain.ReadString('FRCash', 'Port', 'localhost'));
       	ovObject.setSingleSetting(ovObject.LIBFPTR_SETTING_IPPORT, 5555);
       	ovObject.applySingleSettings;
       end else begin
       	ovObject.setSingleSetting(ovObject.LIBFPTR_SETTING_PORT, ovObject.LIBFPTR_PORT_COM);
       	//ovObject.setSingleSetting(ovObject.LIBFPTR_SETTING_COM_FILE, IntToStr(ifMain.ReadInteger('FRCash', 'Port', 1)));
        ovObject.setSingleSetting(ovObject.LIBFPTR_SETTING_COM_FILE, ifMain.ReadString('FRCash', 'Port', '1'));
        baudRate:=ifMain.ReadInteger('FRCash', 'Baud', 6);
        resBoudRate:=ovObject.LIBFPTR_PORT_BR_115200;
        case baudRate of
         0: resBoudRate:=ovObject.LIBFPTR_PORT_BR_2400;
         1: resBoudRate:=ovObject.LIBFPTR_PORT_BR_4800;
         2: resBoudRate:=ovObject.LIBFPTR_PORT_BR_9600;
         3: resBoudRate:=ovObject.LIBFPTR_PORT_BR_19200;
         4: resBoudRate:=ovObject.LIBFPTR_PORT_BR_38400;
         5: resBoudRate:=ovObject.LIBFPTR_PORT_BR_57600;
         6: resBoudRate:=ovObject.LIBFPTR_PORT_BR_115200;
         1200: resBoudRate:=ovObject.LIBFPTR_PORT_BR_1200;
         2400: resBoudRate:=ovObject.LIBFPTR_PORT_BR_2400;
         4800: resBoudRate:=ovObject.LIBFPTR_PORT_BR_4800;
         9600: resBoudRate:=ovObject.LIBFPTR_PORT_BR_9600;
         19200: resBoudRate:=ovObject.LIBFPTR_PORT_BR_19200;
         38400: resBoudRate:=ovObject.LIBFPTR_PORT_BR_38400;
         57600: resBoudRate:=ovObject.LIBFPTR_PORT_BR_57600;
         115200: resBoudRate:=ovObject.LIBFPTR_PORT_BR_115200;
         230400: resBoudRate:=ovObject.LIBFPTR_PORT_BR_230400;
         460800: resBoudRate:=ovObject.LIBFPTR_PORT_BR_460800;
         921600: resBoudRate:=ovObject.LIBFPTR_PORT_BR_921600;
        end;
       	ovObject.setSingleSetting(ovObject.LIBFPTR_SETTING_BAUDRATE, IntToStr(resBoudRate));
       	ovObject.applySingleSettings;
       end;
       //ovObject.ComNumber := ifMain.ReadInteger('FRCash', 'Port', 1);
       //ovObject.BaudRate  := ifMain.ReadInteger('FRCash', 'Baud', 6);
       //ovObject.Password  := ifMain.ReadInteger('FRCash', 'Password', 30);
       ovObject.open;
       ovObject.Beep;
     finally
       sleep(100);
       if CheckFRResult(sOption) then
          Setup := True;
     end;

  end;

  if (FsModel = 'Shtrih') then begin
//     ifMain.ReadSection('TaxType', slDepart2Tax);
//    for i := 0 to ts.Count - 1 do begin
//    end;
     LineLength := 36;
     WideLineLen := 18;
     try
       ovObject.ComNumber := ifMain.ReadInteger('FRCash', 'Port', 1);
       ovObject.BaudRate  := ifMain.ReadInteger('FRCash', 'Baud', 5);
       ovObject.Password  := ifMain.ReadInteger('FRCash', 'Password', 30);
       ovObject.Connect;
       ovObject.Beep;
     finally
       sleep(100);
       if CheckFRResult(sOption) then
          Setup := True;
     end;

  end;

  if (FsModel = 'MStar') then begin
     LineLength := 40;
     WideLineLen := 20;
     try
       ovObject.TitleStringsCount := ifMain.ReadInteger('FRCash', 'Titles', 4);
       ovObject.ComNumber := ifMain.ReadInteger('FRCash', 'Port', 1);
       ovObject.BaudRate  := ifMain.ReadInteger('FRCash', 'Baud', 57600);
       ovObject.Password  := ifMain.ReadString ('FRCash', 'Password', '0000');
       ovObject.TimeOut := 2000;
       ovObject.Connect;
     finally
       if CheckFRResult(sOption) then
          Setup := True;
     end;

  end;

  if (FsModel = 'Felix02') then begin
     LineLength := 20;
     WideLineLen := 10;
     try
       ovObject.TextWrap := 1;
       ovObject.Password  := ifMain.ReadString ('FRCash', 'Password', '30');
       ovObject.DeviceEnabled := true;
     finally
       sleep(100);
       if CheckFRResult(sOption) then
          Setup := True;
     end;

  end;

  if (FsModel = 'Mercury') then begin
     LineLength := 40;
     WideLineLen := 20;

     try
        ovObject.PortNum := ifMain.ReadInteger('FRCash', 'Port', 1);
        case ifMain.ReadInteger('FRCash', 'Baud', 2) of
          0: ovObject.BaudRate := CBR_9600;
          1: ovObject.BaudRate := CBR_19200;
          2: ovObject.BaudRate := CBR_57600;
          3: ovObject.BaudRate := CBR_115200;
        end;
        ovObject.Password  := ifMain.ReadString ('FRCash', 'Password', '0000');
        ovObject.Open;
     finally
       sleep(100);
       if CheckFRResult(sOption) then
          Setup := True;
     end;

     if ovObject.Active then begin
        ovObject.SetAutocut(True);
        ovObject.OpenDay(0, '������1', True, 0);
     end else begin
        Setup := False;
     end;

  end; // Mercury Setup

  if (FsModel = 'S500N') then begin
     LineLength := 32;
     WideLineLen := 16;
     try
       ovObject.ComNumber := ifMain.ReadInteger('FRCash','Port',1);
       ovObject.BaudRate  := ifMain.ReadInteger('FRCash', 'Baud', 5);
       ovObject.ConnectionType := 1;
       ovObject.ComputerName := ifMain.ReadString('FRCash','SvrIP','127.0.0.1');
       ovObject.TCPPort := ifMain.ReadInteger('FRCash', 'SvrPort', 211);
       ovObject.ServerConnect;
       ovObject.Connect;
       ovObject.Beep;
     finally
       if CheckFRResult(sOption) then
          Setup := True;
     end;
  end;

  if Assigned(ocObject) then begin // MecruryVCL
     LineLength := 40;
     WideLineLen := 20;
     ocObject.TitleStringsCount := ifMain.ReadInteger('FRCash', 'Titles', 4);
     ocObject.PortName := ifMain.ReadString('FRCash', 'Port', '');
     ocObject.BaudRate := ifMain.ReadInteger('FRCash', 'Baud', 6);
     ocObject.Password := ifMain.ReadString ('FRCash', 'Password', '0000');
     ocObject.TimeOut := 2000;
     ocObject.Connect;

     if ocObject.Connected then begin
        ocObject.Operator := '������1';
        ocObject.OperNumber :=  1;
        ocObject.OpenSession; // auto
        Setup := True;
     end else begin
        Setup := False;
     end;
  end;

end;

function TVariantPrint.CheckFRStateBegin: Bool;
const sOption: string = ':: CheckFRState ::';
var sUserQuestion: string;
begin

  Result := true;
  exit;

  if FsModel = 'Atol10' then begin
  	//ovObject.setParam(ovObject.LIBFPTR_PARAM_DATA_TYPE, ovObject.LIBFPTR_DT_RECEIPT_STATE);
  	//ovObject.queryData;
  	//receiptType:=ovObject.getParamInt(ovObject.LIBFPTR_PARAM_RECEIPT_TYPE);
  	//if receiptType <> ovObject.LIBFPTR_RT_CLOSED then
  	//	ovObject.cancelReceipt();
    Result := True;
  end;

  if (FsModel = 'Shtrih') then begin

     while Result = False do begin

       try
         ovObject.GetECRStatus;
       finally
         CheckFRResult(sOption);
       end;

       if ovObject.ECRMode = 8 then begin
          sUserQuestion := '������ ������ ��������� ����������.'#$D#$A +
                           '��������� ��:' + ovObject.ECRModeDescription +
                           '/' + ovObject.ECRAdvancedModeDescription + #$D#$A +
                           '��������, ��� ����������� ���������� ��������'#$D#$A +
                           '���������� ������������� ��������.';
          if Application.MessageBox(PChar(sUserQuestion), '�������������� ��', $30 + MB_OKCANCEL) = idOk then begin
             try
               ovObject.CancelCheck;
             finally
               CheckFRResult(':: CancelCheck inside CheckResult ::');
               Result := True;
             end;
          end else begin
             Break;
          end;
       end else begin
         Result := True;
       end; // if

     end; // while

  end; // FsModel Shtrih

  if (FsModel = 'MStar') then begin
     Result := True;
  end;
  if (FsModel = 'Felix02') then begin
     Result := True;
  end;
  if (FsModel = 'Mercury') then begin
      while Result = False do begin
        try
          ovObject.QueryLastDocInfo;
        finally
          CheckFRResult(sOption);
        end;

        if ovObject.ConnState <> 1 then begin  // non-idle

          sUserQuestion := '������ ������ ��������� ����������.'#$D#$A +
                           '��������� ��:' + ovObject.ErrMessage + #$D#$A +
                           '��������, ��� ����������� ���������� ��������'#$D#$A +
                           '���������� ������������� ��������.';
           if Application.MessageBox(PChar(sUserQuestion), '�������������� ��', $30 + MB_OKCANCEL) = idOk then begin
              try
                ovObject.CancelCheck;
              finally
                CheckFRResult(':: CancelCheck inside CheckResult ::');
                Result := True;
              end;
           end else begin
              Break;
           end;
        end else begin
          Result := True;
        end; // if

      end; // while
     Result := True;
  end;
  if (FsModel = 'S500N') then begin
     Result := True;
  end;
  if Assigned(ocObject) then begin
     while Result = False do begin
        try
          ocObject.GetECRStatus;
        finally
          CheckFRResult(sOption);
        end;

        if (ocObject.lmECRState <> 0) or (ocObject.lmPrintState <> 0) then begin  // non-idle
           sUserQuestion := '������ ������ ��������� ����������.'#$D#$A +
                            '��������� ��:' + ocObject.EcrStateDescr + ocObject.PrinterStateDescr + #$D#$A +
                            '��������, ��� ����������� ���������� ��������'#$D#$A +
                            '���������� ������������� ��������.';
           if Application.MessageBox(PChar(sUserQuestion), '�������������� ��', $30 + MB_OKCANCEL) = idOk then begin
              try
                ocObject.CancelCheck;
              finally
                CheckFRResult(':: CancelCheck inside CheckResult::');
                if Application.MessageBox('���������� �������� ������ ?', '�������������� ��', $30 + MB_OKCANCEL) = idOk then begin
                   MSPrintTitle('', $FF);
                   Result := True;
                end;
              end;
           end else begin
              Break;
           end;
        end else begin
           Result := True;
        end; // if
     end; // while
  end;

end; // proc

function TVariantPrint.CheckFRAdvancedMode(wTimeOut: Word; sCheckSection: string): Bool;
var
  sUserQuestion: string;
  receiptType:integer;
begin
  Result := true;
  exit;

  if FsModel = 'Atol10' then begin
  	//ovObject.setParam(ovObject.LIBFPTR_PARAM_DATA_TYPE, ovObject.LIBFPTR_DT_RECEIPT_STATE);
  	//ovObject.queryData;
  	//receiptType:=ovObject.getParamInt(ovObject.LIBFPTR_PARAM_RECEIPT_TYPE);
  	//if receiptType <> ovObject.LIBFPTR_RT_CLOSED then
  	//	ovObject.cancelReceipt();
    Result := True;
  end;

  if (FsModel = 'Shtrih') then begin

     while Result = False do begin

       CheckFRResult('::' + sCheckSection + '::');

       sleep(wTimeOut);

       Application.ProcessMessages;

       ovObject.GetECRStatus;

       case ovObject.ECRMode of
         3: begin
              sUserQuestion := '������ ��������� ����������.'#$D#$A +
                               '��������� ��:' + ovObject.ECRModeDescription + #$D#$A +
                               '��� ����������� ������ ���������� ������� �����.';
              Application.MessageBox(PChar(sUserQuestion), '������ ��', $10);
              Break;
            end;
         5, 6, 7, 9, 10:
            begin
              sUserQuestion := '������ ��������� ����������.'#$D#$A +
                               '��������� ��:' + ovObject.ECRModeDescription + #$D#$A +
                               '��������, ��������� ����� ������������ �����������.';
              Application.MessageBox(PChar(sUserQuestion), '������ ��', $10);
              Break;
            end;
       end;

       case ovObject.ECRAdvancedMode of
         0: Result := True;
       1,2: begin
             sUserQuestion := '������ ��������� ��������������.'#$D#$A +
                              '��������� ��:' + ovObject.ECRAdvancedModeDescription + #$D#$A +
                              '��� ����������� ���������� ���������'#$D#$A +
                              '�������������, ����� ������ "����������"';
             if Application.MessageBox(PChar(sUserQuestion), '�������������� ��', $30 + MB_RETRYCANCEL) = idRetry then begin
                try
                  ovObject.ContinuePrint;
                finally
                  CheckFRResult(':: ContPrint inside CheckAdvMode ::');
   //               Result := True;
                end;
             end else begin
                Break;
             end;
            end; // if
         3: try
              ovObject.ContinuePrint;
            finally
              CheckFRResult(':: ContPrint inside CheckAdvMode ::');
              Result := True;
            end;
       end; // case

     end; // while

  end; // FsModel Shtrih

  if (FsModel = 'MStar') then begin
     Result := True;
  end;
  if (FsModel = 'Felix02') then begin
     Result := True;
  end;
  if (FsModel = 'Mercury') then begin
     Result := True;
  end;
  if (FsModel = 'S500N') then begin
     Result := True;
  end;
  if Assigned(ocObject) then begin
     Result := True;
  end;

end; // proc


procedure TVariantPrint.CancelDoc;
const sOption: string = ':: CancelDoc ::';
var bCashErr: Bool;
begin

  if (FsModel = 'Atol10') then begin
     try
       ovObject.cancelReceipt;
     finally
     end;
     if not CheckFRAdvancedMode(100, sOption) then
        Exit;
  end;

  if (FsModel = 'Shtrih') then begin
     try
       ovObject.CancelCheck;
     finally
     end;
     if not CheckFRAdvancedMode(100, sOption) then
        Exit;
  end;

  if (FsModel = 'MStar') then begin
     try
       ovObject.CancelCheck;
     finally
       bCashErr := not CheckFRResult(sOption);
     end;

     if not bCashErr then
        try
          ovObject.StringQuantity := 6;
          ovObject.FeedDocument;
        finally
          CheckFRResult(':: FeedDoc ::');
        end;
  end;

  if (FsModel = 'Felix02') then begin
     try
       ovObject.CancelCheck;
     finally
       sleep(100);
       CheckFRResult(sOption);
     end;
  end;

  if (FsModel = 'Mercury') then begin
     bIsFisc := False;
     try
       ovObject.CancelFiscalDoc(False);
     finally
       sleep(100);
       CheckFRResult(sOption);
     end;
  end;

  if Assigned(ocObject) then begin
     bIsFisc := False;
     ocObject.CancelCheck;
     sleep(100);
     CheckFRResult(sOption);
  end;

end;

function TVariantPrint.DrawImage: Bool;
begin
  DrawImage := False;

  if (FsModel = 'Atol10') then begin
    
  end;

  if (FsModel = 'Shtrih') then begin
     try
       ovObject.FirstLineNumber := 1;
       ovObject.LastLineNumber := 64;
       ovObject.Draw;
     finally
       DrawImage := True;
     end;
  end;

  if (FsModel = 'S500N') then begin
     try
       ovObject.FirstLineNumber := 1;
       ovObject.LastLineNumber := 62;
       ovObject.Draw;
     finally
       DrawImage := True;
     end;
  end;
end;

function TVariantPrint.OpenDrawer: Bool;
begin
  OpenDrawer := False;

  if (FsModel = 'Atol10') then begin
    try
      ovObject.openDrawer;
    finally
      OpenDrawer := True;
    end;
  end;

  if (FsModel = 'Shtrih') then begin
     try
       ovObject.OpenDrawer;
     finally
       OpenDrawer := True;
     end;
  end;

  if (FsModel = 'MStar') then begin
     try
       ovObject.OpenDrawer;
     finally
       OpenDrawer := True;
     end;
  end;

  if (FsModel = 'Felix02') then begin
     try
       ovObject.OpenDrawer;
     finally
       Sleep(100);
       OpenDrawer := True;
     end;
  end;

  if (FsModel = 'Mercury') then begin
     try
       ovObject.ExternalPulse(1, 5, 5, 2);
     finally
       Sleep(100);
       OpenDrawer := True;
     end;
  end;

  if Assigned(ocObject) then begin
     ocObject.OpenDrawer;
     Sleep(100);
     OpenDrawer := True;
  end;

end;

function TVariantPrint.Cut: Bool;
begin
  Cut := False;

  if (FsModel = 'Atol10') then begin
     try
       ovObject.Cut;
     finally
       Sleep(100);
       Cut := True;
     end;
  end;

  if (FsModel = 'Shtrih') then begin
     try
       ovObject.CutCheck;
     finally
       Sleep(100);
       Cut := True;
     end;
  end;

  if (FsModel = 'Mercury') then begin
     try
//       ovObject.PrintNonFiscal('', False, True);
       if ovObject.Generation >= 2 then
         ovObject.FeedAndCut(1, True);
     finally
       Sleep(100);
       Cut := True;
     end;
  end;

  if Assigned(ocObject) then begin
     ocObject.Cut;
     Sleep(100);
     Cut := True;
  end;

end;

function TVariantPrint.FeedPaper(iLines: Byte): Bool;
begin
  FeedPaper := False;

  if (FsModel = 'Atol10') then begin
     try
       ovObject.lineFeed;
     finally
       Sleep(100);
       FeedPaper := True;
     end;
  end;

  if (FsModel = 'Shtrih') then begin
     ovObject.StringQuantity := iLines;
     try
       ovObject.FeedDocument;
     finally
       Sleep(100);
       FeedPaper := True;
     end;
  end;

  if (FsModel = 'MStar') then begin
     ovObject.StringQuantity := iLines;
     try
       ovObject.FeedDocument;
     finally
       Sleep(100);
       FeedPaper := True;
     end;
  end;

  if (FsModel = 'S500N') then begin
     ovObject.StringQuantity := iLines;
     try
       ovObject.FeedDocument;
     finally
       Sleep(100);
       FeedPaper := True;
     end;
  end;

  if (FsModel = 'Mercury') then begin
     try
//       ovObject.PrintNonFiscal('', False, True);
       if ovObject.Generation >= 2 then
         ovObject.FeedAndCut({iLines}1, False);
     finally
       Sleep(100);
       FeedPaper := True;
     end;
  end;

  if Assigned(ocObject) then begin
     ocObject.FeedDocument;
     Sleep(100);
     FeedPaper := True;
  end;

end;


function TVariantPrint.Continue: Bool;
begin
  Continue := False;

  if (FsModel = 'Atol10') then begin
     try
       ovObject.continuePrint;
     finally
       sfMF.AddSingleResultEvent(54, 56, '������ ���������� ����� ������.', '');
     end;

     if not CheckFRAdvancedMode(100, 'ContPrint') then                         // �������� ����� ������
       Exit;
  end;

  if (FsModel = 'Shtrih') then begin
     try
       ovObject.ContinuePrint;
     finally
       sfMF.AddSingleResultEvent(54, 56, '������ ���������� ����� ������.', '');
     end;

     if not CheckFRAdvancedMode(100, 'ContPrint') then                         // �������� ����� ������
       Exit;
  end;

  if (FsModel = 'MStar') then begin
     sfMF.AddSingleResultEvent(54, 56, '������ ������� �� ������������� ��� �� ���������� ����.', '');
  end;

  if (FsModel = 'Felix02') then
     try
       ovObject.ResetMode;
     finally
       Sleep(100);
       sfMF.AddSingleResultEvent(54, 56, '������ ���������� ����� ������.', '');
     end;

  if (FsModel = 'Mercury') then begin
     sfMF.AddSingleResultEvent(54, 56, '������ ������� �� ������������� ��� �� ���������� ����.', '');
  end;

  if Assigned(ocObject) then begin
     sfMF.AddSingleResultEvent(54, 56, '������ ������� �� ������������� ��� �� ���������� ����.', '');
  end;

  Continue := True;
end;

function TVariantPrint.OpenSession(sSysOpNm: string): Bool;
const sOption: string = ':: Open Session ::';
begin
  WriteLogFile('OpenSession+');
  OpenSession := False;
  if (FsModel = 'MStar') then begin
    ovObject.OperatorNumber := 1;
    ovObject.OperatorName := '������1';
//    sfMF.LUsername.Caption := ovObject.OperatorName;
    try
      ovObject.OpenSession;
    finally
      if CheckFRResult(sOption) then
         OpenSession := True;
    end;
  end;

  if (FsModel = 'Mercury') then begin
    try
      if ovObject.Active then begin
         ovObject.SetAutocut(True);
         ovObject.OpenDay(0, '������1', True, 0);
      end;
    finally
      if CheckFRResult(sOption) then
         OpenSession := True;
    end;
  end; // Mercury

  if Assigned(ocObject) then begin
     ocObject.Operator := '������1';
     ocObject.OperNumber :=  1;
     ocObject.OpenSession;
     if CheckFRResult(sOption) then
        OpenSession := True;
  end; // MercuryVCL

  if FsModel = 'Atol10' then begin
     try
       ovObject.setParam(1021, sSysOpNm);
       //ovObject.setParam(1203, '123456789047');
       ovObject.operatorLogin;

       ovObject.openShift;
     finally
       sfMF.AddSingleResultEvent(54, 56, '����� �������.', '');
     end;

     if not CheckFRAdvancedMode(100, 'ContPrint') then                         // �������� ����� ������
       Exit;
  end;

  if (FsModel = 'Shtrih') then begin
     try
       ovObject.TableNumber := 2;
       ovObject.FieldNumber := 2;
       ovObject.RowNumber := 30;
       ovObject.ValueOfFieldString := sSysOpNm;
       ovObject.WriteTable;
     finally
       sfMF.AddSingleResultEvent(54, 56, '������ ��� ���������.', '');
     end;

     try
       ovObject.TableNumber := 1;
       ovObject.FieldNumber := 6;
       ovObject.RowNumber := 1;
       ovObject.ValueOfFieldInteger := 0; //�� ��������� �������� ����
       ovObject.WriteTable;
     finally
       sfMF.AddSingleResultEvent(54, 56, '�� ��������� �������� ���� �������������.', '');
     end;

     try
       ovObject.OpenSession;
     finally
       sfMF.AddSingleResultEvent(54, 56, '����� �������.', '');
     end;

     if not CheckFRAdvancedMode(100, 'ContPrint') then                         // �������� ����� ������
       Exit;
  end;
  WriteLogFile('OpenSession-');
end;

function TVariantPrint.MSPrintTitle(sLine: string; bSubType: Byte): Bool; // + MercuryVCL
const sOption: string = ':: MStar/MMSKVCL Title ::';
var sMsg: string;
begin
  MSPrintTitle := False;
  if (FsModel = 'MStar') then begin      // ��������� �� ���������/��������
     try
//       sMsg := 'MSPrintTitle.Sub='+inttostr(bSubType);
//       Application.Messagebox(pchar(sMsg),'DBG',0);

       ovObject.SubCommand := bSubType;
       ovObject.StringForPrinting := sLine;
       ovObject.PrintDocumentTitle;
       ovObject.Department := 0;
     finally
       if CheckFRResult(sOption) then
          MSPrintTitle := True;
     end;
  end else
  if Assigned(ocObject) then begin
     if (bSubType < $FF) then begin
        ocObject.SubCommand := bSubType;
        ocObject.StringForPrinting := sLine;
     end;
     ocObject.PrintDocumentTitle;
     ocObject.Department := 0;
     if CheckFRResult(sOption) then
        MSPrintTitle := True;
  end else
    MSPrintTitle := True;

end;

function TVariantPrint.MMSKPrintTitle(sLine: string; SubType: Byte): Bool;
const sOption: string = ':: Mercury Title ::';
var iCounter: Integer;
begin
  MMSKPrintTitle := False;
  if (FsModel = 'Mercury') then begin
     IV := 0;
     bIsFisc := True;
     try
       case SubType of
         0: ovObject.OpenFiscalDoc(1);                                         // �������
         1: ovObject.OpenFiscalDoc(2);                                         // �������
         2: ovObject.OpenFiscalDoc(5);                                         // ��������
         3: ovObject.OpenFiscalDoc(6);                                         // �������
       end;
    // ��������� ������ ���������
//       ovObject.AddCustom(StringOfChar('-', LineLength), 0, 0, IV); Inc(IV);
       for iCounter := 1 to 4 do begin
         ovObject.AddHeaderLine(iCounter,0,0,IV); Inc(IV);
       end;
//       ovObject.AddCustom(StringOfChar('-', LineLength), 0, 0, IV); Inc(IV);
    // ��������� ����� ��� � ����� ��������� (�� ����� ������)
       ovObject.AddSerialNumber(0, 0, IV); ovObject.AddDocNumber(0, 31, IV); Inc(IV);
    // ��������� ���
       ovObject.AddTaxPayerNumber(0, 0, IV); Inc(IV);
    // ��������� ���� / ����� � ����� ���� (�� ����� ������)
       ovObject.AddDateTime(0, 0, IV); ovObject.AddReceiptNumber(0, 31, IV); Inc(IV);
    // ��������� ���������� �� ���������
       ovObject.AddOperInfo(2, 0, 0, IV); Inc(IV);
    // ������ ������
    //   ovObject.AddCustom(sLine, 0, 0, IV); Inc(IV);
     finally
       if CheckFRResult(sOption) then
          MMSKPrintTitle := True;
     end;
  end else
    MMSKPrintTitle := True;
end;

function TVariantPrint.PrintString(sLine: string): Bool;
const sOption: string = ':: PrintString ::';
var wTmp: Word;
begin
  PrintString := False;

  if FsModel = 'Atol10' then begin
   try
    ovObject.setParam(ovObject.LIBFPTR_PARAM_TEXT, sLine);
    ovObject.printText;
   finally
    if CheckFRResult(sOption) then
    PrintString := True;
   end;
  end;

  if (FsModel = 'Shtrih') then begin
     try
       ovObject.StringForPrinting := sLine;
       ovObject.PrintString;
     finally
       if CheckFRResult(sOption) then
          PrintString := True;
     end;
  end;

  if (FsModel = 'MStar') then begin
     try
       ovObject.StringForPrinting := sLine;
       ovObject.PrintString;
     finally
       if CheckFRResult(sOption) then
          PrintString := True;
     end;
  end;

  if (FsModel = 'Felix02') then begin
     try
       ovObject.Caption := sLine;
       ovObject.PrintString;
     finally
       if CheckFRResult(sOption) then
          PrintString := True;
     end;
  end;

  if (FsModel = 'Mercury') then begin
     wTmp := Length(sLine);
     sLine := sLine + StringOfChar(#$20, LineLength - wTmp);
     try
       if bIsFisc then begin
         ovObject.AddCustom(sLine, 0, 0, IV); inc(IV);
       end else begin
         ovObject.PrintNonFiscal('', True, False);
         ovObject.PrintNonFiscal(sLine, False, False);
         ovObject.PrintNonFiscal(''#13#10, False, True);
       end;
     finally
       if CheckFRResult(sOption) then
          PrintString := True;
     end;
  end;

  if (FsModel = 'S500N') then begin
     try
       ovObject.StringForPrinting := sLine;
       ovObject.PrintString;
     finally
       if CheckFRResult(sOption) then
          PrintString := True;
     end;
  end;

  if Assigned(ocObject) then begin
     ocObject.StringForPrinting := Copy(sLine,1,40);
     if bIsFisc then begin
        ocObject.PrintString(False);
     end else begin
        ocObject.PrintDocFreeStr(False);
     end;
     if CheckFRResult(sOption) then
        PrintString := True;
  end; // MercuryVCL

end;

function TVariantPrint.PrintWideString(sLine: string): Bool;
const sOption: string = ':: PrintWideString ::';
var wTmp: Word;
begin
  PrintWideString := False;

  if FsModel = 'Atol10' then begin
   try
    ovObject.setParam(ovObject.LIBFPTR_PARAM_TEXT, sLine);
    ovObject.printText;
   finally
     if CheckFRResult(sOption) then
        PrintWideString := True;
   end;
  end;

  if (FsModel = 'Shtrih') then begin
     try
       ovObject.StringForPrinting := sLine;
       ovObject.PrintWideString;
     finally
       if CheckFRResult(sOption) then
          PrintWideString := True;
     end;
  end;

  if (FsModel = 'MStar') then begin
     try
       ovObject.StringForPrinting := sLine;
       ovObject.PrintString;
     finally
       if CheckFRResult(sOption) then
          PrintWideString := True;
     end;
  end;

  if (FsModel = 'Felix02') then begin
     try
       ovObject.Caption := sLine;
       ovObject.PrintString;
     finally
       if CheckFRResult(sOption) then
          PrintWideString := True;
     end;
  end;

  if (FsModel = 'Mercury') then begin
     wTmp := Length(sLine);
     sLine := sLine + StringOfChar(#$20, WideLineLen - wTmp); // 18 23
     try
       if bIsFisc then begin
         ovObject.AddCustom(sLine, 8, 0, IV); inc(IV);
       end else begin
         ovObject.PrintNonFiscal('', True, False);
         ovObject.PrintNonFiscal('                    ' + sLine, False, False);
         ovObject.PrintNonFiscal(''#13#10, False, True);
       end;
     finally
//       sleep(50);
       if CheckFRResult(sOption) then
          PrintWideString := True;
     end;
  end;

  if (FsModel = 'S500N') then begin
     try
       ovObject.StringForPrinting := sLine;
       ovObject.PrintWideString;
     finally
       if CheckFRResult(sOption) then
          PrintWideString := True;
     end;
  end;

  if Assigned(ocObject) then begin
     ocObject.StringForPrinting := Copy(sLine,1,20);
     if bIsFisc then begin
        ocObject.PrintString(True);
     end else begin
        ocObject.PrintDocFreeStr(True);
     end;
     if CheckFRResult(sOption) then
        PrintWideString := True;
  end; // MercuryVCL

end;


function TVariantPrint.IsFFD12():boolean;
var
 verFFD:integer;
begin
 result:=false;
 if FsModel = 'Atol10' then begin
  ovObject.setParam(ovObject.LIBFPTR_PARAM_FN_DATA_TYPE, ovObject.LIBFPTR_FNDT_REG_INFO);
  ovObject.fnQueryData;
  try
   if ovObject.getParamInt(1209) = ovObject.LIBFPTR_FFD_1_2 then result:=true;
  except
  end;
 end;
 if (FsModel = 'Shtrih') then begin
  ovObject.TableNumber:=17;
  ovObject.FieldNumber:=17;
  ovObject.RowNumber:=1;
  ovObject.ReadTable;
  verFFD:=ovObject.ValueOfFieldInteger; //1 (1.0),2 (1.5),3 (1.1), 4(1.2)
  if verFFD=4 then result:=true;
 end;
 if result then
  WriteLogFile('������ ���' + ' :: ' + '1.2')
 else
  WriteLogFile('������ ���' + ' :: ' + '1.05');
end; //IsFFD12

function TVariantPrint.CheckMarkOnServer(returnCheck:boolean; matrix, gtin, serial, tail:string):integer;
var
 markUnion:string;
 CounterOfTryes, CountOfTryes, i:integer;
 isRequestSent:boolean;
 sTempRes:string;
 info, processingResult, processingCode, error, ValidationResult:integer;
 errorDescription:string;
 SessionNotOpen:boolean;
 resCheck, shiftState:integer;
begin
 markUnion:='01' + gtin + '21' + serial + tail;
 result:=0;
 if FsModel = 'Atol10' then begin
  //��������� �����
  try
   ovObject.setParam(ovObject.LIBFPTR_PARAM_DATA_TYPE, ovObject.LIBFPTR_DT_STATUS);
   ovObject.queryData;
   shiftState      := ovObject.getParamInt(ovObject.LIBFPTR_PARAM_SHIFT_STATE);
   if shiftState = ovObject.LIBFPTR_SS_CLOSED then begin
    if FCashierName<>'' then begin
     ovObject.setParam(1021, FCashierName);
     ovObject.operatorLogin;
    end;
	  ovObject.openShift;
  	ovObject.checkDocumentClosed;
   end;
  except
  end; //try

  ovObject.setParam(ovObject.LIBFPTR_PARAM_FN_DATA_TYPE, ovObject.LIBFPTR_FNDT_REG_INFO);
  ovObject.fnQueryData;
  {VersFFD12:=false;
  try
   if ovObject.getParamInt(1209) = ovObject.LIBFPTR_FFD_1_2 then	VersFFD12:=true;
  except
  end;
  if not(VersFFD12) then exit;}
  ovObject.setParam(ovObject.LIBFPTR_PARAM_MARKING_CODE_TYPE, ovObject.LIBFPTR_MCT12_AUTO);
  ovObject.setParam(ovObject.LIBFPTR_PARAM_MARKING_CODE, markUnion);
  if returnCheck then
   ovObject.setParam(ovObject.LIBFPTR_PARAM_MARKING_CODE_STATUS, ovObject.LIBFPTR_MES_PIECE_RETURN)
  else
   ovObject.setParam(ovObject.LIBFPTR_PARAM_MARKING_CODE_STATUS, ovObject.LIBFPTR_MES_PIECE_SOLD);
  //������.setParam(������.LIBFPTR_PARAM_QUANTITY, 1);
  //������.setParam(������.LIBFPTR_PARAM_MEASUREMENT_UNIT, ������.LIBFPTR_IU_PIECE);
  ovObject.setParam(ovObject.LIBFPTR_PARAM_MARKING_PROCESSING_MODE, 0);
  ovObject.beginMarkingCodeValidation;
  WriteLogFile('beginMarkingCodeValidation' + ' :: ' + ovObject.errorDescription);
  // ���������� ��������� �������� � ���������� ���������
  CounterOfTryes:=0;
  CountOfTryes:=5;
  while 1 = 1 do begin
   Inc(CounterOfTryes);
   ovObject.getMarkingCodeValidationStatus;
   WriteLogFile('getMarkingCodeValidationStatus' + ' :: ' + ovObject.errorDescription);
   if ovObject.getParamBool(ovObject.LIBFPTR_PARAM_MARKING_CODE_VALIDATION_READY) <> 0 then break;
   i:=0;
   WriteLogFile('���� �������� ����� "' + Trim(matrix) + '". ������� ' + IntToStr(CounterOfTryes) + '/' + IntToStr(CountOfTryes) + '...');
   while i<10 do begin //����� � 1 �������
    Sleep(100);
    Application.ProcessMessages;
    Inc(i);
   end;
 	 if CounterOfTryes >= CountOfTryes then begin
    ovObject.cancelMarkingCodeValidation;
    WriteLogFile('cancelMarkingCodeValidation' + ' :: ' + ovObject.errorDescription);
    break;
 	 end;
  end;
  //����� ���������� ��������
  if 1 = 1 then begin
   ValidationResult:=ovObject.getParamInt(ovObject.LIBFPTR_PARAM_MARKING_CODE_ONLINE_VALIDATION_RESULT);
   WriteLogFile('��������� �������� �������� � ������ (��� 2106) (���� OK, �� 15)' + ' :: ' + IntToStr(ValidationResult));
   isRequestSent:=ovObject.getParamBool(ovObject.LIBFPTR_PARAM_IS_REQUEST_SENT);
   sTempRes:='��';
   if not(isRequestSent) then sTempRes:='���';
   WriteLogFile('�� ��� ��������� �� ������' + ' :: ' + sTempRes);
   error:=ovObject.getParamInt(ovObject.LIBFPTR_PARAM_MARKING_CODE_ONLINE_VALIDATION_ERROR);
   errorDescription:=ovObject.getParamString(ovObject.LIBFPTR_PARAM_MARKING_CODE_ONLINE_VALIDATION_ERROR_DESCRIPTION);
   WriteLogFile('�������� ������ ��� �������� �����' + ' :: ' + errorDescription);
   info:=ovObject.getParamInt(2109);
   processingResult:=ovObject.getParamInt(2005);
   WriteLogFile('��� 2005' + ' :: ' + IntToStr(processingCode));
   processingCode:=ovObject.getParamInt(2105);
   WriteLogFile('��� 2105 (0 - ��� ����, 1 - ��������� ������, 2 - ������������ �����)' + ' :: ' + IntToStr(processingCode));
  end;
  result:=ovObject.getParamInt(ovObject.LIBFPTR_PARAM_MARKING_CODE_ONLINE_VALIDATION_RESULT);
  // ������������ ���������� ������ � ��������� ��
  ovObject.acceptMarkingCode;
  //��������("������.acceptMarkingCode() = " + ������(������.errorDescription()));
 end; //Atol1SessionNotOpen0
 //
 //����� ���
 //
 if (FsModel = 'Shtrih') then begin
  //��������� ������� �� �����
  //���� �� �������, �� ���������
  SessionNotOpen:=false;
  ovObject.GetECRStatus;
  if ovObject.ECRMode = 4 then SessionNotOpen:=true;
  if SessionNotOpen then begin
   try
    ovObject.TableNumber := 2;
    ovObject.FieldNumber := 2;
    ovObject.RowNumber := 30;
    ovObject.ValueOfFieldString := FCashierName;
    ovObject.WriteTable;
   finally
   end;
   try
    ovObject.TableNumber := 1;
    ovObject.FieldNumber := 6;
    ovObject.RowNumber := 1;
    ovObject.ValueOfFieldInteger := 0; //
    ovObject.WriteTable;
   finally
   end;
   try
    ovObject.OpenSession;
   finally
   end;
  end; //��������� �����

  if returnCheck then
   ovObject.ItemStatus:=3 //�������
  else
   ovObject.ItemStatus:=1; //������
  ovObject.CheckItemMode:=0; //������ �������� (��������� �������� �� � �������� ����� ���
  ovObject.TLVDataHEX:='';
  ovObject.BarCode:=markUnion;
  ovObject.FNCheckItemBarcode;
  resCheck:=ovObject.CheckItemLocalResult;
  WriteLogFile('��������� ��������� ��������(CheckItemLocalResult)' + ' :: ' + IntToStr(resCheck));
  try
   resCheck:=ovObject.CheckItemLocalError;
   WriteLogFile('������� �� ������� �� ���� ����������� ��������� ��������(CheckItemLocalError)' + ' :: ' + IntToStr(resCheck));
  except
  end;
  try
   resCheck:=ovObject.MarkingType2;
   WriteLogFile('������������ ��� ��, ��� 2100 (MarkingType2)' + ' :: ' + IntToStr(resCheck));
  except
  end;
  resCheck:=ovObject.KMServerErrorCode;
  WriteLogFile('��� ������ �� �� ������� ������-��������(KMServerErrorCode)' + ' :: ' + IntToStr(resCheck));
  resCheck:=ovObject.KMServerCheckingStatus;
  WriteLogFile('KMServerCheckingStatus(15:M+)' + ' :: ' + IntToStr(resCheck));
  resCheck:=ovObject.ResultCode;
  if resCheck <> 0 then begin
    //211 d3 - �� ���������� ��� �����
    //212 d4 - c�������������
    WriteLogFile('������ �������� �����(' + IntToStr(resCheck) + '). ����� � ���� ������� �� �����' + ' :: ' + markUnion);
    ovObject.FNDeclineMarkingCode;
  end
  else
   ovObject.FNAcceptMarkingCode;
 end; //Shtrih
end; //TVariantPrint.CheckMarkOnServer


function TVariantPrint.Sale(returnCheck:boolean; sLine: string; cQty: Currency; cPrice: Currency; iDepartment, iTaxIx: Integer;
                            datamatrix, gtin, serial, tail:string; excise:boolean; sno:integer; Validation_result:integer;
                            VersFFD12:boolean): Bool;
const sOption: string = ':: Sale ::';
var
 receiptType, shiftState:integer;
 tag1162:  Variant;
 //VersFFD12:boolean;
 MarkParsed:string;
 PredmRasch:integer;
begin
  Sale := False;
  if cQty <= 0 then begin
     Sale := True;
     Exit;
  end;

  if FsModel = 'Atol10' then begin
	 {���� ��� = 1 �����
		������.setParam(1055, ������.LIBFPTR_TT_OSN);
	 ��������� ��� = 2 �����
		������.setParam(1055, ������.LIBFPTR_TT_USN_INCOME);
	 ��������� ��� = 4 �����
		������.setParam(1055, ������.LIBFPTR_TT_USN_INCOME_OUTCOME);
	 ��������� ��� = 8 �����
		������.setParam(1055, ������.LIBFPTR_TT_ENVD);
   ��������� ��� = 16 �����
		������.setParam(1055, ������.LIBFPTR_TT_ESN);
   ��������� ��� = 32 �����
	 	������.setParam(1055, ������.LIBFPTR_TT_PATENT);
   ���������;}

   try
    ovObject.setParam(ovObject.LIBFPTR_PARAM_DATA_TYPE, ovObject.LIBFPTR_DT_STATUS);
    ovObject.queryData;
    receiptType     := ovObject.getParamInt(ovObject.LIBFPTR_PARAM_RECEIPT_TYPE);
    shiftState      := ovObject.getParamInt(ovObject.LIBFPTR_PARAM_SHIFT_STATE);
    if shiftState = ovObject.LIBFPTR_SS_CLOSED then begin
     if FCashierName<>'' then begin
      ovObject.setParam(1021, FCashierName);
      ovObject.operatorLogin;
     end;
	   ovObject.openShift;
   	 ovObject.checkDocumentClosed;
    end;

	  ovObject.setParam(ovObject.LIBFPTR_PARAM_FN_DATA_TYPE, ovObject.LIBFPTR_FNDT_REG_INFO);
    ovObject.fnQueryData;
    {VersFFD12:=false;
    try
		 if ovObject.getParamInt(1209) = ovObject.LIBFPTR_FFD_1_2 then	VersFFD12:=true;
	  except
	  end;

	  if VersFFD12 then begin
     WriteLogFile('������ ���' + ' :: ' + '1.2');
		 ovObject.setSingleSetting(ovObject.LIBFPTR_SETTING_VALIDATE_MARK_WITH_FNM_ONLY, 1); //�������� ����� ���������� ��������
	  end else begin
     WriteLogFile('������ ���' + ' :: ' + '1.05');
    end;}

    if receiptType  = ovObject.LIBFPTR_RT_CLOSED then begin
     if FCashierName<>'' then begin
      ovObject.setParam(1021, FCashierName);
      //���� ����������<>"" �����
 		  // ovObject.setParam(1203, ����������);
      //���������;
      ovObject.operatorLogin;
     end;
     if not(returnCheck) then
      ovObject.setParam(ovObject.LIBFPTR_PARAM_RECEIPT_TYPE, ovObject.LIBFPTR_RT_SELL)
     else
      ovObject.setParam(ovObject.LIBFPTR_PARAM_RECEIPT_TYPE, ovObject.LIBFPTR_RT_SELL_RETURN);
     if sno<>0 then begin
      if sno=1 then ovObject.setParam(1055, ovObject.LIBFPTR_TT_OSN);
      if sno=2 then ovObject.setParam(1055, ovObject.LIBFPTR_TT_USN_INCOME);
      if sno=3 then ovObject.setParam(1055, ovObject.LIBFPTR_TT_USN_INCOME_OUTCOME);
      if sno=4 then ovObject.setParam(1055, ovObject.LIBFPTR_TT_ENVD);
      if sno=5 then ovObject.setParam(1055, ovObject.LIBFPTR_TT_ESN);
      if sno=6 then ovObject.setParam(1055, ovObject.LIBFPTR_TT_PATENT);
     end;
     ovObject.openReceipt;
    end;

    if datamatrix <> '' then begin
     if VersFFD12 then begin
      MarkParsed:='01'+gtin+'21'+serial+tail;
      ovObject.setParam(ovObject.LIBFPTR_PARAM_MARKING_CODE, MarkParsed);
      ovObject.setParam(ovObject.LIBFPTR_PARAM_MARKING_CODE_STATUS, ovObject.LIBFPTR_MES_PIECE_SOLD);
      ovObject.setParam(ovObject.LIBFPTR_PARAM_MARKING_CODE_ONLINE_VALIDATION_RESULT, Validation_result);
      ovObject.setParam(ovObject.LIBFPTR_PARAM_MARKING_PROCESSING_MODE, 0);
     end else begin
      //ovObject.setParam(ovObject.LIBFPTR_PARAM_MARKING_CODE, datamatrix);
      //ovObject.parseMarkingCode;
      //tag1162 := ovObject.getParamByteArray(1162);
      ovObject.setParam(ovObject.LIBFPTR_PARAM_NOMENCLATURE_TYPE, ovObject.LIBFPTR_NT_SHOES);
      ovObject.setParam(ovObject.LIBFPTR_PARAM_GTIN, gtin);
      ovObject.setParam(ovObject.LIBFPTR_PARAM_SERIAL_NUMBER, serial);
      ovObject.utilFormNomenclature;

      tag1162:=ovObject.getParamByteArray(ovObject.LIBFPTR_PARAM_TAG_VALUE);
      ovObject.setParam(1162, tag1162);
     end;
    end;

    ovObject.setParam(ovObject.LIBFPTR_PARAM_COMMODITY_NAME, sLine);
	  ovObject.setParam(ovObject.LIBFPTR_PARAM_PRICE, cPrice);
  	ovObject.setParam(ovObject.LIBFPTR_PARAM_QUANTITY, cQty);
    ovObject.setParam(ovObject.LIBFPTR_PARAM_DEPARTMENT, iDepartment);
    if VersFFD12 then
     ovObject.setParam(ovObject.LIBFPTR_PARAM_MEASUREMENT_UNIT, ovObject.LIBFPTR_IU_PIECE); //�����

    ovObject.setParam(1214, 4); //������ ������
    PredmRasch:=1;
    if not(excise) then begin
     if (datamatrix <> '') and (VersFFD12) then
  	  PredmRasch:=33; //������������� �����
    end
    else begin
     if (datamatrix <> '') and (VersFFD12) then
      PredmRasch:=31 //�������������, ����������� �����
     else
      PredmRasch:=2; //����������� �����
    end;
    ovObject.setParam(1212, PredmRasch); //������� �������
    //ovObject.setParam(ovObject.LIBFPTR_PARAM_RECEIPT_TYPE, ovObject.LIBFPTR_RT_SELL_RETURN);
    case iTaxIx of
     0:ovObject.setParam(ovObject.LIBFPTR_PARAM_TAX_TYPE, ovObject.LIBFPTR_TAX_NO);
     1:ovObject.setParam(ovObject.LIBFPTR_PARAM_TAX_TYPE, ovObject.LIBFPTR_TAX_VAT18);
     2:ovObject.setParam(ovObject.LIBFPTR_PARAM_TAX_TYPE, ovObject.LIBFPTR_TAX_VAT10);
     3:ovObject.setParam(ovObject.LIBFPTR_PARAM_TAX_TYPE, ovObject.LIBFPTR_TAX_VAT20);
     4:ovObject.setParam(ovObject.LIBFPTR_PARAM_TAX_TYPE, ovObject.LIBFPTR_TAX_NO);
     5:ovObject.setParam(ovObject.LIBFPTR_PARAM_TAX_TYPE, ovObject.LIBFPTR_TAX_VAT0);
     6:ovObject.setParam(ovObject.LIBFPTR_PARAM_TAX_TYPE, ovObject.LIBFPTR_TAX_VAT118);
    end;

    ovObject.registration;
   finally
    if CheckFRAdvancedMode(100, sOption) then                      // �������� ����� ������ ?????
     Sale := True;
   end;
  end;

  if (FsModel = 'Shtrih') then begin
     try
       ovObject.CheckType := 1;                                                // ffd 1.05
       //ovObject.OpenCheck := 1;                                                // ffd 1.05

       //ovObject.TagNumber := 1021;
       //ovObject.TagType := 7;
       //ovObject.TagValueStr := '������ �����-��';
       //ovObject.FNSendTag;

       //Drv.Summ1Enabled := True; - ��������������� ������ �����
       ovObject.StringForPrinting := sLine;
       ovObject.Quantity   := cQty;
       ovObject.Price      := cPrice;
       ovObject.Department := iDepartment;
       iLastDepartment := iDepartment;
       ovObject.Tax1 := iTaxIx;
       ovObject.Tax2 := 0;
       ovObject.Tax3 := 0;
       ovObject.Tax4 := 0;
       ovObject.PaymentTypeSign := 4;                                          // ffd 1.05 (������ ������)

       PredmRasch:=1;
       if not(excise) then begin
        if (datamatrix <> '') and (VersFFD12) then
         PredmRasch := 33;                                          // ffd 1.05 (�����)
       end
       else begin
        if (datamatrix <> '') and (VersFFD12) then
         PredmRasch := 31
        else
         PredmRasch := 2;                                          // ffd 1.05 (�������� �����)
       end;
       ovObject.PaymentItemSign := PredmRasch;
       
       try
        ovObject.MeasureUnit:=0;
       except
       end;
       //ovObject.Sale;
       {ovObject.FNOperation;                                                  // ffd 1.05 (CheckType==1 => sale)
       if datamatrix <> '' then begin
         ovObject.BarCode:=datamatrix;
         ovObject.FNSendItemBarcode;
       end;}
       ovObject.FNOperation;

       if (datamatrix <> '') then begin
        if VersFFD12 then begin
         MarkParsed:='01'+gtin+'21'+serial+tail;
         ovObject.BarCode:=MarkParsed;
         ovObject.FNSendItemBarcode;
        end else begin
         ovObject.MarkingType := $444D; //Data Matrix 3
         //ovObject.GTIN := '00000046198488';
         ovObject.GTIN := gtin;
         //ovObject.SerialNumber := 'X?io+qCABm8 '; // ??? ??????? ? ????? (?? 13 ????.)
         ovObject.SerialNumber := serial; // ??? ??????? ? ????? (?? 13 ????.)
         ovObject.FNSendItemCodeData;
        end;
       end;
     finally
       if CheckFRAdvancedMode(100, sOption) then                      // �������� ����� ������ ?????
          Sale := True;
     end;
  end;

  if (FsModel = 'MStar') then begin
     try
       ovObject.StringForPrinting := sLine;
       ovObject.Quantity   := cQty;
       ovObject.Price      := cPrice;
       ovObject.Department := 0;
       ovObject.Sale;
     finally
       CheckFRResult(sOption);
       Sale := True;
     end;
  end;

  if (FsModel = 'Felix02') then begin
     try
       ovObject.Mode := 1;
       ovObject.SetMode;
       ovObject.Name       := sLine;
       ovObject.Quantity   := cQty;
       ovObject.Price      := cPrice;
       ovObject.Department := 1;
       ovObject.Registration;
     finally
       Sleep(100);
       CheckFRResult(sOption);
       Sale := True;
     end;
  end;

  if (FsModel = 'Mercury') then begin
     try
       ovObject.AddCustom(sLine, 0, 0, IV); Inc(IV);
       ovObject.AddItem(0, // - ������ ��� �����
           cPrice,         // - ���� ������
           False,          // - ����� �� �������� �����
           1,              // - ����� ������
           0,              // - ��� ������
           0,              // - ������������
           cQty*1000, 3,        // - ���������� = 2 (��� ������ ����� ���������� �����)
           Tax1,           // - ������ ��������� ������
           '��.',          // - ������� ���������
           0,              // - �����
           0,              // - �������� �� �����������
           IV,             // - �������� �� ���������
           0);             // - ������������
       Inc(IV);
     finally
       if CheckFRResult(sOption) then                      // �������� ����� ������ ?????
          Sale := True;
     end;
  end;

  if (FsModel = 'S500N') then
     if SaleCredit(sLine, cQty, cPrice) then
        Sale := True;

  if Assigned(ocObject) then begin
     ocObject.StringForPrinting := sLine;
     ocObject.Quantity   := cQty;
     ocObject.Price      := cPrice;
     ocObject.Department := iDepartment;
     ocObject.Sale;
     if CheckFRResult(sOption) then
        Sale := True;
  end;

end;

function TVariantPrint.SaleCredit(sLine: string; cQty: Currency; cPrice: Currency): Bool;  // ���� �������� 2 ������ �� �����
var sTemp, sTemp1, sTemp2: string;
    iSctLen: Byte;
begin
  SaleCredit := False;
  if cQty <= 0 then begin
     Salecredit := True;
     Exit;
  end;

  iSctLen := Trunc(LineLength/3);

  PrintString(sLine);

  sTemp  := FormatFloat(',0.00', cPrice);
  sTemp1 := FormatFloat(',0.000', cQty);
  sTemp2 := FormatFloat(',0.00', cPrice*cQty);

  PrintString(StringOfChar(#$20, iSctLen - Length(sTemp) - 1) + sTemp + 'x' +
              StringOfChar(#$20, iSctLen - Length(sTemp1) - 1) + sTemp1 + '=' +
              StringOfChar(#$20, iSctLen - Length(sTemp2)) + sTemp2);
end;

function TVariantPrint.ReturnSale(sLine: string; cQty: Currency; cPrice: Currency; iDepartment, iTaxIx: Integer;
                                  datamatrix, gtin, serial, tail:string; excise:boolean; sno:integer): Bool;
const sOption: string = ':: ReturnSale ::';
var receiptType:integer;
    tag1162:  Variant;
begin
  ReturnSale := False;
  if cQty <= 0 then begin
     ReturnSale := True;
     Exit;
  end;
{
       ovObject.CheckType := 1;                                                // ffd 1.05
       //Drv.Summ1Enabled := True; - ��������������� ������ �����
       ovObject.StringForPrinting := sLine;
       ovObject.Quantity   := cQty;
       ovObject.Price      := cPrice;
       ovObject.Department := iDepartment;
       iLastDepartment := iDepartment;
       ovObject.Tax1 := iTaxIx;
       ovObject.Tax2 := 0;
       ovObject.Tax3 := 0;
       ovObject.Tax4 := 0;
       ovObject.PaymentTypeSign := 4;                                          // ffd 1.05 (������ ������)
       ovObject.PaymentItemSign := 1;                                          // ffd 1.05 (�����)
       //ovObject.Sale;
       ovObject.FNOperation;                                                   // ffd 1.05 (CheckType==1 => sale)
}

  if FsModel = 'Atol10' then begin
	 {���� ��� = 1 �����
		������.setParam(1055, ������.LIBFPTR_TT_OSN);
	 ��������� ��� = 2 �����
		������.setParam(1055, ������.LIBFPTR_TT_USN_INCOME);
	 ��������� ��� = 4 �����
		������.setParam(1055, ������.LIBFPTR_TT_USN_INCOME_OUTCOME);
	 ��������� ��� = 8 �����
		������.setParam(1055, ������.LIBFPTR_TT_ENVD);
   ��������� ��� = 16 �����
		������.setParam(1055, ������.LIBFPTR_TT_ESN);
   ��������� ��� = 32 �����
	 	������.setParam(1055, ������.LIBFPTR_TT_PATENT);
   ���������;}

   try
     ovObject.setParam(ovObject.LIBFPTR_PARAM_DATA_TYPE, ovObject.LIBFPTR_DT_STATUS);
     ovObject.queryData;
     receiptType     := ovObject.getParamInt(ovObject.LIBFPTR_PARAM_RECEIPT_TYPE);

     if receiptType  = ovObject.LIBFPTR_RT_CLOSED then begin
      if FCashierName<>'' then begin
       ovObject.setParam(1021, FCashierName);
       //���� ����������<>"" �����
 		   // ovObject.setParam(1203, ����������);
       //���������;
       ovObject.operatorLogin;
      end;
      ovObject.setParam(ovObject.LIBFPTR_PARAM_RECEIPT_TYPE, ovObject.LIBFPTR_RT_SELL_RETURN);
      if sno<>0 then begin
       if sno=1 then ovObject.setParam(1055, ovObject.LIBFPTR_TT_OSN);
       if sno=2 then ovObject.setParam(1055, ovObject.LIBFPTR_TT_USN_INCOME);
       if sno=3 then ovObject.setParam(1055, ovObject.LIBFPTR_TT_USN_INCOME_OUTCOME);
       if sno=4 then ovObject.setParam(1055, ovObject.LIBFPTR_TT_ENVD);
       if sno=5 then ovObject.setParam(1055, ovObject.LIBFPTR_TT_ESN);
       if sno=6 then ovObject.setParam(1055, ovObject.LIBFPTR_TT_PATENT);
      end;
      ovObject.openReceipt;
     end;

     if datamatrix <> '' then begin
       //ovObject.setParam(ovObject.LIBFPTR_PARAM_MARKING_CODE, datamatrix);
       //ovObject.parseMarkingCode;
       //tag1162 := ovObject.getParamByteArray(1162);
       ovObject.setParam(ovObject.LIBFPTR_PARAM_NOMENCLATURE_TYPE, ovObject.LIBFPTR_NT_SHOES);
       ovObject.setParam(ovObject.LIBFPTR_PARAM_GTIN, gtin);
       ovObject.setParam(ovObject.LIBFPTR_PARAM_SERIAL_NUMBER, serial);
       ovObject.utilFormNomenclature;

      tag1162:=ovObject.getParamByteArray(ovObject.LIBFPTR_PARAM_TAG_VALUE);
      ovObject.setParam(1162, tag1162);
     end;

     ovObject.setParam(ovObject.LIBFPTR_PARAM_COMMODITY_NAME, sLine);
	   ovObject.setParam(ovObject.LIBFPTR_PARAM_PRICE, cPrice);
  	 ovObject.setParam(ovObject.LIBFPTR_PARAM_QUANTITY, cQty);

     ovObject.setParam(1214, 4); //������ ������
     if not(excise) then
  		 ovObject.setParam(1212, 1) //�����
     else
       ovObject.setParam(1212, 2); //�������� �����
     //ovObject.setParam(ovObject.LIBFPTR_PARAM_RECEIPT_TYPE, ovObject.LIBFPTR_RT_SELL_RETURN);
     case iTaxIx of
      0:ovObject.setParam(ovObject.LIBFPTR_PARAM_TAX_TYPE, ovObject.LIBFPTR_TAX_NO);
      1:ovObject.setParam(ovObject.LIBFPTR_PARAM_TAX_TYPE, ovObject.LIBFPTR_TAX_VAT18);
      2:ovObject.setParam(ovObject.LIBFPTR_PARAM_TAX_TYPE, ovObject.LIBFPTR_TAX_VAT10);
      3:ovObject.setParam(ovObject.LIBFPTR_PARAM_TAX_TYPE, ovObject.LIBFPTR_TAX_VAT20);
      4:ovObject.setParam(ovObject.LIBFPTR_PARAM_TAX_TYPE, ovObject.LIBFPTR_TAX_NO);
      5:ovObject.setParam(ovObject.LIBFPTR_PARAM_TAX_TYPE, ovObject.LIBFPTR_TAX_VAT0);
      6:ovObject.setParam(ovObject.LIBFPTR_PARAM_TAX_TYPE, ovObject.LIBFPTR_TAX_VAT118);
     end;

    ovObject.registration;
   finally
    if CheckFRAdvancedMode(100, sOption) then                      // �������� ����� ������ ?????
         ReturnSale := True;
   end;
  end;

  if (FsModel = 'Shtrih') then begin
     try
       ovObject.CheckType := 2;                                                // ffd 1.05
       ovObject.StringForPrinting := sLine;
       ovObject.Quantity   := cQty;
       ovObject.Price      := cPrice;
       ovObject.Department := iDepartment;
       ovObject.Tax1 := iTaxIx;
       ovObject.Tax2 := 0;
       ovObject.Tax3 := 0;
       ovObject.Tax4 := 0;
       ovObject.PaymentTypeSign := 4;                                          // ffd 1.05 (������ ������)
       //ovObject.PaymentItemSign := 1;                                          // ffd 1.05 (�����)
       if not(excise) then
        ovObject.PaymentItemSign := 1                                          // ffd 1.05 (�����)
       else
        ovObject.PaymentItemSign := 2;                                          // ffd 1.05 (�������� �����)
//       ovObject.ReturnSale;
       ovObject.FNOperation;                                                   // ffd 1.05 (CheckType==1 => sale)
       if datamatrix <> '' then begin
        ovObject.MarkingType := $444D; //Data Matrix 3
        //ovObject.GTIN := '00000046198488';
        ovObject.GTIN := gtin;
        //ovObject.SerialNumber := 'X?io+qCABm8 '; // ??? ??????? ? ????? (?? 13 ????.)
        ovObject.SerialNumber := serial; // ??? ??????? ? ????? (?? 13 ????.)
        ovObject.FNSendItemCodeData;
       end;
     finally
       if CheckFRAdvancedMode(100, sOption) then                      // �������� ����� ������ ?????
          ReturnSale := True;
     end;
  end;

  if (FsModel = 'MStar') then begin
     try
       ovObject.StringForPrinting := sLine;
       ovObject.Quantity   := cQty;
       ovObject.Price      := cPrice;
       ovObject.Department := 0;
       ovObject.ReturnSale;
     finally
       if CheckFRResult(sOption) then
          ReturnSale := True;
     end;
  end;

  if (FsModel = 'Felix02') then begin
     try
       ovObject.Mode := 1;
       ovObject.SetMode;
       ovObject.Name       := sLine;
       ovObject.Quantity   := cQty;
       ovObject.Price      := cPrice;
       ovObject.Department := 1;
       ovObject.Return;
     finally
       Sleep(100);
       if CheckFRResult(sOption) then
          ReturnSale := True;
     end;
  end;

  if (FsModel = 'Mercury') then begin
     try
       ovObject.AddCustom(sLine, 0, 0, IV); Inc(IV);
       ovObject.AddItem(0, // - ������ ��� �����
           cPrice,         // - ���� ������
           False,          // - ����� �� �������� �����
           1,              // - ����� ������
           0,              // - ��� ������
           0,              // - ������������
           cQty*1000, 3,   // - ���������� = 2 (��� ������ ����� ���������� �����)
           iTaxIx,         // - ������ ��������� ������
           '��.',          // - ������� ���������
           0,              // - �����
           0,              // - �������� �� �����������
           IV,             // - �������� �� ���������
           0);             // - ������������
       Inc(IV);
     finally
       if CheckFRResult(sOption) then                      // �������� ����� ������ ?????
          ReturnSale := True;
     end;
  end;

  if (FsModel = 'S500N') then
     if SaleCredit(sLine, cQty, cPrice) then
        ReturnSale := True;

  if Assigned(ocObject) then begin
     ocObject.StringForPrinting := sLine;
     ocObject.Quantity   := cQty;
     ocObject.Price      := cPrice;
     ocObject.Department := 0;
     ocObject.ReturnSale;
     if CheckFRResult(sOption) then
        ReturnSale := True;
  end;

end;

//function TVariantPrint.CloseCheck(sLine: string; cSum: Currency; cExact: Currency; bSaleCredit: Bool): Bool;
function TVariantPrint.CloseCheck(sLine: string; cSum: Currency; cExact: Currency; TPayment, Tax: Integer): Bool;
const sOption: string = ':: CloseCheck ::';
      saLocalParams: array[0..3] of string = ('RcHeader1','RcHeader2','RcHeader3','RcHeader4');
var sTemp: string;
    iCounter: Integer;
    tryOk: Bool;
    openDrawerB:boolean;
begin
  CloseCheck := False;

  openDrawerB:=false;
  if TPayment <= 1 then openDrawerB:=true;

  if (FsModel = 'Atol10') then begin
   try
     case TPayment of
        0,1: ovObject.setParam(ovObject.LIBFPTR_PARAM_PAYMENT_TYPE, ovObject.LIBFPTR_PT_CASH);
        2: ovObject.setParam(ovObject.LIBFPTR_PARAM_PAYMENT_TYPE, ovObject.LIBFPTR_PT_ELECTRONICALLY);
        3: ovObject.setParam(ovObject.LIBFPTR_PARAM_PAYMENT_TYPE, ovObject.LIBFPTR_PT_PREPAID);
        4: ovObject.setParam(ovObject.LIBFPTR_PARAM_PAYMENT_TYPE, ovObject.LIBFPTR_PT_CREDIT);
     end;
    	ovObject.setParam(ovObject.LIBFPTR_PARAM_PAYMENT_SUM, cSum);
  		ovObject.Payment;

     ovObject.closeReceipt; //��������� ���
     if openDrawerB then
       OpenDrawer;
   finally
    if CheckFRAdvancedMode(100, sOption) then begin                         // �������� ����� ������ ?????
	   ovObject.setParam(ovObject.LIBFPTR_PARAM_FN_DATA_TYPE, ovObject.LIBFPTR_FNDT_LAST_DOCUMENT);
   	 ovObject.fnQueryData;
	   iLastNDoc:=ovObject.getParamInt(ovObject.LIBFPTR_PARAM_DOCUMENT_NUMBER);
     CloseCheck := True;
    end;
   end;
  end;

  if (FsModel = 'Shtrih') then begin
     try                                                                       // �������
       ovObject.CheckSubTotal;
     finally
     end;

     if not CheckFRResult(':: CheckSubTotals inside CloseCheck ::') then
        Exit;

     try
       ovObject.StringForPrinting := '';
       ovObject.Summ1 := 0; ovObject.Summ2 := 0; ovObject.Summ3 := 0; ovObject.Summ4 := 0;
       ovObject.Summ5 := 0; ovObject.Summ6 := 0; ovObject.Summ7 := 0; ovObject.Summ8 := 0;
       ovObject.Summ9 := 0; ovObject.Summ10 := 0; ovObject.Summ11 := 0; ovObject.Summ12 := 0;
       ovObject.Summ13 := 0; ovObject.Summ14 := 0; ovObject.Summ15 := 0; ovObject.Summ16 := 0;
       case TPayment of
          0,1: ovObject.Summ1 := cSum;
          2: ovObject.Summ2 := cSum;
          3: ovObject.Summ3 := cSum;
          4: ovObject.Summ4 := cSum;
       end;
       ovObject.DiscountOnCheck := 0;
       ovObject.TaxValue1 := 0;
       ovObject.TaxValue2 := 0;
       ovObject.TaxValue3 := 0;
       ovObject.TaxValue4 := 0;
       ovObject.TaxValue5 := 0;
       ovObject.TaxValue6 := 0;

//       if (slDepart2Tax.IndexOf(IntToStr(iLastDepartment)) > 0) then begin
       ovObject.TaxType := ifSetup.ReadInteger('TaxType', IntToStr(iLastDepartment), 1);
//       slDepart2Tax
//       end else begin
//            := 1;
//       end;
       //ovObject.CloseCheck;
       ovObject.FNCloseCheckEx;                                                // ffd 1.05
       if openDrawerB then
         OpenDrawer;
     finally
       if CheckFRAdvancedMode(100, sOption) then begin                         // �������� ����� ������ ?????
          iLastNDoc := ovObject.OpenDocumentNumber;
          CloseCheck := True;
       end;
     end;
  end;

  if (FsModel = 'MStar') then begin

     ovObject.StringForPrinting := '';
     ovObject.Summ1 := cSum;

     try
       ovObject.CloseCheck;
       ovObject.Summ1 := 0;
     finally
     end;

     if not CheckFRResult(sOption) then
       Exit;

     try
       ovObject.GetECRStatus;
     finally
       iLastNDoc := ovObject.OpenDocumentNumber;
     end;

     if not CheckFRResult(':: GetState inside ' + sOption + '::') then
       Exit;

     OpenDrawer;

     try
        ovObject.StringQuantity := 6;
        ovObject.FeedDocument;
     finally
        CloseCheck := True;
     end;

  end;

  if (FsModel = 'Felix02') then begin

     try
       ovObject.GetStatus;
     finally
       iLastNDoc := ovObject.CheckNumber; // + 1;
       Sleep(200);
     end;

     if not CheckFRResult(':: GetState inside ' + sOption + '::') then
       Exit;

     ovObject.Caption := '';
     ovObject.TypeClose := 0;
     ovObject.Summ := cSum;

     try
       ovObject.Delivery;
     finally
       Sleep(200);
     end;

     if not CheckFRResult(':: Delivery inside ' + sOption + ' ::') then
       Exit;

     try
       ovObject.GetStatus;
     finally
       CloseCheck := True;
     end;

     if not CheckFRResult(sOption) then
       Exit;

  end;

  if (FsModel = 'Mercury') then begin

     try
        ovObject.AddTotal(0, 0, IV, 0); Inc(IV);
        if ovObject.CurrentOper = 1 then begin
          // ��������� ���������� �� ������
          ovObject.AddPay(
            0,      // - ������: �������� + ��������� �����
            cSum,             // - ����� ������ ���������
            0,               // - ����� ������ �� �������
            '',               // - �������������� ���������� �� ������ - ������������ ��� ��������������� ������
            0, 0, IV, 0); Inc(IV);
          // ��������� ����� �����
          ovObject.AddChange(0, 0, IV, 0);
        end;
        // ��������� ��������
        ovObject.CloseFiscalDoc;

     finally
       Sleep(200);
       OpenDrawer;
       if CheckFRResult(sOption) then
          CloseCheck := True;
     end;

     try
       ovObject.QueryLastDocInfo;
     finally
       iLastNDoc := ovObject.LastDocNumber; // get n_doc here ...
       bIsFisc := False;
       Sleep(200);
     end;

  end;

  if (FsModel = 'S500N') then begin
     sTemp := FormatFloat(',0.00', cExact);
     PrintWideString('����:' + StringOfChar(#$20, WideLineLen - 5 - Length(sTemp)) + sTemp);

     sTemp := FormatFloat(',0.00', cSum);
     PrintString('���������:' + StringOfChar(#$20, LineLength - 10 - Length(sTemp)) + sTemp);

     if (cSum-cExact) > 0 then begin
       sTemp := FormatFloat(',0.00', cSum-cExact);
       PrintString('�����:' + StringOfChar(#$20, LineLength - 6 - Length(sTemp)) + sTemp);
     end;


     PrintString(StringOfChar('=', LineLength));
     FeedPaper(3);

     for iCounter := 0 to 3 do                                                    // ��������� ���������
         PrintString(ifSetup.ReadString('Local',saLocalParams[iCounter],''));

     iLastNDoc := -1;
     CloseCheck := True;
  end;

  if Assigned(ocObject) then begin

     ocObject.StringForPrinting := sLine;
     ocObject.Summ1 := cSum;

     ocObject.CloseCheck;
     ocObject.Summ1 := 0;
     if not CheckFRResult(sOption) then
        Exit;

     ocObject.GetECRStatus;
     if not CheckFRResult(':: State inside ' + sOption + ' ::') then
        Exit;

     iLastNDoc := ocObject.OpenDocumentNumber;

     ocObject.OpenDrawer;
     if CheckFRResult(':: OpenDrawer inside ' + sOption + ' ::') then
        CloseCheck := True;

  end;

end;

function TVariantPrint.FNSendCustomerTel(sLine: string): Bool;
const sOption: string = ':: CustomerTel ::';
begin
  FNSendCustomerTel := False;

  if FsModel = 'Atol10' then begin
    ovObject.setParam(1008, sLine);

    if not CheckFRResult(sOption) then
       Exit;
    FNSendCustomerTel := True;
  end;

  if (FsModel = 'Shtrih') then begin

     try
       ovObject.CustomerEmail := sLine;
       ovObject.FNSendCustomerEmail;
       ovObject.AttrNumber := 1008;
       ovObject.WriteAttribute;
     finally
     end;

     if not CheckFRResult(sOption) then
        Exit;

     FNSendCustomerTel := True;
  end;
end;

function TVariantPrint.FNSendCustomerEml(sLine: string): Bool;
const sOption: string = ':: CustomerEml ::';
begin
  FNSendCustomerEml := False;

  if FsModel = 'Atol10' then begin
    ovObject.setParam(1008, sLine);

    if not CheckFRResult(sOption) then
       Exit;
    FNSendCustomerEml := True;
  end;

  if (FsModel = 'Shtrih') then begin

     try
       ovObject.CustomerEmail := sLine;
       ovObject.FNSendCustomerEmail;
     finally
     end;

     if not CheckFRResult(sOption) then
        Exit;

     FNSendCustomerEml := True;
  end;
end;

function TVariantPrint.FNSendCustomerINN(sLine: string): Bool;
const sOption: string = ':: CustomerINN ::';
begin
  FNSendCustomerINN := False;

  if FsModel = 'Atol10' then begin
    ovObject.setParam(1228, sLine);

    if not CheckFRResult(sOption) then
       Exit;
    FNSendCustomerINN := True;
  end;

  if (FsModel = 'Shtrih') then begin

     try
       ovObject.TagNumber := 1228;
       ovObject.TagType := 7;
       ovObject.TagValueStr := sLine;
       ovObject.FNSendTag;
     finally
     end;

     if not CheckFRResult(sOption) then
        Exit;

     FNSendCustomerINN := True;
  end;
end;

function TVariantPrint.FNSendCashFam(sLine: string): Bool;
const sOption: string = ':: Cashir ::';
begin
  FNSendCashFam := False;

  if FsModel = 'Atol10' then begin
    ovObject.setParam(1021, sLine);
    if not CheckFRResult(sOption) then
       Exit;
    FNSendCashFam := True;
  end;

  if (FsModel = 'Shtrih') then begin

     try
       ovObject.TagNumber := 1021;
       ovObject.TagType := 7;
       ovObject.TagValueStr := sLine;
       ovObject.FNSendTag;
     finally
     end;

     if not CheckFRResult(sOption) then
        Exit;

     FNSendCashFam := True;
  end;
end;


function TVariantPrint.FNSendCustomerNm(sLine: string): Bool;
const sOption: string = ':: CustomerNm ::';
begin
  FNSendCustomerNm := False;

  if FsModel = 'Atol10' then begin
    ovObject.setParam(1227, sLine);

    if not CheckFRResult(sOption) then
       Exit;
    FNSendCustomerNm := True;
  end;

  if (FsModel = 'Shtrih') then begin

     try
       ovObject.TagNumber := 1227;
       ovObject.TagType := 7;
       ovObject.TagValueStr := sLine;
       ovObject.FNSendTag;
     finally
     end;

     if not CheckFRResult(sOption) then
        Exit;

     FNSendCustomerNm := True;
  end;
end;

function TVariantPrint.CashIncome(sLine: string; cSum: Currency): Bool;
const sOption: string = ':: CashIncome ::';
var bCloseErr: Bool;
begin
  CashIncome := False;
  WriteLogFile('CashIncome+');

  if FsModel = 'Atol10' then begin
    try
      ovObject.setParam(ovObject.LIBFPTR_PARAM_SUM, cSum);
      ovObject.cashIncome;
    finally
    end;

     if not CheckFRResult(sOption) then
        Exit;
     //iLastNDoc := ovObject.OpenDocumentNumber + 1;
     CashIncome := True;
  end;

  if (FsModel = 'Shtrih') then begin

     if not PrintString(sLine) then
        Exit;

     if not PrintString('���������� ���������� "����"-"�����"') then
        Exit;

     try
       ovObject.Summ1 := cSum;
       ovObject.CashIncome;
     finally
     end;

     if not CheckFRResult(sOption) then
        Exit;

     iLastNDoc := ovObject.OpenDocumentNumber + 1;

     CashIncome := True;
  end;

  if (FsModel = 'Mercury') then begin

     if not PrintString(sLine) then
        Exit;

//     if not PrintString('���������� ���������� "����"-"�����"') then
//        Exit;

     if not MMSKPrintTitle('���������� ���������� "����"-"�����"', 2) then
        Exit;

     try
       ovObject.AddCustom('���������� ���������� "����"-"�����"', 0, 0, IV); Inc(IV);
       ovObject.AddItem(0, // - ������ ��� �����
           cSum,         // - ���� ������
           False,          // - ����� �� �������� �����
           1,              // - ����� ������
           0,              // - ��� ������
           0,              // - ������������
           1, 0,        // - ���������� = 2 (��� ������ ����� ���������� �����) // ������ ���� �����
           Tax1,           // - ������ ��������� ������
           '��.',          // - ������� ���������
           0,              // - �����
           0,              // - �������� �� �����������
           IV,             // - �������� �� ���������
           0);             // - ������������
       Inc(IV);
     finally
     end;

     if not CheckFRResult(sOption) then begin
        bIsFisc := False;
        Exit;
     end;

     try
       bCloseErr := not CloseCheck('', cSum, cSum, 1, 0);

       if (iLastNDoc = 0) or bCloseErr then begin                         // ����� ��������� - � ���������
         if Application.MessageBox('��������, ������ ��� ���������� ��������� ����������. ������������ �������� ?',
                                   '��������������',$34) = idYes then begin
            WriteLogFile('������ ����������. ��������� ������ ��������� ��������');
            Exit;
         end else begin
            WriteLogFile('������ ����������. �������� "��������" ��������.');
            CashIncome := True;
         end;
         sfMF.aCancelDocumentExecute(Self);
       end;
     except
         sfMF.aCancelDocumentExecute(Self);
         Exit;
     end;

     CashIncome := True;

  end;

  if (FsModel = 'MStar') then begin

     MSPrintTitle(sLine, 2);

     ovObject.StringForPrinting := '���������� ���������� "����"-"�����"';
     ovObject.Price := cSum;
     ovObject.Quantity := 1;
     try
       ovObject.CashIncome;
     finally
       CheckFRResult(sOption);
     end;

     try
       ovObject.CloseCheck;
     finally
     end;

     if not CheckFRResult(':: CheckRes inside ' + sOption + ' ::') then
        Exit;

     try
       ovObject.GetECRStatus;
     finally
       iLastNDoc := ovObject.OpenDocumentNumber;
     end;

     if not CheckFRResult(':: nDoc inside ' + sOption + ' ::') then
        Exit;

     if not FeedPaper(7) then
        Exit;
  end;

  if Assigned(ocObject) then begin

     MSPrintTitle(sLine, 2);

     ocObject.StringForPrinting := '���������� ���������� "����"-"�����"';
     ocObject.Price := cSum;
     ocObject.Quantity := 1;
     ocObject.CashIncome;
     CheckFRResult(sOption);

     ocObject.CloseCheck;

     if not CheckFRResult(':: CloseCheck inside ' + sOption + ' ::') then
        Exit;

     ocObject.GetECRStatus;
     iLastNDoc := ocObject.OpenDocumentNumber;

     if not CheckFRResult(':: GetNDoc inside ' + sOption + ' ::') then
        Exit;

  end;
  WriteLogFile('CashIncome+');

end;

function TVariantPrint.CashOutcome(sLine: string; cSum: Currency): Bool;
const sOption: string = ':: CashOutcome ::';
var bCloseErr: Bool;
begin
  CashOutcome := False;
  WriteLogFile('CashOutcome+');

  if FsModel = 'Atol10' then begin
    try
      ovObject.setParam(ovObject.LIBFPTR_PARAM_SUM, cSum);
      ovObject.cashOutcome;
    finally
    end;

     if not CheckFRResult(sOption) then
        Exit;
     //iLastNDoc := ovObject.OpenDocumentNumber + 1;
     CashOutcome := True;
  end;

  if (FsModel = 'Shtrih') then begin

     if not PrintString(sLine) then
        Exit;

     if not PrintString('���������� ���������� "�����"-"����"') then
        Exit;

     try
       ovObject.Summ1 := cSum;
       ovObject.CashOutcome;
     finally
     end;

     if not CheckFRResult(sOption) then
        Exit;

     iLastNDoc := ovObject.OpenDocumentNumber + 1;

     CashOutcome := True;
  end;

  if (FsModel = 'Mercury') then begin

     if not PrintString(sLine) then
        Exit;

//     if not PrintString('���������� ���������� "����"-"�����"') then
//        Exit;

     if not MMSKPrintTitle('', 3) then
        Exit;

     try
       ovObject.AddCustom('���������� ���������� "�����"-"����"', 0, 0, IV); Inc(IV);
       ovObject.AddItem(0, // - ������ ��� �����
           cSum,         // - ���� ������
           False,          // - ����� �� �������� �����
           1,              // - ����� ������
           0,              // - ��� ������
           0,              // - ������������
           1, 0,        // - ���������� = 2 (��� ������ ����� ���������� �����) // ������ ���� �����
           Tax1,           // - ������ ��������� ������
           '��.',          // - ������� ���������
           0,              // - �����
           0,              // - �������� �� �����������
           IV,             // - �������� �� ���������
           0);             // - ������������
       Inc(IV);
     finally
     end;

     if not CheckFRResult(sOption) then begin
        bIsFisc := False;
        Exit;
     end;

     try
       bCloseErr := not CloseCheck('', cSum, cSum, 1, 0);

       if (iLastNDoc = 0) or bCloseErr then begin                         // ����� ��������� - � ���������
         if Application.MessageBox('��������, ������ ��� ���������� ��������� ����������. ������������ �������� ?',
                                   '��������������',$34) = idYes then begin
            WriteLogFile('������ ����������. ��������� ������ ��������� "�������"');
            Exit;
         end else begin
            WriteLogFile('������ ����������. �������� "�������" ��������.');
            CashOutcome := True;
         end;
         sfMF.aCancelDocumentExecute(Self);
       end;
     except
         sfMF.aCancelDocumentExecute(Self);
         Exit;
     end;

     CashOutcome := True;

  end;

  if (FsModel = 'MStar') then begin

     MSPrintTitle(sLine, 3);

     ovObject.StringForPrinting := '���������� ���������� "�����" - "����"';
     ovObject.Price := cSum;
     ovObject.Quantity := 1;
     try
       ovObject.CashOutcome;
     finally
       CheckFRResult(sOption);
     end;

     try
       ovObject.CloseCheck;
     finally
     end;

     if not CheckFRResult(':: CloseCheck inside ' + sOption + ' ::') then
        Exit;

     try
       ovObject.GetECRStatus;
     finally
       iLastNDoc := ovObject.OpenDocumentNumber;
     end;

     if not CheckFRResult(':: GetNDoc inside ' + sOption + ' ::') then
        Exit;

     if not FeedPaper(7) then
        Exit;
  end;

  if Assigned(ocObject) then begin

     MSPrintTitle(sLine, 3);

     ocObject.StringForPrinting := '���������� ���������� "�����"-"����"';
     ocObject.Price := cSum;
     ocObject.Quantity := 1;
     ocObject.CashIncome;
     CheckFRResult(sOption);

     ocObject.CloseCheck;

     if not CheckFRResult(':: CloseCheck inside ' + sOption + ' ::') then
        Exit;

     ocObject.GetECRStatus;
     iLastNDoc := ocObject.OpenDocumentNumber;

     if not CheckFRResult(':: GetNDoc inside ' + sOption + ' ::') then
        Exit;

  end;
  WriteLogFile('CashOutcome+');
end;          

function TVariantPrint.Report(bClearing:Bool): Bool;
var stateSm:integer;
begin
  Report := False;
  WriteLogFile('Report+');
  if bClearing then begin

    if (FsModel = 'Atol10') then begin
     try

    	ovObject.setParam(ovObject.LIBFPTR_PARAM_DATA_TYPE, ovObject.LIBFPTR_DT_SHIFT_STATE);
    	ovObject.queryData;

    	stateSm := ovObject.getParamInt(ovObject.LIBFPTR_PARAM_SHIFT_STATE);
		  if stateSm = ovObject.LIBFPTR_SS_CLOSED then begin
			  {��������("����� ��� �������!");
  			������������������ = "����� ��� �������!";
	  		��� = 0;
		  	������������������105(������, 0);
			  ������� ���;}
  		end;

   		{ovObject.setParam(1021,������);
   		���� ���������� <> "" �����
   		    ������.setParam(1203, ����������);
   		���������;
   		ovObject.operatorLogin();}
      if FCashierName<>'' then begin
       ovObject.setParam(1021, FCashierName);
       //���� ����������<>"" �����
 		   // ovObject.setParam(1203, ����������);
       //���������;
       ovObject.operatorLogin;
      end;

	    ovObject.setParam(ovObject.LIBFPTR_PARAM_REPORT_TYPE, ovObject.LIBFPTR_RT_CLOSE_SHIFT);
    	ovObject.report;

  		//����������������������� =	ovObject.errorDescription;
	  	//������������������		= 	ovObject.errorCode;
     finally
      Sleep(300);
     end;
      if not CheckFRResult(':: Z-REPORT ::') then
         Exit;

      Report := True;
    end;

    if (FsModel = 'Shtrih') then begin
       try
         ovObject.PrintReportWithCleaning;
       finally
         Sleep(300);
       end;

       if not CheckFRResult(':: Z-REPORT ::') then
          Exit;

       Report := True;
    end;

    if (FsModel = 'MStar') then begin
       try
         ovObject.PrintReportWithCleaning;
       finally
         Sleep(300);
       end;

       if not CheckFRResult(':: Z-REPORT ::') then
          Exit;

       Report := True;
    end;

    if (FsModel = 'Felix02') then begin

       ovObject.Mode := 3;
       ovObject.SetMode;
       ovObject.ReportType := 1;
       try
         ovObject.Report;
       finally
         Sleep(300);
       end;

       if not CheckFRResult(':: Z-REPORT ::') then
          Exit;

       Report := True;
    end;

    if (FsModel = 'Mercury') then begin

       try
         ovObject.ZReport(1);
       finally
         Sleep(300);
       end;

       if not CheckFRResult(':: Z-REPORT ::') then
          Exit;

       ovObject.OpenDay(0, '������1', True, 0);
       Report := True;
    end;

    if Assigned(ocObject) then begin

       ocObject.PrintReportWithCleaning;
       if not CheckFRResult(':: Z-REPORT ::') then
          Exit;

       ocObject.OpenSession;
       Report := True;
    end;

  end else begin

    if (FsModel = 'Atol10') then begin
      try
        if FCashierName<>'' then begin
         ovObject.setParam(1021, FCashierName);
         //���� ����������<>"" �����
 		     // ovObject.setParam(1203, ����������);
         //���������;
         ovObject.operatorLogin;
        end;

  	    ovObject.setParam(ovObject.LIBFPTR_PARAM_REPORT_TYPE, ovObject.LIBFPTR_RT_X);
      	ovObject.report;
      finally
        Sleep(300);
      end;

		  //����������������������� =	������.errorDescription;
		  //������������������		= 	������.errorCode;

	  	//���� ������������������ = ������.LIBFPTR_OK �����
	  	//	��� = 1;
	  	//�����
       if not CheckFRResult(':: X-REPORT ::') then
          Exit;

       Report := True;

    end;

    if (FsModel = 'Shtrih') then begin
       try
         ovObject.PrintReportWithoutCleaning;
       finally
         Sleep(300);
       end;

       if not CheckFRResult(':: X-REPORT ::') then
          Exit;

       Report := True;
    end;

    if (FsModel = 'MStar') then begin
       try
         ovObject.PrintReportWithoutCleaning;
       finally
         Sleep(300);
       end;

       if not CheckFRResult(':: X-REPORT ::') then
          Exit;

       Report := True;
    end;

    if (FsModel = 'Felix02') then begin

       ovObject.Mode := 2;
       ovObject.SetMode;
       ovObject.ReportType := 2;
       try
         ovObject.Report;
       finally
         Sleep(300);
       end;

       if not CheckFRResult(':: X-REPORT ::') then
          Exit;

       Report := True;
    end;


    if (FsModel = 'Mercury') then begin

       try
         ovObject.XReport(1);
       finally
         Sleep(300);
       end;

       if not CheckFRResult(':: X-REPORT ::') then
          Exit;

       ovObject.OpenDay(0, '������1', True, 0);
       Report := True;
    end;

    if Assigned(ocObject) then begin

       ocObject.PrintReportWithoutCleaning;
       if not CheckFRResult(':: X-REPORT ::') then
          Exit;

       ocObject.OpenSession;
       Report := True;
    end;

  end;
  WriteLogFile('Report-');

end;



function TVariantPrint.DReport(bClearing:Bool): Bool;
begin
  DReport := False;

    if Assigned(ocObject) then begin

       ocObject.PrintReportWithDeparts;
       if not CheckFRResult(':: DX-REPORT ::') then
          Exit;

//       ocObject.OpenSession;
       DReport := True;
    end;

end;




function TVariantPrint.GetDocIsActive: Bool; // MMSKVCL ONLY, all another is always true
begin
  if Assigned(ocObject) then
     GetDocIsActive := ocObject.DocIsActive
  else
     GetDocIsActive := True;
end;

function TVariantPrint.DepartReport(): Bool;
begin
  DepartReport := false;
  if FsModel = 'Atol10' then begin
    try
      ovObject.setParam(ovObject.LIBFPTR_PARAM_REPORT_TYPE, ovObject.LIBFPTR_RT_OFD_EXCHANGE_STATUS);
      ovObject.report;
    finally
      sleep(100);
    end;
  end;
  if FsModel = 'Shtrih' then begin
    try
      ovObject.PrintDepartmentReport;
    finally
      sleep(100);
    end;
    if not CheckFRResult(':: D-REPORT ::') then
       Exit;
  end;
  if FsModel = 'Mercury' then begin
    try
      ovObject.XReportByDep(-1, 1);
    finally
      sleep(100);
    end;
    if not CheckFRResult(':: D-REPORT ::') then
       Exit;
  end;

    if Assigned(ocObject) then begin

       ocObject.PrintReportWithDeparts;
       if not CheckFRResult(':: DX-REPORT ::') then
          Exit;

//       ocObject.OpenSession;
       DepartReport := True;
    end;

end;

function TVariantPrint.WaitForPrinting(): Bool;
var iC: integer;
    bRes: bool;
begin
  WriteLogFile('waitforprinting+');
  bRes := false;
  if FsModel = 'Shtrih' then begin
    for iC := 1 to 10 do begin
      try
        ovObject.GetShortECRStatus;
      finally
        WriteLogFile('t-f:EAM=' + IntToStr(ovObject.ECRAdvancedMode));
      end;
      if ovObject.ECRAdvancedMode < 1 then begin
        bRes := true;
        break;
      end;
      sleep(250);
    end;
  end;
  WaitForPrinting := bRes;
  WriteLogFile('waitforprinting-');
end;

end.



