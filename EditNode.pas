unit EditNode;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Type32, EditMove, Game32Type, Game32Solve, Constants, Buttons;

type
  TNodeDlg = class(TForm)
    CancelBtn: TButton;
    Bevel1: TBevel;
    Static1: TStaticText;
    EditName: TEdit;
    OkButton: TButton;
    Label1: TLabel;
    OwnerListBox: TListBox;
    ChanceRadioButton: TRadioButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure EditNameChange(Sender: TObject);
    procedure FillOwnerBox;
    procedure OwnerListBoxClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure ChanceRadioButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    SelIndex:Integer;
    DlgNode: TNode32;
    OwnerList: TGameList;
    procedure InitDialog(ANode:TNode32;AGame:TGameType32);
  end;

  function NodeDelete(ANode:TNode32;AGame:TGameType32):Boolean;
  procedure NodeEdit(ANode:TNode32;AGame:TGameType32);

var
  NodeDlg: TNodeDlg;

implementation

{$R *.DFM}

function NodeDelete(ANode:TNode32;AGame:TGameType32):Boolean;

  {procedure DisconnectUpto(AMove:TMove32);
  begin
    if (AMove.Upto=ANode)
    then begin
      AMove.SetUpto(nil);
      AMove.SetPosition(ANode.XPos,ANode.YPos);
    end;

  end;
  {procedure DeleteFrom(AMove:TMove32);
  begin
    with AMove do
    if (From=ANode) and (Upto=nil)
    then MoveDelete(AMove,AGame);
  end;}
begin
  if ANode.CanDelete
  then begin
    {AGame.MoveList.ForEach(@DisconnectUpto);
    AGame.MoveList.ForEach(@DeleteFrom);
    if ANode.Family<>nil
    then ANode.Family.Events.Remove(ANode); }
    AGame.DeleteSingletons(False);

    ANode.Disconnect; 
    AGame.NodeList.Remove(ANode);
    AGame.SetState(gs_Edited);
    ANode.Free;
    NodeDelete:=True;
  end else NodeDelete:=False;
end;

procedure NodeEdit(ANode:TNode32;AGame:TGameType32);
begin
  NodeDlg.InitDialog(ANode,AGame);
  if NodeDlg.ShowModal = mrOK
  then begin
    ANode.Assign(NodeDlg.DlgNode);
    AGame.SetState(gs_Edited);
  end;
end;

procedure TNodeDlg.FormCreate(Sender: TObject);
begin
  DlgNode:=TNode32.Create(nil);
end;

procedure TNodeDlg.FormDestroy(Sender: TObject);
begin
  DlgNode.Free;
  OwnerList:=nil;
end;

procedure TNodeDlg.FormActivate(Sender: TObject);
begin
  FocusControl(EditName);
end;

procedure TNodeDlg.FillOwnerBox;
  procedure FillBox(AnObject:TGameObject32);
  begin
    OwnerListBox.Items.Append(AnObject.Name);
  end;
begin
  OwnerListBox.Clear;
  OwnerList.ForEach(@FillBox);
  OwnerListBox.ItemIndex:=1; {To make sure something is highlighted}
end;

procedure TNodeDlg.InitDialog(ANode:TNode32;AGame:TGameType32);
begin
  if ANode<>nil
  then DlgNode.Assign(ANode)
  else begin
    DlgNode.SetGame(AGame);
    DlgNode.Remake;
  end;
  EditName.Text:=DlgNode.Name;
  if AGame.PlayerList<>nil
  then begin
    OwnerList:=AGame.PlayerList;
    FillOwnerBox;
  end;
  if DlgNode.Owner=nil
  then begin
    ChanceRadioButton.Checked:=True;
    OwnerListBox.ItemIndex:=-1;
  end else begin
    ChanceRadioButton.Checked:=False;
    OwnerListBox.ItemIndex:=OwnerList.IndexOf(DlgNode.Owner);
  end;
  SelIndex:=-1;
end;

procedure TNodeDlg.EditNameChange(Sender: TObject);
begin
  DlgNode.SetName(EditName.Text);
end;

procedure TNodeDlg.OwnerListBoxClick(Sender: TObject);
begin
  if (DlgNode.Family<>nil)
  then begin
    MessageDlg('Cannot change owner. Node belongs to an Information set', mtWarning, [mbOk], 0);
    OwnerListBox.ItemIndex:=OwnerList.IndexOf(DlgNode.Owner);
  end else begin
    SelIndex:=OwnerListBox.ItemIndex;
    if SelIndex>=0
    then begin
      DlgNode.SetOwner(TPlayer32(OwnerList.Items[SelIndex]));
      ChanceRadioButton.Checked:=False;
    end;
  end;
end;

procedure TNodeDlg.ChanceRadioButtonClick(Sender: TObject);
begin
  if (DlgNode.Family<>nil)
  then begin
    MessageDlg('Cannot change owner. Node belongs to an Information set', mtWarning, [mbOk], 0);
    ChanceRadioButton.Checked:=False;
  end else begin
    ChanceRadioButton.Checked:=True;
    DlgNode.Owner:=nil;
    OwnerListBox.ItemIndex:=-1;
  end;
end;

procedure TNodeDlg.OkButtonClick(Sender: TObject);
begin
  with DlgNode do
  if (Length(Name)<=0)
  then MessageDlg('Invalid name', mtWarning, [mbOk], 0)
  else ModalResult:=mrOk;
end;


end.
