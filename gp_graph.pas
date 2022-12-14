{Copyright (c), Jean-Pierre P. Langlois, 2007-2022}

unit GP_Graph;
{$R MyStrings.res}

interface

uses GP_Glob,GP_Loop,GP_Type,GP_Cnst,Strings,WinDos,GP_Util,GP_File,
     OPrinter,OWindows,ODialogs,OStdDlgs,Objects,WinTypes,WinProcs;

 {----------------------------------------------}
 {----Graphics objects definition---------------}
 {----------------------------------------------}

type

 DispModeType   = array[0..15] of Boolean;

type

 PGameForm      = ^TGameForm;
 TGameForm      = object(TObject)
  TheEquilibrium : PEquilibrium;
  FormCase       : Byte;
  AName          : NameType;
  constructor Init(AFormCase:Byte;AnEquilibrium:PEquilibrium);
  destructor Done; virtual;
  procedure SelfDraw;
  procedure SketchTitle(TheDC:HDC;AnObject:PGameObject);
  procedure SketchComment(TheDC:HDC;AComment:PComment);
  procedure SketchPlayer(TheDC:HDC;APlayer:PPlayer);
  procedure SketchNode(TheDC:HDC;ANode:PNode;DisplayPlayer:PPlayer);
  procedure SketchInfo(TheDC:HDC;AnInfo:PInfo);
  procedure SketchMove(TheDC:HDC;AMove:PMove;AProba,AnIncent:Real;
                       Active,Freedom:Boolean;DisplayPlayer:PPlayer);
  procedure SketchStrategy(TheDC:HDC;AStrategy:PStrategy);
  procedure SketchCell(TheDC:HDC;ACell:PCell);
  procedure SketchEvolver(TheDC:HDC;AnEvolver:PEvolver);
  function ShowEquilibrium: PEquilibrium;
  procedure ShowGrid(TheDC:HDC);
  procedure SketchAxes(TheDC:HDC;HasTwoPop:Boolean);
  procedure SketchWeights(TheDC:HDC;AnEvolver:PEvolver);
  procedure ShowForm(ADC: HDC);
  {procedure SwitchForm;}
 end;

 PMakeStat      = ^TMakeStat;
 TMakeStat      = object(TObject)
  LineColl      : TCollection;
  NewLine       : PTextLine;
  AText         : HugeName;
  constructor Init;
  destructor Done; virtual;
  procedure MatchStat;
  procedure ReplicStat;
  procedure MakeLines;
  procedure EvolverStat;
  procedure EvObjectStat;
  procedure ShowLines(TheDC:HDC;Page:Word);
 end;

 procedure ShowBugs(PageNumber:Word;ADC:HDC);

 function MakeTitleRect(AnObject:PGameObject):PRect;
 function MakePlayerRect(AnObject:PGameObject):PRect;
 function MakeNodeRect(AnObject:PGameObject):PRect;
 function MakeMoveRect(AnObject:PGameObject):PRect;
 function MakeInfoRect(AnObject:PGameObject):PRect;
 function SizedX(X:Integer):Integer;
 function SizedY(Y:Integer):Integer;

 function IsVisibleRow(Row:Integer;Page:Word):Boolean;
 function Visible(Row:Integer;Page:Word):Integer;
 procedure ChangeSize(ASize:Integer);
 procedure ChangeHead(IsXHead:Boolean;AHead:Integer);

 procedure SelectPen(ADC:HDC;ASize:Byte;AColor:LongInt);
 procedure InitGraphUnit;
 procedure CleanupGraphUnit;

var

 ListFont,
 TheFont,
 MediumFont,
 LargeFont,
 CommentFont,
 SmallFont          : HFont;
 BlackBrush         : HBrush;
 TableBlackPen,
 DotGrayPen,
 BigBlackPen,
 MidBlackPen,
 BlackPen           : HPen;
 ThePen             : array[0..12] of HPen;
 TheBigPen          : array[0..MaxPlayerNumber] of HPen;
 TheBrush           : array[0..MaxPlayerNumber] of HBrush;

 Color              : array[0..12] of LongInt;
 GPText             : TLogFont;
 MouseLocus         : TPoint;
 DisplayMode       : DispModeType;
 DisplayPlayer     : PPlayer;
 Lin,
 LineMargin,
 LineNumber,
 LeftMargin,
 TopMargin,
 CellMargin,
 ColSpacing,             {**********************}
 RowSpacing,
 HalfCell,
 CellSpacing,
 DepSpacing,
 EdgeSpacing,
 AxisSpacing,
 CurveSpacing,
 GraphicSize,
 VertSize,
 HorzSize,
 HorzShift,
 XHead,YHead       : Integer;
 DisplaySize       : Real;
 ScrollUnit        : Integer;
 ScrollRange       : LongInt;
 IsPrinting        : Boolean;
 Printer           : PPrinter;

