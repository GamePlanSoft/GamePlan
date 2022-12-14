{Copyright (c), Jean-Pierre P. Langlois, 2007-2022}

unit EditMove;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls, Type32, Game32Type, Game32Solve, Constants, Utilities, Dialogs;

type
  TMoveDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    EditName: TEdit;
    EditDiscount: TEdit;
    StaticText2: TStaticText;
    UptoListBox: TListBox;
    Bevel2: TBevel;
    StaticText3: TStaticText;
    Bevel3: TBevel;
    FromListBox: TListBox;
    StaticText4: TStaticText;
    Bevel4: TBevel;
    FinalRadioButton: TRadioButton;
    PayBtn: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FromListBoxClick(Sender: TObject);
    procedure FillBox(AList:TGameList;AListBox:TListBox);
    procedure UptoListBoxClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure EditNameChange(Sender: TObject);
    procedure EditDiscountChange(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FinalRadioButtonClick(Sender: TObject);
    procedure PayBtnClick(Sender: TObject);
    procedure ToggleDiscount;
  private
    { Private declarations }
  public
    { Public declarations }
    SelIndex : Integer;
    DscntIsWrong:Boolean;
    DlgMove  : TMove32;
    NodeList : TGameList;
    procedure InitDialog(AMove:TMove32;AGame:TGameType32);
  end;

  procedure MoveDelete(AMove:TMove32;AGame:TGameType32);
  function MoveEdit(AMove:TMove32;AGame:TGameType32):Boolean;

var
  MoveDlg: TMoveDlg;

implementation

uses EditPayoff;

{$R *.DFM}

procedure MoveDelete(AMove:TMove32;AGame:TGameType32);
begin
    AGame.MoveList.Remove(AMove);
    AGame.SetState(gs_Edited);
    AMove.Free;
end;

function MoveEdit(AMove:TMove32;AGame:TGameType32):Boolean;
begin
  MoveDlg.InitDialog(AMove,AGame);
  if MoveDlg.ShowModal = mrOK
  then begin
    AMove.Assign(MoveDlg.DlgMove);
    AGame.SetState(gs_Edited);
    MoveEdit:=True;
  end else MoveEdit:=False;
  MoveDlg.DlgMove.DeletePayments;  {To avoid duplicate payoffs in Game}
end;

procedure TMoveDlg.FormCreate(Sender: TObject);
begin
  DlgMove:=TMove32.Create(nil);
end;

procedure TMoveDlg.FormDestroy(Sender: TObject);
begin
  //DlgMove:=nil;
  if DlgMove<>nil then DlgMove.Free;
  NodeList:=nil;
end;

procedure TMoveDlg.FormActivate(Sender: TObject);
begin
  FocusControl(EditName);
end;

procedure TMoveDlg.FillBox(AList:TGameList;AListBox:TListBox);
  procedure FillBox(AnObject:TGameObject32);
  begin
    AListBox.Items.Append(AnObject.Name);
  end;
begin
  AListBox.Clear;
  AList.ForEach(@FillBox);
  AListBox.ItemIndex:=1;  {To make sure something is highlighted}
end;

procedure TMoveDlg.InitDialog(AMove:TMove32;AGame:TGameType32);
begin
  if AMove<>nil
  then DlgMove.Assign(AMove)
  else DlgMove.Remake;
  DlgMove.SetGame(AGame);
  if (AGame.NodeList<>nil)
  then begin
    NodeList:=AGame.NodeList;
    FillBox(NodeList,FromListBox);
    FillBox(NodeList,UptoListBox);
  end;
  with DlgMove do begin
    EditName.Text:=Name;
    EditDiscount.Text:=FloatToStrF(Discount,ffGeneral,7,6);
    if (From=nil)
    then FromListBox.ItemIndex:=-1
    else FromListBox.ItemIndex:=NodeList.IndexOf(From);
    ToggleDiscount;
    if (Upto<>nil)
    then begin
      UptoListBox.ItemIndex:=NodeList.IndexOf(Upto);
      FinalRadioButton.Checked:=False;
    end else begin
      UptoListBox.ItemIndex:=-1;
      FinalRadioButton.Checked:=True;
    end;
  end;
  SelIndex:=-1;
end;

procedure TMoveDlg.EditNameChange(Sender: TObject);
begin
  DlgMove.SetName(EditName.Text);
end;

procedure TMoveDlg.EditDiscountChange(Sender: TObject);
var AReal:Real; ACode:Integer;
begin
  DscntIsWrong:=False;
  Val(EditDiscount.Text,AReal,ACode);
  if (ACode<>0) then DscntIsWrong:=True;
  if (AReal<MinDscnt)
  then DscntIsWrong:=True;
  if (AReal>1)
  then DscntIsWrong:=True;
  if (AReal<1) and (AReal>MaxDscnt)
  then DscntIsWrong:=True;
  if not DscntIsWrong
  then DlgMove.SetDiscount(AReal);
end;

procedure TMoveDlg.FromListBoxClick(Sender: TObject);
begin
  SelIndex:=FromListBox.ItemIndex;
  if SelIndex>=0
  then begin
    DlgMove.SetFrom(TNode32(NodeList.Items[SelIndex]));
    ToggleDiscount;
  end;
end;

procedure TMoveDlg.ToggleDiscount;
begin
  if (DlgMove.From<>nil)
  then if DlgMove.From.Owner=nil
       then StaticText2.Caption:='Probability'
       else StaticText2.Caption:='Discount';
end;

procedure TMoveDlg.FinalRadioButtonClick(Sender: TObject);
begin
    DlgMove.SetUpto(nil);
    UptoListBox.ItemIndex:=-1;
end;

procedure TMoveDlg.UptoListBoxClick(Sender: TObject);
begin
  SelIndex:=UptoListBox.ItemIndex;
  if SelIndex>=0
  then with DlgMove do begin
    SetUpto(TNode32(NodeList.Items[SelIndex]));
    FinalRadioButton.Checked:=False;
  end;
end;

procedure TMoveDlg.OKBtnClick(Sender: TObject);
begin
  with DlgMove do
  if (Length(Name)<=0)
  then MessageDlg('Invalid name', mtWarning, [mbOk], 0)
  else if (From=nil)
       then MessageDlg('From is undefined', mtWarning, [mbOk], 0)
       else if From=Upto
            then MessageDlg('From cannot equal Upto', mtWarning, [mbOk], 0)
            else if DscntIsWrong
                 then MessageDlg('Discount other than one must be between 0.001 and 0.999',mtWarning,[mbOk],0)
                 else ModalResult:=mrOk;
end;

procedure TMoveDlg.PayBtnClick(Sender: TObject);
begin
  PayoffDlg.InitDialog(DlgMove);
  if PayoffDlg.ShowModal = mrOK
  then DlgMove.Assign(PayoffDlg.DlgMove);
  PayoffDlg.DlgMove.DeletePayments; {Removes payoffs from game}
end;

end.
