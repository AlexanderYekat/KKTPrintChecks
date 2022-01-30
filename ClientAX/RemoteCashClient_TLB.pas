unit RemoteCashClient_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : 1.2
// File generated on 09.12.2021 15:31:27 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\musor\Тесленко\CashBrOpytDelphi7_4ФФД1_2\ClientAX\RemoteCashClient.tlb (1)
// LIBID: {6F9B71F3-1B46-448D-969F-C50FDC52A9D1}
// LCID: 0
// Helpfile: 
// HelpString: Project1 Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  RemoteCashClientMajorVersion = 3;
  RemoteCashClientMinorVersion = 0;

  LIBID_RemoteCashClient: TGUID = '{6F9B71F3-1B46-448D-969F-C50FDC52A9D1}';

  IID_IRemoteCashClient: TGUID = '{95A9A785-36C1-46D4-8286-AEEC157E60D6}';
  CLASS_CRemoteCashClient: TGUID = '{EFDF7EA9-C34B-4D0D-8C4E-37381C3D8D4E}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IRemoteCashClient = interface;
  IRemoteCashClientDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  CRemoteCashClient = IRemoteCashClient;


// *********************************************************************//
// Interface: IRemoteCashClient
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {95A9A785-36C1-46D4-8286-AEEC157E60D6}
// *********************************************************************//
  IRemoteCashClient = interface(IDispatch)
    ['{95A9A785-36C1-46D4-8286-AEEC157E60D6}']
    function Get_RemoteIP: WideString; safecall;
    procedure Set_RemoteIP(const Value: WideString); safecall;
    function Get_RemotePort: SYSINT; safecall;
    procedure Set_RemotePort(Value: SYSINT); safecall;
    function Get_SenderId: SYSINT; safecall;
    procedure Set_SenderId(Value: SYSINT); safecall;
    function Get_CmdId: SYSINT; safecall;
    procedure Set_CmdId(Value: SYSINT); safecall;
    function Get_Font: SYSINT; safecall;
    procedure Set_Font(Value: SYSINT); safecall;
    function Get_Text: WideString; safecall;
    procedure Set_Text(const Value: WideString); safecall;
    function Get_Qty: Double; safecall;
    procedure Set_Qty(Value: Double); safecall;
    function Get_Price: Double; safecall;
    procedure Set_Price(Value: Double); safecall;
    procedure SendCmd; safecall;
    function Get_OwnerWnd: SYSUINT; safecall;
    procedure Set_OwnerWnd(Value: SYSUINT); safecall;
    function Get_SendRes: SYSINT; safecall;
    function Get_Depart: SYSINT; safecall;
    procedure Set_Depart(Value: SYSINT); safecall;
    function Get_KeepAlive: SYSINT; safecall;
    procedure Set_KeepAlive(Value: SYSINT); safecall;
    function Get_InternalMSGs: SYSINT; safecall;
    procedure Set_InternalMSGs(Value: SYSINT); safecall;
    function Get_Tax1: SYSINT; safecall;
    procedure Set_Tax1(Value: SYSINT); safecall;
    function Get_TimeOut: SYSINT; safecall;
    procedure Set_TimeOut(Value: SYSINT); safecall;
    function Get_LogEvents: SYSINT; safecall;
    procedure Set_LogEvents(Value: SYSINT); safecall;
    function Get_LastNDoc: SYSINT; safecall;
    procedure Set_LastNDoc(Value: SYSINT); safecall;
    function Get_WaitNDoc: SYSINT; safecall;
    procedure Set_WaitNDoc(Value: SYSINT); safecall;
    function Get_TPayment: SYSINT; safecall;
    procedure Set_TPayment(Value: SYSINT); safecall;
    procedure AddLine(SenderId: SYSINT; CmdId: SYSINT; Depart: SYSINT; const Text: WideString; 
                      Qty100x: SYSINT; Price100x: SYSINT; Tax1: SYSINT; TPayment: SYSINT; 
                      NFont: SYSINT; const matrix: WideString; excise: SYSINT; SNO: Integer); safecall;
    procedure SendBuff; safecall;
    function Get_matrix: WideString; safecall;
    procedure Set_matrix(const Value: WideString); safecall;
    function Get_GTIN: WideString; safecall;
    procedure Set_GTIN(const Value: WideString); safecall;
    function Get_Serial: WideString; safecall;
    procedure Set_Serial(const Value: WideString); safecall;
    function Get_excise: SYSINT; safecall;
    procedure Set_excise(Value: SYSINT); safecall;
    function Get_SNO: SYSINT; safecall;
    procedure Set_SNO(Value: SYSINT); safecall;
    function Get_tail: WideString; safecall;
    procedure Set_tail(const Value: WideString); safecall;
    property RemoteIP: WideString read Get_RemoteIP write Set_RemoteIP;
    property RemotePort: SYSINT read Get_RemotePort write Set_RemotePort;
    property SenderId: SYSINT read Get_SenderId write Set_SenderId;
    property CmdId: SYSINT read Get_CmdId write Set_CmdId;
    property Font: SYSINT read Get_Font write Set_Font;
    property Text: WideString read Get_Text write Set_Text;
    property Qty: Double read Get_Qty write Set_Qty;
    property Price: Double read Get_Price write Set_Price;
    property OwnerWnd: SYSUINT read Get_OwnerWnd write Set_OwnerWnd;
    property SendRes: SYSINT read Get_SendRes;
    property Depart: SYSINT read Get_Depart write Set_Depart;
    property KeepAlive: SYSINT read Get_KeepAlive write Set_KeepAlive;
    property InternalMSGs: SYSINT read Get_InternalMSGs write Set_InternalMSGs;
    property Tax1: SYSINT read Get_Tax1 write Set_Tax1;
    property TimeOut: SYSINT read Get_TimeOut write Set_TimeOut;
    property LogEvents: SYSINT read Get_LogEvents write Set_LogEvents;
    property LastNDoc: SYSINT read Get_LastNDoc write Set_LastNDoc;
    property WaitNDoc: SYSINT read Get_WaitNDoc write Set_WaitNDoc;
    property TPayment: SYSINT read Get_TPayment write Set_TPayment;
    property matrix: WideString read Get_matrix write Set_matrix;
    property GTIN: WideString read Get_GTIN write Set_GTIN;
    property Serial: WideString read Get_Serial write Set_Serial;
    property excise: SYSINT read Get_excise write Set_excise;
    property SNO: SYSINT read Get_SNO write Set_SNO;
    property tail: WideString read Get_tail write Set_tail;
  end;

