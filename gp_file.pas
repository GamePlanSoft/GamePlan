{Copyright (c), Jean-Pierre P. Langlois, 2007-2022}

Unit GP_File;

interface

uses GP_Glob,GP_Type,GP_FlTyp,GP_Cnst,GP_Util,Strings,WinDos,WinCRT,
     OWindows,ODialogs,OStdDlgs,Objects,WinTypes,WinProcs,ShellAPI;

procedure InitFileUnit;
procedure CleanupFileUnit;
procedure ClearHeap;

function FileExists(AFileName:FileNameType):Boolean;
function OpenTextFile(AFileName:FileNameType):Boolean;
function OpenFile(AFileName:FileNameType):Boolean;

procedure FillForm;
function CheckUserFile:Boolean;
procedure LoadUserInfo;
procedure SaveUserInfo;
procedure SaveUserFile;
function IsExpired:Boolean;
procedure CheckAccessCode;

procedure RestoreEquilibrium(AnEquilibrium:PEquilibrium);
function SolutionLoad(AMode:Byte):Boolean;
procedure SolutionCheck;
procedure SortObjects;
function RestoreSymmetric:Boolean;
function RestoreEvolutionary:Boolean;
function RestoreNormalGame:Boolean;
function RestoreExtensiveGame:Boolean;
function RestoreOutcomes:Boolean;
function GameIsOpen:Boolean;

procedure DropSolution(AMode:Byte);
procedure SolutionPurge;
procedure SolutionSave(AnEquilibrium:PEquilibrium);
procedure MakeGameCollect;
procedure SaveGame(WithSolution:Boolean);
procedure SaveTextGame;
procedure SaveFile(ACollection:PCollection;AFileName:FileNameType);

function SolutionMode(SolveMeth,SolveConc:Byte):Byte; {can be moved to gp_Solve}

var
 NoFile,
 TempName,
 FileName,
 NoteFile,
 UserFile          : FileNameType;
 TheFile           : TBufStream;
 F                 : File;
 TF                : Text;
 UserDate          : PLastDate;
 GameUser          : PGameUser;
 UserColl,
 SolveColl,                           {All solution objects of all types}
 GameColl          : PCollection;    {Game objects plus solutions}
 FileVersion       : Byte;

implementation

 procedure ClearHeap;
 begin
  SolveColl^.DeleteAll;
  GameColl^.DeleteAll;               {BUGGY!!!!!!!!!!!!!!!!!}
  TheGame^.ClearAll;
 end;

 function FileExists(AFileName:FileNameType):Boolean;
 begin
  Assign(F,AFileName);
  {$I-} Reset(F); {$I+}
  if IoResult<>0 then FileExists:=False
  else begin
   FileExists:=True;
   Close(F);
  end;
 end;

 procedure FillForm;
 var ReturnVal:THandle; ALongStr:LongName;
 begin
   StrCopy(NoteFile,'');
   FileSearch(NoteFile,'Register.doc',StartupDir);
   if NoteFile[0] = #0
   then MessageBox(0,'Cannot find Register.doc','ERROR',mb_Ok)
   else begin
    {MessageBox(0,StrCopy(ALongStr,StartupDir),'Register.doc is in directory',mb_Ok);}
    ReturnVal:=ShellExecute(0,nil,'Register.doc',nil,StartupDir,SW_SHOW);
    if ReturnVal<=32
    then MessageBox(0,'Cannot find or open Word','ERROR',mb_IconStop or mb_Ok);
   end;
 end;

function CheckUserFile:Boolean;
 var NewFirst,NewLast:LongName;NewCode,NewID:NameType;
begin
 FileSearch(UserFile,'GamePlan.ini', GetEnvVar('PATH'));
 if UserFile[0] = #0
 then CheckUserFile:=False
 else begin
  UserDate:=nil;
  GameUser:=nil;
  if FileExists(UserFile)
  then LoadUserInfo;  {Retrieve GameUser from GamePlan.ini file}
  {See code to make empty ini file at the end}
  if GameUser=nil
  then CheckUserFile:=False
  else CheckUserFile:=True;
 end;
end;

procedure LoadUserInfo;
 var AnObject:PObject;
procedure GetuserInfo(UserObject:PObject);far;
begin
   if(TypeOf(UserObject^)=TypeOf(TGameUser))
   then GameUser:=PGameUser(UserObject);
   if(TypeOf(UserObject^)=TypeOf(TLastDate))
   then UserDate:=PLastDate(UserObject);
end;
begin
 UserDate:=nil;
 GameUser:=nil;
 TheFile.Init(UserFile,stOpen,2048);
 if TheFile.Status=stOk
 then begin
    AnObject:=TheFile.Get;
    if (AnObject<>nil)
    and (TypeOf(AnObject^)=TypeOf(TCollection))
         then begin
          {UserColl:=New(PCollection,Init(FileDim,FileDim)); }
          UserColl:=PCollection(AnObject);
          UserColl^.ForEach(@GetuserInfo);
          UserColl^.DeleteAll;
          Dispose(UserColl);
          if UserDate=nil
          then UserDate:=New(PLastDate,Init);
         end;
 end;
 TheFile.Done;
end;

procedure SaveUserInfo;
begin
  CheckAccessCode;
  GameUser^.MakeData(False,True); {GameUser is now activated}
  SaveUserFile;
