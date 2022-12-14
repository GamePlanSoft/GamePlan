
{Copyright (c), Jean-Pierre P. Langlois, 2007-2022}

Unit GP_Loop;

interface

uses GP_Type,Winprocs,Objects,WinTypes,Strings,WinDos,
     GP_Cnst,GP_Util;

type

 PGameType = ^TGameType;
 TGameType = object(TGame)
  MainTitle             : PHeader;
  Protected             : PProtect;
  SelectedObject        : PGameObject;        {Selected objects are used in}
  SelectedComment       : PComment;
  SelectedPlayer        : PPlayer;            {graphics and editing routines}
  StartNode,
  SelectedNode          : PNode;
  SelectedMove          : PMove;
  SelectedInfo          : PInfo;
  FocusStrategy,
  SelectedStrategy      : PStrategy;
  SelectedCell          : PCell;
  SelectedEvolver       : PEvolver;
  SelectedPair          : PPair;
  CommentSet,
  PlayerSet,
  NodeSet,
  MoveSet,
  OutcomeSet,
  InfoSet,
  ChoiceSet,
  StartNodeColl,
  StartInfoColl,
  CellSet,
  StrategySet,
  EvolverSet,
  EvObjSet,
  PairSet,
  GameAuditSet,
  ViewEquilSet,
  NashPureSet,
  NashExplSet,
  NashSampSet,
  PerfPureSet,
  PerfExplSet,
  PerfSampSet,
  SequExplSet,
  SequSampSet,
  CrntEquilSet          : PCollection;
  IsEvolutionary,
  IsSymmetric,
  IsNormalForm,
  IsSolved,
  IsPerfectInfo,
  HasBayesianInfo       : Boolean;
  GameForm,             {gf_cnst}
  Drift                 : Byte;
  constructor Init;
  destructor Done; virtual;
  procedure ReorderStrategies(var First,Second,Third:PStrategy);
  procedure DistributeStrategies;
  procedure ShiftStrategyFocus;
  function FindCell(First,Second,Third:PStrategy):PCell;
  procedure FreeCell(ACell:PCell);
  procedure SetDrift;
  procedure AdjustCells(IsAdding:Boolean;AStrategy:PStrategy);
  procedure MakeTwinSet;
  procedure RankCollections(ForSaving:Boolean);
  function DeleteStrategy(AStrategy:PStrategy):Boolean;
  function CanDeletePlayer(APlayer:PPlayer):Boolean;
  function CanDeleteNode(ANode:PNode):Byte;
  procedure CreateSingleton(ANode:PNode);
  procedure DeleteEmptyInfo;
  procedure ClearChoices;
  procedure ClearAll;
  procedure CleanUpNormalSol;
  procedure MakeBug(ACase:Byte;AnObject1,AnObject2,AnObject3,AnObject4:PGameObject);
  function TransAudit:Boolean;
  function FindLead(ANode:PNode):PMove;
  function FindChoice(AStrategy:PStrategy):PChoice;
  procedure TranslateNormPayoff;
  function TranslatedForm:Boolean;
  procedure NormalCleanUp;
  procedure MakeBayesObjects;
  procedure MakeGameAudit;
  function ShowAudit:PCollection;
  procedure MakeViewable;
  function ShowViewable:PCollection;
  function ThirdPlayer:PPlayer;
  function ExistStartNode:Boolean;
  procedure OrderStartNodes;
  procedure MakeStartInfoColl;
  function MakeStartCollection:Boolean;
  function FindSingleFamily(TheNode:PNode;var TheInfo:PInfo):Boolean;
  function FindOutcome(IsMove:Boolean;AMove:PMove;ACell:PCell;APlayer:PPlayer;
                       var FoundOutcome:POutcome):Boolean;
  procedure DumpOutcomes(AMove:PMove);
  {Conditioning utilities}
  function CheckEventOwners(AnInfo:PInfo):Boolean;
  function FindMatchingStrategy(TheStrategy:PStrategy):Boolean;
  function FindMatchingMove(AName:NameType;AFrom:PNode;
                            var TheMove:PMove):Boolean;
  procedure ConditionChoices(AnInfo:PInfo);     {Used in ConditionAll only}
  procedure SetSolve(ItIs:Boolean);
  function SelectSolution(AMode:Byte):Boolean;
 end;

implementation

constructor TGameType.Init;
begin
 MainTitle      :=nil;
 Protected      :=nil;
 CommentSet     :=New(PCollection,Init(10,10));
 PlayerSet      :=New(PCollection,Init(MaxPlayerNumber,MaxPlayerNumber));
 NodeSet        :=New(PCollection,Init(MaxNodeNumber,MaxNodeNumber));
 MoveSet        :=New(PCollection,Init(MaxMoveNumber,MaxMoveNumber));
 OutcomeSet     :=New(PCollection,Init(MaxMoveNumber*MaxPlayerNumber,
                                       MaxMoveNumber*MaxPlayerNumber));
 InfoSet        :=New(PCollection,Init(MaxNodeNumber,MaxNodeNumber));
 ChoiceSet      :=New(PCollection,Init(MaxMoveNumber,MaxMoveNumber));
 CellSet        :=New(PCollection,Init(MaxMoveNumber,MaxMoveNumber));
 StrategySet    :=New(PCollection,Init(MaxStrategy,MaxStrategy));
 EvolverSet     :=New(PCollection,Init(MaxStratNumber,MaxStratNumber));
 EvObjSet       :=New(PCollection,Init(MaxStrategy,MaxStrategy));
 PairSet        :=New(PCollection,Init(MaxStrategy,MaxStrategy));
 GameAuditSet    :=New(PCollection,Init(MaxStrategy,MaxStrategy));
 ViewEquilSet   :=New(PCollection,Init(MaxEquilNumber,MaxEquilNumber));
 NashPureSet    :=New(PCollection,Init(MaxEquilNumber,MaxEquilNumber));
 NashExplSet    :=New(PCollection,Init(MaxEquilNumber,MaxEquilNumber));
 NashSampSet    :=New(PCollection,Init(MaxEquilNumber,MaxEquilNumber));
 PerfPureSet    :=New(PCollection,Init(MaxEquilNumber,MaxEquilNumber));
 PerfExplSet    :=New(PCollection,Init(MaxEquilNumber,MaxEquilNumber));
 PerfSampSet    :=New(PCollection,Init(MaxEquilNumber,MaxEquilNumber));
 SequExplSet    :=New(PCollection,Init(MaxEquilNumber,MaxEquilNumber));
 SequSampSet    :=New(PCollection,Init(MaxEquilNumber,MaxEquilNumber));
 CrntEquilSet   :=nil;
 StartNodeColl  :=New(PCollection,Init(MaxNodeNumber,MaxNodeNumber));
 StartInfoColl  :=New(PCollection,Init(MaxNodeNumber,MaxNodeNumber));
 IsSolved:=False;
  SelectedObject        :=nil;
  SelectedComment       :=nil;
  SelectedPlayer        :=nil;
  StartNode             :=nil;
  SelectedNode          :=nil;
  SelectedMove          :=nil;
  SelectedInfo          :=nil;
  FocusStrategy         :=nil;
  SelectedStrategy      :=nil;
  SelectedCell          :=nil;
  SelectedEvolver       :=nil;
  SelectedPair          :=nil;
