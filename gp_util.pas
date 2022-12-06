
unit GP_Util;

interface

uses GP_Cnst,Strings,WinTypes,WinProcs,Objects,WinDos,WinCrt,ODialogs,BWCC;

type

 TVersion       = record WinMajor,WinMinor,DosMinor,DosMajor:Byte;end;

type
 PArrow         = ^Arrow;
 Arrow          = array[1..3] of TPoint;

 PArc           = ^Arc;
 Arc            = array[1..20] of TPoint;

 FileNameType      = array[0..fsPathName] of Char;

 PSignature     = ^TSignature;
 TSignature     = object(TObject)
  Value         : LongInt;
  constructor Init(AValue:LongInt);
 end;

function ValidInt(AStr:PChar):LongInt;

function ValidReal(AStr:PChar):Real;

function ShowStrIndex(AStr:PChar):Integer;

function ShowStringPart(AStrP:PChar;Pos,Len:Byte):PChar;

function StrLenAdjust(AStr:PChar;Alength{Mult:Byte}:Word):PChar;

function ShowDate(AYear,AMonth,ADay:Word):LongInt;

function HeapFunc(Size:Word):Integer;far;

function FindResChar(PlayerCount:Integer;IsNormal:Boolean):PChar;

function MyChar(Index:Byte):Char;

function NewOrd(Index:Byte):Byte;

function ScreenName(AName:PChar):PChar;

procedure Delay(MSecs: LongInt);

procedure MakeCoef(h0,h1,h2:Real;var c0,c1,c2:Real);

function StringRawReal(X:Real):PChar;

function StringReal(X:Real;ALength:Byte):PChar;

function StringProba(X:Real;ALength:Byte):PChar;

function Sign(x:Real):Real;

function Min(I,J:Integer):Integer;

function Max(I,J:Integer):Integer;

function MaxRect(Rect1,Rect2:PRect):PRect;

function WhatIsWrong(AWindow:THandle;AReason:PChar):Boolean;

function GoodSoFar(AWindow:THandle;AMarker:PChar):Boolean;

function Truncate(AReal:Real;var Flag:Boolean):Real;

function Exponential(AReal:Real):Real;

function Logarithm(AReal:Real):Real;

function SafeMultiply(First,Second:Real):Real;

function Multiply(First,Second:Real):Real;

function LowTruncate(AReal:Real):Real;          {Used in GP_Graph}

function SubsetCount(ACount:Byte):Byte;

implementation

{-------------------------------------------------------------------}
{ Next Subset takes a current subset and generates the next one of  }
{ current size within set of current cardinal. It returns TRUE when }
{ no more such subset can be found.                                 }
{-------------------------------------------------------------------}

 function ValidInt(AStr:PChar):LongInt;  {Eliminates ' ' at end of AStr}
 var AText: NameType; AnInt:LongInt; I,ACode:Integer;
 begin
  I:=NameSize; ValidInt:=0;
  repeat
   StrLCopy(AText,AStr,I);
   Val(AText,AnInt,ACode);
   I:=I-1;
  until (ACode=0) or (I=0);
  if ACode=0 then ValidInt:=AnInt;
 end;

 function ValidReal(AStr:PChar):Real;  {Eliminates ' ' at end of AStr}
 var AText: NameType; AReal:Real; I,ACode:Integer;
 begin
  I:=NameSize; ValidReal:=0;
  repeat
   StrLCopy(AText,AStr,I);
   Val(AText,AReal,ACode);
   I:=I-1;
  until (ACode=0) or (I=0);
  if ACode=0 then ValidReal:=AReal;
 end;

 function ShowStrIndex(AStr:PChar):Integer;
 var I:Integer;
 begin
   I:=0;
   if StrLComp(AStr,'GAM',3)=0 then I:=1;
   if StrLComp(AStr,'PLA',3)=0 then I:=2;
   if StrLComp(AStr,'NOD',3)=0 then I:=3;
   if StrLComp(AStr,'MOV',3)=0 then I:=4;
   if StrLComp(AStr,'INF',3)=0 then I:=5;
   if StrLComp(AStr,'STR',3)=0 then I:=6;
   if StrLComp(AStr,'CEL',3)=0 then I:=7;
   if StrLComp(AStr,'PAY',3)=0 then I:=9;

   ShowStrIndex:=I;
 end;

 function ShowStringPart(AStrP:PChar;Pos,Len:Byte):PChar;
 var TPos,TLen:Byte; AStr:HugeName;
 begin
   if Pos>StrLen(AStrP) then TPos:=StrLen(AStrP) else TPos:=Pos;
   if Pos+Len>StrLen(AStrP) then TLen:=StrLen(AStrP)-TPos else TLen:=Len;
   StrLCopy(AStr,AStrP,TPos+TLen);
   ShowStringPart:=@AStr[TPos];
 end;

