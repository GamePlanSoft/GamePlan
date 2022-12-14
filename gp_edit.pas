{Copyright (c), Jean-Pierre P. Langlois, 2007-2022}

Unit GP_Edit;

interface

uses GP_Loop,GP_Type,GP_FlTyp,GP_Cnst,GP_Util,GP_Glob,
     OWindows,ODialogs,{OStdDlgs,}Strings,Objects,WinTypes,WinProcs,WinDos;

const
 id_Select      = 102;
 id_Change      = 102;
 id_Add         = 111;
 id_Delete      = 102;
 id_ReadPayoff  = 407;
 id_Edit        = 410;
 id_Cut         = 413;
 id_Paste       = 414;
 id_SetPre      = 320;
 id_SetFinal    = 321;
 id_SetFrom     = 302;
 id_SetUpto     = 304;
 id_Outcome     = 415;
 id_Another     = 416;
 id_ReadList    = 500;
 id_Dump        = 411;
 id_List        = 420;
 id_SetOwner    = 202;
 id_SetChance   = 210;
 id_SetPlayer   = 211;
 id_SetBayes    = 250;
 id_Select1     = 401;
 id_Select2     = 402;
 id_Select3     = 403;
 id_Select4     = 404;
 id_Protect     = 200;
 id_Unprotect   = 201;
 id_Form        = 200;
 id_Color       = 211;
 id_Variable    = 201;
 id_Assignment  = 205;
 id_MakeTest    = 207;
 id_MakeStep    = 208;
 id_Statement   = 206;
 id_Event       = 203;
 id_Logic       = 204;
 id_Default     = 122;
 {id_MoveUp      = 302;
 id_MoveDown    = 303;  }

 {----------------------------------------------}
 {----Options objects definition----------------}
 {----------------------------------------------}

type

 PProtection      = ^TProtection;
 TProtection      = object(TDialog)
  IsProtected     : Boolean;
  NewPassword,
  Date            : NameType;
  Owner           : LongName;
  constructor Init(AParent:PWindowsObject;AResource:PChar);
  procedure SetUpWindow; virtual;
  procedure MakeDate;
  procedure Ok(var Msg:TMessage);virtual id_First + id_Ok;
 end;

 {POptionsDlg   = ^TOptionsDlg;
 TOptionsDlg   = object(TDialog)
  DialogData   : POptionsRec;
  IterationText: NameType;
  constructor Init(AParent:PWindowsObject;AResource:PChar;P:POptionsRec);
  procedure SetUpWindow; virtual;
  procedure UpdateRecord;
  procedure Ok(var Msg:TMessage);virtual id_First + id_Ok;
 end;  }

 {----------------------------------------------}
 {----Parameter objects definition--------------}
 {----------------------------------------------}

type
 PEditParam    = ^TEditParam;
 TEditParam    = object(TDialog)
  ParamCase    : Byte;
  constructor Init(AParent:PWindowsObject;AResource:PChar;AParamCase:Byte);
  procedure SetupWindow; virtual;
  procedure Ok(var Msg:TMessage); virtual id_First + id_Ok;
 end;

 {----------------------------------------------}
 {----Header objects definition-----------------}
 {----------------------------------------------}

type
 PEditHeader   = ^TEditHeader;
 TEditHeader   = object(TDialog)
  TheHeader    : PGameObject;
  constructor Init(AParent:PWindowsObject;AResource:PChar;AHeader:PGameObject);
  procedure SetupWindow; virtual;
  procedure Ok(var Msg:TMessage); virtual id_First + id_Ok;
 end;

 {----------------------------------------------}
 {----Header objects definition-----------------}
 {----------------------------------------------}

type

 PEditComment  = ^TEditComment;
 TEditComment  = object(TDialog)
  NewComment    : PComment;
  IsNewComment  : Boolean;
  constructor Init(AParent:PWindowsObject;AResource:PChar;
                   IsNew:Boolean;AComment:PComment);
  procedure SetupWindow; virtual;
  procedure Ok(var Msg:TMessage); virtual id_First + id_Ok;
 end;

 {----------------------------------------------}
 {----Player objects definition-----------------}
 {----------------------------------------------}

type
 PMakePlayer     = ^TMakePlayer;
 TMakePlayer     = object(TDialog)
  ThePlayer      : PPlayer;
  IsNewPlayer    : Boolean;
  constructor Init(AParent:PWindowsObject;AResource:PChar;
                   NewPlayer:Boolean;APlayer:PPlayer);
  procedure SetupWindow; virtual;
  procedure Ok(var Msg:TMessage); virtual id_First + id_Ok;
  end;

type
 PEditPlayer   = ^TEditPlayer;
 TEditPlayer   = object(TDialog)
  procedure SetupWindow; virtual;
  procedure Change(var Msg:TMessage); virtual id_First + id_Change;
 end;

type
 PDeletePlayer  = ^TDeletePlayer;
 TDeletePlayer  = object(TDialog)
  StringText,
  StringTitle   : LongName;
  procedure SetupWindow; virtual;
  procedure Delete(var Msg:TMessage); virtual id_First + id_Delete;
 end;

type
 PSelectPlayer   = ^TSelectPlayer;
 TSelectPlayer   = object(TDialog)
  constructor Init(AParent:PWindowsObject;AResource:PChar);
  procedure SetupWindow; virtual;
  procedure Select(var Msg:TMessage); virtual id_First + id_Select;
 end;

 {----------------------------------------------}
 {----Node objects definition-------------------}
 {----------------------------------------------}

type
 PMakeNode     = ^TMakeNode;
 TMakeNode     = object(TDialog)
  TheNode       : PNode;
  NewOwner,
  TheOwner      : PPlayer;
  IsBayesNode,
  IsChance,
  IsNewNode     : Boolean;
  AText         : NameType;
  OwnerIndex    : Integer;
  constructor Init(AParent:PWindowsObject;
                   AResource:PChar;IsNew:Boolean;ANode:PNode);
  procedure SetupWindow; virtual;
  procedure UpdateNode;
  procedure SetChance(var Msg:TMessage); virtual id_First + id_SetChance;
  procedure SetPlayer(var Msg:TMessage); virtual id_First + id_SetPlayer;
  procedure SetOwner(var Msg:TMessage); virtual id_First + id_SetOwner;
  procedure SetBayes(var Msg:TMessage); virtual id_First + id_SetBayes;
  procedure Ok(var Msg:TMessage); virtual id_First + id_Ok;
  end;

type
 PEditNode   = ^TEditNode;
 TEditNode   = object(TDialog)
  TheNode    : PNode;
  procedure SetupWindow; virtual;
  procedure Change(var Msg:TMessage); virtual id_First + id_Change;
 end;

type
 PDeleteNode  = ^TDeleteNode;
 TDeleteNode  = object(TDialog)
  StringText,
  StringTitle   : LongName;
  procedure SetupWindow; virtual;
  procedure Delete(var Msg:TMessage); virtual id_First + id_Delete;
 end;

type
 PInformation = ^TInformation;
 TInformation = object(TDialog)
  TheInfo     : PInfo;
  TheOwner    : PPlayer;
  NodeListBox,
  EventListBox: PListBox;
  constructor Init(AParent:PWindowsObject;AResource:PChar;
                   AnInfo:PInfo;ANode:PNode);
  procedure SetupWindow; virtual;
  procedure UpdateWindow;
  procedure Add(var Msg:TMessage); virtual id_First + id_Add;
  procedure Delete(var Msg: TMessage); virtual id_First+ id_Delete;
  procedure Ok(var Msg:TMessage); virtual id_First + id_Ok;
 end;

type
 PSelectNode  = ^TSelectNode;
 TSelectNode  = object(TDialog)
  NodeColl    : PCollection;
  constructor Init(AParent:PWindowsObject;AResource:PChar;
                   AColl:PCollection);
  procedure SetupWindow; virtual;
  procedure Select(var Msg:TMessage); virtual id_First + id_Select;
 end;

 {----------------------------------------------}
 {----Move objects definition-------------------}
 {----------------------------------------------}

type
 PMakeMove     = ^TMakeMove;
 TMakeMove     = object(TDialog)
  TheMove       : PMove;
  IsFinal,
  IsPreDiscnt,
  IsNewMove     : Boolean;
  UptoIndex,
  FromIndex     : Integer;
  TheDiscount,
  NewDiscount   : Real;
  DiscountStr   : NameType;
  TheFrom,
  TheUpto       : PNode;
  InfoString    : LongName;
  constructor Init(AParent:PWindowsObject;
                   AResource:PChar;IsNew:Boolean;AMove:PMove);
  procedure SetupWindow; virtual;
  procedure UpdateMove;
  procedure SetPre(var Msg:TMessage); virtual id_First + id_SetPre;
  procedure SetFinal(var Msg:TMessage); virtual id_First + id_SetFinal;
  procedure SetFrom(var Msg:TMessage); virtual id_First + id_SetFrom;
  procedure SetUpto(var Msg:TMessage); virtual id_First + id_SetUpto;
  procedure GoOutcome(Msg:TMessage); virtual id_First + id_Outcome;
  procedure Ok(var Msg:TMessage); virtual id_First + id_Ok;
  end;

type
 PEditMove   = ^TEditMove;
 TEditMove   = object(TDialog)
  procedure SetupWindow; virtual;
  procedure Change(var Msg:TMessage); virtual id_First + id_Change;
 end;

type
 PDeleteMove  = ^TDeleteMove;
 TDeleteMove  = object(TDialog)
  StringText,
  StringTitle   : LongName;
  procedure SetupWindow; virtual;
  procedure Delete(var Msg:TMessage); virtual id_First + id_Delete;
 end;

type
 PEditOutcome     = ^TEditOutcome;
 TEditOutcome     = object(TDialog)
  PayoffText      : NameType;
  InfoString      : LongName;
  TheOutcome      : POutcome;
  Duplicates      : array[0..MaxPlayerNumber-1] of POutcome;
  TheCell         : PCell;
  TheMove         : PMove;
  ThePlayer       : PPlayer;
  IsMoveCase      : Boolean;
  ThePayoff       : Real;
  Position        : Integer;
  constructor Init(AParent:PWindowsObject;AResource:PChar;ACell:PCell;AMove:PMove);
  procedure SetupWindow; virtual;
  procedure MakeDuplicates;
  procedure DumpDuplicates;
  procedure RestoreDuplicates;
  procedure ListPlayers;
  procedure ListOutcomes;
  procedure Select1(var Msg:TMessage);virtual id_First + id_Select1;
  procedure Select2(var Msg:TMessage);virtual id_First + id_Select2;
  procedure Select3(var Msg:TMessage);virtual id_First + id_Select3;
  procedure Select4(var Msg:TMessage);virtual id_First + id_Select4;
  procedure Delete(var Msg:TMessage); virtual id_First + id_Dump;
  function CanReadOutcomes:Boolean;
  procedure Ok(var Msg:TMessage); virtual id_First + id_Ok;
  procedure Cancel(var Msg:TMessage); virtual id_First + id_Cancel;
  end;

type
 PPickOutcome     = ^TPickOutcome;
 TPickOutcome     = object(TDialog)
  procedure SetupWindow; virtual;
  procedure Change(var Msg:TMessage); virtual id_First + id_Change;
 end;

type
 PSelectMove  = ^TSelectMove;
 TSelectMove   = object(TDialog)
  procedure SetupWindow; virtual;
  procedure Select(var Msg:TMessage); virtual id_First + id_Select;
 end;

type
 PDeleteStrategy  = ^TDeleteStrategy;
 TDeleteStrategy  = object(TDialog)
  StringText,
  StringTitle   : LongName;
  procedure SetupWindow; virtual;
  procedure Delete(var Msg:TMessage); virtual id_First + id_Delete;
 end;

type
 PEditStrategy   = ^TEditStrategy;
 TEditStrategy   = object(TDialog)
  AStrategy      : PStrategy;
  procedure SetupWindow; virtual;
  procedure Change(var Msg:TMessage); virtual id_First + id_Change;
 end;

 PMakeSymStrat  = ^TMakeSymStrat;
 TMakeSymStrat   = object(TDialog)
  TheStrat       : PStrategy;
  IsNewStrat     : Boolean;
  constructor Init(AParent:PWindowsObject;AResource:PChar;IsNew:Boolean;AStrategy:PStrategy);
  procedure SetupWindow; virtual;
  procedure Ok(var Msg:TMessage); virtual id_First + id_Ok;
 end;

type
 PMakeStrategy = ^TMakeStrategy;
 TMakeStrategy = object(TDialog)
  IsNewStrategy : Boolean;
  TheStrategy   : PStrategy;
  NewOwner,
  TheOwner      : PPlayer;
  AText         : NameType;
  OwnerIndex    : Integer;
  constructor Init(AParent:PWindowsObject;
                   AResource:PChar;IsNew:Boolean;AStrategy:PStrategy);
  procedure SetupWindow; virtual;
  procedure UpdateStrategy;
  procedure SetOwner(var Msg:TMessage); virtual id_First + id_SetOwner;
  procedure Ok(var Msg:TMessage); virtual id_First + id_Ok;
 end;

 PPopulation    = ^TPopulation;
 TPopulation    = object(TDialog)
  procedure SetupWindow; virtual;
  procedure Select1(var Msg:TMessage); virtual id_First + id_Select1;
  procedure Select2(var Msg:TMessage); virtual id_First + id_Select2;
  procedure Ok(var Msg:TMessage); virtual id_First + id_Ok;
 end;

