{Copyright (c), Jean-Pierre P. Langlois, 2007-2022}

unit Game32Type;

interface

uses Windows, SysUtils, Classes, Graphics, Constants, Type32, Matrices;

type

  TGameForm32     = class(TFakeGame)
  protected
  public
    GameState     : Integer;
    GameName      : String;
    IsBacking     : Boolean;
    GameHeader    : TGameObject32;
    PlayerList    : TGameList;
    NodeList      : TGameList; 
    MoveList      : TGameList;
    InfoList      : TGameList;
    PayList       : TGameList;
    ChoiceList    : TGameList;
    BugList       : TGameList;
    EquationList  : TGameList;
    SolutionList  : TGameList;
    SolBitList    : TGameList;
    ProfileList   : TGameList;
    SolGroupList  : TgameList;
    {DepthList     : TGameList;}

    TestList      : TGameList;
    MinMaxList    : TGameList;
    Selection     : TGameList;
    {MinMaxList    : TGameList; }
    StartNode     : TNode32;
    {StartInfo     : TInfo32;}
    XDim,YDim     : Integer;
    IminT,
    IR,
    FullJacob,                {Contains all DChoiceIncentDChoiceProba}
    Expect,
    {DXG,
    DXPTranspose, }
    {TestJacob, }
    Jacobian      : TMatrix;
    FullBeliefs,
    Deviation,
    {Direction,}
    {DeltaX,}
    NodeFrequent,
    InfoFrequent,

    FullIncent,               {Full vectors are for debug}
    {TestProba,
    TestDeviat, }
    FullProba{,
    FullDirect}    : TVector;

    {InitNorm, }
    NextNorm      : Real;
    ABug          : TBug;
    SelRect       : TSelectRect;
    constructor Create;
    destructor Destroy; override;
    procedure SetFileName(AName:String);
    procedure SetBacking(DoBack:Boolean);
    {File operations}
    procedure DispatchObject(AnObject:TGameObject32);
    procedure ResetNodes;
    procedure ResetMoves;
    procedure ResetTables;
    procedure DeleteSingletons(GhostsOnly:Boolean);
    procedure FixBayesianInfos;
    function ResetInfos(ForSolving:Boolean):Boolean;
    procedure ResetRanks;
    procedure ResetPayoffs;
    procedure UpdateDim(AnObject:TGameObject32);
    procedure ResetTies;
    procedure ResetSolutions;

    {Initializing}
    {procedure Makelevels; }
    procedure MakeChoices;
    procedure MakePayments;
    procedure DepthSearch(ANode:TNode32;ADepth:Integer);
    procedure MakeNodeDepths;
    procedure MakeInfoDepths;
    function MakeStartNode:Boolean;
    {Game checking}
    function FindConnectedNode:TNode32;
    function CheckConnected:Boolean;
    function CheckChoices: Boolean;
    function CheckDegrees: Boolean;
    function CheckPayments: Boolean;
    function CheckChances: Boolean;
    function CheckGame: Boolean;
    procedure MakeBug(AString:String);

    function FindEstimate(AnObject:TGameObject32;IsMax:Boolean;APlayer:TPlayer32):TPayoff32;
    procedure EstimateMoves;
    function EstimateInfos:Boolean;
    procedure EstimateChoices;
    procedure EliminateDominatedChoices;

    {for testing}
    {procedure ShowBeliefs;
    procedure ShowIncentives;  }

    procedure ReturnToEdit;
    procedure DisAssociate;
    procedure SwitchAssociates;
    procedure SetState(AState:Integer);
    function HasSelection:Boolean;
    procedure DeleteSelection;
    procedure CopySelection;
    procedure DrawGame(ACanvas:TCanvas);
  end;

implementation

uses SolvOptDlg, Game32Solve;

constructor TGameForm32.Create;
begin
  inherited Create;
  GameState:=gs_CanClose;
  XDim:=gp_Horz*GridStep; {Default}
  YDim:=gp_Vert*GridStep;

  GameHeader:=TGameObject32.Create(Self);
  GameHeader.SetPosition(50,50);
  SelRect:=TSelectRect.Create(Self);

  PlayerList:=TGameList.Create;
  NodeList:=TGameList.Create;
  MoveList:=TGameList.Create;
  InfoList:=TGameList.Create;
  PayList:=TGameList.Create;
  ChoiceList:=TGameList.Create;
  Selection:=TGameList.Create;
  BugList:=TGameList.Create;

  {StartList:=TGameList.Create;}

  SolGroupList:=TGameList.Create;
  ProfileList:=TGameList.Create;
  SolutionList:=TGameList.Create;
  SolBitList:=TGameList.Create;
  EquationList:=TGameList.Create;
  {DepthList:=TGameList.Create; }

  TestList:=TGameList.Create;
  MinMaxList:=TGameList.Create;

  IminT:=nil;
  IR:=nil;
  Expect:=nil;
  FullJacob:=nil;
  Jacobian:=nil;
  FullBeliefs:=nil;
  Deviation:=nil;
  NodeFrequent:=nil;
  InfoFrequent:=nil;
  FullIncent:=nil;
  FullProba:=nil;

  {TestDeviat:=nil;
  TestProba:=nil;}
  {FullDirect:=nil;}
  {TestJacob:=nil;}
  {Direction:=nil;}
  {DeltaX:=nil; }
end;

