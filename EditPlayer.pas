unit EditPlayer;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Dialogs, Type32, Game32Type, Game32Solve, Constants, ColorGrd;

type
  TPlayerDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Cadre: TBevel;
    EditName: TEdit;
    StaticText1: TStaticText;
    ColorGrid: TColorGrid;
    ColorLbl: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure EditNameChange(Sender: TObject);
    procedure ColorGridChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    DlgPlayer: TPlayer32;
    DlgColor : TColor;
    procedure InitDialog(APlayer:TPlayer32;AGame:TGameType32);
  end;

function PlayerDelete(APlayer:TPlayer32;AGame:TGameType32):Boolean;
procedure PlayerEdit(APlayer:TPlayer32;AGame:TGameType32);

var
  PlayerDlg: TPlayerDlg;

implementation

{$R *.DFM}

function PlayerDelete(APlayer:TPlayer32;AGame:TGameType32):Boolean;
begin
  if APlayer.CanDelete
  then begin
    AGame.PlayerList.Remove(APlayer);
    AGame.SetState(gs_Edited);
    APlayer.Free;
    PlayerDelete:=True;
  end else PlayerDelete:=False;
end;

procedure PlayerEdit(APlayer:TPlayer32;AGame:TGameType32);
begin
  PlayerDlg.InitDialog(APlayer,AGame);
  if PlayerDlg.ShowModal = mrOK
  then begin
    APlayer.Assign(PlayerDlg.DlgPlayer);
    AGame.SetState(gs_Edited);
  end;
end;

{TPlayerDlg implementation}

procedure TPlayerDlg.FormCreate(Sender: TObject);
begin
  DlgPlayer:=TPlayer32.Create(nil);
end;

procedure TPlayerDlg.FormDestroy(Sender: TObject);
begin
  DlgPlayer.Free;
end;

procedure TPlayerDlg.InitDialog(APlayer:TPlayer32;AGame:TGameType32);
begin
  if APlayer<>nil
  then DlgPlayer.Assign(APlayer)
  else begin
    DlgPlayer.SetGame(AGame); {Since it is nil in FormCreate}
    DlgPlayer.Remake; {To clean up}
    DlgColor:=clMyColor;
  end;
  EditName.Text:=DlgPlayer.Name;
  DlgColor:=DlgPlayer.Color;
end;

procedure TPlayerDlg.EditNameChange(Sender: TObject);
begin
  DlgPlayer.SetName(EditName.Text);
end;

procedure TPlayerDlg.ColorGridChange(Sender: TObject);
begin
  DlgColor:=ColorGrid.ForegroundColor;
end;

procedure TPlayerDlg.FormActivate(Sender: TObject);
begin
  FocusControl(EditName);
end;

procedure TPlayerDlg.OKBtnClick(Sender: TObject);
begin
  if (Length(DlgPlayer.Name)<=0)
  then MessageDlg('Invalid name', mtWarning, [mbOk], 0)
  else case DlgColor of
    clWhite  : MessageDlg('White reserved for background', mtWarning, [mbOk], 0);
    clGray   : MessageDlg('Gray reserved for Chance', mtWarning, [mbOk], 0);
    clMyColor: MessageDlg('Color undefined', mtWarning, [mbOk], 0);
    else begin
      DlgPlayer.SetColor(DlgColor);
      ModalResult:=mrOk;
    end;
  end;
end;


end.
 