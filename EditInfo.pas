{Copyright (c), Jean-Pierre P. Langlois, 2007-2022}

unit EditInfo;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Type32, Game32Type, Game32Solve, Constants, Buttons, Dialogs, ExtCtrls;

type
  TInfoDlg = class(TForm)
    OKBtn: TButton;
    Bevel1: TBevel;
    DeleteButton: TButton;
    AddButton: TButton;
    CandListBox: TListBox;
    EventListBox: TListBox;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FillBox(AList:TGameList;AListBox:TListBox);
    procedure MakeCandList;
    procedure MakeEvntList;
    procedure CandListBoxClick(Sender: TObject);
    procedure EventListBoxClick(Sender: TObject);
    procedure AddButtonClick(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    CandIndx : Integer;
    EvntIndx : Integer;
    DlgNode  : TNode32;
    CandNode : TNode32;
    CandList : TGameList;
    EvntList : TGameList;
    function InitDialog(ANode:TNode32):Boolean;
  end;

var
  InfoDlg: TInfoDlg;

implementation

{$R *.DFM}

procedure TInfoDlg.FormCreate(Sender: TObject);
begin
  DlgNode:=nil;
  CandList:=TGameList.Create;
  EvntList:=TGameList.Create;
end;

procedure TInfoDlg.FormDestroy(Sender: TObject);
begin
  DlgNode:=nil;
  CandList.Clear;
  CandList.Free;
  EvntList.Clear;
  EvntList.Free;
end;

procedure TInfoDlg.FillBox(AList:TGameList;AListBox:TListBox);
  procedure FillBox(AnObject:TGameObject32);
  begin
    AListBox.Items.Append(AnObject.Name);
  end;
begin
  AListBox.Clear;
  AList.ForEach(@FillBox);
end;

procedure TInfoDlg.MakeCandList;
  procedure CheckCandidate(BNode:TNode32);
  begin
    if (BNode=DlgNode) then Exit;   {DlgNode is not candidate}
    if (BNode.Owner=nil) then Exit; {Chance nodes are not candidate}
    if (BNode.Family<>nil) and (BNode.Family<>DlgNode.Family)
    then Exit; {Nodes of other non-trivial families are not candidate}
    if (DlgNode.Family<>nil) {Existing family events are not candidate}
    then if (TInfo32(DlgNode.Family).Events.IndexOf(BNode)>=0) then Exit;
    if (BNode.Owner=DlgNode.Owner)
    then CandList.Add(BNode);
  end;
begin
  CandList.Clear;
  TGameType32(DlgNode.Game).NodeList.ForEach(@CheckCandidate);
  FillBox(CandList,CandListBox);
  CandIndx:=-1;  {So that buttons have no effect}
end;

procedure TInfoDlg.MakeEvntList;
  procedure FillEvntList(ANode:TNode32);
  begin
    EvntList.Add(ANode);
  end;
begin
  EvntList.Clear;
  try if (DlgNode.Family<>nil)
  then with TInfo32(DlgNode.Family) do begin
    Restore; {Find family members. Put then in events}
    Events.ForEach(@FillEvntList);
  end else FillEvntList(DlgNode);
  except on Exception do MessageDlg('Error creating events list.', mtWarning, [mbOk], 0); end;
  FillBox(EvntList,EventListBox);
  EvntIndx:=-1;  {So that buttons have no effect}
end;

function TInfoDlg.InitDialog(ANode:TNode32):Boolean;
begin
  DlgNode:=ANode; {Can't just copy ANode.Family to DlgNode}
  MakeCandList;
  MakeEvntList;
  if (CandList.Count+EvntList.Count<=1)
  then InitDialog:=False
  else InitDialog:=True;
end;

procedure TInfoDlg.CandListBoxClick(Sender: TObject);
begin
  CandIndx:=CandListBox.ItemIndex;
end;

procedure TInfoDlg.EventListBoxClick(Sender: TObject);
begin
  EvntIndx:=EventListBox.ItemIndex;
end;

procedure TInfoDlg.AddButtonClick(Sender: TObject);
begin
  if (CandIndx>=0) and (CandIndx<CandList.Count)
  then begin
    CandNode:=CandList.Items[CandIndx];
    if (EvntList.IndexOf(CandNode)<0)
    then begin
      EvntList.Add(CandNode);
      FillBox(EvntList,EventListBox);
      CandList.Remove(CandNode);
      FillBox(CandList,CandListBox);
      TGameType32(DlgNode.Game).SetState(gs_Edited);
    end;
  end;
  CandIndx:=-1;
end;

procedure TInfoDlg.DeleteButtonClick(Sender: TObject);
begin
  if (EvntIndx>=0) and (EvntIndx<EvntList.Count)
  then begin
    CandNode:=EvntList.Items[EvntIndx];
    if (CandNode=DlgNode)
    then MessageDlg('Cannot delete access node', mtWarning, [mbOk], 0)
    else begin
      EvntList.Remove(CandNode);
      FillBox(EvntList,EventListBox);
      CandList.Add(CandNode);
      FillBox(CandList,CandListBox);
      TGameType32(DlgNode.Game).SetState(gs_Edited);
    end;
  end;
  EvntIndx:=-1;
end;

procedure TInfoDlg.OKBtnClick(Sender: TObject);
var TheFamily:TInfo32;
  procedure SetNilFamily(ANode:TNode32);
  begin
    ANode.SetFamily(nil);
  end;
  procedure SetNewFamily(ANode:TNode32);
  begin
    ANode.SetFamily(TheFamily);
  end;
begin
  if (EvntList.Count<=1) and (DlgNode.Family<>nil)
  then try begin {Dismember and delete that family}
    TheFamily:=TInfo32(DlgNode.Family);
    TheFamily.Events.ForEach(@SetNilFamily);
    TheFamily.Events.Clear;
    TGameType32(DlgNode.Game).InfoList.Remove(TheFamily);
    TInfo32(TheFamily).Free;    {Also need to free it, together with its events}
  end; except on Exception do MessageDlg('Error handling events.', mtWarning, [mbOk], 0); end;
  if (EvntList.Count>=2) then try begin
    if (DlgNode.Family=nil)
    then begin   {Create family if necessary}
      TheFamily:=TInfo32.Create(DlgNode.Game);
      TGameType32(DlgNode.Game).InfoList.Add(TheFamily);
    end else TheFamily:=TInfo32(DlgNode.Family);
    {Now redo TheFamily from EvntList}
    TheFamily.Events.ForEach(@SetNilFamily);
    EvntList.ForEach(@SetNewFamily);
    TheFamily.Restore;
  end; except on Exception do MessageDlg('Error handling events.', mtWarning, [mbOk], 0); end;
end;

end.
