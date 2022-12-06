unit EditTable;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Type32, Game32Type, Game32Solve, ExtCtrls, Constants;

type
  TTableDlg = class(TForm)
    EditName: TEdit;
    StaticText1: TStaticText;
    SidesListBox: TListBox;
    StaticText2: TStaticText;
    Bevel1: TBevel;
    AddButton: TButton;
    EditButton: TButton;
    DelButton: TButton;
    Bevel2: TBevel;
    OkButton: TButton;
    CancelButton: TButton;
    PaysBtn: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure EditNameChange(Sender: TObject);
    procedure AddButtonClick(Sender: TObject);
    procedure SidesListBoxClick(Sender: TObject);
    procedure EditButtonClick(Sender: TObject);
    procedure DelButtonClick(Sender: TObject);
    procedure PaysBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    SelIndex:Integer;
    DlgTable: TTable32;
    DlgCell : TCell32;
    procedure FillSidesBox;
    procedure InitDialog(ATable:TTable32;AGame:TGameType32);
  end;

  function TableDelete(ATable:TTable32;AGame:TGameType32):Boolean;
  procedure TableEdit(ATable:TTable32;AGame:TGameType32);

var
  TableDlg: TTableDlg;

implementation

uses EditSide, SelectDlg, EditPayoff;

{$R *.DFM}

function TableDelete(ATable:TTable32;AGame:TGameType32):Boolean;
begin
  if ATable.CanDelete
  then begin
    AGame.{TableList}NodeList.Remove(ATable);
    ATable.Free;
    TableDelete:=True;
  end else TableDelete:=False;
end;

procedure TableEdit(ATable:TTable32;AGame:TGameType32);
begin
  TableDlg.InitDialog(ATable,AGame);
  if TableDlg.ShowModal = mrOK
  then ATable.Assign(TableDlg.DlgTable);
  if TableDlg.DlgCell<>nil then TableDlg.DlgCell.DeletePayments;
  TableDlg.DlgTable.Cells.FreeAll(ot_All);
end;

procedure TTableDlg.FillSidesBox;
  procedure FillBox(ASide:TSide32);
  begin
    if ASide<>nil then if ASide.Owner<>nil
                       then SidesListBox.Items.Append(ASide.Owner.Name);
  end;
begin
  SidesListBox.Clear;
  DlgTable.Sides.ForEach(@FillBox);
end;

procedure TTableDlg.InitDialog(ATable:TTable32;AGame:TGameType32);
begin
  if ATable<>nil
  then begin
    ATable.SelfAssociateChoices;
    DlgTable.Assign(ATable);
  end else begin
    DlgTable.SetGame(AGame);
    DlgTable.Remake;
  end;
  EditName.Text:=DlgTable.Name;
  SelIndex:=-1;
  DlgCell:=nil;
  FillSidesBox;
end;

procedure TTableDlg.FormCreate(Sender: TObject);
begin
  DlgTable:=TTable32.Create(nil);
  DlgCell:=nil;
end;

procedure TTableDlg.FormDestroy(Sender: TObject);
begin
  DlgTable.Sides.Clear; {To avoid repeat free of sides}
  DlgTable.Free;
  DlgCell:=nil;
end;

procedure TTableDlg.EditNameChange(Sender: TObject);
begin
  DlgTable.SetName(EditName.Text);
end;

procedure TTableDlg.AddButtonClick(Sender: TObject);
var ASide:TSide32;
begin
  if SideDlg.FillOwnerList(DlgTable)
  then begin
    SideDlg.InitDialog(nil,DlgTable,TGameType32(DlgTable.Game));
    if SideDlg.ShowModal=mrOK
    then if (SideDlg.DlgSide.Choices.Count>0) and (SideDlg.DlgSide.Owner<>nil)
    then begin
      ASide:=TSide32.Create(DlgTable.Game);
      ASide.SetTable(DlgTable);
      ASide.Assign(SideDlg.DlgSide);
      DlgTable.Sides.Add(ASide);
      FillSidesBox;
    end else MessageDlg('No Owner or Choices defined', mtWarning, [mbOk], 0);
  end;
end;

procedure TTableDlg.SidesListBoxClick(Sender: TObject);
begin
  SelIndex:=SidesListBox.ItemIndex;
end;

procedure TTableDlg.EditButtonClick(Sender: TObject);
var ASide:TSide32;
begin
  if SelIndex>=0
  then begin
    ASide:=TSide32(DlgTable.Sides.Items[SelIndex]);
    DlgTable.SelfAssociateChoices; {Before SideDlg associates new ones for ASide}
    SideDlg.InitDialog(ASide,DlgTable,TGameType32(DlgTable.Game));
    if SideDlg.ShowModal=mrOK
    then if SideDlg.DlgSide.Choices.Count>0
         then begin
           {Update associations before}
           DlgTable.UpdateCells; {from current strategies to SideDlg ones in ASide}
           ASide.Assign(SideDlg.DlgSide); {New ASide choices become associates}
           DlgTable.UpdateCells;  {Updates associations from SideDlg. BUG BUG BUG}
         end else begin
           DlgTable.Sides.Remove(ASide);
           ASide.Free;
           MessageDlg('No Choices defined', mtWarning, [mbOk], 0);
           FillSidesBox;
         end;
  end;
end;

procedure TTableDlg.DelButtonClick(Sender: TObject);
var ASide:TSide32;
begin
  if SelIndex>=0
  then begin
    ASide:=TSide32(DlgTable.Sides.Items[SelIndex]);

    {Need to cleanup strategies and cells}
    DlgTable.Cells.FreeAll(ot_All);
    DlgTable.Sides.Remove(ASide);
    ASide.Free;
    FillSidesBox;
  end;
end;

procedure TTableDlg.PaysBtnClick(Sender: TObject);
begin
  {DlgTable.SidesToCells;
  with SelectDialog do begin
    SelectDialog.InitDialog(DlgTable.Cells);
    if (SelIndex>=0)
    then begin
      DlgCell:=TCell32(DlgTable.Cells.Items[SelIndex]);
      PayoffDlg.InitDialog(DlgCell);
      if PayoffDlg.ShowModal = mrOK
      then DlgCell.Assign(PayoffDlg.DlgCell);
    end;
  end;
  PayoffDlg.DlgCell.DeletePayments; }
end;

end.
