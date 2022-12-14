{Copyright (c), Jean-Pierre P. Langlois, 2007-2022}

Unit GP_Solve;

interface

uses {GP_Debug,}GP_File,GP_Glob,GP_Type,GP_Cnst,GP_Util,Strings,WinDos,
     OMemory,OWindows,ODialogs,OStdDlgs,Objects,WinTypes,WinProcs;

 {----------------------------------------------}
 {----Solution objects definition---------------}
 {----------------------------------------------}

type
 OrderedSet = array[0..MaxDegree] of Byte;
 Enumerator = object
  private
  function NextSubset(CrntCardinal,Size: Byte;
                     var CrntSet: OrderedSet): Boolean;
  public
  Pure          : Boolean;
  Cardinal      : Byte;
  InitSet       : OrderedSet;
  procedure Init(PureCase:Boolean;NewCardinal:Byte; var FullSet: OrderedSet);
  function Done(var FullSet:OrderedSet):Boolean;
 end;

 PVector        = ^Vector;
 Vector         = array[1..MaxDimension] of Real;

 PSqrMatrix     = ^TSqrMatrix;
 TSqrMatrix     = array[1..MaxDimension] of PVector;

 PUtility       = ^TUtility;
 TUtility       = array[1..MaxPlayerNumber] of PVector;

 ChoiceActivity = array[1..MaxMoveNumber] of Boolean;
 InfoActivity   = array[1..MaxNodeNumber] of Boolean;
 Exchange       = array[1..MaxDimension] of Byte;


type
 OutletType     = array[1..MaxDegree] of PChoice;

type
 PInvertor      = ^Invertor;
 Invertor       = object(TObject)
  IsInvertible  : Boolean;
  InvertDim     : Byte;
  AbsPivot,
  Pivot         : Real;
  Solution      : Vector;
  Matrix        : PSqrMatrix;
  procedure Init(AMatrix:PSqrMatrix;ADimension:Byte);
  procedure InitInverse;
  function BestRow(Column:Byte):Byte;
  procedure ExchangeRows(OldRow,NewRow:Byte);
  procedure Invert;
  function DirectSolve(AVector:PVector):PVector;
 end;

type
 PExpectator    = ^Expectator;
 Expectator     = object(TObject)
  HighPrecis,
  TruncFlag     : Boolean;
  Dimension     : Byte;
  InvFltr,
  Filter        : Exchange;
  TheInvertor   : Invertor;
  procedure MakeFilter;
  procedure MakeIRT(ChosenPlayer:PPlayer);
  procedure CheckPositiveInverse;
  procedure ImproveInverse;
  procedure MakeBeliefs;
  function MakeExpectation(IsHighPrec:Boolean;ChosenPlayer:PPlayer):Boolean;
  procedure MakeIncentive(EstimatedChoice:PChoice);
 end;

type
 PDerivator     = ^Derivator;
 Derivator      = object(Expectator)
  procedure MakeDeviation;
  function dzkdxj(zk,xj:PChoice):Real;
  function dAbsBeliefOfNudzk(nu:PNode;k:PMove):Real;
  function dAbsBeliefOfNudck(nu:PNode;ck:PChoice):Real;
  function dAbsBeliefOfNudxj(nu:PNode;xj:PChoice):Real;
  function dNormBeliefOfNudck(nu:PNode;ck:PChoice):Real;
  function dNormBeliefOfNudxj(Nu:PNode;xj:PChoice):Real;
  function dEOmegaOfNudzk(Omega:PPlayer;Nu:PNode;k:PMove):Real;
  function dEOmegaOfNudxj(Omega:PPlayer;Nu:PNode;j:PChoice):Real;
  function dciIncentivedxj(ci,xj:PChoice):Real;
  function dfidxj(fi,xj:PChoice):Real;
  procedure MakeTestExpectation;
  procedure MakeTestIncentive;
  procedure MakeTestBelief;
  procedure MakeJacobian;
 end;

type
 PSolveDlg      = ^TSolveDlg;
 TSolveDlg      = object(TDialog)
  OldNorm,
  NewNorm                        : Real;
  ProfileNorm,
  Step,{Step1,Step2,}                                    {Step size in MixedSolve}
  PercentDone                    : Real;
  {GlobalIter, }
  Turn,
  Complexity                     : LongInt;
  Dim,                                      {Set in ResetCoordinates}
  SolutionType,                             {mode and concept}
  SolutionNumber                 : Byte;
  TruncFlag,
  IsSuspended,
  IsTooFat,                                  {for debugging}
  IsTooLarge,
  IsAborted                      : Boolean;
  EstimatedPlayer                : PPlayer;
  StartInfo                      : PInfo;
  EstimatedChoice                : PChoice;
  StartUptoActivity,
  StartFromActivity              : InfoActivity;
  StartChoiceActivity            : ChoiceActivity;
  TheExpectator                  : PExpectator;
  TheDerivator                   : PDerivator;
  InfoString                     : NameType;
  SignatureList                  : TCollection;
  constructor Init(AParent:PWindowsObject;ResourceID:PChar);
  destructor Done; virtual;
  procedure ConstructStrategy(DoneInfos,StratProfile:TCollection;
                              var TooMany:Boolean);
  function MakeStrategies:Boolean;
  procedure ProfileToProba;
  procedure ResetBounds(IsInitial:Boolean);
  procedure ResetCoordinates(IsInitial:Boolean);
  procedure ConvertProfile;
  function MixedSolve:Boolean;
  procedure Explore(Location:Byte);
  function MakeRandomProfile:Boolean;
  procedure SampleInterior;
  function MakeRandomFacet:Boolean;
  procedure SampleBoundary;
  function Norm:Real;
  function MakeStep:Real;
  function PureSolve:Boolean;
  procedure Investigate(WhatInfo:PInfo);
  function Estimate:Boolean;
  function MakeStartInfo:PInfo;
  procedure ActivityToPureProba;
  procedure RecordActivity(var AnInfoActivity:InfoActivity;AChoiceActivity:ChoiceActivity);
  procedure CheckDepth(ADepth:Byte);
  procedure Search(FromActivity,UptoActivity:InfoActivity;
                   ActiveMoveSet:ChoiceActivity;FromInfo:PInfo;
                   LocalProgress:LongInt;IsEstimating:Boolean;Depth:Byte);
  procedure ReleaseMessage;
  procedure PostProgress(AProgress:LongInt);
  {procedure MakeTestJacobian; }
  function InvertJacobian:Boolean;
  function MakeDirection:Boolean;
  function MakeProfile:Boolean;
  function IsOptimalSet(NextInfo:PInfo):Boolean;
  function IsNashSet:Boolean;
  function IsPerfectSet(IsHighTest:Boolean):Boolean;
  function HasNoSameSolution:Boolean;
  function IsNewSolution:Boolean;
  procedure SaveEquilibrium;
  procedure Abort(var Msg:TMessage); virtual id_First+id_Abort;
  procedure ProcessLog;
  procedure Resume(var Msg:TMessage); virtual id_First+id_Resume;
  procedure Evolve;
  function Execute:Integer; virtual;
 end;

 PControlSolve  = ^TControlSolve;
 TControlSolve  = object(TDialog)
  procedure ChooseStart(var Msg:TMessage);
            virtual id_First + id_ChooseStart;
 end;

 PShowSol       = ^TShowSol;
 TShowSol       = object(TDialog)
  Index         : Integer;
  procedure SetupWindow; virtual;
  procedure Update(Var Msg:TMessage);
            virtual id_First + id_Update;
  procedure Show(var Msg:TMessage);
            virtual id_First + id_Show;
  procedure Dump(var Msg:TMessage);
            virtual id_First + id_Dump;
  procedure ShowNone(var Msg:TMessage);
            virtual id_First + id_ShowNone;
  procedure SaveAll(var Msg:TMessage);
            virtual id_First + id_SaveAll;
 end;

 PModeChoice    = ^TModeChoice;
 TModeChoice    = object(TObject)
  ModeString    : LongName;
  ModeCode      : Byte;
  constructor Init(AMode:Byte);
  function ShowModeString:PChar;
  function ShowModeCode:Byte;
 end;

 PChooseSol     = ^TChooseSol;
 TChooseSol     = object(TDialog)
  ThePick       : Integer;
  TheModeChoice : PModeChoice;
  ChoiceColl    : TCollection;
  procedure SetupWindow; virtual;
  procedure Ok(var Msg:TMessage);
            virtual id_First + id_Ok;
  procedure Cancel(var Msg:TMessage);
            virtual id_First + id_Cancel;
 end;

procedure InitSolveUnit;

procedure CleanupSolveUnit;

procedure InitMatrix(AMatrix:PSqrMatrix);

procedure DisposeMatrix(AMatrix:PSqrMatrix);

procedure InitUtility(AUtility:PUtility);

procedure DisposeUtility(AUtility:PUtility);

procedure StoreMatrix(ADim:Byte;AMatrix:PSqrMatrix;var StoredMatrix:PSqrMatrix);

