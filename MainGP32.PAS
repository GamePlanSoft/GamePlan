unit MainGP32;

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
    N6: TMenuItem;
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
    Debug: TMenuItem;
    AuditAct: TAction;
    OptionAct: TAction;
    ViewPass1: TMenuItem;
    CloseAll1: TMenuItem;
    CloseAllAct: TAction;
    CloseSolutions: TToolButton;
    ShowDebug: TMenuItem;
    ShowTest1: TMenuItem;
    N9: TMenuItem;
    UndoEditAct: TAction;
    Undo1: TMenuItem;
    AutoSave1: TAction;
    //procedure ResetAutoSave(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FileExitExecute(Sender: TObject);
    procedure FileNewExecute(Sender: TObject);
    procedure FileOpenExecute(Sender: TObject);
    (*procedure FileRestoreExecute(Sender: TObject);  *)
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
    procedure SolveClick(Sender: TObject);
    procedure ShowSolutionClick(Sender: TObject);
    procedure CloseAllClick(Sender: TObject);
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
    procedure UndoEditClick(Sender: TObject);
    procedure Backup;
    procedure SaveGame(AFile:String;AGame:Pointer);

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
    procedure ShowTest1Click(Sender: TObject);
  private
    procedure DoSolve;
    procedure MakeGameAudit(ForWhat:Integer);
    procedure CheckPass;
    procedure UpdatePass;
    procedure CheckRegistry;
    procedure WriteRegistration;
    {procedure InitRegistration; }
    function DaysLeft(IsTrial:Boolean):Integer;
    function CanReadRegistry:Boolean;
    function BypassRegistry:Boolean;
  public
    procedure CreateMDIChild(AName:string;AWindowCase:Integer;AGame,ASolution:Pointer);
    function ActiveChild : TMDIChild;
    function AuditWindow(AGame:Pointer): TMDIChild;
    function DebugWindow(ACase:Integer;AGame,ASolution:Pointer): TMDIChild;
    function GameWindow(AGame:Pointer): TMDIChild;
    procedure OpenProfileWindow(AName:string;AGame,AProfile:Pointer);
    procedure OpenSolutionWindow(AName:string;AGame,ASolution:Pointer);
    procedure OpenSolLogWindow(AName:string;AGame,ASolution:Pointer);
    procedure CloseSolutionWindow(AGame,ASolution:Pointer);
    {procedure CommandEnabling(SolveEditCase:Integer);  }
    procedure MenuUpdating(AGameState:Integer);
    procedure EnableSelect(IsEnabled:Boolean);
    procedure UpdateChildrenDisplay;
  end;

var
  MainForm: TMainForm;
  AutoSave: Boolean;

implementation

uses  About, SelectDlg, EditNode, EditMove, EditPlayer, Constants,
      Type32, File32, Game32Type, Game32Solve, Solve32, AuditUnit, SolvOptDlg, Name,
      EditInfo, EditTable, EditSide, ShellAPI, Registration, PassUnit,
  ViewPass;

{$R *.DFM}

{procedure TMainForm.ResetAutoSave(Sender: TObject);
begin
  if AutoSave
  then begin
    AutoSave:=False;
    AutoSaveOn1.Caption:='Auto Save... Off';
    MessageDlg('Autosave is now OFF.', mtWarning, [mbOk], 0);
  end else begin
    AutoSave:=True;
    AutoSaveOn1.Caption:='Auto Save... On';
    MessageDlg('Autosave is now ON.', mtWarning, [mbOk], 0);
  end;
end; }

