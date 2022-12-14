{Copyright (c), Jean-Pierre P. Langlois, 2007-2022}

unit SelectDlg;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls, Dialogs, Type32, Constants;

type
  TSelectDialog = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    ListBox: TListBox;
    procedure CancelBtnClick(Sender: TObject);
    procedure ListBoxClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    DlgList :TGameList;
    BoxIndex:Integer;
    SelIndex:Integer;
    Criterion:Integer;
    procedure InitDialog(AList: TGameList; ACriterion:Integer);
    procedure FindIndex;
  end;

var
  SelectDialog: TSelectDialog;

implementation

{$R *.DFM}

procedure TSelectDialog.InitDialog(AList: TGameList; ACriterion:Integer);
  procedure FillList(AnObject:TGameObject32);
  begin
    if (ACriterion=0) or (AnObject.ObjType=ACriterion)
    then ListBox.Items.Append(AnObject.Description(fw_Audit));
  end;
begin
  DlgList:=AList;
  SelIndex:=-1;
  BoxIndex:=-1;
  Criterion:=ACriterion;
  ListBox.Clear;
  AList.ForEach(@FillList);
  case ListBox.Items.Count of
   0: SelIndex:=-2;
   1: begin BoxIndex:=0;FindIndex; end;
   else ShowModal;
  end;
end;

procedure TSelectDialog.CancelBtnClick(Sender: TObject);
begin
  DlgList:=nil;
end;

procedure TSelectDialog.ListBoxClick(Sender: TObject);
begin
  BoxIndex:=ListBox.ItemIndex;
end;

procedure TSelectDialog.FindIndex;
  procedure MatchIndex(AnObject:TGameObject32);
  begin
    if BoxIndex>=0 then SelIndex:=SelIndex+1 else Exit;
    if AnObject.ObjType=Criterion then BoxIndex:=BoxIndex-1;
  end;
begin
  if Criterion=0
  then SelIndex:=BoxIndex
  else DlgList.ForEach(@MatchIndex);
end;

procedure TSelectDialog.OKBtnClick(Sender: TObject);
begin
  FindIndex;
  DlgList:=nil;
end;

end.
 
