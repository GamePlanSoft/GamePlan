unit Solve32;    {From Feb02}

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls, Type32, Game32Type, Game32Solve, Dialogs, Constants, ComCtrls;

type

  TSolveDlg = class(TForm)
    ProgressBar: TProgressBar;
    CancelBtn: TBitBtn;
    SolutionBox: TListBox;
    ShowBtn: TButton;
    DeleteBtn: TButton;
    CloseBtn: TBitBtn;
    ProgText: TStaticText;
    ShowLog: TButton;
    procedure CancelBtnClick(Sender: TObject);
    procedure CloseBtnClick(Sender: TObject);
    procedure SolutionBoxClick(Sender: TObject);
    procedure ShowBtnClick(Sender: TObject);
    procedure DeleteBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    function CloseQuery: Boolean; override;
    procedure ShowLogClick(Sender: TObject);

  private
    { Private declarations }
    IsProfiling,
    IsDone,
    HitFacet : Boolean;
    IterationCount,
    HitFacetCount,
    MaxStepNumber,
    MaxSampleNumber
    {MinSpeedTurns,
    MaxSpeedTurns{,
    LowSpeedTurn{,
    HiSpeedTurn} : Integer;
    ConvTest,
    Progress,
    StartNorm,
    OldNorm,
    StepSize : Real;
    ViewList : TGameList;
    procedure InitActivity(ForAll:Boolean);
    function ProbaInit(ForSampling:Boolean):Boolean;
    {procedure SetAllActive;}
    function FindNextFrom(AnInfo:TInfo32):TInfo32;
    procedure CheckOptimality;
    procedure Search(AComplexity:Integer;FromInfo:TInfo32);
    function UpdateProbas(ForSampling:Boolean):Boolean;
    {function NormalizeProbas:Boolean; }
    procedure ControlStepSize;
    {procedure CheckSpeed;}
    procedure CheckFacet;
    procedure InactivateNilChoices;
    {function IsDeadEnd:Boolean;
    {procedure ReportChoices;}
    function MakeComplexity(AnInfo:TInfo32;AComplexity:Integer): Integer;
    procedure PostProgress(Complexity:Integer);
    procedure MakeProfile;
    function HasDominatedProfile:Boolean;
    procedure Eliminate;
    function HasDominatedChoice(AProfile:TProfile):Boolean;
    procedure DeleteDominatedProfiles;
    procedure PureSolve;
    procedure MixedSolve(ForSampling:Boolean);
    procedure SetDisplay(IsSolving:Boolean);
  public
    { Public declarations }
    IsBusy       : Boolean;
    GameToSolve  : TGameType32;
    SlctSolution : TSolution32; {Solution type}
    SlctProfile  : TProfile;
    procedure InitDialog(ForSolving:Boolean;AGame:TGameType32);
    procedure UpdateSolutionBox(WhileGrouping:Boolean);
  protected
    procedure ExecuteDlg;
  end;

var
  SolveDlg: TSolveDlg; ALine:TBug;


implementation

uses AuditUnit, SolvOptDlg, Matrices, ChildWin, MainGP32;

{$R *.DFM}

 {----------------------------------------------}
 {----Solution methods implementation-----------}
 {----------------------------------------------}

function TSolveDlg.CloseQuery: Boolean;
begin
  if IsDone then CloseQuery:=True else CloseQuery:=False;
end;

procedure TSolveDlg.SetDisplay(IsSolving:Boolean);
begin
  if IsSolving then begin
    CancelBtn.Show;
    CloseBtn.Hide;
    DeleteBtn.Hide;
    ProgText.Show;
    case SolveOptions.SolveMethod of
      {sm_Profile : Caption:='Profiling...'; }
      sm_Pure    : Caption:='Solving for pure equilibria';
      sm_Mixed   : Caption:='Solving for mixed equilibria';
    end;
    IsDone:=False;
  end else begin
    CancelBtn.Hide;
    CloseBtn.Show;
    ProgText.Hide;
    DeleteBtn.Show;
    Caption:='Solved';
    IsDone:=True;
  end;
end;

procedure TSolveDlg.InitDialog(ForSolving:Boolean;AGame:TGameType32);
begin
  SlctSolution:=nil;
  SlctProfile:=nil;
  GameToSolve:=AGame;
  SolutionBox.Clear;
  ViewList.Clear;
  SetDisplay(ForSolving);
  if ForSolving then begin
    with ProgressBar do Position:=Min;
    ExecuteDlg;
  end else begin
    with ProgressBar do Position:=Max;
    UpdateSolutionBox(False);
  end;
end;

procedure TSolveDlg.ExecuteDlg;
var I:Integer;
begin
  {GameToSolve.BugList.FreeAll;  {Only for testing}
  IsBusy:=True;
  GameToSolve.InitSolving;

  {if IsDebug then with GameToSolve do begin
      NullGroup:=TSolutionGroup.Create(GameToSolve);
      SolGroupList.Add(NullGroup);
      NullGroup.SetName('Null');
  end else GameToSolve.NullGroup:=nil;  }

  {case SolveOptions.SolveDepth of
    sd_LowDepth  : begin MaxStepNumber:=sd_LowDepth; MaxSampleNumber:=50; MaxSpeedTurns:=2; MinSpeedTurns:=2; end;
    sd_MidDepth  : begin MaxStepNumber:=sd_MidDepth; MaxSampleNumber:=200; MaxSpeedTurns:=3; MinSpeedTurns:=3; end;
    sd_HighDepth : begin MaxStepNumber:=sd_HighDepth; MaxSampleNumber:=500; MaxSpeedTurns:=4; MinSpeedTurns:=4; end;
  end;}

  MaxStepNumber:=12;
  MaxSampleNumber:=200;
  Progress:=0;
  IterationCount:=0;
  HitFacetCount:=0;

  if SolveOptions.SolveMethod=sm_Sample
  then begin
    Caption:='Sampling...';
    RandSeed:=1;
    I:=0;
    Progress:=0;
    with ProgressBar do Position:=Min;
    repeat
      InitActivity(True);
      I:=I+1;
      IterationCount:=IterationCount+1;
      MixedSolve(True);
      PostProgress(MaxSampleNumber);
      if IsDone then I:=MaxSampleNumber;
    until I>=MaxSampleNumber;
  end;

  if SolveOptions.SolveMethod in [sm_Pure,sm_Mixed]
  then begin
    InitActivity(False);
    IsProfiling:=True;
    Caption:='Profiling...';
    GameToSolve.ProfileList.FreeAll(ot_All);
    Search(1,GameToSolve.StartNode.Family); {Construct profiles. Initializes activity}
    IsProfiling:=False;
  end;

  if SolveOptions.SolveMethod=sm_Mixed
  then begin
    Caption:='Eliminating...';
    Eliminate;
    Progress:=0;
    UpdateSolutionBox(False);
    Caption:='Exploring...';
    with ProgressBar do Position:=Min;
    Search(1,GameToSolve.StartNode.Family);
  end;

  Caption:='Organizing...';
  with GameToSolve do begin
    UpdateAllBases(nil);
    RemoveDuplicateSolutions;
    ReOrganizeGroups;
  end;
  UpdateSolutionBox(True);

  with GameToSolve do if SolutionList.Count>0 then SetState(gs_Solved)
  else begin SetState(gs_CanClose);ReturnToEdit; end;

  Caption:='Cleaning up...';
  GameToSolve.CleanUp;
  SetDisplay(False);
  IsBusy:=False;

  if GameToSolve.SolutionList.Count=0
  then begin
    Hide;
    MessageDlg('No solution found.', mtInformation, [mbOk], 0);
  end;
end;

procedure TSolveDlg.CancelBtnClick(Sender: TObject);
begin
  IsDone:=True;
end;

procedure TSolveDlg.CloseBtnClick(Sender: TObject);
begin
  Hide;
end;

procedure TSolveDlg.UpdateSolutionBox(WhileGrouping:Boolean);
  procedure ReFillList(BItem:TGameObject32);
  begin
    with BItem as TSolution32 do if not IsShown
    then ViewList.Add(BItem);
  end;
  procedure ShowList(AnItem:TGameObject32);
  begin
    SolutionBox.Items.Append(AnItem.Name);
  end;
begin
  SolutionBox.Clear;
  ViewList.Clear;
  GameToSolve.SolutionList.ForEach(@ReFillList);
  ViewList.ForEach(@ShowList);
end;

procedure TSolveDlg.SolutionBoxClick(Sender: TObject);
var SlctIndx:Integer;
begin
  SlctIndx:=SolutionBox.ItemIndex;
  if SlctIndx>=0
  then SlctSolution:=ViewList.Items[SlctIndx]
  else begin SlctSolution:=nil; {SlctProfile:=nil;} end;
end;

procedure TSolveDlg.ShowBtnClick(Sender: TObject);
var AGameWindow:TMDIChild;
begin
  AGameWindow:=MainForm.GameWindow(GameToSolve);
  if (AGameWindow<>nil)
  then case SolveOptions.SolveMethod of
      {sm_Profile : if SlctProfile<>nil then
                   MainForm.OpenProfileWindow(SlctProfile.Name,GameToSolve,SlctProfile);}
      sm_Pure,
      sm_Mixed,
      sm_Sample   : if SlctSolution<>nil then begin
                   MainForm.OpenSolutionWindow(SlctSolution.Name,GameToSolve,SlctSolution);
                   SlctSolution.SetShown(True);
                   SlctSolution:=nil;
                   UpdateSolutionBox(False);
                   end;
  end;
  {if ViewList.Count=0 then Hide;}
end;

procedure TSolveDlg.DeleteBtnClick(Sender: TObject);
var AGameWindow:TMDIChild;
begin
  if SlctSolution=nil then Exit;
  AGameWindow:=MainForm.GameWindow(GameToSolve);
  if (AGameWindow<>nil)
  then begin
    MainForm.CloseSolutionWindow(GameToSolve,SlctSolution);
    GameToSolve.DeleteSolution(SlctSolution);
    SlctSolution:=nil;
    UpdateSolutionBox(False);
  end;
  {if ViewList.Count=0 then Hide;}
end;

procedure TSolveDlg.InitActivity(ForAll:Boolean);
  procedure SetActivity(AnInfo:TInfo32);
  begin
    with AnInfo do if (Owner<>nil)
    then SetActive(False) {Will have to be searched choice by choice}
    else begin            {Make chance info and all chance choices active}
      SetActive(True);
      ResetChoiceActivity(True,Choices.Count);
    end;
  end;
  procedure SetAllActive(AnInfo:TInfo32);
  begin
    with AnInfo do begin
      SetActive(True);
      ResetChoiceActivity(True,Choices.Count);
    end;
  end;
begin
  with GameToSolve do if ForAll
  then InfoList.ForEach(@SetAllActive)
  else InfoList.ForEach(@SetActivity);
end;

function TSolveDlg.FindNextFrom(AnInfo:TInfo32):TInfo32;
var NextFrom:TInfo32;
  procedure InspectMoves(AChoice:TChoice32);
    procedure CheckUpto(AMove:TMove32);
    begin
      with AMove do
      if (Upto<>nil)
      then if not (Upto.Family.IsActive)
           then NextFrom:=Upto.Family;
    end;
  begin
    AChoice.Instances.ForEach(@CheckUpto);
  end;
  procedure FindFreeInfo(AnInfo:TInfo32);
  begin
    if not AnInfo.IsActive
    then NextFrom:=AnInfo;
  end;
begin
  NextFrom:=nil;
  AnInfo.Choices.ForEach(@InspectMoves);
  if (NextFrom=nil)
  then GameToSolve.InfoList.ForEach(@FindFreeInfo);
  FindNextFrom:=NextFrom;
end;

function TSolveDlg.MakeComplexity(AnInfo:TInfo32;AComplexity:Integer): Integer;
begin
  MakeComplexity:=AComplexity; {If Owner is nil}
  with AnInfo do if (Owner<>nil)
  then if IsProfiling then MakeComplexity:=Choices.Count*AComplexity
  else case SolveOptions.SolveMethod of
    sm_Pure    : MakeComplexity:=Choices.Count*AComplexity;
    sm_Mixed   : MakeComplexity:=AnInfo.Complexity*AComplexity;
    sm_Sample  : MakeComplexity:=100;
  end;
end;

procedure TSolveDlg.Search(AComplexity:Integer;FromInfo:TInfo32);
var NextComplexity:Integer;
  procedure SearchFurther;
  var NextFrom:TInfo32;
  begin
    {Need to check whether active choice set at FromInfo is dominated.
    If so must exit but post progress}
    NextComplexity:=MakeComplexity(FromInfo,AComplexity);
    if not IsProfiling and FromInfo.IsDominatedSet
    then PostProgress(NextComplexity)
    else begin
      NextFrom:=FindNextFrom(FromInfo);
      if (NextFrom=nil)
      then begin
        PostProgress(NextComplexity);
        CheckOptimality; {Solve pure or mixed with active choices}
      end else Search(NextComplexity,NextFrom);
    end;
  end;
  procedure ChooseChoice(AChoice:TChoice32);
  begin
    if AChoice.IsDominated then Exit else
    with FromInfo do begin
      ResetChoiceActivity(False,Choices.Count);
      AChoice.SetActive(True);
      SearchFurther;
    end;
  end;
begin
  if (FromInfo=nil) or IsDone then Exit;
  with FromInfo do if (Owner=nil)
  then SearchFurther {since chance-owned info is always active}
  else begin
    SetActive(True);
    ResetChoiceActivity(False,Choices.Count);
    if IsProfiling then Choices.ForEach(@ChooseChoice) {Could use this with restricted to pure choices at this info}
    else while ExistNextChoiceSet(Choices.Count) do SearchFurther;
    SetActive(False);
  end;
end;

procedure TSolveDlg.PostProgress(Complexity:Integer);
var CrntStep:Integer;
begin
  try Progress:=Progress+1/Complexity; except on Exception do {nothing} end;
  ProgText.Caption:=FloatToStrF(100*Progress,ffFixed,4,2)+'%';
  CrntStep:=Round(ProgressBar.Max*Progress-ProgressBar.Position);
  if CrntStep>=1 then ProgressBar.StepBy(CrntStep);
  Application.ProcessMessages; 
end;

procedure TSolveDlg.CheckOptimality;
begin
    if IsProfiling then MakeProfile
    else begin
      IterationCount:=IterationCount+1;
      case SolveOptions.SolveMethod of
        {sm_Profile : MakeProfile;}
        sm_Pure    : PureSolve;
        sm_Mixed   : MixedSolve(False);
      end;
    end;
end;

function TSolveDlg.ProbaInit(ForSampling:Boolean):Boolean;
  procedure InitChoices(AnInfo:TInfo32);
    procedure SetRandom(AChoice:TChoice32);
    begin
      with AChoice do if IsActive
      then begin
           if ForSampling
           then SetProba(Random)
           else SetProba(1);
      end else SetProba(0); 
    end;
  begin
    with AnInfo do if Owner<>nil {Chance choice proba set to one at create}
    then Choices.ForEach(@SetRandom)  {Experimental}
  end;
begin
  GameToSolve.InfoList.ForEach(@InitChoices);
  ProbaInit:=GameToSolve.NormalizeProbas;
end;

function TSolveDlg.UpdateProbas(ForSampling:Boolean):Boolean;
  procedure UpdateProba(AChoice:TChoice32);
  begin
    with AChoice do if (Owner<>nil)
    then SetProba(Proba+StepSize*Direction);
  end;
begin
  CheckFacet;
  if ForSampling then InactivateNilChoices; {Must re-initialize activity}
  with GameToSolve do begin
    ChoiceList.ForEach(@UpdateProba);
    UpdateProbas:=NormalizeProbas;
  end;
end;

procedure TSolveDlg.CheckFacet;
  procedure CheckStepSize(AChoice:TChoice32);
  begin
    with AChoice do
    if (Proba+StepSize*Direction<0) and IsActive
    then begin
      HitFacet:=True;
      try StepSize:=Minimum(StepSize,-Proba/Direction);
      except on Exception do StepSize:=0.12345; end;
    end;
  end;
begin
  HitFacet:=False;
  GameToSolve.ChoiceList.ForEach(@CheckStepSize);
end;

procedure TSolveDlg.InactivateNilChoices;
  procedure CheckNilProba(AChoice:TChoice32);
  begin
    with AChoice do
    if (Proba+StepSize*Direction<MinProba)
    then SetActive(False)
    else SetActive(True);
  end;
begin
  GameToSolve.ChoiceList.ForEach(@CheckNilProba);
end;

{procedure TSolveDlg.CheckSpeed;
begin
  with GameToSolve do begin
    if Speed>TopSpeed
    then HiSpeedTurn:=HiSpeedTurn+1
    else HiSpeedTurn:=0;
    if StepSize<=MinSpeed
    then LowSpeedTurn:=LowSpeedTurn+1
    else LowSpeedTurn:=0;
  end;
end; }

procedure TSolveDlg.ControlStepSize;
begin
  if OldNorm=0 then Exit;
  try ConvTest:=(GameToSolve.NextNorm/OldNorm)*Exp(2*StepSize);
  except on Exception do ConvTest:=StepTest; end;
  if ConvTest>=StepTest
  then StepSize:=StepShrink*StepSize
  else StepSize:=InitStep;
  if StepSize<=MinStepSize then StepSize:=MinStepSize;
end;

{Elimination procedures}

procedure TSolveDlg.MakeProfile;
{var ASolution : TSolution32; }
begin
  with GameToSolve do begin
    if IsDebug then TestList.FreeAll(ot_All);
    PureToProbas;
    {if IsDebug then ShowProba;}
    SaveProfile;
    if IsOptimal then begin
      {if IsDebug then MakeDebugInfo('Pure solving..');
      {ASolution:=TSolution32.Create(GameToSolve); }
      SaveSolution(sm_Pure,sc_Perfect);
    end;
  end;
end;

function TSolveDlg.HasDominatedProfile:Boolean;
var IsComplete:Boolean;
  procedure CheckDomination(AChoice:TChoice32);
  begin
    with AChoice do if IsDominated then Exit {Otherwise looping}
    else if CheckDominated {AChoice is dominated}
    then begin
      SetDominated(True);
      IsComplete:=False;
    end;
  end;
begin
  HasDominatedProfile:=False;
  with GameToSolve do repeat
    IsComplete:=True;
    ChoiceList.ForEach(@CheckDomination);
    if not IsComplete then begin
      DeleteDominatedProfiles;
      HasDominatedProfile:=True;
    end;
  until IsComplete;
end;

procedure TSolveDlg.Eliminate;
  {procedure RecordMinimax(AMove:TMove32);
  var ASolBit:TSolutionBit;
  begin
    if AMove.From.Owner=nil then Exit;
    ASolBit:=TSolutionBit.Create(ot_Max,nil,AMove,nil,AMove.OwnChoice.MaxIncent);
    GameToSolve.MinMaxList.Add(ASolBit);
    ASolBit:=TSolutionBit.Create(ot_Min,nil,AMove,nil,AMove.OwnChoice.MinIncent);
    GameToSolve.MinMaxList.Add(ASolBit);
  end;  }
  {procedure SetAllInfoInactive(AnInfo:TInfo32);
  begin
    with AnInfo do if Owner<>nil then SetActive(False);
  end; }
  procedure RemakeMinMax(AChoice:TChoice32);
  begin
    AChoice.MakeMinMax;
  end;
  {procedure AddInitNorm(AnInfo:TInfo32);
  begin
    if AnInfo.Owner<>nil
    then GameToSolve.InitNorm:=GameToSolve.InitNorm+AnInfo.InitNorm;
  end; }
begin
  with GameToSolve do begin
    {MinMaxList.FreeAll;   {For debug }
    repeat
      ChoiceList.ForEach(@RemakeMinMax);
    until not HasDominatedProfile;
    {InitNorm:=0.0;
    InfoList.ForEach(@AddInitNorm);
    {MoveList.ForEach(@RecordMinimax); {For debug }
  end;
end;

function TSolveDlg.HasDominatedChoice(AProfile:TProfile):Boolean;
  procedure FindDominatedChoice(AChoice:TChoice32);
  begin
    with AChoice do if AProfile.ChoiceActivity.Entry(Rank) and IsDominated
                    then HasDominatedChoice:=True;
  end;
begin
  HasDominatedChoice:=False;
  GameToSolve.ChoiceList.ForEach(@FindDominatedChoice);
end;

procedure TSolveDlg.DeleteDominatedProfiles;
  procedure FindGarbage(AProfile:TProfile);
  begin
    if HasDominatedChoice(AProfile)
    then AProfile.SetUnclean;   
  end;
begin
  with GameToSolve do begin
    ProfileList.ForEach(@FindGarbage);
    ProfileList.FreeAll(ot_Unclean);
  end;
end;

{Solve procedures}

procedure TSolveDlg.PureSolve;
begin
  with GameToSolve do begin
    {if IsDebug then TestList.FreeAll(ot_All); }
    PureToProbas;
    if MakeBestReplies(False)
    then if IsOptimal
         then begin
           {if IsDebug then MakeDebugInfo('Pure solving..');}
           SaveSolution(sm_Pure,sc_Perfect);
         end;
  end;
end;

procedure TSolveDlg.MixedSolve(ForSampling:Boolean);
var HasConverged:Boolean; I,HitFacetNumber:Integer; InterationStr: String;
begin
  with GameToSolve do begin
    {if IsDebug then TestList.FreeAll(ot_All); }
    if IsDebug then begin
      InterationStr:='**************** Iteration # '+IntToStr(IterationCount)+' '+'Hit facet # '+IntToStr(HitFacetCount)+'**********************';
      MakeDebugInfo(InterationStr);
    end;

    if not ProbaInit(ForSampling) then Exit; {COULD HAVE A REPEAT LOOP WITH SEVERAL INIT!!!!!!}
    if not MakeBestReplies(True) then Exit;
    {if not InitAssociations then Exit; } {************************************ WE'RE HERE !!!!! ************************}
    I:=1; HasConverged:=False; StepSize:=InitStep; OldNorm:=1; HitFacetNumber:=0; {HiSpeedTurn:=0; LowSpeedTurn:=0; }
    repeat

    if IsDebug then begin
      ShowFrequent;
      ShowBelief;
      ShowActivity;
      ShowProba;
      {ShowIncentive;
      {ShowDeviation;}
      MakeDebugInfo(
           'Iter # ='+IntToStr(I)
           +' HitFacet# = '+IntToStr(HitFacetNumber));
    end;

      if IsOptimal {or (OldNorm<=Convergence*StartNorm) }
      then begin {Incentives were calculated by MakeBestReplies}
        SaveSolution(sm_Mixed,sc_Perfect);
        HasConverged:=True;
      end else begin
        MakeDirection; {Multiply invert Jacobian by Deviation, or tremble if fails}
        if I=1 then begin
          StartNorm:=NextNorm;
          if IsDebug then MakeDebugInfo('Start norm = '+FloatToStrF(StartNorm,ffGeneral,8,8));
        end else ControlStepSize;
        UpdateProbas(ForSampling); {Using Direction and StepSize. Also checks speed and hit facet}
        if HitFacet then HitFacetNumber:=HitFacetNumber+1 {else HitFacetNumber:=0};
        if HitFacetNumber>=MaxHitFacet then begin
          HasConverged:=True;
          if IsDebug then HitFacetCount:=HitFacetCount+1;
        end;
        OldNorm:=NextNorm;
        MakeBestReplies(True);
        if (I>=MaxStepNumber) then begin
          if IsDebug then MakeDebugInfo('Too many steps');
          HasConverged:=True;
        end;
      end;

      if IsDebug then begin
        ShowDirection;
        MakeDebugInfo(
           ' Speed = '+FloatToStrF(Speed,ffGeneral,16,16)
           +' Step = '+FloatToStrF(StepSize,ffGeneral,8,8)
           +' SqrNorm = '+FloatToStrF(NextNorm,ffGeneral,8,8)
           +' CVTest = '+FloatToStrF(ConvTest,ffGeneral,16,16));
      end;

      I:=I+1;
    until HasConverged;

  end;
end;

procedure TSolveDlg.FormCreate(Sender: TObject);
begin
  ViewList:=TGameList.Create;
end;

procedure TSolveDlg.FormDestroy(Sender: TObject);
begin
  IsBusy:=False;
  ViewList.Clear;
  ViewList.Free;
end;

procedure TSolveDlg.ShowLogClick(Sender: TObject);
var AGameWindow:TMDIChild;
begin
  AGameWindow:=MainForm.GameWindow(GameToSolve);
  if (AGameWindow<>nil)
  then if (SlctSolution<>nil)
       then MainForm.OpenSolLogWindow(SlctSolution.Name,GameToSolve,SlctSolution);
end;

end.