function StrLenAdjust(AStr:PChar;Alength:Word):PChar;
var TheString: HugeName; Index: Byte; TheLength:Word;
begin
 StrCopy(TheString,AStr);
 if ALength>StrLen(TheString)
 then begin
      TheLength:=ALength-StrLen(TheString);
      if TheLength>0 then repeat
         TheLength:=TheLength-1;
         StrCat(TheString,' ');
      until TheLength=0;
 end;
 StrLenAdjust:=@TheString;
end;

constructor TSignature.Init(AValue:LongInt);
begin
 Value:=AValue;
end;

function ShowDate(AYear,AMonth,ADay:Word):LongInt;
begin
 ShowDate:=365*AYear+30*AMonth+ADay;
end;

 function HeapFunc(Size:Word):Integer;
 begin
  HeapFunc:=1;
 end;

function FindResChar(PlayerCount:Integer;IsNormal:Boolean):PChar;
var AResource:array[0..15] of Char;
begin
  if IsNormal
  then case PlayerCount of
   1:StrCopy(AResource,'Normal_Dlg1');
   2:StrCopy(AResource,'Normal_Dlg2');
   3:StrCopy(AResource,'Normal_Dlg3');
  end else case PlayerCount of
   1:StrCopy(AResource,'Outcome_Dlg1');
   2:StrCopy(AResource,'Outcome_Dlg2');
   3:StrCopy(AResource,'Outcome_Dlg3');
   4:StrCopy(AResource,'Outcome_Dlg4');
  end;
  FindResChar:=@AResource;
end;

function MyChar(Index:Byte):Char;  {0<=Index<=34 gives 35 true char}
var AChar:Char;
begin
 if (Index<=9)
 then AChar:=Chr(48+Index)
 else if (Index<=23)
      then AChar:=Chr(55+Index)
      else if (Index<=34)
           then AChar:=Chr(56+Index)
           else AChar:='0';
 MyChar:=AChar;
end;

function NewOrd(Index:Byte):Byte;  {Maps byte into 0<=NewOrd<=35}
begin
 case Index of
  48..57: NewOrd:=Index-48;
  65..78: NewOrd:=Index-55;
  80..90: NewOrd:=Index-56;
   else NewOrd:=35;
 end;
end;

function ScreenName(AName:PChar):PChar;
var I,J,L:Byte;TestChar: Char; TestName,NewName: array[0..60] of Char;
 function PassTest(AChar:Char):Boolean;
 var Order:Byte;
 begin
  Order:=Ord(AChar);
  if (Order<48)
  or ((Order>57) and (Order<65))
  or (Order>90)
  then PassTest:=False
  else PassTest:=True;
 end;
begin
  StrCopy(NewName,'');
  StrCopy(TestName,StrUpper(AName));
  L:=StrLen(TestName);
  J:=0;
  for I:=1 to L
  do begin
   TestChar:=TestName[I-1];
   if PassTest(TestChar)
   then begin
    StrCat(NewName,' ');
    NewName[J]:=TestChar;
    J:=J+1;
   end;
  end;
  ScreenName:=@NewName;
end;

procedure Delay(MSecs: LongInt);
var Mark:LongInt;
begin
  Mark:=GetTickCount+MSecs;
  repeat {Wait} until GetTickCount>=Mark;
end;

procedure MakeCoef(h0,h1,h2:Real;var c0,c1,c2:Real);
var d:Real;
begin     {Calculate coefficients of multistep method}
 if h1=0  {1-step case}
 then begin
  c0:=h0; c1:=0; c2:=0;
 end else if h2=0  {2-step case}
          then begin
           c2:=0; c1:=-0.5*h0*h0/h1; c0:=h0-c1;
          end else begin  {3-step case}
           d:=h0*h0/h2/6;
           c2:=d*(2*h0+3*h1)/(h1+h2);
           c1:=-d*(2*h0+3*h1+3*h2)/h1;
           c0:=h0-c1-c2;
          end;
end;

function ShortRound(X:Real;ALength:Byte):Real;
var Index:Byte;
begin
 ShortRound:=X;
 if (ABS(X)>100.0) then Exit; {Because 2.0E+9 is not a LongInt}
 if ALength<=3 then ALength:=3;
 if ALength>=7 then ALength:=7;
 for Index:=1 to ALength do X:=10*X;
 X:=Round(X);
 for Index:=1 to ALength do X:=0.1*X;
 ShortRound:=X;
end;

function StringReal(X:Real;ALength:Byte):PChar;
var XName,
    ExpName,
    MantName    : array[0..24] of Char;
    Mantissa    : Real;
    ErrorCode,
    Exponent    :Integer;
