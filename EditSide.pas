unit EditSide;
              
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Type32, Game32Solve, Game32Type,
  StdCtrls, ExtCtrls, Constants;

type
  TSideDlg = class(TForm)
    OkBtn: TButton;
    CancelBtn: TButton;
    Bevel2: TBevel;
    StrategyText: TStaticText;
    StrategyListBox: TListBox;
    AddStratBtn: TButton;
    DeleteStratBtn: TButton;
    Bevel1: TBevel;
    StaticText1: TStaticText;
    OwnerListBox: TListBox;
    EditChoice: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OwnerListBoxClick(Sender: TObject);
    procedure StrategyListBoxClick(Sender: TObject);
    procedure AddStratBtnClick(Sender: TObject);
    procedure DeleteStratBtnClick(Sender: TObject);
    procedure EditChoiceClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    SelIndex:Integer;
    DlgSide: TSide32;
    OwnerList  : TGameList;
    procedure FillOwnerBox;
    procedure FillStrategyBox;
    function FillOwnerList(ATable:TTable32):Boolean;
    procedure InitDialog(ASide:TSide32;ATable:TTable32;AGame:TGameType32);
  end;

  {procedure TableDelete(ATable:TTable32;AGame:TGameType32);
  {procedure SideDelete(ATable:TTable32;ASide:TSide32;AGame:TGameType32);}
  procedure SideEdit(ASide:TSide32;ATable:TTable32;AGame:TGameType32);

var
  SideDlg: TSideDlg;

implementation

uses Name;

{$R *.DFM}

procedure SideEdit(ASide:TSide32;ATable:TTable32;AGame:TGameType32);
begin
  try begin
    SideDlg.InitDialog(ASide,ATable,AGame);
    if SideDlg.ShowModal = mrOK
    then if (SideDlg.DlgSide.Choices.Count>0) {mi ht want to add default if =0}
       and (SideDlg.DlgSide.Owner<>nil)
       then begin
         if ASide=nil then begin
           ASide:=TSide32.Create(AGame);
           ATable.Sides.Add(ASide);
           AGame. DispatchObject(ASide);
         end;
         with ASide do begin
           RemoveAllChoices; {Remove existing strategies from game}
           ATable.UpdateCells; {Store dlgchoices into existing cells}
           Assign(SideDlg.DlgSide); {Destroys old choices}
           ATable.UpdateCells; {Store new choices into existing cells}
           AddAllChoices; {Add edited strategies to game}
           ATable.RemoveCells; {Remove cells from game.celllist}
           ATable.SidesToCells; {Match, delete and create cells}
           ATable.RestoreCells; {Restore cells to game.celllist}
         end;
         TGameType32(AGame).SetState(gs_Edited);
       end else MessageDlg('No Owner or Choices defined', mtWarning, [mbOk], 0);
  end;
  except on Exception do MessageDlg('Invalid table operation',mtWarning,[mbOk],0); end;
end;

function TSideDlg.FillOwnerList(ATable:TTable32):Boolean;
var IsCandidate:Boolean;
  procedure FindCandidate(APlayer:TPlayer32);
    procedure CheckIfFree(ASide:TSide32);
    begin
      if ASide.Owner=APlayer then IsCandidate:=False;
    end;
  begin
    IsCandidate:=True;
    ATable.Sides.ForEach(@CheckIfFree);
    if IsCandidate then OwnerList.Add(APlayer);
  end;
begin
  OwnerList.Clear;
  TGameType32(ATable.Game).PlayerList.ForEach(@FindCandidate);
  if OwnerList.Count>0 then FillOwnerList:=True else FillOwnerList:=False;
end;

procedure TSideDlg.FillOwnerBox;
  procedure FillBox(AnObject:TGameObject32);
  begin
    OwnerListBox.Items.Append(AnObject.Name);
  end;
begin
  OwnerListBox.Clear;
  OwnerList.ForEach(@FillBox);
  OwnerListBox.ItemIndex:=0;
end;

procedure TSideDlg.FillStrategyBox;
  procedure FillBox(AnObject:TGameObject32);
  begin
    StrategyListBox.Items.Append(AnObject.Name);
  end;
begin
  StrategyListBox.Clear;
  DlgSide.Choices.ForEach(@FillBox);
  StrategyListBox.ItemIndex:=0;
end;

procedure TSideDlg.InitDialog(ASide:TSide32;ATable:TTable32;AGame:TGameType32);
begin
  if ASide<>nil
  then begin
    DlgSide.Assign(ASide); {Duplicates choices of ASide and associate them}
    OwnerList.Clear;
    OwnerList.Add(ASide.Owner);
  end else with DlgSide do begin
    Owner:=nil;
    Choices.FreeAll(ot_All);
    SetGame(AGame);
    SetTable(ATable);
  end;
  FillStrategyBox;
  FillOwnerBox;
  SelIndex:=-1;
end;

procedure TSideDlg.FormCreate(Sender: TObject);
begin
  DlgSide:=TSide32.Create(nil);
  OwnerList:=TGameList.Create;
end;

procedure TSideDlg.FormDestroy(Sender: TObject);
begin
  DlgSide.Choices.FreeAll(ot_All); {OwnTable may have been destroyed}
  DlgSide.Free; 
  OwnerList.Clear;
  OwnerList.Free;
end;

procedure TSideDlg.OwnerListBoxClick(Sender: TObject);
begin
  SelIndex:=OwnerListBox.ItemIndex;
  if SelIndex>=0
  then DlgSide.SetOwner(TPlayer32(OwnerList.Items[SelIndex]));
  SelIndex:=-1;
end;

procedure TSideDlg.StrategyListBoxClick(Sender: TObject);
begin
  SelIndex:=StrategyListBox.ItemIndex;
end;

procedure TSideDlg.AddStratBtnClick(Sender: TObject);
var AStrategy: TStrat32;
begin
  AStrategy:=TStrat32.Create(DlgSide.Game);
  AStrategy.SetSource(DlgSide);
  with NameDlg do begin
    InitDialog('Strategy Name',AStrategy,nil);
    case ShowModal of
      mrOk     : DlgSide.Choices.Add(AStrategy);
      mrCancel : AStrategy.Free;
    end;
  end;
  FillStrategyBox;
end;

procedure TSideDlg.DeleteStratBtnClick(Sender: TObject);
var AStrategy: TStrat32;
begin
  if SelIndex<0 then Exit;
  AStrategy:=DlgSide.Choices.Items[SelIndex];
  AStrategy.Associate.SetAssociate(nil); {So AStrategy not called by associate}
  DlgSide.Choices.Remove(AStrategy);
  FillStrategyBox;
end;

procedure TSideDlg.EditChoiceClick(Sender: TObject);
var AStrategy: TStrat32;
begin
  if SelIndex<0 then Exit;
  AStrategy:=DlgSide.Choices.Items[SelIndex];
  with NameDlg do begin
    InitDialog('Strategy Name',AStrategy,nil);
    ShowModal;
  end;
  FillStrategyBox;
end;

end.