procedure TMainForm.FormCreate(Sender: TObject);
var SplashAbout:TAboutBox; {Reg:TRegistry;}
begin
  {Reg:=TRegistry.Create;
  Reg.RootKey:=HKEY_CURRENT_USER; MUST BE REACTIVATED WHEN REGISTRY IN}
  if BypassRegistry {CanReadRegistry   {First checks registration}
  then begin
    {CheckRegistry; {will define RegCase. MUST BE REACTIVATED WHEN REGISTRY IN}
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
    AutoSave:=True;
  end else RegCase:=rc_NoInstall;
  {Reg.Free;  MUST BE REACTIVATED WHEN REGISTRY IN}
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
  if RegCase=rc_NoInstall {Failed to read from or write to registry}
  then begin
    MessageDlg('GamePlan incorrectly installed.', mtWarning, [mbOk], 0);
    Close;
  end else begin
    SolveDlg.Hide;
    DecimalSeparator:='.'; {To deal with localization issues in FloatToStrF}

    {Backup try}
    {MessageDlg('Run from '+ExtractFilePath(Application.ExeName), mtInformation, [mbOk], 0); }
    {CreateMDIChild(BackupName,wc_MainGame,nil,nil);

    FileOpen(BackupName,ActiveChild.MainGame);
    ActiveChild.ResetDisplay;
    MenuUpdating(ActiveChild.MainGame.GameState); }



    {if RegCase in [rc_TryUser,rc_FullUser] then begin }
      if ParamCount>0 then begin
        CreateMDIChild(ParamStr(1),wc_MainGame,nil,nil);
        FileOpen(ParamStr(1),ActiveChild.MainGame);
        ActiveChild.ResetDisplay;
        MenuUpdating(ActiveChild.MainGame.GameState);
      end;
    {end; }
  end;
end;


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

procedure TMainForm.CloseAllClick(Sender: TObject);
begin
  if ActiveMDIChild=nil then Exit;
  with ActiveChild do
  if (MainGame<>nil)
  then CloseSolutionWindow(MainGame,nil);
end;

procedure TMainForm.DeleteAllClick(Sender: TObject);
begin
  if MessageDlg('Discard existing solutions?',mtConfirmation,[mbYes, mbNo],0)=mrNo
  then Exit;
  MenuUpdating(gs_CanClose);
  if ActiveMDIChild=nil then Exit;
  with ActiveChild do
  if (MainGame<>nil) then with MainGame do begin
    CloseSolutionWindow(MainGame,nil);
    ReturnToEdit;
    FileSave(GameWindow(MainGame).Caption,MainGame); {In case solutions were saved}
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
  then CreateMDIChild('',wc_MainGame,nil,nil);
  ActiveChild:=TMDIChild(ActiveMDIChild)
end;

procedure TMainForm.CreateMDIChild(AName:string;AWindowCase:Integer;AGame,ASolution:Pointer);
var NewChild: TMDIChild;
begin  { create a new MDI child window }
  NewChild := TMDIChild.Create(Application);
  with NewChild do begin
    (*Parent:=MainForm;*)
    WindowState:=wsMaximized;
    WindowCase:=AWindowCase;
    Caption := AName;
    case WindowCase of
      wc_MainGame: begin MainGame:=TGameType32.Create;MainSolution:=nil;MainProfile:=nil;
                         if MainGame.GameState in [gs_Solved,gs_SavSol]
                         then MenuUpdating(gs_Solved)
                         else MenuUpdating(gs_Edited); end;
      wc_Solution: begin MainGame:=TGameType32(AGame);MainSolution:=ASolution;
                         MainProfile:=nil;MenuUpdating(gs_Solved);UpdateChildrenDisplay; end;
      wc_Profile : begin MainGame:=TGameType32(AGame);MainSolution:=nil;
                         MainProfile:=ASolution;MainProfile.FillBitList;end;
      wc_Audit   : begin MainGame:=TGameType32(AGame);MainSolution:=nil;
                         MainProfile:=nil;end;
      wc_Debug   : begin MainGame:=TGameType32(AGame);MainSolution:=ASolution;
                         MainProfile:=nil;end;
      wc_SolLog  : begin MainGame:=TGameType32(AGame);MainSolution:=ASolution;
                         MainProfile:=nil;end;
      wc_Test    : begin MainGame:=TGameType32(AGame);MainSolution:=nil;
                         MainProfile:=nil;end;
    end;
    if WindowCase in [wc_Audit,wc_Debug,wc_Test]
    then AuditList:=TGameList.Create
    else if WindowCase=wc_SolLog
         then AuditList:=MainSolution.SolutionLog
         else AuditList:=nil;
    EnableSelect(False);
    ResetDisplay;
  end;
end;

procedure TMainForm.FileExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.FileNewExecute(Sender: TObject);
begin
  CreateMDIChild('',wc_MainGame,nil,nil);
  ActiveChild.MainGame.SetState(gs_New);
  ActiveChild.MainGame.SetBacking(False);
  if AutoSave then FileSaveAs1.Execute;
end;

(*procedure TMainForm.FileRestoreExecute(Sender: TObject);
begin
  if OpenDialog.Execute
  then begin
    CreateMDIChild(BackupName,wc_MainGame,nil,nil);
    FileOpen(BackupName,ActiveChild.MainGame);
    ActiveChild.ResetDisplay;
    MenuUpdating(ActiveChild.MainGame.GameState);
  end;
end; *)

procedure TMainForm.FileOpenExecute(Sender: TObject);
begin
  if OpenDialog.Execute
  then begin
    CreateMDIChild(OpenDialog.FileName,wc_MainGame,nil,nil);
    FileOpen(OpenDialog.FileName,ActiveChild.MainGame);
    ActiveChild.ResetDisplay;
    MenuUpdating(ActiveChild.MainGame.GameState);

    (*SaveGame(BackupName,ActiveChild.MainGame);   *)
    
  end;
end;

procedure TMainForm.SaveGame(AFile:String;AGame:Pointer);
var TrueGame:TGameType32;
begin
  {if RegCase<>rc_FullUser
  then MessageDlg('Unregistered user cannot save games', mtWarning, [mbOk], 0)
  else begin}
    TrueGame:=TGameType32(AGame);
    if (TrueGame.GameState in [gs_SavSol,gs_Solved])
    then if (MessageDlg('Save solutions?', mtConfirmation, [mbYes, mbNo], 0)=mrYes)
       then begin
         FileSave(AFile,TrueGame);
         SaveSolutionFile(AFile,TrueGame);
       end else ReturnAct.Execute;
    if (TrueGame.GameState in [gs_New,gs_Edited,gs_CanClose])
    then FileSave(AFile,TrueGame);
  {end; }
end;

procedure TMainForm.Backup;
begin
  if Autosave and ActiveChild.MainGame.IsBacking
  then SaveGame(ActiveChild.MainGame.GameName,ActiveChild.MainGame);
end;

procedure TMainForm.FileSaveItemClick(Sender: TObject);
begin
  if ActiveMDIChild=nil then Exit;
  if (ActiveChild.MainGame.GameState=gs_New)
  or not ActiveChild.MainGame.IsBacking
  then FileSaveAs1.Execute
  else with GameWindow(ActiveChild.MainGame) do SaveGame(Caption,MainGame);
end;

procedure TMainForm.FileSaveAsItemClick(Sender: TObject);
begin
  if ActiveMDIChild=nil then Exit;
  with SaveDialog do
  begin
    if Execute then begin
      if ofExtensionDifferent in Options
      then MessageDlg ('Not a gpx extension', mtWarning, [mbOK], 0)
      else with GameWindow(ActiveChild.MainGame) do begin
        SaveGame(SaveDialog.FileName,ActiveChild.MainGame);
        SetCaption(SaveDialog.FileName);
      end;
    end {else {MessageDlg ('Cancel', mtWarning, [mbOK], 0)} {ActiveMDIChild.Close};
  end;
end;

procedure TMainForm.HelpAboutExecute(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

procedure TMainForm.AddPlayerClick(Sender: TObject);
begin
  if ActiveChild.CannotEdit then Exit else Backup;
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
  if ActiveChild.CannotEdit then Exit else Backup;
  with ActiveChild do begin
    with SelectDialog do begin
      InitDialog(MainGame.PlayerList,0);
      if (SelIndex>=0)
      then if not PlayerDelete(MainGame.PlayerList.Items[SelIndex],MainGame)
           then MessageDlg('Player owns nodes, sides or payoffs.', mtWarning, [mbOk], 0);
    end;
    Invalidate;
  end;
end;

procedure TMainForm.EditPlayerClick(Sender: TObject);
begin
  if ActiveChild.CannotEdit then Exit else Backup;
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
  if ActiveChild.CannotEdit then Exit else Backup;
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
  if ActiveChild.CannotEdit then Exit else Backup;
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
  if ActiveChild.CannotEdit then Exit else Backup;
  with ActiveChild do begin
    with SelectDialog do begin
      InitDialog(ActiveChild.MainGame.NodeList,ot_Table);
      case SelIndex of
       -2: MessageDlg('No defined table', mtWarning, [mbOk], 0);
       -1: SelectedObject:=nil;
       else SelectedObject:=MainGame.NodeList.Items[SelIndex];
      end;
    end;
    if SelectedObject<>nil then try begin
      MainGame.NodeList.Remove(SelectedObject);
      MainGame.SetState(gs_Edited);
      SelectedObject.Free;
    end; except on Exception do MessageDlg('Invalid table operation',mtWarning,[mbOk],0); end;
    Invalidate;
  end;
end;

procedure TMainForm.AddSideClick(Sender: TObject);
var ATable: TTable32;
begin
  if ActiveChild.CannotEdit then Exit else Backup;
  with ActiveChild do begin
    with SelectDialog do begin
      InitDialog(ActiveChild.MainGame.NodeList,ot_Table);
      case SelIndex of
       -2: MessageDlg('No defined table', mtWarning, [mbOk], 0);
       -1: SelectedObject:=nil;
       else SelectedObject:=MainGame.NodeList.Items[SelIndex];
      end;
    end;
    if SelectedObject<>nil then try begin
      ATable:=TTable32(SelectedObject);
      if SideDlg.FillOwnerList(ATable) {Check there are possible owners}
      then begin
        SideEdit(nil,ATable,MainGame); {Redoes cells}
        ATable.RedoGraphics;
      end else MessageDlg('Need additional players', mtWarning, [mbOk], 0);
    end; except on Exception do MessageDlg('Invalid table operation',mtWarning,[mbOk],0); end;
    Invalidate;
  end;
end;

procedure TMainForm.DeleteSideClick(Sender: TObject);
var ATable: TTable32; ASide: TSide32;
begin
  if ActiveChild.CannotEdit then Exit else Backup;
  with ActiveChild do begin
    with SelectDialog do begin
      InitDialog(ActiveChild.MainGame.InfoList,ot_Side);
      case SelIndex of
       -2: MessageDlg('No defined side', mtWarning, [mbOk], 0);
       -1: SelectedObject:=nil;
       else SelectedObject:=MainGame.InfoList.Items[SelIndex];
      end;
    end;
    if SelectedObject<>nil then try begin
      ASide:=TSide32(SelectedObject);
      ATable:=ASide.OwnTable;
      ATable.DeleteSide(ASide);
      ATable.SidesToCells;
      ATable.RedoGraphics;
      MainGame.SetState(gs_Edited);
    end; except on Exception do MessageDlg('Invalid table operation',mtWarning,[mbOk],0); end;
    Invalidate;
  end;
end;

procedure TMainForm.UndoEditClick(Sender: TObject);
begin

  if (ActiveChild=nil) or not AutoSave
  then Exit
  else with ActiveChild.MainGame do begin
    if not IsBacking then Exit;
    PlayerList.FreeAll(ot_All);
    NodeList.FreeAll(ot_All);
    PayList.FreeAll(ot_All);
    ChoiceList.FreeAll(ot_All);
    MoveList.FreeAll(ot_All);
    InfoList.FreeAll(ot_All);

    FileOpen(ActiveChild.MainGame.GameName,ActiveChild.MainGame);

    ActiveChild.ResetDisplay;
    ActiveChild.MainGame.GameState:=gs_Edited;
    MenuUpdating(ActiveChild.MainGame.GameState);
    ActiveChild.Invalidate;

  end;


end;

procedure TMainForm.EditSideClick(Sender: TObject);
var ASide: TSide32;
begin
  if ActiveChild.CannotEdit then Exit else Backup;
  with ActiveChild do begin
    with SelectDialog do begin
      InitDialog(ActiveChild.MainGame.InfoList,ot_Side);
      case SelIndex of
       -2: MessageDlg('No defined side', mtWarning, [mbOk], 0);
       -1: SelectedObject:=nil;
       else SelectedObject:=MainGame.InfoList.Items[SelIndex];
      end;
    end;
    if SelectedObject<>nil then try begin
      ASide:=TSide32(SelectedObject);
      SideEdit(ASide,ASide.OwnTable,MainGame);
      Aside.OwnTable.RedoGraphics;
    end; except on Exception do MessageDlg('Invalid table operation',mtWarning,[mbOk],0); end;
    Invalidate;
  end; 
end;

procedure TMainForm.AddNodeClick(Sender: TObject);
begin
  if ActiveChild.CannotEdit then Exit else Backup;
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
  if ActiveChild.CannotEdit then Exit else Backup;
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
  if ActiveChild.CannotEdit then Exit else Backup;
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
  if ActiveChild.CannotEdit then Exit else Backup;
  with SelectDialog do begin
    InitDialog(ActiveChild.MainGame.InfoList,ot_Info);
    if SelIndex>=0 then with ActiveChild do try begin
      SelectedObject:=MainGame.InfoList.Items[SelIndex];
      AnInfo:=TInfo32(SelectedObject);
      if AnInfo.Events.Count=0
      then AFirstNode:=nil
      else AFirstNode:=AnInfo.Events.Items[0];
      if AFirstNode<>nil
      then with InfoDlg do begin
        if InitDialog(AFirstNode)
        then ShowModal
      end;
    Invalidate;
    end; except on Exception do MessageDlg('Invalid info set operation',mtWarning,[mbOk],0); end;
  end;
end;

procedure TMainForm.AddMoveClick(Sender: TObject);
begin
  if ActiveChild.CannotEdit then Exit else Backup;
  with MoveDlg do begin
    InitDialog(nil,ActiveChild.MainGame);
    if ShowModal = mrOK
    then with ActiveChild do begin
      SetToDraw(False);
      SelectedObject:=TMove32.Create(MainGame);
      with DlgMove do begin
        if Upto=nil then SetPosition(From.XPos+ArrowStep,From.YPos)
        else SetPosition(Round((From.XPos+Upto.XPos)/2),Round((From.YPos+Upto.YPos)/2))
      end;
      //MessageDlg('Position is set.', mtWarning, [mbOk], 0);
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
  if ActiveChild.CannotEdit then Exit else Backup;
  with SelectDialog do begin
    InitDialog(ActiveChild.MainGame.MoveList,ot_Move);
    if SelIndex>=0 then with ActiveChild do begin
      SelectedObject:=MainGame.MoveList.Items[SelIndex];
      if MoveEdit(TMove32(SelectedObject),MainGame) then begin
        SetToDraw(True);
        Invalidate;
      end;
    end;
  end;
end;

procedure TMainForm.DeleteMoveClick(Sender: TObject);
begin
  if ActiveChild.CannotEdit then Exit else Backup;
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

function TMainForm.DebugWindow(ACase:Integer;AGame,ASolution:Pointer): TMDIChild;
var I:Integer; TheWindow,AChild:TMDIChild;
begin
  TheWindow:=nil;
  for I:=MDIChildCount-1 downto 0 do begin
    AChild:=TMDIChild(MDIChildren[I]);
    with AChild do
    if (MainGame=TGameType32(AGame))
    and (MainSolution=TSolution32(ASolution))
    and (WindowCase=ACase)  {ACase in [wc_Debug,wc_Test]}
    then TheWindow:=AChild;
  end;
  if TheWindow<>nil then DebugWindow:=TheWindow
  else begin
    case ACase of
      wc_Debug : CreateMDIChild('Debug '+TSolution32(ASolution).Name,wc_Debug,AGame,ASolution);
      wc_Test  : CreateMDIChild('Test ',wc_Test,AGame,nil);
    end;
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
       DebugWin:=DebugWindow(wc_Debug,MainGame,MainSolution);
       DebugWin.MakeAudit(fw_Debug);
     end;
  Cascade;
end;

procedure TMainForm.ShowTest1Click(Sender: TObject);
var TestWin: TMDIChild;
begin
  if ActiveMDIChild=nil then Exit
  else with ActiveChild
  do begin
       TestWin:=DebugWindow(wc_Test,MainGame,nil);
       TestWin.MakeAudit(fw_Test);
     end;
  Cascade;
end;

procedure TMainForm.ListGame(Sender: TObject);
begin
  MakeGameAudit(fw_ObjList);
end;

procedure TMainForm.DoSolve;
begin
  with ActiveChild do
  if MainGame.CheckGame
  then with SolveDlg do begin
    if IsBusy then Exit;
    MenuUpdating(gs_Solving);
    MainGame.SetState(gs_Solving);
    MainGame.SolutionList.FreeAll(ot_All);
    MainGame.ProfileList.FreeAll(ot_All);
    Show;
    InitDialog(True,MainGame);
  end else begin
    MakeGameAudit(fw_Bugs);
    MainGame.ReturnToEdit;
  end;
end;

procedure TMainForm.SolveClick(Sender: TObject);
begin {Open solve dialog}
  if ActiveMDIChild=nil then Exit;
  with ActiveChild do begin
    if MainGame.GameState=gs_CanClose then DoSolve
    else if MainGame.GameState in [gs_New,gs_Edited]
         then MessageDlg('You must save before solving', mtInformation, [mbOk], 0)
         else if (MainGame.GameState in [gs_Solved,gs_SavSol])
              then if (MessageDlg('Discard existing solutions?', mtConfirmation, [mbYes, mbNo], 0)=mrYes)
                   then begin
                     FileSave(GameWindow(MainGame).Caption,MainGame);
                     DoSolve;
                   end else MessageDlg('Solving cancelled', mtInformation, [mbOk], 0);
  end;
end;

procedure TMainForm.ShowSolutionClick(Sender: TObject);
begin
  if ActiveMDIChild=nil then Exit;
  with ActiveChild do if MainGame.SolutionList.Count>0
  then with SolveDlg do begin
    Show;
    InitDialog(False,MainGame);
  end;
end;

procedure TMainForm.OptionsClick(Sender: TObject);
begin
  SolveOptionsDlg.ShowModal;
end;

procedure TMainForm.NameGameClick(Sender: TObject);
begin
  {if ActiveChild.CannotEdit then Exit;}
  with NameDlg do begin

    case ActiveChild.WindowCase of
      wc_MainGame: begin
                   InitDialog('Edit Name',ActiveChild.MainGame.GameHeader,nil);
                   if ShowModal=mrOK then ActiveChild.MainGame.SetState(gs_Edited);
                   end;
      wc_Solution: begin
                   InitDialog('Edit Name',ActiveChild.MainSolution,nil);
                   if ShowModal=mrOK then ActiveChild.MainGame.SetState(gs_Solved);
                   ActiveChild.SetCaption(ActiveChild.MainSolution.Name);
                   end;
    end;
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
  if IsDebug then begin
    IsDebug:=False;
    Debug.Checked:=False;
  end else begin
    IsDebug:=True;
    Debug.Checked:=True;
  end;
end;

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
    Invalidate;
  end;
end;

procedure TMainForm.AddSelectionClick(Sender: TObject);
begin
  with ActiveChild do if not CannotEdit then begin
    MainGame.CopySelection;
    SelectedObject:=MainGame.SelRect;
    EnableSelect(False);
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

procedure TMainForm.Help2Click(Sender: TObject);
begin
  {ShellExecute(Handle, 'open', 'http://www.gametheorysoftware.net/documentation/3.2/',nil,nil, SW_SHOWNORMAL) ;  }
  ShellExecute(Handle, 'open', PChar(ExtractFilePath(Application.ExeName)+'GameHelp.chm'),nil,nil, SW_SHOWNORMAL) ;
end;

procedure TMainForm.ViewPass1Click(Sender: TObject);
begin
  ViewPassForm.ShowModal;
end;

procedure TMainForm.OpenSolLogWindow(AName:string;AGame,ASolution:Pointer);
var SolLogWin:TMDIChild;
begin
  CreateMDIChild(AName,wc_SolLog,AGame,ASolution);
  SolLogWin:=TMDIChild(ActiveMDIChild);
  SolLogWin.MakeAudit(fw_SolLog);
  Cascade;
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
    AuditAct.Enabled:=IsEnabled;
    OptionAct.Enabled:=IsEnabled;
    SolveAct.Enabled:=IsEnabled;
    ReturnAct.Enabled:=not IsEnabled;
    ShowAct.Enabled:=not IsEnabled;
    CloseAllAct.Enabled:=not IsEnabled;
  end;
begin
  EnableSelect(False);
  ActiveChild.FloatMenuUpdating(AGameState);
  case AGameState of
    gs_New,
    gs_Edited,
    gs_CanClose : begin EnableEdit(True);EnableSolve(True); end;
    gs_Solved,
    gs_SavSol   : begin EnableEdit(False);EnableSolve(False); end;
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

{******************** New check registration routines ********************}

function TMainForm.CanReadRegistry:Boolean;
{If registry keys exist, read username, serialnumber, installdate, currentpass}
var ErrCode: Integer; Reg:TRegistry;
begin
  CanReadRegistry:=True;
  RegCase:=0;
  UserName:='';
  SerialNumber:=0;
  InstallDate:=0;
  CrntPass:=0;
  Reg:=TRegistry.Create;
  Reg.RootKey:=HKEY_CURRENT_USER;
  if not Reg.KeyExists('\Software\GameTheorySoftware\GamePlan32')
  then CanReadRegistry:=False
  else try begin
    Reg.OpenKey('\Software\GameTheorySoftware\GamePlan32',False);
    UserName:=Reg.ReadString('UserName');
    SerialName:=Reg.ReadString('Serial');
    Val(SerialName,SerialNumber,ErrCode);
    if ErrCode<>0 then SerialNumber:=0;
    DateName:=Reg.ReadString('DateName');
    Val(DateName,InstallDate,ErrCode);
    if ErrCode<>0 then InstallDate:=0;
    PassName:=Reg.ReadString('PassName');
    Val(PassName,CrntPass,ErrCode);
    if ErrCode<>0 then CrntPass:=0;
    if (UserName='') or (SerialNumber=0) or (InstallDate=0) or (CrntPass=0)
    then RegCase:=rc_NeedReg; {This will trigger InitRegistration}
  end except on Exception do CanReadRegistry:=False end;
  Reg.Free;
end;

function TMainForm.BypassRegistry:Boolean;
begin
  BypassRegistry:=True;
  RegCase:=rc_FullUser;
  UserName:='SFSU';

end;

{******************* End new check registration routines *******************}

{******************** Begin check registration routines ********************}

procedure TMainForm.CheckRegistry;
var RegForm: TRegistrationForm;
  procedure InitRegistration;
  begin
    RegForm:=TRegistrationForm.Create(Application);
    if RegForm.ShowModal=mrOk {i.e., RegistrationDlg was good}
    then WriteRegistration
    else RegCase:=rc_NoInstall; {Will close GamePlan}
    RegForm.Free;
  end;
begin
  if RegCase=rc_NeedReg then InitRegistration;
  CheckPass; {Checks whether licensed user and for how long}
end;

procedure TMainForm.WriteRegistration; {Called by CheckRegistry or UpdatePass}
var Reg:TRegistry;
begin
  Reg:=TRegistry.Create;
  Reg.RootKey:=HKEY_CURRENT_USER;
  if not Reg.KeyExists('\Software\GameTheorySoftware\GamePlan32')
  then RegCase:=rc_NoInstall {Will close GamePlan}
  else try begin
    Reg.OpenKey('\Software\GameTheorySoftware\GamePlan32',False);
    Reg.WriteString('UserName',UserName);
    Reg.WriteString('DateName',DateName);
    Reg.WriteString('Serial',SerialName);
    Reg.WriteString('PassName',PassName);
  end except on Exception do RegCase:=rc_NoInstall; {Will close GamePlan} end;
  Reg.Free;
end;

procedure TMainForm.CheckPass;
var Deadline:Integer;
begin
  Deadline:=-1; {If CrntPass doesn't match any of three cases below}
  if (CrntPass=MakeScramble(Trunc((SerialNumber+InstallDate)/2))) {30/90 day license depending on TrialLength constant}
  then Deadline:=DaysLeft(True);
  if (CrntPass=MakeScramble(Trunc((2*SerialNumber+InstallDate)/3)))  {One-year license}
  then Deadline:=DaysLeft(False);
  if (CrntPass=MakeScramble(Trunc((SerialNumber+2*InstallDate)/3)))  {Forever license}
  then Deadline:=PassMagn;
  if Deadline<=0
  then begin
    MessageDlg('Your license has expired.',mtInformation,[mbOk],0);
    RegCase:=rc_TryUser;
  end else begin
    RegCase:=rc_FullUser;
    if (Deadline>=MonthLength)
    then RegAction.Enabled:=False
    else begin
      MessageDlg('Your license expires in '+IntToStr(Deadline)+' day(s)',mtInformation,[mbOk],0);
      RegAction.Enabled:=True;
    end;
  end;
end;

function TMainForm.DaysLeft(IsTrial:Boolean):Integer;
var YI, MI, DI, YN, MN, DN: Word; TimeLeft:Real;
begin
  YI:=Trunc(InstallDate/TenK);
  MI:=Trunc((InstallDate-TenK*YI)/Hundred);
  DI:=InstallDate-TenK*YI-Hundred*MI;
  DecodeDate(Date, YN, MN, DN);
  if IsTrial
  then TimeLeft:=(YI-YN)*YearLength+(MI-MN)*MonthLength+(DI-DN)+TrialLength {Defined in Constants}
  else TimeLeft:=(YI+1-YN)*YearLength+(MI-MN)*MonthLength+(DI-DN); {One year license}
  if TimeLeft<=0 then DaysLeft:=0
  else try DaysLeft:=Trunc(TimeLeft)
  except on Exception do DaysLeft:=0 end;
end;

procedure TMainForm.Registration1Click(Sender: TObject);
var MailText:String;
begin
    with PassForm do
      case ShowModal of
       mrOk : begin {Entered password}
                UpdatePass;
                if RegCase=rc_FullUser
                then AboutBox.ShowModal
                else MessageDlg('Incorrect password', mtWarning, [mbOk], 0);
              end;
       mrYes: begin {Clicked the Email button in PassForm}
                MailText:='mailto: gameplan@sfsu.edu?subject=GP v3.7 Password for '
                    +UserName+'&body=Serial Number: '+MyIntToStr(SerialNumber)
                    +' Install Date: '+MyIntToStr(InstallDate)
                    +' Current Pass: '+MyIntToStr(CrntPass);
                ShellExecute(0,'open',PChar(MailText), NIL, NIL, SW_SHOWNORMAL);
              end;
      end;
end;

procedure TMainForm.UpdatePass;
var Updating: Boolean;
begin
  Updating:=False;
  if UpdateCode=MakeScramble(Trunc((2*SerialNumber+InstallDate)/3))
  then begin {Update to 1-year license}
    Updating:=True;
    InstallDate:=TodaysDate;
    CrntPass:=MakeSerialPass(rc_FullUser,InstallDate,SerialNumber);
    MessageDlg('Your license is extended by one year.',mtInformation,[mbOk],0);
  end;
  if UpdateCode=MakeScramble(Trunc((SerialNumber+2*InstallDate)/3))
  then begin {Update to forever license}
    Updating:=True;
    InstallDate:=TodaysDate;
    CrntPass:=MakeSerialPass(rc_Forever,InstallDate,SerialNumber);
    MessageDlg('Your license is extended indefinitely.',mtInformation,[mbOk],0);
  end;
  if Updating then begin
    DateName:=MyIntToStr(InstallDate);
    PassName:=MyIntToStr(CrntPass);
    WriteRegistration;
    CheckPass;
  end else MessageDlg('Incorrect update password',mtWarning,[mbOk],0);
end;

{******************** End check registration routines ********************}


end.