begin
 if ALength<=4 then ALength:=4;
 if ALength>=10 then ALength:=10;     {Allow no more than 4 digits}
 Str(X,XName);                        {Make X into string}
 StrCopy(ExpName,StrScan(XName,'E'));   {Find the E... part of XName}
 StrCopy(ExpName,@ExpName[1]);             {Keep E+/- part}
 val(ExpName,Exponent,ErrorCode);
 if ErrorCode=0
 then begin
  StrLCopy(MantName,XName,ALength+1);     {Begin rounding off}
  val(MantName,Mantissa,ErrorCode);
  if ErrorCode=0
  then begin
   Mantissa:=ShortRound(Mantissa,ALength-3);
   if ABS(Mantissa)=10.0
   then begin
    Mantissa:=0.1*Mantissa;
    Exponent:=Exponent+1;
   end;
   Str(Mantissa,XName);
   StrLCopy(XName,XName,ALength);       {End rounding off}
   if Exponent>=0 then StrCat(XName,'E+');
   if Exponent<0
   then begin
    StrCat(XName,'E-');
    Exponent:=-Exponent;
   end;
   if Exponent<10 then StrCat(XName,'0');
   Str(Exponent,ExpName);
   StrCat(XName,ExpName);
  end else StrCopy(XName,'ERROR');
 end else StrCopy(XName,'ERROR');
 StringReal:=@XName
end;

function StringRawReal(X:Real):PChar;
var XName: array[0..36] of Char;
begin
 Str(X,XName);                        {Make X into string}
 StringRawReal:=@XName
end;

function StringProba(X:Real;ALength:Byte):PChar;
var XName,
    YName,
    EName,
    ZName  : array[0..24] of Char;  {Want [0..ALength]}
    Index,
    ErrorCode,
    Exponent:Integer;
begin
 if ALength<=4 then ALength:=4;
 if ALength>=10 then ALength:=10;     {Allow no more than 4 digits}
 StrCopy(XName,StringReal(X,ALength));
 val(XName,X,ErrorCode);
 {X:=ShortRound(X,ALength); }
 if (X>0) and (X<1)
 then begin
  StrCopy(XName,StringReal(X,ALength));
  StrCopy(EName,StrScan(XName,'E'));  {Copy E-xxx into EName}
  StrCopy(EName,@EName[2]);           {Keep positive exponent only}
  val(EName,Exponent,ErrorCode);      {Convert to numeric value}
  StrCopy(ZName,'0.');
  for Index:=2 to 20 do StrCat(ZName,'0');
  if Exponent<=10
  then begin
   ZName[1+Exponent]:=XName[1];
   for Index:=3 to ALength-1
   do ZName[Index+Exponent-1]:=XName[Index];
  end;
 end else begin
  if (X<0) or (X>1)
  then StrCopy(ZName,'ERROR')
  else begin
   if (X=0) then StrCopy(ZName,'0.')
            else StrCopy(ZName,'1.');
   for Index:=2 to ALength do StrCat(ZName,'0');
  end;
 end;
 StrLCopy(ZName,ZName,ALength);
 StringProba:=@ZName;
end;

function OldStringProba(X:Real;ALength:Byte):PChar;
var EName,
    XName,
    YName,
    ZName  : array[0..24] of Char;
    Index,
    ErrorCode,
    Exponent:Integer;
begin
 X:=ShortRound(X,ALength-2);
 if (X>0) and (X<1)
 then begin
  Str(X,XName);
  StrCopy(EName,StrScan(XName,'E'));
  StrCopy(EName,@EName[2]);
  val(EName,Exponent,ErrorCode);
  if (Exponent>ALength-1) then Exponent:=ALength-1;
  StrCopy(ZName,'0.');
  for Index:=1 to Exponent-1
  do StrCat(ZName,'0');
  StrLCopy(YNAme,@XName[1],1);
  StrCat(ZName,YName);
  if (ALength>=Exponent+3)
  then begin
   StrLCopy(YNAme,@XName[3],ALength-Exponent-2);
   StrCat(ZName,YName);
  end;
 end else
     if X=0
     then begin
      StrCopy(ZName,'0.');
      for Index:=1 to ALength-2 do StrCat(ZName,'0');
     end else if X=1
          then begin
           StrCopy(ZName,'1.');
           for Index:=1 to ALength-2 do StrCat(ZName,'0');
          end else StrCopy(ZName,'ERROR');
 OldStringProba:=@ZName;
end;

function Sign(x:Real):Real;
begin
 if x>0
 then Sign:=1
 else if x<0
      then Sign:=-1
      else Sign:=0;
end;

function Min;
begin
 if I>=J then Min:=J else Min:=I;
end;

function Max;
begin
 if I>=J then Max:=I else Max:=J;
end;

function MaxRect;
var ARect:TRect;
begin
 ARect.left:=Min(Rect1^.left,Rect2^.left);
 ARect.right:=Max(Rect1^.right,Rect2^.right);
 ARect.top:=Min(Rect1^.top,Rect2^.top);
 ARect.bottom:=Max(Rect1^.bottom,Rect2^.bottom);
 MaxRect:=@ARect;