implementation

 {----------------------------------------------}
 {----Graphics objects implementation-----------}
 {----------------------------------------------}

 procedure SelectPen(ADC:HDC;ASize:Byte;AColor:LongInt);
 begin
  if ASize=sc_Big
  then SelectObject(ADC,BlackPen)
  else begin
  if AColor= cl_Blue then SelectObject(ADC,ThePen[0]);
  if AColor= cl_Red then SelectObject(ADC,ThePen[1]);
  if AColor= cl_Green then SelectObject(ADC,ThePen[2]);
  if AColor= cl_Black then SelectObject(ADC,ThePen[3]);
  if AColor= cl_Gray then SelectObject(ADC,ThePen[4]);
  if AColor= cl_Cyan then SelectObject(ADC,ThePen[5]);
  if AColor= cl_Pink then SelectObject(ADC,ThePen[6]);
  if AColor= cl_Yellow then SelectObject(ADC,ThePen[7]);
  if AColor= cl_Pastel then SelectObject(ADC,ThePen[8]);
  if AColor= cl_Purple then SelectObject(ADC,ThePen[9]);
  if AColor= cl_Khaki then SelectObject(ADC,ThePen[10]);
  if AColor= cl_Neon then SelectObject(ADC,ThePen[11]);
  if AColor= cl_White then SelectObject(ADC,ThePen[12]);
  end;
 end;

 procedure TGameForm.SketchAxes;
 var Shift:Byte; Correct:Real;
  procedure Dents;
  var I,J:Byte;
  begin
   SelectObject(TheDC,TheFont);
   SetTextColor(TheDC,Color[3]);
   if Generation<=10
   then begin
    J:=Generation;
    Correct:=1;
   end else begin
    J:=10;
    Correct:=Generation/10;
   end;
   for I:=0 to J do begin  {Make dents on horizontal}
    MoveTo(TheDC,SizedX((1+5*Shift)*AxisSpacing+Round(Correct*I)*HorzSize),SizedY(5*AxisSpacing));
    LineTo(TheDC,SizedX((1+5*Shift)*AxisSpacing+Round(Correct*I)*HorzSize),SizedY(5*AxisSpacing+5));   {Horizontal}
    Str(Round(Correct*I),AName);
    TextOut(TheDC,SizedX((1+5*Shift)*AxisSpacing+Round(Correct*I)*HorzSize),SizedY(5*AxisSpacing+10),AName,StrLen(AName));
   end;
   for I:=0 to 10 do begin         {Make dents on vertical}
    MoveTo(TheDC,SizedX((1+5*Shift)*AxisSpacing),SizedY(2*AxisSpacing+I*VertSize));
    LineTo(TheDC,SizedX((1+5*Shift)*AxisSpacing-5),SizedY(2*AxisSpacing+I*VertSize));
    SetTextColor(TheDC,Color[3]);
    Str(100-10*I,AName);
    TextOut(TheDC,SizedX((1+5*Shift)*AxisSpacing-20),SizedY(2*AxisSpacing+I*VertSize),AName,StrLen(AName));
   end;
   SelectObject(TheDC,CommentFont);
   StrCopy(AName,'%');
   TextOut(TheDC,SizedX((1+5*Shift)*AxisSpacing),SizedY(2*AxisSpacing-VertSize),AName,StrLen(AName));
   StrCopy(AName,'Steps');
   TextOut(TheDC,SizedX((4+5*Shift)*AxisSpacing+20),SizedY(5*AxisSpacing),AName,StrLen(AName));
  end;
 begin
  SelectPen(TheDC,sc_Big,0);
  for Shift:=0 to Byte(HasTwoPop) do begin
   MoveTo(TheDC,SizedX((1+5*Shift)*AxisSpacing),SizedY(5*AxisSpacing));
   LineTo(TheDC,SizedX((4+5*Shift)*AxisSpacing),SizedY(5*AxisSpacing));   {Horizontal}
   MoveTo(TheDC,SizedX((1+5*Shift)*AxisSpacing),SizedY(2*AxisSpacing));
   LineTo(TheDC,SizedX((1+5*Shift)*AxisSpacing),SizedY(5*AxisSpacing));     {Vertical}
   Dents;
  end;
 end;

 procedure TGameForm.SketchWeights(TheDC:HDC;AnEvolver:PEvolver);
 var IniRec:PPlayRec; IsRow:Boolean;
   function Height(AWeight:Real):Integer;
   var RealHeight:Real;
   begin
    RealHeight:=3*SafeMultiply((1-AWeight),AxisSpacing)-CurveSpacing;
    if ABS(RealHeight)>=30000
    then Height:=30000
    else Height:=Round(RealHeight);
   end;
   procedure ShowPlay(APlayRec:PPlayRec);far;
   begin
    if APlayRec<>nil
    then with APlayRec^
    do begin                           {Margin}
     LineTo(TheDC,SizedX(HorzShift),SizedY(2*AxisSpacing+Height(Weight)));
     HorzShift:=HorzShift+HorzSize;
    end;
   end;
 begin
  if AnEvolver<>nil
  then with AnEvolver^ do
  if PGameType(Game)^.IsSymmetric and (PGameType(Game)^.PlayerSet^.IndexOf(Owner)>0)
  then Exit {Don't repeat display}
  else begin
   SelectPen(TheDC,sc_Small,Color);
   IniRec:=PlayLog.At(0);
   if IniRec=nil then Exit;
   if IsForRow
   then HorzShift:=AxisSpacing
   else HorzShift:=6*AxisSpacing;
   MoveTo(TheDC,SizedX(HorzShift),SizedY(2*AxisSpacing+Height(Weight)));
   PlayLog.ForEach(@ShowPlay);
  end;
 end;

 constructor TGameForm.Init(AFormCase:Byte;AnEquilibrium:PEquilibrium);
 begin
   FormCase:=AFormCase;
   HorzSize:=Round(3*AxisSpacing/Generation); {ForAxes drawing}
   if FormCase in [gf_GraphSol,gf_TableSol] then TheEquilibrium:=AnEquilibrium;
 end;

 destructor TGameForm.Done;
 begin
  TheEquilibrium:=nil;  {To avoid dumping the equilibrium when closing window}
  TObject.Done;
 end;

 procedure TGameForm.SelfDraw;
 var APlayer:PPlayer; AStrategy: PStrategy; TheDrift,Index,PIndex:Integer; ALocus: TPoint;
  procedure SelfDrawPlayer(AnObject:PGameObject);far;
  begin
    APlayer:=PPlayer(AnObject);
    Index:=TheGame^.PlayerSet^.IndexOf(APlayer);
    PIndex:=APlayer^.OwnStrategies.Count;
    ALocus.X:= LeftMargin;
    ALocus.Y:= TopMargin;
    case Index of
     0: ALocus.Y:= TopMargin+2*CellSpacing+(PIndex-1)*HalfCell;
     1: begin
         ALocus.X:= LeftMargin+(2+PIndex)*CellSpacing+DepSpacing*TheDrift;
         ALocus.Y:=ALocus.Y+HalfCell-DepSpacing*TheDrift;
        end;
     2: ALocus.X:=ALocus.X+HalfCell;
    end;
    APlayer^.SetLocus(ALocus);
  end;
  procedure SelfDrawStrategy(AnObject:PGameObject);far;
  begin
    AStrategy:=PStrategy(AnObject);
    APlayer:=AStrategy^.Owner;
    PIndex:=TheGame^.PlayerSet^.IndexOf(APlayer);
    Index:=APlayer^.OwnStrategies.IndexOf(AStrategy);
    ALocus.X:= LeftMargin+CellSpacing;
    ALocus.Y:= TopMargin+CellSpacing;
    case PIndex of
      0: ALocus.Y:=ALocus.Y+(1+Index)*CellSpacing;
      1: begin
          ALocus.X:=ALocus.X+2*(1+Index)*CellSpacing+DepSpacing*TheDrift;
          ALocus.Y:=ALocus.Y-DepSpacing*TheDrift;
         end;
      2: begin
          ALocus.X:=ALocus.X+Index*DepSpacing;
          ALocus.Y:=ALocus.Y-Index*DepSpacing;
         end;
    end;
    AStrategy^.SetLocus(ALocus);
  end;
  procedure SelfDrawCell(ACell:PCell);far;
  var ALocus:TPoint;
  begin
   with ACell^ do begin
    ALocus.Y:=ShowStrategy(1)^.ShowLocus^.Y-CellMargin;
    ALocus.X:=ShowStrategy(2)^.ShowLocus^.X-CellMargin-DepSpacing*TheDrift;
    AStrategy:=ShowStrategy(3);
    if AStrategy<>nil
    then begin
     APlayer:=AStrategy^.Owner;
     Index:=APlayer^.OwnStrategies.IndexOf(AStrategy);
     ALocus.X:=ALocus.X+Index*DepSpacing;
     ALocus.Y:=ALocus.Y-Index*DepSpacing;
    end;
    SetLocus(ALocus);
   end;
  end;
  procedure SelfDrawEvolver(AnEvolver:PEvolver);far;
   function FindIndex(AnItem:PEvolver):Boolean;far;
   begin
    FindIndex:=False;
    if AnItem=AnEvolver
    then FindIndex:=True
    else if AnItem^.Owner=AnEvolver^.Owner
         then Index:=Index+1;
   end;
  begin
   with AnEvolver^ do begin
    PIndex:=PGameType(Game)^.PlayerSet^.IndexOf(Owner);
    Index:=-1;
    PGameType(Game)^.EvolverSet^.FirstThat(@FindIndex);
    ALocus.X:= LeftMargin+10*PIndex*CellSpacing;
    ALocus.Y:= 3*TopMargin+Index*HalfCell;     {Adjust to # row strategies}
    SetLocus(ALocus);
   end;
  end;
 begin
  with TheGame^ do begin
   if not IsNormalForm then Exit;
   DistributeStrategies;
   SetDrift;        {Drift player 2 and his strategies when exists player 3}
   TheDrift:=Drift;
   PlayerSet^.ForEach(@SelfDrawPlayer);
   StrategySet^.ForEach(@SelfDrawStrategy);
   CellSet^.ForEach(@SelfDrawCell);
   EvolverSet^.ForEach(@SelfDrawEvolver);
  end;
 end;

 procedure TGameForm.SketchTitle(TheDC:HDC;AnObject:PGameObject);
 begin
   if AnObject=nil then Exit;
   SelectObject(TheDC,CommentFont);
   SelectObject(TheDC,BlackPen);
   SetTextColor(TheDC,Color[3]);
   with AnObject^
   do TextOut(TheDC,SizedX(ShowLocus^.X),SizedY(ShowLocus^.Y),ShowName,StrLen(ShowName));
 end;

 procedure TGameForm.SketchComment(TheDC:HDC;AComment:PComment);
 var TheText:LongName;
 begin
  if not DisplayMode[dm_Comments] then Exit;
  SelectObject(TheDC,CommentFont);
  SelectObject(TheDC,BlackPen);
  SetTextColor(TheDC,LongInt(0));
  with AComment^
  do begin
   StrCopy(TheText,'<');
   StrCat(TheText,TheComment);
   StrCat(TheText,'>');
   TextOut(TheDC,SizedX(ShowLocus^.X-10),SizedY(ShowLocus^.Y-5),
           TheText,StrLen(TheText));
  end;
 end;

 procedure TGameForm.SketchPlayer(TheDC:HDC;APlayer:PPlayer);
 var CrntX,CrntY,Index: Integer;{AName: NameType;  }
 begin
   with APlayer^ do begin
    Index:=TheGame^.PlayerSet^.IndexOf(APlayer);
    CrntX:=ShowLocus^.X;
    CrntY:=ShowLocus^.Y;
    {Select color}
    SelectObject(TheDC,TheFont);
    if DisplayMode[dm_ShowColor]
    then begin
     SelectObject(TheDC,ThePen[Index]);
     SelectObject(TheDC,TheBrush[Index]);
     SetTextColor(TheDC,Color[Index]);
    end else begin
     SelectObject(TheDC,BlackPen);
     SelectObject(TheDC,BlackBrush);
     SetTextColor(TheDC,LongInt(0));
    end;
    SetBkMode(TheDC,Transparent);
    {Draw player}
    Ellipse(TheDC,SizedX(CrntX),SizedY(CrntY-2),
                  SizedX(CrntX+5),SizedY(CrntY+3)); {Draw head}
    MoveTo(TheDC,SizedX(CrntX+2),SizedY(CrntY+3));
    LineTo(TheDC,SizedX(CrntX+2),SizedY(CrntY+8)); {Draw body}
    MoveTo(TheDC,SizedX(CrntX-1),SizedY(CrntY+4));
    LineTo(TheDC,SizedX(CrntX+6),SizedY(CrntY+4)); {Draw arms}
    MoveTo(TheDC,SizedX(CrntX),SizedY(CrntY+10));
    LineTo(TheDC,SizedX(CrntX+2),SizedY(CrntY+8));
    LineTo(TheDC,SizedX(CrntX+5),SizedY(CrntY+11)); {Draw legs}
    StrCopy(AName,ShowName);
    TextOut(TheDC,SizedX(10+CrntX),SizedY(CrntY),AName,StrLen(AName));
   end;
 end;

 procedure TGameForm.SketchNode(TheDC:HDC;ANode:PNode;DisplayPlayer:PPlayer);
  var
  CrntX,
  CrntY,
  Index         : Integer;
  procedure DisplayExpectation(APlayer:PPlayer);far;
  begin
   if not (DisplayMode[dm_AllValues] or DisplayMode[dm_OneValue]) then Exit;
   Index:=TheGame^.PlayerSet^.IndexOf(APlayer)+1;
   if DisplayMode[dm_ShowColor]
   then SetTextColor(TheDC,Color[TheGame^.PlayerSet^.IndexOf(APlayer)])
   else SetTextColor(TheDC,LongInt(0));
   StrCopy(AName,'E= ');
   StrCat(AName,StringReal(LowTruncate(ANode^.ShowValue(Index)),DefaultLength));
   TextOut(TheDC,SizedX(CrntX-12),SizedY(CrntY+8*Index),AName,StrLen(AName));
  end;
  procedure DisplayBelief(ABelief:Real);
  begin
   StrCopy(AName,'b= ');
   if DisplayMode[dm_Absolute]
   then StrCat(AName,StringReal(ABelief,DefaultLength))
   else if DisplayMode[dm_Scientific]
        then StrCat(AName,StringReal(ABelief,DefaultLength))
        else StrCat(AName,StringProba(ABelief,DefaultLength));
   TextOut(TheDC,SizedX(CrntX-12),SizedY(CrntY-26),AName,StrLen(AName));
  end;
 begin
   if FormCase in [gf_Table,gf_TableSol,gf_Evolve,gf_EvolveSol] then Exit;
   if ANode^.IsBayes then Exit;           {Experiment}
   with ANode^ do begin
    CrntX:=ShowLocus^.X;
    CrntY:=ShowLocus^.Y;
    {Select color}
    SelectObject(TheDC,TheFont);
    if DisplayMode[dm_ShowColor]
    then begin
     if Owner=nil then Index:=MaxPlayerNumber
     else Index:=TheGame^.PlayerSet^.IndexOf(Owner);
     SelectObject(TheDC,ThePen[Index]);
     SelectObject(TheDC,TheBrush[Index]);
     SetTextColor(TheDC,Color[Index]);
    end else begin
     SelectObject(TheDC,BlackPen);
     SelectObject(TheDC,BlackBrush);
     SetTextColor(TheDC,LongInt(0));
    end;
    SetBkMode(TheDC,Transparent);
    {Draw node}
    Ellipse(TheDC,SizedX(CrntX-8),SizedY(CrntY-8),
                  SizedX(CrntX+8),SizedY(CrntY+8));
    if DisplayMode[dm_Name] then begin
     StrCopy(AName,ShowName);
     TextOut(TheDC,SizedX(CrntX-8),SizedY(CrntY-18),AName,StrLen(AName));
    end;
    if FormCase=gf_GraphSol
    then begin
     {Keep current color}
     if DisplayMode[dm_Belief]
     then if DisplayMode[{dm_Absolute}dm_Scientific]              {Experiment by dm_Scientific here}
          then DisplayBelief(ANode^.Belief)
          else DisplayBelief(ANode^.NormBelief);        {Experiment}
     {This part changes colors}
     if DisplayMode[dm_AllValues] then TheGame^.PlayerSet^.ForEach(@DisplayExpectation);
     if DisplayMode[dm_OneValue] and (DisplayPlayer<>nil)
     then DisplayExpectation(DisplayPlayer);
    end;
    if IsBayes then begin                              {Experiment}
      SetTextColor(TheDC,LongInt(0));
      TextOut(TheDC,SizedX(CrntX),SizedY(CrntY),'B',StrLen('B'));
    end;
   end;
 end;

 procedure TGameForm.SketchInfo;
 var
  Count,
  Index         : Byte;
  FX,FY,
  DX,DY,
  WX,WY         : Integer;
  FirstNode,
  SecondNode    : PNode;
  Owner         : PPlayer;
 begin
 if FormCase in [gf_Table,gf_TableSol,gf_Evolve,gf_EvolveSol] then Exit;
 if AnInfo=nil then Exit;
 if AnInfo^.IsBayes then Exit;
 with AnInfo^ do begin
  if Event.Count<=1 then Exit;
  FirstNode:=Event.At(0);
  Owner:=FirstNode^.Owner;
  {Select color}
  if DisplayMode[dm_ShowColor]
  then begin
   if (Owner=nil)
   {or IsBayesian                {Experiment}
   then Index:=MaxPlayerNumber
   else Index:=TheGame^.PlayerSet^.IndexOf(Owner);
   SelectObject(TheDC,TheBigPen[Index]);
  end else SelectObject(TheDC,BigBlackPen);
  {Draw info}
  Index:=0;
  repeat
   FirstNode:={Show}Event.At(Index);
   SecondNode:={Show}Event.At(Index+1);
   FX:=FirstNode^.ShowLocus^.X;
   DX:=SecondNode^.ShowLocus^.X-FX;
   WX:=Round(DX/15);
   FY:=FirstNode^.ShowLocus^.Y;
   DY:=SecondNode^.ShowLocus^.Y-FY;
   WY:=Round(DY/15);
   for Count:=1 to 7 do begin
    FX:=FX+WX;FY:=FY+WY;
    MoveTo(TheDC,SizedX(FX),SizedY(FY));
    FX:=FX+WX;FY:=FY+WY;
    LineTo(TheDC,SizedX(FX),SizedY(FY));
   end;
   Index:=Index+1;
  until Index={Show}Event.Count-1;
 end;
 end;

 procedure TGameForm.SketchMove(TheDC:HDC;AMove:PMove;AProba,AnIncent:Real;
                                 Active,Freedom:Boolean;DisplayPlayer:PPlayer);
 var
  CrntX,
  CrntY,
  Index         : Integer;
  {AName         : NameType; }
  Count         : Byte;
  AnArrow       : Arrow;
  procedure DisplayPayoff(APlayer:PPlayer);far;
  var
   AnOutcome    : POutcome;
   PayoffName   : NameType;
  begin
   if APlayer=nil then Exit;
   if DisplayMode[dm_ShowColor]
   then SetTextColor(TheDC,Color[TheGame^.PlayerSet^.IndexOf(APlayer)])
   else SetTextColor(TheDC,LongInt(0));
   {This is for positioning only}
   if DisplayMode[dm_AllValues]
   then Index:=TheGame^.PlayerSet^.IndexOf(APlayer)+1
   else Index:=1;
   {Now find what to display}
   if TheGame^.FindOutcome(True,AMove,nil,APlayer,AnOutcome)
   then StrCopy(PayoffName,StringReal(AnOutcome^.{Show}Payoff,DefaultLength))
   else StrCopy(PayoffName,'');
   TextOut(TheDC,SizedX(CrntX-12),SizedY(CrntY+8*Index),
                                  PayoffName,StrLen(PayoffName));
  end;
  procedure DrawArc(IsDotted:Boolean);
  var ACount:Byte;
  begin
   with AMove^ do begin
    with From^.ShowLocus^ do MoveTo(TheDC,SizedX(X),SizedY(Y));
    if IsDotted
    then begin
     ACount:=1;
     repeat
      with {ShowArc^}TheArc[ACount] do MoveTo(TheDC,SizedX(X),SizedY(Y));
      with {ShowArc^}TheArc[ACount+1] do LineTo(TheDC,SizedX(X),SizedY(Y));
      ACount:=ACount+2;
     until ACount>20;
    end else for ACount:=1 to 20 do
    with {ShowArc^}TheArc[ACount] do LineTo(TheDC,SizedX(X),SizedY(Y));
   end;
  end;
 begin
  {Safety measures}
  if FormCase in [gf_Table,gf_TableSol,gf_Evolve,gf_EvolveSol] then Exit;
  if (AMove=nil) then Exit;                      {No move}
  if AMove^.From=nil then Exit;              {No from node}
  if AMove^.IsBayes then Exit;                {Experiment}
  if AMove^.TheArc[1].X=0 then Exit;           {It's a new arc}
  SetBkMode(TheDC,Transparent);
  SelectObject(TheDC,TheFont);
  with AMove^ do begin     {Find location and color index}
   CrntX:=ShowLocus^.X;
   CrntY:=ShowLocus^.Y;
   {Select color}
   if DisplayMode[dm_ShowColor]
   then begin
    if From^.{Show}Owner=nil then Index:=MaxPlayerNumber
    else Index:=PGameType(Game)^.PlayerSet^.IndexOf(From^.{Show}Owner);
    SelectObject(TheDC,TheBrush[Index]);
    SelectObject(TheDC,ThePen[Index]);
    SetTextColor(TheDC,Color[Index]);
   end else begin
    SelectObject(TheDC,BlackBrush);
    SelectObject(TheDC,BlackPen);
    SetTextColor(TheDC,LongInt(0));
   end;
   {Draw the arrow}
   AnArrow:={ShowArrow^}TheArrow;
   for Count:=1 to 3 do with AnArrow[Count]
   do begin X:=SizedX(X);Y:=SizedY(Y);end;
   Polygon(TheDC,AnArrow,3);
   {Draw the arc}
   if (FormCase=gf_GraphSol)
   and (AProba<=MidwayDefault)
   then DrawArc(True)
   else DrawArc(False);
   {Write the arc name}
   if DisplayMode[dm_Name] then begin
    StrCopy(AName,ShowName);
    TextOut(TheDC,SizedX(CrntX-8),SizedY(CrntY-16),AName,StrLen(AName));
   end;
   {Write the discount or Chance proba}
   if DisplayMode[dm_Discount] or (AMove^.From^.{Show}Owner=nil)
   then begin
    SetTextColor(TheDC,LongInt(0));
    if AMove^.From^.{Show}Owner=nil
    then StrCopy(AName,'p=') else StrCopy(AName,'d=');
    StrCat(AName,StringProba(AMove^.{Show}Discount,DefaultLength));
    TextOut(TheDC,SizedX(CrntX-12),SizedY(CrntY-24),AName,StrLen(AName));
   end;
   {Write move proba}
   if (FormCase=gf_GraphSol)
   and DisplayMode[dm_Proba]
   and (AMove^.From^.{Show}Owner<>nil)
   then begin
    SetTextColor(TheDC,LongInt(0));
    StrCopy(AName,'p=');
    if DisplayMode[dm_Scientific]
    then StrCat(AName,StringReal(AProba,DefaultLength))
    else StrCat(AName,StringProba(AProba,DefaultLength));
    TextOut(TheDC,SizedX(CrntX-12),SizedY(CrntY-24),AName,StrLen(AName));
   end;
   {Write Choice incentive}
   if (FormCase=gf_GraphSol) and DisplayMode[dm_Incentive]
   and (AMove^.From^.{Show}Owner<>nil)
   then begin
    SetTextColor(TheDC,LongInt(0));
    StrCopy(AName,'E=');
    StrCat(AName,StringReal(LowTruncate(AnIncent),DefaultLength));
    TextOut(TheDC,SizedX(CrntX-12),SizedY(CrntY-24),AName,StrLen(AName));
   end;
   {Write Move outcome}
   if DisplayMode[dm_AllValues] then TheGame^.PlayerSet^.ForEach(@DisplayPayoff);
   if DisplayMode[dm_OneValue] and (DisplayPlayer<>nil)
   then DisplayPayoff(DisplayPlayer);
  end;
 end;

 function TGameForm.ShowEquilibrium:PEquilibrium;
 begin
  ShowEquilibrium:=TheEquilibrium;
 end;

 procedure TGameForm.ShowGrid(TheDC:HDC);
 var Index:Byte;
 begin
  {if Printing then Exit; }
  SelectObject(TheDC,ThePen[MaxPlayerNumber]);        {Gray}
  for Index:=1 to 150
  do begin
   MoveTo(TheDC,2*Index*ScrollUnit,0);
   LineTo(TheDC,2*Index*ScrollUnit,200*ScrollUnit);
   MoveTo(TheDC,0,2*Index*ScrollUnit);
   LineTo(TheDC,300*ScrollUnit,2*Index*ScrollUnit);
  end;
  SelectObject(TheDC,BlackPen);        {Black}
  for Index:=0 to 15
  do begin
   MoveTo(TheDC,20*Index*ScrollUnit,0);
   LineTo(TheDC,20*Index*ScrollUnit,200*ScrollUnit);
   MoveTo(TheDC,0,20*Index*ScrollUnit);
   LineTo(TheDC,300*ScrollUnit,20*Index*ScrollUnit);
  end;
 end;

 procedure TGameForm.SketchCell(TheDC:HDC;ACell:PCell);
 var CrntX,CrntY,Index:Integer; {AName: LongName;}
  procedure DrawRect(X,Y:Integer);
  begin
    MoveTo(TheDC,SizedX(X),SizedY(Y));
    X:=X+2*CellSpacing;
    LineTo(TheDC,SizedX(X),SizedY(Y));
    Y:=Y+CellSpacing;
    LineTo(TheDC,SizedX(X),SizedY(Y));
    X:=X-2*CellSpacing;
    LineTo(TheDC,SizedX(X),SizedY(Y));
    Y:=Y-CellSpacing;
    LineTo(TheDC,SizedX(X),SizedY(Y));
  end;
  procedure DrawBox(X,Y:Integer);
  var I,J:Byte;
   procedure DrawEdge(XX,YY:Integer);
   begin
    MoveTo(TheDC,SizedX(XX),SizedY(YY));
    LineTo(TheDC,SizedX(XX+EdgeSpacing),SizedY(YY-EdgeSpacing));
   end;
  begin
   DrawRect(X,Y);
   DrawRect(X+EdgeSpacing,Y-EdgeSpacing);
   for I:=0 to 1 do for J:=0 to 1 do DrawEdge(X+2*I*CellSpacing,Y+J*CellSpacing);
  end;
  procedure DisplayPayoff(APlayer:PPlayer);far;
  var
   AnOutcome    : POutcome;
   PayoffName   : NameType;
  begin
   if APlayer=nil then Exit;
   if not ACell^.{Show}HasFocus
   then SetTextColor(TheDC,Color[4])
   else if DisplayMode[dm_ShowColor]
        then SetTextColor(TheDC,Color[TheGame^.PlayerSet^.IndexOf(APlayer)])
        else SetTextColor(TheDC,LongInt(0));
   {This is for positioning only}
   if DisplayMode[dm_AllValues]
   then Index:=TheGame^.PlayerSet^.IndexOf(APlayer)+1
   else Index:=1;
   {Now find what to display}
   if TheGame^.FindOutcome(False,nil,ACell,APlayer,AnOutcome)
   then StrCopy(PayoffName,StringReal(AnOutcome^.{Show}Payoff,DefaultLength))
   else StrCopy(PayoffName,'');
   TextOut(TheDC,SizedX(CrntX+16),SizedY(CrntY+8*Index),
                                  PayoffName,StrLen(PayoffName));
  end;
 begin
  {if FormCase in [gf_Graph,gf_GraphSol] then Exit; }
  with ACell^ do begin
    if (RowStrat=nil) or (ColStrat=nil) then Exit;
    SelectObject(TheDC,TheFont);
    if HasFocus
    then SelectObject(TheDC,MidBlackPen)
    else SelectObject(TheDC,DotGrayPen);
    CrntX:=ShowLocus^.X;
    CrntY:=ShowLocus^.Y;
    if (DepStrat=nil)
    then DrawRect(CrntX,CrntY)
    else DrawBox(CrntX,CrntY);
   {Write Cell outcome}
   if not HasFocus then Exit;
   if DisplayMode[dm_AllValues] then TheGame^.PlayerSet^.ForEach(@DisplayPayoff);
   if DisplayMode[dm_OneValue] and (DisplayPlayer<>nil)
   then DisplayPayoff(DisplayPlayer);
  end;
 end;

 procedure TGameForm.SketchStrategy(TheDC:HDC;AStrategy:PStrategy);
 var CrntX,CrntY,Index:Integer;{AName: NameType;} APlayer:PPlayer;
 begin
   {if FormCase in [gf_Graph,gf_GraphSol] then Exit;}
   with AStrategy^ do begin
    Index:=TheGame^.PlayerSet^.IndexOf(AStrategy^.Owner);
    CrntX:=ShowLocus^.X;
    CrntY:=ShowLocus^.Y;
    SelectObject(TheDC,TheFont);
    if DisplayMode[dm_ShowColor]
    then begin
     SelectObject(TheDC,ThePen[Index]);
     SetTextColor(TheDC,Color[Index]);
    end else begin
     SelectObject(TheDC,BlackPen);
     SetTextColor(TheDC,LongInt(0));
    end;
    if ((Index=2) or (FormCase=gf_TableSol))
    and not AStrategy^.{Show}HasFocus
    then SetTextColor(TheDC,Color[4]);
    SetBkMode(TheDC,Transparent);
    StrCopy(AName,ShowName);
    TextOut(TheDC,SizedX(10+CrntX),SizedY(CrntY),AName,StrLen(AName));
    if FormCase=gf_TableSol
    then begin
     SelectObject(TheDC,BlackPen);
     SetTextColor(TheDC,LongInt(0));
     SetBkMode(TheDC,Transparent);
     if DisplayMode[dm_Proba]
     then begin
      StrCopy(AName,'p= ');
      if DisplayMode[dm_Scientific]
      then StrCat(AName,StringReal(AStrategy^.{Show}Probability,DefaultLength))
      else StrCat(AName,StringProba(AStrategy^.{Show}Probability,DefaultLength));
     end;
     if DisplayMode[dm_Incentive]
     then begin
      StrCopy(AName,'E= ');
      StrCat(AName,StringReal(AStrategy^.{Show}Expectation,DefaultLength));
     end;
     CrntY:=CrntY+10;
     TextOut(TheDC,SizedX(10+CrntX),SizedY(CrntY),AName,StrLen(AName));
    end;
   end;
 end;

 procedure TGameForm.SketchEvolver(TheDC:HDC;AnEvolver:PEvolver);
 var CrntX,CrntY:Integer;
 begin
  with AnEvolver^ do
  if PGameType(Game)^.IsSymmetric and (PGameType(Game)^.PlayerSet^.IndexOf(Owner)>0)
  then Exit {Don't repeat display}
  else begin
    CrntX:=ShowLocus^.X;
    CrntY:=ShowLocus^.Y;
    SelectObject(TheDC,TheFont);
    if DisplayMode[dm_ShowColor]
    then SetTextColor(TheDC,Color)
    else SetTextColor(TheDC,LongInt(0));
    StrCopy(AName,ShowName);
    TextOut(TheDC,SizedX(10+CrntX),SizedY(CrntY),AName,StrLen(AName));
    StrCopy(AName,Owner^.ShowName);
    TextOut(TheDC,SizedX(110+CrntX),SizedY(CrntY),AName,StrLen(AName));
    if FormCase=gf_EvolveSol
    then begin
     StrCopy(AName,StringReal(OwnScore,7));
     TextOut(TheDC,SizedX(210+CrntX),SizedY(CrntY),AName,StrLen(AName));
     StrCopy(AName,StringReal(Weight,7));
     TextOut(TheDC,SizedX(310+CrntX),SizedY(CrntY),AName,StrLen(AName));
     StrCopy(AName,StringReal(Perform,7));
     TextOut(TheDC,SizedX(410+CrntX),SizedY(CrntY),AName,StrLen(AName));
    end;
  end;
 end;

  procedure TGameForm.ShowForm(ADC: HDC);
  procedure SketchAComment(AComment:PComment);far;
  begin
   SketchComment(ADC,AComment);
  end;
  procedure SketchAPlayer(APlayer:PPlayer); far;
  begin
   SketchPlayer(ADC,APlayer);
  end;
  procedure SketchANode(ANode:PNode); far;
  begin
   SketchNode(ADC,ANode,DisplayPlayer);
  end;
  procedure SketchAChoice(AChoice:PChoice);far;
   procedure SketchInstance(AMove:PMove);far;
   begin
    with AChoice^ do
    SketchMove(ADC,AMove,Probability,Incentive,True,True,DisplayPlayer);
   end;
  begin
   if AChoice^.Instance.Count>0
   then AChoice^.Instance.ForEach(@SketchInstance);
  end;
  procedure SketchAMove(AMove:PMove); far;
  begin
   SketchMove(ADC,AMove,1,0,True,True,DisplayPlayer);
  end;
  procedure SketchAnInfo(AnInfo:PInfo); far;
  begin
   SketchInfo(ADC,AnInfo);
  end;
  procedure SketchAStrategy(AStrategy:PStrategy);far;
  begin
   SketchStrategy(ADC,AStrategy);
  end;
  procedure SketchAnEvolver(AnEvolver:PEvolver);far;
  begin
   SketchEvolver(ADC,AnEvolver);
  end;
  procedure SketchAnyCell(ACell:PCell);far;
  begin
   if ACell^.HasFocus then Exit;
   SketchCell(ADC,ACell);
  end;
  procedure SketchFocusCell(ACell:PCell);far;
  begin
   if not ACell^.HasFocus then Exit;
   SketchCell(ADC,ACell);
  end;
  procedure SketchATitle;
  begin
   if FormCase in [gf_graphSol,gf_TableSol]
   then SketchTitle(ADC,ShowEquilibrium)
   else SketchTitle(ADC,TheGame^.MainTitle);
  end;
  procedure SketchAWeight(AnEvolver:PEvolver);far;
  begin
   SketchWeights(ADC,AnEvolver);
   CurveSpacing:=CurveSpacing+1;
  end;
 begin
  if IsPrinting then SetMapMode(ADC,mm_LoEnglish);
  if DisplayMode[dm_GridOn] then ShowGrid(ADC);
  SketchATitle;
  with TheGame^
  do begin
   if FormCase=gf_Replicate
   then begin
    CurveSpacing:=0;
    EvolverSet^.ForEach(@SketchAWeight);
    SketchAxes(ADC,not IsSymmetric);
   end else begin
    CommentSet^.ForEach(@SketchAComment);
    PlayerSet^.ForEach(@SketchAPlayer);
    if FormCase in [gf_GraphSol,gf_TableSol]
    then begin
     ShowEquilibrium^.NodeSolSet^.ForEach(@SketchANode);
     ShowEquilibrium^.ChoiceSolSet^.ForEach(@SketchAChoice);
     ShowEquilibrium^.StratSolSet^.ForEach(@SketchAStrategy);
    end else begin
     NodeSet^.ForEach(@SketchANode);
     MoveSet^.ForEach(@SketchAMove);
     StrategySet^.ForEach(@SketchAStrategy);
    end;
     InfoSet^.ForEach(@SketchAnInfo);
     CellSet^.ForEach(@SketchAnyCell);
     CellSet^.ForEach(@SketchFocusCell);
     EvolverSet^.ForEach(@SketchAnEvolver);
    end;
   end;
  if IsPrinting then SetMapMode(ADC,mm_Text);
 end;



 function MakeTitleRect(AnObject:PGameObject):PRect;
 var ARect:TRect;
 begin
  with AnObject^ do begin
   ARect.left:=SizedX(Locus.X)-GraphicSize;
   ARect.right:=SizedX(Locus.X)+5*GraphicSize;
   ARect.top:=SizedY(Locus.Y)-GraphicSize;
   ARect.bottom:=SizedY(Locus.Y)+GraphicSize;
  end;
  MakeTitleRect:=@ARect;
 end;

 function MakePlayerRect(AnObject:PGameObject):PRect;
 var ARect:TRect;
 begin
  with AnObject^ do begin
   ARect.left:=SizedX(Locus.X)-GraphicSize;
   ARect.right:=SizedX(Locus.X+4)+GraphicSize;
   ARect.top:=SizedY(Locus.Y)-GraphicSize;
   ARect.bottom:=SizedY(Locus.Y)+GraphicSize;
  end;
  MakePlayerRect:=@ARect;
 end;

 function MakeNodeRect(AnObject:PGameObject):PRect;
 var
  ARect : TRect;
  ANode : PNode;
  procedure CheckMoveRect(AMove:PMove); far;
  var MoveRect:TRect;
  begin
   if (AMove^.From=ANode) or (AMove^.Upto=ANode)
   then begin
    MoveRect:=MakeMoveRect(AMove)^;
    ARect:=MaxRect(@MoveRect,@ARect)^;
   end;
  end;
 begin
  ANode:=PNode(AnObject);
  with ANode^ do begin
   ARect.left:=SizedX(Locus.X)-GraphicSize;
   ARect.right:=SizedX(Locus.X+4)+GraphicSize;
   ARect.top:=SizedY(Locus.Y)-GraphicSize;
   ARect.bottom:=SizedY(Locus.Y)+GraphicSize;
   TheGame^.MoveSet^.ForEach(@CheckMoveRect);
  end;
  MakeNodeRect:=@ARect;
 end;

 function MakeMoveRect(AnObject:PGameObject):PRect;
 var
  ARect : TRect;
  AMove : PMove;
 begin
  AMove:=PMove(AnObject);
  with AMove^ do begin
   ARect.left:=SizedX(Minimum.X)-GraphicSize;
   ARect.right:=SizedX(Maximum.X+4)+GraphicSize;
   ARect.top:=SizedY(Minimum.Y)-GraphicSize;
   ARect.bottom:=SizedY(Maximum.Y)+GraphicSize;
  end;
  MakeMoveRect:=@ARect;
 end;

 function MakeInfoRect(AnObject:PGameObject):PRect;
 var
  ARect : TRect;
  AnInfo: PInfo;
  procedure MakeEventRect(ANode:PNode); far;
  var ERect:PRect;
  begin
   ERect:=MakeNodeRect(ANode);
   ARect:=MaxRect(@ARect,ERect)^;
  end;
 begin
  AnInfo:=PInfo(AnObject);
  AnInfo^.{Show}Event.ForEach(@MakeEventRect);
  MakeInfoRect:=@ARect;
 end;

 function SizedX(X:Integer):Integer;
 begin
  SizedX:=Round(DisplaySize*(X+XHead));
 end;

 function SizedY(Y:Integer):Integer;
 var YY:Integer;
 begin
  YY:=Round(DisplaySize*(Y+YHead));
  if IsPrinting
  then SizedY:=-YY
  else SizedY:=YY;
 end;

procedure ShowBugs(PageNumber:Word;ADC:HDC);
var
 Row,
 Column  : Integer;
 ErrorText: LongName;
 Name1,
 Name2,
 Name3,
 Name4   : NameType;
 Name    : array[1..4] of NameType;
 procedure ShowBug(ABug:PAuditItem);far;
 var  I: Byte;
 begin
  Row:=Row+RowSpacing;Column:=LeftMargin;
  if not IsVisibleRow(Row,PageNumber) then Exit;
  for I:=1 to 4 do StrCopy(Name[I],'');
  case ABug^.InfoCase of
   gi_TooSmallBug: begin
       LoadString(HInstance,26,ErrorText,LongSize);
      end;
   gi_DegreeBug: begin
       LoadString(HInstance,28,ErrorText,LongSize);
       {StrCopy(Name[1],ABug^.ShowObject(1)^.ShowName);}
      end;
   gi_OutcomeBug: begin
       LoadString(HInstance,29,ErrorText,LongSize);
       {StrCopy(Name[1],ABug^.ShowObject(1)^.ShowName);
       StrCopy(Name[2],ABug^.ShowObject(2)^.ShowName); }
      end;
   3: begin
       LoadString(HInstance,30,ErrorText,LongSize);
       {StrCopy(Name[1],ABug^.ShowObject(1)^.ShowName);  }
      end;
   4: begin
       LoadString(HInstance,90,ErrorText,LongSize);
       {StrCopy(Name[1],ABug^.ShowObject(1)^.ShowName);
       StrCopy(Name[2],ABug^.ShowObject(2)^.ShowName);
       StrCopy(Name[3],ABug^.ShowObject(3)^.ShowName); }
      end;
   5: begin
       LoadString(HInstance,31,ErrorText,LongSize);
      end;
   6: Begin
       LoadString(HInstance,91,ErrorText,LongSize);
       {StrCopy(Name[1],ABug^.ShowObject(1)^.ShowName);}
      end;
   7: begin
       LoadString(HInstance,92,ErrorText,LongSize);
       {StrCopy(Name[1],ABug^.ShowObject(1)^.ShowName);}
      end;
   8: begin
       LoadString(HInstance,93,ErrorText,LongSize);
       {StrCopy(Name[1],ABug^.ShowObject(1)^.ShowName);}
      end;
   9: begin
       LoadString(HInstance,94,ErrorText,LongSize);
       {StrCopy(Name[1],ABug^.ShowObject(1)^.ShowName);
       StrCopy(Name[2],ABug^.ShowObject(2)^.ShowName);}
      end;
   10:begin
       LoadString(HInstance,29,ErrorText,LongSize);
       {for I:=1 to 3
       do if ABug^.ShowObject(I)<>nil
          then StrCopy(Name[I],ABug^.ShowObject(I)^.ShowName);
       StrCopy(Name[4],ABug^.ShowObject(4)^.ShowName);}
      end;
   11:begin
       LoadString(HInstance,121,ErrorText,LongSize);
       {StrCopy(Name[1],ABug^.ShowObject(1)^.ShowName);
       StrCopy(Name[2],ABug^.ShowObject(2)^.ShowName);}
      end;
  end;
  TextOut(ADC,Column,Visible(Row,PageNumber),ErrorText,StrLen(ErrorText));
  Column:=Column+ColSpacing;
  for I:=1 to 4 do begin
   Column:=Column+ColSpacing;
   if ABug^.ShowObject(I)<>nil
   then StrCopy(Name[I],ABug^.ShowObject(I)^.ShowName);
   TextOut(ADC,Column,Visible(Row,PageNumber),Name[I],StrLen(Name[I]));
  end;
 end;
begin
  SetMapMode(ADC,mm_LoEnglish);
  SelectObject(ADC,LargeFont);
  SetTextColor(ADC,LongInt(0));
  Column:=IntegZero;
  Row:=2*RowSpacing;
  TheGame^.ShowAudit^.ForEach(@ShowBug);
end;


 constructor TMakeStat.Init;
 begin
  LineColl.Init(100,100);
 end;

 destructor TMakeStat.Done;
 begin
  LineColl.FreeAll;
  TObject.Done;
 end;

 procedure TMakeStat.ReplicStat;
  procedure ShowRecord(AnEvolver:PEvolver);far;
   procedure ShowEvolver;
   begin
    LineColl.Insert(New(PTextLine,Init));  {Space line}
    NewLine:=New(PTextLine,Init);
    StrCopy(AText,AnEvolver^.ShowName);
    NewLine^.AddText(0,AText);
    StrCopy(AText,AnEvolver^.Owner^.ShowName);
    NewLine^.AddText(NameSize,AText);
    LineColl.Insert(NewLine);
   end;
   procedure ShowPlay(APlayRec:PPlayRec);far;
   begin
    if APlayRec<>nil
    then with APlayRec^ do begin
     NewLine:=New(PTextLine,Init);
     Str(Score,AText);
     NewLine^.AddText(0,AText);
     {Str(Perform,AText);
     NewLine^.AddText(NameSize,AText); }
     Str(Weight,AText);
     NewLine^.AddText(2*NameSize,AText);
     {Str(Average,AText);
     NewLine^.AddText(3*NameSize,AText);  }
     LineColl.Insert(NewLine);
    end;
   end;
  begin
   if AnEvolver<>nil
   then with AnEvolver^ do begin
    ShowEvolver;
    PlayLog.ForEach(@ShowPlay);
   end;
  end;
 begin
  if IsInspect then Exit;
  TheGame^.EvolverSet^.ForEach(@ShowRecord);
 end;

 procedure TMakeStat.MatchStat;
 var ThePair:PPair; I:Byte;
  procedure MakeLogLine(ALog:PEvLog);far;
   procedure MakeStepLine(AStep:PEvBasic);far;
   begin
    if AStep=nil then Exit;
    if NewLine=nil
    then NewLine:=New(PTextLine,Init);
    StrCopy(AText,AStep^.ShowName);
    NewLine^.AddText(NameSize*I,AText);
    I:=I+1;
    if I=6 then begin
     LineColl.Insert(NewLine);  {To make new line}
     I:=0; NewLine:=nil;
    end;
   end;
  begin
   if ALog=nil then Exit;
   case ALog^.LogCase of
    lc_Steps: begin
               I:=0; NewLine:=nil;
               ALog^.StepsLog.ForEach(@MakeStepLine);
               if NewLine<>nil then LineColl.Insert(NewLine); {Because it wasn't in MakeStepLine}
              end;
    lc_Msg  : begin
               NewLine:=New(PTextLine,Init);
               StrCopy(AText,ALog^.Message);
               NewLine^.AddText(0,AText);
               LineColl.Insert(NewLine);  {Space line}
              end;
   end;
  end;
 begin
  if IsInspect then Exit;
  ThePair:=TheGame^.PairSet^.At(0);
  if ThePair=nil then Exit;
  ThePair^.PairLog.ForEach(@MakeLogLine);
 end;

 procedure TMakeStat.MakeLines;
 var Pos,Len:Byte;
  procedure MakeObjectText(AnObject:PGameObject);far;
  begin
   if AnObject=nil then Exit;
   NewLine:=New(PTextLine,Init);
   NewLine^.SetText(ShowStringPart(AnObject^.{MakeTextLine}MakeCodeLine,0,HugeSize));
   LineColl.Insert(NewLine);
  end;
 begin
  with TheGame^ do begin
  if MainTitle<>nil then MakeObjectText(MainTitle);
  PlayerSet^.ForEach(@MakeObjectText);
  if IsNormalForm
  then begin
   StrategySet^.ForEach(@MakeObjectText);
   CellSet^.ForEach(@MakeObjectText);
  end else begin
   NodeSet^.ForEach(@MakeObjectText);
   MoveSet^.ForEach(@MakeObjectText);
   InfoSet^.ForEach(@MakeObjectText);
  { ChoiceSet^.ForEach(@MakeObjectText); }
  end;
  OutcomeSet^.ForEach(@MakeObjectText);
{  if TheGame^.IsNormalForm
  and TheGame^.IsEvolutionary
  then begin
    EvolverStat;
    if IsInspect then EvObjectStat;
  end; }
  end;
 end;

 procedure TMakeStat.ShowLines(TheDC:HDC;Page:Word);
 var MinLin,MaxLin:Word;
  procedure ShowLine(ALine:PTextLine);far;
  begin
   Lin:=Lin+1;
   if (Lin>=MinLin) and (Lin<MinLin+MaxLin)
   then with ALine^
   do TextOut(TheDC,LeftMargin,(LineMargin+Lin-MinLin)*RowSpacing,ShowText,StrLen(ShowText));
  end;
 begin  {Show line by line}
  SetMapMode(TheDC,mm_LoEnglish);
  SelectObject(TheDC,ListFont);
  SetTextColor(TheDC,LongInt(0));
  if Page=0 then MaxLin:=10000 else MaxLin:=LinesPerPage;
  if Page=0 then MinLin:=0 else MinLin:=(Page-1)*MaxLin;
  Lin:=0;
  LineColl.ForEach(@ShowLine);
 end;

 procedure TMakeStat.EvolverStat;
  procedure MakeEvolverHead;
  begin
   NewLine:=New(PTextLine,Init);
   StrCopy(AText,'Evolution:');
   NewLine^.AddText(0,AText);
   LineColl.Insert(NewLine);
   NewLine:=New(PTextLine,Init);
   LoadString(HInstance,44,AText,NameSize);
   NewLine^.AddText(0,AText);
   LoadString(HInstance,45,AText,NameSize);
   NewLine^.AddText(NameSize,AText);
   LoadString(HInstance,128,AText,NameSize);
   NewLine^.AddText(2*NameSize,AText);
   StrCopy(AText,'(Program Steps)');
   NewLine^.AddText(3*NameSize,AText);
   LineColl.Insert(NewLine);
  end;
  procedure MakeEvolverBlock(AnEvolver:PEvolver);far;
   procedure ListStep(AnEvObject:PEvBasic);far;
   begin
    if AnEvObject=nil then Exit;
    NewLine:=New(PTextLine,Init);
    StrCopy(AText,AnEvObject^.Description);
    NewLine^.AddText(3*NameSize,AText);
    LineColl.Insert(NewLine);
   end;
  begin
   if AnEvolver=nil then Exit;
   NewLine:=New(PTextLine,Init);
   with AnEvolver^ do begin
    StrCopy(AText,ShowName);
    NewLine^.AddText(0,AText);
    {Rank info}
    Str(Rank,AText);
    NewLine^.AddText(NameSize,AText);
    if IsInspect then begin

    end else begin
     if Owner<>nil
     then begin
      StrCopy(AText,Owner^.ShowName);
      NewLine^.AddText(NameSize,AText);
     end;
     StrCopy(AText,ColorStr);
     NewLine^.AddText(2*NameSize,AText);
     StrCopy(AText,'DFLT ');
     if Default<>nil
     then StrCat(AText,Default^.ShowName);
     NewLine^.AddText(3*NameSize,AText);
     LineColl.Insert(NewLine);
     if DlgEvList.Count>0
     then DlgEvList.ForEach(@ListStep)
     else begin
      NewLine:=New(PTextLine,Init);
      StrCopy(AText,'No steps');
      NewLine^.AddText(3*NameSize,AText);
     end;
    end;
   end;
  end;
 begin
  MakeEvolverHead;
  TheGame^.EvolverSet^.ForEach(@MakeEvolverBlock);
 end;

procedure TMakeStat.EvObjectStat;
 procedure MakeEvObjHead;
 begin
   NewLine:=New(PTextLine,Init);
   StrCopy(AText,'Ev objects:');
   NewLine^.AddText(0,AText);
   LineColl.Insert(NewLine);
   NewLine:=New(PTextLine,Init);
   LoadString(HInstance,44,AText,NameSize);
   NewLine^.AddText(0,AText);
   LineColl.Insert(NewLine);
 end;
 procedure MakeEvObjBlock(AnEvObj:PEvBasic);far;
 begin
   if AnEvObj=nil then Exit;
   NewLine:=New(PTextLine,Init);
   with AnEvObj^ do begin
    StrCopy(AText,ShowName);
    NewLine^.AddText(0,AText);
    {Rank info}
    Str(LongRank,AText);
    NewLine^.AddText(NameSize,AText);
    Str(EvOwnerRank,AText);
    NewLine^.AddText(2*NameSize,AText);
    case ObjectType of
     lt_RealVar,lt_OwnChce,lt_OppChce                     : begin
                                                             StrCopy(AText,'Vrbl');
                                                             NewLine^.AddText(3*NameSize,AText);
                                                            end;
     lt_TestOwn,lt_TestOpp,lt_TestReal,lt_TestBool        : with (PEvTest(AnEvObj))^ do begin
                                                             StrCopy(AText,'Test');
                                                             NewLine^.AddText(3*NameSize,AText);
                                                             Str(TestVarRank,AText);
                                                             NewLine^.AddText(3*NameSize+SmallSize,AText);
                                                             Str(LongRank2,AText);
                                                             NewLine^.AddText(3*NameSize+2*SmallSize,AText);
                                                             Str(Test1Rank,AText);
                                                             NewLine^.AddText(3*NameSize+3*SmallSize,AText);
                                                             Str(Test2Rank,AText);
                                                             NewLine^.AddText(3*NameSize+4*SmallSize,AText);
                                                            end;
     lt_SetOwn,lt_SetOpp,lt_SetReal,lt_SetOper,lt_SetResp : with (PEvAssgn(AnEvObj))^ do begin
                                                             StrCopy(AText,'Assgn');
                                                             NewLine^.AddText(3*NameSize,AText);
                                                             Str(StratRank,AText);
                                                             NewLine^.AddText(3*NameSize+SmallSize,AText);
                                                             Str(LongRank1,AText);
                                                             NewLine^.AddText(3*NameSize+2*SmallSize,AText);
                                                             Str(LongRank2,AText);
                                                             NewLine^.AddText(3*NameSize+3*SmallSize,AText);
                                                            end;
     lt_IfThen,lt_IfThenElse,lt_Goto                      : with (PEvStep(AnEvObj))^ do begin
                                                             StrCopy(AText,'Step');
                                                             NewLine^.AddText(3*NameSize,AText);
                                                             Str(TestRank,AText);
                                                             NewLine^.AddText(3*NameSize+SmallSize,AText);
                                                             Str(LongRank1,AText);
                                                             NewLine^.AddText(3*NameSize+2*SmallSize,AText);
                                                             Str(LongRank2,AText);
                                                             NewLine^.AddText(3*NameSize+3*SmallSize,AText);
                                                            end;
    end;
   end;
   LineColl.Insert(NewLine);
 end;
begin
  MakeEvObjHead;
  TheGame^.EvObjSet^.ForEach(@MakeEvObjBlock);
end;


function IsVisibleRow(Row:Integer;Page:Word):Boolean;
begin
 if Page=0 then IsVisibleRow:=True
           else begin
            Row:=-Row;
            if (Row<=1000*Page)
            and (Row>=1000*(Page-1))
            then IsVisibleRow:=True
            else IsVisibleRow:=False;
           end;
end;

function Visible(Row:Integer;Page:Word):Integer;
begin
 Visible:=Row;

{ if Page=0
 then Visible:=Row
 else begin
  Visible:=-30+Row+1000*(Page-1);
 end;  }
end;

procedure ChangeSize(ASize:Integer);
begin
 case ASize of
   id_Small  :begin
               DisplaySize:=2/3;
               GraphicSize:=25;
               TheFont:=SmallFont;
               ScrollRange:=LongInt(5);
              end;
   id_Normal :begin
               DisplaySize:=1;
               GraphicSize:=40;
               TheFont:=MediumFont;
               ScrollRange:=LongInt(50);
              end;
   id_Large  :begin
               DisplaySize:=1.5;
               GraphicSize:=60;
               TheFont:=LargeFont;
               ScrollRange:=LongInt(150);
              end;
 end;
end;

procedure ChangeHead(IsXHead:Boolean;AHead:Integer);
begin
 if IsXHead
 then XHead:=AHead
 else YHead:=AHead;
end;

{Unit execution}

procedure InitGraphUnit;
 var I:Byte;
begin
  LineMargin    :=3;
  LineNumber    :=50;
  LeftMargin    :=40;
  TopMargin     :=120;
  CellMargin    :=20;
  ColSpacing    :=120;             {**********************}
  RowSpacing    :=-15;
  HalfCell      :=25;
  CellSpacing   :=50;
  DepSpacing    :=25;
  EdgeSpacing   :=15;
  AxisSpacing   :=100;
  VertSize      :=Round(3*AxisSpacing/10); {For 10 spaces on y-axis}
  DefaultLength    :=8;           {Set print and display options}
  XHead            :=0;
  YHead            :=0;
  DisplaySize      :=1;
  GraphicSize      := 40;
  ScrollUnit       := 5;
  ScrollRange      := LongInt(50);
  Printer          :=New(PPrinter,Init);
  with GPText do begin
                     lfHeight       :=8;        lfWidth         :=0;
                     lfEscapement   :=0;         lfOrientation   :=0;
                     lfWeight       :=fw_Normal; lfItalic        :=0;
                     lfUnderline    :=0;         lfStrikeOut     :=0;
                     lfCharSet      :=ANSI_CharSet;
                     lfOutPrecision :=Out_Default_Precis;
                     lfClipPrecision:=Clip_Default_Precis;
                     lfQuality      :=Default_Quality;
                     lfPitchAndFamily   :=Default_Pitch or ff_DontCare;  {FixedPitch gives spacing}
  end;
   {Now create graphing tools}
  Color[0]         := cl_Blue;
  Color[1]         := cl_Red;
  Color[2]         := cl_Green;
  Color[3]         := cl_Black;
  Color[4]         := cl_Gray;
  Color[5]         := cl_Cyan;
  Color[6]         := cl_Pink;
  Color[7]         := cl_Yellow;
  Color[8]         := cl_Pastel;
  Color[9]         := cl_Purple;
  Color[10]        := cl_Khaki;
  Color[11]        := cl_Neon;
  Color[12]        := cl_White;

   for I:=0 to 12
   do ThePen[I]:=CreatePen(ps_Solid,0,Color[I]);

   for I:=0 to MaxPlayerNumber
   do begin
    TheBrush[I]:=CreateSolidBrush(Color[I]);
    TheBigPen[I]:=CreatePen(ps_Solid,5,Color[I]);
   end;
   BlackBrush:=CreateSolidBrush(LongInt(0));
   TableBlackPen:=CreatePen(ps_Solid,2,LongInt(0));
   DotGrayPen:=CreatePen(ps_dot,0,$00808080);
   BlackPen:=CreatePen(ps_Solid,0,LongInt(0));
   BigBlackPen:=CreatePen(ps_Solid,5,LongInt(0));
   MidBlackPen:=CreatePen(ps_Solid,2,LongInt(0));
   SmallFont:=CreateFontIndirect(GPText);
   GPText.lfHeight:=10;
   MediumFont:=CreateFontIndirect(GPText);
   GPText.lfHeight:=16;
   LargeFont:=CreateFontIndirect(GPText);
   GPText.lfItalic:=1;
   CommentFont:=CreateFontIndirect(GPText);
   TheFont:=MediumFont;
   with GPText do begin
    lfHeight:=14;
    lfItalic:=0;
    lfPitchAndFamily:=Fixed_Pitch or ff_DontCare;
   end;
   ListFont:=CreateFontIndirect(GPText);
end;

procedure CleanupGraphUnit;
var I:Byte;
begin
  if Printer<>nil then Dispose(Printer,Done);
  for I:=0 to 12
  do DeleteObject(ThePen[I]);
  for I:=0 to MaxPlayerNumber
  do begin
   DeleteObject(TheBrush[I]);
   DeleteObject(TheBigPen[I]);
  end;
  DeleteObject(BlackBrush);
  DeleteObject(TableBlackPen);
  DeleteObject(DotGrayPen);
  DeleteObject(BlackPen);
  DeleteObject(BigBlackPen);
  DeleteObject(MidBlackPen);
  DeleteObject(SmallFont);
  DeleteObject(LargeFont);
  DeleteObject(CommentFont);
  DeleteObject(MediumFont);
  DeleteObject(ListFont);
end;


begin

end.

