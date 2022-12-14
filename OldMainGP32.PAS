{Copyright (c), Jean-Pierre P. Langlois, 2007-2022}

unit OldMainGP32;

{This defines the GamePlan desktop. It contains all menu and buttons for
 file operations, edit, and solving. It can contain several child windows,
 showing the game and its solutions.}

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, Menus,
  StdCtrls, Dialogs, Buttons, Messages, ExtCtrls, ComCtrls, StdActns,
  ActnList, ToolWin, ImgList, ChildWin, Printers, Spin, Registry, Utilities;

type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    FileNewItem: TMenuItem;
    FileOpenItem: TMenuItem;
    Help1: TMenuItem;
    N1: TMenuItem;
    FileExitItem: TMenuItem;
    HelpAboutItem: TMenuItem;
    OpenDialog: TOpenDialog;
    FileSaveItem: TMenuItem;
    FileSaveAsItem: TMenuItem;
    StatusBar: TStatusBar;
    GeneralActionList: TActionList;
    FileNew1: TAction;
    FileSave1: TAction;
    FileExit1: TAction;
    FileOpen1: TAction;
    FileSaveAs1: TAction;
    WindowCascade1: TWindowCascade;
    WindowTileHorizontal1: TWindowTileHorizontal;
    WindowArrangeAll1: TWindowArrange;
    WindowMinimizeAll1: TWindowMinimizeAll;
    HelpAbout1: TAction;
    FileClose1: TWindowClose;
    WindowTileVertical1: TWindowTileVertical;
    ToolBar2: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton9: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton11: TToolButton;
    ImageList1: TImageList;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    AddMenu: TMenuItem;
    AddPlayer: TMenuItem;
    AddNode: TMenuItem;
    EditMenu: TMenuItem;
    EditPlayer: TMenuItem;
    EditNode: TMenuItem;
    DeleteMenu: TMenuItem;
    SaveDialog: TSaveDialog;
    DeletePlayer: TMenuItem;
    DeleteNode: TMenuItem;
    AddMove: TMenuItem;
    EditMove: TMenuItem;
    DeleteMove: TMenuItem;
    Solution1: TMenuItem;
    Solve: TMenuItem;
    Audit: TMenuItem;
    Options: TMenuItem;
    Name1: TMenuItem;
    N2: TMenuItem;
    PrintDialog: TPrintDialog;
    PrintItem: TMenuItem;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    SolveBtn: TToolButton;
    ToolButton17: TToolButton;
    ViewSolutions: TToolButton;
    Show: TMenuItem;
    ReturnBtn: TToolButton;
    DeleteAll1: TMenuItem;
    EditActionList: TActionList;
    SolveActionList: TActionList;
    SolveAct: TAction;
    ReturnAct: TAction;
    ShowAct: TAction;
    AddPlayerAct: TAction;
    AddNodeAct: TAction;
    AddMoveAct: TAction;
    EditPlayerAct: TAction;
    EditNodeAct: TAction;
    EditMoveAct: TAction;
    DeletePlayerAct: TAction;
    DeleteNodeAct: TAction;
    DeleteMoveAct: TAction;
    Table1: TMenuItem;
    Info1: TMenuItem;
    Table2: TMenuItem;
    Table3: TMenuItem;
    Side1: TMenuItem;
    Side2: TMenuItem;
    Side3: TMenuItem;
    List1: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    ToolButton18: TToolButton;
    AddTableAct: TAction;
    EditTableAct: TAction;
    EditInfoAct: TAction;
    Display: TMenuItem;
    Export1: TMenuItem;
    AddSideAct: TAction;
    EditSideAct: TAction;
    DeleteSideAct: TAction;
    DeleteTableAct: TAction;
    ZoomOutAct: TAction;
    ZoomInAct: TAction;
    N7: TMenuItem;
    DeleteSelection: TMenuItem;
    N8: TMenuItem;
    AddSelection: TMenuItem;
    AddSelectAct: TAction;
    DeleteSelectAct: TAction;
    DisplayGrid: TMenuItem;
    Values1: TMenuItem;
    ProbaCheck: TMenuItem;
    BeliefCheck: TMenuItem;
    ExpectCheck: TMenuItem;
    Registration1: TMenuItem;
    SpinButton1: TSpinButton;
    Help2: TMenuItem;
    RegAction: TAction;
    ToolButton6: TToolButton;
    ToolButton10: TToolButton;
    ToolButton19: TToolButton;
    ConstraintCheck: TMenuItem;
    N9: TMenuItem;
    ToolButton20: TToolButton;
    ConstrainAct: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FileExitExecute(Sender: TObject);
    procedure FileNewExecute(Sender: TObject);
    procedure FileOpenExecute(Sender: TObject);
    procedure FileSaveItemClick(Sender: TObject);
    procedure HelpAboutExecute(Sender: TObject);
    procedure AddPlayerClick(Sender: TObject);
    procedure EditPlayerClick(Sender: TObject);
    procedure AddNodeClick(Sender: TObject);
    procedure DeletePlayerClick(Sender: TObject);
    procedure DeleteNodeClick(Sender: TObject);
    procedure EditNodeClick(Sender: TObject);
    procedure EditInfoClick(Sender: TObject);
    procedure AddMoveClick(Sender: TObject);
    procedure EditMoveClick(Sender: TObject);
    procedure DeleteMoveClick(Sender: TObject);
    procedure AddTableClick(Sender: TObject);
    procedure EditTableClick(Sender: TObject);
    procedure DeleteTableClick(Sender: TObject);
    procedure ConstrainSolve(Sender: TObject);
    procedure SolveClick(Sender: TObject);
    procedure ShowSolutionClick(Sender: TObject);
    procedure DeleteAllClick(Sender: TObject);
    procedure AuditClick(Sender: TObject);
    procedure OptionsClick(Sender: TObject);
    procedure NameGameClick(Sender: TObject);
    procedure PrintClick(Sender: TObject);
    procedure DebugClick(Sender: TObject);
    procedure DebugShowClick(Sender: TObject);
    procedure AddSideClick(Sender: TObject);
    procedure EditSideClick(Sender: TObject);
    procedure DeleteSideClick(Sender: TObject);
    procedure ListGame(Sender: TObject);
    procedure Export1Click(Sender: TObject);
    procedure FileSaveAsItemClick(Sender: TObject);
    procedure In1Click(Sender: TObject);
    procedure Out1Click(Sender: TObject);
    procedure DeleteSelectionClick(Sender: TObject);
    procedure AddSelectionClick(Sender: TObject);
    procedure DisplayGridClick(Sender: TObject);
    procedure ProbaCheckClick(Sender: TObject);
    procedure BeliefCheckClick(Sender: TObject);
    procedure ExpectCheckClick(Sender: TObject);
    procedure Registration1Click(Sender: TObject);
    procedure Help2Click(Sender: TObject);
    procedure ViewPass1Click(Sender: TObject);
  private
    procedure CheckPass;
    procedure CheckUser;
  public
    procedure CreateMDIChild(AName:string;AWindowCase:Integer;AGame,ASolution:Pointer);
    function ActiveChild : TMDIChild;
    function AuditWindow(AGame:Pointer): TMDIChild;
    function DebugWindow(AGame,ASolution:Pointer): TMDIChild;
    function GameWindow(AGame:Pointer): TMDIChild;
    procedure OpenProfileWindow(AName:string;AGame,AProfile:Pointer);
    procedure OpenSolutionWindow(AName:string;AGame,ASolution:Pointer);
    procedure CloseSolutionWindow(AGame,ASolution:Pointer);
    procedure MenuUpdating(AGameState:Integer);
    procedure EnableSelect(IsEnabled:Boolean);
    procedure DoSolve;
    procedure MakeGameAudit(ForWhat:Integer);
    procedure SaveGame(AFile:String;AGame:Pointer);
    {procedure CommandEnabling(SolveEditCase:Integer); }
    procedure UpdateChildrenDisplay;
  end;