var

  {begin Mixed Solve Statistics********************************
         MinStepNumb,
         IterationNumb,
         ConvergNumb,
         CutOffNumb,
         SlowIterNumb,
         HitBoundNumb:LongInt;
  {end Mixed Solve Statistics***********************************}
 {Solve instruments}
 Jacobian,
 {Storage,}
 Inverse,
 Transition,
 IminusT                : PSqrMatrix;
 InstantResult,
 Expectation            : PUtility;
 XVector,
 DummyCol,
 {Direction,}
 Deviation,
 OldProfile,
 Profile                : PVector;
 {StoreDimension         : Byte; }
 SelectedSolution       : PEquilibrium;
 IsEliminating,
 ShowDetails            : Boolean;

implementation

procedure InitMatrix(AMatrix:PSqrMatrix);
var ARow:PVector;Row:Byte;
begin
  for Row:=1 to MaxDimension
  do begin
   GetMem(ARow,SizeOf(Vector));
   AMatrix^[Row]:=ARow;
  end;
end;

procedure DisposeMatrix(AMatrix:PSqrMatrix);
var ARow:PVector;Row:Byte;
begin
  for Row:=1 to MaxDimension
  do begin
   ARow:=AMatrix^[Row];
   if ARow<>nil then FreeMem(ARow,SizeOf(Vector));
   AMatrix^[Row]:=nil;
  end;
end;

procedure InitUtility(AUtility:PUtility);
var ARow:PVector;Row:Byte;
begin
  for Row:=1 to MaxPlayerNumber
  do begin
   GetMem(ARow,SizeOf(Vector));
   AUtility^[Row]:=ARow;
  end;
end;

procedure DisposeUtility(AUtility:PUtility);
var ARow:PVector;Row:Byte;
begin
  for Row:=1 to MaxPlayerNumber
  do begin
   ARow:=AUtility^[Row];
   if ARow<>nil then FreeMem(ARow,SizeOf(Vector));
   AUtility^[Row]:=nil;
  end;
end;

procedure StoreMatrix(ADim:Byte;AMatrix:PSqrMatrix;var StoredMatrix:PSqrMatrix);
var StoredRow,ARow:PVector;Row,Column:Byte;
begin
 for Row:=1 to MaxDim
 do begin
  ARow:=AMatrix^[Row];
  StoredRow:=StoredMatrix^[Row];
  for Column:=1 to MaxDim
  do StoredRow^[Column]:=ARow^[Column];
 end;
end;

 {----------------------------------------------}
 {----Solution methods implementation-----------}
 {----------------------------------------------}

function Enumerator.NextSubset(CrntCardinal,Size: Byte;
                              var CrntSet: OrderedSet): Boolean;
var
 CheckOut       : Boolean;
 SubCardinal,i,
 SubSize        : Byte;
 SubSet         : OrderedSet;
begin
 if Size>1 then {Reduce to lower dimension} begin
  SubCardinal:= CrntSet[Size]-1; SubSize:= Size-1; SubSet:= CrntSet;
  CheckOut:= NextSubset(SubCardinal,SubSize,SubSet); {Test for unexhausted
                                                      subsets}
 end else CheckOut:= TRUE; {Size<=1}
 if not CheckOut {There are unexhausted subsets}
 then for i:=1 to SubSize do CrntSet[i]:= SubSet[i]; {Use subset in CrntSet}
 if CheckOut
 and (CrntSet[Size]<CrntCardinal) {All subsets exhausted but last
                                           element not used yet}
 then begin
  CrntSet[Size]:=CrntSet[Size]+1; {Increment last element}
  for i:=1 to Size-1 do CrntSet[i]:=i; {Re-initialize subsets}
  CheckOut:=FALSE; {Signal subsets not exhausted yet}
 end;
 NextSubset:=CheckOut; {TRUE when subsets<=Size are exhausted}
end;
procedure Enumerator.Init(PureCase:Boolean;NewCardinal:Byte;
                          var FullSet:OrderedSet); {Initializes ordered set}
var
 Index  : Byte;
begin
 Pure:=PureCase;
 Cardinal:=NewCardinal;
 InitSet[0]:=1;
 for Index:=1 to MaxDegree do InitSet[Index]:=Index;
 FullSet:=InitSet;
end;
{-------------------------------------------------------------------}
{ Done exploits NextSubset to generate all subsets of cardinal      }
{ less than or equal to Cardinal. It returns TRUE when done.        }
{-------------------------------------------------------------------}
function Enumerator.Done(var FullSet:OrderedSet):Boolean;
var
 CrntSize       : Byte;
begin {Done}
 Done:=FALSE;
 if Cardinal=0 then begin Done:=TRUE; Exit; end;
 CrntSize:=FullSet[0];
 if NextSubset(Cardinal,CrntSize,FullSet)
 then if Pure
      then begin Done:=TRUE; Exit;
      end else
      if (CrntSize<Cardinal)
      then begin
       FullSet:=InitSet;
       FullSet[0]:=CrntSize+1;
      end else Done:=TRUE;
end;

procedure Invertor.Init;
var Row,Column:Byte;ARow:PVector;
begin
 InvertDim:=ADimension;
 IsInvertible:=True;
 Matrix:=AMatrix;
 AbsPivot:=-HighDefault;
 InitInverse;
end;

procedure Invertor.InitInverse;
var InverseRow:PVector;Row,Column:Byte;
begin
 for Row:=1 to InvertDim
 do begin
  InverseRow:=Inverse^[Row];
  for Column:=1 to InvertDim
  do if Column=Row
     then InverseRow^[Column]:=1.0
     else InverseRow^[Column]:=0.0;
 end;
end;

function Invertor.BestRow(Column:Byte):Byte;
var
 RowIndex       : Byte;
 ARow           : PVector;
begin
 RowIndex:=Column;
 repeat
  ARow:=Matrix^[RowIndex];
  if (ABS(ARow^[Column])>AbsPivot)
  or (RowIndex=Column)
  then begin
   Pivot:=ARow^[Column];
   AbsPivot:=ABS(Pivot);
   BestRow:=RowIndex;
  end;
  RowIndex:=RowIndex+1;
 until RowIndex>InvertDim;
 if AbsPivot<LowDefault then BestRow:=0;       {Signal of Degeneracy}
end;

procedure Invertor.ExchangeRows(OldRow,NewRow:Byte);
var ARow,BRow:PVector;
 procedure MakeExchange(AMatrix:PSqrMatrix);
 begin
  ARow:=AMatrix^[OldRow];
  BRow:=AMatrix^[NewRow];
  AMatrix^[OldRow]:=BRow;;
  AMatrix^[NewRow]:=ARow;;
 end;
begin
 MakeExchange(Matrix);
 MakeExchange(Inverse);
end;

procedure Invertor.Invert;
var
 Row,
 RowIndex       : Byte;
 LeftRow,
 RightRow,
 OtherLeftRow,
 OtherRightRow  : PVector;
 procedure NormalizeRows;
  procedure DivideRow(ARow:PVector);
  var Index:Byte;
  begin
   for Index:=1 to InvertDim
   do ARow^[Index]:=SafeMultiply(Pivot,ARow^[Index]);
  end;
 begin
  LeftRow:=Matrix^[Row];
  DivideRow(LeftRow);
  RightRow:=Inverse^[Row];
  DivideRow(RightRow);
 end;
 procedure SubtractRows;
 var Index:Byte;
 begin
  for Index:=1 to InvertDim
  do begin
   OtherLeftRow^[Index]:=OtherLeftRow^[Index]-
                         SafeMultiply(Pivot,LeftRow^[Index]);
   OtherRightRow^[Index]:=OtherRightRow^[Index]-
                         SafeMultiply(Pivot,RightRow^[Index]);
  end;
 end;
begin
 Row:=0;
 repeat
  Row:=Row+1;
  RowIndex:=BestRow(Row);
  if RowIndex=0 then IsInvertible:=FALSE
  else begin
   if RowIndex>Row then ExchangeRows(Row,RowIndex);
   Pivot:=1/Pivot;
   NormalizeRows;
   for RowIndex:=1 to InvertDim
   do if RowIndex<>Row
   then begin
    OtherLeftRow:=Matrix^[RowIndex];
    Pivot:=OtherLeftRow^[Row];
    if Pivot<>0 then begin
     OtherRightRow:=Inverse^[RowIndex];
     SubtractRows;
    end;
   end;
  end;
 until not IsInvertible or (Row=InvertDim);
end;

function Invertor.DirectSolve(AVector:PVector):PVector;
var Row,Column:Byte;ARow:PVector; AReal:Real;
begin
 for Row:=1 to InvertDim
 do begin
  ARow:=Inverse^[Row];
  AReal:=0.0;
  for Column:=1 to InvertDim
  do AReal:=AReal+SafeMultiply(ARow^[Column],AVector^[Column]);
  Solution[Row]:=AReal;
 end;
  DirectSolve:=@Solution;
end;

{---------------------------------------------------------------------}
{--------------------Expectation formation----------------------------}
{---------------------------------------------------------------------}

{---------------------------------------------------------------------}
{ Activities are set in TSolveDlg. MakeFilter fills Filter and InvFltr}
{ and MakeIRT fills IR and T using Choice probabilities (provided by  }
{ TSolveDlg). MakeExpectation calls Invertor to invert (I-T) to       }
{ produce Expectation. MakeBelief produces Belief.                    }
{---------------------------------------------------------------------}

procedure Expectator.MakeFilter;
{For each active node, creates a unit of dimension.           }
{Filter gives rank of active node at that coordinate          }
{in T and IR. InvFltr gives coordinate of node of given rank  }
{in expectation calculations. Inactive nodes are not shown in }
{Filter and show a zero coordinate in expect calculations.    }
 procedure ResetFilter(ANode:PNode);far;
 begin
  Filter[ANode^.Rank]:=0;
 end;
 procedure FilterNode(ANode:PNode);far;
 begin
  if ANode^.Family^.IsActive
  then begin
   Dimension:=Dimension+1;
   Filter[Dimension]:=ANode^.Rank;
   InvFltr[ANode^.Rank]:=Dimension;
  end else InvFltr[ANode^.Rank]:=0;
 end;
begin {Update}
 Dimension:=0;                          {Update Filter}
 TheGame^.NodeSet^.ForEach(@ResetFilter);
 TheGame^.NodeSet^.ForEach(@FilterNode);
end;

procedure Expectator.MakeIRT(ChosenPlayer:PPlayer);
{Creates IminusT & InstantResult matrices using InvFltr}
var
 Row,Col  : Byte;
 ARow,
 BRow     : PVector;
 procedure RecordChoice(AChoice:PChoice); far;
  procedure RecordMove(AMove:PMove);far;
   procedure RecordIR(APlayer:PPlayer);far;
   begin
    ARow:=InstantResult^[APlayer^.Rank];
    ARow^[InvFltr[AMove^.From^.Rank]]:=
      ARow^[InvFltr[AMove^.From^.Rank]]+
      SafeMultiply(AMove^.ShowPayoff(APlayer^.Rank),AChoice^.Probability);
   end;
  begin  {RecordMove}
   with AMove^ do begin
    if Upto<>nil
    then begin          {Record move proba in IminusT}
     ARow:=IminusT^[InvFltr[From^.Rank]];
     ARow^[InvFltr[Upto^.Rank]]:=
          ARow^[InvFltr[Upto^.Rank]]-Discount*DefaultDiscount*AChoice^.Probability;
     if HighPrecis      {Record move proba in Transition}
     then begin
      BRow:=Transition^[InvFltr[From^.Rank]];
      BRow^[InvFltr[Upto^.Rank]]:=
           BRow^[InvFltr[Upto^.Rank]]+Discount*DefaultDiscount*AChoice^.Probability;

     end;
    end;
    if ChosenPlayer=nil
    then TheGame^.PlayerSet^.ForEach(@RecordIR)
    else RecordIR(ChosenPlayer);
   end;
  end;  {RecordMove}
 begin  {RecordChoice}
  with AChoice^ do
                if IsActive
                and Source^.IsActive
                then Instance.ForEach(@RecordMove);
 end;   {RecordChoice}
 procedure InitIR(APlayer:PPlayer);far;
 var Index:Byte;
 begin
  ARow:=InstantResult^[APlayer^.Rank];
  for Index:=1 to Dimension do ARow^[Index]:=DefaultCost;
 end;
begin
 MakeFilter;
 for Row:=1 to Dimension              {Create Dimension and Filter}
 do begin
  ARow:=IminusT^[Row];                {Initialize IminusT as identity matrix}
  for Col:=1 to Dimension
  do if Col=Row then ARow^[Col]:=1.0
                else ARow^[Col]:=0.0;
 end;
 if HighPrecis                        {If high precision needed}
 then for Row:=1 to Dimension
 do begin
  BRow:=Transition^[Row];             {Initialize Transition identically 0}
  for Col:=1 to Dimension
  do BRow^[Col]:=0.0;
 end;
 if ChosenPlayer=nil
 then TheGame^.PlayerSet^.ForEach(@InitIR)
 else InitIR(ChosenPlayer);
 TheGame^.ChoiceSet^.ForEach(@RecordChoice);     {Construct IminusT and IR}
 {Need to fill Transition if small enough step............................}
 TheInvertor.Init(IminusT,Dimension);
end;

procedure Expectator.CheckPositiveInverse;
var ARow:PVector;RowIndex,ColIndex:Byte;
begin
 for RowIndex:=1 to Dimension
 do begin
  ARow:=Inverse^[RowIndex];
  for ColIndex:=1 to Dimension
  do if ARow^[ColIndex]<MatrixCheck     {Small positive value}
     then ARow^[ColIndex]:=0;
 end;
end;

procedure Expectator.ImproveInverse;       {Iterate Inverse=Id+Transition*Inverse}
var Row,Col,Index:Byte;ARow,BRow:PVector;Dummy:Real;
begin
 for Col:=1 to Dimension
 do begin
  for Row:=1 to Dimension      {Calculate DummyCol at each Row}
  do begin
   ARow:=Transition^[Row];
   Dummy:=0.0;
   for Index:=1 to Dimension
   do begin
    BRow:=Inverse^[Index];
    Dummy:=Dummy+SafeMultiply(ARow^[Index],BRow^[Col]);
   end;
   DummyCol^[Row]:=Dummy;
  end;
  for Row:=1 to Dimension       {Replace DummyCol into Inverse}
  do begin
   BRow:=Inverse^[Row];
   BRow^[Col]:=DummyCol^[Row];
   if Row=Col then BRow^[Col]:=BRow^[Col]+1.0;  {Add identity}
  end;
 end;
end;

procedure Expectator.MakeBeliefs;
var ARow:PVector;
 procedure ResetBelief(ANode:PNode);far;
 var TotalBelief:Real;
  procedure AddStartNode(BNode:PNode);far;
  var Factor:Real;
  begin
   if InvFltr[BNode^.Rank]>0
   then begin
    Factor:=0;
    ARow:=Inverse^[InvFltr[BNode^.Rank]];
    if TheGameMode^.SolveConcept in [sm_Perfect,sm_Sequential]    {IsPerfect}
    then begin
     if (BNode=TheGame^.StartNode)
     then Factor:=StartDefault
     else if BNode^.IsBayes then Factor:=BayesDefault  {Experiment.. low default}
                            else Factor:={1.0}SingletDefault;
    end else if (BNode=TheGame^.StartNode)
             then Factor:=1.0;
    TotalBelief:=TotalBelief+SafeMultiply(Factor,ARow^[InvFltr[ANode^.Rank]]);
   end;         {Since positive inverse}
  end;
 begin {ResetBelief}
  TotalBelief:=VeryLowDefault;                     {Experiment}
  if InvFltr[ANode^.Rank]>0                         {Node is active}
  then begin
   if TheGameMode^.SolveConcept in [sm_Perfect,sm_Sequential]   {IsPerfect}
   then TheGame^.StartNodeColl^.ForEach(@AddStartNode)
   else AddStartNode(TheGame^.StartNode);
  end;
  ANode^.SetBelief(TotalBelief);
 end; {ResetBelief}
 procedure CheckBelief(ANode:PNode);far;                {Check positive beliefs}
 begin
  with ANode^ do if Belief<TinyDefault
                 then SetBelief(TinyDefault);
  if (TheGameMode^.SolveConcept=sm_Nash)        {not IsPerfect}
  then ANode^.SetNormBelief(ANode^.Belief);  {Default if not IsPerfect}
 end;
 procedure ResetSum(AnInfo:PInfo);far;
 var Sum:Real;
  procedure AddBelief(ANode:PNode);far;
  begin
   Sum:=Sum+ANode^.Belief;
  end;
 begin
  Sum:=0;
  AnInfo^.Event.ForEach(@AddBelief);
  if Sum<LowDefault then Sum:=LowDefault;
  AnInfo^.SetBeliefSum(Sum);
 end;
 procedure PerfectNormalize(AnInfo:PInfo);far;
 var Denom : Real;
  procedure DivideBelief(ANode:PNode);far;
  begin
   ANode^.SetNormBelief(SafeMultiply(Denom,ANode^.Belief));
  end;
 begin
  Denom:=1/AnInfo^.BeliefSum;
  AnInfo^.Event.ForEach(@DivideBelief);
 end;
begin
  TheGame^.NodeSet^.ForEach(@ResetBelief);
  TheGame^.NodeSet^.ForEach(@CheckBelief);
  TheGame^.InfoSet^.ForEach(@ResetSum);
  if TheGameMode^.SolveConcept in [sm_Perfect,sm_Sequential]{IsPerfect}
  then TheGame^.InfoSet^.ForEach(@PerfectNormalize);
end;

function Expectator.MakeExpectation(IsHighPrec:Boolean;ChosenPlayer:PPlayer):Boolean;
var ARow:PVector;Turn:Byte;
 procedure MakePlayerExp(APlayer:PPlayer);far;
 var Index:Byte;
 begin
   XVector:=TheInvertor.DirectSolve(InstantResult^[APlayer^.Rank]);
   ARow:=Expectation^[APlayer^.Rank];
   for Index:=1 to MaxNodeNumber do ARow^[Index]:=0;
   for Index:=1 to Dimension
   do ARow^[Filter[Index]]:=XVector^[Index]; {Expectation is unfiltered}
 end;
begin
 HighPrecis:=IsHighPrec;
 MakeIRT(ChosenPlayer);
 TheInvertor.Invert;
 if TheInvertor.IsInvertible
 then begin
  MakeExpectation:=True;
  CheckPositiveInverse;     {Cut out all small or negative entries}
  if HighPrecis
  then for Turn:=1 to 4     {Changed from 3 Feb 99}
       do ImproveInverse;   {To improve Inverse if small enough norm}
 {StoreMatrix(Dimension,Inverse,Storage);
 StoreDimension:=Dimension;}
  if ChosenPlayer=nil
  then TheGame^.PlayerSet^.ForEach(@MakePlayerExp)
  else MakePlayerExp(ChosenPlayer);         {For Estimator}
  {Now make beliefs}
  MakeBeliefs;
 end else MakeExpectation:=False;
end;

procedure Expectator.MakeIncentive(EstimatedChoice:PChoice);
var OwnerRank:Byte; AValue:Real; ARow:PVector;
 procedure MoveSetChoiceIncentive(AChoice:PChoice);far;
  procedure SetMoveIncentive(AMove:PMove);far;
  begin
   with AMove^ do begin
    if Upto=nil
    then SetIncentive(ShowPayoff(OwnerRank))
    else if Upto^.Family^.IsActive
         then SetIncentive(ShowPayoff(OwnerRank)+Discount*
                           DefaultDiscount*ARow^[Upto^.Rank])
         else SetIncentive(ARow^[From^.Rank]{-BigDefault});
   end;
  end;
 begin    {MoveSetChoiceIncentive}
  with AChoice^ do
  if Source^.IsActive
  and (Source^.Owner<>nil)
  then begin
   OwnerRank:=Source^.Owner^.Rank;
   ARow:=Expectation^[OwnerRank];
   Instance.ForEach(@SetMoveIncentive);
  end;
 end;    {MoveSetChoiceIncentive}
 procedure BeliefSetChoiceIncentive(AChoice:PChoice);far;
  procedure AddIncentive(AMove:PMove);far;
  begin
   with AMove^
   do AValue:=AValue+SafeMultiply(From^.NormBelief,Incentive);
  end;
 begin   {BeliefSetChoiceIncentive}
  with AChoice^ do
  if Source^.IsActive
  and (Source^.Owner<>nil)
  then begin
   AValue:=0;
   Instance.ForEach(@AddIncentive);
   SetIncentive(AValue);
  end;  {BeliefSetChoiceIncentive}
 end;
begin
 if EstimatedChoice=nil
 then begin
  TheGame^.ChoiceSet^.ForEach(@MoveSetChoiceIncentive);
  TheGame^.ChoiceSet^.ForEach(@BeliefSetChoiceIncentive);
  {MakeVector(13);
  MakeVector(12); }
 end else begin
  MoveSetChoiceIncentive(EstimatedChoice);
  BeliefSetChoiceIncentive(EstimatedChoice);
 end;
end;

{-------------------------------------------------------------------}
{----------------Derivator object implementation--------------------}
{-------------------------------------------------------------------}

procedure Derivator.MakeDeviation;
var BoundChoice:PChoice;
 procedure RecordDeviation(AnInfo:PInfo);far;
  procedure SubtractBound(AChoice:PChoice);far;
  begin
   if (AChoice<>AnInfo^.Bound)
   and AChoice^.IsActive
   then Deviation^[AChoice^.Coordinate]:=
         SafeMultiply(AChoice^.Probability,
        (AChoice^.Incentive-BoundChoice^.Incentive));
  end;
 begin
  if AnInfo^.IsActive and (AnInfo^.Owner<>nil)
  then begin
   BoundChoice:=AnInfo^.Bound;
   AnInfo^.ChoiceList.ForEach(@SubtractBound);
  end;
 end;
begin
 TheGame^.InfoSet^.ForEach(@RecordDeviation);
end;

function Derivator.dzkdxj(zk,xj:PChoice):Real;
var Dummy:Real;
begin
 if (not zk^.IsActive)
 or (not xj^.IsActive)
 or (xj=xj^.Source^.Bound)
 or (xj^.Source<>zk^.Source)
 then Dummy:=0.0
 else begin
  Dummy:=xj^.Probability;
  if xj=zk then Dummy:=SafeMultiply(Dummy,(1.0-zk^.Probability))
           else Dummy:=-SafeMultiply(Dummy,zk^.Probability);
 end;
 dzkdxj:=Dummy;
end;

function Derivator.dAbsBeliefOfNudzk(nu:PNode;k:PMove):Real;
var Result:Real;ARow:Pvector;
begin
 if k^.Upto=nil
 then Result:=0
 else begin
  ARow:=Inverse^[InvFltr[k^.Upto^.Rank]];
  Result:=k^.Discount*DefaultDiscount*
                          SafeMultiply(k^.From^.Belief,ARow^[InvFltr[nu^.Rank]]);
 end;
 {MakeDetailLog(121,'',k^.From^.ShowName,Result); }
 dAbsBeliefOfNudzk:=Result;
end;

function Derivator.dAbsBeliefOfNudck(nu:PNode;ck:PChoice):Real;
var Total:Real;
 procedure AddMove(k:PMove);far;
 begin
  Total:=Total+dAbsBeliefOfNudzk(nu,k);
 end;
begin
 Total:=0;
 ck^.Instance.ForEach(@AddMove);
 {MakeDetailLog(111,nu^.ShowName,ck^.ShowName,Total); }
 dAbsBeliefOfNudck:=Total;
end;

function Derivator.dAbsBeliefOfNudxj(nu:PNode;xj:PChoice):Real;
{*************This is for testing purposes only**************}
var Deriv:Real;
 procedure AddPartial(ck:PChoice);far;
 begin
  if not ck^.IsActive then Exit;
  Deriv:=Deriv+SafeMultiply(dAbsBeliefOfNudck(nu,ck),dzkdxj(ck,xj));
 end;
begin
 Deriv:=0;
 if not xj^.IsActive then Exit;
 if (xj=xj^.Source^.Bound) then Exit;
 xj^.Source^.ChoiceList.ForEach(@AddPartial);
 dAbsBeliefOfNudxj:=Deriv;
end;

function Derivator.dNormBeliefOfNudck(nu:PNode;ck:PChoice):Real;
var Denom,Deriv:Real;
 procedure AddPartial(Eta:PNode);far;
 begin
  Deriv:=Deriv+dAbsBeliefOfNudck(Eta,ck);
 end;
begin
 Deriv:=0;
 if not ck^.IsActive then Exit;
 Nu^.Family^.Event.ForEach(@AddPartial);
 {MakeDetailLog(110,nu^.ShowName,ck^.ShowName,Deriv);}
 Deriv:=-SafeMultiply(Deriv,Nu^.NormBelief);
 Deriv:=Deriv+dAbsBeliefOfNudck(Nu,ck);
 Denom:=1.0/Nu^.Family^.BeliefSum;
 Deriv:=SafeMultiply(Deriv,Denom);
 {MakeDetailLog(112,nu^.ShowName,ck^.ShowName,Nu^.Showfamily^.ShowBeliefSum);}
 dNormBeliefOfNudck:=Deriv;
end;

function Derivator.dNormBeliefOfNudxj(Nu:PNode;xj:PChoice):Real;
var Deriv:Real;
 procedure AddPartial(ck:PChoice);far;
 begin
  if not ck^.IsActive then Exit;
  Deriv:=Deriv+SafeMultiply(dNormBeliefOfNudck(Nu,ck),dzkdxj(ck,xj));
 end;
begin
 Deriv:=0;
 if not xj^.IsActive then Exit;
 xj^.Source^.ChoiceList.ForEach(@AddPartial);
 dNormBeliefOfNudxj:=Deriv;
end;

function Derivator.dEOmegaOfNudzk(Omega:PPlayer;Nu:PNode;k:PMove):Real;
var Box:Real; ERow,IRow:PVector;
begin
 dEOmegaOfNudzk:=0;
 Box:=k^.ShowPayoff(Omega^.Rank);
 if (k^.Upto<>nil)
 then if k^.Upto^.Family^.IsActive
      then begin
       ERow:=Expectation^[Omega^.Rank];
       Box:=Box+k^.Discount*DefaultDiscount
                  *ERow^[k^.Upto^.Rank];
      end;
 IRow:=Inverse^[InvFltr[Nu^.Rank]];
 dEOmegaOfNudzk:=SafeMultiply(Box,IRow^[InvFltr[k^.From^.Rank]]);
end;

function Derivator.dEOmegaOfNudxj(Omega:PPlayer;Nu:PNode;j:PChoice):Real;
var jSource:PInfo; Partial,dzk:Real;
 procedure AddPartial(k:PChoice);far;
  procedure AddItem(Mu:PMove);far;
  begin
   Partial:=Partial+SafeMultiply(dzk,dEOmegaOfNudzk(Omega,Nu,Mu));
  end;
 begin
  if not k^.IsActive then Exit;
  dzk:=dzkdxj(k,j);
  k^.Instance.ForEach(@AddItem);
 end;
begin
 Partial:=0;
 if Omega<>nil
 then begin
  jSource:=j^.Source;
  jSource^.ChoiceList.ForEach(@AddPartial);
 end;
 dEOmegaOfNudxj:=Partial;
end;

function Derivator.dciIncentivedxj(ci,xj:PChoice):Real;
var Omega:PPlayer;Partial:Real;
 function dmiIncentivedxj(mi:PMove):Real;
 begin
  if (mi^.Upto=nil)
  then dmiIncentivedxj:=0
  else if mi^.Upto^.Family^.IsActive
       then dmiIncentivedxj:=mi^.Discount*DefaultDiscount*
                             dEOmegaOfNudxj(Omega,mi^.Upto,xj)
       else dmiIncentivedxj:=dEOmegaOfNudxj(Omega,mi^.From,xj);
 end;
 procedure AddDbNu(mi:PMove);far;
 var dbnu:Real;
 begin
  dbnu:=dNormBeliefOfNudxj(mi^.From,xj);
  {MakeDetailLog(11,mi^.From^.ShowName,xj^.ShowName,dbnu); }
  Partial:=Partial+SafeMultiply(mi^.Incentive,dbnu);
 end;
 procedure AddDmi(mi:PMove);far;
 begin
  Partial:=Partial+SafeMultiply(mi^.From^.NormBelief,dmiIncentivedxj(mi));
 end;
begin
 {MakeDetailLog(10,ci^.ShowName,xj^.ShowName,0); }
 Omega:=nil;
 Omega:=ci^.Source^.Owner;
 Partial:=0;
 if Omega<>nil
 then begin
  ci^.Instance.ForEach(@AddDbNu);
  ci^.Instance.ForEach(@AddDmi);
 end;
 dciIncentivedxj:=Partial;
end;

function Derivator.dfidxj(fi,xj:PChoice):Real;
var fiSource,xjSource:PInfo;fiBound:PChoice;
Derivative,dfi,dbi:Real;
begin
 {Begin with some safety}
 dfidxj:=TopDefault;
 if not (fi^.IsActive and xj^.IsActive) then Exit;
 fiSource:=fi^.Source;
 fiBound:=fiSource^.Bound;
 if (fiBound=fi) then Exit;
 xjSource:=xj^.Source;
 if (xjSource^.Bound=xj) then Exit;
 {End safety measures}
 {MakeDetailLog(0,fi^.ShowName,xj^.ShowName,0);}
 if fiSource<>xjSource
 then Derivative:=0
 else Derivative:=dzkdxj(fi,xj);
 {MakeDetailLog(1,fi^.ShowName,xj^.ShowName,Derivative);
 MakeDetailLog(2,fi^.ShowName,'',fi^.ShowIncentive);
 MakeDetailLog(2,fiBound^.ShowName,'',fiBound^.ShowIncentive); }
 Derivative:=SafeMultiply(Derivative,(fi^.Incentive-fiBound^.Incentive));
 {MakeDetailLog(3,fi^.ShowName,'',fi^.Probability); }
 dfi:=dciIncentivedxj(fi,xj);
 {MakeDetailLog(4,fi^.ShowName,xj^.ShowName,dfi);}
 dbi:=dciIncentivedxj(fiBound,xj);
 {MakeDetailLog(4,fiBound^.ShowName,xj^.ShowName,dbi);}
 Derivative:=Derivative+SafeMultiply(fi^.Probability,(dfi-dbi));
 {MakeDetailLog(5,fi^.ShowName,xj^.ShowName,Derivative); }
 dfidxj:=Derivative;
end;

procedure Derivator.MakeTestExpectation;
var dExp:PVector;
 procedure MakeExpTest(xj:PChoice);far;
  procedure TestPlayer(Omega:PPlayer);far;
   procedure TestExp(nu:PNode);far;
   begin
    if not nu^.Family^.IsActive then Exit;
    dExp^[nu^.Rank]:=dEOmegaOfNudxj(Omega,nu,xj);
   end;
  begin
   {MakeDetailLog(61,xj^.ShowName,Omega^.ShowName,0);
   dExp:=New(PVector);
   TheGame^.NodeSet^.ForEach(@TestExp);
   {MakeVectorLog(61,TheGame^.NodeSet^.Count,dExp);
   Dispose(dExp); }
  end;
 begin
  if not xj^.IsActive then Exit;
  if (xj=xj^.Source^.Bound) then Exit;
  TheGame^.PlayerSet^.ForEach(@TestPlayer);
 end;
begin
 TheGame^.ChoiceSet^.ForEach(@MakeExpTest);
end;

procedure Derivator.MakeTestIncentive;
var dInc:PVector;
 procedure MakeIncTest(xj:PChoice);far;
  procedure TestInc(ck:PChoice);far;
  begin
   if not ck^.IsActive then Exit;
   dInc^[ck^.Rank]:=dciIncentivedxj(ck,xj);
  end;
 begin
  if not xj^.IsActive then Exit;
  if (xj=xj^.Source^.Bound) then Exit;
  {MakeDetailLog(60,xj^.ShowName,'',0);
  dInc:=New(PVector);
  ChoiceSet^.ForEach(@TestInc);
  {MakeVectorLog(60,ChoiceSet^.Count,dInc);
  Dispose(dInc); }
 end;
begin
 TheGame^.ChoiceSet^.ForEach(@MakeIncTest);
end;

procedure Derivator.MakeTestBelief;
var dAb,dNb:PVector;
 procedure MakeAbsTest(xj:PChoice);far;
  procedure TestAbs(nu:PNode);far;
  begin
   dAb^[nu^.Rank]:=dAbsBeliefOfNudxj(nu,xj);
  end;
 begin
  if not xj^.IsActive then Exit;
  if (xj=xj^.Source^.Bound) then Exit;
  {MakeDetailLog(50,xj^.ShowName,'',0);          {Announce the test}
  {dAb:=New(PVector);
  TheGame^.NodeSet^.ForEach(@TestAbs);
  {MakeVectorLog(50,TheGame^.NodeSet^.Count,dAb);         {Record test result}
  {Dispose(dAb);}
 end;
 procedure MakeNormTest(xj:PChoice);far;
  procedure TestAbs(nu:PNode);far;
  begin
   dNb^[nu^.Rank]:=dNormBeliefOfNudxj(nu,xj);
  end;
 begin
  if not xj^.IsActive then Exit;
  if (xj=xj^.Source^.Bound) then Exit;
  {MakeDetailLog(51,xj^.ShowName,'',0);          {Announce the test}
  {dNb:=New(PVector);
  TheGame^.NodeSet^.ForEach(@TestAbs);
  {MakeVectorLog(51,TheGame^.NodeSet^.Count,dNb);         {Record test result}
  {Dispose(dNb);}
 end;
begin
 TheGame^.ChoiceSet^.ForEach(@MakeAbsTest);
 TheGame^.ChoiceSet^.ForEach(@MakeNormTest);
end;

procedure Derivator.MakeJacobian;
var fiBound,xjBound:PChoice;JRow:PVector;Deriv:Real;
 procedure MakeRow(fi:PChoice);far;
  procedure MakeColumn(xj:PChoice);far;
  begin
   if xj^.Coordinate=0 then Exit;
   xjBound:=xj^.Source^.Bound;
   if (xj=xjBound) then Exit;
   JRow:=Jacobian^[fi^.Coordinate];
   Deriv:=dfidxj(fi,xj);
   JRow^[xj^.Coordinate]:=Deriv;
   {MakeLogDeriv(fi,xj,Deriv);  }
  end;
 begin
  if fi^.Coordinate=0 then Exit;
  fiBound:=fi^.Source^.Bound;
  if (fi=fiBound) then Exit;
  TheGame^.ChoiceSet^.ForEach(@MakeColumn);
 end;
begin
 TheGame^.ChoiceSet^.ForEach(@MakeRow);
end;

{-------------------------------------------------------------------}
{----------------Solve object implementation------------------------}
{-------------------------------------------------------------------}

constructor TSolveDlg.Init(AParent:PWindowsObject;ResourceID:PChar);
begin
 TDialog.Init(AParent,ResourceID);
 IsModal:=False;
 TheExpectator:=New(PExpectator);
 TheDerivator:=New(PDerivator);
 SignatureList.Init(MaxTurn,MaxTurn);       {Was major source of heap leak}
end;

{procedure TSolveDlg.SetupWindow;
begin
 TDialog.Show(sw_ShowNormal);
end; }

function TSolveDlg.MakeStartInfo:PInfo;
var TheStart:PInfo;
 function FindFreeInfo(AnInfo:PInfo):Boolean;far;
 begin
  if AnInfo^.Owner=nil
  then FindFreeInfo:=False
  else begin
   TheStart:=AnInfo;
   FindFreeInfo:=True;
  end;
 end;
begin
 TheStart:=nil;
 if not TheGame^.HasBayesianInfo
 then TheGame^.StartInfoColl^.FirstThat(@FindFreeInfo)
 else if TheGame^.StartNode^.Owner<>nil
      then TheStart:=TheGame^.StartNode^.Family;
 if TheStart=nil
 then TheGame^.InfoSet^.FirstThat(@FindFreeInfo);
 MakeStartInfo:=TheStart;
end;

destructor TSolveDlg.Done;
begin
 Dispose(TheExpectator);
 Dispose(TheDerivator);
 TDialog.Done;
end;

procedure TSolveDlg.ConstructStrategy(DoneInfos,StratProfile:TCollection;
                                      var TooMany:Boolean);
var NextDoneInfos:TCollection;NextInfo:PInfo;
 procedure FillInfos(AnInfo:PInfo);far;
 begin
  NextDoneInfos.Insert(AnInfo);
 end;
 procedure SeekNextInfo;
  procedure FindEligible(AnInfo:PInfo);far;
   function IsInDoneInfos:Boolean;
    procedure IsDone(BInfo:PInfo);far;
    begin
     if (BInfo=AnInfo) then IsInDoneInfos:=True;
    end;
   begin
    IsInDoneInfos:=False;
    if DoneInfos.Count>0 then DoneInfos.ForEach(@IsDone);
   end;
  begin
   if AnInfo^.Owner<>EstimatedPlayer then Exit;
   if IsInDoneInfos then Exit else NextInfo:=AnInfo;
  end;
 begin
  NextInfo:=nil;
  TheGame^.InfoSet^.ForEach(@FindEligible);
 end;
 procedure RecordProfile;
 var AStrategy:PStrategy;
  procedure FillStrategy(AChoice:PChoice);far;
  begin
   AStrategy^.AddDecision(AChoice);
  end;
 begin
  if StratProfile.Count=0 then Exit;
  if LowMemory
  then begin
   LowMemFlag:=True;
   IsAborted:=True;
  end;
  AStrategy:=New(PStrategy,Init(nil,EstimatedPlayer));
  StratProfile.ForEach(@FillStrategy);
  TheGame^.StrategySet^.Insert(AStrategy);
  if TheGame^.StrategySet^.Count>=MaxStrategySet
  then TooMany:=True;
  {MakeStrategyLog(AStrategy);   {For Debug}
 end;
 procedure ScreenNextProfile(NextChoice:PChoice);far;
 var NextProfile:TCollection;
  procedure FillProfile(AChoice:PChoice);far;
  begin
   NextProfile.Insert(AChoice);
  end;
 begin
  NextProfile.Init(10,10);
  StratProfile.ForEach(@FillProfile);
  NextProfile.Insert(NextChoice);
  ConstructStrategy(NextDoneInfos,NextProfile,TooMany);
  NextProfile.DeleteAll;
 end;
begin
 if TooMany then Exit;
 SeekNextInfo;
 if NextInfo=nil
 then RecordProfile
 else begin
  NextDoneInfos.Init(10,10);
  DoneInfos.ForEach(@FillInfos);
  NextDoneInfos.Insert(NextInfo);
  NextInfo^.ChoiceList.ForEach(@ScreenNextProfile);
  NextDoneInfos.DeleteAll;
 end;
end;

function TSolveDlg.MakeStrategies:Boolean;
var StartProfile:TCollection; {of PChoice}
    StartInfos:TCollection; {of PInfo}
    TooMany:Boolean;
 procedure MakePlayerStrategies(APlayer:PPlayer);far;
 begin
  StartInfos.DeleteAll;
  StartProfile.DeleteAll;
  EstimatedPlayer:=APlayer;
  ConstructStrategy(StartInfos,StartProfile,TooMany);
 end;
begin
 TheGame^.StrategySet^.FreeAll;
 StartProfile.Init(10,10);
 StartInfos.Init(10,10);
 TooMany:=False;
 TheGame^.PlayerSet^.ForEach(@MakePlayerStrategies); {Use EstimatedPlayer}
 if TooMany
 then begin
  MakeStrategies:=False;
  LoadString(HInstance,76,ErrorString,LongSize);
  WhatIsWrong(HWindow,ErrorString);
 end else MakeStrategies:=True;
 StartProfile.DeleteAll;
 StartInfos.DeleteAll;
end;

function TSolveDlg.Norm:Real;
 var Index:Byte;Dummy:Real;
begin
 Dummy:=0;
 for Index:=1 to Dim
 do Dummy:=Dummy+SafeMultiply(Deviation^[Index],Deviation^[Index]);
 Norm:=Dummy;
end;

function TSolveDlg.MakeStep:Real;
var Test:Real;
begin
 MakeStep:=Step;
 if (NewNorm=0) or (OldNorm=TopDefault) then Exit;
 Test:=(Logarithm(NewNorm)-Logarithm(OldNorm))/Step;
 if Test<-4.0 then Exit
 else if Test<-2.3
      then MakeStep:=1.2*Step                          {-4.0<Test<-2.3}
      else if Test<-2.2
           then MakeStep:=1.4*Step                     {-2.3<Step<-2.2}
           else if Test<-2.1
                then MakeStep:=2*Step                  {-2.2<Step<-2.1}
                else if Test<-1.9
                     then MakeStep:=1.4*Step           {-2.1<Step<-1.9}
                     else if Test<-1.8
                          then MakeStep:=1.2*Step      {-1.9<Step<-1.8}
                          else if Test<-1.7
                               then MakeStep:=Step     {-1.8<Step<-1.7}
                               else if Test<-1.0
                                    then MakeStep:=0.8*Step
                                    else if Test>=0
                                    then begin
                                     MakeStep:=0.5*Step;
                                    end;
end;

procedure TSolveDlg.ResetBounds(IsInitial:Boolean);
{When IsInitial, incentives do not exist and cannot be used}
var MaxIncentive:Real;
 procedure ReSetBound(AnInfo:PInfo);far;
  procedure FindIfBound(AChoice:PChoice);far;
  begin
   if AChoice^.IsActive
   then if IsInitial
        then begin
         AnInfo^.SetBound(AChoice);
        end else if AChoice^.Incentive>MaxIncentive
             then begin
              AnInfo^.SetBound(AChoice);
              MaxIncentive:=AChoice^.Incentive;
             end;
  end;
 begin {ResetBound}
  with AnInfo^
  do if IsActive
     then begin
      MaxIncentive:=-TopDefault;                {Arbitrary value}
      ChoiceList.ForEach(@FindIfBound);
      if Bound^.Coordinate<>0           {Means bound has changed}
      then SetProfileChange(Bound^.ProfileValue)
      else SetProfileChange(0);
     end;
 end; {ResetBound}
begin
 TheGame^.InfoSet^.ForEach(@ReSetBound);
end;

procedure TSolveDlg.ResetCoordinates(IsInitial:Boolean);
var Index:Byte;
 procedure ResetCoordinate(AnInfo:PInfo);far;
  procedure RecordCoordinate(AChoice:PChoice);far;
  begin
   if not AnInfo^.IsActive
   or (AnInfo^.Owner=nil)
   or not AChoice^.IsActive
   or (AChoice=AnInfo^.Bound)
   then AChoice^.SetCoordinate(0)
   else begin
    Index:=Index+1;
    AChoice^.SetCoordinate(Index);
   end;
  end;
 begin
  AnInfo^.ChoiceList.ForEach(@RecordCoordinate);
 end;
 procedure CheckDimension;
 begin
  Dim:=Index;
  if Dim>MaxDim
  then begin
   IsTooFat:=True;
   IsAborted:=True;
  end;
 end;
begin
 Index:=0;
 TheGame^.InfoSet^.ForEach(@ResetCoordinate);
 if IsInitial
 then CheckDimension;
end;

procedure TSolveDlg.ConvertProfile;
 procedure AdjustProfile(AnInfo:PInfo);far;
 var Change:Real;
  procedure SubtractProfileChange(AChoice:PChoice);far;
  begin
   with AChoice^ do
   if Coordinate>0
   then SetProfileValue(ProfileValue-Change)
   else SetProfileValue(0);
  end;
 begin
  with AnInfo^ do
  if IsActive and (Owner<>nil)
  then begin
   Change:=ProfileChange;
   ChoiceList.ForEach(@SubtractProfileChange);
  end;
 end;
begin
 TheGame^.InfoSet^.ForEach(@AdjustProfile);
end;

procedure TSolveDlg.Explore(Location:Byte);
var I:Byte; Value:Real;
 procedure ResetChoiceValue(AChoice:PChoice);far;
 begin
  with AChoice^ do
  if Coordinate>0
  then SetProfileValue(Profile^[Coordinate])
  else SetProfileValue(0);
 end;
begin
 if Location=1 then Turn:=0;
 if IsAborted then Exit;
 for I:=0 to 2 do begin
  case I of
   0: Value:=0.0;
   1: Value:=2.5;
   2: Value:=-2.5;
  end;
  Profile^[Location]:=Value;
  if (Location<Dim)
  then Explore(Location+1)
  else begin
   Turn:=Turn+1;
   if Turn>Complexity
   then IsAborted:=True;
   TheGame^.ChoiceSet^.ForEach(@ResetChoiceValue);
   if MixedSolve
   then if IsOptimalSet(nil)
        then SaveEquilibrium;
   PostProgress(Complexity);
  end;
 end;
end;

function TSolveDlg.MakeRandomProfile;
 var Entry,Value:Integer;
     Signature:LongInt;
     IsNewSignature:Boolean;
     NewSignature:PSignature;
 procedure CheckSignature(ASignature:PSignature);far;
 begin
  if ASignature^.Value=Signature
  then IsNewSignature:=False;
 end;
 procedure MakeSignature(AChoice:PChoice);far;
 begin
  with AChoice^ do
  if Coordinate>0
  then begin
   Value:=Random($0004)-2;
   if Value>0 then Value:=1;
   if Value<0 then Value:=-1;
   SetProfileValue(2.5*Value);                             {Profile^[Entry]:=}
   if Coordinate<=18 then Signature:=3*Signature+Value+1;
  end;
 end;
begin
 Signature:=0;
 TheGame^.ChoiceSet^.ForEach(@MakeSignature);
 IsNewSignature:=True;
 SignatureList.ForEach(@CheckSignature);
 if IsNewSignature
 then begin
  MakeRandomProfile:=True;
  NewSignature:=New(PSignature,Init(Signature));
  SignatureList.Insert(NewSignature);
 end else MakeRandomProfile:=False;
end;

procedure TSolveDlg.SampleInterior;
begin
 Turn:=0;
 repeat
  Turn:=Turn+1;
  if MakeRandomProfile
  then if MixedSolve
       then if IsOptimalSet(nil)
            then SaveEquilibrium;
  PostProgress(MaxTurn);
 until (Turn>=MaxTurn) or IsAborted;
end;

function TSolveDlg.MakeRandomFacet:Boolean;
 var Entry,Value:Integer;
     Signature:LongInt;
     MakeFacet,CheckActive,IsNewSignature:Boolean;
     NewSignature:PSignature;
 procedure CheckSignature(ASignature:PSignature);far;
 begin
  if ASignature^.Value=Signature
  then IsNewSignature:=False;
 end;
 procedure Inactivate(AnInfo:PInfo);far;
 var IsActive:Boolean;
  procedure ResetChoice(AChoice:PChoice);far;
  begin
   AChoice^.SetActive(IsActive);
  end;
 begin {Inactivate}
  if AnInfo^.Owner=nil
  then begin
   IsActive:=True;
   AnInfo^.SetActive(True);
   AnInfo^.ChoiceList.ForEach(@ResetChoice);
  end else begin
   IsActive:=False;
   AnInfo^.SetActive(False);
   AnInfo^.ChoiceList.ForEach(@ResetChoice);
  end;
 end;  {Inactivate}
 procedure RandomActive(AChoice:PChoice);far;
 begin
  if (AChoice^.Source^.Owner=nil) then Exit;
  Entry:=Entry+1;
  Value:=Random($0003);
  if Entry<=30
  then Signature:=2*Signature+Value;
  if Value>0
  then begin
   AChoice^.SetActive(True);
   AChoice^.Source^.SetActive(True);
  end;
 end;
 procedure CheckAllActive(AnInfo:PInfo);far;
 begin
  if not AnInfo^.IsActive
  then CheckActive:=False;
 end;
begin
 MakeFacet:=False;
 CheckActive:=True;
 Signature:=0;
 Entry:=0;
 TheGame^.InfoSet^.ForEach(@Inactivate);
 TheGame^.ChoiceSet^.ForEach(@RandomActive);
 TheGame^.InfoSet^.ForEach(@CheckAllActive);
 if CheckActive
 then begin
  IsNewSignature:=True;
  SignatureList.ForEach(@CheckSignature);
  if IsNewSignature
  then begin
   MakeFacet:=True;
   NewSignature:=New(PSignature,Init(Signature));
   SignatureList.Insert(NewSignature);
  end;
 end;
 MakeRandomFacet:=MakeFacet;
end;

procedure TSolveDlg.SampleBoundary;
begin
 Turn:=0;
 repeat
  Turn:=Turn+1;
  if MakeRandomFacet
  then if MixedSolve
       then if IsOptimalSet(nil)
            then SaveEquilibrium;
  PostProgress(MaxTurn);
 until (Turn>=MaxTurn) or IsAborted;
end;

function TSolveDlg.MixedSolve:Boolean;
var Iteration:Byte;IsSmallNorm,IsInitial,MustStop,HasTested:Boolean;LogInitialNorm:Real;
 procedure InitProfile;
  procedure SetZeroProfile(AChoice:PChoice);far;
  begin
   AChoice^.SetProfileValue(0);
  end;
 begin
  TheGame^.ChoiceSet^.ForEach(@SetZeroProfile);
  {MakeVector(1);}
 end;
 procedure MakeLogInitialNorm;
 begin
  LogInitialNorm:=Logarithm(NewNorm)+TooSlow;
  IsInitial:=False;
 end;
 procedure CheckStop;
 begin
   ReleaseMessage;
   if IsAborted then MustStop:=True;
   if (Step<MinStep) then MustStop:=True;
   if (Logarithm(NewNorm)>LogInitialNorm-Iteration) then MustStop:=True;
   if (NewNorm<NormThreshold) then MustStop:=True;
   if (Iteration>MaxIteration) then MustStop:=True;
 end;
begin  {MixedSolve}
 MustStop:=False;
 HasTested:=False;
 if (TheGameMode^.SolveConcept<>sm_Sequential)
 then begin
  InitProfile;
  ResetBounds(True);       {Sets the BoundChoice of each info arbitrarily}
  ResetCoordinates(True);  {Assume initial profile. Compute Dim}
 end;
 if Dim=0 then MixedSolve:=PureSolve
 else begin
  Iteration:=0;
  IsInitial:=True;
  Step:=InitStep;
  OldNorm:=TopDefault;
  NewNorm:=TopDefault;
  with TheDerivator^ do repeat              {Iterate from new probas}
   {MakeNewton(Step,NewNorm);
   {MakeVectorLog(1,Dim,Profile);}
   Iteration:=Iteration+1;
   if NewNorm<MidwayDefault
   then IsSmallNorm:=True                   {Triggers belief iteration}
   else IsSmallNorm:=False;
   ProfileToProba;                          {Get probas from profile, bounds, and coordinates}
   if MakeExpectation(IsSmallNorm,nil)      {Use IR & T to make expectations and beliefs}
   then begin
    MakeIncentive(nil);         {Use expectations and beliefs to make choice incentives}
    ResetBounds(False);         {Identify new choice bounds}
    ResetCoordinates(False);    {Reset coordinates since bounds may have changed}
    ConvertProfile;             {NEW: Convert directly from Choice parameters}
    MakeDeviation;              {Vector of xi times fi minus fi-bound}
    {MakeVectorLog(2,Dim,Deviation);}
    NewNorm:=Norm;                          {Square norm of deviation vector}
    if IsInitial then MakeLogInitialNorm;
    if NewNorm>=NormThreshold
    then begin         {Convergence not yet achieved}
     {Need test for early convergence off equilibrium or near existing one}
     if (TheGameMode^.SolveConcept in [sm_Perfect,sm_Sequential])
     and (not HasTested)
     and (NewNorm<CutoffThreshold)
     then begin
      HasTested:=True;
      if not IsPerfectSet(False)
      then begin
       MustStop:=True;
       {CutOffNumb:=CutOffNumb+1;}
      end;
     end;
     Step:=MakeStep;
     begin                                       {Continue iteration}
      OldNorm:=NewNorm;
      MakeJacobian;             {Construct Jacobian}
      if not MakeDirection      {If Jacobian is not singular make direction}
      then MustStop:=True       {Jacobian is singular: STOP}
      else if not MakeProfile   {Make next profile using direction unless it is too large}
           then begin
            MustStop:=True;     {Profile is too large: STOP}
            {HitBoundNumb:=HitBoundNumb+1; }
           end;
     end;
    end else begin
              MustStop:=True; {Convergence is achieved}
              {ConvergNumb:=ConvergNumb+1;}
             end;
    {if ShowDetails then PostProgress(0,Iteration,Step,NewNorm); }
   end else MustStop:=True;    {Expectations do not exist: STOP}
   if not MustStop then CheckStop;
  until MustStop;
  {if ShowDetails then PostProgress(0,GlobalIter,Step,NewNorm);}
  if NewNorm<=NormThreshold then MixedSolve:=True else MixedSolve:=False;
 end;
 {PostProgress(-11); }
end;  {MixedSolve}

procedure TSolveDlg.Abort(var Msg:TMessage);
begin
 IsAborted:=True;
end;

procedure TSolveDlg.Evolve;
var Percent:LongInt; I,Generate: Byte; NewWeight,RowAv,ColAv:Real; RowPlayer:PPlayer;
 procedure ResetPlayLog(AnEvolver:PEvolver);far;
 begin
  if AnEvolver<>nil
  then AnEvolver^.PlayLog.FreeAll;
 end;
 procedure ResetScore(AnEvolver:PEvolver);far;
 begin
  if AnEvolver<>nil then
  with AnEvolver^ do begin
   SetScore(True,0);
   SetScore(False,0);
   SetPerform(0);
  end;
 end;
 procedure MakeSimulation(APair:PPair);far;
 begin
  if APair=nil then Exit;
  APair^.Simulate(Horizon);
  PostProgress(Percent);
 end;
 procedure MakeAverage(AnEvolver:PEvolver);far;
 begin
  if AnEvolver<>nil then
  with AnEvolver^ do
   if IsForRow
   then RowAv:=RowAv+SafeMultiply(Weight,OwnScore)
   else ColAv:=ColAv+SafeMultiply(Weight,OwnScore);
 end;
 procedure MakePerform(AnEvolver:PEvolver);far;
 begin
  if AnEvolver<>nil then
  with AnEvolver^ do
   if IsForRow
   then SetPerform(OwnScore-RowAv)
   else SetPerform(OwnScore-ColAv);
 end;
 procedure MakeRecord(AnEvolver:PEvolver);far;
 var APlayRec:PPlayRec;
 begin
  if AnEvolver<>nil then
  with AnEvolver^ do begin
   APlayRec:=New(PPlayRec,Init);
   APlayRec^.SetRec(1,OwnScore);
   APlayRec^.SetRec(3,Weight);
   PlayLog.Insert(APlayRec);
  end;
 end;
 procedure MakeNewWeight(AnEvolver:PEvolver);far;
 begin
  if AnEvolver<>nil then
  with AnEvolver^ do begin
   if TheGame^.IsSymmetric
   then NewWeight:=SafeMultiply(Weight+Twin^.Weight,(1+SafeMultiply(Step,Perform+Twin^.Perform)))
   else NewWeight:=SafeMultiply(Weight,(1+SafeMultiply(Step,Perform)));
   if NewWeight<=0 then NewWeight:=0;
   SetWeight(NewWeight);
  end;
 end;
 procedure TotalWeight(AnEvolver:PEvolver);far;
 begin
  if AnEvolver<>nil
  then with AnEvolver^ do begin
   if Owner=RowPlayer
   then RowAv:=RowAv+Weight
   else ColAv:=ColAv+Weight;
  end;
 end;
 procedure AdjustWeight(AnEvolver:PEvolver);far;
 begin
  if AnEvolver<>nil then
  with AnEvolver^ do
  if Owner=RowPlayer
  then SetWeight(SafeMultiply(Weight,1/RowAv))
  else SetWeight(SafeMultiply(Weight,1/ColAv));
 end;
begin
 Step:=0.01;
 with TheGame^ do begin
  RowPlayer:=PlayerSet^.At(0);
  if (TheGameMode^.SolveMatchup=sm_Replicate)
  then Generate:=Generation
  else Generate:=1;
  if PairSet^.Count>0
  then Percent:=Generate*PairSet^.Count;   {Change if several generations}
  EvolverSet^.ForEach(@ResetPlayLog);  {Cleanup the PlayLog}
  EvolverSet^.ForEach(@ResetScore);  {Own and Opp scores set to zero}
  EvolverSet^.ForEach(@MakeRecord);  {This creates the record}

  for I:=1 to Generate do begin

   EvolverSet^.ForEach(@ResetScore);  {Own and Opp scores set to zero}
   PairSet^.ForEach(@MakeSimulation); {All pairs play and add weighted scores}
   if (TheGameMode^.SolveMatchup=sm_Replicate)
   then begin
    RowAv:=0;ColAv:=0;
    EvolverSet^.ForEach(@MakeAverage); {Make average of each population}
    EvolverSet^.ForEach(@MakePerform); {Make Performance of each}
    EvolverSet^.ForEach(@MakeNewWeight);
    RowAv:=0.0;ColAv:=0;
    EvolverSet^.ForEach(@TotalWeight);
    EvolverSet^.ForEach(@AdjustWeight);
    EvolverSet^.ForEach(@MakeRecord);  {This creates the record}
   end;
  end;
 end;
end;

function TSolveDlg.Execute:Integer;
 procedure MakeInfoActivity(AnInfo:PInfo);far;
 {Initializes all infos as inactive except chance ones}
 begin
  if AnInfo^.Owner=nil
  then StartFromActivity[AnInfo^.Rank]:=True
  else StartFromActivity[AnInfo^.Rank]:=False;
  StartUptoActivity[AnInfo^.Rank]:=False;
 end;
 procedure MakeChoiceActivity(AChoice:PChoice);far;
 {Initializes all choices as inactive except chance ones}
  procedure MakeUptoActivity(AMove:PMove);far;
  begin
   if AMove^.Upto<>nil
   then StartUptoActivity[AMove^.Upto^.Family^.Rank]:=True;
  end;
 begin
  if AChoice^.Source^.Owner<>nil     {It's NOT a CHANCE move}
  then StartChoiceActivity[AChoice^.Rank]:=False
  else begin
   AChoice^.SetProba(1.0);
   StartChoiceActivity[AChoice^.Rank]:=True;
   AChoice^.Instance.ForEach(@MakeUptoActivity);
  end;
 end;
 procedure InitFullActivity; {Used for sequential}
  procedure MakeStartFrom(AnInfo:PInfo);far;
  begin
   if not AnInfo^.IsBayes                       {Experiment}
   then StartFromActivity[AnInfo^.Rank]:=True;
  end;
  procedure MakeStartChoice(AChoice:PChoice);far;
  begin
   if not AChoice^.IsBayes                       {Experiment}
   then StartChoiceActivity[AChoice^.Rank]:=True;
   AChoice^.SetProfileValue(0);
  end;
 begin {InitFullActivity}
  TheGame^.InfoSet^.ForEach(@MakeStartFrom);
  TheGame^.ChoiceSet^.ForEach(@MakeStartChoice);
  RecordActivity(StartFromActivity,StartChoiceActivity);
  ResetBounds(True);
  ResetCoordinates(True);
 end;  {InitFullActivity}
 procedure InitComplexity;
 begin
  if Dim<=MaxComp
  then Complexity:=Round(Exponential(Dim*Logarithm(3)))
  else Complexity:=Round(Exponential(MaxComp*Logarithm(3)));
  if Complexity>MaxTurn
  then Complexity:=MaxTurn;
 end;
begin
 PostProgress(-1);
 PercentDone:=0;
 SolutionType:=SolutionMode(TheGameMode^.SolveMethod,TheGameMode^.SolveConcept);
 TheGameMode^.ShowMode(HWindow);
if TheGame^.IsEvolutionary             {New branch}
then Evolve
else begin
 TheGame^.SelectSolution(SolutionType);
 IsTooFat:=False;
 IsTooLarge:=False;
 IsAborted:=False;
 IsSuspended:=False;
 StartInfo:=MakeStartInfo;
 TheGame^.InfoSet^.ForEach(@MakeInfoActivity);          {Chance nodes and moves are made active}
 TheGame^.ChoiceSet^.ForEach(@MakeChoiceActivity);
 RecordActivity(StartFromActivity,StartChoiceActivity);
 if (TheGameMode^.SolveConcept=sm_Nash)  {Nash concept}
 then IsAborted:=not MakeStrategies;  {Abort if too many strategies}
 {GlobalIter:=0;}
 SolutionNumber:=0;
 if (TheGameMode^.SolveMethod=sm_Sample){IsSampling} then SignatureList.FreeAll;
 if {IsSequential} (TheGameMode^.SolveConcept=sm_Sequential)
 then begin
  InitFullActivity;
  if (TheGameMode^.SolveMethod=sm_Sample) {IsSampling }
  then begin
   SampleInterior;
  end else begin
   InitComplexity;
   Explore(1);
  end;
 end;
 if (TheGameMode^.SolveMethod=sm_Sample){IsSampling}
 and (TheGameMode^.SolveConcept<>sm_Sequential) {not IsSequential          {SampleBoundary Nash or perfect}
 then SampleBoundary;
 if IsTooFat
 then begin
   LoadString(HInstance,88,ErrorString,LongSize);
   WhatIsWrong(HWindow,ErrorString);
 end;
 if (TheGameMode^.SolveMethod<>sm_Sample){(not IsSampling)}
 and (TheGameMode^.SolveConcept<>sm_Sequential) {(not IsSequential)  {Search with Nash or Perfect}
 then begin                                  {4 cases}
  if (StartInfo<>nil)
  then Search(StartFromActivity,StartUptoActivity,
              StartChoiceActivity,StartInfo,1,False,0);
  if IsTooLarge
  then begin
   LoadString(HInstance,39,ErrorString,LongSize);
   WhatIsWrong(HWindow,ErrorString);
  end;
 end;
end; {NewBranch}
 {PostProgress(-10);}
end;

procedure TSolveDlg.ActivityToPureProba;   {Used in PureSolve and Estimate}
 procedure TranslateChoiceActivity(AChoice:PChoice);far;
 begin
  if AChoice^.IsActive then AChoice^.SetProba(1.0)
                         else AChoice^.SetProba({Trembling}0);
 end;
begin
 TheGame^.ChoiceSet^.ForEach(@TranslateChoiceActivity);
end;

function TSolveDlg.PureSolve:Boolean;
begin
 {MakeWarning(0,nil);}
 ActivityToPureProba;
 with TheExpectator^ do begin
  if MakeExpectation(False,nil)
  then begin
   MakeIncentive(nil);
   PureSolve:=True;
  end else PureSolve:=False;
 end;
end;

function TSolveDlg.Estimate:Boolean;
begin
 Estimate:=FALSE;
 ActivityToPureProba;                                    {NEED TO PRINT}
 with TheExpectator^ do begin
  if MakeExpectation(False,EstimatedPlayer)
  then with EstimatedChoice^ do begin
   MakeIncentive(EstimatedChoice);
   {Now update min and max}
    if Incentive>ShowMax then SetMax(Incentive);
    if Incentive<ShowMin then SetMin(Incentive);
  end else with EstimatedChoice^ do begin
    SetMax(TopDefault);
    SetMin(-TopDefault);
  end;
 end;
end;

procedure TSolveDlg.Investigate(WhatInfo:PInfo);
var MaxMin:Real;
 procedure InvestigateChoice(AChoice:PChoice);far;
  procedure ResetFreedom(BChoice:PChoice);far;
  begin
   BChoice^.SetFreedom(FALSE);
  end;
 begin
  if IsAborted then Exit;
  EstimatedChoice:=AChoice;
  WhatInfo^.ChoiceList.ForEach(@ResetFreedom);
  EstimatedChoice^.SetFreedom(TRUE);
  Search(StartFromActivity,StartUptoActivity,StartChoiceActivity,WhatInfo,0,True,0);
 end;
 procedure SetDefaultEstimate(AChoice:PChoice);far;
 begin
  AChoice^.SetMax(-TopDefault);
  AChoice^.SetMin(TopDefault);
 end;
 procedure UpdateMaxMin(AChoice:PChoice);far;
 begin
  with AChoice^ do if ShowMin>=MaxMin then MaxMin:=ShowMin;
 end;
 procedure EliminateChoice(AChoice:PChoice);far;
 begin
  with AChoice^ do begin
   if (ShowMax<=MaxMin-Tolerance)
   then SetFreedom(False)
   else SetFreedom(True);
  end;
 end;
begin
 {For test, first set all free}
 {PostProgress(-4);}
 if WhatInfo^.IsBayes then Exit;     {Experiment.. This is where dominated choices are off}
 if IsEliminating then
 with WhatInfo^ do begin
  EstimatedPlayer:=Owner;
  ChoiceList.ForEach(@SetDefaultEstimate);
  ChoiceList.ForEach(@InvestigateChoice);
  if IsAborted then Exit;
  {Finally, eliminate dominated choices}
  MaxMin:=-TopDefault;
  ChoiceList.ForEach(@UpdateMaxMin);
  ChoiceList.ForEach(@EliminateChoice);
 end;
 {PostProgress(-5); }
end;

procedure TSolveDlg.ProfileToProba;
{Translates Profile into magnitudes and probabilities for each move}
{given existing definition of bounds}
 procedure TranslateProfileValues(AnInfo:PInfo);far;
 var Denom:Real;
  procedure ResetPreProba(AChoice:PChoice);far;
  begin
   AChoice^.SetPreProba;        {Takes exponential of profile value. Defined in Choice type}
  end;
  procedure AddToDenom(AChoice:PChoice);far;
  begin
   if (AChoice<>AnInfo^.Bound)
   and AChoice^.IsActive
   then Denom:=Denom+AChoice^.PreProba;
  end;
  procedure ResetProba(AChoice:PChoice);far;
  begin
   if not AChoice^.IsActive
   then AChoice^.SetProba(0)
   else if AChoice=AnInfo^.Bound
        then AChoice^.SetProba(Denom)
        else AChoice^.SetProba(SafeMultiply(Denom,AChoice^.PreProba));
  end;
 begin   {Translate}
  with AnInfo^ do
  if IsActive
  and (Owner<>nil)
  and (Bound<>nil)
  then begin
   Denom:=1.0;
   ChoiceList.ForEach(@ResetPreProba);
   ChoiceList.ForEach(@AddToDenom);
   Denom:=1.0/Denom;
   ChoiceList.ForEach(@ResetProba);
  end;
 end;  {Translate}
begin
 TheGame^.InfoSet^.ForEach(@TranslateProfileValues);
end;

procedure TSolveDlg.RecordActivity(var AnInfoActivity:InfoActivity;
                                   AChoiceActivity:ChoiceActivity);
 procedure RecordChoiceActivity(AChoice:PChoice);far;
 begin
  with AChoice^
  do if AChoiceActivity[Rank]
     then SetActive(True)
     else SetActive(False);
 end;
 procedure RecordInfoActivity(AnInfo:PInfo);far;
 begin
  with AnInfo^
  do if AnInfoActivity[Rank]
     then SetActive(True)
     else SetActive(False);
 end;
begin
 with TheGame^
 do begin
  ChoiceSet^.ForEach(@RecordChoiceActivity);
  InfoSet^.ForEach(@RecordInfoActivity);
 end;
end;

procedure TSolveDlg.CheckDepth(ADepth:Byte);
begin
 if (ADepth<=MaxDepth) then Exit;
 IsAborted:=True;
 IsTooLarge:=True;
end;

procedure TSolveDlg.Search(FromActivity,UptoActivity:InfoActivity;
                           ActiveMoveSet:ChoiceActivity;
                           FromInfo:PInfo;LocalProgress:LongInt;
                           IsEstimating:Boolean;Depth:Byte);
var
 Degree,
 Index                  : Byte;
 NextFromInfo           : PInfo;
 NextActiveMoveSet      : ChoiceActivity;
 NextFromActivity,
 NextUptoActivity       : InfoActivity;
 TheEnumerator          : Enumerator;
 Outlet                 : OutletType;
 TheSubset              : OrderedSet;
 function IsClosedGraph:Boolean;  {Check if closed or return NextFromInfo}
  procedure FreeInfo;             {Reaching FreeInfo is only way to have IsClosedGraph true}
   function FindFreeInfo(AnInfo:PInfo):Boolean;far;
   begin
    if NextFromActivity[AnInfo^.Rank]
    then FindFreeInfo:=False
    else begin
     NextFromInfo:=AnInfo;
     FindFreeInfo:=True;
    end;
   end;
  begin
   IsClosedGraph:=True;
   NextFromInfo:=nil;
   TheGame^.StartInfoColl^.FirstThat(@FindFreeInfo);
   if NextFromInfo=nil
   then TheGame^.InfoSet^.FirstThat(@FindFreeInfo);
  end;
  procedure FindNextInfo(AnInfo:PInfo);far;
  begin
   if NextUptoActivity[AnInfo^.Rank]
   and not NextFromActivity[AnInfo^.Rank]
   then NextFromInfo:=AnInfo;      {choose ONE upto info that is not a from}
  end;
  procedure CheckAncestors;
   procedure CheckIfActive(AnInfo:PInfo);far;
   begin
    if not NextFromActivity[AnInfo^.Rank]
    then NextFromInfo:=AnInfo;
   end;
  begin {CheckAncestors}
   if FromInfo^.Ancestors.Count>1
   then FromInfo^.Ancestors.ForEach(@CheckIfActive);
   if NextFromInfo<>nil
   then IsClosedGraph:=False
   else FreeInfo;
  end;  {CheckAncestors}
 begin  {IsClosedGraph}
  if not NextFromActivity[StartInfo^.Rank]
  then begin
   NextFromInfo:=StartInfo;
   IsClosedGraph:=False;
  end else begin
   NextFromInfo:=nil;
   TheGame^.InfoSet^.ForEach(@FindNextInfo);
   if NextFromInfo<>nil
   then IsClosedGraph:=False
   else if TheGame^.HasBayesianInfo
        then CheckAncestors
        else FreeInfo;
  end;
 end;   {IsClosedGraph}
 procedure UpdateChoiceActivity(AChoice:PChoice);far;
  procedure UpdateUptoActivity(AMove:PMove); far;
  begin
   if AMove^.Upto<>nil
   then NextUptoActivity[AMove^.Upto^.Family^.Rank]:=True;
  end;
 begin
   NextActiveMoveSet[AChoice^.Rank]:=True;
   AChoice^.Instance.ForEach(@UpdateUptoActivity);
 end;
 procedure MakeFreedom;
  procedure CheckChoiceFreedom(AChoice:PChoice);far;
  begin
   with AChoice^ do if ActiveMoveSet[Rank]
   then SetFreedom(True) else SetFreedom(False);
  end;
  procedure CheckInfoFreedom(AnInfo:PInfo);far;
   procedure SetFree(AChoice:PChoice);far;
   begin
    AChoice^.SetFreedom(True);
   end;
  begin
   with AnInfo^ do
   if not FromActivity[Rank] then ChoiceList.ForEach(@SetFree);
  end;
 begin {MakeFreedom}
  TheGame^.ChoiceSet^.ForEach(@CheckChoiceFreedom);
  TheGame^.InfoSet^.ForEach(@CheckInfoFreedom);
 end;  {MakeFreedom}
 procedure MakeOutlet;
  procedure AddOutlet(AChoice:PChoice);far;
  begin
   if AChoice^.IsFree
   or (Depth=0)
   then begin
    Degree:=Degree+1;
    Outlet[Degree]:=AChoice;
   end;
  end;
 begin {MakeOutlet}
  Degree:=0;
  if not IsEstimating
  then begin
   MakeFreedom; {of active choices and inactive info outlets}
   if (FromInfo^.Owner<>nil)
   then Investigate(FromInfo);
  end;
  FromInfo^.ChoiceList.ForEach(@AddOutlet);
 end; {MakeOutlet}
 function CurrentProgress:LongInt;
 begin
   if TheGameMode^.SolveMethod=sm_Pure
   then CurrentProgress:=Degree*LocalProgress
   else CurrentProgress:=SubsetCount(Degree)*LocalProgress;
 end;
 procedure MakeNextSearch;
 var SearchFurther          : Boolean;
 begin {MakeNextSearch}
   if IsClosedGraph
   then begin   {to check optimality}
    RecordActivity(NextFromActivity,NextActiveMoveSet);
    if IsEstimating
    then SearchFurther:=Estimate   {Always false}
    else if TheGameMode^.SolveMethod=sm_Pure
         then SearchFurther:=PureSolve
         else SearchFurther:=MixedSolve;
    if SearchFurther then SearchFurther:=IsOptimalSet(NextFromInfo);
   end else SearchFurther:=True           {because graph is not closed};
   {If graph was not closed or if it was closed and choices were optimal, then go on searching}
   if SearchFurther
   then if (NextFromInfo=nil)
        then SaveEquilibrium      {Info activity was full and choices were optimal}
        else Search(NextFromActivity,NextUptoActivity, {Search graph further}
                    NextActiveMoveSet,NextFromInfo,
                    CurrentProgress,{IsNowOff,}IsEstimating,Depth+1)
   else if IsEstimating
        then ReleaseMessage
        else PostProgress(CurrentProgress); {and leave current branch}
 end; {MakeNextSearch}
begin  {Search}
 CheckDepth(Depth);
 if IsAborted then Exit;
 NextFromActivity:=FromActivity;          {Record from activities}
 NextFromActivity[FromInfo^.Rank]:=True;
 MakeOutlet;
 TheEnumerator.Init((TheGameMode^.SolveMethod=sm_Pure){IsPureCase} or IsEstimating or TheGame^.IsPerfectInfo,Degree,TheSubset);
 repeat
   NextActiveMoveSet:=ActiveMoveSet;      {Recall original move set}
   NextUptoActivity:=UptoActivity;        {Recall original upto activity}
   for Index:=1 to TheSubset[0]
   do UpdateChoiceActivity(Outlet[TheSubset[Index]]);
   MakeNextSearch;
 until TheEnumerator.Done(TheSubset);
end; {Search}

procedure TSolveDlg.ReleaseMessage;
var Msg:TMsg;
begin
 while PeekMessage(Msg,0,0,0,pm_Remove) do
 if not IsDialogMessage(HWindow,Msg)
 then begin
  TranslateMessage(Msg);
  DispatchMessage(Msg);
 end;
end;

procedure TSolveDlg.PostProgress(AProgress:LongInt);
var Percentage,Remainder:Integer;
    PercentString:NameType;AString:LongName;
begin
 if AProgress=-1
 then begin
  SetWindowText(HWindow,' Solving ');
  SetDlgItemText(HWindow,2,'Abort');
  SetDlgItemText(HWindow,100,'% done');
  SetDlgItemText(HWindow,101,'0.00');
  SetDlgItemText(HWindow,102,'0');
  SetDlgItemText(HWindow,103,'Solution(s) found');
 end;
 if AProgress>0
 then begin
  PercentDone:=PercentDone+1/AProgress;
  Percentage:=Trunc(100*PercentDone);
  {MakePercent(Percentage); }
  Remainder:=Trunc(10000*(PercentDone-0.01*Percentage));
  Str(Percentage,PercentString);
  StrCat(PercentString,'.');
  Str(Remainder,InfoString);
  if Remainder<10
  then StrCat(PercentString,'0');
  StrCat(PercentString,InfoString);
  SetDlgItemText(HWindow,101,PercentString);
 end;
 if AProgress=-2
 then begin
  Str(SolutionNumber,InfoString);
  SetDlgItemText(HWindow,102,InfoString);
 end;
 {if AProgress=-4
 then SetWindowText(HWindow,'Eliminating');
 if AProgress=-5
 then SetWindowText(HWindow,' Solving ');}
 ReleaseMessage;
 {if AProgress<=-10
 then begin
  Str(MinStepNumb,AString);
  SetDlgItemText(HWindow,120,AString);
  Str(IterationNumb,AString);
  SetDlgItemText(HWindow,121,AString);
  Str(ConvergNumb,AString);
  SetDlgItemText(HWindow,122,AString);
  Str(CutOffNumb,AString);
  SetDlgItemText(HWindow,123,AString);
  Str(SlowIterNumb,AString);
  SetDlgItemText(HWindow,124,AString);
  Str(HitBoundNumb,AString);
  SetDlgItemText(HWindow,125,AString);
  if AProgress<-10 then Exit;
  IsSuspended:=True;
  repeat
   ReleaseMessage;
  until IsAborted or not IsSuspended;
 end;}
 {if AProgress=0
 then begin
  Str(ASignature,AString);
  SetDlgItemText(HWindow,120,AString);
  repeat
   ProcessLog;
   ReleaseMessage;
  until IsAborted or not IsSuspended;
 end;
  {StrCopy(AString,StringReal(AStep,7));
  SetDlgItemText(HWindow,121,AString);
  StrCopy(AString,StringReal(ANorm,7));
  SetDlgItemText(HWindow,122,AString);
 {end;
 {if AProgress=-3
 then begin
  WhatIsWrong(HWindow,'Check');
 end; }
end;

procedure TSolveDlg.ProcessLog;
begin
 {if not DebugIsOff then} IsSuspended:=True;
end;

procedure TSolveDlg.Resume(var Msg:TMessage);
begin
 {PurgeLog; }
 IsSuspended:=False;
end;

function TSolveDlg.IsOptimalSet(NextInfo:PInfo):Boolean;
begin
 if (TheGameMode^.SolveConcept in [sm_Perfect,sm_Sequential])
 or (NextInfo<>nil)
 then IsOptimalSet:=IsPerfectSet(True)
 else IsOptimalSet:=IsNashSet;
end;

function TSolveDlg.IsNashSet:Boolean;
var IsOptimal:Boolean; ARow:PVector;
 procedure SetActiveInfo(AnInfo:PInfo);far;
 begin
  AnInfo^.SetActive(True);
 end;
 procedure SetActiveChoice(AChoice:PChoice);far;
 begin
  AChoice^.SetActive(True);
 end;
 procedure StoreProba(AChoice:PChoice);far;
 begin
  AChoice^.SetOldProba(AChoice^.Probability);
 end;
 procedure FillExpectation(APlayer:PPlayer);far;
 begin
  ARow:=Expectation^[APlayer^.Rank];
  TheGame^.StartNode^.SetValue(APlayer^.Rank,ARow^[TheGame^.StartNode^.Rank]);
 end;
 procedure CheckStrategy(AStrategy:PStrategy);far;
  procedure RestoreProba(AChoice:PChoice);far;
  begin
   AChoice^.SetProba(AChoice^.OldProba);
  end;
  procedure AdjustProba(AChoice:PChoice);far;
   procedure SetZero(BChoice:PChoice);far;
   begin
    BChoice^.SetProba(0.0);
   end;
  begin
   AChoice^.Source^.ChoiceList.ForEach(@SetZero);
   AChoice^.SetProba(1.0);
  end;
 begin {CheckStrategy}
  if not IsOptimal then Exit;
  TheGame^.ChoiceSet^.ForEach(@RestoreProba);
  AStrategy^.ShowDecisions^.ForEach(@AdjustProba);
  {Now construct expectations}
  TheExpectator^.MakeExpectation(False,AStrategy^.Owner);
  ARow:=Expectation^[AStrategy^.Owner^.Rank];
  if (ARow^[TheGame^.StartNode^.Rank]>
     TheGame^.StartNode^.ShowValue(AStrategy^.Owner^.Rank)+Tolerance)
  then IsOptimal:=False;
 end;  {CheckStrategy}
 procedure RecordProba(AChoice:PChoice);far;
 begin
  AChoice^.SetProba(AChoice^.OldProba);
 end;
begin
 IsOptimal:=True;
 TheGame^.InfoSet^.ForEach(@SetActiveInfo);      {for MakeFilter in MakeIRT}
 TheGame^.ChoiceSet^.ForEach(@SetActiveChoice);
 TheGame^.ChoiceSet^.ForEach(@StoreProba);       {To recover if True}
 {MakeWarning(100,nil);}
 TheGame^.PlayerSet^.ForEach(@FillExpectation);  {Store calculated expectations}
 {MakeStartExp(0,0); }
 TheGame^.StrategySet^.ForEach(@CheckStrategy);
 if IsOptimal
 then begin
  TheGame^.ChoiceSet^.ForEach(@RecordProba);
  TheExpectator^.MakeExpectation(False,nil);   {They have been poluted}
 end;
 IsNashSet:=IsOptimal;
end;

function TSolveDlg.IsPerfectSet(IsHighTest:Boolean):Boolean;
var IsOptimal:Boolean;BestValue,TestValue:Real;
 procedure CheckInfoOptimality(AnInfo:PInfo);far;
  procedure CheckOptimalChoice(AChoice:PChoice);far;
  begin
   with AChoice^
   do begin
    TestValue:=SafeMultiply(Probability,(BestValue-Incentive));
    if not IsHighTest
    and (TestValue>LowThreshold)
    then IsOptimal:=False;
    if IsHighTest
    and (TestValue>HighThreshold)
    then IsOptimal:=False;
   end;
  end;
  procedure FindBestValue(AChoice:PChoice);far;
  begin
   with AChoice^ do
   if (Incentive>BestValue)
   then BestValue:=Incentive;
  end;
 begin  {CheckInfoOptimality}
  if not IsOptimal
  or (AnInfo^.IsBayes)    {Experiment}    {Problem with saving solutions..}
  or (not AnInfo^.IsActive) {non active info}
  or (AnInfo^.Owner=nil)  {Chance info}
  then Exit;
  BestValue:=-TopDefault;
  AnInfo^.ChoiceList.ForEach(@FindBestValue);
  AnInfo^.ChoiceList.ForEach(@CheckOptimalChoice);
 end;
begin {IsPerfectSet}
 IsOptimal:=True;
 TheGame^.InfoSet^.ForEach(@CheckInfoOptimality);
 IsPerfectSet:=IsOptimal;
end;  {IsPerfectSet}

function TSolveDlg.HasNoSameSolution:Boolean;
var IsDifferent:Boolean;EquilChoice:PChoice;EquilNode:PNodeS;
  procedure SetActiveProbas(AChoice:PChoice);far;
  begin
   with AChoice^ do
   if IsBayes then SetActive(False)       {Experiment}
   else if Probability>LowTolerance
        then SetActive(True)
        else SetActive(False);
  end;
  procedure SetActiveBeliefs(ANode:PNode);far;
  begin
   with ANode^ do
   if IsBayes then SetActive(False)       {Experiment}
   else if NormBelief>LowTolerance
        then SetActive(True)
        else SetActive(False);
  end;
 procedure CompareSolution(AnEquilibrium:PEquilibrium);far;
  procedure CompareProbas(AChoice:PChoice);far;
  begin {CompareProbas}
   if AChoice^.IsBayes then Exit;       {Experiment}
   EquilChoice:=AnEquilibrium^.ChoiceSolSet^.At(TheGame^.ChoiceSet^.IndexOf(AChoice));
   if ((EquilChoice^.Probability>Tolerance) and (AChoice^.Probability<LowTolerance))
   or ((EquilChoice^.Probability<LowTolerance) and (AChoice^.Probability>Tolerance))
   then IsDifferent:=True;
  end;  {CompareProbas}
  procedure CompareBeliefs(ANode:PNode);far;
  begin {CompareBeliefs}
   if ANode^.IsBayes then Exit;        {Experiment}
   EquilNode:=AnEquilibrium^.NodeSolSet^.At(TheGame^.NodeSet^.IndexOf(ANode));
   if ((EquilNode^.NormBelief>Tolerance) and (ANode^.NormBelief<LowTolerance))
   or ((EquilNode^.NormBelief<LowTolerance) and (ANode^.NormBelief>Tolerance))
   then IsDifferent:=True;
  end; {CompareBeliefs}
 begin
  IsDifferent:=False;
  TheGame^.ChoiceSet^.ForEach(@CompareProbas);
  TheGame^.NodeSet^.ForEach(@CompareBeliefs);
  if not IsDifferent then HasNoSameSolution:=False;
 end;
begin
 HasNoSameSolution:=True;
 with TheGame^ do begin
  {ChoiceSet^.ForEach(@SetActiveProbas);
  NodeSet^.ForEach(@SetActiveBeliefs); }
  if CrntEquilSet<>nil
  then CrntEquilSet^.ForEach(@CompareSolution);
 end;
end;

function TSolveDlg.IsNewSolution:Boolean;
var IsNew,SameProbas,SameBeliefs:Boolean;EquilChoice:PChoice;EquilNode:PNodeS;
 procedure CompareSolution(AnEquilibrium:PEquilibrium);far;
  procedure CompareProbas(AChoice:PChoice);far;
  begin {CompareProbas}
   if AChoice^.IsBayes then Exit;       {Experiment}
   EquilChoice:=AnEquilibrium^.ChoiceSolSet^.At(TheGame^.ChoiceSet^.IndexOf(AChoice));
   if ABS(AChoice^.Probability-EquilChoice^.Probability)>Tolerance
   then SameProbas:=False;
  end;  {CompareProbas}
  procedure CompareBeliefs(ANode:PNode);far;
  begin
   if ANode^.IsBayes then Exit;        {Experiment}
   EquilNode:=AnEquilibrium^.NodeSolSet^.At(TheGame^.NodeSet^.IndexOf(ANode));
   if ABS(ANode^.NormBelief-EquilNode^.NormBelief)>Tolerance
   then SameBeliefs:=False;
  end;
 begin {CompareSolution}
  SameProbas:=True;
  SameBeliefs:=True;
  TheGame^.ChoiceSet^.ForEach(@CompareProbas);
  TheGame^.NodeSet^.ForEach(@CompareBeliefs);
  if SameProbas and SameBeliefs then IsNew:=False;
 end;  {CompareSolution}
begin {IsNewSolution}
 IsNew:=True;
 with TheGame^ do
 if CrntEquilSet<>nil
 then CrntEquilSet^.ForEach(@CompareSolution);
 {if not IsNew then PostProgress(-2,0,0,0); }
 IsNewSolution:=IsNew;
end;

procedure TSolveDlg.SaveEquilibrium;
var
 ANodeSol       : PNode2;
 AChoiceSol     : PChoice2;
 AStratSol      : PStrategyS;
 AnEquilibrium  : PEquilibrium;
 ARow           : PVector;
 SName,
 BName,
 AName          : NameType;
 procedure FillExpectation(ANode:PNode); far;
  procedure FillPlayer(APlayer:PPlayer); far;
  begin {FillPlayer}
   ARow:=Expectation^[APlayer^.Rank];
   ANodeSol^.SetValue(APlayer^.Rank,ARow^[ANode^.Rank]);
  end; {FillPlayer}
 begin {FillExpectation}
  ANodeSol:=New(PNode2,Init(TheGame,SolutionType));
  with ANodeSol^ do begin
   SetLocus(ANode^.ShowLocus^);
   SetBayes(ANode^.IsBayes);   {Experiment}
   SetRank(SolutionNumber);
   StrCopy(AName,ANode^.ShowName);
   SetName(AName);
   SetOwner(ANode^.Owner);        {Initialize NodeSol as Node}
   SetOwnerRank(ANode^.OwnerRank);
   SetFamily(ANode^.Family);
   TheGame^.PlayerSet^.ForEach(@FillPlayer);
   SetBelief(ANode^.Belief);
   SetNormBelief(ANode^.NormBelief);
  end;
  AnEquilibrium^.NodeSolSet^.Insert(ANodeSol);
 end; {FillExpectation}
 procedure FillChoice(AChoice:PChoice); far;
 begin
  AChoiceSol:=New(PChoice2,Init(TheGame,SolutionType));
  with AChoiceSol^ do begin
   SetRank(SolutionNumber);
   with AChoice^ do AChoiceSol^.SetInstance(@Instance);
   SetFirstRank(AChoice^.FirstRank);
   SetProba(AChoice^.Probability);
   SetIncentive(AChoice^.Incentive);
  end;
  AnEquilibrium^.ChoiceSolSet^.Insert(AChoiceSol);
 end;
 procedure FillStrategy(AStrategy:PStrategy);far;
 var AChoice:PChoice;
 begin
  AStratSol:=New(PStrategyS,Init(@Self,AStrategy^.Owner,SolutionType));
  with AStratSol^
  do begin
   SetRank(SolutionNumber);
   StrCopy(AName,AStrategy^.ShowName);
   SetName(AName);
   SetRank(SolutionNumber);
   SetLocus(AStrategy^.ShowLocus^);
   SetOwnerRank(AStrategy^.OwnerRank);
   AChoice:=TheGame^.FindChoice(AStrategy);
   if AChoice<>nil
   then with AChoice^ do begin
    SetProbability(Probability);
    SetExpectation(Incentive);
    if Probability>MidwayDefault
    then SetFocus(True)
    else SetFocus(False);
   end;
  end;
  AnEquilibrium^.StratSolSet^.Insert(AStratSol);
 end;
begin  {SaveEquilibrium}
 if (SolutionNumber>=MaxEquilNumber) then Exit;
 if not {IsNewSolution} HasNoSameSolution then Exit;
 if LowMemory then begin
  LowMemFlag:=True;
  IsAborted:=True;
 end;
 SolutionNumber:=SolutionNumber+1;
 AnEquilibrium:=New(PEquilibrium,Init(TheGame,SolutionNumber,SolutionType));
 with TheGame^
 do begin
     NodeSet^.ForEach(@FillExpectation);   {Fill NodeSet and ChoiceSet}
     ChoiceSet^.ForEach(@FillChoice);      {even in normal form case to spot repeat solutions}
     if IsNormalForm
     then StrategySet^.ForEach(@FillStrategy);
    end;
 with TheGame^ do
 if CrntEquilSet<>nil
 then begin
  CrntEquilSet^.Insert(AnEquilibrium);
  SolutionSave(AnEquilibrium);
 end;
 PostProgress(-2);
end;

function TSolveDlg.InvertJacobian:Boolean;
begin
 InvertJacobian:=True;
 TheExpectator^.TheInvertor.Init(Jacobian,Dim);
 with TheExpectator^.TheInvertor do begin
  Invert;
  InvertJacobian:=IsInvertible;
 end;
end;

function TSolveDlg.MakeDirection:Boolean;
{Direction is minus inverse Jacobian times Deviation}
var Sum:Real;ARow:PVector;
 procedure SetDirections(AChoice:PChoice);far;
 var Col:Byte;
 begin
  with AChoice^ do
  if Coordinate>0
  then begin
   Sum:=0;
   ARow:=Inverse^[Coordinate];
   for Col:=1 to Dim
   do Sum:=Sum-SafeMultiply(ARow^[Col],Deviation^[Col]);
   SetDirection(Sum);
  end else SetDirection(0);
 end;
begin
 if InvertJacobian    {Stored in Inverse}
 then begin
  MakeDirection:=True;
  TheGame^.ChoiceSet^.ForEach(@SetDirections);
 {MakeVectorLog(0,Dim,Direction);}
 end else MakeDirection:=False;
end;

function TSolveDlg.MakeProfile:Boolean;
var Coef0,Coef1,Coef2:Real;
 procedure MakeProfileNorm;
  procedure CheckMax(AChoice:PChoice);far;
  begin
   with AChoice^ do
   if Coordinate>0
   then if (ABS(ProfileValue)>ProfileNorm)
        then ProfileNorm:=ABS(ProfileValue);
  end;
 begin
  ProfileNorm:=0;
  TheGame^.ChoiceSet^.ForEach(@CheckMax);
 end;
 procedure MakeNewProfile(AChoice:PChoice);far;
 begin
  with AChoice^ do
  if Coordinate>0
  then SetProfileValue(ProfileValue+Step*Direction)
  else SetProfileValue(0);
 end;
begin
 {MakeCoef(Step,Step1,Step2,Coef0,Coef1,Coef2);}
 TheGame^.ChoiceSet^.ForEach(@MakeNewProfile);
 {MakeVector(1);
  {MakeVectorLog(1,Dim,Profile); }
 MakeProfileNorm;
 if ProfileNorm>ProfileCutOff
 then MakeProfile:=False
 else MakeProfile:=True;
end;

 {----------------------------------------------}
 {-------Control Solve Dialog-------------------}
 {----------------------------------------------}

 procedure TControlSolve.ChooseStart;
 begin
  EndDlg(id_ChooseStart);
 end;

 {----------------------------------------------}
 {-------Show Dialog----------------------------}
 {----------------------------------------------}

 procedure TShowSol.SetupWindow;
  procedure PrintName(AGameObject:PGameObject); far;
  begin
   SendDlgItemMsg(104,lb_AddString,0,LongInt(AGameObject^.ShowName));
  end;
 begin
  SendDlgItemMsg(121,bm_SetCheck,1,0);
  TheGame^.ShowViewable^.ForEach(@PrintName);
  TheGameMode^.ShowMode(HWindow);
  SendDlgItemMsg(104,lb_SetCurSel,0,LongInt(0));
  if TheGame^.ShowViewable^.Count>0
  then SelectedSolution:=TheGame^.ShowViewable^.At(0);
 end;

 procedure TShowSol.Update;    {Activated by clicking the listbox}
 begin
  Index:=SendDlgItemMsg(104,lb_GetCurSel,0,LongInt(0));
  if Index>=0 then SelectedSolution:=TheGame^.ShowViewable^.At(Index);
 end;

 procedure TShowSol.Show(var Msg:TMessage);
 begin
  if SendDlgItemMsg(120,bm_GetCheck,0,0)<>0
  then EndDlg(id_ShowOne) else EndDlg(id_ShowFew);
 end;

 procedure TShowSol.Dump(var Msg:TMessage);
 begin
  EndDlg(id_Dump);
 end;

 procedure TShowSol.ShowNone(var Msg:TMessage);
 begin
  EndDlg(id_Ok);
 end;

 procedure TShowSol.SaveAll(var Msg:TMessage);
 begin
  EndDlg(id_SaveAll);
 end;

 constructor TModeChoice.Init(AMode:Byte);
 begin
  ModeCode:=AMode;
  if TheGame^.IsNormalForm
  then case (AMode-sm_Rational) of
    sm_Perfect+sm_Pure          : StrCopy(ModeString,'Pure & Normal');
    sm_Perfect+sm_Explore       : StrCopy(ModeString,'Explore & Normal');
  end else case (AMode-sm_Rational) of
   sm_Nash+sm_Pure            : StrCopy(ModeString,'Pure & Nash');
   sm_Nash+sm_Explore         : StrCopy(ModeString,'Explore & Nash');
   sm_Nash+sm_Sample          : StrCopy(ModeString,'Sample & Nash');
   sm_Perfect+sm_Pure         : StrCopy(ModeString,'Pure & Perfect');
   sm_Perfect+sm_Explore      : StrCopy(ModeString,'Explore & Perfect');
   sm_Perfect+sm_Sample       : StrCopy(ModeString,'Sample & Perfect');
   sm_Sequential+sm_Explore   : StrCopy(ModeString,'Explore & Sequential');
   sm_Sequential+sm_Sample    : StrCopy(ModeString,'Sample & Sequential');
   {sm_Normal+sm_Pure          : StrCopy(ModeString,'Pure & Normal');
   sm_Normal+sm_Explore       : StrCopy(ModeString,'Explore & Normal');}
  end;
 end;

 function TModeChoice.ShowModeString:PChar;
 begin
  ShowModeString:=@ModeString[0];
 end;

 function TModeChoice.ShowModeCode:Byte;
 begin
  ShowModeCode:=ModeCode;
 end;

 procedure TChooseSol.SetupWindow;
 var Index:Byte;
  procedure PrintMode(AModeChoice:PModeChoice); far;
  begin
   SendDlgItemMsg(500,lb_AddString,0,LongInt(AModeChoice^.ShowModeString));
  end;
 begin
  ChoiceColl.Init(10,10);
  for Index:=200 to 255
  do if TheGame^.SelectSolution(Index)
  then begin
   TheModeChoice:=New(PModeChoice,Init(Index));
   ChoiceColl.Insert(TheModeChoice);
  end;
  ChoiceColl.ForEach(@PrintMode);
  SendDlgItemMsg(500,lb_SetCurSel,0,LongInt(0));
  ThePick:=-1;
 end;

 procedure TChooseSol.Ok;
 begin
  ThePick:=SendDlgItemMsg(500,lb_GetCurSel,0,0);
  if ThePick>=0
  then begin
   TheModeChoice:=ChoiceColl.At(ThePick);
   EndDlg(TheModeChoice^.ShowModeCode);
  end else EndDlg(id_Cancel);
 end;

 procedure TChooseSol.Cancel;
 begin
  EndDlg(id_Cancel);
 end;

 {----------------------------------------------}
 {----Unit execution----------------------------}
 {----------------------------------------------}

procedure InitSolveUnit;
begin
  GetMem(DummyCol,SizeOf(Vector));
  {GetMem(Direction,SizeOf(Vector)); }
  GetMem(Profile,SizeOf(Vector));
  GetMem(OldProfile,SizeOf(Vector));
  GetMem(Deviation,SizeOf(Vector));
  GetMem(Jacobian,SizeOf(TSqrMatrix));
  GetMem(Transition,SizeOf(TSqrMatrix));
  GetMem(IminusT,SizeOf(TSqrMatrix));
  GetMem(Inverse,SizeOf(TSqrMatrix));
  {GetMem(Storage,SizeOf(TSqrMatrix));}
  InitMatrix(Jacobian);
  InitMatrix(Transition);
  InitMatrix(IminusT);
  InitMatrix(Inverse);
  {InitMatrix(Storage);}
  GetMem(Expectation,SizeOf(TUtility));
  GetMem(InstantResult,SizeOf(TUtility));
  InitUtility(Expectation);
  InitUtility(InstantResult);
end;

procedure CleanupSolveUnit;
begin
  DisposeUtility(Expectation);
  DisposeUtility(InstantResult);
  FreeMem(Expectation,SizeOf(TUtility));
  FreeMem(InstantResult,SizeOf(TUtility));
  DisposeMatrix(Jacobian);
  DisposeMatrix(Transition);
  DisposeMatrix(IminusT);
  DisposeMatrix(Inverse);
  {DisposeMatrix(Storage);}
  FreeMem(Jacobian,SizeOf(TSqrMatrix));
  FreeMem(Transition,SizeOf(TSqrMatrix));
  FreeMem(IminusT,SizeOf(TSqrMatrix));
  FreeMem(Inverse,SizeOf(TSqrMatrix));
  {FreeMem(Storage,SizeOf(TSqrMatrix));}
  {FreeMem(Direction,SizeOf(Vector));}
  FreeMem(Profile,SizeOf(Vector));
  FreeMem(OldProfile,SizeOf(Vector));
  FreeMem(Deviation,SizeOf(Vector));
  FreeMem(DummyCol,SizeOf(Vector));
end;

begin
  MaxTurn:=10000;    {About 10 hours of compute time}
  ShowDetails:=True;
  IsEliminating:=True;
  RandSeed:=LongInt(0);
  Horizon:=DefaultHorizon;
  Noise:=DefaultNoise;
  Generation:=DefaultGener;
end.