// *********************************************************************//
// DispIntf:  IRemoteCashClientDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {95A9A785-36C1-46D4-8286-AEEC157E60D6}
// *********************************************************************//
  IRemoteCashClientDisp = dispinterface
    ['{95A9A785-36C1-46D4-8286-AEEC157E60D6}']
    property RemoteIP: WideString dispid 1;
    property RemotePort: SYSINT dispid 2;
    property SenderId: SYSINT dispid 3;
    property CmdId: SYSINT dispid 4;
    property Font: SYSINT dispid 5;
    property Text: WideString dispid 6;
    property Qty: Double dispid 7;
    property Price: Double dispid 8;
    procedure SendCmd; dispid 9;
    property OwnerWnd: SYSUINT dispid 20;
    property SendRes: SYSINT readonly dispid 11;
    property Depart: SYSINT dispid 10;
    property KeepAlive: SYSINT dispid 12;
    property InternalMSGs: SYSINT dispid 13;
    property Tax1: SYSINT dispid 14;
    property TimeOut: SYSINT dispid 15;
    property LogEvents: SYSINT dispid 16;
    property LastNDoc: SYSINT dispid 17;
    property WaitNDoc: SYSINT dispid 18;
    property TPayment: SYSINT dispid 19;
    procedure AddLine(SenderId: SYSINT; CmdId: SYSINT; Depart: SYSINT; const Text: WideString; 
                      Qty100x: SYSINT; Price100x: SYSINT; Tax1: SYSINT; TPayment: SYSINT; 
                      NFont: SYSINT; const matrix: WideString; excise: SYSINT; SNO: Integer); dispid 21;
    procedure SendBuff; dispid 22;
    property matrix: WideString dispid 201;
    property GTIN: WideString dispid 202;
    property Serial: WideString dispid 203;
    property excise: SYSINT dispid 204;
    property SNO: SYSINT dispid 205;
    property tail: WideString dispid 206;
  end;

// *********************************************************************//
// The Class CoCRemoteCashClient provides a Create and CreateRemote method to          
// create instances of the default interface IRemoteCashClient exposed by              
// the CoClass CRemoteCashClient. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCRemoteCashClient = class
    class function Create: IRemoteCashClient;
    class function CreateRemote(const MachineName: string): IRemoteCashClient;
  end;

implementation

uses ComObj;

class function CoCRemoteCashClient.Create: IRemoteCashClient;
begin
  Result := CreateComObject(CLASS_CRemoteCashClient) as IRemoteCashClient;
end;

class function CoCRemoteCashClient.CreateRemote(const MachineName: string): IRemoteCashClient;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CRemoteCashClient) as IRemoteCashClient;
end;

end.