var
  MainForm: TMainForm;

implementation

uses  About, SelectDlg, EditNode, EditMove, EditPlayer, Constants,
      Type32, File32, Game32Type, Game32Solve, Solve32, AuditUnit, SolvOptDlg, Name,
      EditInfo, EditTable, EditSide, ShellAPI, Registration, PassUnit,
  ViewPass;

{$R *.DFM}

procedure TMainForm.OpenSolutionWindow(AName:string;AGame,ASolution:Pointer);
begin
  CreateMDIChild(AName,wc_Solution,AGame,ASolution);
  Cascade;
end;

procedure TMainForm.OpenProfileWindow(AName:string;AGame,AProfile:Pointer);
begin
  CreateMDIChild(AName,wc_Profile,AGame,AProfile);
  Cascade;
end;

procedure TMainForm.CloseSolutionWindow(AGame,ASolution:Pointer);
var I:Integer; AChild:TMDIChild;
begin
  for I:=MDIChildCount-1 downto 0 do begin
    AChild:=TMDIChild(MDIChildren[I]);
    with AChild do
    if (MainGame=TGameType32(AGame))
    and (WindowCase<>wc_MainGame)
    then if (ASolution=nil)
         or (MainSolution=ASolution)
         then Close;
  end;
end;

procedure TMainForm.DeleteAllClick(Sender: TObject);
begin
  MenuUpdating(gs_CanClose);
  if ActiveMDIChild=nil then Exit;
  with ActiveChild do
  if (MainGame<>nil) then begin
    CloseSolutionWindow(MainGame,nil);
    MainGame.ReturnToEdit;
    {MenuUpdating(gs_Edited);
    {CommandEnabling(ce_Edit); }
    FileSave(GameWindow(MainGame).Caption,MainGame);
    {CommandEnable(ce_Edit); }
  end;
  SolveDlg.Hide;
end;

function TMainForm.GameWindow(AGame:Pointer): TMDIChild;
var I:Integer; AChild:TMDIChild;
begin
  GameWindow:=nil;
  for I:=MDIChildCount-1 downto 0 do begin
    AChild:=TMDIChild(MDIChildren[I]);
    with AChild do
    if (MainGame=TGameType32(AGame))
    and (WindowCase=wc_MainGame)
    then GameWindow:=AChild;
  end;
end;

function TMainForm.ActiveChild : TMDIChild;
begin
  if ActiveMDIChild=nil
  then CreateMDIChild('New Game',wc_MainGame,nil,nil);
  ActiveChild:=TMDIChild(ActiveMDIChild)
end;

procedure TMainForm.CreateMDIChild(AName:string;AWindowCase:Integer;AGame,ASolution:Pointer);
var NewChild: TMDIChild;
begin  { create a new MDI child window }
  NewChild := TMDIChild.Create(Application);
  with NewChild do begin
    WindowState:=wsMaximized;
    WindowCase:=AWindowCase;
    Caption := AName;
    case WindowCase of
      wc_MainGame: begin MainGame:=TGameType32.Create;MainSolution:=nil;MainProfile:=nil;
                         if MainGame.GameState in [gs_Solved,gs_SavSol]
                         then {CommandEnabling(ce_Solve)}MenuUpdating(gs_Solved) else {CommandEnabling(ce_Edit)}MenuUpdating(gs_Edited); end;
      wc_Solution: begin MainGame:=TGameType32(AGame);MainSolution:=ASolution;
                         MainProfile:=nil;MenuUpdating(gs_Solved){CommandEnabling(ce_Solve)};UpdateChildrenDisplay; end;
      wc_Profile : begin MainGame:=TGameType32(AGame);MainSolution:=nil;
                         MainProfile:=ASolution;MainProfile.FillBitList;end;
      wc_Audit   : begin MainGame:=TGameType32(AGame);MainSolution:=nil;
                         MainProfile:=nil;end;
      wc_Debug   : begin MainGame:=TGameType32(AGame);MainSolution:=ASolution;
                         MainProfile:=nil;end;
    end;
    if WindowCase in [wc_Audit,wc_Debug] then AuditList:=TGameList.Create else AuditList:=nil;
    EnableSelect(False);
    ResetDisplay;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var SplashAbout:TAboutBox;
begin
  CheckUser;
  SplashAbout:=TAboutBox.Create(Application);
  try
    SplashAbout.MakeSplash;
    SplashAbout.Delay;
    SplashAbout.Close;
  finally
    SplashAbout.Free;
  end;
  WindowState:=wsMaximized;
  ZoomSize:=1.0;
  DisplayGrid.Checked:=False;
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
  SolveDlg.Hide;
  SolveOptionsDlg.InitSolveOptions;
  if ParamCount>0 then begin
    CreateMDIChild(ParamStr(1),wc_MainGame,nil,nil);
    FileOpen(ParamStr(1),ActiveChild.MainGame);
    ActiveChild.ResetDisplay;
    MenuUpdating(ActiveChild.MainGame.GameState);

    {if ActiveChild.MainGame.GameState in [gs_Solved,gs_SavSol] then CommandEnabling(ce_Solve);  }
  end;
end;

procedure TMainForm.FileExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.FileNewExecute(Sender: TObject);
begin
  CreateMDIChild('New Game',wc_MainGame,nil,nil);
  ActiveChild.MainGame.SetState(gs_New);
end;

procedure TMainForm.FileOpenExecute(Sender: TObject);
begin
  if OpenDialog.Execute
  then begin
    CreateMDIChild(OpenDialog.FileName,wc_MainGame,nil,nil);
    FileOpen(OpenDialog.FileName,ActiveChild.MainGame);
    ActiveChild.ResetDisplay;
    MenuUpdating(ActiveChild.MainGame.GameState);

    {if ActiveChild.MainGame.GameState in [gs_Solved,gs_SavSol] then CommandEnabling(ce_Solve);}
  end;
end;

procedure TMainForm.SaveGame(AFile:String;AGame:Pointer);
var TrueGame:TGameType32;
begin
  if IsPassUser then begin
  TrueGame:=TGameType32(AGame);
  if (TrueGame.GameState in [gs_SavSol,gs_Solved])
  then if (MessageDlg('Save with solutions?', mtConfirmation, [mbYes, mbNo], 0)=mrYes)
       then begin
         FileSave(AFile,TrueGame);
         SaveSolutionFile(AFile,TrueGame);
       end else ReturnAct.Execute;
  if (TrueGame.GameState in [gs_New,gs_Edited,gs_CanClose])
  then FileSave(AFile,TrueGame);
  end else MessageDlg('Unregistered user cannot save games', mtWarning, [mbOk], 0)
end;

procedure TMainForm.FileSaveItemClick(Sender: TObject);
begin
  if ActiveMDIChild=nil then Exit;
  if ActiveChild.MainGame.GameState=gs_New then FileSaveAs1.Execute
  else with GameWindow(ActiveChild.MainGame) do SaveGame(Caption,MainGame);
end;

procedure TMainForm.FileSaveAsItemClick(Sender: TObject);
begin
  with SaveDialog do
  begin
    Filename := '';
    if Execute then
      if ofExtensionDifferent in Options
      then MessageDlg ('Not a gpx extension', mtWarning, [mbOK], 0)
      else begin
        SaveGame(FileName,ActiveChild.MainGame);
        GameWindow(ActiveChild.MainGame).SetCaption(FileName);
      end;
  end;
end;

procedure TMainForm.HelpAboutExecute(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

procedure TMainForm.AddPlayerClick(Sender: TObject);
begin
  if ActiveChild.CannotEdit then Exit;
  with PlayerDlg do begin
    InitDialog(nil,ActiveChild.MainGame);
    if ShowModal = mrOK
    then with ActiveChild do begin
      SelectedObject:=TPlayer32.Create(MainGame);
      SelectedObject.Assign(DlgPlayer);
      MainGame.DispatchObject(SelectedObject);
      MainGame.SetState(gs_Edited);
      SetToDraw(True);
    end;
  end;
end;

procedure TMainForm.DeletePlayerClick(Sender: TObject);
begin
  if ActiveChild.CannotEdit then Exit;
  with ActiveChild do begin
    with SelectDialog do begin
      InitDialog(MainGame.PlayerList,0);
      if (SelIndex>=0)
      then if not PlayerDelete(MainGame.PlayerList.Items[SelIndex],MainGame)
           then MessageDlg('Player owns nodes or sides.', mtWarning, [mbOk], 0);
    end;
    Invalidate;
  end;
end;

procedure TMainForm.EditPlayerClick(Sender: TObject);
begin
  if ActiveChild.CannotEdit then Exit;
  with SelectDialog do begin
    InitDialog(ActiveChild.MainGame.PlayerList,0);
    if SelIndex>=0 then with ActiveChild do begin
      SelectedObject:=MainGame.PlayerList.Items[SelIndex];
      PlayerEdit(TPlayer32(SelectedObject),MainGame);
      Invalidate;
    end;
  end;
end;

procedure TMainForm.AddTableClick(Sender: TObject);
begin
  if ActiveChild.CannotEdit then Exit;
  with ActiveChild do
  with NameDlg do begin
    SelectedObject:=TTable32.Create(MainGame);
    InitDialog('New Table',SelectedObject,ActiveChild.MainGame);
    if ShowModal = mrOK
    then begin
      MainGame.DispatchObject(SelectedObject);
      MainGame.SetState(gs_Edited);
      TTable32(SelectedObject).RedoGraphics;
      SetToDraw(True);
    end else begin
      SelectedObject.Free;
      SelectedObject:=nil;
    end;
  end;
end;

procedure TMainForm.EditTableClick(Sender: TObject);
begin
  if ActiveChild.CannotEdit then Exit;
  with ActiveChild do begin
    with SelectDialog do begin
      InitDialog(ActiveChild.MainGame.NodeList,ot_Table);
      case SelIndex of
       -2: MessageDlg('No defined table', mtWarning, [mbOk], 0);
       -1: SelectedObject:=nil;
       else SelectedObject:=MainGame.NodeList.Items[SelIndex];
      end;
    end;
    if SelectedObject<>nil then with NameDlg do begin
      InitDialog('Edit Table',SelectedObject,ActiveChild.MainGame);
      if ShowModal=mrOK then MainGame.SetState(gs_Edited);
    end;
    Invalidate;
  end;
end;

procedure TMainForm.DeleteTableClick(Sender: TObject);
begin
  if ActiveChild.CannotEdit then Exit;
  with ActiveChild do begin
    with SelectDialog do begin
      InitDialog(ActiveChild.MainGame.NodeList,ot_Table);
      case SelIndex of
       -2: MessageDlg('No defined table', mtWarning, [mbOk], 0);
       -1: SelectedObject:=nil;
       else SelectedObject:=MainGame.NodeList.Items[SelIndex];
      end;
    end;
    if SelectedObject<>nil then begin
      MainGame.NodeList.Remove(SelectedObject);
      MainGame.SetState(gs_Edited);
      SelectedObject.Free;
    end;
    Invalidate;
  end;
end;

procedure TMainForm.AddSideClick(Sender: TObject);
var ATable: TTable32;
begin
  if ActiveChild.CannotEdit then Exit;
  with ActiveChild do begin
    with SelectDialog do begin
      InitDialog(ActiveChild.MainGame.NodeList,ot_Table);
      case SelIndex of
       -2: MessageDlg('No defined table', mtWarning, [mbOk], 0);
       -1: SelectedObject:=nil;
       else SelectedObject:=MainGame.NodeList.Items[SelIndex];
      end;
    end;
    if SelectedObject<>nil then begin
      ATable:=TTable32(SelectedObject);
      if SideDlg.FillOwnerList(ATable) {Check there are possible owners}
      then begin
        SideEdit(nil,ATable,MainGame); {Redo cells?}
        ATable.RedoGraphics;
      end else MessageDlg('Need additional players', mtWarning, [mbOk], 0);
    end;
    Invalidate;
  end;
end;

procedure TMainForm.DeleteSideClick(Sender: TObject);
var ATable: TTable32; ASide: TSide32;
begin
  if ActiveChild.CannotEdit then Exit;
  with ActiveChild do begin

    with SelectDialog do begin
      InitDialog(ActiveChild.MainGame.InfoList,ot_Side);
      case SelIndex of
       -2: MessageDlg('No defined side', mtWarning, [mbOk], 0);
       -1: SelectedObject:=nil;
       else SelectedObject:=MainGame.InfoList.Items[SelIndex];
      end;
    end;
    if SelectedObject<>nil then begin
      ASide:=TSide32(SelectedObject);
      ATable:=ASide.OwnTable;
      ATable.DeleteSide(ASide);
      ATable.RedoGraphics;
    end;

    {with SelectDialog do begin
      InitDialog(ActiveChild.MainGame.NodeList,ot_Table);
      case SelIndex of
       -2: MessageDlg('No defined table', mtWarning, [mbOk], 0);
       -1: SelectedObject:=nil;
       else SelectedObject:=MainGame.NodeList.Items[SelIndex];
      end;
    end;
    if SelectedObject<>nil then begin
      ATable:=TTable32(SelectedObject);
      if ATable.Sides.Count>0
      then with SelectDialog do begin
        InitDialog(ATable.Sides,0);
        if SelIndex>=0
        then with ATable do begin
          ASide:=Sides[SelIndex];
          DeleteSide(ASide);
          MainGame.SetState(gs_Edited);
          SidesToCell;
          RedoGraphics;
        end;
      end else MessageDlg('Table has no defined sides', mtWarning, [mbOk], 0);
    end;   }
    Invalidate;
  end;
end;

procedure TMainForm.EditSideClick(Sender: TObject);
var {ATable: TTable32;} ASide: TSide32;
begin
  if ActiveChild.CannotEdit then Exit;
  with ActiveChild do begin


    {with SelectDialog do begin
      InitDialog(ActiveChild.MainGame.NodeList,ot_Table);
      case SelIndex of
       -2: MessageDlg('No defined table', mtWarning, [mbOk], 0);
       -1: SelectedObject:=nil;
       else SelectedObject:=MainGame.NodeList.Items[SelIndex];
      end;
    end;
    if SelectedObject<>nil then begin
      ATable:=TTable32(SelectedObject);
      if ATable.Sides.Count>0
      then with SelectDialog do begin
        InitDialog(ATable.Sides,0);
        if SelIndex>=0
        then begin
          ASide:=ATable.Sides[SelIndex];
          SideEdit(ASide,ATable,MainGame);
          ATable.RedoGraphics;
        end;
      end else MessageDlg('Table has no defined sides', mtWarning, [mbOk], 0);
    end; }
    with SelectDialog do begin
      InitDialog(ActiveChild.MainGame.InfoList,ot_Side);
      case SelIndex of
       -2: MessageDlg('No defined side', mtWarning, [mbOk], 0);
       -1: SelectedObject:=nil;
       else SelectedObject:=MainGame.InfoList.Items[SelIndex];
      end;
    end;
    if SelectedObject<>nil then begin
      ASide:=TSide32(SelectedObject);
      SideEdit(ASide,ASide.OwnTable,MainGame);
      Aside.OwnTable.RedoGraphics;
    end;


      {ATable:=TTable32(SelectedObject);
      if ATable.Sides.Count>0
      then with SelectDialog do begin
        InitDialog(ATable.Sides,0);
        if SelIndex>=0
        then begin
          ASide:=ATable.Sides[SelIndex];
          SideEdit(ASide,ATable,MainGame);
          ATable.RedoGraphics;
        end;
      end else MessageDlg('Table has no defined sides', mtWarning, [mbOk], 0); }


    Invalidate;
  end; 
end;

procedure TMainForm.AddNodeClick(Sender: TObject);
begin
  if ActiveChild.CannotEdit then Exit;
  with NodeDlg do begin
    InitDialog(nil,ActiveChild.MainGame);
    if ShowModal = mrOK
    then with ActiveChild do begin
      SelectedObject:=TNode32.Create(MainGame);
      MainGame.DispatchObject(SelectedObject);
      MainGame.SetState(gs_Edited);
      SelectedObject.Assign(DlgNode);
      SetToDraw(True);
    end;
  end;
end;

procedure TMainForm.DeleteNodeClick(Sender: TObject);
begin
  if ActiveChild.CannotEdit then Exit;
  with ActiveChild do begin
    with SelectDialog do begin
      InitDialog(MainGame.NodeList,ot_Node);
      if (SelIndex>=0)
      then if not NodeDelete(MainGame.NodeList.Items[SelIndex],MainGame)
           then MessageDlg('Node owns moves or belongs to information set.', mtWarning, [mbOk], 0);
    end;
    Invalidate;
  end;
end;

procedure TMainForm.EditNodeClick(Sender: TObject);
begin
  if ActiveChild.CannotEdit then Exit;
  with SelectDialog do begin
    InitDialog(ActiveChild.MainGame.NodeList,ot_Node);
    if SelIndex>=0 then with ActiveChild do begin
      SelectedObject:=MainGame.NodeList.Items[SelIndex];
      NodeEdit(TNode32(SelectedObject),MainGame);
      Invalidate;
    end;
  end;
end;

procedure TMainForm.EditInfoClick(Sender: TObject);
var AnInfo:TInfo32; AFirstNode:TNode32;
begin
  if ActiveChild.CannotEdit then Exit;
  with SelectDialog do begin
    InitDialog(ActiveChild.MainGame.InfoList,ot_Info);
    if SelIndex>=0 then with ActiveChild do begin
      SelectedObject:=MainGame.InfoList.Items[SelIndex];
      AnInfo:=TInfo32(SelectedObject);
      AFirstNode:=nil;
      AFirstNode:=AnInfo.Events.Items[0];
      if AFirstNode<>nil
      then with InfoDlg do begin
        if InitDialog(AFirstNode)
        then ShowModal
      end;

      {if (TNode32(SelectedObject).Owner=nil)
      then MessageDlg('Chance nodes cannot be in an information set.', mtInformation, [mbOk], 0)
      else with InfoDlg do begin
        if InitDialog(TNode32(SelectedObject))
        then ShowModal
        else MessageDlg('All other nodes have a different owner or already belong to an information set.', mtInformation, [mbOk], 0);
      end; }

    Invalidate;
    end;
  end;
end;

procedure TMainForm.AddMoveClick(Sender: TObject);
begin
  if ActiveChild.CannotEdit then Exit;
  with MoveDlg do begin
    InitDialog(nil,ActiveChild.MainGame);
    if ShowModal = mrOK
    then with ActiveChild do begin
      SelectedObject:=TMove32.Create(MainGame);
      SelectedObject.Assign(DlgMove);
      DlgMove.DeletePayments; {To avoid duplicate payoffs in Game}
      MainGame.DispatchObject(SelectedObject);
      MainGame.SetState(gs_Edited);
      SetToDraw(True);
    end;
  end;
end;

procedure TMainForm.EditMoveClick(Sender: TObject);
begin
  if ActiveChild.CannotEdit then Exit;
  with SelectDialog do begin
    InitDialog(ActiveChild.MainGame.MoveList,ot_Move);
    if SelIndex>=0 then with ActiveChild do begin
      SelectedObject:=MainGame.MoveList.Items[SelIndex];
      {MoveEdit(TMove32(SelectedObject),MainGame);   }
      if MoveEdit(TMove32(SelectedObject),MainGame) then begin
        SetToDraw(True);
        Invalidate;
      end;
      {Invalidate;}
    end;
  end;
end;

procedure TMainForm.DeleteMoveClick(Sender: TObject);
begin
  if ActiveChild.CannotEdit then Exit;
  with ActiveChild do begin
    with SelectDialog do begin
      InitDialog(MainGame.MoveList,ot_Move);
      if (SelIndex>=0)
      then MoveDelete(MainGame.MoveList.Items[SelIndex],MainGame);
    end;
    Invalidate;
  end;
end;

function TMainForm.AuditWindow(AGame:Pointer): TMDIChild;
var I:Integer; TheWindow,AChild:TMDIChild;
begin
  TheWindow:=nil;
  for I:=MDIChildCount-1 downto 0 do begin
    AChild:=TMDIChild(MDIChildren[I]);
    with AChild do
    if (MainGame=TGameType32(AGame))
    and (WindowCase=wc_Audit)
    then TheWindow:=AChild;
  end;
  if TheWindow<>nil then AuditWindow:=TheWindow
  else begin
    CreateMDIChild('Audit',wc_Audit,AGame,nil);
    AuditWindow:=TMDIChild(ActiveMDIChild)
  end;
end;

function TMainForm.DebugWindow(AGame,ASolution:Pointer): TMDIChild;
var I:Integer; TheWindow,AChild:TMDIChild;
begin
  TheWindow:=nil;
  for I:=MDIChildCount-1 downto 0 do begin
    AChild:=TMDIChild(MDIChildren[I]);
    with AChild do
    if (MainGame=TGameType32(AGame))
    and (MainSolution=TSolution32(ASolution))
    and (WindowCase=wc_Debug)
    then TheWindow:=AChild;
  end;
  if TheWindow<>nil then DebugWindow:=TheWindow
  else begin
    CreateMDIChild('Debug '+TSolution32(ASolution).Name,wc_Debug,AGame,ASolution);
    DebugWindow:=TMDIChild(ActiveMDIChild)
  end;
end;

procedure TMainForm.MakeGameAudit(ForWhat:Integer);
var AuditWin: TMDIChild;
begin
  with ActiveChild do begin
    AuditWin:=AuditWindow(MainGame);
    AuditWin.MakeAudit(ForWhat);
  end;
  Cascade;
end;

procedure TMainForm.AuditClick(Sender: TObject);
begin
  if ActiveMDIChild=nil then Exit
  else with ActiveChild do begin
    if MainGame.CheckGame
    then MakeGameAudit(fw_ObjList)
    else MakeGameAudit(fw_Bugs);
    MainGame.ReturnToEdit;
  end;
end;

procedure TMainForm.DebugShowClick(Sender: TObject);
var DebugWin: TMDIChild;
begin
  if ActiveMDIChild=nil then Exit
  else with ActiveChild
  do if (MainSolution<>nil)
     then begin
       DebugWin:=DebugWindow(MainGame,MainSolution);
       DebugWin.MakeAudit(fw_Debug);
     end;
  Cascade;
end;

procedure TMainForm.ListGame(Sender: TObject);
begin
  MakeGameAudit(fw_ObjList);
end;

procedure TMainForm.ConstrainSolve(Sender: TObject);
begin
  if ActiveMDIChild=nil then Exit;
  if (ActiveChild.WindowCase<>wc_MainGame) then Exit;
  if SolveDlg.IsBusy then Exit;
  with ActiveChild do
  if ReadyToSolve
  then begin
    MenuUpdating(gs_Constraint);
    MainGame.SetState(gs_Constraint);
  end;
  ActiveChild.Invalidate;
end;

procedure TMainForm.DoSolve;
begin
    with SolveDlg do begin
      Show;
      InitDialog(sd_Solving,ActiveChild.MainGame);
    end;
end;

procedure TMainForm.SolveClick(Sender: TObject);
begin {Open solve dialog}
  if ActiveMDIChild=nil then Exit;
  if (ActiveChild.WindowCase<>wc_MainGame) then Exit;
  if SolveDlg.IsBusy then Exit;
  if (ActiveChild.MainGame.GameState=gs_Constraint)
  then DoSolve
  else with ActiveChild do
  if ReadyToSolve then begin
    MenuUpdating(gs_Solving);
    MainGame.SetState(gs_Solving);
    DoSolve;
  end;
  ActiveChild.Invalidate;
end;

procedure TMainForm.ShowSolutionClick(Sender: TObject);
begin
  if ActiveMDIChild=nil then Exit;
  with ActiveChild do if MainGame.SolutionList.Count>0
  then with SolveDlg do begin
    Show;
    InitDialog(sd_Display,MainGame);
  end;
end;

procedure TMainForm.OptionsClick(Sender: TObject);
begin
  SolveOptionsDlg.ShowModal;
end;

procedure TMainForm.NameGameClick(Sender: TObject);
begin
  if ActiveChild.CannotEdit then Exit;
  with NameDlg do begin
    InitDialog('Game name',ActiveChild.MainGame.GameHeader,nil);
    if ShowModal=mrOK then ActiveChild.MainGame.SetState(gs_Edited);
  end;
  ActiveChild.Invalidate;
end;

procedure TMainForm.PrintClick(Sender: TObject);
begin
  Printer.Orientation:=poLandscape;
  if PrintDialog.Execute
  then with ActiveChild do begin
    if WindowCase=wc_Audit
    then Printer.Orientation:=poPortrait
    else Printer.Orientation:=poLandscape;
    PrintScale:=poPrintToFit;
    Print;
  end;
end;

procedure TMainForm.DebugClick(Sender: TObject);
begin
  {if IsDebug then begin
    IsDebug:=False;
    Debug.Checked:=False;
  end else begin
    IsDebug:=True;
    Debug.Checked:=True;
  end; }
end;

procedure TMainForm.MenuUpdating(AGameState:Integer);
  procedure EnableEdit(IsEnabled:Boolean);
  var J:Integer;
  begin
    with EditActionList do
    if (ActionCount>=1) then
    for J:=ActionCount-1 downto 0
    do TAction(Actions[J]).Enabled:=IsEnabled;
  end;
  procedure EnableSolve(IsEnabled:Boolean);
  begin
    ConstrainAct.Enabled:=IsEnabled;
    SolveAct.Enabled:=IsEnabled;
    ReturnAct.Enabled:=not IsEnabled;
    ShowAct.Enabled:=not IsEnabled;
  end;
begin
  EnableSelect(False);
  ActiveChild.FloatMenuUpdating(AGameState);
  case AGameState of
    gs_New,
    gs_Edited,
    gs_CanClose : begin EnableEdit(True);EnableSolve(True); end;
    gs_Solved,
    gs_SavSol,
    gs_Solving  : begin EnableEdit(False);EnableSolve(False); end;
    gs_Constraint : begin EnableEdit(False);EnableSolve(True);
                          SolveAct.Enabled:=True; ConstrainAct.Enabled:=False;end;
  end;
end;

procedure TMainForm.EnableSelect(IsEnabled:Boolean);
begin
    DeleteSelectAct.Enabled:=IsEnabled;
    AddSelectAct.Enabled:=IsEnabled;
end;

{procedure TMainForm.CommandEnabling(SolveEditCase:Integer);
  procedure EnableEdit(IsEnabled:Boolean);
  var J:Integer;
  begin
    with EditActionList do
    if (ActionCount>=1) then
    for J:=ActionCount-1 downto 0
    do TAction(Actions[J]).Enabled:=IsEnabled;
  end;
  procedure EnableSolve(IsEnabled:Boolean);
  begin
    SolveAct.Enabled:=IsEnabled;
    ReturnAct.Enabled:=not IsEnabled;
    ShowAct.Enabled:=not IsEnabled;
  end;
  procedure EnableSelect(IsEnabled:Boolean);
  begin
    DeleteSelectAct.Enabled:=IsEnabled;
    AddSelectAct.Enabled:=IsEnabled;
  end;
begin
  case SolveEditCase of
    ce_Edit  : begin EnableEdit(True);EnableSolve(True);EnableSelect(False);ActiveChild.CommandEnable(ce_Edit); end;
    ce_Solve : begin EnableEdit(False);EnableSolve(False);EnableSelect(False);ActiveChild.CommandEnable(ce_Solve); end;
    ce_Slct  : EnableSelect(True);
    ce_UnSlct: EnableSelect(False);
  end;
end; }

procedure TMainForm.Export1Click(Sender: TObject);
var IsExported : Boolean;
begin
  IsExported:=True;
  with ActiveChild do begin
    BMPGraph:=TBitmap.Create;
    BMPGraph.Width := MainGame.XDim;
    BMPGraph.Height := MainGame.YDim;
    MainGame.DrawGame(BMPGraph.Canvas);
    if MainSolution<>nil then MainSolution.DrawObject(BMPGraph.Canvas);
    try BMPGraph.SaveToFile(BMPFile) except on Exception do IsExported:=False; end;
    BMPGraph.Free;
    if IsExported then ShellExecute(Handle,'open',PChar('mspaint.exe'),BMPFile , nil, SW_SHOW) ;
  end;

end;

procedure TMainForm.In1Click(Sender: TObject);
begin
  ZoomSize:=ZoomSize+ZoomStep;
  if ZoomSize>=MaxZoom then ZoomSize:=MaxZoom;
  ActiveChild.ResetDisplay;
  ActiveChild.Invalidate;
end;

procedure TMainForm.Out1Click(Sender: TObject);
begin
  ZoomSize:=ZoomSize-ZoomStep;
  if ZoomSize<=MinZoom then ZoomSize:=MinZoom;
  ActiveChild.ResetDisplay;
  ActiveChild.Invalidate;
end;

procedure TMainForm.DeleteSelectionClick(Sender: TObject);
begin
  with ActiveChild do if not CannotEdit then begin
    MainGame.DeleteSelection;
    EnableSelect(False);
    {CommandEnabling(ce_UnSlct); }
    Invalidate;
  end;
end;

procedure TMainForm.AddSelectionClick(Sender: TObject);
begin
  with ActiveChild do if not CannotEdit then begin
    MainGame.CopySelection;
    SelectedObject:=MainGame.SelRect;
    EnableSelect(False);
    {CommandEnabling(ce_UnSlct); }
    Invalidate;
    SetToDraw(True);
  end;
end;

procedure TMainForm.DisplayGridClick(Sender: TObject);
begin
  with DisplayGrid do if Checked then Checked:=False else Checked:=True;
  ActiveChild.Invalidate;
end;

procedure TMainForm.ProbaCheckClick(Sender: TObject);
begin
  with ProbaCheck do if Checked then Checked:=False else Checked:=True;
  UpdateChildrenDisplay;
  ActiveChild.Invalidate;
end;

procedure TMainForm.BeliefCheckClick(Sender: TObject);
begin
  with BeliefCheck do if Checked then Checked:=False else Checked:=True;
  UpdateChildrenDisplay;
  ActiveChild.Invalidate;
end;

procedure TMainForm.ExpectCheckClick(Sender: TObject);
begin
  with ExpectCheck do if Checked then Checked:=False else Checked:=True;
  UpdateChildrenDisplay;
  ActiveChild.Invalidate;
end;

procedure TMainForm.UpdateChildrenDisplay;
var I:Integer;
begin
  for I:=MDIChildCount-1 downto 0 do
    TMDIChild(MDIChildren[I]).UpdateSolDisplay(ProbaCheck.Checked,BeliefCheck.Checked,ExpectCheck.Checked);
end;

procedure TMainForm.CheckPass;
begin
  if IsRegUser and (Password=MakePass(Serial))
  then begin
    IsPassUser:=True;
    Registration1.Enabled:=False; {Dim that menu item}
  end else begin
    IsPassUser:=False;
    Registration1.Enabled:=True;
  end;
end;

procedure TMainForm.CheckUser;
var Reg:TRegistry; EC1,EC2:Integer;
begin
  IsRegUser:=False;
  Reg:=TRegistry.Create;
  Reg.RootKey:=HKEY_CURRENT_USER;
  if Reg.KeyExists('\Software\GameTheorySoftware\GamePlan32')
  then begin
    Reg.OpenKey('\Software\GameTheorySoftware\GamePlan32',False);
    UserName:=Reg.ReadString('UserName');
    UserReg:=Reg.ReadString('UserID');
    Val(UserReg,Serial,EC1);
    UserPass:=Reg.ReadString('Password');
    Val(UserPass,PassWord,EC2);
    if (EC1=0) and (EC2=0) and (Serial<>0)
    then begin
      IsRegUser:=True;
      CheckPass;
    end;
  end else MessageDlg('Cannot find GamePlan registry key',mtWarning,[mbOk],0);
  Reg.Free;
end;

procedure TMainForm.Registration1Click(Sender: TObject);
var MailText:String; Reg:TRegistry;
begin
  if IsPassUser then Exit;
  Reg:=TRegistry.Create;
  Reg.RootKey:=HKEY_CURRENT_USER;
  if not Reg.KeyExists('\Software\GameTheorySoftware\GamePlan32')
  then MessageDlg('Cannot find GamePlan registry key',mtWarning,[mbOk],0)
  else begin
    Reg.OpenKey('\Software\GameTheorySoftware\GamePlan32',False);
    if not IsRegUser then begin
      RegistrationForm.ShowModal;
      if (Serial<>0)
      then begin
        Reg.WriteString('UserName',UserName);
        Reg.WriteString('UserID',UserReg); {Serial number}
        IsRegUser:=True;
      end;
    end;
    if IsRegUser
    then if PassForm.ShowModal=mrOk
         then begin
           CheckPass;
           if IsPassUser then begin
             Reg.WriteString('Password',UserPass);
             AboutBox.ShowModal;
           end else MessageDlg('Incorrect password', mtWarning, [mbOk], 0);
         end else begin
           MailText:='mailto: mailbox.gameplan@verizon.net?subject=GP32 Password for '+UserName+'&body=Serial#'+MyIntToStr(Serial);
           ShellExecute(0,'open',PChar(MailText), NIL, NIL, SW_SHOWNORMAL);
         end;
  end;
  Reg.Free;
end;

procedure TMainForm.Help2Click(Sender: TObject);
begin
  {ShellExecute(Handle, 'open', 'http://www.gametheorysoftware.net/documentation/3.2/',nil,nil, SW_SHOWNORMAL) ;  }
  ShellExecute(Handle, 'open', PChar(ExtractFilePath(Application.ExeName)+'GameHelp.chm'),nil,nil, SW_SHOWNORMAL) ;
end;

procedure TMainForm.ViewPass1Click(Sender: TObject);
begin
  ViewPassForm.ShowModal;
end;

end.
