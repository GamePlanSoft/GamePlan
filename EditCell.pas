unit EditCell;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Type32, Game32Type, Game32Solve;

type
  TCellDlg = class(TForm)
    OkBtn: TButton;
    StaticText1: TStaticText;
    EditDiscount: TEdit;
    FinalRadioButton: TRadioButton;
    UptoListBox: TListBox;
    StaticText2: TStaticText;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    procedure FillBox;
    procedure UptoListBoxClick(Sender: TObject);
    procedure FinalRadioButtonClick(Sender: TObject);
    procedure EditDiscountChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    SelIndex : Integer;
    DlgCell  : TCell32;
    NodeList : TGameList;
    procedure InitDialog(ACell:TCell32);
  end;

var
  CellDlg: TCellDlg;

implementation

{$R *.DFM}

procedure TCellDlg.InitDialog(ACell:TCell32);
begin
  DlgCell:=ACell;
  NodeList:=TGameType32(DlgCell.Game).NodeList;
  FillBox;
  with DlgCell do begin
    EditDiscount.Text:=FloatToStrF(Discount,ffGeneral,7,6);
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

procedure TCellDlg.FillBox;
  procedure FillBox(AnObject:TGameObject32);
  begin
    UptoListBox.Items.Append(AnObject.Name);
  end;
begin
  UptoListBox.Clear;
  NodeList.ForEach(@FillBox);
  if NodeList.Count>0 then
  UptoListBox.ItemIndex:=1;  {To make sure something is highlighted}
end;


procedure TCellDlg.UptoListBoxClick(Sender: TObject);
var AnUpto:TNode32;
begin
  SelIndex:=UptoListBox.ItemIndex;
  if SelIndex>=0
  then with DlgCell do begin
    AnUpto:=TNode32(NodeList.Items[SelIndex]);
    SetUpto(AnUpto);
    XPos:=Round((XFro+AnUpto.XPos)/2);
    YPos:=Round((YFro+AnUpto.YPos)/2);
    FinalRadioButton.Checked:=False;
  end;
end;


procedure TCellDlg.FinalRadioButtonClick(Sender: TObject);
begin
    with DlgCell do begin
      SetUpto(nil);
      XPos:=XFro;
      YPos:=YFro;
    end;
    UptoListBox.ItemIndex:=-1;
end;

procedure TCellDlg.EditDiscountChange(Sender: TObject);
var AReal:Real; ACode:Integer;
begin
  Val(EditDiscount.Text,AReal,ACode);
  if (ACode=0) and (AReal>0) and (AReal<=1)
  then DlgCell.SetDiscount(AReal);
end;

end.