end;

destructor TGameType.Done;
begin
 if MainTitle<>nil then Dispose(MainTitle);
 if Protected<>nil then Dispose(Protected);
 if CommentSet<>nil then Dispose(CommentSet,Done);
 if PlayerSet<>nil then Dispose(PlayerSet,Done);
 if NodeSet<>nil then Dispose(NodeSet,Done);
 if MoveSet<>nil then Dispose(MoveSet,Done);
 if OutcomeSet<>nil then Dispose(OutcomeSet,Done);
 if InfoSet<>nil then Dispose(InfoSet,Done);
 if ChoiceSet<>nil then Dispose(ChoiceSet,Done);
 if NashPureSet<>nil then Dispose(NashPureSet,Done);
 if NashExplSet<>nil then Dispose(NashExplSet,Done);
 if NashSampSet<>nil then Dispose(NashSampSet,Done);
 if PerfPureSet<>nil then Dispose(PerfPureSet,Done);
 if PerfExplSet<>nil then Dispose(PerfExplSet,Done);
 if PerfSampSet<>nil then Dispose(PerfSampSet,Done);
 if SequExplSet<>nil then Dispose(SequExplSet,Done);
 if SequSampSet<>nil then Dispose(SequSampSet,Done);
 if GameAuditSet<>nil then Dispose(GameAuditSet,Done);
 if ViewEquilSet<>nil then Dispose(ViewEquilSet);
 if CellSet<>nil then Dispose(CellSet,Done);
 if StrategySet<>nil then Dispose(StrategySet,Done);
 if EvolverSet<>nil then Dispose(EvolverSet,Done);
 if EvObjSet<>nil then Dispose(EvObjSet,Done);
 if PairSet<>nil then Dispose(PairSet,Done);
 StartNodeColl^.DeleteAll;
 if StartNodeColl<>nil then Dispose(StartNodeColl,Done);
 StartInfoColl^.DeleteAll;
 if StartInfoColl<>nil then Dispose(StartInfoColl,Done);
end;