end;

function WhatIsWrong;
begin
 MessageBeep(0);
 MessageBox(AWindow,AReason,'WARNING',mb_Ok or mb_IconStop);
 WhatIsWrong:=True;
end;

function GoodSoFar(AWindow:THandle;AMarker:PChar):Boolean;
begin
 MessageBeep(0);
 MessageBox(AWindow,AMarker,'GOOD SO FAR',mb_Ok);
end;

function Truncate(AReal:Real;var Flag:Boolean):Real;
begin
 Flag:=False;
 if abs(AReal)<TinyDefault
 then Truncate:=0
 else if abs(AReal)<TopDefault
      then Truncate:=AReal
      else begin
            Flag:=True;
            if AReal>0
            then Truncate:=TopDefault
            else Truncate:=-TopDefault;
      end;
end;

function Exponential(AReal:Real):Real;
begin
 if AReal>70
 then Exponential:=TopDefault
 else if AReal<-70
      then Exponential:=TinyDefault
      else Exponential:=EXP(AReal);
end;

function Logarithm(AReal:Real):Real;
begin
 if AReal<TinyDefault
 then Logarithm:=-150
 else Logarithm:=LN(AReal);
end;

function SafeMultiply(First,Second:Real):Real;
var Sign:Boolean; F,S,P,Store:Real;
 procedure SignAndReorder;
 begin
  Sign:=False;
  if First<SafeZero
  then begin
   Sign:=True;
   F:=-First;
  end else F:=First;
  if Second<SafeZero
  then begin
   Sign:=not Sign;
   S:=-Second;
  end else S:=Second;
  if S<F
  then begin
   Store:=F;
   F:=S;
   S:=Store;
  end;
 end;
 procedure AdjustBounds;
 begin
  if (F<=SafeM36)
  then F:=SafeM36;
  if (S<=SafeM36)
  then S:=SafeM36;
  if (F>=SafeP36)
  then F:=SafeP36;
  if (S>=SafeP36)
  then S:=SafeP36;
 end;
begin
 SignAndReorder;
 if (F=SafeZero)
 then P:=SafeZero
 else if (F>=SafeM18)
      and (S<=SafeP18)
      then P:=F*S       {Product is safe}
      else begin        {Product is not safe}
       AdjustBounds;
       if (F<=SafeM30)
       then if (S<=SafeOne)
            then P:=SafeM30
            else P:=F*S
       else if (F<=SafeM24)
            then if (S<=SafeM06)
                 then P:=SafeM30
                 else P:=F*S
            else if (F<=SafeM18)
                 then if (S<=SafeM12)
                      then P:=SafeM30
                      else P:=F*S
                 else if (S>=SafeP30)
                      then if (F>=SafeOne)
                           then P:=SafeP30
                           else P:=F*S
                      else if (S>=SafeP24)
                           then if (F>=SafeP06)
                                then P:=SafeP30
                                else P:=F*S
                           else if (S>=SafeP18)
                                then if (F>=SafeP12)
                                     then P:=SafeP30
                                     else P:=F*S;
      end;
 if Sign
 then SafeMultiply:=-P
 else SafeMultiply:=P;
end;

function Multiply(First,Second:Real):Real;
var FirstFlag,SecondFlag:Boolean; TruncFirst,TruncSecond:Real;
begin
 TruncFirst:=Truncate(First,FirstFlag);
 TruncSecond:=Truncate(Second,SecondFlag);
 if FirstFlag or SecondFlag                     {First or Second is large}
 then if (TruncFirst=0) or (TruncSecond=0)      {One is very small}
      then Multiply:=0{Truncate(First*Second,FirstFlag)}
      else if TruncFirst>0
           then if TruncSecond>0
                then Multiply:=TopDefault
                else Multiply:=-TopDefault
           else if TruncSecond>0
                then Multiply:=-TopDefault
                else Multiply:=TopDefault
 else Multiply:=TruncFirst*TruncSecond;
end;

function LowTruncate(AReal:Real):Real;
begin
 if abs(AReal)<LowTruncation
 then LowTruncate:=0
 else if abs(AReal)<TopDefault
      then LowTruncate:=AReal
      else if AReal>0
           then LowTruncate:=TopDefault
           else LowTruncate:=-TopDefault;
end;

function SubsetCount(ACount:Byte):Byte;
var Index,Result:Byte;
begin
 if ACount>8 then begin SubsetCount:=0;Exit; end;
 if ACount=0 then SubsetCount:=0;
 Result:=1;Index:=0;
 repeat
  Result:=2*Result;
  Index:=Index+1;
 until Index=ACount;
 SubsetCount:=Result-1;
end;

begin
end.