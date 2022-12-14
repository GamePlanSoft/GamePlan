{Copyright (c), Jean-Pierre P. Langlois, 2007-2022}

unit Matrices;

interface

uses Windows, Classes, Type32, Constants, SysUtils;

type
  TEntry       = class(TGameObject32)
    public
    Value      : Real;
    procedure Remake; override;
    procedure SetValue(AValue:Real);
  end;

  TVector      = class(TGameObject32)
    public
    Dim        : Integer;
    Entries    : TGameList;
    constructor Create(ADim:Integer;AGame:TFakeGame);
    destructor Destroy; override;
    procedure SetEntry(IsToAdd:Boolean;Coord:Integer;AValue:Real);
    function Entry(Coord:Integer):Real;
    function Describe :String;
    procedure Show;
  end;

  TMatrix      = class(TGameObject32)
    public
    IsShowing,  {For debug}
    IsSingular : Boolean;
    InvDim,  {Can be different from RowDim with Jacobian}
    RowDim,
    ColDim,
    CrntRow,
    NextRow,
    NextCol    : Integer;
    Pivot,
    MaxEntry,
    NewValue   : Real;
    Rows       : TGameList;
    constructor Create(ToInvert:Boolean;ARowDim,AColDim:Integer;AGame:TFakeGame);
    destructor Destroy; override;
    procedure HandleOverflow;
    procedure SetInvDim(ADim:Integer);
    procedure FindBestRow;
    procedure EliminateCrntColumn;
    procedure SubtractRows;
    procedure SetEntry(IsToAdd:Boolean;Row,Col:Integer;AValue:Real);
    function Entry(Row,Col:Integer):Real;
    procedure InitIdentity(StartCol:Integer);
    procedure SetNil;
    procedure NormalizeCrntRow;
    procedure Invert;
    {procedure Explain(AString:String); }
    {procedure SetToShow(DoShow:Boolean);}
    procedure Show;
  end;

  TBoolEntry = class(TGameObject32)
    public
      BoolVal  : Boolean;
      procedure SetBoolVal(ABoolVal:Boolean);
  end;

  TBoolVect = class(TGameObject32)
    public
    Dim        : Integer;
    Entries    : TGameList;
    constructor Create(ADim:Integer;AGame:TFakeGame);
    destructor Destroy; override;
    procedure SetEntry(Coord:Integer;ABoolVal:Boolean);
    function Entry(Coord:Integer):Boolean;
  end;

  function DotProduct(ADim,AStart:Integer;RowVector,ColVector:TVector):Real;

  function SqrVectorNorm(ADim:Integer;AVector:TVector):Real;

  function VectorDifference(ADim:Integer;AFirst,ASecond:TVector):Real;

var
  ABug:TBug;

implementation

uses Game32Type, Game32Solve;

procedure TBoolEntry.SetBoolVal(ABoolVal:Boolean);
begin
  BoolVal:=ABoolVal;
end;

constructor TBoolVect.Create(ADim:Integer;AGame:TFakeGame);
var AnEntry:TBoolEntry; I:Integer;
begin
  Game:=AGame;
  Dim:=ADim;
  Entries:=TGameList.Create;
  for I:=0 to ADim do begin
    AnEntry:=TBoolEntry.Create(AGame);
    Entries.Add(AnEntry);
  end;
end;

destructor TBoolVect.Destroy;
begin
  Entries.FreeAll(ot_All);
  Entries.Free;
  inherited Destroy;
end;

procedure TBoolVect.SetEntry(Coord:Integer;ABoolVal:Boolean);
var AnEntry:TBoolEntry;
begin  {Load or add a value at entry (Row,Col)}
  try AnEntry:=Entries.Items[Coord];
  except on EListError do AnEntry:=nil; end;
  if (AnEntry<>nil)
  then AnEntry.SetBoolVal(ABoolVal)
end;

function TBoolVect.Entry(Coord:Integer):Boolean;
var AnEntry:TBoolEntry;
begin  {Show entry value}
  try AnEntry:=Entries.Items[Coord];
  except on EListError do AnEntry:=nil; end;
  if (AnEntry<>nil)
  then Entry:=AnEntry.BoolVal
  else Entry:=False;
end;

function DotProduct(ADim,AStart:Integer;RowVector,ColVector:TVector):Real;
var Dummy:Real; I:Integer;
begin
  Dummy:=0;
  if (RowVector.Dim>=ADim+AStart)
  and (ColVector.Dim>=ADim)
  then for I:=1 to ADim
  do try Dummy:=Dummy+RowVector.Entry(I+AStart)*ColVector.Entry(I);
  except on Exception do Dummy:=0; end;
  DotProduct:=Dummy;