end;

procedure SaveUserFile;
begin
  UserColl:=New(PCollection,Init(FileDim,FileDim));
  UserColl^.Insert(GameUser);
  UserColl^.Insert(UserDate);
  if FileExists(UserFile)
  then SaveFile(UserColl,UserFile);
  UserColl^.DeleteAll;
  Dispose(UserColl);
end;

function IsExpired:Boolean;
 var Current: array[0..2] of Word; Garb:Word; InstallDate,CurrentDate,LastDate:LongInt;
begin
  IsExpired:=False;
  with GameUser^ do begin
   InstallDate:=ShowDate(Year,Month,Day);
   GetDate(Current[0],Current[1],Current[2],Garb); {Year,Month,Day}
   CurrentDate:=ShowDate(Current[0]-1980,Current[1],Current[2]);
  end;
  if (CurrentDate>InstallDate+GracePeriod)
  or (CurrentDate<InstallDate)            {i.e. tinkering with the clock}
  then IsExpired:=True
  else with UserDate^ do begin
   LastDate:=ShowDate(Year,Month,Day);
   if LastDate<CurrentDate
   then IncrementTurn(False)          {Rest turn to 1}
   else if LastDate>CurrentDate
        then IsExpired:=True          {Clock tinkering}
        else if ShowTurn>GraceTurn    {LastDate=CurrentDate}
             then IsExpired:=True
             else begin
              IncrementTurn(True);         {Increment turn by 1}
              SaveUserFile;
             end;
  end;
end;

procedure CheckAccessCode;
begin
  with GameUser^ do
  if StrLComp(MakeCode(False),AccessCode,5)=0  {Full code}
  then begin
   IsNotValidUser:=False;
   MakeData(True,False);
  end else if StrComp(MakeCode(True),AccessCode)=0  {Temp code}
           then begin
            {Compare stored date with current date}
            IsNotValidUser:=IsExpired;
            if not IsNotValidUser
            then MakeData(True,True);
           end else IsNotValidUser:=True;  {Prevents saving games}
end;

 function OpenTextFile(AFileName:FileNameType):Boolean;
 var AStr:String; ATextLine:HugeName; NewLine:PTextLine; ObjCase:LongInt;
     AHeader:PHeader; APlayer:PPlayer; ANode:PNode;
     AMove: PMove; AnOutcome: POutcome; AnInfo:PInfo;
  procedure CreateObject(BTextLine:PTextLine);far;
  begin
    ObjCase:=ValidInt(ShowStringPart(BTextLine^.LineText,5*SmallSize,SmallSize));
    case ObjCase of
      ot_Header  : begin
                    AHeader:=New(PHeader,Init(TheGame));
                    AHeader^.InterpretCodeLine(BTextLine^.LineText);
                    TheGame^.IsNormalForm:=False;
                    TheGame^.MainTitle:=AHeader;
                    GameColl^.Insert(AHeader);
                   end;
      ot_Player  : begin
                    APlayer:=New(PPlayer,Init(TheGame));
                    APlayer^.InterpretCodeLine(BTextLine^.LineText);
                    TheGame^.PlayerSet^.Insert(APlayer);
                   end;
      ot_Node    : begin
                    ANode:=New(PNode,Init(TheGame));
                    ANode^.InterpretCodeLine(BTextLine^.LineText);
                    TheGame^.NodeSet^.Insert(ANode);
                   end;
      ot_Move    : begin
                    AMove:=New(PMove,Init(TheGame));
                    AMove^.InterpretCodeLine(BTextLine^.LineText);
                    TheGame^.MoveSet^.Insert(AMove);
                   end;
      ot_Info    : begin
                    AnInfo:=New(PInfo,Init(TheGame));
                    AnInfo^.InterpretCodeLine(BTextLine^.LineText);
                    TheGame^.InfoSet^.Insert(AnInfo);
                   end;
      ot_Outcome : begin
                    AnOutcome:=New(POutcome,Init(TheGame));
                    AnOutcome^.InterpretCodeLine(BTextLine^.LineText);
                    TheGame^.OutcomeSet^.Insert(AnOutcome);
                   end;

    end;
  end;
  procedure CleanUpText(AnObject:PObject);far;
  begin
    if (GameColl^.IndexOf(AnObject)>=0)
    and (TypeOf(AnObject^)=TypeOf(TTextLine))
    then GameColl^.Delete(AnObject);
  end;
 begin
  OpenTextFile:=False;
  if FileExists(AFileName)
  then begin
   ClearHeap;    {Clear Game, Empty GameColl}
   OpenTextFile:=True;
   Assign(TF,AFileName);
   Reset(TF);
   repeat
    Readln(TF,AStr);
    NewLine:=New(PTextLine,Init);
    StrPCopy(ATextLine,AStr);
    NewLine^.AddText(0,ATextLine);
    GameColl^.Insert(NewLine);
   until Eof(TF);
   Close(TF);
   GameColl^.ForEach(@CreateObject);
   GameColl^.ForEach(@CleanUpText);
   RestoreExtensiveGame; {Restore collections}
   RestoreOutcomes;
  end;
 end;

