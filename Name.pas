{Copyright (c), Jean-Pierre P. Langlois, 2007-2022}

unit Name;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls, Type32, Game32Type;

type
  TNameDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    EditName: TEdit;
    Label1: TLabel;
    procedure EditNameChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    DlgObject : TGameObject32;
    OldName   : String;
    procedure InitDialog(ATitle:String;AnObject:TGameObject32;AGame:TFakeGame);
  end;

var
  NameDlg: TNameDlg;

implementation

{$R *.DFM}

procedure TNameDlg.InitDialog(ATitle:String;AnObject:TGameObject32;AGame:TFakeGame);
begin
  Caption:=ATitle;
  DlgObject:=AnObject;
  if (DlgObject<>nil)
  then OldName:=DlgObject.Name
  else OldName:='';
  EditName.Text:=OldName;
end;

procedure TNameDlg.EditNameChange(Sender: TObject);
begin
  if (DlgObject<>nil)
  then DlgObject.SetName(EditName.Text);
end;

procedure TNameDlg.FormActivate(Sender: TObject);
begin
  FocusControl(EditName);
end;

procedure TNameDlg.CancelBtnClick(Sender: TObject);
begin
  if (DlgObject<>nil)
  then DlgObject.Name:=OldName;
end;

end.
