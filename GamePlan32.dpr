program GamePlan32;

uses
  Forms, Windows,
  MainGP32 in 'MainGP32.PAS' {MainForm},
  Childwin in 'CHILDWIN.PAS' {MDIChild},
  About in 'about.pas' {AboutBox},
  EditPlayer in 'EditPlayer.pas' {PlayerDlg},
  Type32 in 'Type32.pas',
  SelectDlg in 'SelectDlg.pas' {SelectDialog},
  File32 in 'File32.pas',
  Constants in 'Constants.pas',
  EditNode in 'EditNode.pas' {NodeDlg},
  Game32Type in 'Game32Type.pas',
  Utilities in 'Utilities.pas',
  EditMove in 'EditMove.pas' {MoveDlg},
  EditInfo in 'EditInfo.pas' {InfoDlg},
  EditPayoff in 'EditPayoff.pas' {PayoffDlg},
  SolvOptDlg in 'SolvOptDlg.pas' {SolveOptionsDlg},
  Matrices in 'Matrices.pas',
  Game32Solve in 'Game32Solve.pas',
  Solve32 in 'Solve32.pas' {SolveDlg},
  EditSide in 'EditSide.pas' {SideDlg},
  Name in 'Name.pas' {NameDlg},
  EditCell in 'EditCell.pas' {CellDlg},
  Registration in 'Registration.pas' {RegistrationForm},
  PassUnit in 'PassUnit.pas' {PassForm},
  ViewPass in 'ViewPass.pas' {ViewPassForm};

{$R *.RES}

{var
  Hwnd: THandle; }

begin
  {Hwnd:=FindWindow('TMainForm',nil);
  if Hwnd=0
  then begin}
  Application.Initialize;
  Application.HelpFile := '';
  Application.Title := 'GamePlan for Game Theory';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TPassForm, PassForm);
  {Application.CreateForm(TRegistrationForm, RegistrationForm); }
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TPlayerDlg, PlayerDlg);
  Application.CreateForm(TSelectDialog, SelectDialog);
  Application.CreateForm(TNodeDlg, NodeDlg);
  Application.CreateForm(TMoveDlg, MoveDlg);
  Application.CreateForm(TInfoDlg, InfoDlg);
  Application.CreateForm(TPayoffDlg, PayoffDlg);
  Application.CreateForm(TSolveOptionsDlg, SolveOptionsDlg);
  Application.CreateForm(TSolveDlg, SolveDlg);
  Application.CreateForm(TSideDlg, SideDlg);
  Application.CreateForm(TNameDlg, NameDlg);
  Application.CreateForm(TCellDlg, CellDlg);
  Application.CreateForm(TViewPassForm, ViewPassForm);
  Application.Run;

  {end else begin
  {Application.Restore;
  Application.BringToFront;
  SetForeGroundWindow(Hwnd);
  if ParamCount>0 then with TMainForm(Application.MainForm) do begin
    CreateMDIChild(ParamStr(2),wc_MainGame,nil,nil);
    FileOpen(ParamStr(2),ActiveChild.MainGame);
    ActiveChild.ResetDisplay;
    MenuUpdating(ActiveChild.MainGame.GameState);
  end;
  end;}

end.