destructor TGameForm32.Destroy;
begin
  GameHeader.Free;
  SelRect.Free;

  {PlayerList.FreeAll(ot_All);
  NodeList.FreeAll(ot_All);
  PayList.FreeAll(ot_All);
  ChoiceList.FreeAll(ot_All);
  MoveList.FreeAll(ot_All);
  InfoList.FreeAll(ot_All);
  SolutionList.FreeAll(ot_All);
  SolBitList.FreeAll(ot_All);
  ProfileList.FreeAll(ot_All);
  SolGroupList.FreeAll(ot_All);

  MinMaxList.FreeAll(ot_All);
  BugList.FreeAll(ot_All);
  TestList.FreeAll(ot_All);
  {DepthList.FreeAll(ot_All);}

  TGameType32(Self).CleanUp;

  EquationList.Clear; {Don't destroy choices here}

  PlayerList.Free;
  NodeList.Free;
  MoveList.Free;
  InfoList.Free;
  PayList.Free;
  ChoiceList.Free;
  Selection.Free;
  BugList.Free;

  ProfileList.Free;
  SolGroupList.Free;
  SolutionList.Free;
  SolBitList.Free;

  EquationList.Free;

  MinMaxList.Free;
  TestList.Free;

  {DepthList.Free;}

  {StartList.Clear;
  StartList.Free;}

  inherited Destroy;
end;

procedure TGameForm32.SetFileName(AName:String);
begin
  GameName:=AName;
  SetBacking(True);
end;

procedure TGameForm32.SetBacking(DoBack:Boolean);
begin
  if DoBack
  then IsBacking:=True
  else IsBacking:=False;
end;

{File operations}

procedure TGameForm32.DispatchObject(AnObject:TGameObject32);
begin
  case AnObject.ObjType of
    ot_Header   : begin
                    if (GameHeader<>nil) then GameHeader.Free;
                    GameHeader:=AnObject; 
                  end; {else will be solution}
    ot_Player   : PlayerList.Add(AnObject);
    ot_Table    : NodeList.Add(AnObject);
    ot_Side     : InfoList.Add(AnObject);
    ot_Strat    : ChoiceList.Add(AnObject);
    ot_Node     : NodeList.Add(AnObject);
    ot_Move     : MoveList.Add(AnObject);
    ot_Cell     : MoveList.Add(AnObject);
    ot_Info     : InfoList.Add(AnObject);
    ot_Payoff   : PayList.Add(AnObject);
    ot_Solution : SolutionList.Add(AnObject);
    ot_Belief,
    ot_Proba,
    ot_Incent,
    ot_Expect,
    ot_StrProb,
    ot_StrInct  : SolBitList.Add(AnObject);
  end;
  UpdateDim(AnObject);
end;

procedure TGameForm32.ResetSolutions;
  procedure ResetBitType(ASolBit:TSolutionBit);
  begin
    ASolBit.Restore;
  end;
begin
  if (SolutionList.Count>0) and (SolBitList.Count>0) then begin
    SolBitList.ForEach(@ResetBitType);
    SolBitList.Clear;
    SetState(gs_SavSol);
  end else SetState(gs_CanClose);
end;

procedure TGameForm32.ResetNodes;
  procedure RestoreNode(ANode:TNode32);
  begin
    ANode.Restore; {Restore owner and family}
  end;
begin
  NodeList.ForEach(@RestoreNode);
end;

procedure TGameForm32.ResetMoves;
  procedure RestoreMove(AMove:TMove32);
  begin
    AMove.Restore; {Restore from and upto}
  end;
begin
  MoveList.ForEach(@RestoreMove);
end;

procedure TGameForm32.ResetTables;
  procedure SideReset(ASide:TInfo32);
  begin
    if ASide.ObjType=ot_Side then 
    TSide32(ASide).ResetSide; {Owner  and table}
  end;
  procedure StratReset(AStrat:TStrat32);
  begin
    AStrat.Restore; {Find its side and adds itself to side.choices}
  end;
  procedure CellReset(ACell:TMove32);
  begin
    if ACell.ObjType=ot_Cell
    then TCell32(ACell).ResetCell;
  end;
  procedure Reposition(ATable:TNode32);
  begin
    if ATable.ObjType=ot_Table then with TTable32(ATable) do begin
      SidesToCells;
      RedoGraphics;
      RestoreCells; {Into the celllist. Useless if cells are loaded}
    end;
  end;
begin
  InfoList.ForEach(@SideReset);
  ChoiceList.ForEach(@StratReset);
  ChoiceList.FreeAll(ot_Unclean);
  MoveList.ForEach(@CellReset);
  MoveList.FreeAll(ot_Unclean);
  NodeList.ForEach(@Reposition);
end;

procedure TGameForm32.DeleteSingletons(GhostsOnly:Boolean);
  procedure FindGhost(AnInfo:TInfo32);
  begin
    with AnInfo do if ObjType=ot_Info then case Events.Count of
      0 : SetUnclean;
      1 : if not GhostsOnly then SetUnclean;
    end;
  end;
begin {DeleteGhosts}
  InfoList.ForEach(@FindGhost);
  InfoList.FreeAll(ot_Unclean);
end;

procedure TGameForm32.FixBayesianInfos;
  procedure FixIfBayesian(AnInfo:TInfo32);
  begin
    if AnInfo.ObjType=ot_Info then {To avoid fixing sides}
    with AnInfo do if not IsSingleton then FixBayesian; {Adds artificial node}
  end;
begin
  InfoList.ForEach(@FixIfBayesian);
end;

function TGameForm32.ResetInfos(ForSolving:Boolean):Boolean;
  procedure AddSingleton(ANode:TNode32);
  begin
    with ANode do if ObjType=ot_Node then begin {Ignores tables}
      MakeSingleton;
      if IsArtificial and (Family.ObjType=ot_Info)
      then Family.SetArtificial(True); {For choice association}
    end;
  end;
  procedure ResetEvents(AnInfo:TInfo32);
  begin
    if not AnInfo.Restore then begin
      ResetInfos:=False;
      MakeBug('Unreachable node at '+AnInfo.Description(fw_Audit));
    end;
  end;
  procedure ResetTarget(AnInfo:TInfo32);
  var Outlet:TMove32;
    procedure FindAnOutlet(AMove:TMove32);
    begin
      if AMove.From.Family=AnInfo
      then Outlet:=AMove;
    end;
  begin
    if AnInfo.IsArtificial then begin
      Outlet:=nil;
      MoveList.ForEach(@FindAnOutlet);
      if Outlet<>nil
      then if Outlet.Upto<>nil
           then AnInfo.SetTarget(Outlet.Upto.Family);
    end;
  end;
begin
  ResetInfos:=True;
  InfoList.ForEach(@ResetEvents);
  DeleteSingletons(ForSolving); {free useless infos if solving. Ignores sides}
  if ForSolving then begin

    FixBayesianInfos; 

    NodeList.ForEach(@AddSingleton);
    InfoList.ForEach(@ResetTarget);
  end;
end;

procedure TGameForm32.ResetRanks;
  procedure ResetRank(AnObject:TGameObject32);
  begin
    AnObject.ResetRank;
  end;
begin
  PlayerList.ForEach(@ResetRank);
  NodeList.ForEach(@ResetRank);
  MoveList.ForEach(@ResetRank);
  InfoList.ForEach(@ResetRank);
  ChoiceList.ForEach(@ResetRank);
end;

procedure TGameForm32.ResetPayoffs;
  procedure ResetAPayoff(APayoff:TPayoff32);
  begin
    APayoff.Restore;
  end;
begin
  PayList.ForEach(@ResetAPayoff)
end;

procedure TGameForm32.UpdateDim(AnObject:TGameObject32);
begin
  with AnObject do begin
    if XPos>=XDim then XDim:=XPos+GridStep;
    if YPos>=YDim then YDim:=YPos+GridStep;
  end;
end;

procedure TGameForm32.ResetTies;
begin {Reconstruct ties between objects from ranks right after loading from file}
  ResetNodes;
  ResetMoves;
  ResetInfos(False);
  ResetTables;
  ResetPayoffs;
  ResetSolutions;
end;

{procedure TGameForm32.MakeLevels;
var ALevBit:TSolutionBit; NoChange:Boolean;
  procedure UpdateMoveLevel(AMove:TMove32);
  begin
    if AMove.Upto<>nil then AMove.SetLevel(AMove.Upto.Level);
  end;
  procedure UpdateNodeLevel(ANode:TNode32);
    procedure CheckLevel(AMove:TMove32);
    begin
      if AMove.From=ANode
      then if (ANode.Level<AMove.Level+1) and (ANode.Level<=NodeList.Count)
           then begin
             ANode.Level:=AMove.Level+1;
             NoChange:=False;
           end;
    end;
  begin
    MoveList.ForEach(@CheckLevel);
  end;
  procedure UpdateInfoLevel(AnInfo:TInfo32);
    procedure FindLevel(ANode:TNode32);
    begin
      if ANode.Level>AnInfo.Level then AnInfo.Level:=ANode.Level;
    end;
  begin
    AnInfo.Events.ForEach(@FindLevel);
  end;
  procedure UpdateLevel(AnObject:TGameObject32);
  begin
    Case AnObject.ObjType of
      ot_Move: UpdateMoveLevel(TMove32(AnObject));
      ot_Node: UpdateNodeLevel(TNode32(AnObject));
      ot_Info: UpdateInfoLevel(TInfo32(AnObject));
    end;
  end;
  procedure AddLevel(ANode:TNode32);
  begin
    if ANode.IsArtificial then Exit;
    ALevBit:=TSolutionBit.Create(Self);
    ALevBit.SetData(ot_Level,nil,ANode,nil,ANode.Family.Level);
    DepthList.Add(ALevBit);
  end;
begin
  repeat
    NoChange:=True;
    MoveList.ForEach(@UpdateLevel);
    Nodelist.ForEach(@UpdateLevel);
  until NoChange;
  InfoList.ForEach(@UpdateLevel);
  NodeList.ForEach(@AddLevel);  {Only for display
end; }

procedure TGameForm32.MakeChoices;
  procedure AddAChoice(AMove:TMove32);
  begin
    AMove.MakeChoice; {Re-defines OwnChoice and adds it to Source.Choices}
  end;
  procedure SetNilChoice(AMove:TMove32);
  begin
    with AMove do if OwnChoice<>nil  {Ignore strategies}
                  then if OwnChoice.ObjType=ot_Choice
                       then SetChoice(nil);
  end;
begin
  MoveList.ForEach(@SetNilChoice);
  ChoiceList.FreeAll(ot_Choice);  {Destroy choices and clears choicelist}
  MoveList.ForEach(@AddAChoice);
end;

procedure TGameForm32.MakePayments;
  procedure AddPayments(AMove:TMove32);
  begin
    AMove.ResetPayments;
  end;
begin
  MoveList.ForEach(@AddPayments);
end;

{Auditing and solving routines}

procedure TGameForm32.DepthSearch(ANode:TNode32;ADepth:Integer);
  procedure SearchNextNode(AMove:TMove32);
  begin
    with AMove do
    if From=ANode
    then if Upto<>nil
         then if not Upto.IsActive
              then DepthSearch(Upto,ADepth+1);
  end;
begin
  ANode.SetActive(True);
  if ADepth>ANode.Depth then ANode.SetDepth(ADepth);
  MoveList.ForEach(@SearchNextNode);
  ANode.SetActive(False);
end;

procedure TGameForm32.MakeNodeDepths;
var MinDepth:Integer;
  procedure InitDepth(ANode:TNode32);
  begin
    ANode.SetDepth(0);
    ANode.SetActive(False);
  end;
  procedure StartSearch(ANode:TNode32);
  begin
    if ANode.Family=nil
    then DepthSearch(ANode,0);
  end;
  procedure FindMinDepth(ANode:TNode32);
  begin
    if ANode.Depth<MinDepth then MinDepth:=ANode.Depth;
  end;
  procedure AdjustDepth(ANode:TNode32);
  begin
    with ANode do SetDepth(Depth-MinDepth);
  end;
  {procedure ShowResults(ANode:TNode32);
  begin
    ANode.SetName(IntToStr(ANode.Depth));
  end; }
begin
  NodeList.ForEach(@InitDepth);
  NodeList.ForEach(@StartSearch);
  MinDepth:=MaxInteger;
  NodeList.ForEach(@FindMinDepth);
  NodeList.ForEach(@AdjustDepth);

  {NodeList.ForEach(@ShowResults);  }
end;

procedure TGameForm32.MakeInfoDepths; {Min depth of events}
var {ADepBit:TSolutionBit;} MaxInfoDepth:Integer;
  procedure FindMaxDepth(ANode:TNode32);
  begin
    if ANode.Depth>MaxInfoDepth then MaxInfoDepth:=ANode.Depth;
  end;
  procedure UpdateInfoDepth(AnInfo:TInfo32);
    procedure FindEventDepth(ANode:TNode32);
    begin
      if ANode.Depth<AnInfo.Depth then AnInfo.Depth:=ANode.Depth;
    end;
  begin
    AnInfo.SetDepth(MaxInfoDepth);
    AnInfo.Events.ForEach(@FindEventDepth);
  end;
  {procedure AddDepBit(ANode:TNode32);
  begin
    if ANode.IsArtificial then Exit;
    ADepBit:=TSolutionBit.Create(Self);
    ADepBit.SetData(ot_Depth,nil,ANode,nil,ANode.Family.Depth);
    DepthList.Add(ADepBit);
  end;}
begin
  MaxInfoDepth:=0;
  NodeList.ForEach(@FindMaxDepth);
  InfoList.ForEach(@UpdateInfoDepth);

  {NodeList.ForEach(@AddDepBit);  {Only for display }
end;


function TGameForm32.MakeStartNode:Boolean; {One with Depth=0}
  procedure CheckIfZeroDepth(ANode:TNode32);
  begin
    if StartNode=nil then if ANode.Depth=0 then StartNode:=ANode;
  end;
begin
  StartNode:=nil;
  NodeList.ForEach(@CheckIfZeroDepth);
  if StartNode=nil
  then MakeStartNode:=False
  else MakeStartNode:=True;
end;

{Game audit routines}

function TGameForm32.FindConnectedNode:TNode32; {Used only by CheckConnected}
  procedure CheckIfConnected(ANode:TNode32);
    procedure FindConnection(AMove:TMove32);
    begin
      with AMove do if (Upto=nil) then Exit
      else if ((From=ANode) and Upto.IsActive)
           or (From.IsActive and (Upto=ANode))
           then begin
             ANode.SetActive(True);
             FindConnectedNode:=ANode;
           end;
    end;
  begin
    if not ANode.IsActive then MoveList.ForEach(@FindConnection);
  end;
begin
  FindConnectedNode:=nil;
  NodeList.ForEach(@CheckIfConnected);
end;

function TGameForm32.CheckConnected:Boolean; {Check the game is connected}
  procedure SetInactive(ANode:TNode32);
  begin
    ANode.SetActive(False); {IsActive is used as IsConnected}
  end;
  procedure FindUnconnected(ANode:TNode32);
  begin
    if not ANode.IsActive then begin
      CheckConnected:=False;
      MakeBug(ANode.Description(fw_Audit)+' is not connected');
    end;
  end;
begin
  NodeList.ForEach(@SetInactive);
  if StartNode<>nil then begin
    StartNode.SetActive(True);
    repeat {} until FindConnectedNode=nil;
    CheckConnected:=True;
    NodeList.ForEach(@FindUnconnected);
  end else CheckConnected:=False;
  NodeList.ForEach(@SetInactive);
end;

function TGameForm32.CheckChoices: Boolean;
var ChoiceCheck: Boolean;
  procedure CheckChoice(AChoice:TChoice32);
  begin
    if not AChoice.CheckInstances
    then begin
      ChoiceCheck:=False;
      MakeBug('Move mismatch at '+AChoice.Description(fw_Audit));
    end;
  end;
begin
  ChoiceCheck:=True;
  ChoiceList.ForEach(@CheckChoice);
  CheckChoices:=ChoiceCheck;
end;

function TGameForm32.CheckDegrees: Boolean;
var DegreeCheck: Boolean;
  procedure CheckDegree(ANode:TNode32);
  begin
    if ANode.ShowDegree>MaxNodeDegree
    then begin
      DegreeCheck:=False;
      MakeBug('Too many moves at '+ANode.Description(fw_Audit));
    end;
    if (ANode.Family=nil) then Exit;
    if (ANode.Family.ShowFirstDegree<>ANode.ShowDegree)
    then begin
      DegreeCheck:=False;
      MakeBug('Wrong degree at '+ANode.Description(fw_Audit));
    end;
  end;
begin
  DegreeCheck:=True;
  NodeList.ForEach(@CheckDegree);
  CheckDegrees:=DegreeCheck;
end;

function TGameForm32.CheckPayments: Boolean;
  procedure CheckFinalPay(AMove:TMove32);
  begin
    with AMove do
    if (Upto=nil) and MissEndPay
    then begin
      CheckPayments:=False;
      MakeBug('Payoff missing at '+AMove.Description(fw_Audit));
    end;
  end;
  procedure CheckMovePay(APay:TPayoff32);
  var PayStr:String;
  begin
    with APay do
    if (Where=nil) then begin
      CheckPayments:=False;
      PayStr:=FloatToStr(Value);
      MakeBug('Payoff '+PayStr+' is unattached.')
    end;
  end;
begin
  CheckPayments:=True;
  MoveList.ForEach(@CheckFinalPay);
  PayList.ForEach(@CheckMovePay);
end;

function TGameForm32.CheckChances: Boolean;
  procedure CheckChanceProba(ANode:TNode32);
  begin
    if not ANode.CheckChance
    then begin
      CheckChances:=False;
      MakeBug('Wrong chance probabilities at '+ANode.Description(fw_Audit));
    end;
  end;
begin
  CheckChances:=True;
  NodeList.ForEach(@CheckChanceProba);
end;

function TGameForm32.FindEstimate(AnObject:TGameObject32;IsMax:Boolean;APlayer:TPlayer32):TPayoff32;
var AnEstimate:TSolutionBit;
begin
  {FindEstimate:=nil;
  if AnObject.IsArtificial then Exit;  Needs further testing******************}
  AnEstimate:=TSolutionBit(AnObject.ShowEstimate(IsMax,APlayer));
  if AnEstimate=nil then begin  {Creates Estimate if does not exist}
    AnEstimate:=TSolutionBit.Create(Self);
    if IsMax
    then AnEstimate.SetData(ot_Max,nil,AnObject,APlayer,-MaxAbsValue)
    else AnEstimate.SetData(ot_Min,nil,AnObject,APlayer,MaxAbsValue);
    MinMaxList.Add(AnEstimate);
  end;
  FindEstimate:=AnEstimate;
end;

procedure TGameForm32.EstimateMoves;
var NoChange,IsEstimable:Boolean;
    AMax,AMin,AnEst: TSolutionBit; APay,AVal:Real;
    CrntMax,CrntMin:Real; RepeatIndex:Integer;
  procedure UpdateNodeEstimate(ANode:TNode32);
    procedure CheckIfEstimable(AMove:TMove32);
    begin
      with AMove do begin
        if (From<>ANode) then Exit;
        if IsDominated then Exit;
        if not IsEstimated then IsEstimable:=False;
      end;
    end;
    procedure UpdateEstimate(APlayer:TPlayer32);
      procedure CheckEstimateMoves(AMove:TMove32);
      begin
        if AMove.From<>ANode then Exit;
        if AMove.IsDominated then Exit;
        AnEst:=TSolutionBit(FindEstimate(AMove,True,APlayer));
        if AnEst<>nil then with AnEst
        do if Value>CrntMax then CrntMax:=Value;
        AnEst:=TSolutionBit(FindEstimate(AMove,False,APlayer));
        if AnEst<>nil then with AnEst
        do if Value<CrntMin then CrntMin:=Value;
      end;
      procedure AddEstimateMoves(AMove:TMove32);
      begin
        if AMove.From<>ANode then Exit;
        AnEst:=TSolutionBit(FindEstimate(AMove,True,APlayer));
        if AnEst<>nil then CrntMax:=CrntMax+AnEst.Value;
        AnEst:=TSolutionBit(FindEstimate(AMove,False,APlayer));
        if AnEst<>nil then CrntMin:=CrntMin+AnEst.Value;
      end;
    begin
      AMax:=TSolutionBit(FindEstimate(ANode,True,APlayer));
      AMin:=TSolutionBit(FindEstimate(ANode,False,APlayer));
      if ANode.Owner=nil
      then begin
        CrntMax:=0;
        CrntMin:=0;
        MoveList.ForEach(@AddEstimateMoves)
      end else begin
        CrntMax:=-MaxAbsValue;
        CrntMin:=MaxAbsValue;
        MoveList.ForEach(@CheckEstimateMoves);
      end;
      if (AMax.Value<>CrntMax) or (AMin.Value<>CrntMin) then NoChange:=False;
      AMax.SetData(ot_Max,nil,ANode,APlayer,CrntMax);
      AMin.SetData(ot_Min,nil,ANode,APlayer,CrntMin);
    end;
  begin
    {if ANode.IsArtificial then Exit;} {Would prevent artificial node estimate in table}
    IsEstimable:=True;
    if not ANode.IsEstimated then MoveList.ForEach(@CheckIfEstimable);
    if IsEstimable then begin
      PlayerList.ForEach(@UpdateEstimate);
      ANode.SetEstimated(True);
    end;
  end;
  procedure UpdateMoveEstimate(AMove:TMove32);
    procedure CheckPlayerEstimate(APlayer:TPlayer32);
    begin
      with AMove do begin
        if ShowPayment(APlayer)=nil then APay:=0 else APay:=ShowPayment(APlayer).Value;
        if From.Owner=nil then APay:=Discount*APay;  {Chance moves are pre-discounted}
        AMax:=TSolutionBit(FindEstimate(AMove,True,APlayer)); {Can't be nil}
        if Upto=nil then AnEst:=nil else AnEst:=TSolutionBit(Upto.ShowEstimate(True,APlayer));
        if AnEst=nil then AVal:=APay else AVal:=APay+Discount*AnEst.Value;
        AMax.SetData(ot_Max,nil,AMove,APlayer,AVal);
        AMin:=TSolutionBit(FindEstimate(AMove,False,APlayer));
        if Upto=nil then AnEst:=nil else AnEst:=TSolutionBit(Upto.ShowEstimate(False,APlayer));
        if AnEst=nil then AVal:=APay else AVal:=APay+Discount*AnEst.Value;
        AMin.SetData(ot_Min,nil,AMove,APlayer,AVal);
      end;
    end;
  begin
    {if AMove.IsArtificial then Exit; {Would prevent artificial move estimate in table}
    if AMove.IsDominated then Exit; {Estimating dominated moves produces dflt}
    with AMove do if (Upto<>nil) then if not Upto.IsEstimated then Exit;
    {Ensures either Upto=nil or non-nil Upto has been estimated}
    PlayerList.ForEach(@CheckPlayerEstimate);
    AMove.SetEstimated(True);
  end;
  procedure UpdateMinMax(AMove:TMove32);
  begin
    if AMove.From.Owner=nil then Exit;
    AMax:=TSolutionBit(FindEstimate(AMove,True,AMove.From.Owner));
    if AMax<>nil then AMove.SetEstimate(True,AMax.Value);
    AMin:=TSolutionBit(FindEstimate(AMove,False,AMove.From.Owner));
    if AMin<>nil then AMove.SetEstimate(False,AMin.Value);
  end;
begin
  RepeatIndex:=0;
  repeat
    NoChange:=True;
    MoveList.ForEach(@UpdateMoveEstimate);
    NodeList.ForEach(@UpdateNodeEstimate);
    RepeatIndex:=RepeatIndex+1;
  until NoChange or (RepeatIndex>=MoveList.Count);
  MoveList.ForEach(@UpdateMinMax); {Records MinMax into the Move attributes}
end;

procedure TGameForm32.EstimateChoices;
{var AMax,AMin,AnEst: TSolutionBit;}
  procedure EstimateAChoice(AChoice:TChoice32);
  begin
    AChoice.Estimate;
    {AMax:=TSolutionBit(FindEstimate(AChoice,True,AChoice.Source.Owner));
    AMin:=TSolutionBit(FindEstimate(AChoice,False,AChoice.Source.Owner));
    AMax.SetValue(AChoice.MaxEstimate);
    AMin.SetValue(AChoice.MinEstimate); {Used for checking}
  end;
  {procedure UpdateFromChoice(AMove:TMove32);
  begin
    if AMove.IsArtificial then Exit;
    with AMove do if OwnChoice.IsEstimated then begin
      AMax:=TSolutionBit(FindEstimate(AMove,True,AMove.From.Owner));
      if AMax<>nil then begin
        AnEst:=TSolutionBit(OwnChoice.ShowEstimate(True,AMove.From.Owner));
        if AnEst<>nil then AMax.SetData(ot_Max,nil,AMove,AMove.From.Owner,AnEst.Value)
                      else AMax.SetData(ot_Max,nil,AMove,AMove.From.Owner,dfltMax);
      end;
      AMin:=TSolutionBit(FindEstimate(AMove,False,AMove.From.Owner));
      if AMin<>nil then begin
        AnEst:=TSolutionBit(OwnChoice.ShowEstimate(False,AMove.From.Owner));
        if AnEst<>nil then AMin.SetData(ot_Min,nil,AMove,AMove.From.Owner,AnEst.Value)
                      else AMin.SetData(ot_Min,nil,AMove,AMove.From.Owner,dfltMax);
      end;
    end;
  end; }
begin
  ChoiceList.ForEach(@EstimateAChoice);
  {MoveList.ForEach(@UpdateFromChoice); {For checking only}
end;

function TGameForm32.EstimateInfos:Boolean;
  procedure EstimateAnInfo(AnInfo:TInfo32);
  begin
    AnInfo.Estimate;
  end;
  procedure CheckEliminable(AChoice:TChoice32);
    procedure SetDominatedMove(AMove:TMove32);
    begin
      AMove.SetDominated(True);
    end;
  begin
    if AChoice.IsDominated then Exit;
    with AChoice do
    if IsInfoMin then begin
      SetDominated(True);
      Instances.ForEach(@SetDominatedMove);
      EstimateInfos:=True; {Signal elimination is not finished}
    end;
  end;
begin
  EstimateInfos:=False;
  InfoList.ForEach(@EstimateAnInfo);
  ChoiceList.ForEach(@CheckEliminable);
end;

procedure TGameForm32.EliminateDominatedChoices;
var  RepeatIndex:Integer;
  procedure ResetDomination(AnObject:TGameObject32);
  begin
    AnObject.SetEstimated(False);
    AnObject.SetDominated(False);
  end;
begin
  MoveList.ForEach(@ResetDomination);
  NodeList.ForEach(@ResetDomination);
  ChoiceList.ForEach(@ResetDomination);
  InfoList.ForEach(@ResetDomination);
  RepeatIndex:=0;
  repeat
    EstimateMoves;
    EstimateChoices;
  until (not EstimateInfos) or (RepeatIndex>=MoveList.Count);
  MinMaxList.FreeAll(ot_All); {Repositioned at end}
end;


function TGameForm32.CheckGame:Boolean;
  procedure ConvertTable(ATable:TNode32);
  begin
    if ATable.ObjType=ot_Table
    then TTable32(ATable).ConvertToGraph;
  end;
begin
  CheckGame:=True;
  BugList.FreeAll(ot_All);

  NodeList.ForEach(@ConvertTable);

  MakeNodeDepths;
  if not MakeStartNode then CheckGame:=False;
  if not CheckConnected then CheckGame:=False;

  if not ResetInfos(True) then CheckGame:=False; {After editing, some singleton nodes may lack family}
  MakeInfoDepths;
  {if not MakeStartList then CheckGame:=False;}
  MakeChoices;      {Must have called ResetInfos to clear Choices}
  ResetRanks;       {Reset all object ranks}
  MakePayments;     {Refill Payments (payoff) list in each move}

  {MakeLevels; }
  if not CheckChoices then CheckGame:=False;
  if not CheckDegrees then CheckGame:=False;
  if not CheckPayments then CheckGame:=False;
  if not CheckChances then CheckGame:=False;

  EliminateDominatedChoices; 

end;

procedure TGameForm32.MakeBug(AString:String);
begin
  ABug:=TBug.Create(Self);
  ABug.SetName(AString);
  BugList.Add(ABug);
end;

procedure TGameForm32.ReturnToEdit;
  procedure SetToDump(AnObject:TGameObject32);
  begin
    with AnObject do if IsArtificial
    and ((ObjType=ot_Node) or (ObjType=ot_Move)) then SetUnclean;
  end;
  procedure RemoveEvents(AnInfo:TInfo32);
  begin
    with AnInfo do if ObjType=ot_Side then Events.Clear;
  end;
  procedure RemoveCellFrom(ACell:TMove32);
  begin
    with ACell do if ObjType=ot_Cell then SetFrom(nil);
  end;
  procedure EmptyInstances(AChoice:TChoice32);
    procedure SetNilChoice(AMove:TMove32);
    begin
      AMove.SetChoice(nil);
    end;
  begin
    with AChoice.Instances do begin
      ForEach(@SetNilChoice);
      Clear;
    end;
  end;
begin
  ProfileList.FreeAll(ot_All);
  SolGroupList.FreeAll(ot_All);
  SolutionList.FreeAll(ot_All);
  SolBitList.FreeAll(ot_All);
  ChoiceList.ForEach(@EmptyInstances); {Deassociate strategies and cells}
  ChoiceList.FreeAll(ot_Choice);       {Preserve strategies}
  DeleteSingletons(False);
  InfoList.ForEach(@RemoveEvents);     {Empty sides}
  MoveList.ForEach(@SetToDump);        {Remove artificial nodes and moves..}
  NodeList.ForEach(@SetToDump);
  MoveList.FreeAll(ot_Unclean);
  NodeList.FreeAll(ot_Unclean);
  MoveList.ForEach(@RemoveCellFrom);   {Set all cell from to nil}
  SetState(gs_CanClose);
end;

procedure TGameForm32.SetState(AState:Integer);
begin
  if AState=gs_CanClose
  then GameState:=gs_CanClose
  else if GameState<>gs_New    {A new game remains new unless saved}
       then GameState:=AState;
end;

function TGameForm32.HasSelection:Boolean;
  procedure FindSelected(AnObject:TGameObject32);
  begin
    with AnObject do if IsInRect(SelRect.ShowRect)
    and ((ObjType=ot_Node) or (ObjType=ot_Table) {or (ObjType=ot_Player)}
          or (ObjType=ot_Move) or (ObjType=ot_Info))
    then begin
      Selection.Add(AnObject);
      AnObject.SetOrigin(SelRect.XPos,SelRect.YPos);
    end;
  end;
begin
  Selection.Clear;
  PlayerList.ForEach(@FindSelected);
  NodeList.ForEach(@FindSelected);
  MoveList.ForEach(@FindSelected);
  InfoList.ForEach(@FindSelected);
  if Selection.Count>0 then HasSelection:=True else HasSelection:=False;
end;

procedure TGameForm32.DeleteSelection;
  procedure DeleteMoves(AnObject:TGameObject32);
  begin
    with AnObject do
    if (ObjType=ot_Move) then SetUnClean;
  end;
  procedure UnSelect(AnObject:TGameObject32);
  begin
    if AnObject.ObjType=ot_UnClean
    then Selection.Remove(AnObject);
  end;
  procedure DeleteNodes(AnObject:TGameObject32);
  begin
    with AnObject do if CanDelete
    then if (ObjType=ot_Node) or (ObjType=ot_Table)
         then begin
           if (ObjType=ot_Node) then TNode32(AnObject).Disconnect;
           SetUnClean;
           {if TNode32(AnObject).Family<>nil
           then TNode32(AnObject).Family.Events.Remove(AnObject);}
         end;
  end;
begin
  Selection.ForEach(@DeleteMoves);
  MoveList.ForEach(@UnSelect);
  MoveList.FreeAll(ot_UnClean);
  Selection.ForEach(@DeleteNodes);
  NodeList.ForEach(@UnSelect);
  NodeList.FreeAll(ot_UnClean);
  DeleteSingletons(False);
  Selection.Clear;
  SelRect.SetArtificial(True);
  SetState(gs_Edited);
end;

procedure TGameForm32.DisAssociate;
  procedure SetNilAssociate(AnObject:TGameObject32);
  begin
    AnObject.SetAssociate(nil);
  end;
begin
  PlayerList.ForEach(@SetNilAssociate);
  NodeList.ForEach(@SetNilAssociate);
  InfoList.ForEach(@SetNilAssociate);
  MoveList.ForEach(@SetNilAssociate);
  ChoiceList.ForEach(@SetNilAssociate);
end;

procedure TGameForm32.SwitchAssociates;
  procedure ReSelect(AnObject:TGameObject32);
  begin
    if (AnObject.ObjType=ot_Side)
    or (AnObject.ObjType=ot_Cell)
    {or (AnObject.ObjType=ot_Choice)}
    or (AnObject.Associate=nil) then Exit;
    AnObject.Associate.SetOrigin(SelRect.XPos+CopySize,SelRect.YPos+CopySize);
    AnObject.Associate.SetName(AnObject.Name);
    Selection.Add(AnObject.Associate);
  end;
begin
  Selection.Clear;
  NodeList.ForEach(@ReSelect);
  InfoList.ForEach(@ReSelect);  {Beware Sides..}
  MoveList.ForEach(@ReSelect);  {Beware Cells}
end;

procedure TGameForm32.CopySelection;
  procedure CopyNodes(AnObject:TGameObject32);
  var ANode:TNode32;
  begin
    with AnObject do if (ObjType=ot_Node) {or (ObjType=ot_Table)}
    then begin
      ANode:=TNode32.Create(Self);
      ANode.Assign(TNode32(AnObject));
      TNode32(AnObject).SetAssociate(ANode);
      NodeList.Add(ANode);
    end;
  end;
  procedure CopyInfos(AnObject:TGameObject32);
  var AnInfo:TInfo32;
    procedure CopyEvent(AnEvent:TNode32);
    begin
      if Selection.HasItem(AnEvent)
      then begin
        TNode32(AnEvent.Associate).SetFamily(AnInfo);
        AnInfo.Restore;
      end;
    end;
  begin
    if (AnObject.ObjType=ot_Info) then begin
      AnInfo:=TInfo32.Create(Self);
      AnInfo.Assign(TInfo32(AnObject));
      TInfo32(AnObject).SetAssociate(AnInfo);
      TInfo32(AnObject).Events.ForEach(@CopyEvent);
      InfoList.Add(AnInfo);
    end;
  end;
  procedure CopyMoves(AnObject:TGameObject32);
  var AMove:TMove32;
  begin
    if (AnObject.ObjType=ot_Move) then begin
      AMove:=TMove32.Create(Self);
      TMove32(AnObject).SetAssociate(AMove);
      MoveList.Add(AMove);
      with AMove do begin
        Assign(TMove32(AnObject));
        if Selection.HasItem(TNode32(TMove32(AnObject).From))
        then SetFrom(TNode32(TMove32(AnObject).From.Associate))
        else SetFrom(TNode32(TMove32(AnObject).From));
        if Upto<>nil then
                     if Selection.HasItem(TNode32(TMove32(AnObject).Upto))
                     then SetUpto(TNode32(TMove32(AnObject).Upto.Associate))
                     else SetUpto(TNode32(TMove32(AnObject).Upto));
      end;
    end;
  end;
  procedure CopyTables(AnObject:TGameObject32);
  var ATable:TTable32;
  begin
    if (AnObject.ObjType=ot_Table) then begin
      ATable:=TTable32.Create(Self);
      ATable.Assign(TTable32(AnObject));
      TTable32(AnObject).SetAssociate(ATable);
      NodeList.Add(ATable);

    end;
  end;
begin
  DisAssociate; {Set all objects' associates to nil}
  Selection.ForEach(@CopyNodes);
  Selection.ForEach(@CopyInfos); 
  Selection.ForEach(@CopyMoves);
  Selection.ForEach(@CopyTables);
  SwitchAssociates;
  SetState(gs_Edited);
end;

procedure TGameForm32.DrawGame(ACanvas:TCanvas);
  procedure DrawObjects(AnObject:TGameObject32);
  begin
    AnObject.DrawObject(ACanvas);
  end;
begin
    DrawObjects(SelRect);
    PlayerList.ForEach(@DrawObjects);
    NodeList.ForEach(@DrawObjects);
    MoveList.ForEach(@DrawObjects);
    InfoList.ForEach(@DrawObjects);
    ChoiceList.ForEach(@DrawObjects);
    PayList.ForEach(@DrawObjects);

    {DepthList.ForEach(@DrawObjects);}

    //DrawObjects(GameHeader);

end;

{Testing rountines}

{procedure TGameForm32.ShowBeliefs;
var AString:String;
    procedure ShowBelief(ANode:TNode32);
    begin
      AString:=AString+ANode.Name+' '+FloatToStrF(ANode.Belief,ffFixed,5,5)+'  ';
    end;
begin
    ABug:=TBug.Create(Self);
    AString:='Beliefs:  ';
    NodeList.ForEach(@ShowBelief);
    ABug.SetName(AString);
    TestList.Add(ABug);
end;

procedure TGameForm32.ShowIncentives;
    procedure ShowIncentive(AChoice:TChoice32);
    begin
      if AChoice.Owner=nil then Exit;
      ABug:=TBug.Create(Self);
      ABug.SetName(AChoice.Description(fw_Audit)+'= '+FloatToStrF(AChoice.Incentive,ffFixed,6,6)+'  ');
      TestList.Add(ABug);
    end;
begin
    ABug:=TBug.Create(Self);
    ABug.SetName('Incentives');
    TestList.Add(ABug);
    ChoiceList.ForEach(@ShowIncentive);
end;  }



end.
