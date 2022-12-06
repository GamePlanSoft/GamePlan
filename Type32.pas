unit Type32;
  
interface

uses Windows, SysUtils, Classes, Graphics, Constants, Utilities, Dialogs;

type

  {This is to allow the loop with Game32Type. The
   Game attribute in TGameObject32 must be recast
   to GameType32 when using the game properties.}
  TFakeGame     = class(TPersistent)
  end;

  TPayoff32 = class;
  TPlayer32 = class;

  TGameObject32 = class(TPersistent)
  protected
    procedure AssignTo(Dest:TPersistent); override;
    {This tells the object (Self) how to write itself to Dest.
     Dest is actually recast as TGameObject32(Dest) in the implementation.
     Assign is used rather than AssignTo in edit methods.}
  public
    Name        : String;
    ObjType     : Integer;  {Tells whether player, node,..}
    XPos        : Integer;
    YPos        : Integer;
    XOrg        : Integer;
    YOrg        : Integer;
    {Level       : Integer;  {Used to describe how far an object is from endgame}
    Depth,
    Rank        : Integer;  {Used for storing and solving}
    IsEstimated,
    IsDominated,
    IsArtificial,           {Used for Bayesian Info and normal to extensive}
    IsActive    : Boolean;  {Used for searching when solving}
    MaxEstimate,
    MinEstimate : Real;    {Used in move and choice estimates for solving}
    Color       : TColor;
    SubStr      : String;  {Used to interpret TextLine}
    TextLine    : String;  {To store and load object to and from file}
    Game        : TFakeGame;
    IsInFront   : Boolean; {For strategies and cells}
    Associate   : TGameObject32; {For editing and solving}
    constructor Create(AGame:TFakeGame);
    procedure Remake; virtual; {Resets data. Used by create and with editing}
    destructor Destroy; override;
    procedure SetName(AName:String);
    procedure SetPosition(X,Y:Integer); virtual;
    procedure SetOrigin(X,Y:Integer);
    function IsDetected(X,Y:Integer): Boolean; virtual;
    function IsInRect(ARect:TRect):Boolean; virtual;
    function OwnRectangle(CrntX,CrntY:Integer;WithConnect:Boolean):TRect; virtual;
    procedure SetColor(AColor: TColor);
    procedure SetGame(AGame:TFakeGame); {Used for edit dialogs}
    function ResetRank: Integer; virtual; {Used in Description}
    procedure SetDepth(ADepth:Integer);
    {procedure SetLevel(ALevel:Integer); }

    procedure SetEstimated(IsIt:Boolean);
    procedure SetDominated(IsIt:Boolean);
    procedure SetEstimate(IsMax:Boolean;AnEstimate:Real);
    function ShowEstimate(IsMax:Boolean;APlayer:TPlayer32):TPayoff32;

    procedure SetArtificial(IsIt:Boolean);
    procedure SetActive(IsIt:Boolean);
    procedure SetAssociate(AnObject:TGameObject32);

    procedure SetUnclean;  {To free up}
    procedure SetInFront(IsIt:Boolean);
    function CanDelete:Boolean; virtual;
    function Description(ForWhat:Integer) : String; virtual; {Construct and output TextLine}
    procedure SetLine(AStr:String); virtual; {Import and interpret TextLine}
    function Restore:Boolean; virtual;  {Uses Ranks to restore object connections}
    procedure RedoGraphics; virtual;    {Used in moves and tables for changes in components}
    procedure DrawObject(ACanvas:TCanvas); virtual;
  end;

  THeader32       = class(TGameObject32)
    procedure Remake; override;
    function Description(ForWhat:Integer) : String; override; {Construct and output TextLine}
    procedure SetLine(AStr:String); override; {Import and interpret TextLine}
  end;

  TBug            = class(TGameObject32)
  end;

  TSelectRect = class(TGameObject32)
  public
    Hor,Ver   : Integer;
    procedure Remake; override;
    procedure SetCorner(ARgt,ABot:Integer);
    procedure DrawObject(ACanvas:TCanvas); override;
    function ShowRect:TRect;
    function OwnRectangle(CrntX,CrntY:Integer;WithConnect:Boolean):TRect; override;
  end;

  TChoice32 = class;

  {This is to add a ForEach procedure to the TList object}
  TProc         = procedure(AnItem:TGameObject32);
  TGameList     = class(TList)
  public
    destructor Destroy; override;
    procedure ForEach(AProc: TProc);
    {function FindFirst(ACriterion:Integer):TGameObject32;}
    procedure FreeAll(ACriterion:Integer);
    function TrueIndex(Item:Pointer):Integer;
    function HasItem(Item:Pointer):Boolean;
  end;

  TPlayer32     = class(TGameObject32)
  public
    procedure Remake; override;
    function ResetRank: Integer; override;
    function CanDelete:Boolean; override;
    function Description(ForWhat:Integer) : String; override;
    procedure SetLine(AStr:String); override;
    procedure DrawObject(ACanvas:TCanvas); override;
  end;

  TMove32        = class;
  TNode32        = class;
  TTable32       = class;
  TSide32        = class;
  TCell32        = class;
  TStrat32       = class;
  TInfo32        = class(TGameObject32)
  protected
  public
    Owner        : TPlayer32;
    Events       : TGameList; {Of TNode32}
    Choices      : TGameList; {Of TChoice32}
    IsBayesian   : Boolean;
    IsSingleton  : Boolean;
    Complexity   : Integer;
    BestProspect,
    Frequency    : Real;
    BestReply    : TChoice32;
    Target       : TInfo32;  {Upto of a Move From an artificial info}
    destructor Destroy; override;
    procedure Remake; override;
    function ResetRank: Integer; override;
    function IsInRect(ARect:TRect):Boolean; override;
    procedure AddChoice(AChoice:TChoice32);
    procedure MakeArtificialSet;
    procedure FixBayesian;
    function Restore:Boolean;  override;
    procedure SetOwner(AnOwner:TPlayer32);
    function ShowOwner: TPlayer32;
    procedure SetFrequency(IsToAdd:Boolean;AFrequency:Real);
    procedure ResetBestReply;
    procedure SetTarget(ATarget:TInfo32);
    procedure ResetChoiceActivity(SettingTrue:Boolean;Cardinal:Byte);
    function ExistNextChoiceSet(Cardinal:Byte):Boolean;
    procedure Estimate;
    function IsDominatedSet:Boolean;
    {function InitNorm:Real; }
    function ShowFirstDegree: Integer;
    function FirstName:String;
    function Description(ForWhat:Integer) : String; override;
    procedure DrawObject(ACanvas:TCanvas); override;
  end;

  TNode32       = class(TGameObject32)
  protected
    procedure AssignTo(Dest:TPersistent); override;
  public
    Owner       : TPlayer32;
    OwnerRank   : Integer;
    Family      : TInfo32;
    FamilyRank  : Integer;
    Belief,
    {Deriv,}
    Frequency   : Real;
    {procedure SetDeriv(ADeriv:Real); {For testing only}
    destructor Destroy; override;
    procedure Remake; override;
    procedure SetPosition(X,Y:Integer); override;
    function ResetRank: Integer; override;
    procedure SetOwner(AnOwner:TPlayer32);
    procedure SetFamily(AFamily:TInfo32);
    function CanDelete:Boolean; override;
    function Description(ForWhat:Integer) : String; override;
    procedure SetLine(AStr:String); override;
    function Restore:Boolean; override;
    function ShowDegree: Integer;
    procedure Disconnect;
    procedure MakeSingleton;
    function CheckChance:Boolean;
    function HasInput:Boolean;
    function AlwaysHit(AnInfo:TInfo32):Boolean;
    procedure SetFrequency(AFrequency:Real);
    procedure SetBelief(ABelief:Real);
    procedure DrawNode(IsSolid:Boolean;ACanvas:TCanvas);
    procedure DrawObject(ACanvas:TCanvas); override;
    function OwnRectangle(CrntX,CrntY:Integer;WithConnect:Boolean):TRect; override;
  end;

  TTable32      = class(TNode32)
  protected
    procedure AssignTo(Dest:TPersistent); override;
  public
    CellHeight,
    TabWidth,
    TabHeight  : Integer;
    OwnTable   : TTable32;
    TestCell   : TCell32;
    Sides      : TGameList;
    Cells      : TGameList;
    procedure Remake; override;
    destructor Destroy; override;
    procedure DeleteSide(ASide:TSide32);
    {function ResetRank: Integer; override; }
    procedure RedoGraphics; override;
    procedure DrawObject(ACanvas:TCanvas); override;
    function OwnRectangle(CrntX,CrntY:Integer;WithConnect:Boolean):TRect; override;
    {function Description(ForWhat:Integer) : String; override; }
    function NextSide(ASide:TSide32):TSide32;
    procedure EnumerateChoices(ASide:TSide32);
    function FindMatch(ACell:TCell32):TCell32;
    procedure MatchOrCreate(ACell:TCell32);
    procedure RemoveCells;
    procedure RestoreCells;
    procedure UpdateCells;
    procedure SelfAssociateChoices;
    procedure SidesToCells;
    procedure TableToNode;
    function ConvertToGraph:Boolean;
  end;

  TSide32       = class(TInfo32)
  protected
    procedure AssignTo(Dest:TPersistent); override;
  public
    NamePos      : Integer;
    OwnTable     : TTable32;
    OwnerRank,
    TableRank    : Integer;
    FrontStrat   : TStrat32;
    procedure Remake; override;
    destructor Destroy; override;
    function ResetRank: Integer; override;
    procedure RemoveAllChoices; {From game}
    procedure AddAllChoices; {To game}
    procedure DeleteCells(AStrat:TStrat32);
    function Description(ForWhat:Integer) : String; override;
    procedure SetLine(AStr:String); override;
    procedure ResetSide;
    function TabOrder: Integer;
    procedure SetTable(ATable:TTable32);
    procedure ResetFront;
    procedure RedoGraphics; override;
    procedure ConvertToMoves(AFrom:TNode32);
    function IsDetected(X,Y:Integer): Boolean; override;
    procedure DrawObject(ACanvas:TCanvas); override;
  end;

  TArrow        = array[1..3] of TPoint;
  TCurve        = array[0..ArcPrecis] of TPoint;

  TChoice32 = class(TGameObject32)
  protected
    {procedure AssignTo(Dest:TPersistent); override; }
  public
    IsDominated: Boolean;
    IsInfoMin  : Boolean; {To see if dominated in info}
    IsOptimum  : Boolean; {To construct solution class}
    Proba      : Real;
    Incentive  : Real;
    Direction  : Real;
    MinIncent,
    MaxIncent  : Real;
    Source     : TInfo32;
    {Associate  : TChoice32; }
    Instances  : TGameList; {Of TMove32}
    Arrow      : TArrow;
    {Deriv      : Real; {For testing only}
    {procedure SetDeriv(ADeriv:Real); {For testing only}
    {constructor Create(ASource:TInfo32;AGame:TFakeGame); }
    destructor Destroy; override;
    procedure Remake; override;
    procedure SetSource(ASource:TInfo32);
    function ResetRank: Integer; override;
    procedure AddInstance(AnInstance:TGameObject32);
    function NameMatchAt(ANode:TNode32):Boolean;
    function CheckInstances: Boolean;
    procedure SetProba(AProba:Real);
   { procedure SetAssociate(AChoice:TChoice32); }
    function IsBest:Boolean;
    procedure SetIncentive(AnIncentive:Real);
    procedure SetDirection(ADirection:Real);
    procedure SetOptimum(IsIt:Boolean);
    procedure MakeMinMax;
    procedure Estimate;
    procedure SetInfoMin(IsIt:Boolean);
    function CheckDominated:Boolean;
    procedure SetDominated(IsIt:Boolean);
    procedure DrawObject(ACanvas:TCanvas); override;
  end;

  TStrat32      = class(TChoice32)
  protected
    {procedure AssignTo(Dest:TPersistent); override; }
  public
    SideRank  : Integer;
    procedure Remake; override;
    procedure RedoGraphics; override;
    procedure DrawObject(ACanvas:TCanvas); override;
    function ResetRank: Integer; override;
    function Description(ForWhat:Integer) : String; override;
    procedure SetLine(AStr:String); override;
    function Restore:Boolean; override;
  end;

  TMove32       = class(TGameObject32)
  protected
    procedure AssignTo(Dest:TPersistent); override;
  public
    {IsActivated: Boolean;}
    From       : TNode32;
    Upto       : TNode32; {nil if final}
    FromRank   : Integer;
    UptoRank   : Integer;
    Incentive,
    Discount   : Real;
    OwnChoice  : TChoice32;
    Payments   : TGameList;
    Arrow      : TArrow;
    Curve      : TCurve;
    destructor Destroy; override;
    procedure Remake; override;
    function ResetRank: Integer; override;
    procedure SetPosition(X,Y:Integer); override;
    procedure SetFrom(AFrom:TNode32);
    procedure SetUpto(AnUpto:TNode32);
    procedure SetDiscount(ADiscount:Real);
    {function CanDelete:Boolean; override; }
    procedure RedoGraphics; override;
    procedure MakeArrow;
    procedure MakeLine;
    procedure MakeCurve(FroX,FroY:Integer);
    function Description(ForWhat:Integer) : String; override;
    procedure SetLine(AStr:String); override;
    function Restore:Boolean; override;
    procedure DrawCurve(IsSolid:Boolean;ACanvas:TCanvas);
    procedure DrawObject(ACanvas:TCanvas); override;
    function OwnRectangle(CrntX,CrntY:Integer;WithConnect:Boolean):TRect; override;
    procedure SetChoice(AChoice:TChoice32);
    procedure MakeChoice;
    procedure TransferPayments(DestMove:TMove32);
    procedure DuplicatePayments(DestMove:TPersistent);
    procedure ResetPayments;
    procedure DeletePayments;
    function ShowPayment(APlayer:TPlayer32):TPayoff32; {For TPayoff32}
    function MissEndPay:Boolean;
    procedure SetIncentive(AnIncentive:Real);
    {procedure SetActivated(IsIt:Boolean);}
  end;

  TCell32    = class(TMove32)
  protected
    procedure AssignTo(Dest:TPersistent); override;
  public
    XFro,YFro,
    Drift     : Integer;
    OwnTable   : TTable32;
    TableRank  : Integer;
    StratSet   : TGameList;  {Strategies that lead to this cell}
    StratRanks : set of 1..MaxStratNumber;
    destructor Destroy; override;
    procedure Remake; override;
    function IsDetected(X,Y:Integer): Boolean; override;
    procedure SetLine(AStr:String); override;
    function Description(ForWhat:Integer) : String; override;
    procedure ResetCell;
    function ResetRank: Integer; override;
    procedure SetTable(ATable:TTable32);
    function FindStrategyOf(ASide:TInfo32):TStrat32;
    procedure ReplaceStrategy(OldStrategy,NewStrategy:TStrat32);
    function IsMatchOf(ACell:TCell32):Boolean;
    function HasValidChoices:Boolean;
    procedure UpdateToAssociates;
    procedure RenameCell;
    procedure ResetDrift;
    procedure RedoGraphics; override;
    procedure DrawObject(ACanvas:TCanvas); override;
  end;

  TGameValue = class(TGameObject32)
  public
    Where     : TGameObject32; {Allows moves, nodes and cells}
    Whom      : TPlayer32; {nil except for move payoff and node expectation}
    WhereRank : Integer;
    WhomRank  : Integer;
    Value     : Real;
    destructor Destroy; override;
    function Description(ForWhat:Integer): String; override;
    procedure SetLine(AStr:String); override;
    function Restore:Boolean; override;
  end;

  TPayoff32 = class(TGameValue)
  protected
    procedure AssignTo(Dest:TPersistent); override;
  public
    procedure Remake; override;
    procedure SetWhom(APlayer:TPlayer32);
    procedure SetWhere(AWhere:TGameObject32);
    procedure SetValue(AValue:Real);
    procedure DrawObject(ACanvas:TCanvas); override;
    function IsOwnPay:Boolean;
  end;

procedure DrawArrow(ACanvas:TCanvas;AnArrow:TArrow);

function MakeAnArrow(X,Y,DX,DY:Integer):TArrow;

procedure DrawHuman(XPos,YPos:Integer;AColor:TColor;ACanvas:TCanvas);

{function ObjectIsOk(AnObject:TGameObject32;AType:Integer):Boolean; }

function ObjectTypeIsOk(AnObject:TGameObject32;AClass:TClass):Boolean;

implementation

uses Game32Type,Game32Solve, Matrices;

{Two usefull procedures added to TList}

procedure DrawArrow(ACanvas:TCanvas;AnArrow:TArrow);
var ZoomArrow:TArrow;
begin
  ZoomArrow[1].X:=Zoom(AnArrow[1].X);
  ZoomArrow[1].Y:=Zoom(AnArrow[1].Y);
  ZoomArrow[2].X:=Zoom(AnArrow[2].X);
  ZoomArrow[2].Y:=Zoom(AnArrow[2].Y);
  ZoomArrow[3].X:=Zoom(AnArrow[3].X);
  ZoomArrow[3].Y:=Zoom(AnArrow[3].Y);
  ACanvas.Polygon(ZoomArrow);
end;

function MakeAnArrow(X,Y,DX,DY:Integer):TArrow;
begin
  MakeAnArrow[1].X:=X;
  MakeAnArrow[1].Y:=Y;
  MakeAnArrow[2].X:=X-2*DX-DY;
  MakeAnArrow[2].Y:=Y-2*DY+DX;
  MakeAnArrow[3].X:=X-2*DX+DY;
  MakeAnArrow[3].Y:=Y-2*DY-DX;
end;

procedure DrawHuman(XPos,YPos:Integer;AColor:TColor;ACanvas:TCanvas);
begin
  with ACanvas do begin
    Pen.Color:=AColor;
    Brush.Color:=AColor;
    Brush.Style:=bsSolid;
    Pen.Width:=Zoom(ThinPen);
    Ellipse(Zoom(XPos-PlaySize),Zoom(YPos-PlaySize),Zoom(XPos+PlaySize),Zoom(YPos+PlaySize));
    MoveTo(Zoom(XPos),Zoom(YPos));
    LineTo(Zoom(XPos),Zoom(YPos+BodySize));
    LineTo(Zoom(XPos+LegSize),Zoom(YPos+BodySize+LegSize));
    MoveTo(Zoom(XPos),Zoom(YPos+BodySize));
    LineTo(Zoom(XPos-LegSize),Zoom(YPos+BodySize+LegSize));
    MoveTo(Zoom(XPos-ArmSize),Zoom(YPos+NeckSize));
    LineTo(Zoom(XPos+ArmSize),Zoom(YPos+NeckSize));
  end;
end;

{function ObjectIsOk(AnObject:TGameObject32;AType:Integer):Boolean;
begin
    ObjectIsOk:=True;
    if AnObject<>nil
    then try
      if AType<>AnObject.ObjType
      then ObjectIsOk:=False;
    except on Exception do begin
                           ObjectIsOk:=False;
                           MessageDlg('Not valid object type '+IntToStr(AType),mtWarning,[mbOk],0);
                         end;
    end;
end; }

function ObjectTypeIsOk(AnObject:TGameObject32;AClass:TClass):Boolean;
begin
  ObjectTypeIsOk:=True;
    if AnObject<>nil
    then try
      if AClass<>AnObject.ClassType
      then ObjectTypeIsOk:=False;
    except on Exception do begin
                           ObjectTypeIsOk:=False;
                           MessageDlg('Not valid object type.',mtWarning,[mbOk],0);
                         end;
    end;
end;

destructor TGameList.Destroy;
begin
  FreeAll(ot_All);
  inherited Destroy;
end;

procedure TGameList.ForEach(AProc: TProc);
var J:Integer;
begin
  Pack;
  if (Count>=1) then
  for J:=0 to Count-1
      do AProc(Items[J]);
end;

{function TGameList.FindFirst(ACriterion:Integer):TGameObject32;
var TheFirst: TGameObject32;
  procedure FindNext(AnObject:TGameObject32);
  begin
    if TheFirst<>nil then Exit;
    if (AnObject.ObjType=ACriterion)
    or (ACriterion=ot_All)
    then TheFirst:=AnObject;
  end;
begin
  TheFirst:=nil;
  ForEach(@FindNext);
  FindFirst:=TheFirst;
end;

{procedure TGameList.FreeAll(ACriterion:Integer);
var ObjectToFree: TGameObject32;
begin
  repeat
    ObjectToFree:=FindFirst(ACriterion);
    if ObjectToFree<>nil
    then begin
      Remove(ObjectToFree);
      ObjectToFree.Free;
    end;
  until (ObjectToFree=nil);
end; }

procedure TGameList.FreeAll(ACriterion:Integer);
var ObjectToFree: TGameObject32; I: Integer;
begin
  Pack;
  for I:=0 to Count-1 do begin
    ObjectToFree:=Items[I];
    if (ObjectToFree.ObjType=ACriterion)
    or (ACriterion=ot_All)
    then begin
      Items[I]:=nil;
      ObjectToFree.Free;
    end;
  end;
  Pack;
end;

function TGameList.TrueIndex(Item:Pointer):Integer;
begin
  TrueIndex:=IndexOf(Item)+1;
end;

function TGameList.HasItem(Item:Pointer):Boolean;
  procedure FindItem(AnItem:Pointer);
  begin
    if Item=AnItem then HasItem:=True;
  end;
begin
  HasItem:=False;
  ForEach(@FindItem);
end;

{TGameObject32 implementation}

constructor TGameObject32.Create(AGame:TFakeGame);
begin
  Remake;
  SetGame(AGame);
end;

procedure TGameObject32.Remake;
begin
  SetName('');
  SetPosition(DfltPos,DfltPos);
  SetOrigin(0,0);
  ObjType:=ot_Undef;
  Color:=clBlack;
  IsArtificial:=False;
  IsInFront:=False;
  {Level:=0;}
end;

destructor TGameObject32.Destroy;
begin
  Game:=nil;
  inherited Destroy;
end;

procedure TGameObject32.AssignTo;
begin // Assign uses AssignTo in TPersistent
  TGameObject32(Dest).Name:=Self.Name;
  TGameObject32(Dest).XPos:=Self.XPos;
  TGameObject32(Dest).YPos:=Self.YPos;
  TGameObject32(Dest).Color:=Self.Color;
  TGameObject32(Dest).Game:=Self.Game;
 end;

procedure TGameObject32.SetName;
begin
  Name:=AName;
  RealName(Name);
end;

procedure TGameObject32.SetPosition(X,Y:Integer);
begin
  XPos:=X;
  YPos:=Y;
end;

procedure TGameObject32.SetOrigin(X,Y:Integer);
begin
  XOrg:=XPos-X;
  YOrg:=YPos-Y;
end;

function TGameObject32.IsDetected(X,Y:Integer): Boolean;
begin
  if (Abs(XPos-X)+Abs(YPos-Y))<Zoom(HiLiteSize)
  then IsDetected:=True
  else IsDetected:=False;
end;

function TGameObject32.IsInRect(ARect:TRect):Boolean;
begin
  with ARect do
  if (MinInt(Left,Right)<XPos)
  and (MaxInt(Left,Right)>XPos)
  and (MinInt(Top,Bottom)<YPos)
  and (MaxInt(Top,Bottom)>YPos)
  then IsInRect:=True
  else IsInRect:=False;
end;

function TGameObject32.OwnRectangle(CrntX,CrntY:Integer;WithConnect:Boolean):TRect;
var R:TRect;
begin
  with R do begin
    Left:=Zoom(CrntX)-2*RectSize;
    Top:=Zoom(CrntY)-2*RectSize;
    Right:=Zoom(CrntX)+RectSize;
    Bottom:=Zoom(CrntY)+RectSize;
  end;
  OwnRectangle:=R;
end;

procedure TGameObject32.SetGame(AGame:TFakeGame);
begin
  Game:=TGameType32(AGame);
end;

function TGameObject32.ResetRank: Integer;
begin
  Rank:=0;
  ResetRank:=Rank;
end;

procedure TGameObject32.SetActive(IsIt:Boolean);
begin
  IsActive:=IsIt;
end;

procedure TGameObject32.SetDepth(ADepth:Integer);
begin
  Depth:=ADepth;
end;

{procedure TGameObject32.SetLevel(ALevel:Integer);
begin
  Level:=ALevel;
end;}

procedure TGameObject32.SetEstimated(IsIt:Boolean);
begin
  IsEstimated:=IsIt;
end;

procedure TGameObject32.SetDominated(IsIt:Boolean);
begin
  IsDominated:=IsIt;
  if IsDominated then IsEstimated:=True; {For checking}
end;

procedure TGameObject32.SetEstimate(IsMax:Boolean;AnEstimate:Real);
begin
  if IsMax then MaxEstimate:=AnEstimate
           else MinEstimate:=AnEstimate;
end;

function TGameObject32.ShowEstimate(IsMax:Boolean;APlayer:TPlayer32):TPayoff32;
var IsFound:Boolean;
  procedure FindEstimate(AnEstimate:TSolutionBit);
  begin
    if IsFound then Exit;  {For efficiency}
    if AnEstimate.Where<>Self then Exit;
    if AnEstimate.Whom<>APlayer then Exit;
    if IsMax then if AnEstimate.ObjType=ot_Max
                  then begin ShowEstimate:=AnEstimate; IsFound:=True; end;
    if not IsMax then if AnEstimate.ObjType=ot_Min
                      then begin ShowEstimate:=AnEstimate; IsFound:=True; end;
  end;
begin
  ShowEstimate:=nil;
  if not IsEstimated then Exit;
  IsFound:=False;
  TGameType32(Game).MinMaxList.ForEach(@FindEstimate);
end;



procedure TGameObject32.SetArtificial(IsIt:Boolean);
begin
  IsArtificial:=IsIt;
end;

procedure TGameObject32.SetAssociate(AnObject:TGameObject32);
begin
  Associate:=AnObject;
end;

procedure TGameObject32.SetUnclean;
begin
  ObjType:=ot_Unclean;
end;

procedure TGameObject32.SetInFront(IsIt:Boolean);
begin
  IsInFront:=IsIt;
end;

function TGameObject32.Description(ForWhat:Integer): String;
begin
  if ForWhat in [fw_SolLog,fw_Test] then Description:=TextLine
  else begin
    Textline:=Name;
    if ForWhat=fw_Saving then begin
      StrLenAdjust(sl_Name,Textline);
      Textline:=Textline+IntToStr(XPos);
      StrLenAdjust(sl_Name+sl_Short,Textline);
      Textline:=Textline+IntToStr(YPos);
      StrLenAdjust(sl_Name+2*sl_Short,Textline);
      Textline:=Textline+IntToStr(ResetRank);
      StrLenAdjust(sl_Name+3*sl_Short,Textline);
      Textline:=Textline+IntToStr(ObjType);
      StrLenAdjust(sl_Name+4*sl_Short,Textline);
    end;
    Description:=TextLine;
  end;
end;

procedure TGameObject32.SetLine(AStr:String);
begin
  TextLine:=AStr;
  SetName(ShowStringPart(AStr,1,sl_Name));
  SubStr:=ShowStringPart(AStr,sl_Name+1,sl_Short);
  XPos:=ValidInt(SubStr);
  SubStr:=ShowStringPart(AStr,sl_Name+sl_Short+1,sl_Short);
  YPos:=ValidInt(SubStr);
  SubStr:=ShowStringPart(AStr,sl_Name+2*sl_Short+1,sl_Short);
  Rank:=ValidInt(SubStr); {Corrects for the +1 when re-defining game structure}
end;

function TGameObject32.Restore:Boolean;
begin
  Restore:=True;  {To override}
end;

function TGameObject32.CanDelete: Boolean;
begin
  CanDelete:=True;
end;

procedure TGameObject32.RedoGraphics;
begin
  {To override}
end;

procedure TGameObject32.DrawObject(ACanvas:TCanvas);
begin
  if IsArtificial and not IsDebug then Exit;
  with ACanvas do begin
    Brush.Color:=clWhite;
    Font.Color:=Self.Color;
    Font.Size:=Zoom(8);
    if ObjType<>ot_Info then
    TextOut(Zoom(XPos-Length(Self.Name)),Zoom(YPos-NameGap),Self.Name);
    Pen.Color:=Self.Color;
    Brush.Color:=Self.Color;
  end;
end;

procedure TGameObject32.SetColor;
begin
  Color:=AColor;
end;

function THeader32.Description(ForWhat:Integer): String;
begin
  inherited Description(ForWhat);
  Description:=TextLine;
end;

procedure THeader32.SetLine(AStr:String);
begin
  inherited SetLine(AStr);
end;

procedure THeader32.Remake;
begin
  inherited Remake;
  ObjType:=ot_Header;
end;

procedure TSelectRect.Remake;
begin
  inherited Remake;
  Hor:=0; Ver:=0;
  SetArtificial(True);
  ObjType:=ot_SelRect;
end;

procedure TSelectRect.SetCorner(ARgt,ABot:Integer);
begin
  Hor:=ARgt-XPos;
  Ver:=ABot-YPos;
end;

function TSelectRect.ShowRect:TRect;
var R:TRect;
begin
  with R do begin
    Left:=MinInt(XPos,XPos+Hor);
    Top:=MinInt(YPos,YPos+Ver);
    Right:=MaxInt(XPos,XPos+Hor);
    Bottom:=MaxInt(YPos,YPos+Ver);
  end;
  ShowRect:=R;
end;

procedure TSelectRect.DrawObject(ACanvas:TCanvas);
begin
  if IsArtificial and not IsDebug then Exit;
  with ACanvas do begin
    Brush.Color:=clWhite;
    pen.Style:=psDot;
    pen.Color:=clBlack;
    MoveTo(Zoom(XPos),Zoom(YPos));
    LineTo(Zoom(XPos+Hor),Zoom(YPos));
    LineTo(Zoom(XPos+Hor),Zoom(YPos+Ver));
    LineTo(Zoom(XPos),Zoom(YPos+Ver));
    LineTo(Zoom(XPos),Zoom(YPos));
    pen.Style:=psSolid;
  end;
end;

function TSelectRect.OwnRectangle(CrntX,CrntY:Integer;WithConnect:Boolean):TRect;
var R:TRect;
begin
  with R do begin
    Left:=Zoom(MinInt(CrntX,CrntX+Hor))-RectSize;
    Top:=Zoom(MinInt(CrntY,CrntY+Ver))-RectSize;
    Right:=Zoom(MaxInt(CrntX,CrntX+Hor))+RectSize;
    Bottom:=Zoom(MaxInt(CrntY,CrntY+Ver))+RectSize;
  end;
  OwnRectangle:=R;
end;

{TPlayer32 implementation}

function TPlayer32.ResetRank: Integer;
begin
  Rank:=TGameType32(Game).PlayerList.TrueIndex(Self);
  ResetRank:=Rank;
end;

function TPlayer32.CanDelete;
var HasNoTie:Boolean;
  Procedure CheckTie(AnObject:TGameObject32);
  begin
    case AnObject.ObjType of
      ot_Node : if TNode32(AnObject).Owner=Self then HasNoTie:=False;
      ot_Side : if TSide32(AnObject).Owner=Self then HasNoTie:=False;
      ot_Payoff: if TGameValue(AnObject).Whom=Self then HasNoTie:=False;
    end;
  end;
begin
  HasNoTie:=True;
  TGameType32(Game).NodeList.ForEach(@CheckTie);
  TGameType32(Game).InfoList.ForEach(@CheckTie);
  TGameType32(Game).PayList.ForEach(@CheckTie);
  CanDelete:=HasNoTie;
end;

procedure TPlayer32.Remake;
begin
  inherited Remake;
  ObjType:=ot_Player;
end;

function TPlayer32.Description(ForWhat:Integer): String;
begin
  inherited Description(ForWhat);
  if ForWhat=fw_Saving then begin
    Textline:=Textline+IntToStr(color);
    StrLenAdjust(2*sl_Name+4*sl_Short,Textline);
  end;
  Description:=TextLine;
end;

procedure TPlayer32.SetLine(AStr:String);
begin
  inherited SetLine(AStr);
  SubStr:=ShowStringPart(AStr,sl_Name+4*sl_Short+1,sl_Name);
  if ValidInt(SubStr)=0  {Old GamePlan file}
  then case Rank of
    1: SetColor(clBlue);
    2: SetColor(clRed);
    3: SetColor(clGreen);
    4: SetColor(clBlack);
  end else SetColor(ValidInt(SubStr));
end;

procedure TPlayer32.DrawObject(ACanvas:TCanvas);
begin
  inherited DrawObject(ACanvas);
  if not IsArtificial then DrawHuman(XPos,YPos,Color,ACanvas);
end;

procedure TInfo32.Remake;
begin
  inherited Remake;
  ObjType:=ot_Info;
  Owner:=nil;
  BestReply:=nil;
  Target:=nil;
  Events:=TGameList.Create;
  Choices:=TGameList.Create;
end;

destructor TInfo32.Destroy;
  procedure SetNilFamily(ANode:TNode32);
  begin
    if ANode<>nil
    then if ObjectTypeIsOk(ANode,TNode32)
         then ANode.SetFamily(nil);
  end;
begin
  Owner:=nil;
  BestReply:=nil;
  Target:=nil;
  with Events do begin
    ForEach(@SetNilFamily);
    Clear;
    Free;
  end;
  with Choices do begin
    Clear;
    Free;
  end;
  inherited Destroy;
end;

function TInfo32.IsInRect(ARect:TRect):Boolean;
var SelectedNodes:Integer;
  procedure CheckIfIn(ANode:TNode32);
  begin
    if ANode.IsInRect(ARect) then SelectedNodes:=SelectedNodes+1;
  end;
begin
  SelectedNodes:=0;
  Events.ForEach(@CheckIfIn);
  if SelectedNodes>=2 then IsInRect:=True else IsInRect:=False;
end;

function TInfo32.ResetRank: Integer;
begin
  Rank:=TGameType32(Game).InfoList.TrueIndex(Self);
  ResetRank:=Rank;
end;

function TInfo32.Restore:Boolean; {Check all events can be reached}
  procedure RefillFamily(ANode:TNode32);
  begin
    if (ANode.Family=Self) then Events.Add(ANode);
  end;
  procedure FindInputMove(ANode:TNode32);
  begin
    if not ANode.HasInput then Restore:=False;
  end;
  procedure UpdateComplexity(AChoice:TChoice32);
  begin
    Complexity:=1+2*Complexity;
  end;
begin
  Restore:=True;
  Complexity:=0;
  if ObjType=ot_Side then Choices.ForEach(@UpdateComplexity)
  else if ObjType=ot_Info then begin
    Events.Clear;
    Choices.Clear;
    TGameType32(Game).NodeList.ForEach(@RefillFamily);
    with Events do if (Count>0)
    then begin
      SetOwner(TNode32(Events.Items[0]).Owner);
      ForEach(@FindInputMove);
    end;
  end;
  if (Events.Count>1) then IsSingleton:=False else IsSingleton:=True;
end;

procedure TInfo32.MakeArtificialSet;
var ArtNode:TNode32; ArtMove:TMove32; InfoDepth:Integer;
  procedure MakeArtMove(ANode:TNode32);
  begin
    ArtMove:=TMove32.Create(Game);
    with ArtMove do begin
      SetArtificial(True);
      SetFrom(ArtNode);
      SetUpto(ANode);
      SetName('To '+ANode.Name);
      SetDiscount(ArtDiscount);
      if IsDebug then SetPosition(Trunc((ArtNode.XPos+ANode.XPos)/2),Trunc((ArtNode.YPos+ANode.YPos)/2));
    end;
    TGameType32(Game).MoveList.Add(ArtMove);
  end;
  procedure FindDepth(ANode:TNode32);
  begin
    if ANode.Depth>InfoDepth then InfoDepth:=ANode.Depth;
  end;
begin
  ArtNode:=TNode32.Create(Game);
  ArtNode.SetArtificial(True);
  TGameType32(Game).NodeList.Add(ArtNode);
  InfoDepth:=0;
  Events.ForEach(@FindDepth); {Info depth is max event depth}
  ArtNode.SetDepth(InfoDepth-1); {+1 was a serious bug!!!}
  ArtNode.SetName('Art'+FirstName);  {For debug}
  ArtNode.SetOwner(ShowOwner);
  Events.ForEach(@MakeArtMove);
  if IsDebug then ArtNode.SetPosition(Trunc(1000*Random),Trunc(1000*Random));  {For debug}
end;

function TInfo32.ShowOwner: TPlayer32;
var AnOwner: TPlayer32;
begin
  AnOwner:=nil;
  if Events.Count>0 then AnOwner:=TNode32(Events[0]).Owner;
  ShowOwner:=AnOwner;
end;

procedure TInfo32.FixBayesian;
  procedure CheckIfHitting(ANode:TNode32);
  begin
    if IsBayesian then {else Exit}
    if ANode.AlwaysHit(Self) then IsBayesian:=False;
  end;
begin
  IsBayesian:=True;
  TGameType32(Game).NodeList.ForEach(@CheckIfHitting);
  if IsBayesian then MakeArtificialSet; {Can drop the argument Owner}
end;

procedure TInfo32.AddChoice(AChoice:TChoice32);
begin
  Choices.Add(AChoice);
  Complexity:=1+2*Complexity;
end;

procedure TInfo32.SetOwner(AnOwner:TPlayer32);
begin
  Owner:=AnOwner;
end; 

procedure TInfo32.SetFrequency(IsToAdd:Boolean;AFrequency:Real);
begin
  if IsToAdd
  then Frequency:=Frequency+AFrequency
  else Frequency:=AFrequency;
end;

procedure TInfo32.ResetBestReply; {Called by MakeBestReplies in TGameType32}
var BestValue:Real;
  procedure FindBetterProspect(AChoice:TChoice32);
  begin
    with AChoice do if (Incentive>BestValue) {and IsActive -- This was a bug}
    then begin
      BestValue:=Incentive;
      BestReply:=AChoice;
    end;
  end;
begin
  BestValue:=-MaxAbsValue;
  BestReply:=nil;
  Choices.ForEach(@FindBetterProspect);
  BestProspect:=BestValue;
end;

procedure TInfo32.SetTarget(ATarget:TInfo32);
begin
  Target:=ATarget;
end;

procedure TInfo32.ResetChoiceActivity(SettingTrue:Boolean;Cardinal:Byte);
  procedure ResetState(AChoice:TChoice32);
  begin
    if (Choices.IndexOf(AChoice)<Cardinal)
    then AChoice.SetActive(SettingTrue); {Cardinal first choices are set active}
  end;
begin
  if (Choices.Count>0)
  then Choices.ForEach(@ResetState);
end;

function TInfo32.ExistNextChoiceSet(Cardinal:Byte):Boolean;
begin
  if (Cardinal=0)
  then ExistNextChoiceSet:=False
  else if ExistNextChoiceSet(Cardinal-1)
       then ExistNextChoiceSet:=True
       else if TChoice32(Choices.Items[Cardinal-1]).IsActive
            then ExistNextChoiceSet:=False
            else begin
              TChoice32(Choices.Items[Cardinal-1]).SetActive(True);
              ResetChoiceActivity(False,Cardinal-1);
              ExistNextChoiceSet:=True;
            end;
end;

procedure TInfo32.Estimate;
  procedure UpdateInfoMin(AChoice:TChoice32);
  var IsAlone:Boolean;
    procedure FindOtherChoicesMin(BChoice:TChoice32);
    begin
      if BChoice=AChoice then Exit;
      if BChoice.IsDominated then Exit;
      if not BChoice.IsEstimated then Exit;
      IsAlone:=False;
      if BChoice.MinEstimate<=AChoice.MaxEstimate
      then AChoice.SetInfoMin(False);
    end;
  begin
    if AChoice.IsDominated then Exit;
    AChoice.SetInfoMin(False);
    if not AChoice.IsEstimated then SetEstimated(False);
    if not AChoice.IsEstimated then Exit;
    IsAlone:=True;
    AChoice.SetInfoMin(True); {Assume it is eliminable}
    Choices.ForEach(@FindOtherChoicesMin);
    if IsAlone then AChoice.SetInfoMin(False); {Can't eliminate single choice}
  end;
begin
  SetEstimated(True); {Will be set to False if any choice is not estimated}
  if Owner<>nil then Choices.ForEach(@UpdateInfoMin);
end;

function TInfo32.IsDominatedSet:Boolean;
  {procedure CheckDomination(AChoice:TChoice32);
  begin
    with AChoice do if IsActive and IsDominated then IsDominatedSet:=True;
  end; }
  procedure RedoMinMax(AChoice:TChoice32);
  begin
    AChoice.MakeMinMax;
  end;
  procedure RedoLocalDom(AChoice:TChoice32);
  begin
    with AChoice do if IsActive and CheckDominated then IsDominatedSet:=True;
  end;
begin {This test is only used for local elimination}
  IsDominatedSet:=False;
  Choices.ForEach(@RedoMinMax);
  Choices.ForEach(@RedoLocalDom);
  {Choices.ForEach(@CheckDomination);}
end;

{function TInfo32.InitNorm:Real;
var InitMax,InitMin:Real;
  procedure UpdateMinMax(AChoice:TChoice32);
  begin
    with AChoice do begin
      MakeMinMax;
      if MaxIncent>InitMax then InitMax:=MaxIncent;
      if MinIncent<InitMin then InitMin:=MinIncent;
    end;
  end;
begin
  InitMax:=-MaxAbsValue;
  InitMin:=MaxAbsValue;
  Choices.ForEach(@UpdateMinMax);
  InitNorm:=Sqr(InitMax-InitMin);
end;  }

function TInfo32.FirstName:String;
begin
  if Events.Count<=0
  then FirstName:='Anonymous'
  else FirstName:=TNode32(Events.Items[0]).Name;
end;

function TInfo32.ShowFirstDegree: Integer;
begin
  if Events.Count<=0
  then ShowFirstDegree:=0
  else ShowFirstDegree:=TNode32(Events.Items[0]).ShowDegree;
end;

function TInfo32.Description(ForWhat:Integer) : String;
  procedure WriteEvent(AnEvent:TNode32);
  begin
    TextLine:=TextLine+AnEvent.Description(fw_Audit)+' ';
  end;
begin
  inherited Description(ForWhat);
  if ForWhat<>fw_Saving then Events.ForEach(@WriteEvent);
  Description:=TextLine;
end;

procedure TInfo32.DrawObject(ACanvas:TCanvas);
var I:Integer;
begin
  {ResetInfo; That was a bug. Needed to be in EditInfo.OkBtnClick}
  if IsArtificial and not IsDebug then Exit;
  if Events.Count<=1 then Exit;
  if not ObjectTypeIsOk(Owner,TPlayer32) then Exit;
  if (Owner=nil) {or IsBayesian}
  then Color:=clBlack
  else Color:=Owner.Color;
  inherited DrawObject(ACanvas);
  with ACanvas do begin
    Pen.Width:=Zoom(ThickPen);
    with Events do for I:=0 to (Count-2)
    do DotLine(ACanvas,Zoom(TNode32(Items[I]).XPos),Zoom(TNode32(Items[I]).YPos),
                       Zoom(TNode32(Items[I+1]).XPos),Zoom(TNode32(Items[I+1]).YPos));
    Pen.Width:=Zoom(ThinPen);
  end;
end;

{procedure TNode32.SetDeriv(ADeriv:Real);
begin
  Deriv:=ADeriv;
end; }

destructor TNode32.Destroy;
begin
  {Disconnect;   {creates a bug}
  Owner:=nil;
  Family:=nil;
  inherited Destroy;
end;

procedure TNode32.Disconnect;
  procedure DisconnectUpto(AMove:TMove32);
  begin
    if (AMove.Upto=Self)
    then begin
      AMove.SetUpto(nil);
      AMove.SetPosition(XPos,YPos);
    end;
  end;
begin
  TGameType32(Game).MoveList.ForEach(@DisconnectUpto);
  if Family<>nil then Family.Events.Remove(Self);
  {TGameType32(Game).DeleteSingletons(False); }

end;

procedure TNode32.AssignTo;
begin
  inherited AssignTo(Dest);
  TNode32(Dest).Owner:=Self.Owner;
  TNode32(Dest).Family:=Self.Family;
end;

procedure TNode32.SetOwner(AnOwner:TPlayer32);
begin
  if ObjectTypeIsOk(AnOwner,TPlayer32) then Owner:=AnOwner;
end;

procedure TNode32.SetFamily(AFamily:TInfo32);
begin
  if ObjectTypeIsOk(AFamily,TInfo32)
  or ObjectTypeIsOk(AFamily,TSide32)
  then Family:=AFamily;
end;

function TNode32.ResetRank: Integer;
begin
  Rank:=TGameType32(Game).NodeList.TrueIndex(Self);
  ResetRank:=Rank;
end;

procedure TNode32.Remake;
begin
  inherited Remake;
  ObjType:=ot_Node;
  OwnerRank:=0;
  Owner:=nil;
  FamilyRank:=0;
  Family:=nil;
  Depth:=0;
end;

procedure TNode32.SetPosition(X,Y:Integer);
  procedure CheckEnds(AMove:TMove32);
  begin
    if (AMove.From=Self)
    then AMove.RedoGraphics;
    if (AMove.Upto=Self)
    then AMove.RedoGraphics;
  end;
begin
  inherited SetPosition(X,Y);
  if Game<>nil then TGameType32(Game).MoveList.ForEach(@CheckEnds);
end;

function TNode32.CanDelete;
var HasNoTie:Boolean;
  Procedure CheckTie(AMove:TMove32);
  begin
    with AMove do
    if (From=Self)
    then HasNoTie:=False;
    {if (AMove.Upto=Self)
    then HasNoTie:=False;  See Disconnect}
  end;
begin
  HasNoTie:=True;
  TGameType32(Game).MoveList.ForEach(@CheckTie);
  {Will have to add CellList for tables as upto}
  {if Family<>nil then if Family.Events.Count>=2 then HasNoTie:=False;
  {begin
    Family.Events.Remove(Self);
    Family:=nil;
  end;}
  CanDelete:=HasNoTie;
end;

function TNode32.Description(ForWhat:Integer): String;
begin
  inherited Description(ForWhat);
  if ForWhat=fw_Saving then begin
    if Owner=nil
    then Textline:=Textline+IntToStr(0)
    else Textline:=Textline+IntToStr(Owner.ResetRank);
    StrLenAdjust(sl_Name+5*sl_Short,Textline);
    if Family=nil
    then Textline:=Textline+IntToStr(0)
    else Textline:=Textline+IntToStr(Family.ResetRank);
    StrLenAdjust(sl_Name+6*sl_Short,Textline);
  end else if Owner=nil
           then Textline:=Textline+'(CHANCE)'
           else Textline:=Textline+'('+Owner.Name+')';
  Description:=TextLine;
end;

procedure TNode32.SetLine(AStr:String);
begin
  inherited SetLine(AStr);
  SubStr:=ShowStringPart(AStr,sl_Name+4*sl_Short+1,sl_Short);
  OwnerRank:=ValidInt(SubStr);
  SubStr:=ShowStringPart(AStr,sl_Name+5*sl_Short+1,sl_Short);
  FamilyRank:=ValidInt(SubStr);

end;

function TNode32.Restore:Boolean;
begin
  Restore:=True;
  with TGameType32(Game) do begin
    if (OwnerRank>0) and (OwnerRank<=PlayerList.Count)
    then Owner:=PlayerList.Items[OwnerRank-1]
    else Owner:=nil;
    if (FamilyRank>0) and (FamilyRank<=InfoList.Count)
    then SetFamily(InfoList.Items[FamilyRank-1])
    else SetFamily(nil);
  end;
end;

procedure TNode32.MakeSingleton;
begin
  if (Family=nil) then begin
    Family:=TInfo32.Create(Game);
    TGameType32(Game).InfoList.Add(Family);
    Family.Restore;
  end;
end;

function TNode32.CheckChance:Boolean;
var ProbaSum:Real;
  procedure AddProba(AMove:TMove32);
  begin
    if AMove.From=Self
    then ProbaSum:=ProbaSum+ABS(AMove.Discount);
  end;
begin
  CheckChance:=True;
  ProbaSum:=0;
  if Owner=nil
  then TGameType32(Game).MoveList.ForEach(@AddProba);
  if ProbaSum>1 then CheckChance:=False;
end;

function TNode32.HasInput:Boolean;
  procedure CheckIfInput(AMove:TMove32);
  begin
    if AMove.Upto=Self then HasInput:=True;
  end;
begin
  HasInput:=False;
  TGameType32(Game).MoveList.ForEach(@CheckIfInput);
end;

function TNode32.AlwaysHit(AnInfo:TInfo32):Boolean; {Check if TNode32 always hits AnInfo}
var HasSureHit:Boolean;
  procedure ExplorePathFrom(ANode:TNode32;IsHit:Boolean);
    procedure MatchFrom(AMove:TMove32);
    begin
      if HasSureHit then Exit;
      if AMove.From=ANode
      then begin
        if (AMove.Upto=nil)             {It's a final move}
        or (AMove.Upto.IsActive)        {It has looped back}
        then AlwaysHit:=False           {Can't have hit AnInfo}
        else begin
          if (AMove.Upto.Family<>AnInfo) {Path hasn't hit AnInfo yet}
          then ExplorePathFrom(AMove.Upto,IsHit and (ANode.Owner=nil))  {Explore further}
          else if IsHit and (ANode.Owner=nil) then HasSureHit:=True;
        end;
      end;
    end;
  begin
    ANode.SetActive(True);
    TGameType32(Game).MoveList.ForEach(@MatchFrom);
    ANode.SetActive(False);
  end;
begin
  HasSureHit:=False;
  AlwaysHit:=True;
  ExplorePathFrom(Self,True);
  if HasSureHit then AlwaysHit:=True;
end;

procedure TNode32.SetFrequency(AFrequency:Real);
begin
  Frequency:=AFrequency;
end;

procedure TNode32.SetBelief(ABelief:Real);
begin
  Belief:=ABelief;
end;

function TNode32.ShowDegree: Integer;
var Degree: Integer;
  procedure AddDegree(AMove:TMove32);
  begin
    if AMove.From=Self
    then Degree:=Degree+1;
  end;
begin
  Degree:=0;
  TGameType32(Game).MoveList.ForEach(@AddDegree);
  ShowDegree:=Degree;
end;

procedure TNode32.DrawNode(IsSolid:Boolean;ACanvas:TCanvas);
begin
  with ACanvas do begin
    Pen.Width:=ThinPen;
    if IsSolid then Brush.Color:=Color else Brush.Color:=clWhite; 
    Ellipse(Zoom(XPos-NodeSize),Zoom(YPos-NodeSize),Zoom(XPos+NodeSize),Zoom(YPos+NodeSize));
  end;
end;

procedure TNode32.DrawObject(ACanvas:TCanvas);
begin
  if IsArtificial and not IsDebug then Exit;
  if Owner<>nil then Color:=Owner.Color else Color:=clGray;
  inherited DrawObject(ACanvas);
  DrawNode(True,ACanvas);
end;

function TNode32.OwnRectangle(CrntX,CrntY:Integer;WithConnect:Boolean):TRect;
var R:TRect;
  procedure ConnectMove(AMove:TMove32);
  begin
    if (AMove.From=Self)
    then R:=MaxRect(R,AMove.OwnRectangle(AMove.XPos,AMove.YPos,False));
    if (AMove.Upto=Self)
    then R:=MaxRect(R,AMove.OwnRectangle(AMove.XPos,AMove.YPos,False));
  end;
  procedure ConnectNode(ANode:TNode32);
  begin
    if ANode<>Self then R:=MaxRect(R,ANode.OwnRectangle(ANode.XPos,ANode.YPos,False));
  end;
begin
  R:=inherited OwnRectangle(CrntX,CrntY,WithConnect);
  if WithConnect then begin
    TGameType32(Game).MoveList.ForEach(@ConnectMove);
    if Family<>nil then Family.Events.ForEach(@ConnectNode);
  end;
  OwnRectangle:=R;
end;

{TSide32 implementation}

procedure TSide32.Remake;
begin
  inherited Remake;
  ObjType:=ot_Side;
  OwnTable:=nil;
  FrontStrat:=nil;
  if Owner=nil
  then SetName('')
  else if ObjectTypeIsOk(Owner,TPlayer32)
       then SetName(Owner.Name);
end;

destructor TSide32.Destroy;
  procedure RemoveChoice(AStrat:TStrat32);
  begin
    DeleteCells(AStrat); {destroy cells with this strategy}
    with TGameType32(Game).ChoiceList do
    if HasItem(AStrat) then Remove(AStrat);
  end;
begin
  Choices.ForEach(@RemoveChoice);
  OwnTable:=nil;
  inherited Destroy;  {Will free strats}
end;

procedure TSide32.DeleteCells(AStrat:TStrat32);
  procedure MatchStrat(ACell:TCell32);
  begin
    if (AStrat=ACell.FindStrategyOf(Self))
    then begin
      ACell.SetUnclean;
      with TGameType32(Game).MoveList do
      if HasItem(ACell) then Remove(ACell);
    end;
  end;
begin
  if OwnTable=nil then Exit;
  if not ObjectTypeIsOk(OwnTable,TTable32) then Exit;
  OwnTable.Cells.ForEach(@MatchStrat);
  OwnTable.Cells.FreeAll(ot_Unclean);
end;

function TSide32.ResetRank: Integer;
begin
  Rank:=TGameType32(Game).InfoList.TrueIndex(Self);
  ResetRank:=Rank;
end;

function TSide32.Description(ForWhat:Integer) : String;
begin
  inherited Description(ForWhat);
  if ForWhat=fw_Saving then begin
    if Owner=nil
    then Textline:=Textline+IntToStr(0)
    else Textline:=Textline+IntToStr(Owner.ResetRank);
    StrLenAdjust(sl_Name+5*sl_Short,Textline);
    if OwnTable=nil
    then Textline:=Textline+IntToStr(0)
    else Textline:=Textline+IntToStr(OwnTable.ResetRank);
    StrLenAdjust(sl_Name+6*sl_Short,Textline);
  end else begin
    if Owner=nil
    then Textline:=Textline+'(CHANCE)'
    else Textline:=Textline+'('+Owner.Name+')';
    if OwnTable=nil
    then Textline:=Textline+'(No Table)'
    else Textline:=Textline+'('+OwnTable.Name+')';
  end;
  Description:=TextLine;
end;

procedure TSide32.SetLine(AStr:String);
begin
  inherited SetLine(AStr);
  SubStr:=ShowStringPart(AStr,sl_Name+4*sl_Short+1,sl_Short);
  OwnerRank:=ValidInt(SubStr);
  SubStr:=ShowStringPart(AStr,sl_Name+5*sl_Short+1,sl_Short);
  TableRank:=ValidInt(SubStr);

end;

procedure TSide32.ResetSide;
  procedure RecoverOwner(APlayer:TPlayer32);
  begin
    if APlayer.Rank=OwnerRank
    then SetOwner(APlayer);
  end;
  procedure RecoverTable(ATable:TNode32);
  begin
    if ATable.ObjType=ot_Table
    then if ATable.Rank=TableRank
    then SetTable(TTable32(ATable));
  end;
begin
  OwnTable:=nil; Owner:=nil;
  TGameType32(Game).PlayerList.ForEach(@RecoverOwner);
  TGameType32(Game).NodeList.ForEach(@RecoverTable);
  if OwnTable<>nil then OwnTable.Sides.Add(Self);
end;

function TSide32.TabOrder: Integer;
begin
  TabOrder:=-1;
  if OwnTable<>nil then if ObjectTypeIsOk(OwnTable,TTable32)
  then TabOrder:=OwnTable.Sides.IndexOf(Self);
end;

procedure TSide32.SetTable(ATable:TTable32);
begin
  OwnTable:=ATable;
end;

function TSide32.IsDetected(X,Y:Integer): Boolean;
begin
  if (Abs(NamePos-X)+Abs(YPos-Y))<Zoom(HiLiteSize)
  then IsDetected:=True
  else IsDetected:=False;
end;

procedure TSide32.ResetFront;
  procedure CheckIfFront(AStrat:TStrat32);
  begin
    if AStrat.IsInFront then FrontStrat:=AStrat;
  end;
  procedure RemoveFront(AStrat:TStrat32);
  begin
    AStrat.SetInFront(False);
  end;
begin
  if (TabOrder<=1) or (Choices.Count=0) then Exit;
  FrontStrat:=nil;
  Choices.ForEach(@CheckIfFront);
  Choices.ForEach(@RemoveFront);
  if FrontStrat=nil then FrontStrat:=TStrat32(Choices[0]);
  FrontStrat.SetInFront(True);
end;

procedure TSide32.RedoGraphics;
  procedure Reposition(AnObject:TStrat32);
  begin
    AnObject.RedoGraphics;
    if IsInFront then AnObject.SetInFront(True);
  end;
begin
  if Owner<>nil then Color:=Owner.Color else Color:=clGray;
  if TabOrder=1
  then NamePos:=XPos+Round((CellWidth*Choices.Count)/2)
  else NamePos:=XPos;
  if TabOrder<=1 then SetInFront(True);
  Choices.ForEach(@Reposition);
  ResetFront;
end;

procedure TSide32.DrawObject(ACanvas:TCanvas);
  procedure DrawChoice(AChoice:TStrat32);
  begin
    AChoice.DrawObject(ACanvas);
  end;
begin
  {inherited DrawObject(ACanvas); }
  with ACanvas do begin
    Font.Color:=Color;
    Brush.Color:=clWhite;
    TextOut(Zoom(NamePos+8),Zoom(YPos),Owner.Name);
    DrawHuman(NamePos,YPos,Color,ACanvas);
  end;
end;

procedure TSide32.RemoveAllChoices; {From game}
  procedure RemoveChoice(AChoice:TChoice32);
  begin
    with TGameType32(Game).ChoiceList do
    if HasItem(AChoice) then Remove(AChoice);
  end;
begin
  Choices.ForEach(@RemoveChoice);
end;

procedure TSide32.AddAllChoices; {To game}
  procedure AddChoice(AChoice:TChoice32);
  begin
    with TGameType32(Game).ChoiceList do
    if not HasItem(AChoice) then Add(AChoice);
  end;
begin
  Choices.ForEach(@AddChoice);
end;

procedure TSide32.AssignTo;
  procedure DuplicateChoice(AChoice:TChoice32);
  var NewChoice:TStrat32;
  begin
    NewChoice:=TStrat32.Create(Game);
    NewChoice.SetName(AChoice.Name{+'*'});        {Replaces source (side/info)}
    NewChoice.SetSource(TSide32(Dest));
    AChoice.SetAssociate(NewChoice);            {For replacement steps in cells}
    NewChoice.SetAssociate(AChoice);
    TSide32(Dest).Choices.Add(NewChoice);
  end;
begin
  inherited AssignTo(Dest);           {Object.Assign for Name}
  TSide32(Dest).SetOwner(Self.Owner); {Because no defined Info.Assign}
  TSide32(Dest).SetTable(Self.OwnTable);
  TSide32(Dest).Choices.FreeAll(ot_All);
  Choices.ForEach(@DuplicateChoice);
end;

procedure TSide32.ConvertToMoves(AFrom:TNode32);
var AMove:TMove32; AnUpto:TNode32; ANextSide:TSide32; {AMatchCell:TCell32;}
  procedure AddMove(AStrat:TStrat32);
  begin
    OwnTable.TestCell.ReplaceStrategy(nil,AStrat); {Put AStrat in StratSet for side}
    if ANextSide<>nil then begin
      AMove:=TMove32.Create(Game);
      AMove.SetArtificial(True);
      TGameType32(Game).MoveList.Add(AMove);
      AnUpto:=TNode32.Create(Game);
      AnUpto.SetArtificial(True); {creates bug unless TGameForm32.ResetInfos adjusted}
      AnUpto.SetOwner(ANextSide.Owner);
      AnUpto.SetFamily(ANextSide);
      ANextSide.Events.Add(AnUpto);
      TGameType32(Game).NodeList.Add(AnUpto);
      AMove.SetUpto(AnUpto);
      ANextSide.ConvertToMoves(AnUpto); {Recurrent call}
    end else AMove:=TMove32(OwnTable.FindMatch(OwnTable.TestCell));
    if AMove<>nil then with AMove do begin
        SetFrom(AFrom);
        SetName(AStrat.Name);
        SetChoice(AStrat);
        AStrat.AddInstance(AMove);
    end;
  end;
begin
  ANextSide:=OwnTable.NextSide(Self);
  Choices.ForEach(@AddMove);
end;

{TTable32 implementation}

procedure TTable32.Remake;
begin
  inherited Remake;
  ObjType:=ot_Table;
  SetName('Table');
  Color:=clGray;
  Sides:=TGameList.Create;
  Cells:=TGameList.Create;
  TestCell:=TCell32.Create(Game);
  TestCell.SetTable(Self);
end;

destructor TTable32.Destroy;
  procedure RemoveSide(ASide:TSide32);
  begin
    with TGameType32(Game).InfoList do
    if HasItem(ASide) then Remove(ASide);
  end;
  procedure SevereLink(AMove:TMove32);
  begin
    if AMove.Upto=Self then AMove.SetUpto(nil);
  end;
begin
  TGameType32(Game).MoveList.ForEach(@SevereLink);
  Sides.ForEach(@RemoveSide);
  Sides.FreeAll(ot_All); {Also frees associated cells}
  Sides.Free;
  Cells.Free;
  TestCell.Free;
  inherited Destroy;
end;

procedure TTable32.AssignTo;  {Used only to copy table}
  procedure DuplicateSide(ESide:TSide32);
  var ASide:TSide32;
    procedure DuplicateChoice(EChoice:TChoice32);
    var AChoice:TStrat32;
    begin
      AChoice:=TStrat32.Create(Game);
      AChoice.SetName(EChoice.Name);
      EChoice.SetAssociate(AChoice);
      AChoice.SetSource(ASide);
      ASide.Choices.Add(AChoice);
    end;
  begin
    ASide:=TSide32.Create(Game);
    TTable32(Dest).Sides.Add(ASide);
    TGameType32(Game).DispatchObject(ASide);
    ASide.SetOwner(ESide.Owner);
    ASide.SetName(ESide.Name);
    ASide.SetTable(TTable32(Dest));
    ESide.Choices.ForEach(@DuplicateChoice);
    ASide.AddAllChoices; {To Game}
  end;
  procedure DuplicateCell(ECell:TCell32);
  var ACell:TCell32;
  begin
    ACell:=TCell32.Create(Game);
    ACell.Assign(ECell);
    ACell.SetTable(TTable32(Dest));
    TTable32(Dest).Cells.Add(ACell);
    TTable32(Dest).RestoreCells;
  end;
begin
  inherited AssignTo(Dest);
  Sides.ForEach(@DuplicateSide);
  Cells.ForEach(@DuplicateCell);
end;

procedure TTable32.DeleteSide(ASide:TSide32);
begin
  if ASide=nil then Exit;
  with TGameType32(Game).InfoList do
  if HasItem(ASide) then Remove(ASide);
  with Sides do if HasItem(ASide) then Remove(ASide);
  ASide.Free; {Frees and removes associated cells}
  Sides.Pack;
  Cells.Pack;


end;

{function TTable32.ResetRank: Integer;
begin
  Rank:=TGameType32(Game).NodeList.TrueIndex(Self);
  ResetRank:=Rank;
end; }

procedure TTable32.DrawObject(ACanvas:TCanvas);
  procedure DrawVertical(ASide:TSide32);
  begin
    if ASide.TabOrder>1
    then with ACanvas do begin
      MoveTo(Zoom(ASide.XPos-MarginDim),Zoom(YPos));
      LineTo(Zoom(ASide.XPos-MarginDim),Zoom(YPos+TabHeight));
    end;
  end;
begin
  {inherited DrawObject(ACanvas); }
  with ACanvas do begin
    Pen.Color:=Self.Color;
    Pen.Width:=Zoom(ThickPen);
    Font.Color:=Self.Color;
    Brush.Color:=clWhite;
    RedoGraphics;
    RoundRect(Zoom(XPos),Zoom(YPos),Zoom(XPos+TabWidth),Zoom(YPos+TabHeight),Zoom(RoundDim),Zoom(RoundDim));
    Font.Size:=Zoom(8);
    TextOut(Zoom(XPos-ThickPen),Zoom(YPos-ThickPen),Self.Name+' ');
    Sides.ForEach(@DrawVertical);
  end;
end;

function TTable32.OwnRectangle(CrntX,CrntY:Integer;WithConnect:Boolean):TRect;
var R:TRect;
begin
  R:=inherited OwnRectangle(CrntX,CrntY,WithConnect);
  R.BottomRight.X:=CrntX+Zoom(TabWidth+RectSize);
  R.BottomRight.Y:=CrntY+Zoom(TabHeight+RectSize);
  OwnRectangle:=R;
end;

procedure TTable32.RedoGraphics;
var ChoiceCount: Integer;
  procedure Reposition(AnObject:TGameObject32);
  begin
    AnObject.RedoGraphics;
  end;
  procedure AddSideDim(ASide:TSide32);
  begin
    case ASide.TabOrder of
      -1: Exit;
      0 : begin TabWidth:=MarginDim+CellWidth;
                ASide.SetPosition(XPos+MarginDim,YPos+5*MarginDim); end;
      1 : begin ASide.SetPosition(XPos+TabWidth,YPos+MarginDim);
                TabWidth:=TabWidth+CellWidth*ASide.Choices.Count; end;
      else begin ASide.SetPosition(XPos+TabWidth+MarginDim,YPos+5*MarginDim);
                 TabWidth:=TabWidth+CellWidth; end;

    end;
  end;
  procedure FindMaxCount(ASide:TSide32);
  begin
    with ASide do if TabOrder<>1
                  then if Choices.Count>ChoiceCount
                       then ChoiceCount:=Choices.Count;
  end;
begin
  CellHeight:=TGameType32(Game).PlayerList.Count*SideHeight;
  Sides.ForEach(@AddSideDim);
  ChoiceCount:=0;
  Sides.ForEach(@FindMaxCount);
  TabHeight:=4*MarginDim+3*SideHeight+CellHeight*ChoiceCount;
  Sides.ForEach(@Reposition);
  Cells.ForEach(@Reposition);
  if TabWidth<=CellWidth then TabWidth:=TabWidth+CellWidth;
end;

function TTable32.NextSide(ASide:TSide32):TSide32;
var SideIndex:Integer;
begin
  NextSide:=nil;
  if Sides.Count>0 {NextSide(nil) returns nil if no sides}
  then begin
    if ASide=nil then SideIndex:=0
    else SideIndex:=Sides.IndexOf(ASide)+1;
    if SideIndex<Sides.Count then NextSide:=Sides.Items[SideIndex];
  end;
end;

function TTable32.FindMatch(ACell:TCell32):TCell32;
  procedure CompareCell(BCell:TCell32);
  begin
    if BCell.IsMatchOf(ACell) then FindMatch:=BCell;
  end;
begin
  FindMatch:=nil;
  Cells.ForEach(@CompareCell);
end;

procedure TTable32.MatchOrCreate(ACell:TCell32);
var NewCell:TCell32;
begin
  if FindMatch(ACell)=nil then begin
    NewCell:=TCell32.Create(nil);
    NewCell.Assign(ACell);   {Choices must be self-associated, as when created}
    NewCell.SetTable(Self);
    NewCell.SetGame(Game); {Because Assign doesn't do it properly}
    Cells.Add(NewCell);
    with TGameType32(Game).MoveList do
    if not HasItem(NewCell) then Add(NewCell);
  end;
end;

procedure TTable32.EnumerateChoices(ASide:TSide32);
var BSide:TSide32;
  procedure RecordChoice(AChoice:TStrat32);
  begin
    TestCell.ReplaceStrategy(nil,AChoice); {Remove same side strategy in test cell}
    BSide:=NextSide(ASide);
    if BSide=nil then MatchOrCreate(TestCell)
    else EnumerateChoices(BSide);
  end;
begin
  if ASide<>nil then ASide.Choices.ForEach(@RecordChoice);
end;

procedure TTable32.RemoveCells;
  procedure RemoveACell(ACell:TCell32);
  begin
    with TGameType32(Game).MoveList do
    if HasItem(ACell) then Remove(ACell);
  end;
begin
  Cells.ForEach(@RemoveACell);
end;

procedure TTable32.RestoreCells;
  procedure AddACell(ACell:TCell32);
  begin
    with TGameType32(Game).MoveList do
    if not HasItem(ACell) then Add(ACell);
  end;
begin
  Cells.ForEach(@AddACell);
end;

procedure TTable32.UpdateCells;
  procedure ReAssign(ACell:TCell32);
  begin
    ACell.UpdateToAssociates;
  end;
begin
  Cells.ForEach(@ReAssign);
end;

procedure TTable32.SelfAssociateChoices;
  procedure ReAssociateChoices(ASide:TSide32);
    procedure SetSelfAssociate(AChoice:TStrat32);
    begin
      AChoice.SetAssociate(AChoice);
    end;
  begin
    ASide.Choices.ForEach(@SetSelfAssociate);
  end;
begin
  Sides.ForEach(@ReAssociateChoices);
end;

procedure TTable32.SidesToCells;
  procedure CheckIfValidChoices(ACell:TCell32);
  begin
    if not ACell.HasValidChoices
    then ACell.SetUnclean;
  end;
begin
  SelfAssociateChoices; {Preserves non-edited choices in update to associates}
  Cells.ForEach(@CheckIfValidChoices);
  Cells.FreeAll(ot_Unclean);
  TestCell.StratSet.Clear;
  if Sides.Count>1 then EnumerateChoices(Sides.Items[0]);
end;

procedure TTable32.TableToNode;
var FirstSide:TSide32;
begin
  FirstSide:=Sides[0];
  SetOwner(FirstSide.Owner);
  FirstSide.Events.Add(Self);
  SetFamily(FirstSide);
end;

function TTable32.ConvertToGraph:Boolean;
begin
  if Sides.Count<2 then ConvertToGraph:=False
  else begin
    ConvertToGraph:=True;
    TableToNode; {Make table into event of first side}
    TSide32(Sides[0]).ConvertToMoves(Self);
  end;
end;

{TCell32 implementation}

procedure TCell32.AssignTo;
  procedure FillStratSet(AStrategy:TChoice32);
  begin
    TCell32(Dest).StratSet.Add(AStrategy.Associate);
  end;
begin
  inherited AssignTo(Dest); {From TMove32, duplicates payoffs}
  TCell32(Dest).StratSet.Clear;
  StratSet.ForEach(@FillStratSet);
  TCell32(Dest).RenameCell;
end;

procedure TCell32.UpdateToAssociates;
  procedure StoreInGarbage(AChoice:TChoice32);
  begin
    TGameType32(Game).Selection.Add(AChoice);
  end;
  procedure DoUpdate(AChoice:TChoice32);
  begin
    StratSet.Remove(AChoice);
    StratSet.Add(AChoice.Associate);
  end;
begin
  TGameType32(Game).Selection.Clear;
  StratSet.ForEach(@StoreInGarbage);
  TGameType32(Game).Selection.ForEach(@DoUpdate);
  TGameType32(Game).Selection.Clear;
end;

procedure TCell32.ReplaceStrategy(OldStrategy,NewStrategy:TStrat32);
var AStrategy:TStrat32;
begin
  AStrategy:=FindStrategyOf(NewStrategy.Source);
  if (OldStrategy=nil)
  or (OldStrategy=AStrategy)
  then begin
    if AStrategy<>nil then StratSet.Remove(AStrategy);
    StratSet.Pack;
    StratSet.Add(NewStrategy);
  end;
end;

destructor TCell32.Destroy;
begin
  StratSet.Clear;
  StratSet.Free;
  OwnTable:=nil;
  inherited Destroy;
end;

procedure TCell32.Remake;
begin
  inherited Remake;
  ObjType:=ot_Cell;
  OwnTable:=nil;
  Drift:=0;
  StratSet:=TGameList.Create;
end;

function TCell32.Description(ForWhat:Integer) : String;
var VarLength: Integer;
  procedure WriteStrat(AStrat:TStrat32);
  begin
    Textline:=Textline+IntToStr(AStrat.ResetRank);
    VarLength:=VarLength+sl_Short;
    StrLenAdjust(VarLength,Textline);
  end;
  procedure WriteChoice(AChoice:TStrat32);
  begin
    Textline:=Textline+AChoice.Name+' ';
  end;
begin
  inherited Description(ForWhat); {From TMove32}
  if ForWhat=fw_Saving then begin
    Textline:=Textline+IntToStr(OwnTable.ResetRank);
    VarLength:=sl_Name+8*sl_Short;
    StrLenAdjust(VarLength,Textline);
    StratSet.ForEach(@WriteStrat);
  end else begin
    Textline:='';
    StratSet.ForEach(@WriteChoice);
    if From<>nil then TextLine:=TextLine+'@'+From.Name;
    if OwnChoice<>nil then TextLine:=TextLine+' for '+OwnChoice.Name;
  end;
  Description:=TextLine;
end;

procedure TCell32.SetLine(AStr:String);
var VarLength, ARank: Integer;
begin
  inherited SetLine(AStr);
  SubStr:=ShowStringPart(AStr,sl_Name+7*sl_Short+1,sl_Short);
  TableRank:=ValidInt(SubStr);
  StratRanks:=[];
  VarLength:=sl_Name+8*sl_Short+1;
  repeat
    SubStr:=ShowStringPart(TextLine,VarLength,sl_Short);
    ARank:=ValidInt(SubStr);
    if (ARank>=1) then StratRanks:=StratRanks+[ARank];
    VarLength:=VarLength+sl_Short;
  until (ARank<0);
end;

procedure TCell32.ResetCell; {Complements SetLine}
  procedure RecoverTable(ATable:TNode32);
  begin
    if ObjectTypeIsOk(ATable,TTable32)   {(ATable.ObjType=ot_Table)}
    and (ATable.Rank=TableRank)
    then SetTable(TTable32(ATable));
  end;
  procedure RecoverStrats(AStrat:TChoice32);
  begin
    if AStrat.Rank in StratRanks
    then StratSet.Add(AStrat);
  end;
begin
  OwnTable:=nil;
  TGameType32(Game).NodeList.ForEach(@RecoverTable);
  TGameType32(Game).ChoiceList.ForEach(@RecoverStrats);
  if (OwnTable=nil)
  then SetUnclean
  else if (OwnTable.Sides.Count<>StratSet.Count)
       then SetUnclean
       else if not OwnTable.Cells.HasItem(Self)
            then OwnTable.Cells.Add(Self);
end;

function TCell32.ResetRank: Integer;
begin
  Rank:=TGameType32(Game).MoveList.TrueIndex(Self);
  ResetRank:=Rank;
end;

function TCell32.IsDetected(X,Y:Integer): Boolean;
begin
  if not IsInFront then IsDetected:=False
  else if
        (X>XFro-SideHeight)
    and (X<XFro-SideHeight+CellWidth)
    and (Y>YFro)
    and (Y<YFro+OwnTable.CellHeight)

  {(Abs(XPos-X)+Abs(YPos-Y))<Zoom(2*HiLiteSize)}
       then IsDetected:=True
       else IsDetected:=False;
end;

procedure TCell32.RenameCell;
  procedure AddChoiceName(AChoice:TChoice32);
  begin
    SetName(Name+AChoice.Name+' ');
  end;
begin
  SetName('');
  StratSet.ForEach(@AddChoiceName);
end;

procedure TCell32.SetTable(ATable:TTable32);
begin
  OwnTable:=ATable;
end;

function TCell32.FindStrategyOf(ASide:TInfo32):TStrat32;
var IsFound:Boolean;
  procedure FindSameSide(AStrategy:TStrat32);
  begin
    if AStrategy=nil then Exit;
    if not ObjectTypeIsOk(AStrategy,TStrat32) then Exit;
    if (AStrategy.Source=ASide)
    then if IsFound
         then FindStrategyOf:=nil
         else begin
           FindStrategyOf:=AStrategy;
           IsFound:=True;
         end;
  end;
begin
  FindStrategyOf:=nil;
  IsFound:=False;
  StratSet.ForEach(@FindSameSide);
end;

function TCell32.IsMatchOf(ACell:TCell32):Boolean;
  procedure CheckIfMatch(ASide:TSide32);
  begin
    if FindStrategyOf(ASide)<>ACell.FindStrategyOf(ASide)
    then IsMatchOf:=False;
  end;
begin
  if (OwnTable=nil)
  or not ObjectTypeIsOk(OwnTable,TTable32)
  then IsMatchOf:=False
  else begin
    IsMatchOf:=True;
    OwnTable.Sides.ForEach(@CheckIfMatch);
  end;
end;

function TCell32.HasValidChoices:Boolean;
  procedure CheckChoice(ASide:TSide32);
  begin
    if FindStrategyOf(ASide)=nil then HasValidChoices:=False;
  end;
begin
  HasValidChoices:=True;
  if (OwnTable=nil)
  or not ObjectTypeIsOk(OwnTable,TTable32)
  then HasValidChoices:=False
  else if OwnTable.Sides.Count<=1
       then HasValidChoices:=False
       else OwnTable.Sides.ForEach(@CheckChoice);
end;

procedure TCell32.ResetDrift;
var AStrat:TStrat32;
  procedure AddSideDrift(ASide:TSide32);
  begin
    if OwnTable.Sides.IndexOf(ASide)<=1 then Exit;
    AStrat:=FindStrategyOf(ASide);
    if AStrat<>nil
    then Drift:=Drift+DriftSize*ASide.Choices.IndexOf(AStrat);
  end;
begin
  Drift:=0;
  if not ObjectTypeIsOk(OwnTable,TTable32) then Exit;
  OwnTable.Sides.ForEach(@AddSideDrift);
  if Drift>=MaxDrift then Drift:=MaxDrift;
end;

procedure TCell32.RedoGraphics;
var AStrategy:TStrat32;DirX,DirY,Len :Integer;
  procedure CheckInFront(AStrat:TStrat32);
  begin
    if not AStrat.IsInFront then SetInFront(False);
  end;
  procedure MatchInFront(APayoff:TPayoff32);
  begin
    if IsInFront then APayoff.SetInFront(True) else APayoff.SetInFront(False);
  end;
begin
  if OwnTable=nil then Exit;
  if not ObjectTypeIsOk(OwnTable,TTable32) then Exit;
  if OwnTable.Sides.Count<=1 then Exit;
  AStrategy:=FindStrategyOf(TSide32(OwnTable.Sides.Items[1]));
  if AStrategy<>nil then XFro:=AStrategy.XPos else XFro:=50;
  AStrategy:=FindStrategyOf(TSide32(OwnTable.Sides.Items[0]));
  if AStrategy<>nil then YFro:=AStrategy.YPos-MarginDim else YFro:=50;

  ResetDrift; {Increases with strategies of 3rd, 4th, .. sides}
  XFro:=XFro+Drift;
  YFro:=YFro-Drift;

  if Upto=nil
  then begin XPos:=XFro; YPos:=YFro;
  end else begin
    MakeCurve(XFro,YFro+MarginDim);
    DirX:=Upto.XPos-XFro;
    DirY:=Upto.YPos-YFro-MarginDim;
    Len:=MaxInt(1,abs(DirX)+abs(DirY));
    DirX:=Round(ArrowLen*DirX/Len);
    DirY:=Round(ArrowLen*DirY/Len);
    Arrow:=MakeAnArrow(XPos,YPos,DirX,DirY);
  end;
  SetInFront(True);
  StratSet.ForEach(@CheckInFront);
end;

procedure TCell32.DrawObject(ACanvas:TCanvas);
begin
  if OwnTable=nil then Exit;
  if not ObjectTypeIsOk(Self,TCell32) then Exit;
  if IsInFront then with ACanvas do begin
    Pen.Color:=clGray;
    Pen.Width:=ThinPen;
    Brush.Color:=clWhite;
    Rectangle(Zoom(XFro-SideHeight),Zoom(YFro),1+Zoom(XFro-SideHeight+CellWidth),1+Zoom(YFro+OwnTable.CellHeight));
    if Upto<>nil then begin
      Brush.Color:=clGray;
      Ellipse(Zoom(XFro-PlaySize),Zoom(YFro+MarginDim-PlaySize),Zoom(XFro+PlaySize),Zoom(YFro+MarginDim+PlaySize));
      if Upto<>nil then begin
        DrawCurve(True,ACanvas);
        DrawArrow(ACanvas,Arrow);
        if (Discount<1) then begin
          Brush.Color:=clWhite;
          Font.Color:=clBlack;
          TextOut(Zoom(XPos+PayGap),Zoom(YPos-2*PayGap),
                   'd= '+FloatToStrF(Discount,ffGeneral,floatdgts,floatdgts));
        end;
      end;
    end;
  end;
end;

{TMove32 implementation}

destructor TMove32.Destroy;
begin
  From:=nil;
  Upto:=nil;
  OwnChoice:=nil;
  DeletePayments;
  Payments.Free;
  inherited Destroy;
end;

procedure TMove32.TransferPayments(DestMove:TMove32);
  procedure TransferPay(APayoff:TPayoff32);
  begin
    APayoff.SetWhere(DestMove); {Modify where}
  end;
begin
  ResetPayments;
  Payments.ForEach(@TransferPay);
  DestMove.ResetPayments;
  SetAssociate(DestMove); {For transfer back}
end;

procedure TMove32.DuplicatePayments(DestMove:TPersistent);
var NewPay: TPayoff32;
  procedure DuplicatePay(APayoff:TPayoff32);
  begin
    NewPay:=TPayoff32.Create(Game);
    NewPay.Assign(APayoff);  {Sets Whom, Where and Value in EditPayoff}
    NewPay.SetWhere(TGameObject32(DestMove)); {Modify where}
    TGameType32(Game).PayList.Add(NewPay);
  end;
begin
  ResetPayments;
  Payments.ForEach(@DuplicatePay);
  TMove32(DestMove).ResetPayments;
end;

procedure TMove32.AssignTo(Dest:TPersistent);
begin
  inherited AssignTo(Dest);
  TMove32(Dest).SetFrom(Self.From);
  TMove32(Dest).SetUpto(Self.Upto);
  TMove32(Dest).SetDiscount(Self.Discount);
  {Now, MakePayments and assign them as well}
  TMove32(Dest).DeletePayments;
  DuplicatePayments(Dest);
end;

procedure TMove32.DeletePayments;
  procedure RemoveFromGame(APayoff:TPayoff32);
  begin
    TGameType32(Game).PayList.Remove(APayoff);
  end;
begin
  ResetPayments;
  Payments.ForEach(@RemoveFromGame);
  Payments.FreeAll(ot_All);
end;

procedure TMove32.ResetPayments;
  procedure AddPayment(APayment:TPayoff32);
  begin
    if APayment.Where=Self
    then Payments.Add(APayment);
  end;
begin
  Payments.Clear;
  if Game<>nil then TGameType32(Game).PayList.ForEach(@AddPayment);
end;

function TMove32.ResetRank: Integer;
begin
  Rank:=TGameType32(Game).MoveList.TrueIndex(Self);
  ResetRank:=Rank;
end;

procedure TMove32.Remake;
begin
  inherited Remake;
  ObjType:=ot_Move;
  FromRank:=0;
  From:=nil;
  UptoRank:=0;
  Upto:=nil;
  Discount:=DfltDscnt;
  OwnChoice:=nil;
  IsInFront:=True;
  Payments:=TGameList.Create;
end;

procedure TMove32.SetPosition(X,Y:Integer);
begin
  inherited SetPosition(X,Y);
  RedoGraphics;
end;

procedure TMove32.SetFrom(AFrom:TNode32);
begin
  From:=AFrom;
end;

procedure TMove32.SetUpto(AnUpto:TNode32);
begin
  Upto:=AnUpto;
end;

procedure TMove32.SetDiscount(ADiscount:Real);
begin
  Discount:=ADiscount;
end;

{function TMove32.CanDelete:Boolean;
var HasNoTie:Boolean;
  procedure FindPayoff(APayoff:TPayoff32);
  begin
    if APayoff.Where=Self
    then HasNoTie:=False;
  end;
begin
  HasNoTie:=True;
  TGameType32(Game).PayList.ForEach(@FindPayoff);
  CanDelete:=HasNoTie;
end; }

procedure TMove32.RedoGraphics;
begin
  if From=nil then Exit;
  MakeArrow;
  if Upto=nil then MakeLine else MakeCurve(From.XPos,From.YPos);
end;

procedure TMove32.MakeArrow;
var
 Length,
 DirX,
 DirY   : Integer;
begin
  if Upto=nil
  then begin
    DirX:=XPos-From.XPos;
    DirY:=YPos-From.YPos;
  end else begin
    DirX:=Upto.XPos-From.XPos;
    DirY:=Upto.YPos-From.YPos;
  end;
  Length:=MaxInt(1,abs(DirX)+abs(DirY));
  DirX:=Round(ArrowLen*DirX/Length); {Normalize}
  DirY:=Round(ArrowLen*DirY/Length);
  Arrow:=MakeAnArrow(XPos,YPos,DirX,DirY);
end;

procedure TMove32.MakeLine;
var
 Ax,Ay  : Real;
 I      : Byte;
begin
    Curve[0].X:=From.XPos;
    Curve[0].Y:=From.YPos;
    Ax:=ArcStep*(XPos-From.XPos);
    Ay:=ArcStep*(YPos-From.YPos);
    for I:=1 to 20
    do begin  {Draw a straight line}
      Curve[I].X:=Round(From.XPos+I*Ax);
      Curve[I].Y:=Round(From.YPos+I*Ay);
    end;
end;

procedure TMove32.MakeCurve(FroX,FroY:Integer);
var
 T,S,R,
 Ax,Ay,
 Bx,By  : Real;
 I      : Byte;
begin
  if Upto<>nil then begin
    Ax:=(FroX+Upto.XPos)/2-XPos;
    Ay:=(FroY+Upto.YPos)/2-YPos;
    Bx:=(Upto.XPos-FroX)/2;
    By:=(Upto.YPos-FroY)/2;
    Curve[0].X:=FroX;
    Curve[0].Y:=FroY;
    for I:=1 to 20
    do begin
      T:=-1+I*0.1;
      S:=Sqr(T);
      R:=Ax*S+Bx*T+XPos;
      Curve[I].X:=Round(R);
      R:=Ay*S+By*T+YPos;
      Curve[I].Y:=Round(R);
    end;
  end;
end;

function TMove32.OwnRectangle(CrntX,CrntY:Integer;WithConnect:Boolean):TRect;
var R:TRect;
begin
  R:=inherited OwnRectangle(CrntX,CrntY,WithConnect);
  if WithConnect then begin
    if From<>nil then R:=MaxRect(R,From.OwnRectangle(From.XPos,From.YPos,False));
    if Upto<>nil then R:=MaxRect(R,Upto.OwnRectangle(Upto.XPos,Upto.YPos,False));
  end;
  OwnRectangle:=R;
end;

function TMove32.Description(ForWhat:Integer): String;
begin
  inherited Description(ForWhat);
  if ForWhat=fw_Saving then begin
    if (From=nil) or (ObjType=ot_Cell)
    then Textline:=Textline+IntToStr(0)
    else Textline:=Textline+IntToStr(From.ResetRank);
    StrLenAdjust(sl_Name+5*sl_Short,Textline);
    if (Upto=nil)
    then Textline:=Textline+IntToStr(0)
    else Textline:=Textline+IntToStr(Upto.ResetRank);
    StrLenAdjust(sl_Name+6*sl_Short,Textline);
    Textline:=Textline+FloatToStrF(Discount,ffGeneral,floatdgts,floatdgts);
    StrLenAdjust(sl_Name+7*sl_Short,Textline);
  end else if (From<>nil)
           then Textline:=Textline+'@'+From.Description(fw_Audit);
  Description:=TextLine;
end;

procedure TMove32.SetLine(AStr:String);
begin
  inherited SetLine(AStr);
  SubStr:=ShowStringPart(AStr,sl_Name+4*sl_Short+1,sl_Short);
  FromRank:=ValidInt(SubStr);
  SubStr:=ShowStringPart(AStr,sl_Name+5*sl_Short+1,sl_Short);
  UptoRank:=ValidInt(SubStr);
  SubStr:=ShowStringPart(AStr,sl_Name+6*sl_Short+1,sl_Short);
  Discount:=ValidReal(SubStr);

end;

function TMove32.Restore:Boolean;
begin
  Restore:=True;
  {if ObjType=ot_Move then}
  with TGameType32(Game) do begin
    if (FromRank>0) and (FromRank<=NodeList.Count)
    then From:=NodeList.Items[FromRank-1] else From:=nil;
    if (UptoRank>0) and (FromRank<=NodeList.Count)
    then Upto:=NodeList.Items[UptoRank-1] else Upto:=nil;
    RedoGraphics;
  end;
end;

procedure TMove32.DrawCurve(IsSolid:Boolean;ACanvas:TCanvas);
var Indx:Integer;
begin
  with ACanvas do begin
    with Curve[0] do MoveTo(Zoom(X),Zoom(Y));
    if not IsSolid Then Pen.Color:=clWhite;
    for Indx:=1 to ArcPrecis do
    with Curve[Indx] do if IsSolid
                        then LineTo(Zoom(X),Zoom(Y))
                        else if IsEven(Indx)
                             then LineTo(Zoom(X),Zoom(Y))
                             else MoveTo(Zoom(X),Zoom(Y));
  end;
end;

procedure TMove32.DrawObject(ACanvas:TCanvas);
begin
  if IsArtificial and not IsDebug then Exit;
  {if ObjType<>ot_Move then Exit; }
  if not ObjectTypeIsOk(Self,TMove32) then Exit;
  if From=nil then Exit;
  if (From.Owner<>nil) {and IsActivated {For debug}
  then Color:=From.Owner.Color else Color:=clGray;
  inherited DrawObject(ACanvas);
  with ACanvas do begin
    Pen.Width:=Zoom(ThinPen);
    DrawArrow(ACanvas,Arrow);
    DrawCurve(True,ACanvas);
    if (Discount<1) then begin
      Brush.Color:=clWhite;
      Font.Color:=clBlack;
      if (From.Owner<>nil)
      then TextOut(Zoom(XPos+PayGap),Zoom(YPos-2*PayGap),
                   'd= '+FloatToStrF(Discount,ffGeneral,floatdgts,floatdgts))
      else TextOut(Zoom(XPos+PayGap),Zoom(YPos-2*PayGap),
                   'p= '+FloatToStrF(Discount,ffGeneral,floatdgts,floatdgts));
    end;
  end;
end;

procedure TMove32.SetChoice(AChoice:TChoice32);
begin
  OwnChoice:=AChoice;
end;

procedure TMove32.MakeChoice;
  procedure FindExistingChoice(AChoice:TChoice32);
  begin
    if (AChoice.Source=From.Family) {Same source}
    and (AChoice.Name=Name)         {SameName}
    then OwnChoice:=AChoice;
  end;
begin
  if OwnChoice<>nil
  then if ObjectTypeIsOk(OwnChoice,TStrat32) then Exit;
  {if OwnChoice.ObjType=ot_Strat then Exit; }
  TGameType32(Game).ChoiceList.ForEach(@FindExistingChoice);
  if (OwnChoice=nil) then begin
    OwnChoice:=TChoice32.Create(Game); {Source=From.Family}
    OwnChoice.SetSource(From.Family);
    OwnChoice.SetName(Self.Name);
    OwnChoice.SetArtificial(IsArtificial);  {To not display?}
    From.Family.AddChoice(OwnChoice);
    TGameType32(Game).ChoiceList.Add(OwnChoice);
  end;
  if (OwnChoice.Instances.IndexOf(Self)<0)
  then OwnChoice.AddInstance(Self);
  if From.Owner=nil then OwnChoice.SetProba(1.0)
  {else OwnChoice.SetDeriv(-1.0)}; {For testing}
end;

function TMove32.ShowPayment(APlayer:TPlayer32):TPayoff32; {Really TPayoff32}
  procedure FindPlayer(APay:TPayoff32);
  begin
    if APay.Whom=APlayer
    then ShowPayment:=APay;
  end;
begin
  ShowPayment:=nil;
  Payments.ForEach(@FindPlayer);
end;

function TMove32.MissEndPay:Boolean;
  procedure FindPay(APlayer:TPlayer32);
  begin
    if ShowPayment(APlayer)=nil then MissEndPay:=True;
  end;
begin
  MissEndPay:=False;
  TGameType32(Game).PlayerList.ForEach(@FindPay);
end;

procedure TMove32.SetIncentive(AnIncentive:Real);
begin
  Incentive:=AnIncentive;
end;

destructor TChoice32.Destroy;
begin
  Source:=nil;
  Associate:=nil;
  Instances.Clear; {Clears all moves from the list}
  Instances.Free;
  inherited Destroy;
end;

procedure TChoice32.Remake;
begin
  inherited Remake;
  Instances:=TGameList.Create;
  Associate:=Self;
  ObjType:=ot_Choice;
  IsDominated:=False;
  IsOptimum:=False;
  Proba:=1;
  Direction:=0;
end;

procedure TChoice32.SetOptimum(IsIt:Boolean);
begin
  IsOptimum:=IsIt;
end;

procedure TChoice32.SetSource(ASource:TInfo32);
begin
  Source:=ASource;
end;

function TChoice32.ResetRank: Integer;
begin
  Rank:=TGameType32(Game).ChoiceList.TrueIndex(Self);
  ResetRank:=Rank;
end;

procedure TChoice32.AddInstance(AnInstance:TGameObject32);
begin
  Instances.Add(AnInstance);
end;

function TChoice32.NameMatchAt(ANode:TNode32):Boolean;
var MatchFound: Boolean;
  procedure MatchNameAndFrom(AMove:TMove32);
  begin
    if (AMove.From=ANode)
    and (AMove.Name=Self.Name)
    then MatchFound:=True;
  end;
begin
  MatchFound:=False;
  TGameType32(Game).MoveList.ForEach(@MatchNameAndFrom);
  NameMatchAt:=MatchFound;
end;

function TChoice32.CheckInstances: Boolean;
var AllMatch: Boolean;
  procedure FindMatchingMoveAt(ANode:TNode32);
  begin
    if not NameMatchAt(ANode)
    then AllMatch:=False;
  end;
begin
  AllMatch:=True;
  Source.Events.ForEach(@FindMatchingMoveAt);
  CheckInstances:=AllMatch;
end;

procedure TChoice32.SetProba(AProba:Real);
begin
  Proba:=TrueProba(AProba);
end;

function TChoice32.IsBest:Boolean;
begin
  if Source.BestReply=Self
  then IsBest:=True
  else IsBest:=False;
end;

procedure TChoice32.SetIncentive(AnIncentive:Real);
begin
  Incentive:=AnIncentive;
end;

procedure TChoice32.SetDirection(ADirection:Real);
begin
  Direction:=ADirection;
end;

procedure TChoice32.Estimate;
var CrntMax,CrntMin:Real; IsEstimable:Boolean;
    procedure CheckInstance(AMove:TMove32);
    begin
      if AMove.MaxEstimate>CrntMax then CrntMax:=AMove.MaxEstimate;
      if AMove.MinEstimate<CrntMin then CrntMin:=AMove.MinEstimate;
    end;
    procedure CheckEstimable(AMove:TMove32);
    begin
      if AMove.IsDominated then Exit;
      if AMove.IsEstimated then Exit;
      IsEstimable:=False;
    end;
begin
    if Source.Owner=nil then Exit; {Chance choice}
    if IsDominated then Exit;
    IsEstimable:=True; {Check if estimable}
    Instances.ForEach(@CheckEstimable);
    if IsEstimable then begin
      CrntMax:=-MaxAbsValue;
      CrntMin:=MaxAbsValue;
      Instances.ForEach(@CheckInstance);
      SetEstimate(True,CrntMax);
      SetEstimate(False,CrntMin);
      SetEstimated(True);  
    end else SetEstimated(False);
end;

procedure TChoice32.MakeMinMax;
  procedure UpdateMiniMax(AProfile:TProfile);
  var DoesFit:Boolean; CrntIncent:Real;
    procedure CheckProfileFit(BChoice:TChoice32);
    begin {Given current choice and info activity check if profile fits}
      if IsDominated then DoesFit:=False; {Profile with dominated choice is unfit}
      if not DoesFit then Exit; {Exit if profile is already unfit}
      if (BChoice.Source.Owner=nil) then Exit; {Chance choices always fit}
      if BChoice.Source=Self.Source then Exit; {Self has already been screened}
      if BChoice.Source.IsActive  {Inactive source always fit}
      then if AProfile.ChoiceActivity.Entry(BChoice.Rank) {BChoice active in profile}
           then if not BChoice.IsActive {but BChoice not active in search}
                then DoesFit:=False; {This profile does not fit choice activity}
    end;
  begin
    if AProfile.ChoiceActivity.Entry(Rank) {Self must be active in fit profile}
    then DoesFit:=True else DoesFit:=False;
    if DoesFit then with Game as TGameType32 do ChoiceList.ForEach(@CheckProfileFit);
    if DoesFit then begin
      CrntIncent:=AProfile.InfoIncentives.Entry(Source.Rank);
      if CrntIncent>MaxIncent then MaxIncent:=CrntIncent;
      if CrntIncent<MinIncent then MinIncent:=CrntIncent;
    end;
  end;
begin
  if Source.Owner<>nil then begin
     MaxIncent:=-MaxAbsValue;
     MinIncent:=MaxAbsValue;
    with Game as TGameType32 do ProfileList.ForEach(@UpdateMiniMax);
  end;
end;

procedure TChoice32.SetInfoMin(IsIt:Boolean);
begin
  IsInfoMin:=IsIt;
end;

function TChoice32.CheckDominated:Boolean;
var Dominated:Boolean;
  procedure CompareMinMax(BChoice:TChoice32);
  begin
    if BChoice.IsDominated then Exit;
    if (BChoice<>Self)
    and (BChoice.MinIncent<MaxIncent+FadeValue)
    then Dominated:=False;  {BChoice can't dominate Self}
  end;
  procedure CheckExistOther(BChoice:TChoice32);
  begin
    if BChoice.IsDominated then Exit;
    if (BChoice<>Self) then Dominated:=True; {Initialized as true}
  end;
begin
  CheckDominated:=False;
  if (Source.Owner=nil) or IsArtificial then Exit
  else begin
    Dominated:=IsDominated;
    if not Dominated then begin
      Source.Choices.ForEach(@CheckExistOther); {To see if can be dominated}
      Source.Choices.ForEach(@CompareMinMax); {To see if exists domination}
    end;
    CheckDominated:=Dominated;
  end;
end;

procedure TChoice32.SetDominated(IsIt:Boolean);
begin
  IsDominated:=IsIt;
end;

procedure TChoice32.DrawObject(ACanvas:TCanvas);
begin  
  {if ObjType=ot_Choice then Exit; }
  if ObjectTypeIsOk(Self,TChoice32) then Exit;
end;

procedure TStrat32.Remake;
begin
  inherited Remake;
  ObjType:=ot_Strat;
end;

function TStrat32.ResetRank: Integer;
begin
  Rank:=TGameType32(Game).ChoiceList.TrueIndex(Self);
  ResetRank:=Rank;
end;

function TStrat32.Description(ForWhat:Integer) : String;
  procedure AddInstanceName(AnInstance:TMove32);
  begin
    TextLine:=TextLine+'&'+AnInstance.Name;
  end;
begin
  inherited Description(ForWhat);
  if ForWhat=fw_Saving then begin
    if (Source=nil)
    then Textline:=Textline+IntToStr(0)
    else Textline:=Textline+IntToStr(Source.ResetRank);
    StrLenAdjust(sl_Name+5*sl_Short,Textline);
  end else begin
    if Source<>nil then TextLine:=TextLine+'@'+Source.Name;
    Instances.ForEach(@AddInstanceName);
  end;
  Description:=TextLine;
end;

procedure TStrat32.RedoGraphics;
begin
  if Source=nil then Exit;
  if not ObjectTypeIsOk(Source,TSide32) then Exit;  
  if Source.Owner=nil
  then Color:=clGray
  else Color:=Source.Owner.Color;
  XPos:=Source.XPos;
  YPos:=Source.YPos;
  if TSide32(Source).TabOrder=1
  then begin XPos:=XPos+CellWidth*Source.Choices.IndexOf(Self);
             YPos:=YPos+SideHeight;
  end else YPos:=YPos+2*SideHeight+TGameType32(Game).PlayerList.Count*SideHeight*Source.Choices.IndexOf(Self);
  Arrow:=MakeAnArrow(XPos+4,YPos+6,2,0);
end;

procedure TStrat32.DrawObject(ACanvas:TCanvas);
begin  {For strategies in table only}
  if Source=nil then Exit;
  if not ObjectTypeIsOk(Source,TSide32) then Exit;  
  with ACanvas do begin
    Pen.Color:=Color;
    Brush.Color:=Color;
    DrawArrow(ACanvas,Arrow);
    if IsInFront
    then Font.Color:=Color
    else Font.Color:=clGray;
    Brush.Color:=clWhite;
    TextOut(Zoom(XPos+12),Zoom(YPos),Name);
  end;
end;

procedure TStrat32.SetLine(AStr:String);
begin
  inherited SetLine(AStr);
  SubStr:=ShowStringPart(AStr,sl_Name+4*sl_Short+1,sl_Short);
  SideRank:=ValidInt(SubStr);
end;

function TStrat32.Restore:Boolean;
  procedure RecoverSide(ASide:TSide32);
  begin
    if ASide.Rank=SideRank then SetSource(ASide);
  end;
begin
  Restore:=True;
  TGameType32(Game).InfoList.ForEach(@RecoverSide);
  if Source=nil then SetUnclean
  else Source.Choices.Add(Self);
end;

{TGameValue implementation}

destructor TGameValue.Destroy;
begin
  Where:=nil;
  Whom:=nil;
  inherited Destroy;
end;

function TGameValue.Description(ForWhat:Integer) : String;
begin
  inherited Description(ForWhat);
  if ForWhat=fw_Saving then begin
    if Where<>nil
    then Textline:=Textline+IntToStr(Where.ResetRank);
    StrLenAdjust(sl_Name+5*sl_Short,Textline);
    if Whom<>nil
    then Textline:=Textline+IntToStr(Whom.ResetRank);
    StrLenAdjust(sl_Name+6*sl_Short,Textline);
    Textline:=Textline+FloatToStrF(Value,ffGeneral,floatdgts,floatdgts);
    StrLenAdjust(2*sl_Name+6*sl_Short,Textline); {sl_Name allows longer real if needed}
  end else begin
    Textline:=Textline+FloatToStrF(Value,ffGeneral,floatdgts,floatdgts)+' ';
    if Where<>nil then Textline:=Textline+'@'+Where.Description(fw_Audit);
    if Whom<>nil then Textline:=Textline+' for '+Whom.Name;
  end;
  Description:=TextLine;
end;

procedure TGameValue.SetLine(AStr:String);
begin
  inherited SetLine(AStr);
  SubStr:=ShowStringPart(AStr,sl_Name+4*sl_Short+1,sl_Short);
  WhereRank:=ValidInt(SubStr);
  SubStr:=ShowStringPart(AStr,sl_Name+5*sl_Short+1,sl_Short);
  WhomRank:=ValidInt(SubStr);
  SubStr:=ShowStringPart(AStr,sl_Name+6*sl_Short+1,sl_Name);
  Value:=ValidReal(SubStr);
end;

function TGameValue.Restore:Boolean;
begin
  Restore:=True;
  with TGameType32(Game) do begin
    if (WhomRank>0) and (WhomRank<=PlayerList.Count)
    then Whom:=PlayerList.Items[WhomRank-1];
    if (WhereRank>0) and (WhereRank<=MoveList.Count)
    then Where:=MoveList.Items[WhereRank-1];
  end;
end;

{TPayoff32 implementation}

procedure TPayoff32.AssignTo(Dest:TPersistent);
begin
  inherited AssignTo(Dest);
  TPayoff32(Dest).Whom:=Self.Whom;
  TGameValue(Dest).Where:=Self.Where;
  TGameValue(Dest).Value:=Self.Value;
end;

procedure TPayoff32.Remake;
begin
  inherited Remake;
  ObjType:=ot_Payoff;
  Where:=nil;
  Whom:=nil;
  Value:=0;
  IsInFront:=True;
end;

procedure TPayoff32.SetWhom(APlayer:TPlayer32);
begin
  Whom:=APlayer;
end;

procedure TPayoff32.SetWhere(AWhere:TGameObject32);
begin
  Where:=AWhere;
end;

procedure TPayoff32.SetValue(AValue:Real);
begin
  Value:=AValue;
end;

procedure TPayoff32.DrawObject(ACanvas:TCanvas);
begin
  if IsArtificial and not IsDebug then Exit;

  if (Where=nil) then Exit;

  if not Where.IsInFront then Exit;
  if (Whom<>nil)
  then Color:=Whom.Color else Color:=clBlack;
  inherited DrawObject(ACanvas);
  with ACanvas do begin
    Pen.Width:=ThinPen;
    Brush.Color:=clWhite;
    if Where<>nil then begin
      case Where.ObjType of
        ot_Move : begin XPos:=Where.XPos-PayGap;YPos:=Where.YPos;end;
        ot_Cell : begin XPos:=TCell32(Where).XFro+PayGap;YPos:=TCell32(Where).YFro;end;
      end;
      YPos:=YPos+PayGap*(1+2*TGameType32(Game).PlayerList.IndexOf(Whom));
      Font.Size:=Zoom(8);
      TextOut(Zoom(XPos),Zoom(YPos),
              'U= '+FloatToStrF(Value,ffGeneral,floatdgts,floatdgts));
    end;
  end;
end;

function TPayoff32.IsOwnPay:Boolean;
begin  {Simplifies loading payoffs in makeincentives}
  IsOwnPay:=False;
  if Whom=TMove32(Where).From.Owner
  then IsOwnPay:=True;
end;

end.