type
 PChooseColor = ^TChooseColor;
 TChooseColor = object(TDialog)
  procedure Blue(var Msg:TMessage); virtual id_First + id_Blue;
  procedure Red(var Msg:TMessage); virtual id_First + id_Red;
  procedure Green(var Msg:TMessage); virtual id_First + id_Green;
  procedure Black(var Msg:TMessage); virtual id_First + id_Black;
  procedure Cyan(var Msg:TMessage); virtual id_First + id_Cyan;
  procedure Pink(Msg:TMessage); virtual id_First + id_Pink;
  procedure Yellow(var Msg:TMessage); virtual id_First + id_Yellow;
  procedure Gray(var Msg:TMessage); virtual id_First + id_Gray;
  procedure Pastel(var Msg:TMessage); virtual id_First + id_Pastel;
  procedure Purple(var Msg:TMessage); virtual id_First + id_Purple;
  procedure Khaki(var Msg:TMessage); virtual id_First + id_Khaki;
  procedure Neon(var Msg:TMessage); virtual id_First + id_Neon;
 end;

 {Abstract type that is never used in actual dialog box}
 TDefEvBasic = object(TDialog)
  NewName        : NameType;
  ObjType        : Byte;
  Index          : Integer;
  DlgEvolver     : PEvolver;
  RealList       : TCollection;
  ChceList       : TCollection;
  TestList       : TCollection;
  StepList       : TCollection;
  constructor Init(AParent:PWindowsObject;AResource:PChar;AnEvolver:PEvolver;AnIndex:Integer);
  destructor Done; virtual;
 end;

 PDefEvVar = ^TDefEvVar;
 TDefEvVar = object(TDefEvBasic)
  DlgEvVar   : TEvVrbl;
  EditEvVar  : PEvVrbl;
  constructor Init(AParent:PWindowsObject;AResource:PChar;AnEvolver:PEvolver;AnObject:PEvVrbl;AnIndex:Integer);
  procedure SetupWindow; virtual;
  procedure Ok(var Msg:TMessage); virtual id_First + id_Ok;
 end;

 {******** Assignments definition ************}

 PSetResp = ^TSetResp;
 TSetResp = object(TDefEvBasic)
  ChceAssgn  : PEvAssgn;
  DlgChceList,
  StratList  : TCollection;
  constructor Init(AParent:PWindowsObject;AResource:PChar;AnEvolver:PEvolver;AnEvAssgn:PEvAssgn);
  procedure SetupWindow; virtual;
  procedure Ok(var Msg:TMessage); virtual id_First + id_Ok;
 end;

 PSetChoice = ^TSetChce;
 TSetChce = object(TDefEvBasic)
  IsOwn      : Boolean;
  ChceAssgn  : PEvAssgn;
  DlgChceList,
  StratList  : TCollection;
  constructor Init(AParent:PWindowsObject;AResource:PChar;AnEvolver:PEvolver;AnEvAssgn:PEvAssgn;AndIsOwn:Boolean);
  procedure SetupWindow; virtual;
  procedure Ok(var Msg:TMessage); virtual id_First + id_Ok;
 end;

 PSetReal = ^TSetReal;
 TSetReal = object(TDefEvBasic)
  RealAssgn  : PEvAssgn;
  constructor Init(AParent:PWindowsObject;AResource:PChar;AnEvolver:PEvolver;AnEvAssgn:PEvAssgn);
  procedure SetupWindow; virtual;
  procedure Ok(var Msg:TMessage); virtual id_First + id_Ok;
 end;

 PSetOper = ^TSetOper;
 TSetOper = object(TDefEvBasic)
  RealAssgn  : PEvAssgn;
  constructor Init(AParent:PWindowsObject;AResource:PChar;AnEvolver:PEvolver;AnEvAssgn:PEvAssgn);
  procedure SetupWindow; virtual;
  procedure UnCheckOp;
  procedure OpPlus(var Msg:TMessage); virtual id_First + op_Plus;
  procedure OpMinus(var Msg:TMessage); virtual id_First + op_Minus;
  procedure OpTimes(var Msg:TMessage); virtual id_First + op_Times;
  procedure OpDivBy(var Msg:TMessage); virtual id_First + op_DivBy;
  procedure SetToVar(var Msg:TMessage); virtual id_First + at_ToVar;
  procedure SetToConst(var Msg:TMessage); virtual id_First + at_ToConst;
  procedure Ok(var Msg:TMessage); virtual id_First + id_Ok;
 end;

 PDefAssign = ^TDefAssign;
 TDefAssign = object(TDefEvBasic)
  IsNotEdited : Boolean;  {To warn user}
  DlgEvAssgn  : TEvAssgn;
  EditEvAssgn : PEvAssgn;
  constructor Init(AParent:PWindowsObject;AResource:PChar;AnEvolver:PEvolver;AnObject:PEvAssgn;AnIndex:Integer);
  procedure SetupWindow; virtual;
  procedure EditChoice(IsOwn:Boolean);
  procedure EditReal;
  procedure EditOper;
  procedure EditResp;
  procedure Edit(var Msg:TMessage); virtual id_First + id_Edit;
  procedure Ok(var Msg:TMessage); virtual id_First + id_Ok;
 end;

 {***************** Tests definition *****************}

 PTestReal = ^TTestReal;
 TTestReal = object(TDefEvBasic)
  RealTest   : PEvTest;
  constructor Init(AParent:PWindowsObject;AResource:PChar;AnEvolver:PEvolver;AnEvTest:PEvTest);
  procedure SetupWindow; virtual;
  procedure UnCheckTest;
  procedure UnCheckWhat;
  procedure AtToVar(var Msg:TMessage); virtual id_First + at_ToVar;
  procedure AtToConst(var Msg:TMessage); virtual id_First + at_ToConst;
  procedure BtEqualTo(var Msg:TMessage); virtual id_First + bt_EqualTo;
  procedure BtLessThan(var Msg:TMessage); virtual id_First + bt_LessThan;
  procedure BtMoreThan(var Msg:TMessage); virtual id_First + bt_MoreThan;
  procedure BtDiffFrom(var Msg:TMessage); virtual id_First + bt_DiffFrom;
  procedure Ok(var Msg:TMessage); virtual id_First + id_Ok;
 end;

 PTestChce = ^TTestChce;
 TTestChce = object(TDefEvBasic)
  IsOwn      : Boolean;
  ChceTest   : PEvTest;
  DlgChceList,
  StratList  : TCollection;
  constructor Init(AParent:PWindowsObject;AResource:PChar;AnEvolver:PEvolver;AnEvTest:PEvTest;AndIsOwn:Boolean);
  procedure SetupWindow; virtual;
  procedure UnCheckTest;
  procedure UnCheckWhat;
  procedure AtToVar(var Msg:TMessage); virtual id_First + at_ToVar;
  procedure AtToConst(var Msg:TMessage); virtual id_First + at_ToConst;
  procedure BtEqualTo(var Msg:TMessage); virtual id_First + bt_EqualTo;
  procedure BtDiffFrom(var Msg:TMessage); virtual id_First + bt_DiffFrom;
  procedure Ok(var Msg:TMessage); virtual id_First + id_Ok;
 end;

 PTestBool = ^TTestBool;
 TTestBool = object(TDefEvBasic)
  BoolTest   : PEvTest;
  constructor Init(AParent:PWindowsObject;AResource:PChar;AnEvolver:PEvolver;AnEvTest:PEvTest);
  procedure SetupWindow; virtual;
  procedure Ok(var Msg:TMessage); virtual id_First + id_Ok;
 end;

 PDefTest = ^TDefTest;
 TDefTest = object(TDefEvBasic)
  IsNotEdited : Boolean;  {To warn user}
  DlgEvTest  : TEvTest;
  EditEvTest : PEvTest;
  constructor Init(AParent:PWindowsObject;AResource:PChar;AnEvolver:PEvolver;AnObject:PEvTest;AnIndex:Integer);
  procedure SetupWindow; virtual;
  procedure Edit(var Msg:TMessage); virtual id_First + id_Edit;
  procedure Ok(var Msg:TMessage); virtual id_First + id_Ok;
 end;

 PDefStep = ^TDefStep;
 TDefStep = object(TDefEvBasic)
  DlgEvStep  : TEvStep;
  EditEvStep : PEvStep;
  constructor Init(AParent:PWindowsObject;AResource:PChar;AnEvolver:PEvolver;AnObject:PEvStep;AnIndex:Integer);
  procedure SetupWindow; virtual;
  procedure Ok(var Msg:TMessage); virtual id_First + id_Ok;
 end;

 PMakeEvolver = ^TMakeEvolver;
 TMakeEvolver = object(TDialog)
  NewName     : NameType;
  ColorStr    : NameType;
  Index       : Integer;
  DlgEvolver  : PEvolver;
  SelectEvObj : PEvBasic;
  constructor Init(AParent:PWindowsObject;AResource:PChar;AnEvolver:PEvolver);
  procedure SetupWindow; virtual;
  procedure UpdateDialog;
  procedure UpdateOwner;
  procedure MakeColor(var Msg:TMessage); virtual id_First + id_Color;
  procedure MakeVariable(var Msg:TMessage); virtual id_First + id_Variable;
  procedure MakeAssignment(var Msg:TMessage); virtual id_First + id_Assignment;
  procedure MakeTest(var Msg:TMessage); virtual id_First + id_MakeTest;
  procedure MakeStep(var Msg:TMessage); virtual id_First + id_MakeStep;
  procedure MakeDefault(var Msg:TMessage); virtual id_First + id_Default;
  procedure MakeOwner(var Msg:TMessage); virtual id_First + id_SetOwner;
  procedure Delete(var Msg:TMessage); virtual id_First + id_Delete;
  procedure Edit(var Msg:TMessage); virtual id_First + id_Edit;
  procedure Cut(var Msg:TMessage); virtual id_First + id_Cut;
  procedure Paste(var Msg:TMessage); virtual id_First + id_Paste;
  procedure Select(var Msg:TMessage); virtual id_First + id_List;
  procedure Ok(var Msg:TMessage); virtual id_First + id_Ok;
  procedure Cancel(var Msg:TMessage); virtual id_First + id_Cancel;
 end;

 PDeleteEvolver = ^TDeleteEvolver;
 TDeleteEvolver = object(TDialog)
  StringText,
  StringTitle   : LongName;
  procedure SetupWindow; virtual;
  procedure Delete(var Msg:TMessage); virtual id_First + id_Delete;
 end;

 PEditEvolver   = ^TEditEvolver;
 TEditEvolver   = object(TDialog)
  procedure SetupWindow; virtual;
  procedure Change(var Msg:TMessage); virtual id_First + id_Change;
 end;

 PSelectPair    = ^TSelectPair;
 TSelectPair    = object(TDialog)
  RowColl,
  ColColl       : TCollection;
  FirstEV,
  SecndEV       : PEvolver;
  constructor Init(AParent:PWindowsObject;AResource:PChar);
  procedure SetupWindow; virtual;
  procedure Ok(var Msg:TMessage); virtual id_First + id_Ok;
  procedure Cancel(var Msg:TMessage); virtual id_First + id_Cancel;
 end;

 {----------------------------------------------}
 {----Global objects methods and variables------}
 {----------------------------------------------}

type
 PAboutDlg      = ^TAboutDlg;
 TAboutDlg      = object(TDialog)
  GameUser      : PGameUser;
  constructor Init(AParent:PWindowsObject;AResource:PChar;AGameUser:PGameUser);
  procedure SetupWindow; virtual;
 end;

type
 PRegistrDlg    = ^TRegistrDlg;
 TRegistrDlg    = object(TDialog)
  GameUser      : PGameUser;
  constructor Init(AParent:PWindowsObject;AResource:PChar;AGameUser:PGameUser);
  procedure SetupWindow; virtual;
  procedure Ok(var Msg:TMessage); virtual id_First + id_Ok;
  procedure Form(var Msg:TMessage); virtual id_First + id_Form;
 end;

type
 PIniDlg    = ^TIniDlg;
 TIniDlg    = object(TDialog)
  GameUser      : PGameUser;
  constructor Init(AParent:PWindowsObject;AResource:PChar;AGameUser:PGameUser);
  procedure Ok(var Msg:TMessage); virtual id_First + id_Ok;
 end;

type
 PZoom          = ^TZoom;
 TZoom          = object(TDialog)
  constructor Init(AParent:PWindowsObject;AResource:PChar);
  procedure SetupWindow; virtual;
  procedure Small; virtual id_First + id_Small;
  procedure Normal; virtual id_First + id_Normal;
  procedure Large; virtual id_First + id_Large;
 end;

 function IsReservedWord(AName:PChar):Boolean;

 procedure InitEditUnit;

 {----------------------------------------------}
 {----Object methods implementation-------------}
 {----------------------------------------------}

implementation

 {----------------------------------------------}
 {----General methods implementation------------}
 {----------------------------------------------}

 function IsReservedWord(AName:PChar):Boolean;
 var I:Byte;
 begin
  IsReservedWord:=False;
  for I:=1 to 44 do
  if (StrIComp(AName,RsrvWrds[I])=0)
  then IsReservedWord:=True;
 end;


 procedure TPopulation.SetupWindow;
 begin
  TDialog.SetupWindow;
  SendDlgItemMessage(HWindow,id_Select1,bm_SetCheck,1,0);
 end;

 procedure TPopulation.Select1;
 begin
  SendDlgItemMessage(HWindow,id_Select1,bm_SetCheck,1,0);
 end;

 procedure TPopulation.Select2;
 begin
  SendDlgItemMessage(HWindow,id_Select2,bm_SetCheck,1,0);
 end;

 procedure TPopulation.Ok;
 begin
  if SendDlgItemMessage(HWindow,id_Select1,bm_GetCheck,0,0)<>0
  then TheGame^.IsSymmetric:=True
  else TheGame^.IsSymmetric:=False;
  EndDlg(id_Ok);
 end;

procedure TChooseColor.Blue;
begin
 EndDlg(id_Blue);
end;

procedure TChooseColor.Red;
begin
 EndDlg(id_Red);
end;

procedure TChooseColor.Green;
begin
 EndDlg(id_Green);
end;

procedure TChooseColor.Black;
begin
 EndDlg(id_Black);
end;

procedure TChooseColor.Cyan;
begin
 EndDlg(id_Cyan);
end;

procedure TChooseColor.Pink;
begin
 EndDlg(id_Pink);
end;

procedure TChooseColor.Yellow;
begin
 EndDlg(id_Yellow);
end;

procedure TChooseColor.Gray;
begin
 EndDlg(id_Gray);
end;

procedure TChooseColor.Pastel;
begin
 EndDlg(id_Pastel);
end;

procedure TChooseColor.Purple;
begin
 EndDlg(id_Purple);
end;

procedure TChooseColor.Khaki;
begin
 EndDlg(id_Khaki);
end;

procedure TChooseColor.Neon;
begin
 EndDlg(id_Neon);
end;