end;

function SqrVectorNorm(ADim:Integer;AVector:TVector):Real;
begin
  SqrVectorNorm:=DotProduct(ADim,0,AVector,AVector);
end;

function VectorDifference(ADim:Integer;AFirst,ASecond:TVector):Real;
var I:Integer; AResult:Real;
begin
  AResult:=0;
  for I:=1 to ADim
  do AResult:=AResult+SQR(AFirst.Entry(I)-ASecond.Entry(I));
  VectorDifference:=AResult;
end;

procedure TEntry.Remake;
begin
  SetValue(0);
end;

procedure TEntry.SetValue(AValue:Real);
begin
  Value:=AValue;
end;

constructor TVector.Create(ADim:Integer;AGame:TFakeGame);
var AnEntry:TEntry; I:Integer;
begin
  Game:=AGame;
  Dim:=ADim;
  Entries:=TGameList.Create;
  for I:=0 to ADim do begin
    AnEntry:=TEntry.Create(AGame);
    Entries.Add(AnEntry);
  end;
end;

destructor TVector.Destroy;
begin
  Entries.FreeAll(ot_All);
  Entries.Free;
  inherited Destroy;
end;

function TVector.Entry(Coord:Integer):Real;
var AnEntry:TEntry;
begin  {Show entry value}
  try AnEntry:=Entries.Items[Coord];
  except on EListError do AnEntry:=nil; end;
  if (AnEntry<>nil)
  then Entry:=AnEntry.Value
  else Entry:=0;
end;

procedure TVector.SetEntry(IsToAdd:Boolean;Coord:Integer;AValue:Real);
var AnEntry:TEntry;
begin  {Load or add a value at entry (Row,Col)}
  try AnEntry:=Entries.Items[Coord];
  except on EListError do AnEntry:=nil; end;
  if (AnEntry<>nil)
  then with AnEntry do if IsToAdd then SetValue(Value+AValue)
                                  else SetValue(AValue);
end;

function TVector.Describe :String;
var AString: String;
  procedure ShowEntry(AnEntry:TEntry);
  begin
    AString:=AString+FloatToStrF(AnEntry.Value,ffFixed{ffGeneral},16,16)+'  ';
  end;
begin
  AString:='';
  Entries.ForEach(@ShowEntry);
  Describe:=AString;
end;

procedure TVector.Show;
begin
  ABug:=TBug.Create(Game);
  ABug.SetName(Describe);
  TGameType32(Game).TestList.Add(ABug);
end;

constructor TMatrix.Create(ToInvert:Boolean;ARowDim,AColDim:Integer;AGame:TFakeGame);
var AVector: TVector; I:Integer;
begin
  IsShowing:=False;
  Game:=AGame;
  InvDim:=ARowDim; {Can be modified for Jacobian}
  RowDim:=ARowDim;
  ColDim:=AColDim;
  Rows:=TGameList.Create;
  AVector:=TVector.Create(0,Game);
  Rows.Add(AVector);  {Dummy vector to simplify writing row operations}
  for I:=1 to RowDim do begin {Create actual Rows}
    if ToInvert then AVector:=TVector.Create(2*ColDim,Game)
                else AVector:=TVector.Create(ColDim,Game);
    Rows.Add(AVector);
  end;
end;

destructor TMatrix.Destroy;
begin
  Rows.FreeAll(ot_All);
  Rows.Free;
  inherited Destroy;
end;

{Matrix operations}

procedure TMatrix.HandleOverflow;
begin
  IsSingular:=True; Pivot:=0; NewValue:=0;
end;

procedure TMatrix.SetInvDim(ADim:Integer);
begin
  if ADim<=RowDim then InvDim:=ADim;
end;

procedure TMatrix.SetEntry(IsToAdd:Boolean;Row,Col:Integer;AValue:Real);
var AVector:TVector;
begin  {Load or add a value at entry (Row,Col)}
  try AVector:=Rows.Items[Row];
  except on EListError do AVector:=nil; end;
  if (AVector<>nil)
  then with AVector
       do SetEntry(IsToAdd,Col,AValue)
end;