function OpenFile(AFileName:FileNameType):Boolean;
 var AnObject:PObject;
 begin
  OpenFile:=False;
  if FileExists(AFileName)
  then begin
   TheFile.Init(AFileName,stOpen,2048);
   if TheFile.Status=stOk
   then begin
    AnObject:=TheFile.Get;
    if (AnObject<>nil)
    and (TypeOf(AnObject^)=TypeOf(TCollection))
    then begin
     GameColl:=PCollection(AnObject);
     OpenFile:=True;
    end;
   TheFile.Done;
   end;
  end;
 end;

 function SolutionLoad(AMode:Byte):Boolean;
 var ARank:Byte;  SelectedObject:PGameObject;
     AnEquilibrium:PEquilibrium;
  procedure FindNextEquilibrium(AnObject:PGameObject);far;
  begin
   if TypeOf(AnObject^)=TypeOf(Equilibrium)
   then with PEquilibrium(AnObject)^
        do if (Rank=ARank)
           and (SolutionType=AMode)
           then SelectedObject:=AnObject;
  end;
  procedure FindMatches(AnObject:PGameObject);far;
  begin
   if TypeOf(AnObject^)=TypeOf(TStrategyS)
   then with PStrategyS(AnObject)^
        do if (Rank=ARank)
           and (SolutionType=AMode)
           then AnEquilibrium^.StratSolSet^.Insert(AnObject);
   if TypeOf(AnObject^)=TypeOf(Choice2)
   then with PChoice2(AnObject)^
        do if (Rank=ARank)
           and (SolutionType=AMode)
           then AnEquilibrium^.ChoiceSolSet^.Insert(AnObject);
   if TypeOf(AnObject^)=TypeOf(Node2)
   then with PNode2(AnObject)^
        do if (Rank=ARank)
           and (SolutionType=AMode)
           then AnEquilibrium^.NodeSolSet^.Insert(AnObject);
  end;
 begin
  with TheGame^ do begin
   SelectSolution(AMode);   {Makes CrntEquilSet have the given mode}
   if CrntEquilSet<>nil
   then CrntEquilSet^.DeleteAll
   else Exit;
  end;
  if FileVersion=1
  then SolutionLoad:=False       {USED TO BE SolutionLoadV1(AMode)}
  else begin
   SolutionLoad:=False;
   for ARank:=1 to MaxEquilNumber
   do begin
    SelectedObject:=nil;
    SolveColl^.ForEach(@FindNextEquilibrium);
    if (SelectedObject<>nil)
    then begin
     AnEquilibrium:=PEquilibrium(SelectedObject);
     SolveColl^.ForEach(@FindMatches);
     RestoreEquilibrium(AnEquilibrium);
     TheGame^.CrntEquilSet^.Insert(AnEquilibrium);
    end;
   end;
   if (TheGame^.CrntEquilSet^.Count>0)
   then SolutionLoad:=True;
  end;
 end;

 procedure RestoreEquilibrium(AnEquilibrium:PEquilibrium);
   procedure RestoreNodeOwner(ANode:PNode2);far;
   var ARank:Byte;
   begin
    ARank:=ANode^.OwnerRank; {Rank starts at 1}
    if (ARank>0) and (ARank<=TheGame^.PlayerSet^.Count) {for safety}
    then ANode^.SetOwner(TheGame^.PlayerSet^.At(ARank-1))
    else if (ARank=0) then ANode^.SetOwner(nil);
   end;
   procedure RestoreInstance(AChoice:PChoice2);far;  {Restores instance of ChoiceSolSet}
    procedure MatchRank(BChoice:PChoice);far;       {By matching FirstRank with ChoiceSet}
    begin
     if BChoice^.{Show}FirstRank=AChoice^.{Show}FirstRank
     then with BChoice^ do AChoice^.SetInstance(@Instance);
    end;
   begin
    TheGame^.ChoiceSet^.ForEach(@MatchRank);
   end;
   procedure RestoreStratOwner(AStrategy:PStrategyS);far;
   var ARank:Byte;
   begin
    ARank:=AStrategy^.OwnerRank; {Rank starts at 1}
    if (ARank>0) and (ARank<=TheGame^.PlayerSet^.Count) {for safety}
    then AStrategy^.SetOwner(TheGame^.PlayerSet^.At(ARank-1))
    else if (ARank=0) then AStrategy^.SetOwner(nil);
    with AStrategy^ do if {Show}Probability>MidwayDefault
                       then SetFocus(True)
                       else SetFocus(False);
   end;
 begin
  with AnEquilibrium^ do begin
   NodeSolSet^.ForEach(@RestoreNodeOwner);
   ChoiceSolSet^.ForEach(@RestoreInstance);
   StratSolSet^.ForEach(@RestoreStratOwner);
  end;
 end;

 procedure DropSolution(AMode:Byte);
  procedure DeleteEquilibrium(AnEquilibrium:PEquilibrium);far;
   procedure DeleteObject(AGameObject:PGameObject);far;
   begin
    if GameColl^.IndexOf(AGameObject)>=0
    then GameColl^.Delete(AGameObject);
    if SolveColl^.IndexOf(AGameObject)>=0
    then SolveColl^.Delete(AGameObject);
   end;
  begin
   with AnEquilibrium^ do begin
    NodeSolSet^.ForEach(@DeleteObject);
    ChoiceSolSet^.ForEach(@DeleteObject);
    StratSolSet^.ForEach(@DeleteObject);
   end;
   DeleteObject(AnEquilibrium);
  end;
 begin
  with TheGame^ do begin
   if not SelectSolution(AMode) then Exit;
   CrntEquilSet^.ForEach(@DeleteEquilibrium);
   CrntEquilSet^.FreeAll;
   CrntEquilSet:=nil;
  end;
  if FileExists(FileName)
  then SaveFile(GameColl,FileName);
 end;

 procedure SolutionPurge;
 var TheMode:Byte;
 begin
  for TheMode:=200 to 255
  do if TheMode in ModeSet
     then DropSolution(TheMode);  {Saves at the same time}
  TheGame^.SetSolve(False);
 end;

 procedure SolutionCheck;
 var TheMode:Byte;
 begin
  with TheGame^ do begin
   MakeGameAudit;
   SetSolve(False);
   for TheMode:=200 to 255
   do if TheMode in ModeSet
      then if SolutionLoad(TheMode)
           then SetSolve(True);
   NormalCleanUp;
  end;
 end;

 procedure SortObjects;
  procedure SortObjectType(AGameObject:PGameObject); far;
  begin
   AGameObject^.SetGame(TheGame);
   with TheGame^ do begin
    {Insert non-solve objects in game collections}
    if TypeOf(AGameObject^)=TypeOf(Player)
    then PlayerSet^.Insert(AGameObject);
    if TypeOf(AGameObject^)=TypeOf(Node)
    then NodeSet^.Insert(AGameObject);
    if TypeOf(AGameObject^)=TypeOf(Move)
    then MoveSet^.Insert(AGameObject);
    if TypeOf(AGameObject^)=TypeOf(Outcome)
    then OutcomeSet^.Insert(AGameObject);
    if TypeOf(AGameObject^)=TypeOf(Info)
    then InfoSet^.Insert(AGameObject);
    if (TypeOf(AGameObject^)=TypeOf(TStrategy))
    and not (TypeOf(AGameObject^)=TypeOf(TStrategyS))
    then StrategySet^.Insert(AGameObject);
    if TypeOf(AGameObject^)=TypeOf(TCell)
    then CellSet^.Insert(AGameObject);
    if TypeOf(AGameObject^)=TypeOf(TComment)
    then CommentSet^.Insert(AGameObject);
    if TypeOf(AGameObject^)=TypeOf(TProtect)
    then Protected:=PProtect(AGameObject);
    if (TypeOf(AGameObject^)=TypeOf(TEvolver))
    then EvolverSet^.Insert(AGameObject);
    if (TypeOf(AGameObject^)=TypeOf(TAuditItem))
    then GameAuditSet^.Insert(AGameObject);
    if (TypeOf(AGameObject^)=TypeOf(TEvBasic))
    or (TypeOf(AGameObject^)=TypeOf(TEvVrbl))
    or (TypeOf(AGameObject^)=TypeOf(TEvTest))
    or (TypeOf(AGameObject^)=TypeOf(TEvAssgn))
    or (TypeOf(AGameObject^)=TypeOf(TEvStep))
    then EvObjSet^.Insert(AGameObject);

    if (TypeOf(AGameObject^)=TypeOf(Node2))
    then SolveColl^.Insert(AGameObject);
    if (TypeOf(AGameObject^)=TypeOf(Choice2))
    then SolveColl^.Insert(AGameObject);
    if (TypeOf(AGameObject^)=TypeOf(TStrategyS))
    then SolveColl^.Insert(AGameObject);
    if (TypeOf(AGameObject^)=TypeOf(Equilibrium))
    then SolveColl^.Insert(AGameObject);
   end;
  end;
 begin
  GameColl^.ForEach(@SortObjectType);
 end;

 function RestoreSymmetric:Boolean;
 var IsNotCorrupt : Boolean; ARank : Byte; First,Secnd:PPlayer;
  procedure RestoreTwins(AGameInfo:PAuditItem);far;
  begin
   if AGameInfo<>nil then with AGameInfo^ do begin
    RestoreInfo;
    if (Object1=nil) or (Object2=nil)
    then IsNotCorrupt:=False
    else case InfoCase of
     gi_TwinStrat : begin
                     (PStrategy(Object1))^.MakeTwin(PStrategy(Object2));
                     (PStrategy(Object2))^.MakeTwin(PStrategy(Object1));
                    end;
     gi_TwinEvol  : begin
                     (PEvolver(Object1))^.MakeTwin(PEvolver(Object2));
                     (PEvolver(Object2))^.MakeTwin(PEvolver(Object1));
                    end;
    end;
   end;
  end;
 begin
  IsNotCorrupt:=RestoreEvolutionary;
  if IsNotCorrupt and not IsInspect
  then with TheGame^ do begin
   GameAuditSet^.ForEach(@RestoreTwins);
   if IsNotCorrupt
   and (PlayerSet^.Count=2)
   then begin
    First:=PlayerSet^.At(0);
    Secnd:=PlayerSet^.At(1);
    First^.MakeTwin(Secnd);
    Secnd^.MakeTwin(First);
   end else IsNotCorrupt:=False;
   GameAuditSet^.FreeAll;
  end;
  RestoreSymmetric:=IsNotCorrupt;
 end;

 function RestoreEvolutionary:Boolean;
 var IsNotCorrupt : Boolean; ARank : Byte; AnEvOwner:PEvolver;
 procedure RestoreEvolver(AnEvolver:PEvolver);far;             {Should be moved to TEvolver type}
 begin
  if AnEvolver=nil then Exit;
  IsNotCorrupt:=AnEvolver^.Restore;
 end;
 procedure RestoreEvObj(AnEvBasic:PEvBasic);far;
 begin
   if AnEvBasic=nil then Exit;

   ARank:=AnEvBasic^.EvOwnerRank;
   if (ARank>0) and (ARank<=TheGame^.EvolverSet^.Count) {for safety}
   then begin
    AnEvOwner:=TheGame^.EvolverSet^.At(Arank-1);
    AnEvBasic^.Update;                   {Description}
    {Further recovery of attributes such as vrbls, tests, steps}
    case AnEvBasic^.ObjectType of
    {lt_Exit                             : AnEvBasic^.Restore;  }
    lt_SetOwn, lt_SetOpp,
    lt_SetReal,lt_SetOper,lt_SetResp    : (PEvAssgn(AnEvBasic))^.Restore;
    lt_TestOwn, lt_TestOpp,
    lt_TestReal,lt_TestBool             : (PEvTest(AnEvBasic))^.Restore;
    lt_IfThen, lt_IfThenElse,lt_Goto    : (PEvStep(AnEvBasic))^.Restore;
    end;
    AnEvOwner^.AddLine(-1,AnEvBasic);       {Return to its owner}
   end else IsNotCorrupt:=False;
 end;
 begin
  IsNotCorrupt:=RestoreNormalGame;
  if IsNotCorrupt and not IsInspect then
  with TheGame^ do begin
   EvObjSet^.ForEach(@RestoreEvObj);
   EvObjSet^.DeleteAll;
   EvolverSet^.ForEach(@RestoreEvolver);
  end;
  RestoreEvolutionary:=IsNotCorrupt;
 end;

 function RestoreNormalGame:Boolean;
 var IsNotCorrupt : Boolean; ARank : Byte;
  procedure RestoreStrategy(AStrategy:PStrategy);far;
  begin
   ARank:=AStrategy^.OwnerRank; {Rank starts at 1}
   if (ARank>0) and (ARank<=TheGame^.PlayerSet^.Count) {for safety}
   then AStrategy^.SetOwner(TheGame^.PlayerSet^.At(ARank-1))
   else IsNotCorrupt:=False;
  end;
  procedure RestoreCell(ACell:PCell);far;
  var AStrategy:PStrategy; ARank,I:Byte;
  begin
   for I:=1 to 3
   do begin
    ARank:=ACell^.ShowStrategyRank(I);
    if (ARank<=0) or (ARank>TheGame^.StrategySet^.Count)
    then Exit
    else begin
     AStrategy:=TheGame^.StrategySet^.At(ARank-1);
     ACell^.SetStrategy(AStrategy);
    end;
   end;
   ACell^.SetCellName;
  end;
 begin
   IsNotCorrupt:=True;
   if not IsInspect then
   with TheGame^ do begin
     NodeSet^.FreeAll;
     MoveSet^.FreeAll;
     InfoSet^.FreeAll;
     StrategySet^.ForEach(@RestoreStrategy);
     CellSet^.ForEach(@RestoreCell);
   end;
   RestoreNormalGame:=IsNotCorrupt;
 end;

 function RestoreExtensiveGame:Boolean;
 var IsNotCorrupt : Boolean; ARank  : Byte;
  procedure ResetNodeOwner(ANode:PNode); far;
  begin
   ARank:=ANode^.OwnerRank; {Rank starts at 1}
   if (ARank>0) and (ARank<=TheGame^.PlayerSet^.Count) {for safety}
   then ANode^.SetOwner(TheGame^.PlayerSet^.At(ARank-1))
   else if (ARank=0) then ANode^.SetOwner(nil) else IsNotCorrupt:=False;
  end;
  procedure ResetMove(AMove:PMove); far;
  begin
   ARank:=AMove^.FromRank;
   if (ARank>0) and (ARank<=TheGame^.NodeSet^.Count)
   then AMove^.SetFrom(TheGame^.NodeSet^.At(ARank-1))
   else IsNotCorrupt:=False;
   ARank:=AMove^.UptoRank;
   if ARank>TheGame^.NodeSet^.Count
   then IsNotCorrupt:=False
   else if ARank=0
        then begin
         AMove^.SetUpto(nil);
         AMove^.MakeArc;
        end else AMove^.SetUpto(TheGame^.NodeSet^.At(ARank-1));
  end;
  procedure ResetFamily(ANode:PNode);far;
   procedure FindFamily(AnInfo:PInfo);far;
   begin
    if AnInfo^.Rank=ANode^.FamilyRank
    then begin
     AnInfo^.AddEvent(ANode);
     AnInfo^.SetOwner(ANode^.Owner);
     AnInfo^.SetBayes(ANode^.IsBayes);     {Experiment}
     ANode^.SetFamily(AnInfo);
    end;
   end;
  begin
   TheGame^.InfoSet^.ForEach(@FindFamily);
  end;
 begin
   IsNotCorrupt:=True;
   if not IsInspect then
   with TheGame^ do begin
     NodeSet^.ForEach(@ResetNodeOwner);
     MoveSet^.ForEach(@ResetMove);
     NodeSet^.ForEach(@ResetFamily);
     StrategySet^.FreeAll;
     CellSet^.FreeAll;
   end;
   RestoreExtensiveGame:=IsNotCorrupt;
 end;

 function RestoreOutcomes:Boolean;
  var IsNotCorrupt : Boolean;
  procedure ResetOutcome(AnOutcome:POutcome); far;
  begin
   if AnOutcome<>nil then with AnOutcome^ do begin
    if (WhomRank>0) and (WhomRank<=TheGame^.PlayerSet^.Count)
    then SetWhat(TheGame^.PlayerSet^.At(WhomRank-1),nil,nil)
    else IsNotCorrupt:=False;
    if TheGame^.IsNormalForm
    then begin
     if (WhereRank>0) and (WhereRank<=TheGame^.CellSet^.Count)
     then SetWhat(Whom,nil,TheGame^.CellSet^.At(WhereRank-1))
     else IsNotCorrupt:=False;
    end else begin
     if (WhereRank>0) and (WhereRank<=TheGame^.MoveSet^.Count)
     then SetWhat(Whom,TheGame^.MoveSet^.At(WhereRank-1),nil)
     else IsNotCorrupt:=False;
    end;
   end;
  end;
 begin
    IsNotCorrupt:=True;
    if not IsInspect
    then TheGame^.OutcomeSet^.ForEach(@ResetOutcome);   {Common to normal and extensive forms}
    RestoreOutcomes:=IsNotCorrupt;
 end;

 function GameIsOpen:Boolean;
 var
  IsNotCorrupt     : Boolean;
  AFamily       : PInfo;
  function TitleFound(AGameObject:PGameObject):Boolean;far;
  begin
   if (TypeOf(AGameObject^)=TypeOf(Header))
   and (AGameObject^.Rank<sm_Rational)   {Not a solution header}
   then begin
    TitleFound:=True;
    TheGame^.MainTitle:=PHeader(AGameObject);
    TheGame^.MainTitle^.SetGame(TheGame);
   end else TitleFound:=False;
  end;
 { procedure ResetOutcome(AnOutcome:POutcome); far;
  begin
   if AnOutcome<>nil then with AnOutcome^ do begin
    if (WhomRank>0) and (WhomRank<=TheGame^.PlayerSet^.Count)
    then SetWhat(TheGame^.PlayerSet^.At(WhomRank-1),nil,nil)
    else IsNotCorrupt:=False;
    if TheGame^.IsNormalForm
    then begin
     if (WhereRank>0) and (WhereRank<=TheGame^.CellSet^.Count)
     then SetWhat(Whom,nil,TheGame^.CellSet^.At(WhereRank-1))
     else IsNotCorrupt:=False;
    end else begin
     if (WhereRank>0) and (WhereRank<=TheGame^.MoveSet^.Count)
     then SetWhat(Whom,TheGame^.MoveSet^.At(WhereRank-1),nil)
     else IsNotCorrupt:=False;
    end;
   end;
  end; }
 begin {FileOpen}
   GameIsOpen:=False;
   if not OpenFile(FileName) then Exit;
   SolveColl^.DeleteAll;
   TheGame^.MainTitle:=nil;
   TheGame^.Protected:=nil;
   GameColl^.FirstThat(@TitleFound);
   with TheGame^
   do if MainTitle=nil
      then FileVersion:=0
      else begin
            case MainTitle^.Rank of
             1,2: begin IsNormalForm:=False;FileVersion:=1; end;
             3  : begin IsNormalForm:=False;FileVersion:=2; end;
             101: begin IsNormalForm:=True; IsEvolutionary:=False; FileVersion:=2; end;
             111: begin IsNormalForm:=True; IsEvolutionary:=True; IsSymmetric:=False; FileVersion:=2; end;
             112: begin IsNormalForm:=True; IsEvolutionary:=True; IsSymmetric:=True; FileVersion:=2; end;
            else FileVersion:=0;
            end;
           end;
   if FileVersion>0
   then with TheGame^ do begin
    SortObjects;         {sort game objects from solve objects}
    IsNotCorrupt:=True;
    if not IsNormalForm
    then IsNotCorrupt:=RestoreExtensiveGame
    else if not IsEvolutionary
         then IsNotCorrupt:=RestoreNormalGame
         else if IsSymmetric
              then IsNotCorrupt:=RestoreSymmetric
              else IsNotCorrupt:=RestoreEvolutionary;
    if IsNotCorrupt and not IsInspect
    then IsNotCorrupt:=RestoreOutcomes;
    {OutcomeSet^.ForEach(@ResetOutcome);   {Common to normal and extensive forms}
    if IsNotCorrupt
    then begin
      GameIsOpen:=True;
      if not IsInspect
      then SolutionCheck;                     {Load from file existing solution modes. }
    end else GameIsOpen:=False;
   end;
 end;

 procedure SolutionSave(AnEquilibrium:PEquilibrium);
  procedure SaveASolution(ASolution:PEquilibrium);far;
   procedure PutObjectsTogether(AGameObject:PGameObject); far;
   begin
    if AGameObject^.IsBayes then Exit;
    GameColl^.Insert(AGameObject);  {Needed to save game AND solution}
    SolveColl^.Insert(AGameObject);
   end;
  begin
   with TheGame^ do
   if not IsNormalForm
   then begin
    ASolution^.NodeSolSet^.ForEach(@PutObjectsTogether);
    ASolution^.ChoiceSolSet^.ForEach(@PutObjectsTogether);
   end else if IsEvolutionary
            then {Add code here}
            else ASolution^.StratSolSet^.ForEach(@PutObjectsTogether);
   PutObjectsTogether(ASolution);    {HERE EQUILIBRIUM in place of header}
  end;
 begin
  with TheGame^ do begin
   if (AnEquilibrium=nil)
   then CrntEquilSet^.ForEach(@SaveASolution)
   else begin
    SaveASolution(AnEquilibrium);
    if  FileExists(Filename)
    then SaveFile(GameColl,FileName);
   end;
  end;
 end;

 procedure AddSolutions;
 var SolutionType:Byte;
 begin
  for SolutionType:=200 to 250
  do if TheGame^.SelectSolution(SolutionType)
     then SolutionSave(nil);
 end;

 procedure MakeGameCollect;
  procedure PutObjectsTogether(AGameObject:PGameObject); far;
  begin
   if AGameObject^.IsBayes then Exit;
   GameColl^.Insert(AGameObject);
  end;
 begin
   GameColl^.DeleteAll;
   with TheGame^ do begin
    if MainTitle=nil
    then MainTitle:=New(PHeader,Init(TheGame));
    if not IsNormalForm
    then MainTitle^.SetRank(3)
    else if not IsEvolutionary
         then MainTitle^.SetRank(101)
         else if IsSymmetric
              then MainTitle^.SetRank(112)
              else MainTitle^.SetRank(111);
    PutObjectsTogether(MainTitle);
    RankCollections(True);           {Fills EvObjSet in evolution case}
    MakeTwinSet;                     {For evolutionary symmetric games}
    GameAuditSet^.ForEach(@PutObjectsTogether);
    PlayerSet^.ForEach(@PutObjectsTogether);
    if IsNormalForm
    then begin
     StrategySet^.ForEach(@PutObjectsTogether);
     CellSet^.ForEach(@PutObjectsTogether);
     if IsEvolutionary
     then begin
      EvolverSet^.ForEach(@PutObjectsTogether);
      EvObjSet^.ForEach(@PutObjectsTogether);
      EvObjSet^.DeleteAll;
     end;
    end else begin
     NodeSet^.ForEach(@PutObjectsTogether);
     MoveSet^.ForEach(@PutObjectsTogether);
     InfoSet^.ForEach(@PutObjectsTogether);    {Choices are NOT saved}
    end;
    OutcomeSet^.ForEach(@PutObjectsTogether);
    CommentSet^.ForEach(@PutObjectsTogether);
    if Protected<>nil
    then PutObjectsTogether(Protected);
   end;
 end;

 procedure SaveGame(WithSolution:Boolean);
 begin
   MakeGameCollect;
   if WithSolution
   then AddSolutions;
   SaveFile(GameColl,FileName);
 end; {SaveGame}

 procedure SaveTextGame;
  procedure WriteLines(AnObject:PGameObject);far;
  begin
   Writeln(TF,StrPas(AnObject^.MakeCodeLine));
   {Writeln(TF,StrPas(AnObject^.MakeTextLine)); }
  end;
 begin
  Assign(TF,FileName);
  Rewrite(TF);
  MakeGameCollect;
  GameColl^.ForEach(@WriteLines);
  Close(TF);
 end;

 procedure SaveFile(ACollection:PCollection;AFileName:FileNameType);
 begin
  TheFile.Init(AFileName,stCreate,2048);
  TheFile.Flush;
  TheFile.Put(ACollection);
  TheFile.Done;
 end;

 function SolutionMode(SolveMeth,SolveConc:Byte):Byte;
 var TheMode:Byte;
 begin
  TheMode:=sm_Rational;
  case SolveMeth of
   sm_Pure    : TheMode:=TheMode+sm_Pure;
   sm_Explore : TheMode:=TheMode+sm_Explore;
   sm_Sample  : TheMode:=TheMode+sm_Sample;
  end;
  case SolveConc of
   sm_Nash       : TheMode:=TheMode+sm_Nash;
   sm_Perfect    : TheMode:=TheMode+sm_Perfect;
   sm_Sequential : TheMode:=TheMode+sm_Sequential;
  end;
  SolutionMode:=TheMode;
 end;

procedure InitFileUnit;
begin
 GameColl:=New(PCollection,Init(FileDim,FileDim));
 SolveColl:=New(PCollection,Init(FileDim,FileDim));
end;

procedure CleanupFileUnit;
begin
 GameColl^.DeleteAll;
 Dispose(GameColl);
 Dispose(SolveColl);
 if UserDate<>nil
 then Dispose(UserDate);
 if GameUser<>nil
 then Dispose(GameUser);
end;

begin
end.
  {SAVE SAVE SAVE SAVE SAVE SAVE SAVE SAVE SAVE SAVE SAVE SAVE SAVE SAVE SAVE SAVE}
  {This code is to make empty GamePlan.ini file}
  {First 2 lines of SaveUserInfo must be disabled}
  {with GameUser^ do begin
  StrCopy(NewFirst,'');
  MakeName(True,NewFirst);
  StrCopy(NewLast,'');
  MakeName(False,NewLast);
  StrCopy(NewID,'');
  MakeAccess(False,NewID);
  StrCopy(NewCode,'');
  MakeAccess(True,NewCode);
  MakeData(True,False);
  MakeData(False,False);
  SaveUserInfo;
  end; }
  {SAVE SAVE SAVE SAVE SAVE SAVE SAVE SAVE SAVE SAVE SAVE SAVE SAVE SAVE SAVE SAVE}




  {Old solutioncheck code}
  {for CheckPerfect:=False to True      {pure excludes sequential}
  {do begin
   TheMode:=SolutionMode(True,False,CheckPerfect,False);
   if SolutionLoad(TheMode)
   then TheGame^.SetSolve(True);
  end;
  for CheckSampling:=False to True     {explore and sampling allow all concepts}
  {do begin                             {Nash}
   {TheMode:=SolutionMode(False,CheckSampling,False,False);
   if SolutionLoad(TheMode)
   then TheGame^.SetSolve(True);
   for CheckSeq:=False to True         {Perfect and Sequential}
   {do begin
    TheMode:=SolutionMode(False,CheckSampling,True,CheckSeq);
    if SolutionLoad(TheMode)
    then TheGame^.SetSolve(True);
   end;
  end; }

{Common var: CheckSampling,CheckPerfect,CheckSeq:Boolean;}

  {old solutionpurge code
  {for CheckPerfect:=False to True      {pure excludes sequential}
  {do begin
   TheMode:=SolutionMode(True,False,CheckPerfect,False);
   DropSolution(TheMode)
  end;
  for CheckSampling:=False to True     {explore and sampling allow all concepts}
  {do begin                             {Nash}
   {TheMode:=SolutionMode(False,CheckSampling,False,False);
   DropSolution(TheMode);
   for CheckSeq:=False to True         {Perfect and Sequential}
   {do begin
    TheMode:=SolutionMode(False,CheckSampling,True,CheckSeq);
    DropSolution(TheMode)
   end;
  end; }

    {Insert old solve objects in SolveColl}
    {if (TypeOf(AGameObject^)=TypeOf(NodeS))
    then SolveColl^.Insert(AGameObject);
    if (TypeOf(AGameObject^)=TypeOf(Choice))
    then SolveColl^.Insert(AGameObject);
    if (TypeOf(AGameObject^)=TypeOf(Header))
    and (AGameObject^.Rank>=sm_Rational)
    then SolveColl^.Insert(AGameObject);
    {Insert new solve objects in SolveColl}

   {function SolutionLoadV1(AMode:Byte):Boolean;}
   {function SolutionLoadV1(AMode:Byte):Boolean;
 var
     AName              : NameType;
     IsValidMode        : Boolean;
     AnEquilibrium      : PEquilibrium;
  procedure SortObjectType(AGameObject:PGameObject);far;
  begin  {SortObjectType}
   {if (AnEquilibrium=nil)
   then AnEquilibrium:=New(PEquilibrium,Init(TheGame,0,0));   {0,0 because undefined in V1}
   {if (TypeOf(AGameObject^)=TypeOf(Header))
   then begin
        if (AGameObject^.Rank=AMode)    {equilibrium set header of right mode}
        {then IsValidMode:=True;
        if IsValidMode
        and (AGameObject^.Rank<=sm_Rational)   {not equilibrium SET header}
        {then begin
         StrCopy(AName,AGameObject^.ShowName);
         with AnEquilibrium^ do begin
          SetName(AName);                 {Give equilibrium name of header}
          {SetTitleS(PHeaders(AGameObject));  {HERE is the big change}
          {RestoreEquilibrium(AnEquilibrium);
         end;
         with TheGame^ do if CrntEquilSet<>nil
         then CrntEquilSet^.Insert(AnEquilibrium);
         {Prepare next equilibrium}
         {AnEquilibrium:=nil;
        end;
        if (AGameObject^.Rank>sm_Rational)    {Equilibrium set header of different mode}
        {and (AGameObject^.Rank<>AMode)
        then IsValidMode:=False;
   end else if IsValidMode
            then with AnEquilibrium^ do begin
             if TypeOf(AGameObject^)=TypeOf(Choice)
             then ChoiceSolSet^.Insert(AGameObject);
             if TypeOf(AGameObject^)=TypeOf(NodeS)
             then NodeSolSet^.Insert(AGameObject);
             if TypeOf(AGameObject^)=TypeOf(TStrategyS)
             then StratSolSet^.Insert(AGameObject);
            end;
  end; {SortObjectType}
{ begin  {SolutionLoad}
  {SolutionLoadV1:=False;
  with TheGame^ do begin
   IsValidMode:=False;
   AnEquilibrium:=nil;
   SolveColl^.ForEach(@SortObjectType);
   if (CrntEquilSet^.Count>0)
   then SolutionLoadV1:=True;
  end;
 end; {SolutionLoad}

