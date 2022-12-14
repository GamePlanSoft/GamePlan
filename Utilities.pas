{Copyright (c), Jean-Pierre P. Langlois, 2007-2022}

unit Utilities;

interface

uses Windows, SysUtils, Classes, Graphics, Constants;

function IsEven(AnInt:Integer):Boolean;
function MaxInt(I1,I2:Integer):Integer;
function MinInt(I1,I2:Integer):Integer;
function MaxRect(R1,R2:TRect):TRect;
function Zoom(AnInput:Integer):Integer;
function UnZoom(AnInput:Integer):Integer;
procedure DotLine(ACanvas:TCanvas;FrX,FrY,ToX,ToY:Integer);
function GridFilt(AnInteger:Integer):Integer;
function ValidInt(AStr:String):Integer;
function ValidReal(AStr:String):Real;
function MyIntToStr(S:Integer):String;
function ShowStringPart(AStrP:String;Pos,Len:Integer):String;
procedure StrLenAdjust(ALength:Integer;var AStr:String);
procedure RealName(var AName:String);
function MakeInteger(AName:String):Integer;
function MakeScramble(S:Integer):Integer;
function MakeSerialPass(ACase,ADate,ASerial:Integer):Integer;
function TodaysDate:Integer;
{function NewPhi(Z:Integer):Integer; }
{function Phi(Z:Integer):Integer; }
function SpecialCode(ACode:String):Integer;

implementation

function IsEven(AnInt:Integer):Boolean;
begin
  IsEven:=True;
  if AnInt>2*Trunc(AnInt/2) then IsEven:=False;
end;

function MaxInt(I1,I2:Integer):Integer;
begin
  if I1>=I2 then MaxInt:=I1 else MaxInt:=I2;
end;

function MinInt(I1,I2:Integer):Integer;
begin
  if I1<=I2 then MinInt:=I1 else MinInt:=I2;
end;

function MaxRect(R1,R2:TRect):TRect;
var R:TRect;
begin
  with R do begin
    Left:=MinInt(MinInt(R1.Left,R2.Left),MinInt(R1.Right,R2.Right));
    Top:=MinInt(MinInt(R1.Top,R2.Top),MinInt(R1.Bottom,R2.Bottom));
    Right:=MaxInt(MaxInt(R1.Left,R2.Left),MaxInt(R1.Right,R2.Right));
    Bottom:=MaxInt(MaxInt(R1.Top,R2.Top),MaxInt(R1.Bottom,R2.Bottom));
  end;
  MaxRect:=R;
end;

function Zoom(AnInput:Integer):Integer;
begin
  Zoom:=Round(ZoomSize*AnInput);
end;

function UnZoom(AnInput:Integer):Integer;
begin
  UnZoom:=Round(AnInput/ZoomSize);
end;

procedure DotLine(ACanvas:TCanvas;FrX,FrY,ToX,ToY:Integer);
var DotSteps,Indx,DX,DY:Integer;
begin
  DotSteps:=Round(Sqrt(Sqr(ToX-FrX)+Sqr(ToY-FrY))/InfoStep);
  DX:=Round((ToX-FrX)/(2*DotSteps+1));
  DY:=Round((ToY-FrY)/(2*DotSteps+1));
  with ACanvas do for Indx:=1 to DotSteps do begin
    MoveTo(FrX-DX+2*Indx*DX,FrY-DY+2*Indx*DY);
    LineTo(FrX+2*Indx*DX,FrY+2*Indx*DY);
  end;
end;

function GridFilt(AnInteger:Integer):Integer;
begin
  GridFilt:=GridStep*Round(AnInteger/GridStep);
end;

function ValidInt(AStr:String):Integer;  {Eliminates ' ' at end of AStr}
var AnInt,I,ACode:Integer; VStr:String;
begin
  VStr:=AStr;
  I:=Length(VStr);
  repeat
   SetLength(VStr,I);
   Val(VStr,AnInt,ACode);
   I:=I-1;
  until (ACode=0) or (I<=0);
  if ACode=0 then ValidInt:=AnInt else ValidInt:=-1;
end;

function ValidReal(AStr:String):Real;
var AReal:Real;I,ACode:Integer; VStr:String;
begin
  VStr:=AStr;
  I:=Length(VStr);
  ValidReal:=0;
  repeat
   SetLength(VStr,I);
   Val(VStr,AReal,ACode);
   I:=I-1;
  until (ACode=0) or (I<=0);
  if ACode=0 then ValidReal:=AReal;
