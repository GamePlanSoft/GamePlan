{Copyright (c), Jean-Pierre P. Langlois, 2007-2022}

unit OldCHILDWIN;

{This defines the typical child window. It contains all the graphing and
 display routines. It can be of several forms: extensive, normal, bla}

interface

uses Windows, Classes, Graphics, Forms, SysUtils, Controls, StdCtrls, Type32, Menus,
     Messages, Dialogs, Game32Type, Game32Solve, Spin, ToolWin, ComCtrls,
  ActnList;

type
  TMDIChild = class(TForm)
    PlayerPopupMenu: TPopupMenu;
    DeletePlayer: TMenuItem;
    EditPlayer: TMenuItem;
    RedrawPlayer: TMenuItem;
    NodePopupMenu: TPopupMenu;
    DeleteNode: TMenuItem;
    EditNode: TMenuItem;
    ReDrawNode: TMenuItem;
    InfoSet: TMenuItem;
    MovePopupMenu: TPopupMenu;
    DeleteMove: TMenuItem;
    EditMove: TMenuItem;
    RedrawMove: TMenuItem;
    EditPayoff: TMenuItem;
    NameMenu: TPopupMenu;
    EditName: TMenuItem;
    ReDraw1: TMenuItem;
    AuditMemo: TMemo;
    TablePopupMenu: TPopupMenu;
    Redraw2: TMenuItem;
    DeleteTable: TMenuItem;
    EditTable: TMenuItem;
    CellPopupMenu: TPopupMenu;
    Payoff1: TMenuItem;
    ChoicePopupMenu: TPopupMenu;
    EditChoiceMenu: TMenuItem;
    AddSide1: TMenuItem;
    SidePopupMenu: TPopupMenu;
    Delete1: TMenuItem;
    Edit1: TMenuItem;
    FloatActList: TActionList;
    FDeletePlayer: TAction;
    FEditPlayer: TAction;
    FDeleteNode: TAction;
    FEditNode: TAction;
    FEditInfo: TAction;
    FDeleteMove: TAction;
    FEditMove: TAction;
    FMovePayoff: TAction;
    ShowCells1: TMenuItem;
    SelectPopupMenu: TPopupMenu;
    Delete2: TMenuItem;
    Copy1: TMenuItem;
    ReDraw3: TMenuItem;
    EditCell: TMenuItem;
    RedrawCell: TMenuItem;
    MoveConstraint: TMenuItem;
    StratConstraint: TMenuItem;
    FConstraint: TAction;
    FEditStrat: TAction;
    {procedure WndProc(var Message: TMessage); override; }
    procedure VertFormScroll(var ScrollData:TWMScroll); message wm_VScroll;
    procedure HorzFormScroll(var ScrollData:TWMScroll); message wm_HScroll;
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ResetDisplay;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SetToDraw(IsDrawing:Boolean);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormPaint(Sender: TObject);
    procedure DeletePlayerClick(Sender: TObject);
    procedure EditPlayerClick(Sender: TObject);
    procedure EditNodeClick(Sender: TObject);
    procedure DeleteNodeClick(Sender: TObject);
    procedure DeleteMoveClick(Sender: TObject);
    procedure EditMoveClick(Sender: TObject);
    procedure InfoSetClick(Sender: TObject);
    procedure EditPayoffClick(Sender: TObject);
    procedure EditNameClick(Sender: TObject);
    {procedure ActivateClick(Sender: TObject);}
    procedure RedrawClick(Sender: TObject);
    procedure DeleteTableClick(Sender: TObject);
    procedure EditTableClick(Sender: TObject);
    procedure SideDeleteClick(Sender: TObject);
    procedure SideEditClick(Sender: TObject);
    procedure AddSideClick(Sender: TObject);
    {procedure CommandEnable(ACase:Integer);}
    procedure ShowCells1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean) ;
    procedure FormCreate(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure DeleteSelectClick(Sender: TObject);
    procedure CopySelectClick(Sender: TObject);
    procedure EditCellClick(Sender: TObject);
    procedure RedrawCellClick(Sender: TObject);
    procedure MoveConstraintClick(Sender: TObject);
  private
    { Private declarations }
    XScr,YScr: Integer;
    IsSelecting:Boolean;
    MousePos:TPoint;
    {fRect:TRect; }
  public
    { Public declarations }
    WindowCase     : Integer;
    SelectedObject : TGameObject32;
    AuditList      : TGameList;
    MustDraw       : Boolean;
    XDim,YDim      : Integer;
    MainGame       : TGameType32;
    MainSolution   : TSolution32;
    MainProfile    : TProfile;
    BMPGraph       : TBitmap;  {TJpegImage in Delphi 5}
    procedure SetCaption(ACaption:String);
    procedure MakeAudit(ForWhat:Integer);
    function ReadyToSolve:Boolean;
    procedure AddAuditLine(ALine:String);
    procedure DisplayAuditList;
    procedure ClearAudit;
    {procedure ResetConstraint(IsOn:Boolean); }
    function CannotEdit:Boolean;
    procedure ShowGrid;
    procedure FloatMenuUpdating(AGameState:Integer);
    procedure UpdateSolDisplay(HasProba,HasBelief,HasExpect:Boolean);
  end;

implementation

uses EditPlayer, EditNode, EditMove, EditInfo, EditPayoff, EditTable, Constants, Utilities,
  MainGP32, AuditUnit, SolvOptDlg, Name, Solve32, EditSide, File32,
  EditCell, PassUnit;

{$R *.DFM}

{procedure TMDIChild.WndProc(var Message: TMessage);
begin
  if (Message.Msg=WM_MOUSEWHEEL) then Exit; {Trap mousewheel}
 { inherited WndProc(Message);
end; }

procedure TMDIChild.VertFormScroll;
begin        {Replaces the absence of OnScroll event}
  inherited;
  YScr:=VertScrollBar.Position;
  Invalidate;
end;

procedure TMDIChild.HorzFormScroll;
begin
  inherited;
  XScr:=HorzScrollBar.Position;
  Invalidate;
end;

procedure TMDIChild.FormActivate(Sender: TObject);
begin
  IsSelecting:=False;
  SelectedObject:=nil;
  with MainForm do begin
    EnableSelect(False);
    if MainGame<>nil then MenuUpdating(MainGame.GameState);
  end;
  {if MainGame=nil then MainForm.CommandEnabling(ce_Edit)
  else begin
  MessageDlg('State is '+FloatToStrF(MainGame.GameState,ffGeneral,floatdgts,floatdgts), mtInformation, [mbOk], 0);

  case MainGame.GameState of
    gs_Solved,
    gs_SavSol  : begin
                 MainForm.CommandEnabling(ce_Solve);
                 CommandEnable(ce_Solve);
                 SolveDlg.InitDialog(False,MainGame);
                 end;
    gs_Edited,
    gs_CanClose,
    gs_New     : begin
                 MainForm.CommandEnabling(ce_Edit);
                 CommandEnable(ce_Edit);
                 end;
    gs_Solving  : begin
                  MainForm.CommandEnabling(ce_Solving);
                  CommandEnable(ce_Solving);
                  end;
    gs_Constraint : begin
                    CommandEnable(ce_Constraint);
                    end;
  end;



  {if MainGame.GameState in [gs_Solved,gs_SavSol]
       then begin
         MainForm.CommandEnabling(ce_Solve);
         CommandEnable(ce_Solve);
         SolveDlg.InitDialog(False,MainGame);
       end else begin
         MainForm.CommandEnabling(ce_Edit);
         CommandEnable(ce_Edit);
       end;
  end; }
  Invalidate;
end;

procedure TMDIChild.SetCaption(ACaption:String);
begin
  Caption:=ACaption;
  Invalidate;
end;

procedure TMDIChild.ResetDisplay;
begin
  if WindowCase in [wc_Audit,wc_Debug] then begin
    AuditMemo.Visible:=True;

  end else begin
    AuditMemo.Visible:=False;
    XDim:=Zoom(MainGame.XDim);  {Could reset game dimensions}
    YDim:=Zoom(MainGame.YDim);
    VertScrollBar.Range:=XDim;
    HorzScrollBar.Range:=YDim;
  end;
end;

procedure TMDIChild.FormCreate(Sender: TObject);
begin
  {DoubleBuffered := True; }
end;

procedure TMDIChild.FormDestroy(Sender: TObject);
begin
  SelectedObject:=nil;
  case WindowCase of
    wc_MainGame : begin
                    MainForm.CloseSolutionWindow(MainGame,nil);
                    if (SolveDlg.GameToSolve=MainGame) then SolveDlg.Hide;
                    if MainGame<>nil then MainGame.Free;
                  end;
    wc_Solution : begin MainSolution:=nil; MainProfile:=nil; end;
    wc_Profile  : begin MainSolution:=nil; MainProfile:=nil; end;
    wc_Audit    : begin AuditList.FreeAll(ot_All); AuditList.Free;
                        MainSolution:=nil; MainProfile:=nil; end;
    wc_Debug    : begin {AuditList.FreeAll(ot_All); AuditList.Free;  }
                        MainSolution:=nil; MainProfile:=nil; end;
  end;
end;

procedure TMDIChild.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if MainSolution<>nil then begin
    MainSolution.SetShown(False);
    {MainSolution.BitList.FreeAll(ot_All);}
    SolveDlg.UpdateSolutionBox(nil);
  end;
  Action := caFree;
end;

procedure TMDIChild.SetToDraw(IsDrawing:Boolean);
begin
  if SelectedObject<>nil then begin
    MousePos.X:=Zoom(SelectedObject.XPos)-XScr;
    MousePos.Y:=Zoom(SelectedObject.YPos)-YScr;
    Mouse.CursorPos:= ClientToScreen(MousePos);
    if IsDrawing then begin
      Screen.Cursor:=crCross;
      MustDraw:=True;
    end;
  end;
end;

procedure TMDIChild.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and MustDraw
  then begin
    SelectedObject.SetPosition(GridFilt(UnZoom(X+XScr)),GridFilt(UnZoom(Y+YScr)));
    {if SelectedObject.ObjType=ot_Move then TMove32(SelectedObject).RedoGraphics; }
    Invalidate;
  end;
  if (Button = mbRight) and not MustDraw and (SelectedObject<>nil)
  then begin
    if SelectedObject<>MainGame.SelRect then MainGame.SelRect.SetArtificial(True);
    case SelectedObject.ObjType of
      ot_Player  : PlayerPopupMenu.Popup(X+ClientOrigin.X,Y+ClientOrigin.Y);
      ot_Node    : NodePopupMenu.Popup(X+ClientOrigin.X,Y+ClientOrigin.Y);
      ot_Move    : MovePopupMenu.Popup(X+ClientOrigin.X,Y+ClientOrigin.Y);
      ot_Table   : TablePopupMenu.Popup(X+ClientOrigin.X,Y+ClientOrigin.Y);
      ot_Header  : NameMenu.Popup(X+ClientOrigin.X,Y+ClientOrigin.Y);
      ot_Cell    : CellPopupMenu.Popup(X+ClientOrigin.X,Y+ClientOrigin.Y);
      ot_Strat   : ChoicePopupMenu.Popup(X+ClientOrigin.X,Y+ClientOrigin.Y);
      ot_Side    : SidePopupMenu.Popup(X+ClientOrigin.X,Y+ClientOrigin.Y);
      ot_SelRect : if not MainGame.SelRect.IsArtificial
                   then SelectPopupMenu.Popup(X+ClientOrigin.X,Y+ClientOrigin.Y);
    end;
  end;
  if (Button = mbLeft) and not MustDraw
  then begin
    IsSelecting:=True;
    SetCapture(Handle);
    with MainGame.SelRect do begin
      SetArtificial(False);
      SetPosition(UnZoom(X+XScr),UnZoom(Y+YScr));
      SetCorner(UnZoom(X+XScr),UnZoom(Y+YScr));
    end;
    Invalidate;
   end;
end;

procedure TMDIChild.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
var R:TRect;
  procedure CheckCoordinates(AnObject:TGameObject32);
  begin
    if AnObject<>nil
    then with AnObject
         do if AnObject.IsDetected(UnZoom(XScr+X),UnZoom(YScr+Y))
            then SelectedObject:=AnObject;
  end;
  procedure MoveSelected(AnObject:TGameObject32);
  begin
    with AnObject do begin
      SetPosition(GridFilt(UnZoom(X+XScr)+XOrg),GridFilt(UnZoom(Y+YScr)+YOrg));
      R:=OwnRectangle(X,Y,True);
      InvalidateRect(Handle,@R,True);
    end;
  end;
begin
  if MustDraw
  then with SelectedObject do begin
    SetPosition(GridFilt(UnZoom(X+XScr)),GridFilt(UnZoom(Y+YScr)));
    R:=OwnRectangle(XPos-XScr,YPos-YScr,True);
    InvalidateRect(Handle,@R,True);
    with MainGame do if SelectedObject=SelRect
    then Selection.ForEach(@MoveSelected)
    else Selection.Clear;
  end;
  if IsSelecting and not MustDraw
  then with MainGame.SelRect do begin
    SetCorner(UnZoom(X+XScr),UnZoom(Y+YScr));
    R:=OwnRectangle(XPos-XScr,YPos-YScr,False);
    InvalidateRect(Handle,@R,True); {Invalidate; }
  end;
  if not IsSelecting and not MustDraw
  then begin
    SelectedObject:=nil;
    with MainGame do begin
      PlayerList.ForEach(@CheckCoordinates);
      NodeList.ForEach(@CheckCoordinates);
      MoveList.ForEach(@CheckCoordinates);
      InfoList.ForEach(@CheckCoordinates);
      ChoiceList.ForEach(@CheckCoordinates); {Build safeguard for ot_Choice}
      CheckCoordinates(GameHeader);
      CheckCoordinates(SelRect);
    end;
    if SelectedObject<>nil
    then Screen.Cursor:=crHandPoint
    else Screen.Cursor:=crDefault;
  end;
end;

procedure TMDIChild.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and MustDraw
  then begin
    MustDraw:=False;
    Screen.Cursor:=crDefault;
    MainGame.Selection.Clear;
    MainForm.EnableSelect(False);
    MainGame.SelRect.SetArtificial(True);
    Invalidate;
  end;
  if (Button = mbLeft) and IsSelecting
  then begin
    ReleaseCapture;
    IsSelecting:=False;
    MainGame.SelRect.SetCorner(UnZoom(X+XScr),UnZoom(Y+YScr));
    if MainGame.HasSelection
    then begin
      SelectedObject:=MainGame.SelRect;
      MainForm.EnableSelect(True);
      SetToDraw(False);
      Screen.Cursor:=crHandPoint;
    end else begin
      SelectedObject:=nil;
      MainForm.EnableSelect(False);
      MainGame.SelRect.SetArtificial(True);
      Invalidate;
    end;
  end;
end;

procedure TMDIChild.FormPaint(Sender: TObject);
  procedure ShowProfile;
    procedure ShowOwnBits(ABit:TSolutionBit);
    begin
      ABit.DrawObject(Canvas);
    end;
  begin
    MainProfile.BitList.ForEach(@ShowOwnBits);
  end;
begin
  SetWindowOrgEx(Canvas.Handle,XScr,YScr,nil);
  if MainForm.DisplayGrid.Checked then ShowGrid;
  MainGame.DrawGame(Canvas);
  {if (MainSolution=nil) and (MainProfile=nil) then MinMaxList.ForEach(@DrawObjects); }
  if MainSolution<>nil then MainSolution.DrawObject(Canvas);
  if MainProfile<>nil then ShowProfile;
end;

procedure TMDIChild.ShowGrid;
var I:Integer;
begin
  with Canvas do begin
    Brush.Color:=clWhite;
    Pen.Width:=Zoom(ThinPen);
    pen.Color:=clGray;
    pen.Style:=psDot;
    for I:=1 to Round(gp_Horz/2-1) do begin
      MoveTo(Zoom(2*I*GridStep),1);
      LineTo(Zoom(2*I*GridStep),Zoom(gp_Vert*GridStep));
    end;
    for I:=1 to Round(gp_Vert/2-1) do begin
      MoveTo(1,Zoom(2*I*GridStep));
      LineTo(Zoom(gp_Horz*GridStep),Zoom(2*I*GridStep));
    end;
    pen.Style:=psSolid;
  end;
end;

procedure TMDIChild.DeletePlayerClick(Sender: TObject);
begin
  if CannotEdit then Exit;
  if PlayerDelete(TPlayer32(SelectedObject),MainGame)
  then SelectedObject:=nil
  else MessageDlg('Player owns nodes or sides.', mtWarning, [mbOk], 0);
  Invalidate;
end;

procedure TMDIChild.EditPlayerClick(Sender: TObject);
begin
  if CannotEdit then Exit;
  PlayerEdit(TPlayer32(SelectedObject),MainGame);
  Invalidate;
end;

procedure TMDIChild.DeleteNodeClick(Sender: TObject);
begin
  if CannotEdit then Exit;
  if NodeDelete(TNode32(SelectedObject),MainGame)
  then SelectedObject:=nil
  else MessageDlg('Node owns moves or belongs to information set.', mtWarning, [mbOk], 0);
  Invalidate;
end;

procedure TMDIChild.EditNodeClick(Sender: TObject);
begin
  if CannotEdit then Exit;
  NodeEdit(TNode32(SelectedObject),MainGame);
  Invalidate;
end;

procedure TMDIChild.DeleteTableClick(Sender: TObject);
begin
  if CannotEdit then Exit;
  MainGame.NodeList.Remove(SelectedObject);
  MainGame.SetState(gs_Edited);
  TTable32(SelectedObject).Free;
  Invalidate;
end;

procedure TMDIChild.EditTableClick(Sender: TObject);
begin
  if CannotEdit then Exit;
  with NameDlg do begin
    InitDialog('Edit Table',SelectedObject,MainGame);
    if ShowModal=mrOk then MainGame.SetState(gs_Edited);
  end;
  Invalidate;
end;

procedure TMDIChild.AddSideClick(Sender: TObject);
var ATable:TTable32;
begin
  if CannotEdit then Exit;
      ATable:=TTable32(SelectedObject);
      if SideDlg.FillOwnerList(ATable) {Check there are possible owners}
      then begin
        SideEdit(nil,ATable,MainGame);
        ATable.RedoGraphics;
        Invalidate;
      end else MessageDlg('Need additional players', mtWarning, [mbOk], 0);
end;

procedure TMDIChild.EditNameClick(Sender: TObject);
begin
  if CannotEdit then Exit;
  with NameDlg do begin
    case SelectedObject.ObjType of
      ot_Header : InitDialog('Solution name',MainGame.GameHeader,nil);
      ot_Strat  : InitDialog('Strategy Name',SelectedObject,nil);
    end;
    if ShowModal=mrOK then MainGame.SetState(gs_Edited);
  end;
  Invalidate;
end;

procedure TMDIChild.SideEditClick(Sender: TObject);
var ASide:TSide32; ATable:TTable32;
begin
  if CannotEdit then Exit;
  ASide:=TSide32(SelectedObject);
  ATable:=ASide.OwnTable;
  SideEdit(ASide,ATable,MainGame);
  ATable.RedoGraphics;
  Invalidate;

end;

procedure TMDIChild.SideDeleteClick(Sender: TObject);
var ASide:TSide32; ATable:TTable32;
begin
  if CannotEdit then Exit;
  ASide:=TSide32(SelectedObject);
  ATable:=ASide.OwnTable;
  ATable.DeleteSide(ASide);
  ATable.RedoGraphics;
  MainGame.SetState(gs_Edited);
  Invalidate;
end;

procedure TMDIChild.DeleteMoveClick(Sender: TObject);
begin
  if CannotEdit then Exit;
  MoveDelete(TMove32(SelectedObject),MainGame);
  Invalidate;
end;

procedure TMDIChild.EditMoveClick(Sender: TObject);
begin
  if CannotEdit then Exit;
  if MoveEdit(TMove32(SelectedObject),MainGame) then begin
    SetToDraw(True);
    Invalidate;
  end;
end;

procedure TMDIChild.InfoSetClick(Sender: TObject);
begin
  if CannotEdit then Exit;
  if SelectedObject.ObjType<>ot_Node then Exit;
  if (TNode32(SelectedObject).Owner=nil)
  then MessageDlg('Chance nodes cannot be in an information set.', mtInformation, [mbOk], 0)
  else with InfoDlg do begin
    if InitDialog(TNode32(SelectedObject))
    then ShowModal
    else MessageDlg('All other nodes have a different owner or already belong to an information set.', mtInformation, [mbOk], 0);
  end;
  Invalidate;
end; 

procedure TMDIChild.EditCellClick(Sender: TObject);
begin
  if CannotEdit then Exit;
  with CellDlg do begin
    InitDialog(TCell32(SelectedObject));
    ShowModal;
    if ModalResult=mrOk then Hide;
    MainGame.SetState(gs_Edited);
    if TCell32(SelectedObject).Upto<>nil then SetToDraw(True);
  end;
  Invalidate;
end;

procedure TMDIChild.EditPayoffClick(Sender: TObject);
begin
  if CannotEdit then Exit;
  with PayoffDlg do begin
    if SelectedObject.ObjType=ot_Cell
    then TCell32(SelectedObject).OwnTable.SelfAssociateChoices;
    InitDialog(SelectedObject);
    if ShowModal = mrOK
    then begin
      case SelectedObject.ObjType of
      ot_Move : TMove32(SelectedObject).Assign(DlgMove);
      ot_Cell : TCell32(SelectedObject).Assign(DlgCell);
      end;
      MainGame.SetState(gs_Edited);
    end;
    DlgMove.DeletePayments;
    DlgCell.DeletePayments;
  end;
  Invalidate;
end;

function TMDIChild.ReadyToSolve:Boolean;
begin
  ReadyToSolve:=False;
  with MainGame do if GameState in [gs_New,gs_Edited]
  then MessageDlg('You must save before solving', mtInformation, [mbOk], 0)
  else if CheckGame
  then begin
    ReadyToSolve:=True;
    SolutionList.FreeAll(ot_All);
    ProfileList.FreeAll(ot_All);
    SolGroupList.FreeAll(ot_All);
  end else begin
    MainForm.MakeGameAudit(fw_Bugs);
    ReturnToEdit;
  end;
end;

procedure TMDIChild.MakeAudit(ForWhat:Integer);
  procedure ShowLine(AnObject:TBug);
  begin
    AddAuditLine(AnObject.Description(False));
  end;
begin
    ClearAudit;
    case ForWhat of
    fw_Bugs   : begin
                 AddAuditLine('GAME IS FLAWED');
                 MainGame.BugList.ForEach(@ShowLine)
                end;
    fw_ObjList: with MainGame do begin
                 AddAuditLine('GAME IS SOLVABLE');
                 AddAuditLine('PLAYERS');
                 PlayerList.ForEach(@ShowLine);
                 AddAuditLine('TURNS');
                 InfoList.ForEach(@ShowLine);
                 AddAuditLine('NODES');
                 NodeList.ForEach(@ShowLine);
                 AddAuditLine('MOVES');
                 MoveList.ForEach(@ShowLine);
                 AddAuditLine('CHOICES');
                 ChoiceList.ForEach(@ShowLine);
                 {AddAuditLine('TABLES');
                 TableList.ForEach(@ShowLine);
                 {AddAuditLine('SIDES');
                 SideList.ForEach(@ShowLine); }
                 {AddAuditLine('STRATEGIES');
                 StratList.ForEach(@ShowLine);
                 {AddAuditLine('CELLS');
                 CellList.ForEach(@ShowLine); }
                 AddAuditLine('PAYOFFS');
                 PayList.ForEach(@ShowLine);
                end;
    fw_Test   : MainGame.TestList.ForEach(@ShowLine);
    fw_Debug  : begin
                  AddAuditLine('AUDIT SOLUTION');
                  if (MainSolution<>nil) then MainSolution.DebugList.ForEach(@ShowLine);
                end;
    end;
    DisplayAuditList;
end;

procedure TMDIChild.AddAuditLine(ALine:String);
var ABug:TBug;
begin
  ABug:=TBug.Create(nil);
  ABug.SetLine(ALine);
  AuditList.Add(ABug);
end;

procedure TMDIChild.DisplayAuditList;
  procedure DisplayLine(ALine:TGameObject32);
  begin
    AuditMemo.Lines.Add(ALine.TextLine);
  end;
begin
  AuditList.ForEach(@DisplayLine);
end;

procedure TMDIChild.ClearAudit;
begin
  AuditMemo.Clear;
  AuditList.FreeAll(ot_All);
end;

{procedure TMDIChild.ActivateClick(Sender: TObject);
begin
  with SelectedObject as TMove32 do SetActivated(not IsActivated);
  Invalidate;
end; }

procedure TMDIChild.RedrawClick(Sender: TObject);
begin
  SetToDraw(True);
end;

procedure TMDIChild.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if WindowCase<>wc_MainGame then CanClose:=True
  else case MainGame.GameState of
    gs_CanClose,
    gs_SavSol   : CanClose:=True;
    gs_Edited   : if not IsPassUser then MessageDlg('Unregistered user cannot save games', mtWarning, [mbOk], 0)
                  else if MessageDlg('Save edited game?', mtConfirmation, [mbYes, mbNo], 0) = mrYes
                  then begin FileSave(Self.Caption,MainGame); CanClose:=True; end;
    gs_Solved   : if not IsPassUser then MessageDlg('Unregistered user cannot save games', mtWarning, [mbOk], 0)
                  else if MessageDlg('Save solutions?', mtConfirmation, [mbYes, mbNo], 0) = mrYes
                  then begin SaveSolutionFile(Self.Caption,MainGame); CanClose:=True; end;
  end;
end;

procedure TMDIChild.FloatMenuUpdating(AGameState:Integer);
  procedure EnableEdit(IsEnabled:Boolean);
  var J:Integer;
  begin
    with FloatActList do
    if (ActionCount>=1) then
    for J:=ActionCount-1 downto 0
    do TAction(Actions[J]).Enabled:=IsEnabled;
  end;
begin
  case AGameState of
    gs_New,
    gs_Edited,
    gs_CanClose : begin EnableEdit(True); FConstraint.Enabled:=False; end;
    gs_Solved,
    gs_SavSol,
    gs_Solving   : begin EnableEdit(False); FConstraint.Enabled:=False; end;
    gs_Constraint : begin EnableEdit(False); FConstraint.Enabled:=True; end;
  end;
end;

{procedure TMDIChild.CommandEnable(ACase:Integer);
  procedure EnableEdit(IsEnabled:Boolean);
  var J:Integer;
  begin
    with FloatActList do
    if (ActionCount>=1) then
    for J:=ActionCount-1 downto 0
    do TAction(Actions[J]).Enabled:=IsEnabled;
  end;
begin
  case ACase of
    ce_Edit  : EnableEdit(True);
    ce_Solve : EnableEdit(False);
    ce_Solving : EnableEdit(False);
  end;
end;}

procedure TMDIChild.UpdateSolDisplay(HasProba,HasBelief,HasExpect:Boolean);
begin
  if MainSolution<>nil then begin
    MainSolution.SetDisplay(HasProba,HasBelief,HasExpect);
    Invalidate;
  end;
end;

procedure TMDIChild.ShowCells1Click(Sender: TObject);
begin
  with TStrat32(SelectedObject) do begin
    if TSide32(Source).FrontStrat<>nil
    then TSide32(Source).FrontStrat.SetInFront(False);
    SetInFront(True);
    TSide32(Source).OwnTable.RedoGraphics;
  end;
  Invalidate;
end;

function TMDIChild.CannotEdit:Boolean;
begin
  if MainGame.GameState in [gs_Solved,gs_SavSol]
  then begin
    CannotEdit:=True;
    MessageDlg('Solved game cannot be edited. Delete solutions first', mtInformation, [mbOK], 0);
  end else CannotEdit:=False;
end;

procedure TMDIChild.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  MainForm.ZoomOutAct.Execute;
end;

procedure TMDIChild.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  MainForm.ZoomInAct.Execute; 
end;

procedure TMDIChild.DeleteSelectClick(Sender: TObject);
begin
  {if CannotEdit then Exit;
  MainGame.DeleteSelection;
  Invalidate; }
  MainForm.DeleteSelectAct.Execute;
end;

procedure TMDIChild.CopySelectClick(Sender: TObject);
begin
  {if CannotEdit then Exit;
  MainGame.CopySelection;
  Invalidate;
  SetToDraw(True); }
  MainForm.AddSelectAct.Execute;
end;

procedure TMDIChild.RedrawCellClick(Sender: TObject);
begin
  if TCell32(SelectedObject).Upto=nil
  then MessageDlg('Non-final cell cannot be drawn', mtWarning, [mbOk], 0)
  else SetToDraw(True);
end;

{procedure TMDIChild.ResetConstraint(IsOn:Boolean);
begin
  MoveConstraint.Enabled:=IsOn;
  StratConstraint.Enabled:=IsOn;
end;}

procedure TMDIChild.MoveConstraintClick(Sender: TObject);
begin
  with SelectedObject do case ObjType of
    ot_Move  : begin
                 with TMove32(SelectedObject) do if (From.Owner=nil)
                 then MessageDlg('Chance moves cannot be constrained', mtWarning, [mbOk], 0)
                 else if (OwnChoice<>nil) then with OwnChoice do
                 if IsOff then SetOff(False) else SetOff(True);
               end;
    ot_Strat : with TStrat32(SelectedObject) do if IsOff
               then SetOff(False) else SetOff(True);
  end;
  Invalidate;
end;

end.

