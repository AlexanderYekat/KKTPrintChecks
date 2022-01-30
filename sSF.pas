unit sSF;

interface

uses Windows, Classes, Graphics, ComCtrls, SysUtils, Db;

type
  PItemRec = ^TItemRec;
  TItemRec = record
    Id, IsParent, ParentId, Level: integer;
  end;

procedure WriteLogFile(sMsg: string);
function BarCodeCS(Value: string): char;
function Sign(Signed: Integer): Integer;
function IIf(bCondition: Boolean; vTrueResult, vFalseResult: Variant): Variant;
function TreeLocate(tvGroups: TTreeView; iCurrParent: Integer): TTreeNode;
function TreeRecurseVerify(tvGroups: TTreeView; iSource: Integer; iTarget: Integer): Boolean;
function RoundFloat(Value, RoundToNearest: Double): Double;
function NameTypeConversion(Value: String): TFieldType;
function hStr2Str(sHexData: string): string;
function ThisVersionInfo(sAppExeName: PChar): string;

implementation

procedure WriteLogFile(sMsg: string);
var stDateTime: TSystemTime;
    fsExternal: TFileStream;
    sMsgLine: string;
    pcBuf: PChar;
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
                    FormatFloat('00', stDateTime.wMinute) + ' | ' + sMsg + #$0D#$0A#$00;
  StringReplace(sMsgLine, #$D#$A, '                 '#$D#$A, [rfReplaceAll]);
  pcBuf := PChar(sMsgLine);
  fsExternal.Write(pcBuf^, Length(sMsgLine));

  fsExternal.Destroy;
end;

function BarCodeCS(Value: string): char;
var wCntr, wEvens, wOdds, wSum, wNear, wValLen: Word;
begin
  wEvens := 0;
  wOdds := 0;
  wValLen := Length(Value);

  if wValLen > 3 then begin

    for wCntr := wValLen-1 downto 1 do begin
      if (wValLen - wCntr - 1) / 2 = Trunc((wValLen - wCntr - 1) / 2) then
        wEvens := wEvens + StrToInt(Value[wCntr])
      else
        wOdds := wOdds + StrToInt(Value[wCntr]);
    end;

    wSum := wEvens * 3 + wOdds;
    wNear := Trunc(wSum / 10) * 10;
    if wNear < wSum then wNear := wNear + 10;
    Result := IntToStr(wNear - wSum)[1];

  end else Result:='0';
end;

function Sign(Signed: Integer): Integer;
begin
  if Signed > 0 then
    result := 1
  else
    if Signed = 0 then
      result := 0
    else
      result := -1;
end;

function IIf(bCondition: Boolean; vTrueResult, vFalseResult: Variant): Variant;
begin
  if bCondition=True then
    Result := vTrueResult
  else
    Result := vFalseResult;
end;

function TreeLocate(tvGroups: TTreeView; iCurrParent: Integer): TTreeNode;
var iCounter: Integer;
    irSelect: PItemRec;
begin
  Result := tvGroups.Selected; //Items[0];
  for iCounter := 0 to tvGroups.Items.Count-1 do begin
    irSelect := tvGroups.Items[iCounter].Data;
    if irSelect^.Id = iCurrParent then begin
      Result := tvGroups.Items[iCounter];
      Break;
    end;
  end;
end;

function TreeRecurseVerify(tvGroups: TTreeView; iSource: Integer; iTarget: Integer):Boolean;
var irSelect: PItemRec;
    tnCurrNode: TTreeNode;
begin
  Result := False;
  tnCurrNode := TreeLocate(tvGroups, iTarget);
  irSelect := tnCurrNode.Data;
  while irSelect^.Id <> 0 do begin
    if irSelect^.Id = iSource then
      Result := True;
    tnCurrNode := tnCurrNode.Parent;
    irSelect := tnCurrNode.Data;
  end;
end;

function RoundFloat(Value, RoundToNearest: Double): Double;
var
  dvx, int_val, frac_val: Double;
begin
  if RoundToNearest<>0 then begin
    dvx := Value/RoundToNearest;
    int_val := Int(dvx);
    frac_val := Frac(dvx);
    if not (frac_val+0.5000001<1) then
      int_val:=int_val+1; //inc();
    Result := int_val * RoundToNearest;
  end else
    Result:=Value;
end;

function NameTypeConversion(Value: String): TFieldType;
begin
  if Value = 'Integer' then Result := ftInteger else
  if Value = 'Currency' then Result := ftCurrency else
  if Value = 'Float' then Result := ftFloat else
  if Value = 'String' then Result := ftString else
  if Value = 'Date' then Result := ftDateTime else
  Result := ftVariant;
end;

function hStr2Str(sHexData: string): string;
var wDivPos: Word;
    sSubStr, sResStr: string;
begin
  wDivPos := 0; sResStr := '';
  while wDivPos <> $FF do begin
        wDivPos := Pos(#$20, sHexData);
        if wDivPos = 0 then
           wDivPos := $FF;
        sSubStr := Copy(sHexData, 1, (wDivPos-1));
        if Length(sSubStr) <> 0 then
           if sSubStr[1] in ['0'..'9'] then
              sResStr := sResStr + Chr(StrToInt(sSubStr))
           else
              sResStr := sResStr + sSubStr;
        Delete(sHexData, 1, wDivPos);
  end;
  hStr2Str := sResStr;
end;


function ThisVersionInfo(sAppExeName: PChar): string;
var fvHandle,fvSize: DWord;
    fvData: PChar;
    Len: Cardinal;
    pTrStr,Value: Pointer;
    szName: array[0..255] of Char;
begin
  fvSize:=GetFileVersionInfoSize(sAppExeName, fvHandle);
  GetMem(fvData,fvSize);
  GetFileVersionInfo(sAppExeName, fvHandle, fvSize, fvData);
  VerQueryValue(fvData, '\VarFileInfo\Translation', pTrStr, Len);
  StrPCopy(szName,'\StringFileInfo\'+IntToHex(MakeLong(HiWord(Longint(pTrStr^)), LoWord(Longint(pTrStr^))), 8)+'\FileVersion');
  VerQueryValue(fvData, szName, Value, Len);
  Result := 'v'+StrPas(PChar(Value));
  FreeMem(fvData,fvSize);
end;

end.
