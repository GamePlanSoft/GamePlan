{Copyright (c), Jean-Pierre P. Langlois, 2007-2022}

unit EditPayoff;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, Dialogs, ExtCtrls, Type32, Game32Type, Game32Solve, Constants;

type
  TPayoffDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    DeleteButton: TButton;
    PlayerListBox: TListBox;
    PayoffEdit: TEdit;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    procedure FormDestroy(Sender: TObject);
    procedure FillPlayerBox;
    procedure PlayerListBoxClick(Sender: TObject);
    procedure RecordPayoff(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure PayoffEditEnter(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    IsMove      : Boolean;
    DlgCell     : TCell32;
    DlgMove     : TMove32;
    CrntPayoff  : TPayoff32;
    SelIndex    : Integer;
    DlgGame     : TGameType32;
    procedure InitDialog(AnObject:TGameObject32);
  end;

var
  PayoffDlg: TPayoffDlg;

implementation

{$R *.DFM}

procedure TPayoffDlg.FormCreate(Sender: TObject);
begin
  DlgMove:=TMove32.Create(nil);
  DlgCell:=TCell32.Create(nil);
end;

procedure TPayoffDlg.FormDestroy(Sender: TObject);
begin
  DlgMove:=nil{.Free};
  DlgCell:=nil{.Free};
  DlgGame:=nil;
end;

procedure TPayoffDlg.FillPlayerBox;
  procedure FillBox(AnObject:TGameObject32);
  begin
    PlayerListBox.Items.Append(AnObject.Name);
  end;
begin
  PlayerListBox.Clear;
  if IsMove then TGameType32(DlgMove.Game).PlayerList.ForEach(@FillBox)
            else TGameType32(DlgCell.Game).PlayerList.ForEach(@FillBox);
end;

procedure TPayoffDlg.InitDialog(AnObject:TGameObject32);
begin
  if AnObject=nil then Exit;
  DlgGame:=TGameType32(AnObject.Game);
  if AnObject.ObjType=ot_Move then IsMove:=True else IsMove:=False;
  if IsMove then DlgMove.Assign(TMove32(AnObject))
            else DlgCell.Assign(TCell32(AnObject));
  FillPlayerBox;
  PayoffEdit.Text:='';
  SelIndex:=-1;
  CrntPayoff:=nil;
end;

procedure TPayoffDlg.PlayerListBoxClick(Sender: TObject);
begin
  SelIndex:=PlayerListBox.ItemIndex;
  if SelIndex>=0
  then begin
    if IsMove then CrntPayoff:=DlgMove.ShowPayment(TPlayer32(DlgGame.PlayerList.Items[SelIndex]))
              else CrntPayoff:=DlgCell.ShowPayment(TPlayer32(DlgGame.PlayerList.Items[SelIndex]));
    if CrntPayoff=nil
    then PayoffEdit.Text:='Undefined'
    else PayoffEdit.Text:=FloatToStrF(CrntPayoff.Value,ffGeneral,7,6);
  end;
end;

procedure TPayoffDlg.PayoffEditEnter(Sender: TObject);
begin
  if (SelIndex>=0) and (CrntPayoff=nil)
  then begin
    CrntPayoff:=TPayoff32.Create(DlgGame);
    DlgGame.PayList.Add(CrntPayoff);
    CrntPayoff.SetWhom(DlgGame.PlayerList.Items[SelIndex]);
    if IsMove then begin
      DlgMove.Payments.Add(CrntPayoff);
      CrntPayoff.SetWhere(DlgMove);
    end else begin
      DlgCell.Payments.Add(CrntPayoff); 
      CrntPayoff.SetWhere(DlgCell);
    end;
  end;
end;

{procedure TPayoffDlg.RecordPayoff(Sender: TObject);
var AReal:Real; ACode:Integer;
begin
  Val(PayoffEdit.Text,AReal,ACode);
  if (ACode=0) and (CrntPayoff<>nil)
  then CrntPayoff.SetValue(AReal);
end;}

procedure TPayoffDlg.RecordPayoff(Sender: TObject);
var AReal:Real; ACode:Integer;
begin
  Val(PayoffEdit.Text,AReal,ACode);
  if (ACode<>0) then Exit;
  if ((Abs(AReal)<=TopValue) and (Abs(AReal)>=MinValue)) or (AReal=0)
  then begin
    if (CrntPayoff<>nil)
    then CrntPayoff.SetValue(AReal);
  end else begin
    MessageDlg('Invalid payoff magnitude.',mtWarning,[mbOk],0);
    PayoffEdit.Text:='Undefined';
  end;
end;

procedure TPayoffDlg.DeleteButtonClick(Sender: TObject);
begin
  if (CrntPayoff<>nil)
  and ObjectTypeIsOk(CrntPayoff,TPayoff32)
  then begin
    DlgGame.PayList.Remove(CrntPayoff);
    DlgMove.Payments.Remove(CrntPayoff);
    CrntPayoff.Free;
    CrntPayoff:=nil;
    PayoffEdit.Text:='Undefined';
  end;
end;

end.