end;  

function ShowStringPart(AStrP:String;Pos,Len:Integer):String;
var Indx,TPos,TLen:Integer; AStr:String;
begin
   if Pos>Length(AStrP) then TPos:=Length(AStrP) else TPos:=Pos;
   if TPos+Len>Length(AStrP) then TLen:=Length(AStrP)-TPos else TLen:=Len;
   AStr:='';
   if (TPos+TLen>0)
   then for Indx:=TPos to (TPos+TLen-1)
        do AStr:=AStr+AStrP[Indx];
   ShowStringPart:=AStr;
end;

procedure StrLenAdjust(ALength:Integer;var AStr:String);
var LengthDiff:Integer;
begin
 if ALength>Length(AStr)
 then begin
      LengthDiff:=ALength-Length(AStr);
      if LengthDiff>0 then repeat
         LengthDiff:=LengthDiff-1;
         AStr:=AStr+' ';
      until LengthDiff=0;
 end else SetLength(AStr,ALength);
end;

procedure RealName(var AName:String);
var RealLength:Integer; IsRealName:Boolean;
begin
  RealLength:=Length(AName);
  IsRealName:=False;
  if RealLength>0 then repeat
    if AName[RealLength]=' '
    then RealLength:=RealLength-1
    else IsRealName:=True;
    SetLength(AName,RealLength);
  until IsRealName or (RealLength=0);
end;

function MakeInteger(AName:String):Integer;
var AnInt,ADigit,ALength,ECode,Iter:Integer; AChar:Char;
begin  {Produce an 8-digit integer from a string without zero digits}
  AnInt:=0; Iter:=0;
  ALength:=Length(AName);
  repeat
    AChar:=AName[ALength];
    Val(AChar,ADigit,ECode);
    if (ECode=0) and (ADigit<>0)
    then begin
      AnInt:=10*AnInt+ADigit;
      Iter:=Iter+1;
    end;
    ALength:=ALength-1
  until (ALength<=0) or (Iter>=ScrmblSize);
  if AnInt>0
  then MakeInteger:=AnInt
  else MakeInteger:=DfltID;
end;

function MakeScramble(S:Integer):Integer;
var Z:Real; D7,D8,Iter,i:Integer;
  function Phi(X:Real):Real;
  begin
    if Z<=0 then Z:=MinScrmbl;
    if Z>=1-MinScrmbl then Z:=1-MinScrmbl;
    Phi:=PhiMag*X*(1-X);;
  end;
begin
  if S<=0 then S:=1;
  if S>=ScrmblMag then S:=ScrmblMag-1;
  D8:=S-10*Trunc(S/10); {Last digit of S}
  D7:=S-100*Trunc(S/100)-D8; {Next to Last digit of S}
  Iter:=2+D7+D8;
  Z:=S/ScrmblMag;
  for i:=1 to Iter do Z:=Phi(Z);
  MakeScramble:=Trunc(Z*ScrmblMag);
end;

function TodaysDate:Integer;
var Y, M, D: Word;
begin
  DecodeDate(Date, Y, M, D);
  TodaysDate:=Y*TenK+M*Hundred+D;
end;

function MakeSerialPass(ACase,ADate,ASerial:Integer):Integer;
begin
  case ACase of
    rc_TryUser :MakeSerialPass:=MakeScramble(ASerial);
    rc_FullUser:MakeSerialPass:=MakeScramble(Trunc((2*ASerial+ADate)/3));
    rc_Forever :MakeSerialPass:=MakeScramble(Trunc((ASerial+2*ADate)/3));
    else MakeSerialPass:=0;
  end;
end;

function MyIntToStr(S:Integer):String;
var OutStr:String;
begin
  OutStr:=IntToStr(S);
  while Length(OutStr)<8 do OutStr:='0'+OutStr;
  MyIntToStr:=OutStr;
end;

{function Phi(Z:Integer):Integer;
begin
  if Z<=0 then Z:=MinPass;
  if Z>=PassMagn then Z:=PassMagn-MinPass;
  Phi:=Trunc(18*Z*(PassMagn-Z)/5/PassMagn);
end; }

function SpecialCode(ACode:String):Integer;
var  SC:Integer;
begin
  SC:=0;
  ACode:=UpperCase(ACode);
  if ACode='GUMSBCCL' then SC:=1234;
  if ACode='SFSUMJPL' then SC:=4321;
  SpecialCode:=SC;
end;

end.