procedure TGameType.ReorderStrategies(var First,Second,Third:PStrategy);  {In owners' order}
var F,S,T:PStrategy;
 procedure FindOrder(AStrategy:PStrategy);
 var Index:Byte; APlayer:PPlayer;
 begin
  if AStrategy=nil then Exit;
  APlayer:=AStrategy^.Owner;
  Index:=PlayerSet^.IndexOf(APlayer);
  case Index of
   0: F:=AStrategy;
   1: S:=ASTrategy;
   2: T:=AStrategy;
  end;
 end;
begin
 F:=nil;S:=nil;T:=nil;
 FindOrder(First);
 FindOrder(Second);
 FindOrder(Third);
 First:=F;
 Second:=S;
 Third:=T;
end;

procedure TGameType.DistributeStrategies;     {To their respective owners}
var APlayer:PPlayer; AStrategy: PStrategy;
 procedure ClearStrategies(BPlayer:PPlayer);far;
 begin
    BPlayer^.OwnStrategies.DeleteAll;
 end;
 procedure ReplaceStrategies(AStrategy:PStrategy);far;
 begin
    APlayer:=AStrategy^.Owner;
    APlayer^.OwnStrategies.Insert(AStrategy);
 end;
begin
 PlayerSet^.ForEach(@ClearStrategies);
 StrategySet^.ForEach(@ReplaceStrategies);
end;

procedure TGameType.ShiftStrategyFocus;
var Index:Byte; ThirdColl:PCollection;
 procedure AdjustFocus(AStrategy:PStrategy);far;
 begin
  if AStrategy=FocusStrategy
  then AStrategy^.SetFocus(True)
  else AStrategy^.SetFocus(False);
 end;
 procedure AdjustCellFocus(ACell:PCell);far;
 begin
  if ACell^.ShowStrategy(3)^.HasFocus
  then ACell^.SetFocus(True)
  else ACell^.SetFocus(False);
 end;
 procedure SetDefaultFocus(ACell:PCell);far;
 begin
  ACell^.SetFocus(True);
 end;
begin
 if not IsNormalForm then Exit;
 CellSet^.ForEach(@SetDefaultFocus);
 if ThirdPlayer=nil
 then FocusStrategy:=nil
 else begin    {Exists third player}
  if ThirdPlayer^.OwnStrategies.Count=0
  then FocusStrategy:=nil
  else begin    {Third player has strategies}
   ThirdColl:=@(ThirdPlayer^.OwnStrategies);
   if FocusStrategy=nil
   then FocusStrategy:=ThirdColl^.At(0)
   else begin
    Index:=ThirdColl^.IndexOf(FocusStrategy);
    Index:=Index+1;
    if Index=ThirdColl^.Count
    then Index:=0;
    FocusStrategy:=ThirdColl^.At(Index);
   end;
   ThirdColl^.ForEach(@AdjustFocus);
   CellSet^.ForEach(@AdjustCellFocus);
  end;
 end;
end;

function TGameType.FindCell(First,Second,Third:PStrategy):PCell;
var TheCell:PCell; IsMatch:Boolean; F,S,T: PStrategy;
 procedure FindMatch(ACell:PCell);far;
 begin
  IsMatch:=True;
  with ACell^ do
   if (ShowStrategy(1)<>F)
   or (ShowStrategy(2)<>S)
   or (ShowStrategy(3)<>T)
   then IsMatch:=False;
  if IsMatch then TheCell:=ACell;
 end;
begin
 TheCell:=nil;
 F:=First; S:=Second; T:=Third;
 ReorderStrategies(F,S,T);
 CellSet^.ForEach(@FindMatch);
 FindCell:=TheCell;
end;

procedure TGameType.FreeCell(ACell:PCell);
var ACandidate:POutcome;
begin
 if ACell=nil then Exit;
 repeat
  if FindOutcome(False,nil,ACell,nil,ACandidate)
  then OutcomeSet^.Free(ACandidate);
 until ACandidate=nil;
 CellSet^.Free(ACell);
end;

  procedure TGameType.SetDrift;
  var APlayer:PPlayer;
  begin
   Drift:=0;
   if (ThirdPlayer<>nil)
   and IsNormalForm
   then Drift:=ThirdPlayer^.OwnStrategies.Count;
  end;

procedure TGameType.AdjustCells(IsAdding:Boolean;AStrategy:PStrategy);
{Add strategy to existing cell or delete cell with strategy}
var P:array[0..2] of PPlayer; ACell:PCell; J:Byte;
 procedure SetPlayers(I:Byte);
 begin
  if PlayerSet^.Count>I
  then P[I]:=PlayerSet^.At(I)
  else P[I]:=nil
 end;
 procedure AddCell(F:PStrategy);far;
  procedure MakeCell(S:PStrategy);far;
   procedure Make3DCell(T:PStrategy);far;
   begin
    ACell:=FindCell(F,S,T);
    if ACell=nil
    then begin
     ACell:=New(PCell,Init(@Self,F,S,T));
     CellSet^.Insert(ACell);
    end;
   end;
  begin
   if P[2]=nil
   then begin {Make 2D Cell}
    ACell:=FindCell(F,S,nil);
    if ACell=nil
    then begin
     ACell:=New(PCell,Init(@Self,F,S,nil));
     CellSet^.Insert(ACell);
    end;
   end else P[2]^.OwnStrategies.ForEach(@Make3DCell);
  end;
 begin {AddCell}
  if P[1]=nil then Exit;
  P[1]^.OwnStrategies.ForEach(@MakeCell);
 end;  {AddCell}
 function IsDeleteCandidate(ACandidate:PCell):Boolean;
 var Index:Byte;
 begin
  IsDeleteCandidate:=False;
  for Index:=1 to 3
  do if ACandidate^.ShowStrategy(Index)=AStrategy
     then IsDeleteCandidate:=True;
 end;
 procedure DeleteCell(F:PStrategy);far;
  procedure SecondLevel(S:PStrategy);far;
   procedure ThirdLevel(T:PStrategy);far;
   begin  {Thirdlevel}
    ACell:=FindCell(F,S,T);
    if IsDeleteCandidate(ACell)
    then FreeCell(ACell);
   end;  {ThirdLevel}
  begin  {SecondLevel}
   if P[2]=nil
   then begin
    ACell:=FindCell(F,S,nil);
    if IsDeleteCandidate(ACell)
    then FreeCell(ACell);
   end else P[2]^.OwnStrategies.ForEach(@ThirdLevel);
  end;   {SecondLevel}
 begin {DeleteCell}
  if P[1]=nil then Exit;
  P[1]^.OwnStrategies.ForEach(@SecondLevel);
 end;  {DeleteCell}
 procedure AddCellStrategy(ACell:PCell);far;
 begin  {Replace nil by AStrategy in all existing cells}
  if ACell=nil then Exit;
  ACell^.SetStrategy(AStrategy);
 end;
begin    {AdjustCells}
 if not IsNormalForm then Exit;
 DistributeStrategies;
 for J:=0 to 2 do SetPlayers(J);
 if P[0]=nil then Exit;
 if IsAdding
 then begin     {adding cells}
  CellSet^.ForEach(@AddCellStrategy);
  P[0]^.OwnStrategies.ForEach(@AddCell);
 end else begin {deleting cells}
  P[0]^.OwnStrategies.ForEach(@DeleteCell);
  if AStrategy=FocusStrategy
  then FocusStrategy:=nil;
 end;
end;  {AdjustCells}

function TGameType.DeleteStrategy(AStrategy:PStrategy):Boolean;
begin
 if EvolverSet^.Count>0
 then DeleteStrategy:=False
 else begin
  DeleteStrategy:=True;
  if IsEvolutionary and IsSymmetric
  then if AStrategy^.Twin<>nil then begin
   AdjustCells(False,AStrategy^.Twin);     {Delete cells with this twin strategy}
   StrategySet^.Free(AStrategy^.Twin);
   AStrategy^.Twin:=nil;
  end;
  AdjustCells(False,AStrategy);     {Delete cells with this strategy}
  StrategySet^.Free(AStrategy);
  AStrategy:=nil;
  StrategySet^.Pack;
  {ShiftStrategyFocus;}
 end;
end;

function TGameType.CanDeletePlayer(APlayer:PPlayer):Boolean;
var AnOutcome:POutcome;
 procedure CheckDecider(AStrategy:PStrategy); far;
 begin
  if AStrategy^.Owner=APlayer
  then CanDeletePlayer:=False;                     {Means node attached}
 end;
 procedure CheckOwner(ANode:PNode); far;
 begin
  if ANode^.Owner=APlayer
  then CanDeletePlayer:=False;                     {Means node attached}
 end;
 procedure CheckOutcomes(AMove:PMove);far;
 begin
  if FindOutcome(True,AMove,nil,APlayer,AnOutcome)
  then CanDeletePlayer:=False;
 end;
begin
 if APlayer<>nil
 then CanDeletePlayer:=True                         {Means can delete}
 else CanDeletePlayer:=False;
 if IsNormalForm
 then begin
  StrategySet^.ForEach(@CheckDecider);
 end else begin
  NodeSet^.ForEach(@CheckOwner);
  MoveSet^.ForEach(@CheckOutcomes);
 end;
end;

function TGameType.CanDeleteNode(ANode:PNode):Byte;
 procedure CheckEnds(AMove:PMove); far;
 begin
  if (AMove^.From=ANode)
  or (AMove^.Upto=ANode)
  then CanDeleteNode:=1;
 end;
begin
 if ANode=nil
 then CanDeleteNode:=3
 else begin
  CanDeleteNode:=0;
  MoveSet^.ForEach(@CheckEnds);
  if ANode^.Family<>nil
  then if ANode^.Family^.Event.Count>1
       then CanDeleteNode:=2;
 end;
end;

 procedure TGameType.MakeTwinSet;
 var TwinInfo:PAuditItem;
  procedure MakeTwinStrats(AStrat:PStrategy);far;
  begin
   if AStrat<>nil then with AStrat^ do begin
    if Owner<>PlayerSet^.At(0) then Exit;
    TwinInfo:=New(PAuditItem,Init(@Self,gi_TwinStrat,AStrat,AStrat^.Twin,nil,nil));
    GameAuditSet^.Insert(TwinInfo);
   end;
  end;
  procedure MakeTwinEvolvs(AnEvolv:PEvolver);far;
  begin
   if AnEvolv<>nil then with AnEvolv^ do begin
    if Owner<>PlayerSet^.At(0) then Exit;
    TwinInfo:=New(PAuditItem,Init(@Self,gi_TwinEvol,AnEvolv,AnEvolv^.Twin,nil,nil));
    GameAuditSet^.Insert(TwinInfo);
   end;
  end;
 begin
  if not (IsEvolutionary and IsSymmetric) then Exit;
  GameAuditSet^.FreeAll;
  StrategySet^.ForEach(@MakeTwinStrats);
  EvolverSet^.ForEach(@MakeTwinEvolvs);
 end;

 procedure TGameType.RankCollections(ForSaving:Boolean);
 var
  ARank : Byte; LongRank:Integer;
  procedure RankObjects(AGameObject:PGameObject); far;
  begin
   AGameObject^.SetRank(ARank);
   ARank:=ARank+1;
  end;
  procedure CheckFamily(ANode:PNode);far;
  begin
   CreateSingleton(ANode);
  end;
  procedure ReOrderEvents(AnInfo:PInfo); far;      {Re-order NodeSet}
   procedure OrderNodes(ANode:PNode);far;
   begin
    with NodeSet^
    do begin
     Delete(ANode);
     Insert(ANode);
    end;
   end;
  begin
   AnInfo^.Event.ForEach(@OrderNodes);
  end;
  procedure ResetNode(ANode:PNode); far;
  begin
   with ANode^ do begin
    if Owner=nil then SetOwnerRank(0)
    else SetOwnerRank(Owner^.Rank);
    if Family<>nil
    then SetFamilyRank(Family^.Rank)
    else SetFamilyRank(0);
   end;
  end;
  procedure ResetMove(AMove:PMove); far;
  var ANode:PNode;
  begin              {Will need some code for final moves at cells}
   AMove^.SetFromRank(AMove^.From^.Rank);
   ANode:=AMove^.Upto;
   if ANode=nil
   then AMove^.SetUptoRank(0)
   else AMove^.SetUptoRank(ANode^.Rank);
  end;
  procedure ResetOutcome(AnOutcome:POutcome); far;
  begin
   with AnOutcome^
   do begin
    SetWhomRank(Whom^.Rank);
    {Distinguish move from cell outcomes}
    if IsNormalForm {Where=nil}
    then SetWhereRank(Whence^.Rank)
    else SetWhereRank(Where^.Rank);
   end;
  end;
  procedure ResetStrategy(AStrategy:PStrategy); far;
  begin
   AStrategy^.SetOwnerRank(AStrategy^.Owner^.Rank);
  end;
  procedure ResetCell(ACell:PCell); far;
  var I:Byte; AStrategy:PStrategy;
  begin
   {Set ranks of cell strategies}
   with ACell^ do
   for I:=1 to 3
   do begin
       AStrategy:=ShowStrategy(I);
       if AStrategy=nil
       then SetStrategyRank(I,0)
       else SetStrategyRank(I,AStrategy^.Rank);
   end;
  end;
  procedure ResetEvolver(AnEvolver:PEvolver);far;
  begin
   AnEvolver^.Reset;   {reset default strat, color, and evolver rank in its evobjects}
  end;
  procedure RankEvObjects(AnEvBasic:PEvBasic); far;
  begin
   AnEvBasic^.SetLongRank(LongRank);
   LongRank:=LongRank+1;
  end;
 begin
   DeleteEmptyInfo;
   NodeSet^.ForEach(@CheckFamily);
   InfoSet^.ForEach(@ReOrderEvents);
   ARank:=1;CommentSet^.ForEach(@RankObjects);
   ARank:=1;PlayerSet^.ForEach(@RankObjects);
   ARank:=1;NodeSet^.ForEach(@RankObjects);
   ARank:=1;MoveSet^.ForEach(@RankObjects);
   ARank:=1;InfoSet^.ForEach(@RankObjects);
   ARank:=1;ChoiceSet^.ForEach(@RankObjects);
   ARank:=1;StrategySet^.ForEach(@RankObjects);
   ARank:=1;EvolverSet^.ForEach(@RankObjects);
   ARank:=1;PairSet^.ForEach(@RankObjects);
   ARank:=1;CellSet^.ForEach(@RankObjects);
   ARank:=1;CommentSet^.ForEach(@RankObjects);
   NodeSet^.ForEach(@ResetNode);
   StrategySet^.ForEach(@ResetStrategy);
   CellSet^.ForEach(@ResetCell);
   MoveSet^.ForEach(@ResetMove);
   if ForSaving
   then begin
    OutcomeSet^.ForEach(@ResetOutcome);
    EvObjSet^.DeleteAll;
    EvolverSet^.ForEach(@ResetEvolver);
    LongRank:=1;EvObjSet^.ForEach(@RankEvObjects);
    {So, LongRank can be used in each Store procedure}
   end;
 end;

 procedure TGameType.CreateSingleton(ANode:PNode);
 var AnInfo:PInfo;
 begin
  if ANode=nil then Exit;                    {No node, no family}
  if ANode^.Family<>nil then Exit;       {No more than one family per node}
  AnInfo:=New(PInfo,Init(ANode^.Game));
  ANode^.SetFamily(AnInfo);
  AnInfo^.SetBayes(ANode^.IsBayes);      {Experiment}
  AnInfo^.AddEvent(ANode);
  AnInfo^.SetOwner(ANode^.Owner);
  InfoSet^.Insert(AnInfo);
 end;

 procedure TGameType.ClearChoices;
  procedure ClearChoiceList(AnInfo:PInfo);far;
  begin
   AnInfo^.ChoiceList.DeleteAll;
  end;
 begin
  InfoSet^.ForEach(@ClearChoiceList);
  ChoiceSet^.FreeAll;
 end;

 procedure TGameType.CleanUpNormalSol;
  procedure RemoveTools(AnEquilibrium:PEquilibrium);far;
  begin
   AnEquilibrium^.NodeSolSet^.FreeAll;
   AnEquilibrium^.ChoiceSolSet^.FreeAll;
  end;
  procedure BackToCell(AnOutcome:POutcome);far;
  begin
   {AnOutcome^.SetWhere(nil); }
   with AnOutcome^ do SetWhat(Whom,nil,Whence);
  end;
 begin
  CrntEquilSet^.ForEach(@RemoveTools);
  ChoiceSet^.FreeAll;
  MoveSet^.FreeAll;
  NodeSet^.FreeAll;
  InfoSet^.FreeAll;
  OutcomeSet^.ForEach(@BackToCell);
 end;

 procedure TGameType.ClearAll;
 begin
  PlayerSet^.FreeAll;
  NodeSet^.FreeAll;
  MoveSet^.FreeAll;
  OutcomeSet^.FreeAll;
  ClearChoices;
  InfoSet^.FreeAll;
  StrategySet^.FreeAll;
  EvolverSet^.FreeAll;
  EvObjSet^.DeleteAll;
  PairSet^.FreeAll;
  CellSet^.FreeAll;
  CommentSet^.FreeAll;
  GameAuditSet^.FreeAll;
  ViewEquilSet^.DeleteAll;
  NashPureSet^.FreeAll;
  NashExplSet^.FreeAll;
  NashSampSet^.FreeAll;
  PerfPureSet^.FreeAll;
  PerfExplSet^.FreeAll;
  PerfSampSet^.FreeAll;
  SequExplSet^.FreeAll;
  SequSampSet^.FreeAll;
  MainTitle:=nil;
  Protected:=nil;
 end;

 procedure TGameType.DeleteEmptyInfo;
 var Culprit:PInfo;
  function CulpritFound(AnInfo:PInfo):Boolean;far;
  begin
   CulpritFound:=False;
   if AnInfo=nil then Exit;
   if AnInfo^.Event.Count=0
   then begin
    Culprit:=AnInfo;
    CulpritFound:=True;
   end;
  end;
  procedure CheckFamily(ANode:PNode);far;
  begin
   if ANode^.Family=Culprit
   then ANode^.SetFamily(nil);
  end;
 begin
  Culprit:=nil;
  repeat
   if Culprit<>nil then begin
    NodeSet^.ForEach(@CheckFamily);
    InfoSet^.Free(Culprit);
   end;
   InfoSet^.FirstThat(@CulpritFound);
   InfoSet^.Pack;
  until (Culprit=nil) or (InfoSet^.Count=0);
 end;

 procedure TGameType.MakeViewable;
  procedure RecordViewable(AnEquilibrium:PEquilibrium);far;
  begin
   if not AnEquilibrium^.IsDisplayed
   then ViewEquilSet^.Insert(AnEquilibrium);
  end;
 begin
  ViewEquilSet^.DeleteAll;
  if CrntEquilSet<>nil
  then CrntEquilSet^.ForEach(@RecordViewable);
 end;

 function TGameType.ShowViewable:PCollection;
 begin
  ShowViewable:=ViewEquilSet;
 end;

 procedure TGameType.MakeBug(ACase:Byte;AnObject1,AnObject2,AnObject3,AnObject4:PGameObject);
 var ABug:PAuditItem;
 begin
   ABug:=New(PAuditItem,Init(@Self,ACase,AnObject1,AnObject2,AnObject3,AnObject4));
   GameAuditSet^.Insert(ABug);
 end;

 function TGameType.TransAudit:Boolean; {Called by TranslatedForm. GameAuditSet is empty}
 var IsTooSmall:Boolean;
  procedure CheckEnoughStrategies(APlayer:PPlayer);far;
  begin
   if APlayer^.OwnStrategies.Count<2
   then IsTooSmall:=True;
  end;
  procedure CheckPayoff(ACell:PCell);far;
  var AnOutcome:POutcome;
   procedure CheckPlayer(APlayer:PPlayer);far;
   begin
    if not FindOutcome(False,nil,ACell,APlayer,AnOutcome)
    then with ACell^
    do MakeBug(10,ShowStrategy(1),ShowStrategy(2),ShowStrategy(3),APlayer);
   end;
  begin
   PlayerSet^.ForEach(@CheckPlayer);
  end;
  procedure CheckNames(AStrategy:PStrategy);far;
  begin
   if FindMatchingStrategy(AStrategy)
   then MakeBug(11,AStrategy,AStrategy^.Owner,nil,nil);
  end;
 begin
   IsTooSmall:=False;
   if (PlayerSet^.Count<2)
   then IsTooSmall:=True;
   DistributeStrategies;
   PlayerSet^.ForEach(@CheckEnoughStrategies);
   if IsTooSmall
   then MakeBug(gi_TooSmallBug,nil,nil,nil,nil);
   CellSet^.ForEach(@CheckPayoff);
   StrategySet^.ForEach(@CheckNames);
   if GameAuditSet^.Count=0
   then TransAudit:=True
   else TransAudit:=False;
 end;

  function TGameType.FindLead(ANode:PNode):PMove;  {Called by TranslateNormPayoff}
 var ALead:PMove;
  procedure FindMatch(AMove:PMove);far;
  begin
   if AMove^.Upto=ANode
   then ALead:=AMove;
  end;
 begin
  ALead:=nil;
  MoveSet^.ForEach(@FindMatch);
  FindLead:=ALead;
 end;

 function TGameType.FindChoice(AStrategy:PStrategy):PChoice;
 var TheChoice:PChoice; TheMove:PMove;
  procedure MatchStrategy(AMove:PMove);far;
  begin
   if AMove^.OwnStrategy=AStrategy
   then TheMove:=AMove;
  end;
  procedure MatchMove(AChoice:PChoice);far;
  begin
   if AChoice^.HasInstance(TheMove)
   then TheChoice:=AChoice;
  end;
 begin
  TheChoice:=nil;
  TheMove:=nil;
  MoveSet^.ForEach(@MatchStrategy);
  if TheMove<>nil
  then ChoiceSet^.ForEach(@MatchMove);
  FindChoice:=TheChoice;
 end;

 procedure TGameType.TranslateNormPayoff;     {Called by TranslatedForm}
 var ACell:PCell; AnOutcome:POutcome;
  procedure StartBackup(FinalMove:PMove); far;
  var PreviousMove,FirstMove:PMove;
   procedure MatchOutcome(APlayer:PPlayer);far;
   begin
    if FindOutcome(False,nil,ACell,APlayer,AnOutcome)
    then begin
     with AnOutcome^
     do begin
      {SetWhere(FinalMove); }
      SetWhat(Whom,FinalMove,Whence);
     end;
    end;
   end;
  begin
   if FinalMove^.Upto=nil
   then begin
    PreviousMove:=FindLead(FinalMove^.From);
    if PreviousMove^.From=nil
    then Exit
    else begin
     FirstMove:=FindLead(PreviousMove^.From);
     if FirstMove=nil
     then ACell:=FindCell(PreviousMove^.OwnStrategy,FinalMove^.OwnStrategy,nil)
     else ACell:=FindCell(FirstMove^.OwnStrategy,
                          PreviousMove^.OwnStrategy,FinalMove^.OwnStrategy);
     PlayerSet^.ForEach(@MatchOutcome);
    end;
   end;
  end;
 begin
  MoveSet^.ForEach(@StartBackup);
 end;

 function TGameType.TranslatedForm:Boolean;  {Called by GameAudit. Trivially true if extensive}
 var APlayer:PPLayer;NewNode:PNode;AMove,FirstMove:PMove;AnInfo:PInfo;
     AName:NameType;NodeColl,MoveColl:TCollection; ThePoint:TPoint;
  procedure CreateLevel(ALevel:Byte;AMoveColl:PCollection);
   procedure CreateMoves(ANode:PNode);far;
    procedure CreateAMove(AStrategy:PStrategy);far;
    begin
     ThePoint.Y:=ThePoint.Y+50;
     AMove:=New(PMove,Init(@Self));
     StrCopy(AName,AStrategy^.ShowName);
     AMove^.SetName(AName);
     AMove^.SetLocus(ThePoint);
     AMove^.SetFrom(ANode);
     AMove^.SetOwnStrategy(AStrategy);  {To reconstruct cells and payoffs}
     MoveColl.Insert(AMove);
     MoveSet^.Insert(AMove);
    end;
   begin
    ThePoint:=ANode^.ShowLocus^;
    ThePoint.X:=ThePoint.X+75;
    APlayer^.OwnStrategies.ForEach(@CreateAMove);
   end;
   procedure CreateEndNode(AMove:PMove);far;
   begin
    ThePoint.Y:=ThePoint.Y+150;
    NewNode:=New(PNode,Init(@Self));
    NewNode^.SetLocus(ThePoint);
    NewNode^.SetOwner(APlayer);
    NewNode^.SetFamily(AnInfo);
    StrCopy(AName,AMove^.ShowName);   {For debugging only}
    NewNode^.SetName(AName);          {For debugging only}
    AMove^.SetUpto(NewNode);
    if AMove^.From<>nil
    then with AMove^
    do begin
     MakeArc;MakeArrow;
    end;
    NodeColl.Insert(NewNode);
    NodeSet^.Insert(NewNode);
    AnInfo^.AddEvent(NewNode);    {Checks info owner}
   end;
   procedure CreateEndArc(AMove:PMove);far;
   begin
    ThePoint.Y:=ThePoint.Y+75;
    if AMove^.From<>nil
    then with AMove^
    do begin
     SetLocus(ThePoint);MakeArc;MakeArrow;SetUpto(nil);
    end;
   end;
  begin
   if ALevel>=PlayerSet^.Count
   then begin
    ThePoint.Y:=0;
    AMoveColl^.ForEach(@CreateEndArc);
    TranslateNormPayoff;
   end else begin
    ThePoint.Y:=0;
    ThePoint.X:=150*(1+ALevel);
    APlayer:=PlayerSet^.At(ALevel);
    AnInfo:=New(PInfo,Init(@Self));
    InfoSet^.Insert(AnInfo);
    NodeColl.DeleteAll;
    AMoveColl^.ForEach(@CreateEndNode);
    MoveColl.DeleteAll;
    NodeColl.ForEach(@CreateMoves);
    CreateLevel(ALevel+1,@MoveColl);
   end;
  end;
 begin
  if not IsNormalForm
  then TranslatedForm:=True
  else if TransAudit
       then begin  {the translation}
        if NodeSet^.Count>0 then Exit;  {Game already translated}
        NodeColl.Init(MaxNodeNumber,MaxNodeNumber);
        MoveColl.Init(MaxMoveNumber,MaxMoveNumber);
        {Initialize Player #1}
        FirstMove:=New(PMove,Init(@Self));
        FirstMove^.SetFrom(nil);       {Virtual first move}
        StrCopy(AName,'First');        {For debugging only}
        FirstMove^.SetName(AName);     {For debugging only}
        MoveColl.Insert(FirstMove);    {Does not go into MoveSet}
        CreateLevel(0,@MoveColl);      {Recursive call to CreateLevel}
        Dispose(FirstMove);
       end else TranslatedForm:=False
 end;

 procedure TGameType.NormalCleanUp;  {Releases extensive form used for solving normal form game}
 begin
  if IsNormalForm
  then begin
   NodeSet^.FreeAll;
   MoveSet^.FreeAll;
   ClearChoices;
   InfoSet^.FreeAll;
  end;
 end;

procedure TGameType.MakeBayesObjects;              {Experiment}
  procedure AddBayesNode(AnInfo:PInfo);far;
  var ABayesNode:PNode; ABayesInfo,AnAncestor:PInfo; AMove:PMove;
   procedure CreateBMove(AnUpto:PNode);far;
   var AName:NameType;
   begin
    AMove:=New(PMove,Init(@Self));
    with AMove^ do begin
     SetFrom(ABayesNode);
     SetUpto(AnUpto);
     StrCopy(AName,AnUpto^.ShowName);
     SetName(AName);
     SetBayes(True);
    end;
    MoveSet^.Insert(AMove);
   end;
  begin
   If not AnInfo^.IsBayesian then Exit;
   If AnInfo^.HasBayesNode then Exit;
   ABayesNode:=New(PNode,Init(@Self));
   NodeSet^.Insert(ABayesNode);
   with ABayesNode^ do begin
    SetBayes(True);
    if AnInfo^.Ancestors.Count>0
    then begin
     AnAncestor:=AnInfo^.Ancestors.At(0);
     SetOwner(AnAncestor^.FirstNode^.Owner);
    end;
   end;
   AnInfo^.SetBayesStatus(True);          {So that don't create BayesNode again when Audit}
   AnInfo^.Event.ForEach(@CreateBMove);
  end;
 begin
  if HasBayesianInfo
  then InfoSet^.ForEach(@AddBayesNode);   {end Experiment}
 end;

 procedure TGameType.MakeGameAudit;
 {Checks for bugs. Calls ConditionChoices(AnInfo) to dump and re-create choices}
 var Outlet:TCollection;  IsDegenerate:Boolean;
  procedure CheckDegree(ANode:PNode); far;
  var Degree:Byte;
   procedure CheckFrom(AMove:PMove); far;
   begin
    if AMove^.From=ANode then Degree:=Degree+1;
   end;
  begin
   Degree:=0;
   MoveSet^.ForEach(@CheckFrom);
   if (Degree>MaxDegree) or (Degree=0)
   then MakeBug(gi_DegreeBug,ANode,nil,nil,nil);
  end;
  procedure CheckPayoff(AMove:PMove); far;
  var
   AnOutcome    : POutcome;
   procedure CheckAllPlayers(APlayer:PPlayer); far;
   begin
    if not FindOutcome(True,AMove,nil,APlayer,AnOutcome)
    then MakeBug(gi_OutcomeBug,AMove,APlayer,nil,nil);
   end;
  begin
    if AMove^.Upto=nil
    then PlayerSet^.ForEach(@CheckAllPlayers);
  end;
  procedure CheckChance(ANode:PNode); far;
  var TotalProba: Real;
   procedure AddProba(AMove:PMove); far;
   begin
    if AMove^.From=ANode
    then TotalProba:=TotalProba+AMove^.Discount;
   end;
  begin
   if ANode^.Owner<>nil then Exit;
   TotalProba:=0;
   MoveSet^.ForEach(@AddProba);
   if TotalProba>1 then MakeBug(3,ANode,nil,nil,nil);
  end;
  procedure CheckMoveDegenerate(AMove:PMove);far;
   procedure CheckMatches(MatchMove:PMove);far;
   begin
    if (MoveSet^.IndexOf(MatchMove)>ComIndex)
    and (MatchMove^.From=AMove^.From)
    and (MatchMove^.Upto=AMove^.Upto)
    then begin
      IsDegenerate:=True;
      MakeBug(4,AMove^.From,AMove,MatchMove,nil);
    end;
   end;
  begin
   if AMove^.Upto=nil then Exit;
   ComIndex:=MoveSet^.IndexOf(AMove);
   MoveSet^.ForEach(@CheckMatches);
  end;
  procedure MakePayoffArray(AMove:PMove); far;
  begin
   AMove^.PayoffCondition;  {Fill move payoff array}
  end;
  procedure ExistSingleFamily(ANode:PNode);far;
  var AnInfo:PInfo;
  begin
   if FindSingleFamily(ANode,AnInfo)   {Single or no family}
   then CreateSingleton(ANode)       {Ignored if single family}
   else MakeBug(6,ANode,nil,nil,nil)        {if multiple family}
  end;
  procedure MakeInfoCondition(AnInfo:PInfo); far;
  begin
   ConditionChoices(AnInfo);
  end;
  procedure CheckChanceInfo(AnInfo:PInfo);far;
  begin
   with AnInfo^ do
                if (Owner=nil)
                and (Event.Count>1)
                then MakeBug(7,FirstNode,nil,nil,nil);
  end;
  procedure CheckOwners(AnInfo:PInfo);far;
  begin
   if not CheckEventOwners(AnInfo)
   then MakeBug(8,AnInfo^.FirstNode,nil,nil,nil);
  end;
  procedure MakeChoiceSet(AnInfo:PInfo);far;
   procedure RecordChoice(AChoice:PChoice);far;
   begin
    ChoiceSet^.Insert(AChoice);
   end;
  begin
   AnInfo^.ChoiceList.ForEach(@RecordChoice);
  end;
  procedure MakeAncestors(AnInfo:PInfo);far;
  begin
   AnInfo^.ResetAncestors;
  end;
  procedure CheckInfoConnection(AMove:PMove);far;
  begin
   with AMove^ do
   if Upto<>nil
   then Upto^.Family^.AddAncestor(From^.Family);
  end;
  procedure CheckBayesian(AnInfo:PInfo);far;
  var CanBeOffTrack:Boolean;
   procedure CheckAncestor(AnAncestor:PInfo);far;
    procedure CheckOutlets(AChoice:PChoice);far;
     procedure CheckDescendant(AMove:PMove);far;
     begin
      if (AMove^.Upto<>nil)
      then if (AMove^.Upto^.Family=AnInfo)
           then Exit; {Else AnInfo is Bayesian}
       AnInfo^.SetBayesian(True);
       HasBayesianInfo:=True;
     end;
    begin
     AChoice^.Instance.ForEach(@CheckDescendant);
    end;
   begin
    AnAncestor^.ChoiceList.ForEach(@CheckOutlets);
   end;
   procedure CheckChanceAncestor(AnAncestor:PInfo);far;
   begin
    if AnAncestor^.Owner=nil then CanBeOffTrack:=False;
   end;
  begin                                    {Experiment.. Need work}
   if (AnInfo^.Event.Count<=1) then Exit;  {Singleton can't be Bayesian}
   CanBeOffTrack:=True;
   AnInfo^.Ancestors.ForEach(@CheckChanceAncestor);
   if CanBeOffTrack then AnInfo^.Ancestors.ForEach(@CheckAncestor);
  end;
  procedure CheckPerfectInfo;
  var MaxHor:Byte;
   procedure FindMaxHorizon(ANode:PNode);far;
   begin
    if ANode^.PostOrder>MaxHor
    then MaxHor:=ANode^.Postorder;
   end;
  begin
   if InfoSet^.Count<NodeSet^.Count
   then IsPerfectInfo:=False
   else begin
    MaxHor:=0;
    NodeSet^.ForEach(@FindMaxHorizon);
    if MaxHor>Nodeset^.Count
    then IsPerfectInfo:=False
    else IsperfectInfo:=True;
   end;
  end;
 begin  {MakeGameAudit}
  GameAuditSet^.FreeAll;
  if not TranslatedForm then Exit;    {First check normal form game}
  if (PlayerSet^.Count<1)
  or (NodeSet^.Count<2)
  or (MoveSet^.Count<2)
  then MakeBug(0,nil,nil,nil,nil);
  NodeSet^.ForEach(@CheckDegree);
  MoveSet^.ForEach(@CheckPayoff);
  NodeSet^.ForEach(@CheckChance);
  Outlet.Init(MaxDegree,MaxDegree);
  IsDegenerate:=False;
  MoveSet^.ForEach(@CheckMoveDegenerate);
  RankCollections(False);                  {For payoff condition. Also deletes empty info}
  MoveSet^.ForEach(@MakePayoffArray);
  NodeSet^.ForEach(@ExistSingleFamily);  {Ensure each node has family. Calls CreateSingleton}
  ChoiceSet^.DeleteAll;                {Choices are freed by ConditionChoice for each info}
  InfoSet^.ForEach(@MakeInfoCondition);    {Creates choices and checks one-one condition}
  InfoSet^.ForEach(@CheckChanceInfo);
  InfoSet^.ForEach(@CheckOwners);
  InfoSet^.ForEach(@MakeChoiceSet);        {Fill ChoiceSet from info.choicelist}
  HasBayesianInfo:=False;      {***************** Bayesian check begins ********}
  InfoSet^.ForEach(@MakeAncestors);                                      {*}
  MoveSet^.ForEach(@CheckInfoConnection);                                {*}
  InfoSet^.ForEach(@CheckBayesian);    {**** Bayesian check ends **********}
  if not MakeStartCollection
  then MakeBug(5,nil,nil,nil,nil);
  CheckPerfectInfo;                        {If singletons and no loops only}
  RankCollections(False);                  {To rank choices and singleton infos}
 end;   {MakeGameAudit}

 function TGameType.ShowAudit:PCollection;
 begin
  ShowAudit:=GameAuditSet;
 end;

 function TGameType.CheckEventOwners(AnInfo:PInfo):Boolean;
   procedure CheckNode(ANode:PNode);far;
   begin
    if ANode^.Owner<>AnInfo^.Owner
    then CheckEventOwners:=False;
   end;
 begin
  CheckEventOwners:=True;
  AnInfo^.Event.ForEach(@CheckNode);
 end;

function TGameType.ThirdPlayer:PPlayer;
begin
 if (PlayerSet^.Count>=3)
 then ThirdPlayer:=PlayerSet^.At(2)
 else ThirdPlayer:=nil;
end;

function TGameType.ExistStartNode:Boolean;
{Looks for a non-upto node to serve as start node}
 procedure CheckCandidate(ANode:PNode);far;
 var IsCandidate:Boolean;
  procedure CheckUpto(AMove:PMove);far;
  begin
   if AMove^.Upto=ANode then IsCandidate:=False; {ANode is Upto}
  end;
 begin
  if ANode^.IsBayes then Exit;          {Experiment.. don't start there}
  IsCandidate:=True;
  MoveSet^.ForEach(@CheckUpto);
  if IsCandidate
  then if StartNode=nil
       then StartNode:=ANode        {Have a candidate}
       else ExistStartNode:=False;  {Have too many}
 end;
begin
 StartNode:=nil;
 ExistStartNode:=True;
 NodeSet^.ForEach(@CheckCandidate);
 if StartNode=nil then ExistStartNode:=False;
end;

procedure TGameType.OrderStartNodes;
{var Index:Byte;}
 procedure BeginOrder(ANode:PNode);far;
 begin
  ANode^.SetOrder(False,0);     {SetPreOrder at 0}
  ANode^.SetOrder(True,0);     {SetPreOrder at 0}
 end;
 procedure UpdateOrder(AMove:PMove);far;
 begin
  with AMove^ do
  if Upto<>nil
  then if From^.PostOrder<=Upto^.PreOrder
       then From^.SetOrder(True,Upto^.PreOrder+1); {Set From PostOrder>=Upto PreOrder+1}
 end;
 procedure ResetOrder(ANode:PNode);far;
 begin
  with ANode^ do SetOrder(False,PostOrder); {Reset node PreOrder to PostOrder}
 end;
begin
 ComIndex:=0;
 NodeSet^.ForEach(@BeginOrder);
 repeat
  MoveSet^.ForEach(@UpdateOrder);
  NodeSet^.ForEach(@ResetOrder);
  ComIndex:=ComIndex+1
 until ComIndex>NodeSet^.Count;
end;

procedure TGameType.MakeStartInfoColl;
var Order:Byte;
 procedure ReorderNode(ANode:PNode);far;
 begin
  if ANode^.PostOrder=Order
  then StartInfoColl^.Insert(ANode^.Family);
 end;
begin
 StartInfoColl^.DeleteAll;
 for Order:=0 to MaxNodeNumber           {Arrange StartInfoColl in increasing order}
 do StartNodeColl^.ForEach(@ReorderNode);
end;

function TGameType.MakeStartCollection:Boolean;
{StartNodeColl is made up of singleton info sets}
 procedure CheckSingle(ANode:PNode);far;
 var AFamily:PInfo;
 begin
   FindSingleFamily(ANode,AFamily);
   if AFamily=nil                     {Just for caution}
   then StartNodeColl^.Insert(ANode)
   else if AFamily^.Event.Count<=1
        then StartNodeColl^.Insert(ANode);
 end;
begin
  OrderStartNodes;          {Order all nodes of NodeSet}
  StartNodeColl^.DeleteAll;
  NodeSet^.ForEach(@CheckSingle);
  if StartNodeColl^.Count>0
  then begin
   MakeStartCollection:=True;
   {Now need to reorder the collection from smallest Postorder}
   MakeStartInfoColl;
   if not ExistStartNode
   then StartNode:=StartNodeColl^.At(0);             {EXPERIMENTAL}
  end else MakeStartCollection:=False;
end;

function TGameType.FindSingleFamily(TheNode:PNode;var TheInfo:PInfo):Boolean;
{True if no or single info, false otherwise}
  procedure CheckInfo(AnInfo:PInfo); far;
   procedure Checknode(ANode:PNode); far;
   begin
    if ANode=TheNode
    then if TheInfo=nil
         then TheInfo:=AnInfo
         else FindSingleFamily:=False;
   end;
  begin
   AnInfo^.Event.ForEach(@CheckNode);
  end;
begin
 FindSingleFamily:=True;
 TheInfo:=nil;
 InfoSet^.ForEach(@CheckInfo);
end;

function TGameType.FindMatchingStrategy(TheStrategy:PStrategy):Boolean;
var MatchName:NameType; MatchOwner:PPlayer; {Index:Byte; }
 procedure FindMatch(AStrategy:PStrategy);far;
 begin
  if (StrategySet^.IndexOf(AStrategy)>ComIndex)
  and (StrIComp(MatchName,AStrategy^.ShowName)=0)
  and (AStrategy^.Owner=MatchOwner)
  then FindMatchingStrategy:=True;
 end;
begin
 FindMatchingStrategy:=False;
 StrCopy(MatchName,TheStrategy^.ShowName);
 MatchOwner:=TheStrategy^.Owner;
 ComIndex:=StrategySet^.IndexOf(TheStrategy);
 StrategySet^.ForEach(@FindMatch);
end;

function TGameType.FindMatchingMove(AName:NameType;AFrom:PNode;
                                var TheMove:PMove):Boolean;
 procedure FindMatch(AMove:PMove);far;
 var MatchName:NameType;
 begin
  StrCopy(MatchName,AMove^.ShowName);
  if (StrIComp(MatchName,AName)=0)
  and (AMove^.From=AFrom)
  then if TheMove=nil                 {Match not yet found}
       then TheMove:=AMove            {Match found}
       else FindMatchingMove:=False;  {Too many matches}
 end;
begin
 FindMatchingMove:=True;
 TheMove:=nil;
 MoveSet^.ForEach(@FindMatch);
 if TheMove=nil then FindMatchingMove:=False;
end;

function TGameType.FindOutcome(IsMove:Boolean;AMove:PMove;ACell:PCell;APlayer:PPlayer;
                     var FoundOutcome:POutcome):Boolean;
 procedure MatchAMove(AnOutcome:POutcome); far;
 begin
  with AnOutcome^ do
  if ((Whom=APlayer) or (APlayer=nil))
  then if (Where=AMove)
       then FoundOutcome:=AnOutcome;
 end;
 procedure MatchACell(AnOutcome:POutcome); far;
 begin
  with AnOutcome^ do
  if ((Whom=APlayer) or (APlayer=nil))
  then if (Whence=ACell)
       then FoundOutcome:=AnOutcome;
 end;
begin
 FoundOutcome:=nil;
 if IsMove
 then OutcomeSet^.ForEach(@MatchAMove)
 else OutcomeSet^.ForEach(@MatchACell);
 if FoundOutcome=nil
 then FindOutcome:=False
 else FindOutcome:=True;
end;

procedure TGameType.DumpOutcomes(AMove:PMove);
var TheOutcome:POutcome;
begin
 while FindOutcome(True,AMove,nil,nil,TheOutcome)
 do OutcomeSet^.Free(TheOutcome);
 OutcomeSet^.Pack;
end;

procedure TGameType.SetSolve(ItIs:Boolean);
begin
 IsSolved:=ItIs;
end;

function TGameType.SelectSolution(AMode:Byte):Boolean;
{used in File routines to load, add, or drop solutions}
begin
 SelectSolution:=False;
 CrntEquilSet:=nil;
 case AMode of
   sm_Rational+sm_Pure+sm_Nash              :CrntEquilSet:=NashPureSet;
   sm_Rational+sm_Pure+sm_Perfect           :CrntEquilSet:=PerfPureSet;
   sm_Rational+sm_Explore+sm_Nash           :CrntEquilSet:=NashExplSet;
   sm_Rational+sm_Explore+sm_Perfect        :CrntEquilSet:=PerfExplSet;
   sm_Rational+sm_Explore+sm_Sequential     :CrntEquilSet:=SequExplSet;
   sm_Rational+sm_Sample+sm_Nash            :CrntEquilSet:=NashSampSet;
   sm_Rational+sm_Sample+sm_Perfect         :CrntEquilSet:=PerfSampSet;
   sm_Rational+sm_Sample+sm_Sequential      :CrntEquilSet:=SequSampSet;
   else CrntEquilSet:=nil;
 end;
 if CrntEquilSet<>nil
 then if CrntEquilSet^.Count>0
      then SelectSolution:=True;
end;

procedure TGameType.ConditionChoices(AnInfo:PInfo);
var
 AName      : NameType;
 Coordinate : Byte;
 procedure RecordChoice(AMove:PMove);far;
 var NewChoice : PChoice;
  procedure CheckIfNewChoice(OldChoice:PChoice);far;
  begin
   if (StrIComp(OldChoice^.ShowName,AMove^.ShowName)=0)
   then NewChoice:=OldChoice;
  end;
 begin
  if AMove^.From^.Family<>AnInfo then Exit;
  NewChoice:=nil;
  AnInfo^.ChoiceList.ForEach(@CheckIfNewChoice);
  if NewChoice<>nil then Exit;
  NewChoice:=New(PChoice,Init(AnInfo^.Game));  {Create Choice here}
  StrCopy(AName,AMove^.ShowName);
  NewChoice^.SetName(AName);
  NewChoice^.SetSource(AnInfo);
  NewChoice^.SetBayes(AMove^.IsBayes);    {Experiment.. ensures choicesol of bayes move is not stored}
  AnInfo^.AddChoice(NewChoice);
 end;
 procedure FillChoice(ANode:PNode);far;       {Given node in Info event set}
  procedure MatchMove(AChoice:PChoice);far;   {Given choice info choices}
  var AMove:PMove;
  begin
    StrCopy(AName,AChoice^.ShowName);
    if FindMatchingMove(AName,ANode,AMove)    {Find matching move}
    then AChoice^.AddInstance(AMove)          {Add it to choice instance}
    else MakeBug(9,AChoice,ANode,nil,nil);    {Matching has failed}
  end;
 begin
  AnInfo^.ChoiceList.ForEach(@MatchMove);   {Screen each choice in list}
 end;
 procedure FindFirstRank(AChoice:PChoice);far; {For file purposes only}
  procedure CheckFrom(AMove:PMove);far;
  begin
   if AMove^.From=AChoice^.Source^.FirstNode
   then AChoice^.SetFirstRank(AMove^.Rank);
  end;
 begin
  AChoice^.Instance.ForEach(@CheckFrom);
 end;
 procedure NodeCoordinate(ANode:PNode);far;
 begin
  Coordinate:=Coordinate+1;
  ANode^.SetCoordinate(Coordinate);
 end;
begin {Info condition}
 AnInfo^.ResetFirstNode;
 AnInfo^.ChoiceList.FreeAll;         {Choices are dumped}
 MoveSet^.ForEach(@RecordChoice);
 AnInfo^.Event.ForEach(@FillChoice);  {Screen each node from events}
 AnInfo^.ChoiceList.ForEach(@FindFirstRank);
 Coordinate:=0;
 AnInfo^.Event.ForEach(@NodeCoordinate);
end;

end.