constructor TMakeEvolver.Init(AParent:PWindowsObject;AResource:PChar;AnEvolver:PEvolver);
begin
 TDialog.Init(AParent,AResource);
 DlgEvolver:=New(PEvolver,Init(TheGame));
 DlgEvolver^.Duplicate(False,AnEvolver);  {AnEvolver can be nil. If so, this creates ExitStep}
{ DlgEvolver:=AnEvolver;      {This didn't allow canceling the editing}
 SelectEvObj:=nil;
end;

procedure TMakeEvolver.SetupWindow;
var AName: NameType;
 procedure ShowPlayer(APlayer:PPlayer);far;
 begin
   StrCopy(AName,APlayer^.ShowName);
   SendDlgItemMessage(HWindow,202,cb_AddString,0,LongInt(@AName));
 end;
begin
 TDialog.SetupWindow;
 with DlgEvolver^ do begin
  SetDlgItemText(HWindow,120,ShowName);
  SendDlgItemMessage(HWindow,202,cb_ResetContent,0,0);
  SendDlgItemMessage(HWindow,122,cb_ResetContent,0,0);
  with TheGame^ do
  if IsSymmetric
  then begin
   Owner:=PlayerSet^.At(0);
   ShowPlayer(Owner);
  end else PlayerSet^.ForEach(@ShowPlayer);
 end;
 UpdateDialog;
end;

procedure TMakeEvolver.MakeVariable;
begin
 Application^.ExecDialog(New(PDefEvVar,Init(@Self,'DEF_VRBL_DLG',DlgEvolver,nil,Index)));
 UpdateDialog;
end;

procedure TMakeEvolver.MakeAssignment;
begin
 Application^.ExecDialog(New(PDefAssign,Init(@Self,'DEF_ASGN_DLG',DlgEvolver,nil,Index)));
 UpdateDialog;
end;

procedure TMakeEvolver.MakeTest;
begin
 Application^.ExecDialog(New(PDefTest,Init(@Self,'DEF_TEST_DLG',DlgEvolver,nil,Index)));
 UpdateDialog;
end;

procedure TMakeEvolver.MakeStep;
begin
 Application^.ExecDialog(New(PDefStep,Init(@Self,'DEF_STEP_DLG',DlgEvolver,nil,Index)));
 UpdateDialog;
end;

procedure TMakeEvolver.UpdateOwner;
var AName: NameType;
 procedure ShowStrategy(AStrategy:PStrategy); far;
 begin
  StrCopy(AName,AStrategy^.ShowName);
  if (AStrategy^.Owner=DlgEvolver^.Owner)
  then SendDlgItemMessage(HWindow,122,cb_AddString,0,LongInt(@AName));
 end;
begin
 SendDlgItemMessage(HWindow,122,cb_ResetContent,0,0);
 with DlgEvolver^ do
 if Owner<>nil
 then begin
  PGameType(Game)^.StrategySet^.ForEach(@ShowStrategy);
  StrCopy(AName,Owner^.ShowName);
  SendDlgItemMessage(HWindow,202,cb_SelectString,0,LongInt(@AName));
 end;
end;

procedure TMakeEvolver.UpdateDialog;
var LName:LongName;
 procedure ShowObject(AnEvolverObject:PEvBasic);far;
 begin
  if AnEvolverObject=nil then Exit;
  StrCopy(LName,AnEvolverObject^.Description);
  SendDlgItemMessage(HWindow,420,lb_AddString,0,LongInt(@LName));
 end;
begin
 with DlgEvolver^ do begin
  UpdateOwner;
  SetDlgItemText(HWindow,121,@ColorStr);
  SendDlgItemMessage(HWindow,420,lb_ResetContent,0,0);
  if Default<>nil
  then begin
   StrCopy(LName,Default^.ShowName);
   SendDlgItemMessage(HWindow,122,cb_SelectString,0,LongInt(@LName));
  end;
  StrCopy(LName,'DFLT ');
  if Default<>nil
  then StrCat(LName,Default^.ShowName)
  else StrCat(LName,'UNDEF');
  SendDlgItemMessage(HWindow,420,lb_AddString,0,LongInt(@LName));
  UpdateObjects(nil);
  DlgEvList.ForEach(@ShowObject);
 end;
end;

procedure TMakeEvolver.MakeColor;
begin
 DlgEvolver^.SetColor(Application^.ExecDialog(New(PChooseColor,Init(@Self,'COLOR_DLG'))));
 UpdateDialog;
end;

procedure TMakeEvolver.MakeDefault;
var I,J:Integer;
 procedure MatchIndex(AStrategy:PStrategy);far;
 begin
  if AStrategy^.Owner=DlgEvolver^.Owner
  then begin
   I:=I+1;
   if J=I
   then DlgEvolver^.SetDefault(AStrategy);
  end;
 end;
begin
 I:=-1;
 J:=SendDlgItemMessage(HWindow,122,cb_GetCurSel,0,0);
 if J>=0
 then TheGame^.StrategySet^.ForEach(@MatchIndex);
 UpdateDialog;
end;

procedure TMakeEvolver.MakeOwner;
var I:Byte;
begin
 I:=SendDlgItemMessage(HWindow,202,cb_GetCurSel,0,0);
 if (I>=0) and (I<TheGame^.PlayerSet^.Count)
 then DlgEvolver^.SetOwner(TheGame^.PlayerSet^.At(I));
 UpdateDialog;
end;

procedure TMakeEvolver.Edit;
begin
 if (Index>0) and (Index<=DlgEvolver^.DlgEvList.Count)
 then SelectEvObj:=DlgEvolver^.DlgEvList.At(Index-1) else Exit;
 case SelectEvObj^.ObjectType of
  lt_RealVar, lt_OwnChce, lt_OppChce
    : Application^.ExecDialog(New(PDefEvVar,Init(@Self,'DEF_VRBL_DLG',DlgEvolver,PEvVrbl(SelectEvObj),-1)));
  lt_SetOwn, lt_SetOpp, lt_SetReal, lt_SetOper, lt_SetResp
   : Application^.ExecDialog(New(PDefAssign,Init(@Self,'DEF_ASGN_DLG',DlgEvolver,PEvAssgn(SelectEvObj),-1)));
  lt_TestOwn, lt_TestOpp, lt_TestReal, lt_TestBool
   : Application^.ExecDialog(New(PDefTest,Init(@Self,'DEF_TEST_DLG',DlgEvolver,PEvTest(SelectEvObj),-1)));
  lt_IfThen, lt_IfThenElse, lt_Goto
   : Application^.ExecDialog(New(PDefStep,Init(@Self,'DEF_STEP_DLG',DlgEvolver,PEvStep(SelectEvObj),-1)));
 end;
 UpdateDialog;
end;

procedure TMakeEvolver.Cut;
begin
 if (Index>0) and (Index<=DlgEvolver^.DlgEvList.Count)
 then SelectEvObj:=DlgEvolver^.DlgEvList.At(Index-1) else Exit;
 if (SelectEvObj=nil) or (SelectEvObj=DlgEvolver^.ExitStep) then Exit;
 DlgEvolver^.DeleteLine(SelectEvObj);     {Removes the object from program list but do not free it}
 UpdateDialog;
 Index:=-1;
end;

procedure TMakeEvolver.Paste;
begin
 if (SelectEvObj=nil) or (SelectEvObj=DlgEvolver^.ExitStep) then Exit;
 with DlgEvolver^ do
 if (Index>0) and (Index<=DlgEvList.Count)
 then AddLine(Index-1,SelectEvObj);
 UpdateDialog;
 SelectEvObj:=nil;
end;

procedure TMakeEvolver.Delete;
begin
 if (Index>0) and (Index<=DlgEvolver^.DlgEvList.Count)
 then SelectEvObj:=DlgEvolver^.DlgEvList.At(Index-1) else Exit;
 if (SelectEvObj=nil) or (SelectEvObj=DlgEvolver^.ExitStep) then Exit;
 DlgEvolver^.DeleteLine(SelectEvObj);     {Removes the object from program list}
 UpdateDialog;
 Dispose(SelectEvObj);  {This is really delete}
 SelectEvObj:=nil;
 Index:=-1;
end;

procedure TMakeEvolver.Select;
begin
 Index:=SendDlgItemMessage(HWindow,id_List,lb_GetCurSel,0,0);   {Since Index is TMakeEvolver var, it sticks}
end;

procedure TMakeEvolver.Ok;
var IsValid: Boolean;
begin
 GetDlgItemText(HWindow,120,NewName,SizeOf(NewName));
 DlgEvolver^.SetName(NewName);
 IsValid:=True;
 with DlgEvolver^ do begin
  if (StrLen(NewName)<=0) then IsValid:=False;
  if ColorID=cl_White then IsValid:=False;
  if Owner=nil then IsValid:=False;
  if Default=nil then IsValid:=False;
 end;
 if IsValid
 then begin
  TheGame^.EvolverSet^.Insert(DlgEvolver);
  {Add code here to handle the twin for sym case}
  DlgEvolver^.MakeTwin(nil);
  DlgEvolver:=nil;
  EndDlg(id_Ok);
 end else MessageBox(HWindow,'Invalid strategy','Error',mb_Ok or mb_IconStop);
end;

procedure TMakeEvolver.Cancel;
begin
  Dispose(DlgEvolver);  {free memory}
  DlgEvolver:=nil;
  EndDlg(id_Cancel);
end;

{************* EvObject dialogs implementation ***************}

constructor TDefEvBasic.Init(AParent:PWindowsObject;AResource:PChar;AnEvolver:PEvolver;AnIndex:Integer);
 procedure ReFillEach(AnEvObject:PEvBasic);far;
 begin
  if AnEvObject=nil then Exit;
  with AnEvObject^ do case ObjectType of
   lt_RealVar                                         : RealList.Insert(AnEvObject);
   lt_OwnChce,lt_OppChce                              : ChceList.Insert(AnEvObject);
   lt_TestOwn,lt_TestOpp,lt_TestReal,lt_TestBool      : TestList.Insert(AnEvObject);
   lt_SetOwn,lt_SetOpp,lt_SetReal,lt_SetOper,lt_SetResp,
   lt_IfThen,lt_IfThenElse,lt_Goto,lt_Exit            : StepList.Insert(AnEvObject);
  end;
 end;
begin
 TDialog.Init(AParent,AResource);
 DlgEvolver:=AnEvolver;
 Index:=AnIndex;
 RealList.Init(50,50);
 ChceList.Init(50,50);
 TestList.Init(50,50);
 StepList.Init(50,50);
 DlgEvolver^.DlgEvList.ForEach(@ReFillEach);    {Need to fill in the lists..}
end;

destructor TDefEvBasic.Done;
begin
 RealList.DeleteAll;
 ChceList.DeleteAll;
 TestList.DeleteAll;
 StepList.DeleteAll;
 TDialog.Done;
end;

constructor TDefEvVar.Init(AParent:PWindowsObject;AResource:PChar;AnEvolver:PEvolver;AnObject:PEvVrbl;AnIndex:Integer);
begin
 TDefEvBasic.Init(AParent,AResource,AnEvolver,AnIndex);
 EditEvVar:=AnObject;
 DlgEvVar.Duplicate(EditEvVar);
end;

procedure TDefEvVar.SetupWindow;
begin
 TDialog.SetupWindow;
 with DlgEvVar do begin
  SetDlgItemText(HWindow,200,ShowName);
  case ObjectType of
   lt_OwnChce : SendDlgItemMessage(HWindow,lt_OwnChce,bm_SetCheck,1,0);
   lt_OppChce : SendDlgItemMessage(HWindow,lt_OppChce,bm_SetCheck,1,0);
   lt_RealVar : SendDlgItemMessage(HWindow,lt_RealVar,bm_SetCheck,1,0);
  end;
 end;
end;

procedure TDefEvVar.Ok;
begin
 with DlgEvVar do begin
  GetDlgItemText(HWindow,200,NewName,5);
  SetName(NewName);
  if SendDlgItemMessage(HWindow,lt_OwnChce,bm_GetCheck,0,0)<>0 then SetEvType(lt_OwnChce);
  if SendDlgItemMessage(HWindow,lt_OppChce,bm_GetCheck,0,0)<>0 then SetEvType(lt_OppChce);
  if SendDlgItemMessage(HWindow,lt_RealVar,bm_GetCheck,0,0)<>0 then SetEvType(lt_RealVar);
 end;
 if EditEvVar=nil
 then begin  {Create and insert a new variable}
  EditEvVar:=New(PEvVrbl,Init(TheGame,DlgEvolver));
  EditEvVar^.SetEvType(DlgEvVar.ObjectType);
  DlgEvolver^.AddLine(Index-1,EditEvVar);
 end;
 EditEvVar^.Duplicate(@DlgEvVar);  {Duplicate edited properties}
 if IsReservedWord(@NewName)
 then WhatIsWrong(HWindow,'Reserved Word')
 else EndDlg(id_Ok);
end;

constructor TSetReal.Init(AParent:PWindowsObject;AResource:PChar;AnEvolver:PEvolver;AnEvAssgn:PEvAssgn);
begin
 TDefEvBasic.Init(AParent,AResource,AnEvolver,-1);
 RealAssgn:=AnEvAssgn;
end;

procedure TSetReal.SetupWindow;
var AName: NameType;
 procedure ShowVar(AVar:PEvVrbl{Var});far;
 begin
  StrCopy(AName,AVar^.ShowName);
  SendDlgItemMessage(HWindow,301,cb_AddString,0,LongInt(@AName));
  SendDlgItemMessage(HWindow,302,cb_AddString,0,LongInt(@AName));
 end;
begin
 TDialog.SetupWindow;
 SendDlgItemMessage(HWindow,301,cb_ResetContent,0,0);
 SendDlgItemMessage(HWindow,302,cb_ResetContent,0,0);
 RealList.ForEach(@ShowVar);
 with RealAssgn^ do begin {Show assignments and operations}
  case StepType of
   at_ToVar   : SendDlgItemMessage(HWindow,at_ToVar,bm_SetCheck,1,0);
   at_ToConst : begin
                 SendDlgItemMessage(HWindow,at_ToConst,bm_SetCheck,1,0);
                 StrCopy(AName,StringReal(TheReal{Cnst},7));
                 SendDlgItemMsg(303,wm_SetText,0,LongInt(@AName));
                end;
   at_ToTurn  : SendDlgItemMessage(HWindow,at_ToTurn,bm_SetCheck,1,0);
   at_ToRand  : SendDlgItemMessage(HWindow,at_ToRand,bm_SetCheck,1,0);
   at_ToOwn   : SendDlgItemMessage(HWindow,at_ToOwn,bm_SetCheck,1,0);
   at_ToOpp   : SendDlgItemMessage(HWindow,at_ToOpp,bm_SetCheck,1,0);
  end;
  if AssgnVar<>nil then begin
   StrCopy(AName,AssgnVar^.ShowName);
   SendDlgItemMessage(HWindow,301,cb_SelectString,0,LongInt(@AName));
  end;
  if ToVar<>nil then begin
   StrCopy(AName,ToVar^.ShowName);
   SendDlgItemMessage(HWindow,302,cb_SelectString,0,LongInt(@AName));
  end;
 end;
end;

procedure TSetReal.Ok;
var I:Byte; AName:NameType; valCode:Integer;InfoString: LongName;
begin
 with RealAssgn^ do begin {Show assignments and operations}
  if SendDlgItemMessage(HWindow,at_ToVar,bm_GetCheck,0,0)<>0 then SetLocalType(True,at_ToVar);
  if SendDlgItemMessage(HWindow,at_ToConst,bm_GetCheck,0,0)<>0 then SetLocalType(True,at_ToConst);
  if SendDlgItemMessage(HWindow,at_ToTurn,bm_GetCheck,0,0)<>0 then SetLocalType(True,at_ToTurn);
  if SendDlgItemMessage(HWindow,at_ToRand,bm_GetCheck,0,0)<>0 then SetLocalType(True,at_ToRand);
  if SendDlgItemMessage(HWindow,at_ToOwn,bm_GetCheck,0,0)<>0 then SetLocalType(True,at_ToOwn);
  if SendDlgItemMessage(HWindow,at_ToOpp,bm_GetCheck,0,0)<>0 then SetLocalType(True,at_ToOpp);
  with DlgEvolver^ do begin
   I:=SendDlgItemMessage(HWindow,301,cb_GetCurSel,0,0);
   if (I>=0) and (I<RealList.Count) then SetLocalVar(1,RealList.At(I));
   if StepType<>at_ToVar then SetLocalVar(2,nil) else begin
    I:=SendDlgItemMessage(HWindow,302,cb_GetCurSel,0,0);
    if ((I>=0) and (I<RealList.Count)) then SetLocalVar(2,RealList.At(I));
   end;
  end;
  if StepType=at_ToConst then begin
   GetDlgItemText(HWindow,303,AName,NameSize);
   Val(AName,TheReal{Cnst},valCode);
   if (valCode<>0)
   then begin
    LoadString(HInstance,126,InfoString,LongSize);
    WhatIsWrong(HWindow,InfoString);
   end;
  end;
 end;
 EndDlg(id_Ok);
end;

constructor TSetOper.Init(AParent:PWindowsObject;AResource:PChar;AnEvolver:PEvolver;AnEvAssgn:PEvAssgn);
begin
 TDefEvBasic.Init(AParent,AResource,AnEvolver,-1);
 RealAssgn:=AnEvAssgn;
end;

procedure TSetOper.SetupWindow;
var AName: NameType;
 procedure ShowVar(AVar:PEvVrbl{Var});far;
 begin
  StrCopy(AName,AVar^.ShowName);
  SendDlgItemMessage(HWindow,301,cb_AddString,0,LongInt(@AName));
  SendDlgItemMessage(HWindow,302,cb_AddString,0,LongInt(@AName));
 end;
begin
 TDialog.SetupWindow;
 SendDlgItemMessage(HWindow,301,cb_ResetContent,0,0);
 SendDlgItemMessage(HWindow,302,cb_ResetContent,0,0);
 RealList.ForEach(@ShowVar);
 with RealAssgn^ do begin {Show assignments and operations}
  case OpType of
   op_Plus    : SendDlgItemMessage(HWindow,op_Plus,bm_SetCheck,1,0);
   op_Minus   : SendDlgItemMessage(HWindow,op_Minus,bm_SetCheck,1,0);
   op_Times   : SendDlgItemMessage(HWindow,op_Times,bm_SetCheck,1,0);
   op_DivBy   : SendDlgItemMessage(HWindow,op_DivBy,bm_SetCheck,1,0);
  end;
  case StepType of
   at_ToVar   : begin
                 SendDlgItemMessage(HWindow,at_ToVar,bm_SetCheck,1,0);
                 if ToVar<>nil then begin
                  StrCopy(AName,ToVar^.ShowName);
                  SendDlgItemMessage(HWindow,302,cb_SelectString,0,LongInt(@AName));
                 end;
                end;
   at_ToConst : begin
                 SendDlgItemMessage(HWindow,at_ToConst,bm_SetCheck,1,0);
                 StrCopy(AName,StringReal(TheReal{Cnst},7));
                 SendDlgItemMsg(303,wm_SetText,0,LongInt(@AName));
                end;
  end;
  if AssgnVar<>nil then begin
   StrCopy(AName,AssgnVar^.ShowName);
   SendDlgItemMessage(HWindow,301,cb_SelectString,0,LongInt(@AName));
  end;
 end;
end;

procedure TSetOper.UnCheckOp;
var I:Byte;
begin
 for I:=op_Plus to op_DivBy
 do SendDlgItemMessage(HWindow,I,bm_SetCheck,0,0);
end;

procedure TSetOper.OpPlus;
begin
 UnCheckOp;
 SendDlgItemMessage(HWindow,Op_Plus,bm_SetCheck,1,0);
end;

procedure TSetOper.OpMinus;
begin
 UnCheckOp;
 SendDlgItemMessage(HWindow,Op_Minus,bm_SetCheck,1,0);
end;

procedure TSetOper.OpTimes;
begin
 UnCheckOp;
 SendDlgItemMessage(HWindow,Op_Times,bm_SetCheck,1,0);
end;

procedure TSetOper.OpDivBy;
begin
 UnCheckOp;
 SendDlgItemMessage(HWindow,Op_DivBy,bm_SetCheck,1,0);
end;

procedure TSetOper.SetToVar;
begin
 SendDlgItemMessage(HWindow,at_ToConst,bm_SetCheck,0,0);
 SendDlgItemMessage(HWindow,at_ToVar,bm_SetCheck,1,0);
end;

procedure TSetOper.SetToConst;
begin
 SendDlgItemMessage(HWindow,at_ToVar,bm_SetCheck,0,0);
 SendDlgItemMessage(HWindow,at_ToConst,bm_SetCheck,1,0);
end;

procedure TSetOper.Ok;
var I:Byte; AName:NameType; valCode:Integer;InfoString: LongName;
begin
 with RealAssgn^ do begin {Show assignments and operations}
  if SendDlgItemMessage(HWindow,at_ToVar,bm_GetCheck,0,0)<>0 then SetLocalType(True,at_ToVar);
  if SendDlgItemMessage(HWindow,at_ToConst,bm_GetCheck,0,0)<>0 then SetLocalType(True,at_ToConst);
  if SendDlgItemMessage(HWindow,op_Plus,bm_GetCheck,0,0)<>0 then SetLocalType(False,op_Plus);
  if SendDlgItemMessage(HWindow,op_Minus,bm_GetCheck,0,0)<>0 then SetLocalType(False,op_Minus);
  if SendDlgItemMessage(HWindow,op_Times,bm_GetCheck,0,0)<>0 then SetLocalType(False,op_Times);
  if SendDlgItemMessage(HWindow,op_DivBy,bm_GetCheck,0,0)<>0 then SetLocalType(False,op_DivBy);
  with DlgEvolver^ do begin
   I:=SendDlgItemMessage(HWindow,301,cb_GetCurSel,0,0);
   if (I>=0) and (I<RealList.Count) then SetLocalVar(1,RealList.At(I));
   if StepType=at_ToVar then begin
    I:=SendDlgItemMessage(HWindow,302,cb_GetCurSel,0,0);
    if ((I>=0) and (I<RealList.Count)) then SetLocalVar(2,RealList.At(I));
   end else SetLocalVar(2,nil);
  end;
  if StepType=at_ToConst then begin
   GetDlgItemText(HWindow,303,AName,NameSize);
   Val(AName,TheReal{Cnst},valCode);
   if (valCode<>0)
   then begin
    LoadString(HInstance,126,InfoString,LongSize);
    WhatIsWrong(HWindow,InfoString);
   end;
  end;
 end;
 EndDlg(id_Ok);
end;

constructor TSetChce.Init(AParent:PWindowsObject;AResource:PChar;AnEvolver:PEvolver;AnEvAssgn:PEvAssgn;AndIsOwn:Boolean);
begin
 TDefEvBasic.Init(AParent,AResource,AnEvolver,-1);
 ChceAssgn:=AnEvAssgn;
 DlgChceList.Init(20,20);
 StratList.Init(20,20);
 IsOwn:=AndIsOwn;
end;

procedure TSetChce.SetupWindow;
var AName: NameType; I:Byte;
 procedure ShowVar(AVar:PEvVrbl{Var});far;
 begin
  StrCopy(AName,AVar^.ShowName);
  SendDlgItemMessage(HWindow,300,cb_AddString,0,LongInt(@AName));
  SendDlgItemMessage(HWindow,301,cb_AddString,0,LongInt(@AName));
 end;
 procedure FillChceList(AVar:PEvVrbl{Var});far;
 begin
  if IsOwn and (AVar^.ObjectType=lt_OwnChce) then DlgChceList.Insert(AVar);
  if (not IsOwn) and (AVar^.ObjectType=lt_OppChce) then DlgChceList.Insert(AVar);
 end;
 procedure FillStratList(AStrat:PStrategy);far;
 begin
  if IsOwn then if AStrat^.Owner=DlgEvolver^.Owner then StratList.Insert(AStrat);
  if not IsOwn then if AStrat^.Owner<>DlgEvolver^.Owner then StratList.Insert(AStrat);
 end;
 procedure ShowStrat(AStrat:PStrategy);far;
 begin
  StrCopy(AName,AStrat^.ShowName);
  SendDlgItemMessage(HWindow,302,cb_AddString,0,LongInt(@AName));
 end;
begin
 TDialog.SetupWindow;
 SendDlgItemMessage(HWindow,300,cb_ResetContent,0,0);
 SendDlgItemMessage(HWindow,301,cb_ResetContent,0,0);
 SendDlgItemMessage(HWindow,302,cb_ResetContent,0,0);
 SendDlgItemMessage(HWindow,105,cb_ResetContent,0,0);
 DlgChceList.DeleteAll;
 ChceList.ForEach(@FillChceList);             {Create choice list}
 DlgChceList.ForEach(@ShowVar);
 StratList.DeleteAll;
 with DlgEvolver^ do
 PGameType(Game)^.StrategySet^.ForEach(@FillStratList);  {Create StratList}
 StratList.ForEach(@ShowStrat);
 for I:=0 to 3 do begin                                   {Show delays}
  Str(I,AName);
  SendDlgItemMessage(HWindow,105,cb_AddString,0,LongInt(@AName));
 end;
 with ChceAssgn^ do begin                                 {Show existing assignment}
  if AssgnVar<>nil then begin                             {Show assigned var}
   StrCopy(AName,AssgnVar^.ShowName);
   SendDlgItemMessage(HWindow,300,cb_SelectString,0,LongInt(@AName));
  end;
  case StepType of
   at_ToVar   : begin
                 SendDlgItemMessage(HWindow,at_ToVar,bm_SetCheck,1,0);
                 if (ToVar<>nil) then begin
                  StrCopy(AName,ToVar^.ShowName);
                  SendDlgItemMessage(HWindow,301,cb_SelectString,0,LongInt(@AName));
                 end;
                end;
   at_ToConst : begin
                 SendDlgItemMessage(HWindow,at_ToConst,bm_SetCheck,1,0);
                 if (TheStrat{Cnst}<>nil) then begin
                  StrCopy(AName,TheStrat{Cnst}^.ShowName);
                  SendDlgItemMessage(HWindow,302,cb_SelectString,0,LongInt(@AName));
                 end;
                end;
   at_ToResp  : begin
                 SendDlgItemMessage(HWindow,at_ToResp,bm_SetCheck,1,0);
                 SendDlgItemMessage(HWindow,105,cb_SetCurSel,Delay,0);
                end;
  end;
 end;
end;

procedure TSetChce.Ok;
var I:Byte;
begin
 with ChceAssgn^ do begin
  if SendDlgItemMessage(HWindow,at_ToVar,bm_GetCheck,0,0)<>0 then SetLocalType(True,at_ToVar);
  if SendDlgItemMessage(HWindow,at_ToConst,bm_GetCheck,0,0)<>0 then SetLocalType(True,at_ToConst);
  if SendDlgItemMessage(HWindow,at_ToResp,bm_GetCheck,0,0)<>0 then SetLocalType(True,at_ToResp);
  with DlgEvolver^ do begin
   I:=SendDlgItemMessage(HWindow,300,cb_GetCurSel,0,0);
   if (I>=0) and (I<DlgChceList.Count) then SetLocalVar(1,DlgChceList.At(I));
   I:=SendDlgItemMessage(HWindow,301,cb_GetCurSel,0,0);
   if (StepType=at_ToVar) and ((I>=0) and (I<DlgChceList.Count)) then SetLocalVar(2,DlgChceList.At(I));
   I:=SendDlgItemMessage(HWindow,302,cb_GetCurSel,0,0);
   if (StepType=at_ToConst) and ((I>=0) and (I<StratList.Count)) then TheStrat{Cnst}:=StratList.At(I);
   I:=SendDlgItemMessage(HWindow,105,cb_GetCurSel,0,0);
   if (StepType=at_ToResp) and ((I>=0) and (I<=3)) then Delay:=I else Delay:=0;
  end;
 end;
 EndDlg(id_Ok);
end;

constructor TSetResp.Init(AParent:PWindowsObject;AResource:PChar;AnEvolver:PEvolver;AnEvAssgn:PEvAssgn);
begin
 TDefEvBasic.Init(AParent,AResource,AnEvolver,-1);
 ChceAssgn:=AnEvAssgn;
 DlgChceList.Init(20,20);
 StratList.Init(20,20);
end;

procedure TSetResp.SetupWindow;
var AName: NameType; I:Byte;
 procedure ShowVar(AVar:PEvVrbl{Var});far;
 begin
  StrCopy(AName,AVar^.ShowName);
  SendDlgItemMessage(HWindow,301,cb_AddString,0,LongInt(@AName));
 end;
 procedure FillChceList(AVar:PEvVrbl{Var});far;
 begin
  if AVar^.ObjectType=lt_OwnChce then DlgChceList.Insert(AVar);
 end;
 procedure FillStratList(AStrat:PStrategy);far;
 begin
  if AStrat^.Owner=DlgEvolver^.Owner then StratList.Insert(AStrat);
 end;
 procedure ShowStrat(AStrat:PStrategy);far;
 begin
  StrCopy(AName,AStrat^.ShowName);
  SendDlgItemMessage(HWindow,302,cb_AddString,0,LongInt(@AName));
 end;
begin
 TDialog.SetupWindow;
 SendDlgItemMessage(HWindow,301,cb_ResetContent,0,0);
 SendDlgItemMessage(HWindow,302,cb_ResetContent,0,0);
 DlgChceList.DeleteAll;
 ChceList.ForEach(@FillChceList);              {Display appropriate Var list}
 DlgChceList.ForEach(@ShowVar);
 StratList.DeleteAll;
 with DlgEvolver^ do
 PGameType(Game)^.StrategySet^.ForEach(@FillStratList);  {Create StratList}
 StratList.ForEach(@ShowStrat);
 with ChceAssgn^ do begin                                 {Show existing assignment}
  case StepType of
   at_ToVar   : begin
                 SendDlgItemMessage(HWindow,at_ToVar,bm_SetCheck,1,0);
                 if (ToVar<>nil) then begin
                  StrCopy(AName,ToVar^.ShowName);
                  SendDlgItemMessage(HWindow,301,cb_SelectString,0,LongInt(@AName));
                 end;
                end;
   at_ToConst : begin
                 SendDlgItemMessage(HWindow,at_ToConst,bm_SetCheck,1,0);
                 if (TheStrat{Cnst}<>nil) then begin
                  StrCopy(AName,TheStrat{Cnst}^.ShowName);
                  SendDlgItemMessage(HWindow,302,cb_SelectString,0,LongInt(@AName));
                 end;
                end;
  end;
 end;
end;

procedure TSetResp.Ok;
var I:Byte;
begin
 with ChceAssgn^ do begin
  if SendDlgItemMessage(HWindow,at_ToVar,bm_GetCheck,0,0)<>0 then SetLocalType(True,at_ToVar);
  if SendDlgItemMessage(HWindow,at_ToConst,bm_GetCheck,0,0)<>0 then SetLocalType(True,at_ToConst);
  I:=SendDlgItemMessage(HWindow,301,cb_GetCurSel,0,0);
  with DlgEvolver^ do if (StepType=at_ToVar) and ((I>=0) and (I<DlgChceList.Count)) then SetLocalVar(2,DlgChceList.At(I));
  I:=SendDlgItemMessage(HWindow,302,cb_GetCurSel,0,0);
  if (StepType=at_ToConst) and ((I>=0) and (I<StratList.Count)) then TheStrat{Cnst}:=StratList.At(I);
 end;
 EndDlg(id_Ok);
end;

constructor TDefStep.Init(AParent:PWindowsObject;AResource:PChar;AnEvolver:PEvolver;AnObject:PEvStep;AnIndex:Integer);
begin
 TDefEvBasic.Init(AParent,AResource,AnEvolver,-1);
 EditEvStep:=AnObject;
 Index:=AnIndex;
 DlgEvStep.Duplicate(EditEvStep);
end;

procedure TDefStep.SetupWindow;
var AName:NameType;
 procedure ShowTest(ATest:PEvTest);far;
 begin
  StrCopy(AName,ATest^.ShowName);
  SendDlgItemMessage(HWindow,301,cb_AddString,0,LongInt(@AName));
 end;
 procedure ShowStep(AStep:PEvStep);far;
 begin
  StrCopy(AName,AStep^.ShowName);
  SendDlgItemMessage(HWindow,302,cb_AddString,0,LongInt(@AName));
  SendDlgItemMessage(HWindow,303,cb_AddString,0,LongInt(@AName));
  SendDlgItemMessage(HWindow,304,cb_AddString,0,LongInt(@AName));
 end;
begin
 TDialog.SetupWindow;
 SendDlgItemMessage(HWindow,301,cb_ResetContent,0,0);
 SendDlgItemMessage(HWindow,302,cb_ResetContent,0,0);
 SendDlgItemMessage(HWindow,303,cb_ResetContent,0,0);
 SendDlgItemMessage(HWindow,304,cb_ResetContent,0,0);
 TestList.ForEach(@ShowTest);
 StepList.ForEach(@ShowStep);
 with DlgEvStep do begin
  SetDlgItemText(HWindow,200,ShowName);
  if EvTest<>nil then begin
   StrCopy(AName,EvTest^.ShowName);
   SendDlgItemMessage(HWindow,301,cb_SelectString,0,LongInt(@AName));
  end;
  if (Step1<>nil) and (ObjectType in [lt_IfThen,lt_IfThenElse])
  then begin
   StrCopy(AName,Step1^.ShowName);
   SendDlgItemMessage(HWindow,302,cb_SelectString,0,LongInt(@AName));
  end;
  if (Step2<>nil) and (ObjectType=lt_IfThenElse)
  then begin
   StrCopy(AName,Step2^.ShowName);
   SendDlgItemMessage(HWindow,303,cb_SelectString,0,LongInt(@AName));
  end;
  if (Step1<>nil) and (ObjectType=lt_Goto)
  then begin
   StrCopy(AName,Step1^.ShowName);
   SendDlgItemMessage(HWindow,304,cb_SelectString,0,LongInt(@AName));
  end;
  case ObjectType of
   lt_IfThen     : SendDlgItemMessage(HWindow,lt_IfThen,bm_SetCheck,1,0);
   lt_IfThenElse : begin
                    SendDlgItemMessage(HWindow,lt_IfThen,bm_SetCheck,1,0);
                    SendDlgItemMessage(HWindow,lt_IfThenElse,bm_SetCheck,1,0);
                   end;
   lt_Goto       : SendDlgItemMessage(HWindow,lt_Goto,bm_SetCheck,1,0);
  end;
 end;
end;

procedure TDefStep.Ok;
var I:Byte;
begin
 with DlgEvStep do begin
  GetDlgItemText(HWindow,200,NewName,5);
  SetName(NewName);
  if SendDlgItemMessage(HWindow,lt_IfThen,bm_GetCheck,0,0)<>0
  then if SendDlgItemMessage(HWindow,lt_IfThenElse,bm_GetCheck,0,0)<>0
       then SetEvType(lt_IfThenElse)
       else SetEvType(lt_IfThen);
  if SendDlgItemMessage(HWindow,lt_Goto,bm_GetCheck,0,0)<>0 then SetEvType(lt_Goto);
  with DlgEvolver^ do begin
   I:=SendDlgItemMessage(HWindow,301,cb_GetCurSel,0,0);
   if ((I>=0) and (I<TestList.Count)) then SetLocalVar(11,TestList.At(I)) else SetLocalVar(11,nil);
   if ObjectType in [lt_IfThen, lt_IfThenElse] then begin
    I:=SendDlgItemMessage(HWindow,302,cb_GetCurSel,0,0);
    if ((I>=0) and (I<StepList.Count)) then SetLocalVar(12,StepList.At(I)) else SetLocalVar(12,nil);
    I:=SendDlgItemMessage(HWindow,303,cb_GetCurSel,0,0);
    if ((I>=0) and (I<StepList.Count)) then SetLocalVar(13,StepList.At(I)) else SetLocalVar(13,nil);
   end;
   if ObjectType=lt_Goto then begin
    I:=SendDlgItemMessage(HWindow,304,cb_GetCurSel,0,0);
    if ((I>=0) and (I<StepList.Count)) then SetLocalVar(12,StepList.At(I)) else SetLocalVar(12,nil);
   end;
  end;
 end;
 if EditEvStep=nil
 then begin  {Create and insert a new test}
  EditEvStep:=New(PEvStep,Init(TheGame,DlgEvolver));
  EditEvStep^.SetEvType(DlgEvStep.ObjectType);
  DlgEvolver^.AddLine(Index-1,EditEvStep);
 end;
 EditEvStep^.Duplicate(@DlgEvStep);  {Transfer all edited properties}
 if IsReservedWord(@NewName)
 then WhatIsWrong(HWindow,'Reserved Word')
 else EndDlg(id_Ok);
end;

constructor TDefTest.Init(AParent:PWindowsObject;AResource:PChar;AnEvolver:PEvolver;AnObject:PEvTest;AnIndex:Integer);
begin
 TDefEvBasic.Init(AParent,AResource,AnEvolver,-1);
 EditEvTest:=AnObject;   {May be nil... signaling it must be created at Ok}
 Index:=AnIndex;
 DlgEvTest.Duplicate(EditEvTest);
 IsNotEdited:=True;
end;

procedure TDefTest.SetupWindow;
begin
 TDialog.SetupWindow;
 with DlgEvTest do begin
  SetDlgItemText(HWindow,200,ShowName);
  case ObjectType of
   lt_TestOwn  : SendDlgItemMessage(HWindow,lt_TestOwn,bm_SetCheck,1,0);
   lt_TestOpp  : SendDlgItemMessage(HWindow,lt_TestOpp,bm_SetCheck,1,0);
   lt_TestReal : SendDlgItemMessage(HWindow,lt_TestReal,bm_SetCheck,1,0);
   lt_TestBool : SendDlgItemMessage(HWindow,lt_TestBool,bm_SetCheck,1,0);
  end;
 end;
end;

constructor TTestChce.Init(AParent:PWindowsObject;AResource:PChar;AnEvolver:PEvolver;AnEvTest:PEvTest;AndIsOwn:Boolean);
begin
 TDefEvBasic.Init(AParent,AResource,AnEvolver,-1);
 ChceTest:=AnEvTest;
 DlgChceList.Init(20,20);
 StratList.Init(20,20);
 IsOwn:=AndIsOwn;
end;

procedure TTestChce.SetupWindow;
var AName: NameType; I:Byte;
 procedure ShowVar(AVar:PEvVrbl{Var});far;
 begin
  StrCopy(AName,AVar^.ShowName);
  SendDlgItemMessage(HWindow,300,cb_AddString,0,LongInt(@AName));
  SendDlgItemMessage(HWindow,301,cb_AddString,0,LongInt(@AName));
 end;
 procedure FillStratList(AStrat:PStrategy);far;
 begin
  if IsOwn then if AStrat^.Owner=DlgEvolver^.Owner then StratList.Insert(AStrat);
  if not IsOwn then if AStrat^.Owner<>DlgEvolver^.Owner then StratList.Insert(AStrat);
 end;
 procedure FillChceList(AVar:PEvVrbl{Var});far;
 begin
  if IsOwn and (AVar^.ObjectType=lt_OwnChce) then DlgChceList.Insert(AVar);
  if (not IsOwn) and (AVar^.ObjectType=lt_OppChce) then DlgChceList.Insert(AVar);
 end;
 procedure ShowStrat(AStrat:PStrategy);far;
 begin
  StrCopy(AName,AStrat^.ShowName);
  SendDlgItemMessage(HWindow,302,cb_AddString,0,LongInt(@AName));
 end;
begin
 TDialog.SetupWindow;
 SendDlgItemMessage(HWindow,300,cb_ResetContent,0,0);
 SendDlgItemMessage(HWindow,301,cb_ResetContent,0,0);
 SendDlgItemMessage(HWindow,302,cb_ResetContent,0,0);
 DlgChceList.DeleteAll;
 ChceList.ForEach(@FillChceList);             {Create choice list}
 DlgChceList.ForEach(@ShowVar);
 StratList.DeleteAll;
 with DlgEvolver^ do
 PGameType(Game)^.StrategySet^.ForEach(@FillStratList);  {Create StratList}
 StratList.ForEach(@ShowStrat);
 with ChceTest^ do begin {Show test}
  if TestVar<>nil then begin
   StrCopy(AName,TestVar^.ShowName);
   SendDlgItemMessage(HWindow,300,cb_SelectString,0,LongInt(@AName));
  end;
  case TestType of
   at_ToVar     : begin
                   SendDlgItemMessage(HWindow,at_ToVar,bm_SetCheck,1,0);
                   if ToVar<>nil then begin
                    StrCopy(AName,ToVar^.ShowName);
                    SendDlgItemMessage(HWindow,301,cb_SelectString,0,LongInt(@AName));
                   end;
                  end;
   at_ToConst   : begin
                   SendDlgItemMessage(HWindow,at_ToConst,bm_SetCheck,1,0);
                   if StratCnst<>nil then begin
                    StrCopy(AName,StratCnst^.ShowName);
                    SendDlgItemMessage(HWindow,302,cb_SelectString,0,LongInt(@AName));
                   end;
                  end;
  end;
  case BoolType of
   bt_EqualTo   : SendDlgItemMessage(HWindow,bt_EqualTo,bm_SetCheck,1,0);     {Same as}
   bt_DiffFrom  : SendDlgItemMessage(HWindow,bt_DiffFrom,bm_SetCheck,1,0);    {Not same}
  end;
 end;
end;

procedure TTestChce.UnCheckTest;
var I:Byte;
begin
 for I:=bt_EqualTo to bt_DiffFrom
 do SendDlgItemMessage(HWindow,I,bm_SetCheck,0,0);
end;

procedure TTestChce.UnCheckWhat;
var I:Byte;
begin
 for I:=at_ToVar to at_ToConst
 do SendDlgItemMessage(HWindow,I,bm_SetCheck,0,0);
end;

procedure TTestChce.AtToVar;
begin
 UnCheckWhat;
 SendDlgItemMessage(HWindow,at_ToVar,bm_SetCheck,1,0);
end;

procedure TTestChce.AtToConst;
begin
 UnCheckWhat;
 SendDlgItemMessage(HWindow,at_ToConst,bm_SetCheck,1,0);
end;

procedure TTestChce.BtEqualTo;
begin
 UnCheckTest;
 SendDlgItemMessage(HWindow,bt_EqualTo,bm_SetCheck,1,0);
end;

procedure TTestChce.BtDiffFrom;
begin
 UnCheckTest;
 SendDlgItemMessage(HWindow,bt_DiffFrom,bm_SetCheck,1,0);
end;

procedure TTestChce.Ok;
var I:Byte;
begin
 with ChceTest^ do begin {Record}
  if SendDlgItemMessage(HWindow,at_ToVar,bm_GetCheck,0,0)<>0 then SetLocalType(True,at_ToVar);
  if SendDlgItemMessage(HWindow,at_ToConst,bm_GetCheck,0,0)<>0 then SetLocalType(True,at_ToConst);
  if SendDlgItemMessage(HWindow,bt_EqualTo,bm_GetCheck,0,0)<>0 then SetLocalType(False,bt_EqualTo);
  if SendDlgItemMessage(HWindow,bt_DiffFrom,bm_GetCheck,0,0)<>0 then SetLocalType(False,bt_DiffFrom);
  with DlgEvolver^ do begin
   I:=SendDlgItemMessage(HWindow,300,cb_GetCurSel,0,0);
   if (I>=0) and (I<DlgChceList.Count) then SetLocalVar(1,DlgChceList.At(I));

   I:=SendDlgItemMessage(HWindow,301,cb_GetCurSel,0,0);
   if (TestType=at_ToVar) and ((I>=0) and (I<DlgChceList.Count)) then SetLocalVar(2,DlgChceList.At(I));
   I:=SendDlgItemMessage(HWindow,302,cb_GetCurSel,0,0);
   if (TestType=at_ToConst) and ((I>=0) and (I<StratList.Count)) then StratCnst:=StratList.At(I);
  end;
 end;
 EndDlg(id_Ok);
end;

constructor TTestReal.Init(AParent:PWindowsObject;AResource:PChar;AnEvolver:PEvolver;AnEvTest:PEvTest);
begin
 TDefEvBasic.Init(AParent,AResource,AnEvolver,-1);
 RealTest:=AnEvTest;
end;

procedure TTestReal.SetupWindow;
var AName: NameType;
 procedure ShowVar(AVar:PEvVrbl{Var});far;
 begin
  StrCopy(AName,AVar^.ShowName);
  SendDlgItemMessage(HWindow,301,cb_AddString,0,LongInt(@AName));
  SendDlgItemMessage(HWindow,302,cb_AddString,0,LongInt(@AName));
 end;
begin
 TDialog.SetupWindow;
 SendDlgItemMessage(HWindow,301,cb_ResetContent,0,0);
 SendDlgItemMessage(HWindow,302,cb_ResetContent,0,0);
 RealList.ForEach(@ShowVar);
 with RealTest^ do begin {Show assignments and operations}
  if TestVar<>nil then begin
   StrCopy(AName,TestVar^.ShowName);
   SendDlgItemMessage(HWindow,301,cb_SelectString,0,LongInt(@AName));
  end;
  case TestType of
   at_ToVar   : begin
                 SendDlgItemMessage(HWindow,at_ToVar,bm_SetCheck,1,0);
                 if ToVar<>nil then begin
                  StrCopy(AName,ToVar^.ShowName);
                  SendDlgItemMessage(HWindow,302,cb_SelectString,0,LongInt(@AName));
                 end;
                end;
   at_ToConst : begin
                 SendDlgItemMessage(HWindow,at_ToConst,bm_SetCheck,1,0);
                 StrCopy(AName,StringReal(RealCnst,7));
                 SendDlgItemMsg(303,wm_SetText,0,LongInt(@AName));
                end;
  end;
  case BoolType of
   bt_EqualTo  : SendDlgItemMessage(HWindow,bt_EqualTo,bm_SetCheck,1,0);
   bt_LessThan : SendDlgItemMessage(HWindow,bt_LessThan,bm_SetCheck,1,0);
   bt_MoreThan : SendDlgItemMessage(HWindow,bt_MoreThan,bm_SetCheck,1,0);
   bt_DiffFrom : SendDlgItemMessage(HWindow,bt_DiffFrom,bm_SetCheck,1,0);
  end;
 end;
end;

procedure TTestReal.UnCheckTest;
var I:Byte;
begin
 for I:=bt_EqualTo to bt_DiffFrom
 do SendDlgItemMessage(HWindow,I,bm_SetCheck,0,0);
end;

procedure TTestReal.UnCheckWhat;
var I:Byte;
begin
 for I:=at_ToVar to at_ToConst
 do SendDlgItemMessage(HWindow,I,bm_SetCheck,0,0);
end;

procedure TTestReal.AtToVar;
begin
 UnCheckWhat;
 SendDlgItemMessage(HWindow,at_ToVar,bm_SetCheck,1,0);
end;

procedure TTestReal.AtToConst;
begin
 UnCheckWhat;
 SendDlgItemMessage(HWindow,at_ToConst,bm_SetCheck,1,0);
end;

procedure TTestReal.BtEqualTo;
begin
 UnCheckTest;
 SendDlgItemMessage(HWindow,bt_EqualTo,bm_SetCheck,1,0);
end;

procedure TTestReal.BtLessThan;
begin
 UnCheckTest;
 SendDlgItemMessage(HWindow,bt_LessThan,bm_SetCheck,1,0);
end;

procedure TTestReal.BtMoreThan;
begin
 UnCheckTest;
 SendDlgItemMessage(HWindow,bt_MoreThan,bm_SetCheck,1,0);
end;

procedure TTestReal.BtDiffFrom;
begin
 UnCheckTest;
 SendDlgItemMessage(HWindow,bt_DiffFrom,bm_SetCheck,1,0);
end;

procedure TTestReal.Ok;
var I:Byte; AName:NameType; valCode:Integer;InfoString: LongName;
begin
 with RealTest^ do begin
  I:=SendDlgItemMessage(HWindow,301,cb_GetCurSel,0,0);
  if (I>=0) and (I<{DlgEvolver^.}RealList.Count) then SetLocalVar(1,{DlgEvolver^.}RealList.At(I)) else SetLocalVar(1,nil);
  if SendDlgItemMessage(HWindow,at_ToVar,bm_GetCheck,0,0)<>0
  then begin
   TestType:=at_ToVar;
   I:=SendDlgItemMessage(HWindow,302,cb_GetCurSel,0,0);
   if ((I>=0) and (I<{DlgEvolver^.}RealList.Count)) then SetLocalVar(2,{DlgEvolver^.}RealList.At(I)) else SetLocalVar(2,nil);
  end else SetLocalVar(2,nil);
  if SendDlgItemMessage(HWindow,at_ToConst,bm_GetCheck,0,0)<>0
  then begin
   TestType:=at_ToConst;
   GetDlgItemText(HWindow,303,AName,NameSize);
   Val(AName,RealCnst,valCode);
   if (valCode<>0) then begin
    LoadString(HInstance,126,InfoString,LongSize);
    WhatIsWrong(HWindow,InfoString);
   end;
  end;
  if SendDlgItemMessage(HWindow,bt_EqualTo,bm_GetCheck,0,0)<>0 then SetLocalType(False,bt_EqualTo);
  if SendDlgItemMessage(HWindow,bt_LessThan,bm_GetCheck,0,0)<>0 then SetLocalType(False,bt_LessThan);
  if SendDlgItemMessage(HWindow,bt_MoreThan,bm_GetCheck,0,0)<>0 then SetLocalType(False,bt_MoreThan);
  if SendDlgItemMessage(HWindow,bt_DiffFrom,bm_GetCheck,0,0)<>0 then SetLocalType(False,bt_DiffFrom);
 end;
 EndDlg(id_Ok);
end;

constructor TTestBool.Init(AParent:PWindowsObject;AResource:PChar;AnEvolver:PEvolver;AnEvTest:PEvTest);
begin
 TDefEvBasic.Init(AParent,AResource,AnEvolver,-1);
 BoolTest:=AnEvTest;
end;

procedure TTestBool.SetupWindow;
var AName: NameType; I:Byte;
 procedure ShowTest(ATest:PEvTest);far;
 begin
  StrCopy(AName,ATest^.ShowName);
  SendDlgItemMessage(HWindow,300,cb_AddString,0,LongInt(@AName));
  SendDlgItemMessage(HWindow,301,cb_AddString,0,LongInt(@AName));
 end;
begin
 TDialog.SetupWindow;                                                 {Identical to Assign Choice..}
 SendDlgItemMessage(HWindow,300,cb_ResetContent,0,0);
 SendDlgItemMessage(HWindow,301,cb_ResetContent,0,0);
 TestList.ForEach(@ShowTest);
 with BoolTest^ do begin {Show test}
  case TestType of
   bt_Neg1     : SendDlgItemMessage(HWindow,bt_Neg1,bm_SetCheck,1,0);
   bt_Neg2     : SendDlgItemMessage(HWindow,bt_Neg2,bm_SetCheck,1,0);
   bt_NegTwice : begin
                  SendDlgItemMessage(HWindow,bt_Neg1,bm_SetCheck,1,0);
                  SendDlgItemMessage(HWindow,bt_Neg2,bm_SetCheck,1,0);
                 end;
  end;
  case BoolType of
   bt_Or    : SendDlgItemMessage(HWindow,bt_Or,bm_SetCheck,1,0);
   bt_And   : SendDlgItemMessage(HWindow,bt_And,bm_SetCheck,1,0);
   bt_None  : SendDlgItemMessage(HWindow,bt_None,bm_SetCheck,1,0);
  end;
  if EvTest1<>nil then begin
   StrCopy(AName,EvTest1^.ShowName);
   SendDlgItemMessage(HWindow,300,cb_SelectString,0,LongInt(@AName));
  end;
  if EvTest2<>nil then begin
   StrCopy(AName,EvTest2^.ShowName);
   SendDlgItemMessage(HWindow,301,cb_SelectString,0,LongInt(@AName));
  end;
 end;
end;

procedure TTestBool.Ok;
var I:Byte;
begin
 with BoolTest^ do begin {Record}
  SetLocalType(True,bt_NoNeg); {Default}
  if SendDlgItemMessage(HWindow,bt_Neg1,bm_GetCheck,0,0)<>0
  then begin
   if SendDlgItemMessage(HWindow,bt_Neg2,bm_GetCheck,0,0)<>0
   then SetLocalType(True,bt_NegTwice)
   else SetLocalType(True,bt_Neg1);
  end else if SendDlgItemMessage(HWindow,bt_Neg2,bm_GetCheck,0,0)<>0 then SetLocalType(True,bt_Neg2);
  if SendDlgItemMessage(HWindow,bt_None,bm_GetCheck,0,0)<>0 then SetLocalType(False,bt_None);
  if SendDlgItemMessage(HWindow,bt_Or,bm_GetCheck,0,0)<>0 then SetLocalType(False,bt_Or);
  if SendDlgItemMessage(HWindow,bt_And,bm_GetCheck,0,0)<>0 then SetLocalType(False,bt_And);
  with DlgEvolver^ do begin
   I:=SendDlgItemMessage(HWindow,300,cb_GetCurSel,0,0);
   if ((I>=0) and (I<TestList.Count)) then SetLocalVar(3,TestList.At(I)) else SetLocalVar(3,nil);
   I:=SendDlgItemMessage(HWindow,301,cb_GetCurSel,0,0);
   if ((I>=0) and (I<TestList.Count)) then SetLocalVar(4,TestList.At(I)) else SetLocalVar(4,nil);
  end;
 end;
 EndDlg(id_Ok);
end;

procedure TDefTest.Edit;
begin
 IsNotEdited:=False;
 if SendDlgItemMessage(HWindow,lt_TestOwn,bm_GetCheck,0,0)<>0
 then Application^.ExecDialog(New(PTestChce,Init(@Self,'TEST_CHCE_DLG',DlgEvolver,@DlgEvTest,True)));
 if SendDlgItemMessage(HWindow,lt_TestOpp,bm_GetCheck,0,0)<>0
 then Application^.ExecDialog(New(PTestChce,Init(@Self,'TEST_CHCE_DLG',DlgEvolver,@DlgEvTest,False)));
 if SendDlgItemMessage(HWindow,lt_TestReal,bm_GetCheck,0,0)<>0
 then Application^.ExecDialog(New(PTestReal,Init(@Self,'TEST_REAL_DLG',DlgEvolver,@DlgEvTest)));
 if SendDlgItemMessage(HWindow,lt_TestBool,bm_GetCheck,0,0)<>0
 then Application^.ExecDialog(New(PTestBool,Init(@Self,'TEST_BOOL_DLG',DlgEvolver,@DlgEvTest)));
end;

procedure TDefTest.Ok;
begin
 if IsNotEdited
 then if MessageBox(HWindow,'Continue editing','Not Edited Yet',mb_YesNo or mb_IconQuestion)=idYes then Exit;
 with DlgEvTest do begin
  GetDlgItemText(HWindow,200,NewName,5);
  SetName(NewName);
  if SendDlgItemMessage(HWindow,lt_TestOwn,bm_GetCheck,0,0)<>0 then SetEvType(lt_TestOwn);
  if SendDlgItemMessage(HWindow,lt_TestOpp,bm_GetCheck,0,0)<>0 then SetEvType(lt_TestOpp);
  if SendDlgItemMessage(HWindow,lt_TestReal,bm_GetCheck,0,0)<>0 then SetEvType(lt_TestReal);
  if SendDlgItemMessage(HWindow,lt_TestBool,bm_GetCheck,0,0)<>0 then SetEvType(lt_TestBool);
 end;
 if EditEvTest=nil
 then begin  {Create and insert a new test}
  EditEvTest:=New(PEvTest,Init(TheGame,DlgEvolver));
  EditEvTest^.SetEvType(DlgEvTest.ObjectType);
  DlgEvolver^.AddLine(Index-1,EditEvTest);
 end;
 EditEvTest^.Duplicate(@DlgEvTest);  {Transfer all edited properties}
 if IsReservedWord(@NewName)
 then WhatIsWrong(HWindow,'Reserved Word')
 else EndDlg(id_Ok);
end;

constructor TDefAssign.Init(AParent:PWindowsObject;AResource:PChar;AnEvolver:PEvolver;AnObject:PEvAssgn;AnIndex:Integer);
begin
 TDefEvBasic.Init(AParent,AResource,AnEvolver,-1);
 EditEvAssgn:=AnObject;   {May be nil... signaling it must be created at Ok}
 Index:=AnIndex;
 DlgEvAssgn.Duplicate(EditEvAssgn);
 IsNotEdited:=True;
end;

procedure TDefAssign.SetupWindow;
begin
 TDialog.SetupWindow;
 with DlgEvAssgn do begin
  SetDlgItemText(HWindow,200,ShowName);
  case ObjectType of
   lt_SetOwn  : SendDlgItemMessage(HWindow,lt_SetOwn,bm_SetCheck,1,0);
   lt_SetOpp  : SendDlgItemMessage(HWindow,lt_SetOpp,bm_SetCheck,1,0);
   lt_SetReal : SendDlgItemMessage(HWindow,lt_SetReal,bm_SetCheck,1,0);
   lt_SetOper : SendDlgItemMessage(HWindow,lt_SetOper,bm_SetCheck,1,0);
   lt_SetResp : SendDlgItemMessage(HWindow,lt_SetResp,bm_SetCheck,1,0);
  end;
 end;
end;

procedure TDefAssign.EditChoice(IsOwn:Boolean);
begin {Define Choice Assignment}
 if IsOwn
 then ObjType:=lt_SetOwn
 else ObjType:=lt_SetOpp;
 Application^.ExecDialog(New(PSetChoice,Init(@Self,'SET_CHCE_DLG',DlgEvolver,@DlgEvAssgn,IsOwn)));
end;

procedure TDefAssign.EditReal;
begin {Define Real Assignment}
 ObjType:=lt_SetReal;
 Application^.ExecDialog(New(PSetReal,Init(@Self,'SET_REAL_DLG',DlgEvolver,@DlgEvAssgn)));
end;

procedure TDefAssign.EditOper;
begin {Define Real Assignment}
 ObjType:=lt_SetOper;
 Application^.ExecDialog(New(PSetOper,Init(@Self,'SET_OPER_DLG',DlgEvolver,@DlgEvAssgn)));
end;

procedure TDefAssign.EditResp;
begin {Define Resp Assignment}
 ObjType:=lt_SetResp;
 Application^.ExecDialog(New(PSetResp,Init(@Self,'SET_RESP_DLG',DlgEvolver,@DlgEvAssgn)));
end;

procedure TDefAssign.Edit;
begin
 IsNotEdited:=False;
 if SendDlgItemMessage(HWindow,lt_SetOwn,bm_GetCheck,0,0)<>0
 then EditChoice(True);
 if SendDlgItemMessage(HWindow,lt_SetOpp,bm_GetCheck,0,0)<>0
 then EditChoice(False);
 if SendDlgItemMessage(HWindow,lt_SetReal,bm_GetCheck,0,0)<>0
 then EditReal;
 if SendDlgItemMessage(HWindow,lt_SetOper,bm_GetCheck,0,0)<>0
 then EditOper;
 if SendDlgItemMessage(HWindow,lt_SetResp,bm_GetCheck,0,0)<>0
 then EditResp;
end;

procedure TDefAssign.Ok;
begin
 if IsNotEdited
 then if MessageBox(HWindow,'Continue editing','Not Edited Yet',mb_YesNo or mb_IconQuestion)=idYes then Exit;
 with DlgEvAssgn do begin
  GetDlgItemText(HWindow,200,NewName,5);
  SetName(NewName);
  if SendDlgItemMessage(HWindow,lt_SetOwn,bm_GetCheck,0,0)<>0 then SetEvType(lt_SetOwn);
  if SendDlgItemMessage(HWindow,lt_SetOpp,bm_GetCheck,0,0)<>0 then SetEvType(lt_SetOpp);
  if SendDlgItemMessage(HWindow,lt_SetReal,bm_GetCheck,0,0)<>0 then SetEvType(lt_SetReal);
  if SendDlgItemMessage(HWindow,lt_SetOper,bm_GetCheck,0,0)<>0 then SetEvType(lt_SetOper);
  if SendDlgItemMessage(HWindow,lt_SetResp,bm_GetCheck,0,0)<>0 then SetEvType(lt_SetResp);
 end;
 if EditEvAssgn=nil
 then begin  {Create and insert a new assignment}
  EditEvAssgn:=New(PEvAssgn,Init(TheGame,DlgEvolver));
  EditEvAssgn^.SetEvType(DlgEvAssgn.ObjectType);
  DlgEvolver^.AddLine(Index-1,EditEvAssgn);
 end;
 EditEvAssgn^.Duplicate(@DlgEvAssgn);  {Transfer all edited properties}
 if IsReservedWord(@NewName)
 then WhatIsWrong(HWindow,'Reserved Word')
 else EndDlg(id_Ok);
end;

{************* TEvolver type implementation **********}

procedure TDeleteEvolver.SetupWindow;
 procedure PrintName(AGameObject:PGameObject); far;
 begin
   SendDlgitemMsg(102,lb_AddString,0,LongInt(AGameObject^.ShowName));
 end;
begin
 SetWindowText(HWindow,'Choose Evolver');
 TheGame^.EvolverSet^.ForEach(@PrintName);
end;

procedure TDeleteEvolver.Delete;
var
 DlgEvolver  : PEvolver;
 EvolvIndex: Integer;
begin
 if Msg.LParamHi=lbn_SelChange
 then begin
  EvolvIndex:=SendDlgItemMsg(102,lb_GetCurSel,0,LongInt(0));
  DlgEvolver:=TheGame^.EvolverSet^.At(EvolvIndex);
  LoadString(HInstance,125,StringText,LongSize);
  LoadString(HInstance,16,StringTitle,LongSize);
  if MessageBox(HWindow,StrCat(StringText,DlgEvolver^.ShowName),
                  StringTitle,mb_OkCancel or mb_IconQuestion)=idOk
  then with TheGame^ do begin
   if DlgEvolver^.Twin<>nil
   then EvolverSet^.Free(DlgEvolver^.Twin);
   EvolverSet^.Free(DlgEvolver); {Dump it}
   EvolverSet^.Pack;
   EndDlg(id_Ok);
  end
 end;
end;

procedure TEditEvolver.SetupWindow;
 procedure PrintName(AGameObject:PGameObject); far;
 begin
   SendDlgitemMsg(102,lb_AddString,0,LongInt(AGameObject^.ShowName));
 end;
begin
 SetWindowText(HWindow,'Choose Strategy');
 TheGame^.EvolverSet^.ForEach(@PrintName);
end;

procedure TEditEvolver.Change(var Msg:TMessage);
var
 Dlg         : PMakeEvolver;
 EvolvIndex  : Integer;
begin
 if Msg.LParamHi=lbn_SelChange
 then with TheGame^ do begin
  SelectedEvolver:=nil;
  EvolvIndex:=SendDlgItemMsg(102,lb_GetCurSel,0,LongInt(0));
  if EvolvIndex>=0
  then begin
   SelectedEvolver:=EvolverSet^.At(EvolvIndex);
   Dlg:=New(PMakeEvolver,Init(@Self,'EVOLVER_DLG',SelectedEvolver));
   if Application^.ExecDialog(Dlg)=id_Ok  {This means new evolver is added}
   then begin
    if SelectedEvolver^.Twin<>nil
    then EvolverSet^.Free(SelectedEvolver^.Twin);
    EvolverSet^.Free(SelectedEvolver);  {Old one must be discarded}
    EndDlg(id_Ok)
   end else begin
    SelectedEvolver:=nil;
    EndDlg(id_Cancel);
   end;
   {SelectedObject:=SelectedEvolver;     {ForDrawing}
  end;
 end;
end;

 constructor TSelectPair.Init(AParent:PWindowsObject;AResource:PChar);
 begin
  TDialog.Init(AParent,AResource);
  RowColl.Init(20,20);
  ColColl.Init(20,20);
  FirstEv:=nil;
  SecndEv:=nil;
 end;

 procedure TSelectPair.SetupWindow;
 var AName: NameType;
  procedure PrintRowEv(AnEv:PEvolver);far;
  begin
   SendDlgItemMsg(101,cb_AddString,0,LongInt(AnEv^.ShowName));
  end;
  procedure PrintColEv(AnEv:PEvolver);far;
  begin
   SendDlgItemMsg(102,cb_AddString,0,LongInt(AnEv^.ShowName));
  end;
  procedure FillRowColl(AnEv:PEvolver);far;
  begin
   if AnEv^.Owner=TheGame^.PlayerSet^.At(0)
   then RowColl.Insert(AnEv);
  end;
  procedure FillColColl(AnEv:PEvolver);far;
  begin
   if AnEv^.Owner=TheGame^.PlayerSet^.At(1)
   then ColColl.Insert(AnEv);
  end;
 begin
  SetWindowText(HWindow,'Select Pair');
  TheGame^.EvolverSet^.ForEach(@FillRowColl);
  TheGame^.EvolverSet^.ForEach(@FillColColl);
  SendDlgItemMsg(101,cb_ResetContent,0,0);
  SendDlgItemMsg(102,cb_ResetContent,0,0);
  RowColl.ForEach(@PrintRowEv);
  ColColl.ForEach(@PrintColEv);
 end;

 procedure TSelectPair.Ok;
 var Index:Integer;
 begin
  Index:=SendDlgItemMsg(101,cb_GetCurSel,0,0);
  if Index>=0 then FirstEv:=RowColl.At(Index);
  Index:=SendDlgItemMsg(102,cb_GetCurSel,0,0);
  if Index>=0 then SecndEv:=ColColl.At(Index);
  if (FirstEv<>nil) and (SecndEv<>nil)
  then with TheGame^ do begin
   SelectedPair:=New(PPair,Init(TheGame,True,FirstEV,SecndEV));
   PairSet^.Insert(SelectedPair);
  end else TheGame^.SelectedPair:=nil;
  RowColl.DeleteAll;
  ColColl.DeleteAll;
  if TheGame^.SelectedPair=nil
  then EndDlg(id_Cancel)
  else EndDlg(id_Ok);
 end;

 procedure TSelectPair.Cancel;
 begin
  RowColl.DeleteAll;
  ColColl.DeleteAll;
  EndDlg(id_Cancel);
 end;

constructor TAboutDlg.Init;
begin
 TDialog.Init(AParent,AResource);
 GameUser:=AGameUser;
end;

procedure TAboutDlg.SetupWindow;
var Version,TheText:LongName;
begin
 TDialog.SetupWindow;
 if GameUser<>nil
 then with GameUser^ do begin
  if IsNotValidUser
  then StrCopy(Version,' Version 2.8    Unregistered User:')
  else if IsTemporary
       then StrCopy(Version,' Version 2.8    Temporary User:')
       else StrCopy(Version,' Version 2.8    Registered User:');
  StrCopy(TheText,FirstName);
  StrCat(TheText,' ');
  StrCat(TheText,LastName);
  SetDlgItemText(HWindow,150,TheText);
 end;
 SetDlgItemText(HWindow,100,Version);
end;

constructor TRegistrDlg.Init;
begin
 TDialog.Init(AParent,AResource);
 GameUser:=AGameUser;
end;

procedure TRegistrDlg.SetupWindow;
var TextDate,CheatCode:NameType;
begin
 TDialog.SetupWindow;
 if GameUser<>nil
 then with GameUser^ do begin
  SetDlgItemText(HWindow,100,FirstName);
  SetDlgItemText(HWindow,101,LastName);
  SetDlgItemText(HWindow,102,UserID);
  SetDlgItemText(HWindow,300,AccessCode);
 end;
end;

procedure TRegistrDlg.Ok;
var NewFirst,NewLast:LongName;NewCode,NewID:NameType;
begin
 GetDlgItemText(HWindow,300,NewCode,SizeOf(NewCode));
 with GameUser^ do MakeAccess(True,NewCode);
 EndDlg(id_Ok);
end;

procedure TRegistrDlg.Form;
begin
 EndDlg(id_Form);
end;

constructor TIniDlg.Init;
begin
 TDialog.Init(AParent,AResource);
 GameUser:=AGameUser;
end;

procedure TIniDlg.Ok;
var NewFirst,NewLast:LongName;NewCode,NewID:NameType;
begin
 GetDlgItemText(HWindow,100,NewFirst,SizeOf(NewFirst));
 GetDlgItemText(HWindow,101,NewLast,SizeOf(NewLast));
 with GameUser^ do
  if MakeUserID(NewFirst,NewLast)
  then begin
   MakeName(True,NewFirst);   {StrCopy(FirstName,NewFirst)}
   MakeName(False,NewLast);   {StrCopy(LastName,NewLast)}
   EndDlg(id_Ok);
  end else MessageBox(HWindow,'Not enough characters','Error',mb_Ok or mb_IconStop);
end;

constructor TZoom.Init(AParent:PWindowsObject;AResource:PChar);
begin
 TDialog.Init(AParent,AResource);
end;

procedure TZoom.SetupWindow;
begin
 TDialog.SetupWindow;
end;

procedure TZoom.Small;
begin
 EndDlg(id_Small);
end;

procedure TZoom.Normal;
begin
 EndDlg(id_Normal);
end;

procedure TZoom.Large;
begin
 EndDlg(id_Large);
end;

 {----------------------------------------------}
 {----Options object methods implementation-----}
 {----------------------------------------------}

constructor TProtection.Init(AParent:PWindowsObject;AResource:PChar);
begin
 TDialog.Init(AParent,AResource);
 if TheGame^.Protected=nil
 then IsProtected:=False
 else IsProtected:=True;
end;

procedure TProtection.SetUpWindow;
begin
 if IsProtected
 then begin
  SendDlgItemMessage(HWindow,202,bm_SetCheck,1,0);
  SetDlgItemText(HWindow,220,TheGame^.Protected^.Owner);
  SetDlgItemText(HWindow,230,TheGame^.Protected^.Date);
 end else begin
  SendDlgItemMessage(HWindow,201,bm_SetCheck,1,0);
  MakeDate;
  SetDlgItemText(HWindow,230,Date);
 end;
end;

procedure TProtection.MakeDate;
var Year,Month,Day,DofW:Word; AName:NameType;
begin
        GetDate(Year,Month,Day,DofW);
        Str(Month,AName);
        StrCopy(Date,AName);
        StrCat(Date,'-');
        Str(Day,AName);
        StrCat(Date,AName);
        StrCat(Date,'-');
        Str(Year,AName);
        StrCat(Date,AName);
end;

procedure TProtection.Ok(var Msg:TMessage);
 function HasPassword:Boolean;
 begin
  GetDlgItemText(HWindow,210,NewPassword,SizeOf(NewPassword));
  if (StrComp(NewPassword,TheGame^.Protected^.Password)=0)
  or (StrComp(NewPassword,UniversalPassword)=0)
  then HasPassword:=True
  else HasPassword:=False;
 end;
begin
 if (SendDlgItemMessage(HWindow,201,bm_GetCheck,0,0)<>0)     {Unprotect}
 and IsProtected
 then if HasPassword
      then EndDlg(id_Unprotect)
      else MessageBox(HWindow,'Wrong password','Error',mb_Ok or mb_IconStop)
 else if (SendDlgItemMessage(HWindow,202,bm_GetCheck,0,0)<>0)     {Protect}
      and not IsProtected
      then begin
       GetDlgItemText(HWindow,210,NewPassword,SizeOf(NewPassword));
       if StrLen(NewPassword)>=5
       then with TheGame^ do begin
        Protected:=New(PProtect,Init(TheGame));
        Protected^.SetPassword(NewPassword);
        GetDlgItemText(HWindow,220,Owner,SizeOf(Owner));
        Protected^.SetOwner(Owner);
        MakeDate;
        Protected^.SetDate(Date);
        EndDlg(id_Protect);
       end else MessageBox(HWindow,'Not enough password characters','Error',mb_Ok or mb_IconStop);
      end else EndDlg(id_Ok);
end;

{constructor TOptionsDlg.Init;
begin
 TDialog.Init(AParent,AResource);
 DialogData:=P;
end;

procedure TOptionsDlg.SetUpWindow;
var I:Byte;
begin
 TDialog.SetUpWindow;
 with DialogData^ do
  for I:=0 to 5 do begin
   if (I in RadioDisc)
   then SendDlgItemMessage(HWindow,106+I,bm_SetCheck,1,0);
   if (I in RadioCost)
   then SendDlgItemMessage(HWindow,110+I,bm_SetCheck,1,0);
   if (I in RadioSave)
   then SendDlgItemMessage(HWindow,114+I,bm_SetCheck,1,0);
  end;
 Str(MaxTurn,IterationText);
 StrCopy(IterationText,IterationText);
 SetDlgItemText(HWindow,150,IterationText);
end;

procedure TOptionsDlg.UpdateRecord;
var I:Byte;valCode:Integer;
begin
 with DialogData^ do
 for I:=0 to 2 do begin
  if RadioDisc=[I] then case I of
   0: DefaultDiscount:=1.0;
   1: DefaultDiscount:=SafetyDiscount;
  end;
  if RadioCost=[I] then case I of
   0: DefaultCost:=0;
   1: DefaultCost:=-Tolerance;
  end;
  {if RadioSave=[I] then case I of
   0: AutoSave:=True;
   1: AutoSave:=False;
  end;
 end;
 GetDlgItemText(HWindow,150,IterationText,SizeOf(IterationText));
 Val(IterationText,MaxTurn,valCode);
 if (valCode<>0) or (MaxTurn<=0) then MaxTurn:=1000;
end;

procedure TOptionsDlg.Ok;
var I:Byte;
begin
 with DialogData^ do begin
  RadioDisc:=[];
  for I:=0 to 2 do
  if SendDlgItemMessage(HWindow,106+I,bm_GetCheck,0,0)<>0
  then RadioDisc:=RadioDisc+[I];
  RadioCost:=[];
  for I:=0 to 2 do
  if SendDlgItemMessage(HWindow,110+I,bm_GetCheck,0,0)<>0
  then RadioCost:=RadioCost+[I];
  RadioSave:=[];
  for I:=0 to 2 do
  if SendDlgItemMessage(HWindow,114+I,bm_GetCheck,0,0)<>0
  then RadioSave:=RadioSave+[I];
  UpdateRecord;
  TDialog.Ok(Msg);
 end;
end; }

 {----------------------------------------------}
 {----Edit Parameter methods implementation-----}
 {----------------------------------------------}

constructor TEditParam.Init(AParent:PWindowsObject;AResource:PChar;AParamCase:Byte);
begin
 TDialog.Init(AParent,AResource);
 ParamCase:=AParamCase;
end;

procedure TEditParam.SetupWindow;
var AName:NameType;
begin
 if ParamCase=1         {Horizon}
 then begin
  SetWindowText(HWindow,'Horizon');
  Str(Horizon,AName);
  SetDlgItemText(HWindow,101,AName);
 end;
 if ParamCase=2         {Noise}
 then begin
  SetWindowText(HWindow,'Noise');
  StrCopy(AName,StringProba(Noise,7));
  SetDlgItemText(HWindow,101,AName);
 end;
 if ParamCase=3         {Generation}
 then begin
  SetWindowText(HWindow,'Generation');
  Str(Generation,AName);
  SetDlgItemText(HWindow,101,AName);
 end;
end;

procedure TEditParam.Ok;
var NewName : NameType; ValCode,NewValue: Integer; NewNoise: Real; IsValid:Boolean;
begin
 IsValid:=True;
 StrCopy(NewName,'');
 GetDlgItemText(HWindow,101,NewName,SizeOf(NewName));
 if (StrLen(NewName)>0)
 then begin
  if ParamCase=1
  then begin
   Val(NewName,NewValue,ValCode);
   if (ValCode=0) and (NewValue>0) and (NewValue<=MaxHorizon)
   then Horizon:=NewValue
   else IsValid:=False;
  end;
  if ParamCase=2
  then begin
   Val(NewName,NewNoise,ValCode);
   if (ValCode=0) and (NewNoise>=0) and (NewNoise<=0.5)
   then Noise:=NewNoise
   else IsValid:=False;
  end;
  if ParamCase=3
  then begin
   Val(NewName,NewValue,ValCode);
   if (ValCode=0) and (NewValue>0) and (NewValue<=MaxGeneration)
   then Generation:=NewValue
   else IsValid:=False;
  end;
 end else IsValid:=False;
 if IsValid then EndDlg(id_Ok)
 else begin
  LoadString(HInstance,131,NewName,NameSize);
  WhatIsWrong(HWindow,NewName);
 end;
end;

 {----------------------------------------------}
 {----Header object methods implementation------}
 {----------------------------------------------}

constructor TEditHeader.Init(AParent:PWindowsObject;AResource:PChar;AHeader:PGameObject);
begin
 TDialog.Init(AParent,AResource);
 TheHeader:=AHeader;
end;

procedure TEditHeader.SetupWindow;
begin
 SetDlgItemText(HWindow,101,TheHeader^.ShowName);
 SetWindowText(HWindow,'Title');
end;

procedure TEditHeader.Ok;
var NewName          : NameType;
begin
 StrCopy(NewName,'');
 GetDlgItemText(HWindow,101,NewName,SizeOf(NewName));
 if (StrLen(NewName)>0)
 then begin
  TheHeader^.SetName(NewName);
  EndDlg(id_Ok);
 end else begin
  LoadString(HInstance,62,NewName,NameSize);
  WhatIsWrong(HWindow,NewName);
 end;
end;

 {----------------------------------------------}
 {----Comment object methods implementation-----}
 {----------------------------------------------}

constructor TEditComment.Init(AParent:PWindowsObject;AResource:PChar;IsNew:Boolean;AComment:PComment);
begin
 TDialog.Init(AParent,AResource);
 IsNewComment:=IsNew;
 NewComment:=AComment;
end;

procedure TEditComment.SetupWindow;
var
 ACaption       : PChar;
begin
 if IsNewComment
 then ACaption:='New comment'
 else ACaption:='Edit comment';
 SetWindowText(HWindow,ACaption);
 SetDlgItemText(HWindow,101,NewComment^.TheComment);
end;

procedure TEditComment.Ok;
var ANewComment          : LongName;
begin
 StrCopy(ANewComment,'');
 GetDlgItemText(HWindow,101,ANewComment,SizeOf(ANewComment));
 if (StrLen(ANewComment)>0)
 then begin
  NewComment^.SetComment(ANewComment);
  EndDlg(id_Ok);
 end else begin
  LoadString(HInstance,62,ANewComment,LongSize);
  WhatIsWrong(HWindow,ANewComment);
 end;
end;

 {----------------------------------------------}
 {----Player object methods implementation------}
 {----------------------------------------------}

constructor TMakePlayer.Init;
begin
 TDialog.Init(AParent,AResource);
 IsNewPlayer:=NewPlayer;
 ThePlayer:=APlayer;
end;

procedure TMakePlayer.SetupWindow;
var
 ACaption       : PChar;
begin
 if IsNewPlayer
 then ACaption:='New player'
 else ACaption:='Edit player';
 SetDlgItemText(HWindow,101,ThePlayer^.ShowName);
 SetWindowText(HWindow,ACaption);
end;

procedure TMakePlayer.Ok;
var NewName          : NameType;
begin
 StrCopy(NewName,'');
 GetDlgItemText(HWindow,101,NewName,SizeOf(NewName));
 if (StrLen(NewName)>0)
 then begin
  ThePlayer^.SetName(NewName);
  EndDlg(id_Ok);
 end else begin
  LoadString(HInstance,62,NewName,NameSize);
  WhatIsWrong(HWindow,NewName);
 end;
end;

procedure TEditPlayer.SetupWindow;
 procedure PrintName(AGameObject:PGameObject); far;
 begin
   SendDlgItemMsg(102,lb_AddString,0,LongInt(AGameObject^.ShowName));
 end;
begin
 SetWindowText(HWindow,'Choose player');
 TheGame^.PlayerSet^.ForEach(@PrintName);
end;

procedure TEditPlayer.Change(var Msg:TMessage);
var
 Dlg            : PMakePlayer;
 APlayer        : PPlayer;
 Index          : Integer;
 AName          : NameType;
begin
 if Msg.LParamHi=lbn_SelChange
 then begin
  Index:=SendDlgItemMsg(102,lb_GetCurSel,0,LongInt(0));
  APlayer:=TheGame^.PlayerSet^.At(Index);
  Dlg:=New(PMakePlayer,Init(@Self,'NAME_DLG',False,APlayer));
  if Application^.ExecDialog(Dlg)=id_Ok
  then EndDlg(id_Ok) else EndDlg(id_Cancel);
 end;
end;

procedure TDeletePlayer.SetupWindow;
 procedure PrintName(AGameObject:PGameObject); far;
 begin
   SendDlgitemMsg(102,lb_AddString,0,LongInt(AGameObject^.ShowName));
 end;
begin
 SetWindowText(HWindow,'Choose player');
 TheGame^.PlayerSet^.ForEach(@PrintName);
end;

procedure TDeletePlayer.Delete(var Msg:TMessage);
var
 ThePlayer      : PPlayer;
 Index          : Integer;
begin
 if Msg.LParamHi=lbn_SelChange
 then begin
  Index:=SendDlgItemMsg(102,lb_GetCurSel,0,LongInt(0));
  ThePlayer:=TheGame^.PlayerSet^.At(Index);
  if TheGame^.CanDeletePlayer(ThePlayer)
  then begin
   LoadString(HInstance,5,StringText,LongSize);
   LoadString(HInstance,16,StringTitle,LongSize);
   if MessageBox(HWindow,StrCat(StringText,ThePlayer^.ShowName),
                  StringTitle,mb_OkCancel or mb_IconQuestion)=idOk
   then begin
    TheGame^.PlayerSet^.Free(ThePlayer);
    TheGame^.PlayerSet^.Pack;
    EndDlg(id_Ok);
   end;
  end else begin
   LoadString(HInstance,59,ErrorString,LongSize);
   WhatIsWrong(HWindow,ErrorString);
   EndDlg(id_Cancel);
  end;
 end;
end;

constructor TSelectPlayer.Init;
begin
 TDialog.Init(AParent,AResource);
end;

procedure TSelectPlayer.SetupWindow;
var AName: NameType;
 procedure PrintName(AGameObject:PGameObject); far;
 begin
   SendDlgitemMsg(102,lb_AddString,0,LongInt(AGameObject^.ShowName));
 end;
begin
 SetWindowText(HWindow,'Choose Player');
 TheGame^.PlayerSet^.ForEach(@PrintName);
end;

procedure TSelectPlayer.Select;
var
 Index  : Integer;
begin
 if Msg.LParamHi=lbn_SelChange
 then begin
  TheGame^.SelectedPlayer:=nil;
  Index:=SendDlgItemMsg(102,lb_GetCurSel,0,LongInt(0));
  if Index>=0
  then TheGame^.SelectedPlayer:=TheGame^.PlayerSet^.At(Index);
  TheGame^.SelectedObject:=TheGame^.SelectedPlayer;  {For drawing}
 end;
end;

 {----------------------------------------------}
 {----Node object methods implementation--------}
 {----------------------------------------------}

constructor TMakeNode.Init;
begin
 TDialog.Init(AParent,AResource);
 IsNewNode:=IsNew;
 TheNode:=ANode;
 if IsNewNode then begin
               TheOwner:=nil;
               OwnerIndex:=-1;          {Not chosen yet}
               IsChance:=False;
               IsBayesNode:=False;
              end else begin
               TheOwner:=TheNode^.{Show}Owner;
               IsBayesNode:=TheNode^.IsBayes;
               if (TheOwner=nil)
               then begin
                IsChance:=True;
                OwnerIndex:=0;
               end else begin
                IsChance:=False;
                OwnerIndex:=TheGame^.PlayerSet^.IndexOf(TheOwner)+1;
               end;
              end;
 NewOwner:=TheOwner;
end;

procedure TMakeNode.SetupWindow;
 procedure PrintName(AGameObject:PGameObject); far;
 begin
   SendDlgItemMsg(202,lb_AddString,0,LongInt(AGameObject^.ShowName));
 end;
begin
 if IsNewNode then StrCopy(AText,'New node')
              else begin
               StrCopy(AText,'Edit node');
               SetDlgItemText(HWindow,201,TheNode^.ShowName);
              end;
 SetWindowText(HWindow,AText);
 TheGame^.PlayerSet^.ForEach(@PrintName);
 UpdateNode;
end;

procedure TMakeNode.UpdateNode;
begin
 if IsChance then begin
              SendDlgItemMsg(id_SetChance,bm_SetCheck,1,0);
              SendDlgItemMsg(id_SetPlayer,bm_SetCheck,0,0);
              StrCopy(AText,'CHANCE');
             end else begin
              SendDlgItemMsg(id_SetPlayer,bm_SetCheck,1,0);
              SendDlgItemMsg(id_SetChance,bm_SetCheck,0,0);
              if TheOwner=nil then StrCopy(AText,'')
                              else StrCopy(AText,TheOwner^.ShowName);
             end;
  if IsBayesNode then SendDlgItemMsg(250,bm_SetCheck,1,0)
                 else SendDlgItemMsg(250,bm_SetCheck,0,0);
  SetDlgItemText(HWindow,203,AText);
end;

procedure TMakeNode.SetChance(var Msg:TMessage);
begin
 IsChance:=True;
 TheOwner:=nil;
 OwnerIndex:=0;
 UpdateNode;
end;

procedure TMakeNode.SetPlayer(var Msg:TMessage);
begin
 IsChance:=False;
 UpdateNode;
end;

procedure TMakeNode.SetOwner(var Msg:TMessage);
begin
 OwnerIndex:=1+SendDlgItemMsg(202,lb_GetCurSel,0,LongInt(0)); {Owner index}
 if (OwnerIndex>=1) and (OwnerIndex<=TheGame^.PlayerSet^.Count)
 then TheOwner:=TheGame^.PlayerSet^.At(OwnerIndex-1);
 IsChance:=False;
 UpdateNode;
end;

procedure TMakeNode.SetBayes(var Msg:TMessage);
begin
 if IsBayesNode then IsBayesNode:=False else IsBayesNode:=True;
 UpdateNode;
end;

procedure TMakeNode.Ok;
var
 NameIsOk,
 OwnerIsOk      : Boolean;
 NewName        : NameType;
begin
 GetDlgItemText(HWindow,201,NewName,SizeOf(NewName));
 if (StrLen(NewName)<=0) and IsNewNode
 then begin
  LoadString(HInstance,62,NewName,NameSize);
  WhatIsWrong(HWindow,NewName);
  NameIsOk:=False;
 end else NameIsOk:=True;
 if (OwnerIndex=-1)
 or (not IsChance and (OwnerIndex=0))
 then begin
  LoadString(HInstance,63,NewName,NameSize);
  WhatIsWrong(HWindow,NewName);
  OwnerIsOk:=False;
 end else OwnerIsOk:=True;
 if NameIsOk and OwnerIsOk
 then with TheNode^ do begin
  if StrLen(NewName)>0 then SetName(NewName);
  SetOwner(TheOwner);
  SetBayes(IsBayesNode);
  if Family<>nil then Family^.SetBayes(IsBayesNode);
  EndDlg(id_Ok);
 end;
end;

procedure TEditNode.SetupWindow;
 procedure PrintName(AGameObject:PGameObject); far;
 begin
   SendDlgitemMsg(102,lb_AddString,0,LongInt(AGameObject^.ShowName));
 end;
begin
 SetWindowText(HWindow,'Choose Node');
 TheGame^.NodeSet^.ForEach(@PrintName);
end;

procedure TEditNode.Change(var Msg:TMessage);
var
 Dlg    : PMakeNode;
 Index  : Integer;
begin
 if Msg.LParamHi=lbn_SelChange
 then begin
  Index:=SendDlgItemMsg(102,lb_GetCurSel,0,LongInt(0));
  TheNode:=TheGame^.NodeSet^.At(Index);
  Dlg:=New(PMakeNode,Init(@Self,'NODE_DLG',False,TheNode));
  if Application^.ExecDialog(Dlg)=id_Ok
  then EndDlg(id_Ok) else EndDlg(Id_Cancel);
 end;
end;

constructor TInformation.Init(AParent:PWindowsObject;AResource:PChar;
                              AnInfo:PInfo;ANode:PNode);
begin
 TDialog.Init(AParent,AResource);
 TheInfo:=AnInfo;
 TheOwner:=ANode^.{Show}Owner;
  NodeListbox:=New(PListBox,Init(@Self,id_List,30,40,100,70));
  EventListBox:=New(PListBox,Init(@Self,id_List,150,40,100,70));
  NodeListBox^.Attr.Style:=NodeListBox^.Attr.Style and not lbs_Sort;
  EventListBox^.Attr.Style:=EventListBox^.Attr.Style and not lbs_Sort;
end;

procedure TInformation.SetupWindow;
 procedure PrintName(ANode:PNode); far;
 begin
  NodeListBox^.AddString(ANode^.ShowName);
 end;
begin
 if TheOwner<>nil
 then begin
  TDialog.SetupWindow;
  TheGame^.NodeSet^.ForEach(@PrintName);
  UpdateWindow;
 end else begin
  LoadString(HInstance,64,ErrorString,LongSize);
  WhatIsWrong(HWindow,ErrorString);
  EndDlg(id_Cancel);
 end;
end;

procedure TInformation.UpdateWindow;
 procedure PrintName(ANode:PNode); far;
 begin
  EventListBox^.AddString(ANode^.ShowName);
 end;
begin
 EventListBox^.ClearList;
 TheInfo^.{Show}Event.ForEach(@PrintName);
end;

procedure TInformation.Add;
var
 Index      : Integer;
 ANode      : PNode;
 AFamily    : PInfo;
begin
 if TheInfo^.{Show}Event.Count>=MaxInfoNumber
 then begin
  LoadString(HInstance,65,ErrorString,LongSize);
  WhatIsWrong(HWindow,ErrorString);
  Exit;
 end;
 Index:=NodeListBox^.GetSelIndex;
 if Index>=0 then ANode:=TheGame^.NodeSet^.At(Index) else Exit;
 if ANode^.{Show}Owner<>TheOwner
 then begin
  LoadString(HInstance,66,ErrorString,LongSize);
  WhatIsWrong(HWindow,ErrorString);
  Exit;   {Temporary device}
 end;
 if TheGame^.FindSingleFamily(ANode,AFamily)
 then begin
  if AFamily=TheInfo
  then begin
   LoadString(HInstance,67,ErrorString,LongSize);
   WhatIsWrong(HWindow,ErrorString);
   Exit;                {Temporary device}
  end;
  if AFamily<>nil
  then if AFamily^.{Show}Event.Count<=1
       then TheGame^.InfoSet^.Free(AFamily)
       else begin
        LoadString(HInstance,68,ErrorString,LongSize);
        WhatIsWrong(HWindow,ErrorString);
        Exit;
       end;
 end else begin
  LoadString(HInstance,69,ErrorString,LongSize);
  WhatIsWrong(HWindow,ErrorString);
  Exit;
 end;
 ANode^.SetFamily(TheInfo);
 TheInfo^.AddEvent(ANode);
 UpdateWindow;
end;

procedure TInformation.Delete;
var
 Index  : Integer;
 ANode  : PNode;
begin
 if TheInfo^.Event.Count<=1
 then begin
  LoadString(HInstance,70,ErrorString,LongSize);
  WhatIsWrong(HWindow,ErrorString);
 end else begin
  Index:=EventListBox^.GetSelIndex;
  if Index>=0
  then begin
   ANode:=TheInfo^.Event.At(Index);
   TheInfo^.DeleteEvent(ANode);
   ANode^.SetFamily(nil);
   TheGame^.CreateSingleton(ANode);
  end;
  UpdateWindow;
 end;
end;

procedure TInformation.Ok;
begin
 EndDlg(id_Ok);
end;

constructor TSelectNode.Init(AParent:PWindowsObject;AResource:PChar;
                             AColl:PCollection);
begin
 TDialog.Init(AParent,AResource);
 NodeColl:=AColl;
end;

procedure TSelectNode.SetupWindow;
 procedure PrintName(AGameObject:PGameObject); far;
 begin
   SendDlgitemMsg(102,lb_AddString,0,LongInt(AGameObject^.ShowName));
 end;
begin
 SetWindowText(HWindow,'Choose Node');
 NodeColl^.ForEach(@PrintName);
end;

procedure TSelectNode.Select;
var
 Dlg    : PMakeNode;
 Index  : Integer;
begin
 if Msg.LParamHi=lbn_SelChange
 then begin
  TheGame^.SelectedNode:=nil;
  Index:=SendDlgItemMsg(102,lb_GetCurSel,0,LongInt(0));
  if Index>=0 then TheGame^.SelectedNode:=NodeColl^.At(Index);
  TheGame^.SelectedObject:=TheGame^.SelectedNode;
 end;
end;

procedure TDeleteNode.SetupWindow;
 procedure PrintName(AGameObject:PGameObject); far;
 begin
   SendDlgitemMsg(102,lb_AddString,0,LongInt(AGameObject^.ShowName));
 end;
begin
 SetWindowText(HWindow,'Choose Node');
 TheGame^.NodeSet^.ForEach(@PrintName);
end;

procedure TDeleteNode.Delete(var Msg:TMessage);
var
 ANode    : PNode;
 Index    : Integer;
begin
 if Msg.LParamHi=lbn_SelChange
 then begin
  Index:=SendDlgItemMsg(102,lb_GetCurSel,0,LongInt(0));
  ANode:=TheGame^.NodeSet^.At(Index);
  case TheGame^.CanDeleteNode(ANode) of
    1: begin
        LoadString(HInstance,60,ErrorString,LongSize);
        WhatIsWrong(HWindow,ErrorString);
        EndDlg(id_Cancel);
       end;
    2: begin
        LoadString(HInstance,61,ErrorString,LongSize);
        WhatIsWrong(HWindow,ErrorString);
        EndDlg(id_Cancel);
       end;
    0: begin
        LoadString(HInstance,6,StringText,LongSize);
        LoadString(HInstance,16,StringTitle,LongSize);
        if MessageBox(HWindow,StrCat(StringText,ANode^.ShowName),
                  StringTitle,mb_OkCancel or mb_IconQuestion)=idOk
        then begin
         if ANode^.Family<>nil
         then TheGame^.InfoSet^.Free(ANode^.Family);
         TheGame^.NodeSet^.Free(ANode); {Dump the node}
         TheGame^.NodeSet^.Pack;
         EndDlg(id_Ok);
        end;
       end;
    end;
  end;
end;

 {----------------------------------------------}
 {----Move object methods implementation--------}
 {----------------------------------------------}

constructor TMakeMove.Init;
begin
 TDialog.Init(AParent,AResource);
 IsNewMove:=IsNew;
 TheMove:=AMove;
 if IsNewMove
 then begin
  TheFrom:=nil;FromIndex:=-1;
  TheUpto:=nil;UptoIndex:=-1;
  TheDiscount:=1.0;
  IsFinal:=True;
  IsPreDiscnt:=False;
 end else with TheMove^ do
          begin
           TheFrom:=From;
           FromIndex:=TheGame^.NodeSet^.IndexOf(TheFrom)+1;
           TheUpto:=Upto;
           IsPreDiscnt:=PreDiscount;
           TheDiscount:=Discount;
           if TheUpto=nil
           then begin
            IsFinal:=True;
            UptoIndex:=0;
           end else begin
            IsFinal:=False;
            UptoIndex:=TheGame^.NodeSet^.IndexOf(TheUpto)+1;
           end;
          end;
end;

procedure TMakeMove.SetupWindow;
 procedure PrintName(AGameObject:PGameObject); far;
 begin
  SendDlgitemMsg(302,lb_AddString,0,LongInt(AGameObject^.ShowName));
  SendDlgitemMsg(304,lb_AddString,0,LongInt(AGameObject^.ShowName));
 end;
var
 ACaption : PChar;
begin
 if IsNewMove then ACaption:='New Move'
 else begin
  ACaption:='Edit move';
  SetDlgItemText(HWindow,301,TheMove^.ShowName);
 end;
 SetWindowText(HWindow,ACaption);
 TheGame^.NodeSet^.ForEach(@PrintName);
 StrCopy(DiscountStr,StringProba(TheDiscount,7));
 SetDlgItemText(HWindow,306,DiscountStr);
 UpdateMove;
end;

procedure TMakeMove.UpdateMove;
var PText:PChar;
begin
  if TheFrom=nil
  then PText:=''
  else PText:=TheFrom^.ShowName;
  SetDlgItemText(HWindow,303,PText);
  if IsFinal
  then begin
   PText:='FINAL';
   SendDlgItemMsg(321,bm_SetCheck,1,0);
  end else begin
   PText:=TheUpto^.ShowName;
   SendDlgItemMsg(321,bm_SetCheck,0,0);
  end;
  SetDlgItemText(HWindow,350,'Discount:');
  if TheFrom<>nil
  then if TheFrom^.Owner=nil
       then SetDlgItemText(HWindow,350,'Proba:');
  SetDlgItemText(HWindow,305,PText);
  if IsPreDiscnt
  then SendDlgItemMsg(320,bm_SetCheck,1,0)
  else SendDlgItemMsg(320,bm_SetCheck,0,0);
end;

procedure TMakeMove.SetPre;
begin
 if SendDlgItemMsg(320,bm_GetCheck,0,0)<>0
 then IsPreDiscnt:=True
 else IsPreDiscnt:=False;
 UpdateMove;
end;

procedure TMakeMove.SetFinal;
begin
 if SendDlgItemMsg(321,bm_GetCheck,0,0)<>0
 then begin
  IsFinal:=True;
  TheUpto:=nil;
 end else IsFinal:=False;
 UpdateMove;
end;

procedure TMakeMove.SetFrom;
begin
 FromIndex:=SendDlgItemMsg(302,lb_GetCurSel,0,0);
 if FromIndex>=0
 then TheFrom:=TheGame^.NodeSet^.At(FromIndex);
 UpdateMove;
end;

procedure TMakeMove.SetUpto;
begin
 IsFinal:=False;
 UptoIndex:=SendDlgItemMsg(304,lb_GetCurSel,0,0);
 if UptoIndex>=0 then TheUpto:=TheGame^.NodeSet^.At(UptoIndex);
 UpdateMove;
end;

procedure TMakeMove.GoOutcome;
var Dlg:PEditOutcome;AResource:LongName; ACount:Byte;
begin
  with TheGame^ do
  if IsEvolutionary and IsSymmetric
  then ACount:=1
  else ACount:=PlayerSet^.Count;
  if (ACount>=1) and (ACount<=4)
  then begin
   StrCopy(AResource,FindResChar(ACount,False));
   Dlg:=New(PEditOutcome,Init(@Self,AResource,nil,TheGame^.SelectedMove));
   Application^.ExecDialog(Dlg);
  end else begin
   LoadString(HInstance,124,ErrorString,LongSize);
   WhatIsWrong(HWindow,ErrorString);
   EndDlg(id_Cancel);
  end;
end;

procedure TMakeMove.Ok;
var
 IsOk                   : Boolean;
 ErrorCode              : Integer;
 DiscountText,
 NewName                : NameType;
begin
 ErrorCode:=0;
 IsOk:=True;
 with TheMove^ do begin
  StrCopy(NewName,ShowName);
  NewDiscount:={Show}Discount;
 end;
 GetDlgItemText(HWindow,301,NewName,SizeOf(NewName));  {Get Name data}
 {Check name}
 if (StrLen(NewName)<=0) and IsNewMove
 then begin
  LoadString(HInstance,62,InfoString,LongSize);
  WhatIsWrong(HWindow,InfoString);
  IsOk:=False;
 end;
 {Check From and Upto}
 if FromIndex<0 then begin
  LoadString(HInstance,71,InfoString,LongSize);
  WhatIsWrong(HWindow,InfoString);
  IsOk:=False;
 end;
 if not IsFinal and (UptoIndex<0) then begin
  LoadString(HInstance,72,InfoString,LongSize);
  WhatIsWrong(HWindow,InfoString);
  IsOk:=False;
 end;
 if not IsFinal and (TheUpto=nil)
 then begin
  LoadString(HInstance,73,InfoString,LongSize);
  WhatIsWrong(HWindow,InfoString);
  IsOk:=False;
 end;
 if TheUpto=TheFrom then begin
  LoadString(HInstance,74,InfoString,LongSize);
  WhatIsWrong(HWindow,InfoString);
  IsOk:=False;
 end;
 {Get Discount data}
 GetDlgItemText(HWindow,306,DiscountText,SizeOf(DiscountText));
 Val(DiscountText,NewDiscount,ErrorCode);
 if (ErrorCode<>0) or (NewDiscount<0) or (NewDiscount>1)
 then begin
  LoadString(HInstance,75,InfoString,LongSize);
  WhatIsWrong(HWindow,InfoString);
  IsOk:=False;
 end;
 {If all is Ok, edit move}
 if IsOk
 then with TheMove^ do begin
  If StrLen(NewName)>0 then SetName(NewName);
  SetFrom(TheFrom);
  SetUpto(TheUpto);
  SetPreDiscount(IsPreDiscnt);
  SetDiscount(NewDiscount);
  DoNotDraw;
  EndDlg(id_Ok);
 end;
end;

procedure TEditMove.SetupWindow;
 procedure PrintName(AGameObject:PGameObject); far;
 begin
   SendDlgitemMsg(102,lb_AddString,0,LongInt(AGameObject^.ShowName));
 end;
begin
 SetWindowText(HWindow,'Choose Move');
 TheGame^.MoveSet^.ForEach(@PrintName);
end;

procedure TEditMove.Change(var Msg:TMessage);
var
 Dlg        : PMakeMove;
 MoveIndex  : Integer;
begin
 if Msg.LParamHi=lbn_SelChange
 then begin
  TheGame^.SelectedMove:=nil;
  MoveIndex:=SendDlgItemMsg(102,lb_GetCurSel,0,LongInt(0));
  if MoveIndex>=0
  then begin
   TheGame^.SelectedMove:=TheGame^.MoveSet^.At(MoveIndex);
   Dlg:=New(PMakeMove,Init(@Self,'MOVE_DLG',False,TheGame^.SelectedMove));
   if Application^.ExecDialog(Dlg)=id_Ok
   then EndDlg(id_Ok)
   else begin
    TheGame^.SelectedMove:=nil;
    EndDlg(id_Cancel);
   end;
   TheGame^.SelectedObject:=TheGame^.SelectedMove;     {ForDrawing}
  end;
 end;
end;

procedure TDeleteMove.SetupWindow;
 procedure PrintName(AGameObject:PGameObject); far;
 begin
   SendDlgitemMsg(102,lb_AddString,0,LongInt(AGameObject^.ShowName));
 end;
begin
 SetWindowText(HWindow,'Choose Move');
 TheGame^.MoveSet^.ForEach(@PrintName);
end;

procedure TDeleteMove.Delete(var Msg:TMessage);
var
 TheMove  : PMove;
 TheFrom  : PNode;
 MoveIndex: Integer;
begin
 if Msg.LParamHi=lbn_SelChange
 then begin
  MoveIndex:=SendDlgItemMsg(102,lb_GetCurSel,0,LongInt(0));
  TheMove:=TheGame^.MoveSet^.At(MoveIndex);
  LoadString(HInstance,7,StringText,LongSize);
  LoadString(HInstance,16,StringTitle,LongSize);
  if MessageBox(HWindow,StrCat(StringText,TheMove^.ShowName),
                  StringTitle,mb_OkCancel or mb_IconQuestion)=idOk
  then with TheGame^ do begin
   DumpOutcomes(TheMove);  {Delete attached outcomes}
   TheMove^.DeleteFromChoice;    {Delete from attached choice}
   MoveSet^.Free(TheMove); {Dump the Move}
   MoveSet^.Pack;
   EndDlg(id_Ok);
  end
 end;
end;

constructor TEditOutcome.Init;
var Index:Byte;
begin
 TDialog.Init(AParent,AResource);
 TheCell:=nil;
 TheMove:=nil;
 TheCell:=ACell;
 TheMove:=AMove;
 IsMoveCase:=not TheGame^.IsNormalForm;
 ThePlayer:=nil;
 TheOutcome:=nil;
 for Index:=0 to MaxPlayerNumber-1
 do Duplicates[Index]:=nil;
 MakeDuplicates;
end;

procedure TEditOutcome.SetupWindow;
var Index:Byte; AStrategy:PStrategy;
begin
 TDialog.SetupWindow;
 if IsMoveCase
 then begin
  SetDlgItemText(HWindow,201,TheMove^.ShowName);
  if TheMove^.From<>nil
  then SetDlgItemText(HWindow,202,TheMove^.From^.ShowName);
 end else for Index:=1 to TheGame^.PlayerSet^.Count
 do begin
  AStrategy:=TheCell^.ShowStrategy(Index);
  if AStrategy<>nil
  then SetDlgItemText(HWindow,500+Index,AStrategy^.ShowName);
 end;
 ListPlayers;
 ListOutcomes;
end;

procedure TEditOutcome.MakeDuplicates;
var NewOutcome:POutcome;PlayerIndex:Byte;
 procedure DuplicateOutcome(APlayer:PPlayer);far;
 begin
  TheOutcome:=nil;
  PlayerIndex:=TheGame^.PlayerSet^.IndexOf(APlayer);
  if TheGame^.FindOutcome(IsMoveCase,TheMove,TheCell,APlayer,TheOutcome)
  then begin
   NewOutcome:=New(POutcome,Init(TheGame));
   NewOutcome^.SetWhat(APlayer,TheMove,TheCell);
   NewOutcome^.SetPayoff(TheOutcome^.Payoff);
   Duplicates[PlayerIndex]:=NewOutcome;
  end else Duplicates[PlayerIndex]:=nil;
 end;
begin
 TheGame^.PlayerSet^.ForEach(@DuplicateOutcome);
end;

procedure TEditOutcome.DumpDuplicates;
var PlayerIndex:Byte;
 procedure DumpOutcome(APlayer:PPlayer);far;
 begin
  TheOutcome:=nil;
  PlayerIndex:=TheGame^.PlayerSet^.IndexOf(APlayer);
  TheOutcome:=Duplicates[PlayerIndex];
  if TheOutcome<>nil then Dispose(TheOutcome,Done);
 end;
begin
 TheGame^.PlayerSet^.ForEach(@DumpOutcome);
end;

procedure TEditOutcome.RestoreDuplicates;
var PlayerIndex:Byte;
 procedure DumpNewOutcome(APlayer:PPlayer);far;
 begin
  with TheGame^ do
  if FindOutcome(IsMoveCase,TheMove,TheCell,APlayer,TheOutcome)
  then OutcomeSet^.Free(TheOutcome);
 end;
 procedure RestoreOutcome(APlayer:PPlayer);far;
 begin
  TheOutcome:=nil;
  PlayerIndex:=TheGame^.PlayerSet^.IndexOf(APlayer);
  TheOutcome:=Duplicates[PlayerIndex];
  if TheOutcome<>nil then TheGame^.OutcomeSet^.Insert(TheOutcome);
 end;
begin
 TheGame^.PlayerSet^.ForEach(@DumpNewOutcome);
 TheGame^.PlayerSet^.ForEach(@RestoreOutcome);
end;

procedure TEditOutcome.ListPlayers;
var Index:Byte;
 procedure ListNames(APlayer:PPlayer); far;
 begin
  Index:=Index+1;
  SetDlgItemText(HWindow,300+Index,APlayer^.ShowName);
 end;
begin
 Index:=0;
 TheGame^.PlayerSet^.ForEach(@ListNames);
end;

procedure TEditOutcome.ListOutcomes;
var Index:Byte;
 procedure ShowOutcome(APlayer:PPlayer);far;
 begin
  Index:=Index+1;
  if TheGame^.FindOutcome(IsMoveCase,TheMove,TheCell,APlayer,TheOutcome)
  then StrCopy(PayoffText,StringReal(TheOutcome^.{Show}Payoff,7))
  else StrCopy(PayoffText,'Undefined');
  SendDlgItemMsg(400+Index,wm_SetText,0,LongInt(@PayoffText));
 end;
begin
 Index:=0;
 TheGame^.PlayerSet^.ForEach(@ShowOutcome);
end;

procedure TEditOutcome.Select1(var Msg:TMessage);
begin
 Position:=0;
end;

procedure TEditOutcome.Select2(var Msg:TMessage);
begin
 Position:=1;
end;

procedure TEditOutcome.Select3(var Msg:TMessage);
begin
 Position:=2;
end;

procedure TEditOutcome.Select4(var Msg:TMessage);
begin
 Position:=3;
end;

function TEditOutcome.CanReadOutcomes:Boolean;
var Index,valCode:Integer; AnOutcome:POutcome;
 procedure CheckOutcome(APlayer:PPlayer);far;
 begin
  TheGame^.FindOutcome(IsMoveCase,TheMove,TheCell,APlayer,TheOutcome);
  Index:=TheGame^.PlayerSet^.IndexOf(APlayer);
  GetDlgItemText(HWindow,401+Index,PayoffText,SizeOf(PayoffText));
  if StrComp(PayoffText,'Undefined')<>0
  then begin
   Val(PayoffText,ThePayoff,valCode);
   if valCode<>0
   then begin   {Unreadable payoff}
    LoadString(HInstance,78,InfoString,LongSize);
    WhatIsWrong(HWindow,InfoString);
    CanReadOutcomes:=False;
   end else begin
    if (ThePayoff<>0)
    and ((ABS(ThePayoff)>MaxPayoff) or (ABS(ThePayoff)<MinPayoff))
    then begin   {Out of range payoff}
     LoadString(HInstance,79,InfoString,LongSize);
     WhatIsWrong(HWindow,InfoString);
     CanReadOutcomes:=False;
    end else begin
     if TheOutcome=nil
     then begin
      TheOutcome:=New(POutcome,Init(TheGame));
      with TheOutcome^ do begin
       SetWhat(APlayer,TheMove,TheCell);
       TheGame^.OutcomeSet^.Insert(TheOutcome);
       MakeTwin(nil);{Ingnored if not sym-evol. Inserted in outcome set with attrib}
      end;
     end;
     with TheOutcome^ do begin
      SetPayoff(ThePayoff);
      if Twin<>nil then Twin^.SetPayoff(ThePayoff);
     end;
    end;
   end;
  end else if (TheOutcome<>nil) then TheGame^.OutcomeSet^.Free(TheOutcome);
 end;
begin
 CanReadOutcomes:=True;
 with TheGame^ do
 if IsEvolutionary and IsSymmetric
 then CheckOutcome(PlayerSet^.At(0))
 else PlayerSet^.ForEach(@CheckOutcome);
end;

procedure TEditOutcome.Delete;
begin
 if (Position<0) then Exit;
 with TheGame^ do
  if PlayerSet^.Count>Position
  then begin
   ThePlayer:=PlayerSet^.At(Position);
   FindOutcome(IsMoveCase,TheMove,TheCell,ThePlayer,TheOutcome);
   if TheOutcome<>nil
   then begin
    if TheOutcome^.Twin<>nil then OutcomeSet^.Free(TheOutcome^.Twin);
    OutcomeSet^.Free(TheOutcome);
    OutcomeSet^.Pack;
   end else begin
    LoadString(HInstance,81,InfoString,LongSize);
    WhatIsWrong(HWindow,InfoString);
   end;
  end;
  StrCopy(PayoffText,'Undefined');
  SendDlgItemMsg(401+Position,wm_SetText,0,LongInt(@PayoffText));
end;

procedure TEditOutcome.Ok;
begin
 if CanReadOutcomes
 then begin
  DumpDuplicates;
  EndDlg(id_Ok);
 end;
end;

procedure TEditOutcome.Cancel;
begin
 RestoreDuplicates;
 EndDlg(id_Cancel);
end;

procedure TPickOutcome.SetupWindow;
 procedure PrintName(AGameObject:PGameObject); far;
 begin
  SendDlgitemMsg(102,lb_AddString,0,LongInt(AGameObject^.ShowName));
 end;
 procedure PrintCellName(ACell:PCell); far;
 begin
  SendDlgitemMsg(102,lb_AddString,0,LongInt(ACell^.ShowCellName));
 end;
begin
 if TheGame^.IsNormalForm
 then begin
  SetWindowText(HWindow,'Choose Cell');
  TheGame^.CellSet^.ForEach(@PrintCellName);
 end else begin
  SetWindowText(HWindow,'Choose Move');
  TheGame^.MoveSet^.ForEach(@PrintName);
 end;
end;

procedure TPickOutcome.Change(var Msg:TMessage);
var
 Dlg    : PEditOutcome;
 AMove  : PMove;
 ACell  : PCell;
 Index  : Integer;
 AResource:LongName;
 ACount:Byte;
begin
 if Msg.LParamHi=lbn_SelChange
 then begin
  Index:=SendDlgItemMsg(102,lb_GetCurSel,0,LongInt(0));
  ACell:=nil;AMove:=nil;
  if TheGame^.IsNormalForm
  then ACell:=TheGame^.CellSet^.At(Index)
  else AMove:=TheGame^.MoveSet^.At(Index);
  with TheGame^ do
  if IsEvolutionary and IsSymmetric
  then ACount:=1
  else ACount:=PlayerSet^.Count;
  if (ACount>=1) and (ACount<=4)
  then begin
   StrCopy(AResource,FindResChar(ACount,TheGame^.IsNormalForm));
   Dlg:=New(PEditOutcome,Init(@Self,AResource,ACell,AMove));
   if Application^.ExecDialog(Dlg)=id_Ok
   then EndDlg(id_Ok)
   else EndDlg(id_Cancel);
  end else begin
   LoadString(HInstance,124,ErrorString,LongSize);
   WhatIsWrong(HWindow,ErrorString);
   EndDlg(id_Cancel);
  end;
 end;
end;

procedure TSelectMove.SetupWindow;
 procedure PrintName(AGameObject:PGameObject); far;
 begin
   SendDlgitemMsg(102,lb_AddString,0,
                   LongInt(AGameObject^.ShowName));
 end;
begin
 SetWindowText(HWindow,'Choose Move');
 TheGame^.MoveSet^.ForEach(@PrintName);
end;

procedure TSelectMove.Select;
var
 Index  : Integer;
begin
 if Msg.LParamHi=lbn_SelChange
 then begin
  TheGame^.SelectedMove:=nil;
  Index:=SendDlgItemMsg(102,lb_GetCurSel,0,LongInt(0));
  if Index>=0 then TheGame^.SelectedMove:=TheGame^.MoveSet^.At(Index);
  TheGame^.SelectedObject:=TheGame^.SelectedMove;       {For drawing}
 end;
end;

procedure TDeleteStrategy.SetupWindow;
 procedure PrintName(AGameObject:PGameObject); far;
 begin
   SendDlgitemMsg(102,lb_AddString,0,
                  LongInt(AGameObject^.ShowName));
 end;
begin
 SetWindowText(HWindow,'Pick a choice');
 TheGame^.StrategySet^.ForEach(@PrintName);
end;

procedure TDeleteStrategy.Delete(var Msg:TMessage);
var
 TheStrategy    : PStrategy;
 Index          : Integer;
begin
 if Msg.LParamHi=lbn_SelChange
 then begin
   Index:=SendDlgItemMsg(102,lb_GetCurSel,0,LongInt(0));
   TheStrategy:=TheGame^.StrategySet^.At(Index);
   LoadString(HInstance,113,StringText,LongSize);
   LoadString(HInstance,16,StringTitle,LongSize);
   if MessageBox(HWindow,StrCat(StringText,TheStrategy^.ShowName),
                  StringTitle,mb_OkCancel or mb_IconQuestion)=idOk
   then if TheGame^.DeleteStrategy(TheStrategy)   {Will delete a non-nil twin}
        then EndDlg(id_Ok)
        else begin
         LoadString(HInstance,129,ErrorString,LongSize);
         WhatIsWrong(HWindow,ErrorString);
         EndDlg(id_Cancel);
        end;
 end;
end;

procedure TEditStrategy.SetupWindow;
 procedure PrintName(AGameObject:PGameObject); far;
 begin
  SendDlgItemMsg(102,lb_AddString,0,LongInt(AGameObject^.ShowName));
 end;
begin
 SetWindowText(HWindow,'Pick a choice');
 TheGame^.StrategySet^.ForEach(@PrintName);
end;

procedure TEditStrategy.Change(var Msg:TMessage);
var
 Dlg            : PDialog;
 Index          : Integer;
 AName          : NameType;
begin
 if Msg.LParamHi=lbn_SelChange
 then with TheGame^ do begin
  Index:=SendDlgItemMsg(102,lb_GetCurSel,0,LongInt(0));
  AStrategy:=StrategySet^.At(Index);
  if IsEvolutionary and IsSymmetric
  then Dlg:=New(PMakeSymStrat,Init(@Self,'NAME_DLG',False,AStrategy))
  else Dlg:=New(PMakeStrategy,Init(@Self,'STRATEGY_DLG',False,AStrategy));
  if Application^.ExecDialog(Dlg)=id_Ok
  then EndDlg(id_Ok) else EndDlg(id_Cancel);
 end;
end;

constructor TMakeSymStrat.Init(AParent:PWindowsObject;AResource:PChar;IsNew:Boolean;AStrategy:PStrategy);
begin
 TDialog.Init(AParent,AResource);
 IsNewStrat:=IsNew;
 TheStrat:=AStrategy;
end;

procedure TMakeSymStrat.SetupWindow;
var ACaption       : PChar;
begin
 TDialog.SetupWindow;
 if IsNewStrat
 then ACaption:='New Choice'
 else ACaption:='Edit Choice';
 SetDlgItemText(HWindow,101,TheStrat^.ShowName);
 SetWindowText(HWindow,ACaption);
end;

procedure TMakeSymStrat.Ok;
var NewName:NameType;
begin
 StrCopy(NewName,'');
 GetDlgItemText(HWindow,101,NewName,SizeOf(NewName));
 if (StrLen(NewName)>0)
 then with TheStrat^ do begin
  SetName(NewName);
  if IsNewStrat then SetOwner(PGameType(Game)^.PlayerSet^.At(0))
                else if Twin<>nil then Twin^.SetName(NewName);
  EndDlg(id_Ok);
 end else begin
  LoadString(HInstance,62,NewName,NameSize);
  WhatIsWrong(HWindow,NewName);
 end;
end;

constructor TMakeStrategy.Init(AParent:PWindowsObject;
                               AResource:PChar;IsNew:Boolean;AStrategy:PStrategy);
begin
 TDialog.Init(AParent,AResource);
 IsNewStrategy:=IsNew;
 TheStrategy:=AStrategy;
 if IsNewStrategy
 then begin
  TheOwner:=nil;
  OwnerIndex:=-1;          {Not chosen yet}
 end else begin
  TheOwner:=TheStrategy^.Owner;
  OwnerIndex:=TheGame^.PlayerSet^.IndexOf(TheOwner)+1
 end;
end;

procedure TMakeStrategy.SetupWindow;
 procedure PrintName(AGameObject:PGameObject); far;
 begin
   SendDlgItemMsg(202,lb_AddString,0,LongInt(AGameObject^.ShowName));
 end;
begin
 if IsNewStrategy
 then StrCopy(AText,'New choice')
 else begin
  StrCopy(AText,'Edit choice');
  SetDlgItemText(HWindow,201,TheStrategy^.ShowName);
 end;
 SetWindowText(HWindow,AText);
 TheGame^.PlayerSet^.ForEach(@PrintName);
 UpdateStrategy;
end;

procedure TMakeStrategy.UpdateStrategy;
begin
 if TheOwner=nil
 then StrCopy(AText,'')
 else StrCopy(AText,TheOwner^.ShowName);
 SetDlgItemText(HWindow,203,AText);
end;

procedure TMakeStrategy.SetOwner(var Msg:TMessage);
var
 NewName        : NameType;
begin
 OwnerIndex:=1+SendDlgItemMsg(202,lb_GetCurSel,0,LongInt(0)); {Owner index}
 if IsNewStrategy
 then begin
  if (OwnerIndex>=1) and (OwnerIndex<=TheGame^.PlayerSet^.Count)
  then TheOwner:=TheGame^.PlayerSet^.At(OwnerIndex-1)
  else OwnerIndex:=-1;
  UpdateStrategy;
 end else if (OwnerIndex<>TheGame^.PlayerSet^.IndexOf(TheOwner)+1)
          then OwnerIndex:=-2;
end;

procedure TMakeStrategy.Ok;
var
 NameIsOk,
 OwnerIsOk      : Boolean;
 NewName        : NameType;
 StringText     : LongName;
begin
 GetDlgItemText(HWindow,201,NewName,SizeOf(NewName));
 if (StrLen(NewName)<=0) {and IsNewStrategy}
 then begin
  LoadString(HInstance,62,StringText,LongSize);
  WhatIsWrong(HWindow,StringText);
  NameIsOk:=False;
 end else NameIsOk:=True;
 if (OwnerIndex<0)
 then begin
  case OwnerIndex of
  -1:  LoadString(HInstance,63,StringText,LongSize);
  -2:  LoadString(HInstance,114,StringText,LongSize);
  end;
  WhatIsWrong(HWindow,StringText);
  OwnerIsOk:=False;
 end else OwnerIsOk:=True;
 if NameIsOk and OwnerIsOk
 then with TheStrategy^ do begin
  if StrLen(NewName)>0 then SetName(NewName);
  SetOwner(TheOwner);
  TheGame^.AdjustCells(True,nil);  {Add cells with this strategy}
  EndDlg(id_Ok);
 end;
 if OwnerIndex=-2
 then OwnerIndex:=TheGame^.PlayerSet^.IndexOf(TheOwner)+1;
end;

 {----------------------------------------------}
 {----Unit execution----------------------------}
 {----------------------------------------------}

 {The following is highly suspect. It creates default objects for evolutionary stuff}

 procedure InitEditUnit;
 begin
 end;


begin
end.