function TMatrix.Entry(Row,Col:Integer):Real;
var AVector:TVector;
begin  {Show entry value}
  try AVector:=Rows.Items[Row];
  except on EListError do AVector:=nil; end;
  if (AVector<>nil)
  then Entry:=AVector.Entry(Col)
  else Entry:=0;
end;

procedure TMatrix.SetNil;
var Row,Col:Integer;
begin
  for Row:=1 to RowDim
  do for Col:=1 to ColDim
     do SetEntry(False,Row,Col,0);
end;

procedure TMatrix.InitIdentity(StartCol:Integer);
  procedure ResetRow;
  var Col:Integer;
  begin
    for Col:=1 to RowDim
    do if (Col=NextRow)
       then SetEntry(False,NextRow,StartCol+Col,1)
       else SetEntry(False,NextRow,StartCol+Col,0);
  end;
begin
  NextRow:=0;
  repeat
    NextRow:=NextRow+1;
    ResetRow; {Reset first RowDim columns}
  until (NextRow=InvDim)
end;

procedure TMatrix.FindBestRow; {Moves row with max entry in CrntCol to CrntRow}
var CandEntry:Real; BestRow: Integer;
begin
  BestRow:=CrntRow;  {CrntRow serves as CrntColumn as well}
  MaxEntry:=0;
  NextRow:=CrntRow-1;
  repeat
    NextRow:=NextRow+1;
    CandEntry:=Entry(NextRow,CrntRow);
    if (Abs(MaxEntry)<Abs(CandEntry))  {Want max MaxEntry}
    then begin
      BestRow:=NextRow;
      MaxEntry:=CandEntry;
    end;
  until (NextRow=InvDim);
  if (Abs(MaxEntry)<MinAbsValue)     {Want MaxEntry large enough}
  then IsSingular:=True
  else if (BestRow<>CrntRow)
       then Rows.Exchange(BestRow,CrntRow);
end;

procedure TMatrix.SubtractRows; {Subtract BestRow times Pivot from NextRow}
var NextCol:Integer;
begin
  Pivot:=Entry(NextRow,CrntRow);
  NextCol:=CrntRow;
  repeat
    try NewValue:=Entry(NextRow,NextCol)-Pivot*Entry(CrntRow,NextCol);
    except on EOverflow do HandleOverflow; end;
    SetEntry(False,NextRow,NextCol,NewValue);
    NextCol:=NextCol+1;
  until IsSingular or (NextCol>ColDim+InvDim);
end;

procedure TMatrix.EliminateCrntColumn; {Eliminate non-zero entries in column}
begin
  NextRow:=0;
  repeat
    NextRow:=NextRow+1;
    if (NextRow<>CrntRow) then SubtractRows;
  until IsSingular or (NextRow=InvDim)
end;

procedure TMatrix.NormalizeCrntRow;
begin
  if MaxEntry=1 then Exit;
  NextCol:=CrntRow;
  repeat
    if (ABS(MaxEntry)>MinAbsValue)
    and (ABS(Entry(CrntRow,NextCol))<MaxAbsValue)
    then try NewValue:=Entry(CrntRow,NextCol)/MaxEntry;
         except on {EOverflow} Exception do HandleOverflow;
         end else HandleOverflow;
    SetEntry(False,CrntRow,NextCol,NewValue);
    NextCol:=NextCol+1;
  until (NextCol>ColDim+InvDim)
end;

procedure TMatrix.Invert; {Matrix inverse is found in last RowDim columns}
begin
  if InvDim=0 then IsSingular:=True
  else begin
    IsSingular:=False;
    InitIdentity(RowDim);
    if IsShowing then Show;
    CrntRow:=0; {Dummy row}
    repeat
      CrntRow:=CrntRow+1;
      FindBestRow; {From CrntRow. This exchanges CrntRow and BestRow if need be}
      if IsShowing then Show;
      NormalizeCrntRow; {After possible exchange}
      if IsShowing then Show;
      EliminateCrntColumn;
      if IsShowing then Show;
    until IsSingular or (CrntRow=InvDim);
  end;
end;

{procedure TMatrix.Explain(AString:String);
begin
    ABug:=TBug.Create(Game);
    ABug.SetName(ASTring);
    TGameType32(Game).TestList.Add(ABug);
end;}

{procedure TMatrix.SetToShow(DoShow:Boolean);
begin
  IsShowing:=DoShow;
end;  }

procedure TMatrix.Show;
  procedure ShowRow(ARow:TVector);
  begin
    ARow.Show;
  end;
begin
  Rows.ForEach(@ShowRow);
end;

end.
