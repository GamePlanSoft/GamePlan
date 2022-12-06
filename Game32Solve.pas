unit Game32Solve;

interface

uses Windows, SysUtils, Classes, Graphics, Constants, Type32, Matrices, Game32Type, Math, Utilities;

type

  TSolution32   = class;
  TSolutionGroup = class;

  TGameType32   = class(TGameForm32)
  protected
  public
    Speed     : Real;
    {NullGroup     : TSolutionGroup; }
    {Initializing operations}
    procedure InitSolving;
    procedure InitFrequency;
    procedure CleanUp;

    {Solving operations}
    function IsOptimal:Boolean;
    procedure PureToProbas;
    procedure ReloadFrequency;
    function MakeIRT:Boolean;
    function MakeExpectations:Boolean;
    function MakeBeliefs:Boolean;
    function MakeIncentives:Boolean;
    function MakeBestReplies(ForAll:Boolean):Boolean;
    {procedure UpdateAssociations;
    function InitAssociations:Boolean;}
    {procedure MakeTestDeviation(TestChoice:TChoice32);
    procedure MakeTestJacobian;
    {Derivatives}
    function DExpectDMoveProba(FromWhat:TMove32;ToWhom:TPlayer32;Where:TNode32):Real;
    function DExpectDChoiceProba(FromWhat:TChoice32;ToWhom:TPlayer32;Where:TNode32):Real;
    function DNodeFrequentDMoveProba(FromWhat:TMove32;Where:TNode32):Real;
    function DInfoFrequentDMoveProba(FromWhat:TMove32;Where:TInfo32):Real;
    function DBeliefDMoveProba(FromWhat:TMove32;Where:TNode32):Real;
    function DBeliefDChoiceProba(FromWhat:TChoice32;Where:TNode32):Real;
    function DChoiceIncentDChoiceProba(Affected,FromWhat:TChoice32):Real;
    {Solving equations}
    function MakeEquations:Boolean;
    procedure MakeRawDeviation;
    procedure MakeFullJacobian;
    procedure ReduceFullJacobianColumns;
    procedure FillJacobianRows;
    procedure SubtractJacobianRows;
    function MakeRawJacobian:Boolean;
    function MakeInverseJacobian:Boolean;
    procedure MakeDeviation;
    procedure MakeSpeed;
    function MakeDirection:Boolean;
    {Saving solutions}
    procedure SaveProfile;
    {procedure SaveNonSolution; }
    procedure SaveSolution(ASolveMethod,ASolveConcept:Integer);
    procedure DeleteSolution(ASolution:TSolution32);
    function SolutionAlreadyExists(ACandidate:TSolution32;InGroup:TSolutionGroup):Boolean;
    procedure UpdateAllBases(ASolution:TSolution32);
    procedure ReOrganizeGroups;
    procedure RemoveDuplicateSolutions;
    function SolutionGroupFor(ASolution:TSolution32):TSolutionGroup;
    function MakeExtension(NewSolution,OldSolution:TSolution32;Mu:Real):Boolean;
    function NormalizeProbas:Boolean;
    {Debug procedures}
    procedure ShowActivity;
    procedure ShowDirection;
    procedure ShowProba;
    procedure ShowIncentive;
    procedure ShowDeviation;
    procedure ShowBelief;
    procedure ShowFrequent;
    procedure MakeDebugInfo(AString:String);

  end;

  TSolution32    = class(TGameObject32) {Client objects will point to it}
  public
    HitCount,
    Method,
    Concept    : Integer;
    IsShown    : Boolean;
    {MaxRec,
    MinRec, }
    Beliefs,
    Probas,
    Incents,
    Deviate    : TVector;
    Optimality : TBoolVect;
    Expects    : TMatrix;
    SolutionLog,
    DeBugList,
    BitList    : TGameList;
    GroupList  : TGameList;
    OwnGroup   : TSolutionGroup;
    SolDisp    : Set of dc_Proba..dc_Expect;
    constructor Create(AGame:TFakeGame);
    destructor Destroy; override;
    procedure Remake; override;
    procedure SetHitCount(AHitCount:Integer);
    procedure SetSolType(AMethod,AConcept:Integer);
    procedure UpdateName{(AName:String)};
    function ResetRank: Integer; override;
    function Description(ForWhat:Integer) : String; override;
    procedure SetLine(AStr:String); override;
    procedure SetShown(IsIt:Boolean);
    procedure SetSolBelief(ANode:TNode32);
    procedure SetSolProba(AChoice:TChoice32);
    procedure SetSolIncent(AChoice:TChoice32);
    procedure SetSolExpect(APlayer:TPlayer32;ANode:TNode32;AnExpect:Real);
    procedure FillBitList;
    procedure RecordSolution;
    function BelongsToGroup(AGroup:TSolutionGroup;IsOwn:Boolean):Boolean;
    function FindOwnGroup:TSolutionGroup;
    function IsInManyGroups:Boolean;
    function DistanceTo(ASolution:TSolution32):Real;
    procedure SetDisplay(HasProba,HasBelief,HasExpect:Boolean);
    procedure DrawObject(ACanvas:TCanvas); override;
  end;

  TSolutionBit = class(TPayoff32)
  public
    Solution   : TGameObject32;
    SolRank    : Integer;
    {constructor Create(ABitType:Integer;AHeader:TGameObject32;
                       AWhere:TGameObject32;AWhom:TPlayer32;AValue:Real); }
    destructor Destroy; override;
    procedure SetData(ABitType:Integer;AHeader:TGameObject32;
                               AWhere:TGameObject32;AWhom:TPlayer32;AValue:Real);
    function Description(ForWhat:Integer) : String; override;
    procedure SetLine(AStr:String); override;
    function Restore:Boolean; override;
    procedure DrawObject(ACanvas:TCanvas); override;
  end;

  TProfile = class(TGameObject32)
    public
    ChoiceActivity : TBoolVect;
    InfoIncentives : TVector;
    BitList        : TGameList;
    constructor Create(AGame:TFakeGame);
    destructor Destroy; override;
    procedure FillBitList;
  end;

  TSolutionGroup = class(TGameObject32)
    public
    {ProbaDimension   : Integer; }
    Optimality : TBoolVect;
    Basis      : TGameList;
    constructor Create(AGame:TFakeGame);
    destructor Destroy; override;
    function Extend(NewSolution,OldSolution:TSolution32):Boolean;
    procedure MatchOptimality(ASolution:TSolution32);
    function HasOwnSolution:Boolean;
    {procedure AddToBasis(NewSolution:TSolution32);
    procedure ExtendBasis(NewSolution:TSolution32);}
    procedure UpdateBasis;
    procedure UpdateName;
  end;

implementation

uses SolvOptDlg, Solve32, MainGP32, Dialogs;

{Init for solving operations}

constructor TProfile.Create(AGame:TFakeGame);
begin
  Game:=AGame;
  ObjType:=ot_Profile;
  with Game as TGameType32 do begin
    ChoiceActivity:=TBoolVect.Create(ChoiceList.Count,Game);
    InfoIncentives:=TVector.Create(InfoList.Count,Game);
    BitList:=TGameList.Create;
  end;
end;

destructor TProfile.Destroy;
begin
  ChoiceActivity.Free;
  InfoIncentives.Free;
  BitList.FreeAll(ot_All);
  BitList.Free;
  inherited Destroy;
end;

procedure TProfile.FillBitList;
var ASolBit: TSolutionBit; AProba:Real;
  procedure RecordMoveData(AMove:TMove32);
  begin
    if AMove.From.Owner=nil then Exit;
    if ChoiceActivity.Entry(AMove.OwnChoice.Rank)
    then AProba:=1 else AProba:=0;
    ASolBit:=TSolutionBit.Create(Game);
    ASolBit.SetData(ot_Proba,Self,AMove,nil,AProba);
    BitList.Add(ASolBit);
    if ChoiceActivity.Entry(AMove.OwnChoice.Rank)
    then begin
      ASolBit:=TSolutionBit.Create(Game);
      ASolBit.SetData(ot_Incent,Self,AMove,nil,InfoIncentives.Entry(AMove.OwnChoice.Source.Rank));
      BitList.Add(ASolBit);
    end;
  end;
begin
  BitList.FreeAll(ot_All);
  with Game as TGameType32 do MoveList.ForEach(@RecordMoveData);
end;

procedure TGameType32.ReloadFrequency;
  procedure InitSingles(ANode:TNode32);
  begin
    with ANode do begin
      NodeFrequent.SetEntry(False,Rank,Frequency);
    end;
  end;
  procedure InitInfoFrequent(AnInfo:TInfo32);
  begin
    with AnInfo do InfoFrequent.SetEntry(False,Rank,0);
  end;
begin
  NodeList.ForEach(@InitSingles);
  InfoList.ForEach(@InitInfoFrequent);
end;

procedure TGameType32.CleanUp;
begin
  (*MessageDlg('Discarding solution tools.',mtInformation,[mbOk],0); *)

  if IminT<>nil then IminT.Free;
  if IR<>nil then IR.Free;
  if Expect<>nil then Expect.Free;
  if NodeFrequent<>nil then NodeFrequent.Free;
  if InfoFrequent<>nil then InfoFrequent.Free;
  if Jacobian<>nil then Jacobian.Free;
  {if TestJacob<>nil then TestJacob.Free; }

  if FullJacob<>nil then FullJacob.Free;

  if FullBeliefs<>nil then FullBeliefs.Free;
  if Deviation<>nil then Deviation.Free;
  if FullIncent<>nil then FullIncent.Free;
  if FullProba<>nil then FullProba.Free;
  {if TestProba<>nil then TestProba.Free;
  if TestDeviat<>nil then TestDeviat.Free; }

  {if Direction<>nil then Direction.Free; }
  {if DeltaX<>nil then DeltaX.Free; }
  {if FullDirect<>nil then FullDirect.Free; }

  IminT:=nil;IR:=nil;Expect:=nil;
  NodeFrequent:=nil;InfoFrequent:=nil;
  FullJacob:=nil;Jacobian:=nil;{TestJacob:=nil;}
  Deviation:=nil;FullBeliefs:=nil; {DeltaX:=nil; }
  {Direction:=nil;}FullProba:=nil;{TestProba:=nil;TestDeviat:=nil;}{FullDirect:=nil;} FullIncent:=nil;
  {if NextSolution<>nil then NextSolution.Free;}
  {NextSolution:=nil;
  {SolGroupList.FreeAll(ot_All); }
  ProfileList.FreeAll(ot_All);

  (*MessageDlg('Solution tools discarded.',mtInformation,[mbOk],0); *)

end;

procedure TGameType32.InitFrequency;
  procedure InitSingles(ANode:TNode32);
  begin
    with ANode do if Family.IsSingleton
    then begin
      SetBelief(1); {Won't be recalculated}
      FullBeliefs.SetEntry(False,Rank,1);

      try SetFrequency(Power(10,TopPower-DeltaPower*Depth))
      except on Exception do SetFrequency(MidFrequency) end;

    end else SetFrequency(NilFrequency);
  end;
  procedure LoadFrequency(ANode:TNode32);
  begin
    with ANode do NodeFrequent.SetEntry(False,Rank,Frequency);
  end;
begin
  NodeList.ForEach(@InitSingles);
  NodeList.ForEach(@LoadFrequency);
end;

procedure TGameType32.InitSolving;
begin
  CleanUp;

  {MessageDlg('Creating solution tools.', mtInformation, [mbOk], 0); }

  IminT:=TMatrix.Create(True,NodeList.Count,NodeList.Count,Self);
  IR:=TMatrix.Create(False,PlayerList.Count,NodeList.Count,Self);
  Expect:=TMatrix.Create(False,PlayerList.Count,NodeList.Count,Self);
  NodeFrequent:=TVector.Create(NodeList.Count,Self);
  InfoFrequent:=TVector.Create(InfoList.Count,Self);
  FullJacob:=TMatrix.Create(False,ChoiceList.Count,ChoiceList.Count,Self);
  {TestJacob:=TMatrix.Create(True,ChoiceList.Count-InfoList.Count,ChoiceList.Count-InfoList.Count,Self);}
  Jacobian:=TMatrix.Create(True,ChoiceList.Count-InfoList.Count,ChoiceList.Count-InfoList.Count,Self);
  FullBeliefs:=TVector.Create(NodeList.Count,Self);
  Deviation:=TVector.Create(ChoiceList.Count-InfoList.Count,Self);
  {Direction:=TVector.Create(ChoiceList.Count-InfoList.Count,Self);}
  {DeltaX:=TVector.Create(ChoiceList.Count-InfoList.Count,Self);  }
  FullIncent:=TVector.Create(ChoiceList.Count,Self);
  FullProba:=TVector.Create(ChoiceList.Count,Self);
  {TestDeviat:=TVector.Create(ChoiceList.Count,Self);
  TestProba:=TVector.Create(ChoiceList.Count,Self); }
  {FullDirect:=TVector.Create(ChoiceList.Count,Self); }
  {NextSolution:=TSolution32.Create(Self);  }

  InitFrequency; {They're never changed in the iteration}

  {MessageDlg('Solution tools created.', mtInformation, [mbOk], 0); }


end;

{Expectations routines}

function TGameType32.IsOptimal:Boolean;
  procedure CheckBest(AnInfo:TInfo32);
  var TheBest:Real;
    procedure ResetOptima(AChoice:TChoice32);
    begin
      with AChoice do if IsArtificial then Exit else
      if (Incentive+FadeValue>=TheBest)
      then SetOptimum(True) else SetOptimum(False);
    end;
    procedure CheckActiveIsBest(AChoice:TChoice32);
    begin
      with AChoice do if IsArtificial then Exit else
      if (Proba>=MinProba) and not IsOptimum
      then IsOptimal:=False;
    end;
  begin
    with AnInfo do if IsArtificial then Exit else
    if (Owner<>nil) then if (BestReply<>nil) then begin
      TheBest:=BestProspect;{BestReply.Incentive;  {BestProspect?}
      Choices.ForEach(@ResetOptima);
      Choices.ForEach(@CheckActiveIsBest);
    end else IsOptimal:=False;
  end;
begin
  IsOptimal:=True;
  InfoList.ForEach(@CheckBest)
end;

{procedure TGameType32.UpdateAssociations;
  procedure CheckAssociations(AnInfo:TInfo32);
    procedure CheckAssociate(AChoice:TChoice32);
    begin
      with AChoice do if (Associate=AnInfo.Target.BestReply)
      then SetAssociate(AnInfo.BestReply.Associate);
    end;
  begin
    with AnInfo do begin
      if not IsArtificial or (Target=nil) then Exit else
      if BestReply.Associate<>Target.BestReply then begin
        Choices.ForEach(@CheckAssociate);
        BestReply.SetAssociate(Target.BestReply);
      end;
    end;
  end;
begin
  InfoList.ForEach(@CheckAssociations);
end;  }

{procedure TGameType32.MakeTestDeviation(TestChoice:TChoice32);
  procedure RefreshProba(AChoice:TChoice32);
  begin
    with AChoice do SetProba(TestProba.Entry(Rank));
  end;
  procedure RecordProba(AChoice:TChoice32);
  begin
    with AChoice do FullProba.SetEntry(False,Rank,Proba);
  end;
  procedure FillTestJacobianRow(AColumn:TChoice32);
  begin
    try with EquationList
    do TestJacob.SetEntry(False,TrueIndex(TestChoice),TrueIndex(AColumn),
      (TestDeviat.Entry(TrueIndex(AColumn))-Deviation.Entry(TrueIndex(AColumn)))/Epsilon);
    except on Exception do end;
  end;
begin
  ChoiceList.ForEach(@RefreshProba);
  with TestChoice do SetProba(Proba+Epsilon);
  with TestChoice.Source.BestReply do SetProba(Proba-Epsilon);
  MakeDebugInfo('Test proba:');
  ChoiceList.ForEach(@RecordProba);
  FullProba.Show;

  MakeBestReplies(False);
  MakeDebugInfo('TestDeviation');
  MakeRawDeviation;
  MakeDeviation;
  EquationList.ForEach(@FillTestJacobianRow);

end;}

{procedure TGameType32.MakeTestJacobian;
  procedure StoreProba(AChoice:TChoice32);
  begin
    with AChoice do TestProba.SetEntry(False,Rank,Proba);
  end;
  procedure StoreDeviation(AChoice:TChoice32);
  begin
    with EquationList do TestDeviat.SetEntry(False,TrueIndex(AChoice),Deviation.Entry(TrueIndex(AChoice)));
  end;
  procedure MakeTestDev(AChoice:TChoice32);
  begin
    MakeTestDeviation(AChoice);
  end;
begin
  ChoiceList.ForEach(@StoreProba);
  EquationList.ForEach(@StoreDeviation);
  TestJacob.SetInvDim(EquationList.Count);
  EquationList.ForEach(@MakeTestDev);
  MakeDebugInfo('TestJacobian:');
  TestJacob.Show;

end;}

{function TGameType32.InitAssociations:Boolean;
  procedure InitAnAssociation(AnInfo:TInfo32);
    procedure FindAssociate(AChoice:TChoice32);
      procedure FindFreeAssociate(BChoice:TChoice32);
      begin
        if BChoice.IsActive
        then if (BChoice.Associate=nil) then begin
               AChoice.SetAssociate(BChoice);
               BChoice.SetAssociate(AChoice);
             end;
      end;
    begin
      if AChoice.IsActive
      then if (AChoice<>AnInfo.BestReply)
           then begin
             AnInfo.Target.Choices.ForEach(@FindFreeAssociate);
             if AChoice.Associate=nil then InitAssociations:=False;
           end;
    end;
  begin
    with AnInfo do if IsArtificial and (Target<>nil) then begin
      BestReply.SetAssociate(Target.BestReply);
      Choices.ForEach(@FindAssociate);
    end;
  end;
  procedure SetNilAssociate(AChoice:TChoice32);
  begin
    AChoice.SetAssociate(nil);
  end;
begin
  InitAssociations:=True;
  ChoiceList.ForEach(@SetNilAssociate);
  InfoList.ForEach(@InitAnAssociation);
end;}

function TGameType32.MakeBestReplies(ForAll:Boolean):Boolean;
  procedure ResetBestChoice(AnInfo:TInfo32);
  begin
    with AnInfo do if (Owner=nil) then Exit else begin
      if ForAll then ResetBestReply
      else if not IsArtificial then ResetBestReply;
      if BestReply=nil then MakeBestReplies:=False;
    end;
  end;
begin
  if MakeIncentives then begin
    MakeBestReplies:=True;
    InfoList.ForEach(@ResetBestChoice);
  end else MakeBestReplies:=False;
end;

procedure TGameType32.PureToProbas;
  procedure SetActiveToUnit(AChoice:TChoice32);
  begin
    with AChoice do if IsActive then SetProba(1) else SetProba(0);
  end;
begin
  ChoiceList.ForEach(@SetActiveToUnit);
end;

function TGameType32.MakeIRT:Boolean;
  procedure FillIminT(AChoice:TChoice32);
    procedure FillProba(AMove:TMove32);
    begin    
      with AMove do if (Upto<>nil)
      then IminT.SetEntry(True,From.Rank,Upto.Rank,-Discount*AChoice.Proba);
    end;
  begin
    AChoice.Instances.ForEach(@FillProba);
  end;
  procedure FillIR(APayoff:TPayoff32);
  begin
    with APayoff do with TMove32(Where) do
    if (From.Owner=nil) {Chance move so discount serves as probability}
    then IR.SetEntry(True,Whom.Rank,From.Rank,Value*Discount)
    else IR.SetEntry(True,Whom.Rank,From.Rank,Value*OwnChoice.Proba);
  end;
begin
  ReloadFrequency;
  IminT.InitIdentity(0);
  ChoiceList.ForEach(@FillIminT);
  IminT.Invert;
  if IminT.IsSingular
  then MakeIRT:=False
  else begin
    MakeIRT:=True;
    IR.SetNil;
    PayList.ForEach(@FillIR);
  end;
end;

function TGameType32.MakeBeliefs:Boolean;
var Dummy:Real;  {ALine:String; }
  procedure UpdateNodeFrequency(ANode:TNode32);
    procedure AddSingletFrequency(ASinglet:TNode32);
    begin
      if ASinglet.Family.IsSingleton {Only singletons have start frequency}
      then try
        Dummy:=Dummy+ASinglet.Frequency*IminT.Entry(ASinglet.Rank,NodeList.Count+ANode.Rank);
      except on Exception do MakeBeliefs:=False; end;
    end;
  begin {UpdateNodeFrequency}
    with ANode do begin
      Dummy:=0;
      NodeList.ForEach(@AddSingletFrequency);
      NodeFrequent.SetEntry(False,Rank,Dummy);
    end; {UpdateNodeFrequency}
  end;
  procedure UpdateInfoFrequency(AnInfo:TInfo32);
    procedure AddNodeFrequent(ANode:TNode32);
    begin
      InfoFrequent.SetEntry(True,AnInfo.Rank,NodeFrequent.Entry(ANode.Rank));
    end;
  begin
    with AnInfo do Events.ForEach(@AddNodeFrequent);
  end;
  procedure ResetBelief(ANode:TNode32);
  begin
    with ANode do
    if not Family.IsSingleton
    then begin
      if (InfoFrequent.Entry(Family.Rank)>0)
      then try SetBelief(NodeFrequent.Entry(Rank)/InfoFrequent.Entry(Family.Rank));
      except on Exception do begin MakeBeliefs:=False; SetBelief(0); end;
      end else begin {MakeBeliefs:=False;} SetBelief(0); end;
    end;
  end;
begin
  MakeBeliefs:=True;
  NodeList.ForEach(@UpdateNodeFrequency);
  InfoList.ForEach(@UpdateInfoFrequency);
  NodeList.ForEach(@ResetBelief);
end;

function TGameType32.MakeExpectations:Boolean;
var AVector,BVector:TVector; Row,Col:Integer;
begin
  if MakeIRT
  then begin
    MakeExpectations:=True;
    AVector:=nil;
    BVector:=nil;
    for Row:=1 to NodeList.Count
    do begin
      try AVector:=IminT.Rows.Items[Row];
      except on EListError do AVector:=nil end;
      if (AVector=nil)
      then MakeExpectations:=False
      else for Col:=1 to PlayerList.Count
           do begin
             try BVector:=IR.Rows.Items[Col];
             except on EListError do BVector:=nil; end;
             if (BVector=nil)
             then MakeExpectations:=False
             else Expect.SetEntry(False,Col,Row,
               DotProduct(NodeList.Count,NodeList.Count,AVector,BVector));
           end;
    end;
    if not MakeBeliefs then MakeExpectations:=False;
  end else MakeExpectations:=False;
end;

function TGameType32.MakeIncentives:Boolean;
  procedure InputMoveExpect(AMove:TMove32);
  begin
    with AMove do if (From.Owner=nil) then Exit {Ignore chance moves}
    else if (Upto=nil) then SetIncentive(0) {Payoff only for final moves}
         else try SetIncentive(Discount*Expect.Entry(From.Owner.Rank,Upto.Rank));
              except on Exception do MakeIncentives:=False; end;
  end;
  procedure AddMovePay(APayoff:TPayoff32);
  begin
    with APayoff do if IsOwnPay
    then with TMove32(Where) do try SetIncentive(Incentive+Value); {Need discount if pre discounting}
         except on Exception do MakeIncentives:=False; end;
  end;
  procedure MakeIncentive(AChoice:TChoice32);
  var Dummy:Real;
    procedure AddIncentive(AMove:TMove32);
    begin
      with AMove do
      try Dummy:=Dummy+From.Belief*Incentive;
      except on Exception do MakeIncentives:=False; end;
    end;
  begin
    with AChoice do if (Source.Owner=nil) then Exit
    else begin
      Dummy:=0;
      Instances.ForEach(@AddIncentive);
      SetIncentive(Dummy);
    end;
  end;
begin
  if MakeExpectations then begin
    MakeIncentives:=True;
    MoveList.ForEach(@InputMoveExpect);
    PayList.ForEach(@AddMovePay);
    ChoiceList.ForEach(@MakeIncentive);
    {Need to fill an incentive vector to display for debug}
    {if IsDebug then begin MakeDebugInfo('Incentives:');FullIncent.Show;end  }
    {if IsDebug then begin
      ShowFrequent;
      ShowBelief;
      ShowIncentive;
      ShowDeviation;
    end;  }
  end else MakeIncentives:=False;
end;

{Derivatives}

function TGameType32.DExpectDMoveProba(FromWhat:TMove32;ToWhom:TPlayer32;Where:TNode32):Real;
{Calculates derivative of Expect for ToWhom at Where with respect to FromWhat-proba}
var Dummy:Real; APay:TPayoff32;
begin
  APay:=FromWhat.ShowPayment(ToWhom);
  if (APay<>nil) then Dummy:=APay.Value else Dummy:=0;
  if (FromWhat.Upto<>nil) and (ToWhom<>nil)
  then with FromWhat do try Dummy:=Dummy+Discount*Expect.Entry(ToWhom.Rank,Upto.Rank);
                        except on Exception do Dummy:=0; end;
  try DExpectDMoveProba:=IminT.Entry(Where.Rank,NodeList.Count+FromWhat.From.Rank)*Dummy;
  except on Exception do DExpectDMoveProba:=0; end;
end;

function TGameType32.DExpectDChoiceProba(FromWhat:TChoice32;ToWhom:TPlayer32;Where:TNode32):Real;
var Dummy:Real;
  procedure AddDeriv(AMove:TMove32);
  begin
    try Dummy:=Dummy+DExpectDMoveProba(AMove,ToWhom,Where);
    except on Exception do Dummy:=0; end;
  end;
begin
  Dummy:=0;
  FromWhat.Instances.ForEach(@AddDeriv);
  DExpectDChoiceProba:=Dummy;
end;

function TGameType32.DNodeFrequentDMoveProba(FromWhat:TMove32;Where:TNode32):Real;
begin
  with FromWhat do
  if Upto=nil then DNodeFrequentDMoveProba:=0
  else try DNodeFrequentDMoveProba:=Discount*NodeFrequent.Entry(From.Rank)
                      *IminT.Entry(Upto.Rank,NodeList.Count+Where.Rank);
       except on Exception do DNodeFrequentDMoveProba:=0; end;
end;

function TGameType32.DInfoFrequentDMoveProba(FromWhat:TMove32;Where:TInfo32):Real;
var Dummy: Real;
  procedure AddNodeDeriv(ANode:TNode32);
  begin
    try Dummy:=Dummy+DNodeFrequentDMoveProba(FromWhat,ANode);
    except on Exception do Dummy:=0; end;
  end;
begin
  Dummy:=0;
  Where.Events.ForEach(@AddNodeDeriv);
  DInfoFrequentDMoveProba:=Dummy;
end;

function TGameType32.DBeliefDMoveProba(FromWhat:TMove32;Where:TNode32):Real;
var FrequentSum:Real;
begin
  FrequentSum:=InfoFrequent.Entry(Where.Family.Rank);
  if FrequentSum>=MinAbsValue
  then try DBeliefDMoveProba:=DNodeFrequentDMoveProba(FromWhat,Where)/FrequentSum
   -NodeFrequent.Entry(Where.Rank)*DInfoFrequentDMoveProba(FromWhat,Where.Family)/Sqr(FrequentSum);
  except on Exception do DBeliefDMoveProba:=0; end else DBeliefDMoveProba:=0;
end;

function TGameType32.DBeliefDChoiceProba(FromWhat:TChoice32;Where:TNode32):Real;
var Dummy:Real;
  procedure AddDBelief(AMove:TMove32);
  begin
    try Dummy:=Dummy+DBeliefDMoveProba(AMove,Where);
    except on Exception do Dummy:=0; end;
  end;
begin
  Dummy:=0;
  with Where do
  if not Family.IsSingleton
  then FromWhat.Instances.ForEach(@AddDBelief);
  DBeliefDChoiceProba:=Dummy;
end;

function TGameType32.DChoiceIncentDChoiceProba(Affected,FromWhat:TChoice32):Real;
var Dummy:Real;
  procedure AddDChoices(AMove:TMove32);
  begin
    with AMove do begin
      try Dummy:=Dummy+Incentive*DBeliefDChoiceProba(FromWhat,From);
      except on Exception do Dummy:=0; end;
      if Upto<>nil
      then try Dummy:=Dummy+From.Belief*Discount*DExpectDChoiceProba(FromWhat,From.Owner,Upto);
      except on Exception do Dummy:=0; end;
    end;
  end;
begin
  Dummy:=0;
  with Affected do if Source.Owner<>nil
  then Instances.ForEach(@AddDChoices);
  DChoiceIncentDChoiceProba:=Dummy;
end;

{Mixed solving iteration procedures}

function TGameType32.MakeEquations:Boolean;
  procedure AddFreeChoice(AChoice:TChoice32);
  begin
    with AChoice do begin
      if (Source.Owner=nil) then Exit;
      if IsBest then Exit;
      {if IsArtificial and (Associate=nil) then Exit;}
      EquationList.Add(AChoice);
    end;
  end;
begin
  MakeEquations:=True;  {MakeBestReplies has been called by IsOptimal upfront}
  EquationList.Clear;
  ChoiceList.ForEach(@AddFreeChoice);
  if EquationList.Count>0
  then Jacobian.SetInvDim(EquationList.Count)
  else MakeEquations:=False;
end;

procedure TGameType32.MakeRawDeviation;
  procedure SetDeviation(AChoice:TChoice32);
  var BChoice:TChoice32;
  begin  {Need to display it to check D=0 for best}
    if AChoice.IsArtificial {and (AChoice.Associate<>nil)}
    then BChoice:=TChoice32(AChoice.Associate) else BChoice:=AChoice;
    Deviation.SetEntry(False,EquationList.TrueIndex(BChoice),
                       BChoice.Source.BestProspect-BChoice.Incentive);
  end;
begin
  EquationList.ForEach(@SetDeviation);
end;

procedure TGameType32.MakeFullJacobian;
  procedure FillFullRow(ARow:TChoice32);
    procedure FillFullColumn(ACol:TChoice32);
    begin
      if ACol.Source.Owner<>nil then
      FullJacob.SetEntry(False,ARow.Rank,ACol.Rank,
                            DChoiceIncentDChoiceProba(ARow,ACol));
    end;
  begin
    {FullJacob.SetEntry(False,ARow.Rank,0,ARow.Rank); {Debug}
    if ARow.Source.Owner<>nil
    then ChoiceList.ForEach(@FillFullColumn);
  end;
begin
  ChoiceList.ForEach(@FillFullRow);
end;

procedure TGameType32.ReduceFullJacobianColumns;
  procedure SubtractBestColumn(ACol:TChoice32);
    procedure SubtractBest(ARow:TChoice32);
    begin
      if ARow.Source.Owner<>nil then with FullJacob do
      try SetEntry(True,ARow.Rank,ACol.Rank,
        -Entry(ARow.Rank,ACol.Source.BestReply.Rank));
      except on Exception do {????} end;
    end;
  begin
    ChoiceList.ForEach(@SubtractBest);
  end;
begin {Constructs minus deriv of best plus deriv of choice}
  EquationList.ForEach(@SubtractBestColumn);
end;

procedure TGameType32.FillJacobianRows;
  procedure FillJacobianRow(ARow:TChoice32);
  var AChoice:TChoice32;
    procedure FillJacobianColumn(ACol:TChoice32);
    begin
      with EquationList do
      Jacobian.SetEntry(False,TrueIndex(ARow),TrueIndex(ACol),
           FullJacob.Entry(AChoice.Rank,ACol.Rank));
    end;
  begin
    if ARow.IsArtificial then AChoice:=TChoice32(ARow.Associate) else AChoice:=ARow;
    EquationList.ForEach(@FillJacobianColumn);
  end;
begin
  EquationList.ForEach(@FillJacobianRow);
end;

procedure TGameType32.SubtractJacobianRows;
  procedure SubtractJacobianRow(ARow:TChoice32);
    procedure AdjustColumn(ACol:TChoice32);
    begin {Actually making minus Jacobian}
      with EquationList do
      Jacobian.SetEntry(True,TrueIndex(ARow),TrueIndex(ACol),
      -FullJacob.Entry(ARow.Source.BestReply.Rank,ACol.Rank));
    end;
  begin
    {Jacobian.SetEntry(False,EquationList.TrueIndex(ARow),0,ARow.Rank); {Debug}
    EquationList.ForEach(@AdjustColumn);
  end;
begin
  EquationList.ForEach(@SubtractJacobianRow);  {Subtract best row}
end;

function TGameType32.MakeRawJacobian:Boolean;
begin {Subtract deriv with respect to best and fill equationlist rows and cols only}
  if MakeEquations then begin
    MakeRawJacobian:=True;
    MakeFullJacobian;                          {Make all DIncent/DProba}
    ReduceFullJacobianColumns;                 {Subtract best column}
    FillJacobianRows;
    SubtractJacobianRows;
  end else MakeRawJacobian:=False;
end;

function TGameType32.MakeInverseJacobian:Boolean;
  procedure ProbaMultiply(ARow:TChoice32);
    procedure ColMultiply(ACol:TChoice32);
    begin
      with EquationList do begin
        Jacobian.SetEntry(False,TrueIndex(ARow),TrueIndex(ACol),
          ARow.Proba*Jacobian.Entry(TrueIndex(ARow),TrueIndex(ACol)));
        if ARow=ACol then {Add this, except when IsArtificial...replace}
        Jacobian.SetEntry(not ARow.IsArtificial,TrueIndex(ARow),TrueIndex(ACol),
          -Deviation.Entry(TrueIndex(ACol))); {Actually making minus Jacobian}
      end;
    end;
  begin
    EquationList.ForEach(@ColMultiply);
  end;
begin {Modifies raw Jacobian and Deviation by probability multiplication}
  if MakeRawJacobian then begin
    MakeInverseJacobian:=True;
    MakeRawDeviation;                       {needed for diagonal}
    EquationList.ForEach(@ProbaMultiply);
    {if IsDebug then begin MakeDebugInfo('Jacobian:');Jacobian.Show; end; }
    Jacobian.Invert;
    {if IsDebug then begin MakeDebugInfo('Inverse Jacobian:');Jacobian.Show; end; }
    if Jacobian.IsSingular then MakeInverseJacobian:=False;
  end else MakeInverseJacobian:=False;
end;

procedure TGameType32.MakeDeviation;
  procedure AdjustDeviation(AChoice:TChoice32);
  begin
    with EquationList do
    Deviation.SetEntry(False,TrueIndex(AChoice),AChoice.Proba*Deviation.Entry(TrueIndex(AChoice)));
  end;
begin
  EquationList.ForEach(@AdjustDeviation);
  NextNorm:=SqrVectorNorm(Jacobian.InvDim,Deviation); {InvDim=EquationList.Count}
  {if IsDebug then begin {Deviation.SetEntry(False,0,NextNorm);}
      {MakeDebugInfo('Dimension = '+FloatToStrF(Jacobian.InvDim,ffGeneral,16,16));
      MakeDebugInfo('Norm = '+FloatToStrF(NextNorm,ffGeneral,16,16));Deviation.Show; end; }
end;

procedure TGameType32.MakeSpeed;
  procedure AddSpeed(AChoice:TChoice32);
  begin
    try Speed:=Speed+Sqr(AChoice.Direction);
    except on Exception do Speed:=MaxSpeed end;
  end;
begin
  Speed:=0;
  ChoiceList.ForEach(@AddSpeed);
  {Speed:=Sqrt(Speed); }
  {if IsDebug then MakeDebugInfo('Speed = '+FloatToStrF(Speed,ffGeneral,16,16)); }
end;

function TGameType32.MakeDirection:Boolean;
  procedure ResetDirection(AChoice:TChoice32);
  begin
    with AChoice do if Source.Owner<>nil then SetDirection(0);
  end;
  procedure SetDirection(AFreeChoice:TChoice32);
  begin
    AFreeChoice.SetDirection(DotProduct(Jacobian.InvDim,Jacobian.ColDim,
         Jacobian.Rows.Items[EquationList.TrueIndex(AFreeChoice)],Deviation));
  end;
  procedure SetTrembling(AChoice:TChoice32);
  begin
    AChoice.SetDirection(Trembling);
  end;
  procedure SetBestDirection(AnInfo:TInfo32);
  var BestValue:Real;
    procedure AddDirection(AChoice:TChoice32);
    begin
      with AChoice do if not IsBest
      then BestValue:=BestValue+Direction;
    end;
  begin
    BestValue:=0;
    with AnInfo do if Owner<>nil then begin
      Choices.ForEach(@AddDirection);
      BestReply.SetDirection(-BestValue);
    end;
  end;
begin
  MakeDirection:=True;
  if MakeInverseJacobian
  then begin
    MakeDeviation;
    ChoiceList.ForEach(@ResetDirection);
    EquationList.ForEach(@SetDirection);
  end else EquationList.ForEach(@SetTrembling);
  InfoList.ForEach(@SetBestDirection);
  MakeSpeed;
end;



{Debug routines}

procedure TGameType32.ShowActivity;
var ALine:String;
  procedure AddActivity(AChoice:TChoice32);
  begin
    with AChoice do begin
      if not IsActive then Exit;
      ALine:=ALine+Name+'@'+Source.FirstName+', ';
    end;
  end;
begin
  ALine:='Activity: ';
  ChoiceList.ForEach(@AddActivity);
  MakeDebugInfo(ALine);
end;

procedure TGameType32.ShowDirection;
var ADirectLine:String;
  procedure DisplayDirection(AChoice:TChoice32);
  begin
    with AChoice do begin
      if Source.Owner=nil then Exit;
      ADirectLine:=ADirectLine+' dr('+Name+'@'+Source.FirstName+')= '+FloatToStrF(AChoice.Direction,ffGeneral,8,8);
    end;
  end;
begin
  ADirectLine:='';
  ChoiceList.ForEach(@DisplayDirection);
  MakeDebugInfo(ADirectLine);
end;

procedure TGameType32.ShowProba;
var ALine:String;
  procedure DisplayProba(AChoice:TChoice32);
  begin
    with AChoice do begin
      if Source.Owner=nil then Exit;
      ALine:=ALine+' p('+Name+'@'+Source.FirstName+')= '+FloatToStrF(AChoice.Proba,ffGeneral,8,8);
    end;
  end;
begin
  ALine:='';
  ChoiceList.ForEach(@DisplayProba);
  MakeDebugInfo(ALine);
end;

procedure TGameType32.ShowIncentive;
var ALine:String;
  procedure DisplayIncent(AChoice:TChoice32);
  begin
    with AChoice do begin
      if Source.Owner=nil then Exit;
      ALine:=ALine+' e('+Name+')= '+FloatToStrF(Incentive,ffGeneral,8,8);
    end;
  end;
begin
  ALine:='';
  ChoiceList.ForEach(@DisplayIncent);
  MakeDebugInfo(ALine);
end;

procedure TGameType32.ShowDeviation;
var ALine:String; TheDev:Real;
  procedure DisplayDeviate(AChoice:TChoice32);
  begin
    with AChoice do begin
      if Source.Owner=nil then Exit;
      try TheDev:=Deviation.Entry(EquationList.TrueIndex(AChoice));
      except on Exception do TheDev:=0; end;
      ALine:=Concat(ALine,' dv(',Name,'@',Source.FirstName,')= ',FloatToStrF(TheDev,ffGeneral,8,8));
    end;
  end;
begin
  ALine:='';
  ChoiceList.ForEach(@DisplayDeviate);
  MakeDebugInfo(ALine);
end;

{procedure TGameType32.ShowDeviation;
var ALine:String;
  procedure DisplayDeviate(AChoice:TChoice32);
  begin
    with AChoice do begin
      if Source.Owner=nil then Exit;
      ALine:=ALine+' dv('+Name+')= '+FloatToStrF(Source.BestProspect-Incentive,ffGeneral,8,8);
    end;
  end;
begin
  ALine:='';
  ChoiceList.ForEach(@DisplayDeviate);
  MakeDebugInfo(ALine);
end; }

procedure TGameType32.ShowBelief;
var ALine:String;
  procedure DisplayBelief(ANode:TNode32);
  begin
    with ANode do begin
      if Owner=nil then Exit;
      if IsArtificial then Exit;
      ALine:=ALine+' b('+ANode.Name+')= '+FloatToStrF(ANode.Belief,ffGeneral,8,8);
    end;
  end;
begin
  ALine:='';
  NodeList.ForEach(@DisplayBelief);
  MakeDebugInfo(ALine);
end;

procedure TGameType32.ShowFrequent;
var ALine:String;
  procedure DisplayFrequent(ANode:TNode32);
  begin
    with ANode do begin
      ALine:=ALine+' fr('+ANode.Name+')= '+FloatToStrF(NodeFrequent.Entry(Rank),ffGeneral,8,8);
    end;
  end;
begin
  ALine:='';
  NodeList.ForEach(@DisplayFrequent);
  MakeDebugInfo(ALine);
end;

{End debug routines}

procedure TGameType32.SaveProfile;
var AProfile:TProfile;
  procedure RecordProfileActivity(AChoice:TChoice32);
  begin
    with AChoice do if Source.Owner<>nil
    then AProfile.ChoiceActivity.SetEntry(Rank,IsActive);
  end;
  procedure RecordInfoIncentive(AnInfo:TInfo32);
    procedure FindActiveChoice(AChoice:TChoice32);
    begin
      with AChoice do if IsActive
      then AProfile.InfoIncentives.SetEntry(False,AnInfo.Rank,Incentive);
    end;
  begin
    with AnInfo do if Owner<>nil
    then Choices.ForEach(@FindActiveChoice);
  end;
begin
  if MakeBestReplies(True)
  then begin
    AProfile:=TProfile.Create(Self);
    AProfile.SetName('Profile # '+FloatToStrF(1+TGameType32(Self).ProfileList.Count,ffGeneral,3,3));
    ChoiceList.ForEach(@RecordProfileActivity);
    InfoList.ForEach(@RecordInfoIncentive);
    ProfileList.Add(AProfile);
  end;
end;

{procedure TGameType32.SaveNonSolution;
var ASolution: TSolution32; SolName:String;
  procedure FillLog(ABug:TBug);
  begin
    ASolution.SolutionLog.Add(ABug);
  end;
begin
  ASolution:=TSolution32.Create(Self);
  NullGroup.Basis.Add(ASolution);
  SolName:='0.'+FloatToStrF(1+NullGroup.Basis.IndexOf(ASolution),ffGeneral,3,3);
  ASolution.SetSolType(sm_None,sc_None,SolName);
  ASolution.SolutionLog.Clear;
  TestList.ForEach(@FillLog);
  TestList.Clear;
  SolutionList.Add(ASolution);
  SolveDlg.UpdateSolutionBox(True);
end; }

procedure TGameType32.DeleteSolution(ASolution:TSolution32);
  procedure DeleteFromBasis(ASolGroup:TSolutionGroup);
  begin
    with ASolGroup.Basis do
    if HasItem(ASolution)
    then Remove(ASolution);
  end;
begin
  SolGroupList.ForEach(@DeleteFromBasis); 
  SolutionList.Remove(ASolution);
  ASolution.Free; {Frees all solbits as well}
  if SolutionList.Count=0 then ReturnToEdit;
end;

procedure TGameType32.MakeDebugInfo(AString:String);
begin
  ABug:=TBug.Create(Self);
  ABug.SetLine(AString);
  TestList.Add(ABug);
end;

constructor TSolution32.Create(AGame:TFakeGame);
begin
  Game:=AGame;
  OwnGroup:=nil;
  Remake;  {Basic settings}
end;

destructor TSolution32.Destroy;
begin
  {MaxRec.Free;
  MinRec.Free; }
  Beliefs.Free;
  Probas.Free;
  Incents.Free;
  Deviate.Free;
  Optimality.Free;
  Expects.Free;
  SolutionLog.FreeAll(ot_All);
  SolutionLog.Free;
  DeBugList.FreeAll(ot_All);
  DeBugList.Free;
  BitList.FreeAll(ot_All);
  BitList.Free;
  GroupList.Clear;
  GroupList.Free;
  inherited Destroy;
end;

function TSolution32.ResetRank: Integer;
begin
  Rank:=TGameType32(Game).SolutionList.TrueIndex(Self);
  ResetRank:=Rank;
end;

procedure TSolution32.SetSolType(AMethod,AConcept:Integer);
begin
  Method:=AMethod;
  Concept:=AConcept;
end;

procedure TSolution32.UpdateName;
var OnesGroup: TSolutionGroup;
  procedure RecordGroupRank(AGroup:TSolutionGroup);
  begin
    if AGroup.Basis.HasItem(Self)
    then SetName(Name+' '+AGroup.Name);
  end;
begin
  if IsInManyGroups
  then begin
    SetName('C');
    TGameType32(Game).SolGroupList.ForEach(@RecordGroupRank);
  end else begin
    case Method of
    {sm_None      : SetName('N'); }
    sm_Pure      : SetName('P');
    sm_Mixed     : SetName('M');
    sm_Sample    : SetName('S');
    {sm_Dominated : SetName('DS');
    sm_Group     : SetName('G');
    sm_Duplicate : SetName('Du');}
    end;
    OnesGroup:=FindOwnGroup;
    if OnesGroup<>nil
    then SetName(Name+' '+OnesGroup.Name+'.'+FloatToStrF(1+OnesGroup.Basis.IndexOf(Self),ffGeneral,3,3));
  end;
  if IsDebug then SetName(Name+'['+IntToStr(HitCount)+']');
end;

procedure TSolution32.SetHitCount(AHitCount:Integer);
begin
  HitCount:=AHitCount;
end;

procedure TSolution32.Remake;
begin
  inherited Remake;
  HitCount:=1;
  objType:=ot_Solution;
  IsShown:=False;
  with TGameType32(Game) do begin
  {MaxRec:=TVector.Create(ChoiceList.Count,Game);
  MinRec:=TVector.Create(ChoiceList.Count,Game); }
  Beliefs:=TVector.Create(NodeList.Count,Game);
  Probas:=TVector.Create(ChoiceList.Count,Game);
  Incents:=TVector.Create(ChoiceList.Count,Game);
  Deviate:=TVector.Create(ChoiceList.Count,Game);
  Optimality:=TBoolVect.Create(ChoiceList.Count,Game);
  Expects:=TMatrix.Create(False,PlayerList.Count,NodeList.Count,Game);
  end;
  BitList:=TGameList.Create;
  GroupList:=TGameList.Create;
  SolutionLog:=TGameList.Create;
  DeBugList:=TGameList.Create;
  SetDisplay(True,True,True);
end;

function TSolution32.Description(ForWhat:Integer) : String;
begin
  inherited Description(ForWhat);
  TextLine:=TextLine+IntToStr(Concept);
  StrLenAdjust(sl_Name+5*sl_Short,Textline);
  TextLine:=TextLine+IntToStr(Method);
  StrLenAdjust(sl_Name+6*sl_Short,Textline);
  Description:=TextLine;
end;

procedure TSolution32.SetLine(AStr:String);
begin
  inherited SetLine(AStr);
  SubStr:=ShowStringPart(AStr,sl_Name+4*sl_Short+1,sl_Short);
  Concept:=ValidInt(SubStr);
  SubStr:=ShowStringPart(AStr,sl_Name+5*sl_Short+1,sl_Short);
  Method:=ValidInt(SubStr);
end;

procedure TSolution32.FillBitList;
var ASolBit: TSolutionBit;
  procedure RecordNodeBelief(ANode:TNode32);
    procedure RecordExpectation(APlayer:TPlayer32);
    begin
      ASolBit:=TSolutionBit.Create(Game);
      ASolBit.SetData(ot_Expect,Self,ANode,APlayer,
                                   Fade(Expects.Entry(APlayer.Rank,ANode.Rank)));
      BitList.Add(ASolBit);
    end;
  begin
    if ANode.IsArtificial then Exit;
    with Game as TGameType32 do PlayerList.ForEach(@RecordExpectation);
    with ANode do if (Owner=nil) or Family.IsSingleton then Exit;
    ASolBit:=TSolutionBit.Create(Game);
    if (ANode.ObjType=ot_Table) then Exit;
    ASolBit.SetData(ot_Belief,Self,ANode,nil,Beliefs.Entry(ANode.Rank));
    BitList.Add(ASolBit);
  end;
  procedure RecordMoveData(AMove:TMove32);
  begin
    with AMove do if (From.Owner=nil) or IsArtificial or (AMove.ObjType=ot_Cell) then Exit;
    ASolBit:=TSolutionBit.Create(Game);
    ASolBit.SetData(ot_Proba,Self,AMove,nil,Probas.Entry(AMove.OwnChoice.Rank));
    BitList.Add(ASolBit);
    ASolBit:=TSolutionBit.Create(Game);
    ASolBit.SetData(ot_Incent,Self,AMove,nil,Incents.Entry(AMove.OwnChoice.Rank));
    BitList.Add(ASolBit);
  end;
  {procedure RecordMinMax(AMove:TMove32);
  begin
    if AMove.From.Owner=nil then Exit;
    ASolBit:=TSolutionBit.Create(ot_Min,Self,AMove,nil,MinRec.Entry(AMove.OwnChoice.Rank));
    BitList.Add(ASolBit);
    ASolBit:=TSolutionBit.Create(ot_Max,Self,AMove,nil,MaxRec.Entry(AMove.OwnChoice.Rank));
    BitList.Add(ASolBit);
  end; }
  procedure RecordStratData(AChoice:TChoice32);
  begin
    with AChoice do if ObjType=ot_Strat then begin
      ASolBit:=TSolutionBit.Create(Game);
      ASolBit.SetData(ot_StrProb,Self,AChoice,nil,Probas.Entry(AChoice.Rank));
      BitList.Add(ASolBit);
      ASolBit:=TSolutionBit.Create(Game);
      ASolBit.SetData(ot_StrInct,Self,AChoice,nil,Incents.Entry(AChoice.Rank));
      BitList.Add(ASolBit);
    end;
  end;
begin
  BitList.FreeAll(ot_All);
  with Game as TGameType32 do begin
    NodeList.ForEach(@RecordNodeBelief);
    MoveList.ForEach(@RecordMoveData);
    ChoiceList.ForEach(@RecordStratData);
    {MoveList.ForEach(@RecordMinMax); }
  end;
end;

procedure TSolution32.SetDisplay(HasProba,HasBelief,HasExpect:Boolean);
begin
  SolDisp:=[];
  if HasProba then SolDisp:=SolDisp+[dc_Proba];
  if HasBelief then SolDisp:=SolDisp+[dc_Belief];
  if HasExpect then SolDisp:=SolDisp+[dc_Expect];
end;

procedure TSolution32.DrawObject(ACanvas:TCanvas);
    procedure ShowOwnBits(ABit:TSolutionBit);
    begin
      with ABit do case ObjType of
        ot_Proba,ot_StrProb  : if dc_Proba in SolDisp then DrawObject(ACanvas);
        ot_Belief : if dc_Belief in SolDisp then DrawObject(ACanvas);
        ot_Expect,ot_Incent,ot_StrInct : if dc_Expect in SolDisp then DrawObject(ACanvas);
      end;
    end;
begin
  with ACanvas do begin
    Brush.Color:=clWhite;
    Font.Color:=clBlack;
    Font.Style:=[];
    Font.Size:=Zoom(8);
    {TextOut(Zoom(XPos),Zoom(YPos),Self.Name); }
    BitList.ForEach(@ShowOwnBits);
  end;
end;

procedure TSolution32.SetShown(IsIt:Boolean);
begin
  IsShown:=IsIt;
end;

destructor TSolutionBit.Destroy;
begin
  Solution:=nil;
  inherited Destroy;
end;

procedure TSolutionBit.SetData(ABitType:Integer;AHeader:TGameObject32;
                               AWhere:TGameObject32;AWhom:TPlayer32;AValue:Real);
begin
  ObjType:=ABitType;
  Solution:=AHeader;
  Where:=AWhere;
  Whom:=AWhom;
  Value:=AValue;
  case ObjType of
    ot_Belief   : SetName('b= ');
    ot_Proba,
    ot_StrProb  : SetName('p= ');
    ot_Incent,
    ot_StrInct  : SetName('e= ');
    ot_Expect   : SetName('E= ');
    ot_Deriv    : SetName('D= ');
    ot_Max      : SetName('M= ');
    ot_Min      : SetName('m= ');
    ot_Depth    : SetName('d= '); 
  end;
  SetName(Name+FloatToStrF(Value,ffGeneral,floatdgts,floatdgts));
end;

function TSolutionBit.Description(ForWhat:Integer) : String;
begin
  inherited Description(ForWhat);
  TextLine:=TextLine+IntToStr(Solution.ResetRank);
  StrLenAdjust(2*sl_Name+7*sl_Short,Textline);
  Description:=TextLine;
end;

procedure TSolutionBit.SetLine(AStr:String);
begin
  inherited SetLine(AStr);
  SubStr:=ShowStringPart(AStr,2*sl_Name+6*sl_Short+1,sl_Short);
  SolRank:=ValidInt(SubStr);
end;

function TSolutionBit.Restore:Boolean;
begin
  Restore:=True;
  with TGameType32(Game) do begin
    if (WhomRank>0) and (WhomRank<=PlayerList.Count)
    then Whom:=PlayerList.Items[WhomRank-1];
    if (SolRank>0) and (SolRank<=SolutionList.Count)
    then Solution:=SolutionList.Items[SolRank-1];
    if Solution<>nil
    then begin
      TSolution32(Solution).BitList.Add(Self);
      if (WhereRank>0) then case ObjType of
      ot_Proba,
      ot_Incent  : if (WhereRank<=MoveList.Count)
                   then Where:=MoveList.Items[WhereRank-1];
      ot_Belief,
      ot_Expect  : if (WhereRank<=NodeList.Count)
                   then Where:=NodeList.Items[WhereRank-1];
      ot_StrProb,
      ot_StrInct : if (WhereRank<=ChoiceList.Count)
                   then Where:=ChoiceList.Items[WhereRank-1];
      end;
      SetData(ObjType,Solution,Where,Whom,Value);
    end;
  end;
end;

procedure TSolutionBit.DrawObject(ACanvas:TCanvas);
begin
  if IsArtificial then Exit;
  with ACanvas do begin
    case ObjType of
      ot_Belief   : begin XPos:=Where.XPos+2*PayGap; YPos:=Where.YPos-PayGap; end;
      ot_Proba    : begin XPos:=Where.XPos-PayGap; YPos:=Where.YPos-NameGap-2*PayGap; end;
      ot_StrProb  : begin XPos:=Where.XPos-PayGap; YPos:=Where.YPos-NameGap+6*PayGap; end;
      ot_Incent   : begin XPos:=Where.XPos-PayGap; YPos:=Where.YPos-NameGap-4*PayGap; end;
      ot_StrInct  : begin XPos:=Where.XPos-PayGap; YPos:=Where.YPos-NameGap+8*PayGap; end;
      ot_Expect   : begin XPos:=Where.XPos-PayGap;YPos:=Where.YPos+PayGap*
                           (2+2*TGameType32(Solution.Game).PlayerList.IndexOf(Whom)); end;
      ot_Deriv    : begin XPos:=Where.XPos-PayGap; YPos:=Where.YPos-NameGap-6*PayGap; end;
      ot_Max      : begin XPos:=Where.XPos-PayGap; YPos:=Where.YPos-NameGap+2*PayGap; end;
      ot_Min      : begin XPos:=Where.XPos-PayGap; YPos:=Where.YPos-NameGap+4*PayGap; end;
      ot_Depth    : begin XPos:=Where.XPos-PayGap; YPos:=Where.YPos-NameGap+4*PayGap; end;
    end;
    Brush.Color:=clWhite;
    if (Whom<>nil)
    then Font.Color:=Whom.Color
    else Font.Color:=clBlack;
    Font.Size:=Zoom(8);
    TextOut(Zoom(XPos),Zoom(YPos),Name);
    if (ObjType=ot_Proba) and (Value=0) then TMove32(Where).DrawCurve(False,ACanvas);
    if (ObjType=ot_Belief) and (Value=0) then TNode32(Where).DrawNode(False,ACanvas);
  end;
end;

constructor TSolutionGroup.Create(AGame:TFakeGame);
begin
  Game:=AGame;
  ObjType:=ot_SolGroup;
  Basis:=TGameList.Create;
  with Game as TGameType32 do Optimality:=TBoolVect.Create(ChoiceList.Count,Game);
end;

destructor TSolutionGroup.Destroy;
begin
  Optimality.Free;
  Basis.Clear;
  Basis.Free;
  inherited Destroy;
end;

procedure TSolution32.SetSolBelief(ANode:TNode32);
begin
  with ANode do Beliefs.SetEntry(False,Rank,Fade(Belief));
end;

procedure TSolution32.SetSolProba(AChoice:TChoice32);
begin
  with AChoice do
  if Source.Owner=nil
  then Probas.SetEntry(False,Rank,1)
  else if (Method<>sm_Group)
       then Probas.SetEntry(False,Rank,Fade(Proba))
       else if IsOptimum
            then Probas.SetEntry(False,Rank,1)
            else Probas.SetEntry(False,Rank,0);
end;

procedure TSolution32.SetSolIncent(AChoice:TChoice32);
begin
  with AChoice do begin
    Incents.SetEntry(False,Rank,Fade(Incentive));
    Deviate.SetEntry(False,Rank,Fade(Source.BestProspect-Incentive));
    Optimality.SetEntry(Rank,IsOptimum);
  end;
end;

procedure TSolution32.SetSolExpect(APlayer:TPlayer32;ANode:TNode32;AnExpect:Real);
begin
  Expects.SetEntry(False,APlayer.Rank,ANode.Rank,Fade(AnExpect));
end;

function TSolution32.FindOwnGroup:TSolutionGroup;
  procedure FindAGroup(AGroup:TSolutionGroup);
  begin
    if OwnGroup<>nil then Exit;
    if BelongsToGroup(AGroup,True) then OwnGroup:=AGroup;
  end;
begin
  OwnGroup:=nil;
  with Game as TGameType32 do SolGroupList.ForEach(@FindAGroup);
  FindOwnGroup:=OwnGroup;
end;

function TSolution32.IsInManyGroups:Boolean;
var OneGroup,ManyGroups:Boolean;
  procedure CheckIfIsIn(AGroup:TSolutionGroup);
  begin
    if ManyGroups then Exit;
    if AGroup.Basis.HasItem(Self)
    then if OneGroup
         then ManyGroups:=True
         else OneGroup:=True;
  end;
begin
  OneGroup:=False;
  ManyGroups:=False;
  with Game as TGameType32 do SolGroupList.ForEach(@CheckIfIsIn);
  IsInManyGroups:=ManyGroups;
end;

procedure TSolution32.RecordSolution;
  procedure SetSolutionNodes(ANode:TNode32);
    procedure RecordExpectation(APlayer:TPlayer32);
    begin
      with Game as TGameType32 do
      SetSolExpect(APlayer,ANode,Expect.Entry(APlayer.Rank,ANode.Rank));
    end;
  begin
      if ANode.Owner<>nil then SetSolBelief(ANode);
      with Game as TGameType32 do PlayerList.ForEach(@RecordExpectation);
  end;
  procedure SetSolutionChoices(AChoice:TChoice32);
  begin
    if AChoice.Source.Owner<>nil
    then begin
      SetSolProba(AChoice);
      SetSolIncent(AChoice);
    end;
  end;
begin
  with Game as TGameType32 do begin
    NodeList.ForEach(@SetSolutionNodes);
    ChoiceList.ForEach(@SetSolutionChoices);
  end;
  FillBitList;
end;

procedure TSolutionGroup.MatchOptimality(ASolution:TSolution32);
  procedure MatchChoice(AChoice:TChoice32);
  begin
    with AChoice do begin
      if IsArtificial then Exit;
      if Source.Owner=nil then Exit;
      Optimality.SetEntry(Rank,ASolution.Optimality.Entry(Rank));
    end;
  end;
begin
  with Game as TGameType32 do ChoiceList.ForEach(@MatchChoice);
end;

procedure TSolutionGroup.UpdateBasis;
var HasChanged: Boolean; Counter:Integer;
  procedure ExtendFrom(ASolution:TSolution32);
    procedure ExtendTo(BSolution:TSolution32);
    begin
      if HasChanged then Exit;
      if BSolution=ASolution then Exit;
      if Extend(ASolution,BSolution) then HasChanged:=True;
      if Extend(BSolution,ASolution) then HasChanged:=True;
    end;
  begin
    Basis.ForEach(@ExtendTo);
  end;
begin
  Counter:=0;
  if Basis.Count>1
  then repeat
    HasChanged:=False;
    Basis.ForEach(@ExtendFrom);
    Counter:=Counter+1;
  until (Counter>=5) or not HasChanged;
end;

procedure TGameType32.UpdateAllBases(ASolution:TSolution32);
  procedure UpdateABasis(AGroup:TSolutionGroup);
  begin
    if ASolution<>nil then if not AGroup.Basis.HasItem(ASolution) then Exit;
    AGroup.UpdateBasis;
  end;
begin
  SolGroupList.ForEach(@UpdateABasis);
  ReOrganizeGroups;
end;

function TSolutionGroup.Extend(NewSolution,OldSolution:TSolution32):Boolean;
var Lambda,Mu,NewProba,OldProba,OldDelta,NewDelta:Real;
  procedure ExtendProba(AChoice:TChoice32);
  begin {Find a Mu such that convex combination yields a zero or 1 proba}
    with AChoice do begin
      if IsArtificial then Exit;
      if Source.Owner=nil then Exit;
      {Testing probas}
      NewProba:=NewSolution.Probas.Entry(Rank);
      OldProba:=OldSolution.Probas.Entry(Rank);
      if Abs(NewProba-OldProba)<=LowProba then Exit;
      if (NewProba>OldProba)
      then try Lambda:=(1-OldProba)/(NewProba-OldProba);
      except on Exception do Lambda:=LargeMu end;
      if (NewProba<OldProba)
      then try Lambda:=OldProba/(OldProba-NewProba);
      except on Exception do Lambda:=LargeMu end;
      if (Lambda<Mu) then Mu:=Lambda;
    end;
  end;
  procedure ExtendDeviate(AChoice:TChoice32);
  begin
    with AChoice do begin
      if IsArtificial then Exit;
      if Source.Owner=nil then Exit;
      {Deviate is best prospect of source minus incentive. Want to make it zero}
      NewDelta:=NewSolution.Deviate.Entry(Rank);
      OldDelta:=OldSolution.Deviate.Entry(Rank);
      if NewDelta>=OldDelta-Convergence then Exit
      else try Lambda:=OldDelta/(OldDelta-NewDelta);
      except on Exception do Lambda:=LargeMu end;
      if (Lambda<Mu) then Mu:=Lambda;
    end;
  end;
begin
  Extend:=False;
  {if OldSolution.Method=sm_Group then Exit;
  if NewSolution.Method=sm_Group then Exit; }
  Mu:=LargeMu;
  with Game as TGameType32 do begin
    ChoiceList.ForEach(@ExtendProba);
    {if IsDebug then MakeDebugInfo('Proba extention Mu= '+FloatToStrF(Mu,ffFixed,6,6)); }
    ChoiceList.ForEach(@ExtendDeviate);
    {if IsDebug then MakeDebugInfo('Deviate extention Mu= '+FloatToStrF(Mu,ffFixed,6,6)); }
    if (Mu>1.0) and (Mu<LargeMu) then Extend:=MakeExtension(NewSolution,OldSolution,Mu);
    {if IsDebug and (Mu=LargeMu) then MakeDebugInfo('Extention fails. New solution too close.');
    if IsDebug and (Mu<=1) then MakeDebugInfo('Extention fails.');}
  end;
end;

function TGameType32.MakeExtension(NewSolution,OldSolution:TSolution32;Mu:Real):Boolean;
  procedure MakeNewProba(AChoice:TChoice32);
  begin
    with AChoice do begin
      if Source.Owner=nil then Exit;
      if IsArtificial then Exit; 
      SetProba((1-Mu)*OldSolution.Probas.Entry(Rank)+Mu*NewSolution.Probas.Entry(Rank));
    end;
  end;
begin
  MakeExtension:=False;
  ChoiceList.ForEach(@MakeNewProba);
  NormalizeProbas;
  if MakeBestReplies(False)
  then if IsOptimal
       then begin
         NewSolution.RecordSolution;
         MakeExtension:=True;
       end;
  {if IsDebug then begin
    MakeDebugInfo('Extending by Mu= '+FloatToStrF(Mu,ffFixed,6,6)+' to..');
    ShowProba;
  end;}
end;

procedure TGameType32.SaveSolution(ASolveMethod,ASolveConcept:Integer);
var NextGroup:TSolutionGroup; NextSolution:TSolution32; {GroupMarker: TSolution32;}
  procedure UpdateABasis(AGroup:TSolutionGroup);
  begin
    if NextSolution.BelongsToGroup(AGroup,False)
    and not NextGroup.Basis.HasItem(NextSolution)
    then AGroup.Basis.Add(NextSolution);
  end;
  procedure CheckInNewGroup(ASolution:TSolution32);
  begin
    if ASolution.BelongsToGroup(NextGroup,False)
    and not NextGroup.Basis.HasItem(ASolution)
    then NextGroup.Basis.Add(ASolution);
  end;
begin
  NextSolution:=TSolution32.Create(Self);
  NextSolution.SetSolType(ASolveMethod,ASolveConcept);
  NextSolution.RecordSolution; {Store current game solution into NextSolution}
  if not SolutionAlreadyExists(NextSolution,nil)
  then begin

    SolutionList.Add(NextSolution);
    NextGroup:=NextSolution.FindOwnGroup;
    if NextGroup=nil
    then begin
      NextGroup:=SolutionGroupFor(NextSolution);
      SolGroupList.Add(NextGroup);
      NextGroup.UpdateName;
      SolutionList.ForEach(@CheckInNewGroup);
    end;

    SolGroupList.ForEach(@UpdateABasis);
    UpdateAllBases(NextSolution);
    RemoveDuplicateSolutions;
    ReOrganizeGroups;

    SolveDlg.UpdateSolutionBox(True);
    if IsDebug then MakeDebugInfo('>>>>>>>>>>>>>>>>>>>>>> New solution <<<<<<<<<<<<<<<<<');
  end else if IsDebug then MakeDebugInfo('>>>>>>>>>>>>>>>>>>>>>> Duplicate solution'+IntToStr(NextSolution.HitCount)+' <<<<<<<<<<<<<<<<<');

end;

procedure TSolutionGroup.UpdateName;
begin
  SetName(FloatToStrF(1+TGameType32(Game).SolGroupList.IndexOf(Self),ffGeneral,3,3));
end;

function TSolution32.BelongsToGroup(AGroup:TSolutionGroup;IsOwn:Boolean):Boolean;
  procedure CheckChoiceOptimality(AChoice:TChoice32);
  begin
    with AChoice do begin
      if IsArtificial then Exit;
      if Source.Owner=nil then Exit;
      {To belong, Group-optimality(Choice) must imply Choice-optimality}
      if AGroup.Optimality.Entry(Rank) and not Optimality.Entry(Rank)
      then BelongsToGroup:=False;
      if IsOwn then begin
        {To be own group, Choice-optimality must imply Group-optimality(Choice)}
        if Optimality.Entry(Rank) and not AGroup.Optimality.Entry(Rank)
        then BelongsToGroup:=False;
      end else begin
        {To belong, not group-optimal must imply zero proba of choice}
        if (Probas.Entry(Rank)>FadeValue) and not AGroup.Optimality.Entry(Rank)
        then BelongsToGroup:=False;
      end;
    end;
  end;
begin
  BelongsToGroup:=True;
  with Game as TGameType32 do ChoiceList.ForEach(@CheckChoiceOptimality);
end;

function TGameType32.SolutionAlreadyExists(ACandidate:TSolution32;InGroup:TSolutionGroup):Boolean;
var Distance:Real;
  procedure CheckSolution(ASolution:TSolution32);
  begin
    if (InGroup<>nil) then if not InGroup.Basis.HasItem(ASolution) then Exit;
    Distance:=ACandidate.DistanceTo(ASolution);
    if (Distance<MaxDistance)
    then begin
      SolutionAlreadyExists:=True;
      if IsDebug then begin
        with ASolution do SetHitCount(HitCount+1);
        ACandidate.SetHitCount(ASolution.HitCount);
      end;
    end;
  end;
begin
  SolutionAlreadyExists:=False;
  if ACandidate<>nil
  then SolutionList.ForEach(@CheckSolution);
end;

function TSolution32.DistanceTo(ASolution:TSolution32):Real;
var Distance:Real;
  procedure AddProbaDistance(AChoice:TChoice32);
  begin
    with AChoice do begin
      if IsArtificial then Exit;
      if Source.Owner=nil then Exit;
      Distance:=Max(Distance,Abs(Self.Probas.Entry(Rank)-ASolution.Probas.Entry(Rank)));
    end;
  end;
  procedure AddBeliefDistance(ANode:TNode32);
  begin
    with ANode do begin
      if IsArtificial then Exit;
      if Owner=nil then Exit;
      Distance:=Max(Distance,Abs(Belief-ASolution.Beliefs.Entry(Rank)));
    end;
  end;
begin
  Distance:=0;
  with Game as TGameType32 do begin
    ChoiceList.ForEach(@AddProbaDistance);
    NodeList.ForEach(@AddBeliefDistance);
  end;
  DistanceTo:=Distance;
end;

function TGameType32.NormalizeProbas:Boolean;
var TotalProb:Real;
  procedure NormalizeChoices(AnInfo:TInfo32);
    procedure AddProba(AChoice:TChoice32);
    begin
      with AChoice do begin
        if Proba<MinProba then SetProba(0);
        TotalProb:=TotalProb+Proba;
      end;
    end;
    procedure Normalize(AChoice:TChoice32);
    begin
      AChoice.SetProba(AChoice.Proba/TotalProb);
    end;
  begin
    with AnInfo do if Owner<>nil {Chance choice proba set to one at create}
    then begin
      TotalProb:=0;
      Choices.ForEach(@AddProba);
      if (TotalProb>=MinProba)
      then Choices.ForEach(@Normalize)
      else NormalizeProbas:=False;
    end;
  end;
begin
  NormalizeProbas:=True;
  InfoList.ForEach(@NormalizeChoices);
  {if IsDebug then ShowProba; }
end;

procedure TGameType32.RemoveDuplicateSolutions;
var Duplicate:TSolution32; Counter:Integer;
  procedure RemoveDuplicate(AGroup:TSolutionGroup);
  begin
    if AGroup.Basis.HasItem(Duplicate)
    then AGroup.Basis.Remove(Duplicate);
  end;
  procedure FindDuplicate(ASolution:TSolution32);
    procedure CheckIfDuplicate(BSolution:TSolution32);
    begin
      if BSolution=ASolution then Exit;
      if ASolution.DistanceTo(BSolution)<=MaxDistance
      then Duplicate:=BSolution;
    end;
  begin
    if Duplicate<>nil then Exit;
    SolutionList.ForEach(@CheckIfDuplicate);
  end;
begin
  Counter:=0;
  repeat
    Duplicate:=nil;
    SolutionList.ForEach(@FindDuplicate);
    if Duplicate<>nil
    then begin
      SolGroupList.ForEach(@RemoveDuplicate);
      SolutionList.Remove(Duplicate);
      MainForm.CloseSolutionWindow(Self,Duplicate);
      Duplicate.Free;
    end;
    Counter:=Counter+1;
  until (Counter>=10) or (Duplicate=nil);
end;

procedure TGameType32.ReOrganizeGroups;
var NewGroup:TSolutionGroup; Counter:Integer;
  procedure SolutionRename(ASolution:TSolution32);
  begin
    ASolution.UpdateName;
  end;
  procedure GroupRename(AGroup:TSolutionGroup);
  begin
    AGroup.UpdateName;
  end;
  procedure CheckHasOwnGroup(ASolution:TSolution32);
  begin
    if ASolution.FindOwnGroup=nil
    then begin
      NewGroup:=SolutionGroupFor(ASolution);
      SolGroupList.Add(NewGroup);
      NewGroup.UpdateName;
    end;
  end;
  procedure FindUselessGroup(AGroup:TSolutionGroup);
  begin
    if not AGroup.HasOwnSolution
    then NewGroup:=AGroup;
  end;
  procedure CheckGroups(ASolution:TSolution32);
    procedure CheckBelonging(AGroup:TSolutionGroup);
    begin
      if ASolution.BelongsToGroup(AGroup,False)
      and not AGroup.Basis.HasItem(ASolution)
      then AGroup.Basis.Add(ASolution);
    end;
  begin
    SolGroupList.ForEach(@CheckBelonging);
  end;
  procedure ReFillSolutions(AGroup:TSolutionGroup);
    procedure Refill(ASolution:TSolution32);
    begin
      if not SolutionList.HasItem(ASolution)
      then SolutionList.Add(ASolution);
    end;
  begin
    AGroup.Basis.ForEach(@ReFill);
  end;
begin
  SolutionList.ForEach(@CheckHasOwnGroup);
  Counter:=0;
  repeat
    NewGroup:=nil;
    SolGroupList.ForEach(@FindUselessGroup);
    if NewGroup<>nil
    then begin
      SolGroupList.Remove(NewGroup);
      NewGroup.Free;
    end;
    Counter:=Counter+1;
  until (Counter>=10) or (NewGroup=nil);
  SolGroupList.ForEach(@GroupRename);
  SolutionList.ForEach(@CheckGroups);
  SolutionList.ForEach(@SolutionRename);
  SolutionList.Clear;
  SolGroupList.ForEach(@ReFillSolutions);
end;

function TSolutionGroup.HasOwnSolution:Boolean;
  procedure FindOwnSolution(ASolution:TSolution32);
  begin
    if ASolution.FindOwnGroup=Self
    then HasOwnSolution:=True;
  end;
begin
  HasOwnSolution:=False;
  TGameType32(Game).SolutionList.ForEach(@FindOwnSolution);
end;

function TGameType32.SolutionGroupFor(ASolution:TSolution32):TSolutionGroup;
var AGroup:TSolutionGroup;
begin
  AGroup:=TSolutionGroup.Create(Self);
  AGroup.MatchOptimality(ASolution);
  SolutionGroupFor:=AGroup;
end;



end.
