
{Copyright (c), Jean-Pierre P. Langlois, 2007-2022}

Unit GP_Cnst;

interface

uses WinTypes,WinDos;

const

 cm_NewTable      = 100;
 cm_NewGame       = 101;
 cm_NewEvolution  = 191;
 cm_1Population   = 192;
 cm_2Population   = 193;
 cm_TextOpen      = 150;
 cm_SaveText      = 151;
 cm_Open          = 102;
 cm_Save          = 103;
 cm_SaveAs        = 104;
 cm_Convert       = 114;
 cm_PrintGame     = 105;
 cm_PrinterSetup  = 106;
 {cm_PrintStat     = 107;}
 cm_ShowList      = 108;
 cm_ShowLog       = 109;
 cm_EditTitle     = 110;
 cm_ReDrawTitle   = 111;
 cm_AddComment    = 115;
 cm_EditComment   = 116;
 cm_DeleteComment = 117;
 cm_ReDrawComment = 118;
 cm_Protect       = 120;
 cm_Inspect       = 130;
 cm_Quit          = 24340;

 cm_AddPlayer     = 201;
 cm_DeletePlayer  = 202;
 cm_EditPlayer    = 203;
 cm_ReDrawPlayer  = 204;
 cm_PDelete       = 212;
 cm_PEdit         = 213;
 cm_PReDraw       = 214;

 cm_AddNode       = 301;
 cm_DeleteNode    = 302;
 cm_EditNode      = 303;
 cm_Information   = 304;
 cm_ReDrawNode    = 305;
 cm_NDelete       = 312;
 cm_NEdit         = 313;
 cm_NInfo         = 314;
 cm_NReDraw       = 315;

 cm_AddMove       = 401;
 cm_DeleteMove    = 402;
 cm_EditMove      = 403;
 cm_Outcome       = 444;
 cm_ReDrawMove    = 405;
 cm_MDelete       = 412;
 cm_MEdit         = 413;
 cm_MOutcome      = 414;
 {cm_COutcome      = 424;}
 cm_MReDraw       = 415;

 cm_AddStrategy   = 421;
 cm_DeleteStrategy= 422;
 cm_EditStrategy  = 423;
 cm_MDeActivate   = 499;
 cm_SDelete       = 432;
 cm_SEdit         = 433;
 cm_AddEvolver    = 431;   {Add strategy}
 cm_DeleteEvolver = 442;
 cm_EditEvolver   = 443;
 cm_EvDelete      = 452;
 cm_EvEdit        = 453;

 cm_Solve         = 500;
 cm_PureSolve     = 501;
 cm_Explore       = 502;
 cm_Sample        = 504;
 cm_Match         = 535;
 cm_Tournament    = 536;
 cm_Replicator    = 537;
 cm_Nash          = 521;
 cm_Perfect       = 522;
 cm_Sequential    = 523;
 {cm_Evolution     = 524;}
 cm_SaveSolution  = 551;
 cm_LoadSolution  = 552;
 cm_ReturnToEdit  = 505;
 cm_PurgeSolution = 596;
 cm_AuditGame     = 510;
 cm_Horizon       = 515;
 cm_Noise         = 516;
 cm_Generation    = 517;
 cm_ShowSol       = 520;
 cm_Control       = 590;
 cm_MakeSpy       = 598;

 cm_DisplayNames  = 601;
 cm_DisplayDiscounts = 602;
 cm_DisplayOne    = 603;
 cm_DisplayAll    = 604;
 cm_DisplayProba  = 605;
 cm_DisplayBelief = 606;
 cm_DisplayColor  = 607;
 cm_DisplayGrid   = 610;
 cm_DisplayScientific = 611;
 cm_DisplayAbsolute   = 612;
 cm_DisplayComments   = 613;
 cm_Zoom              = 615;
 cm_DisplayIncent = 690;
 cm_ProbaIncentShift  = 691;
 cm_SwitchForm    = 695;
 cm_ShiftFocus    = 696;

 cm_DisplayStructure = 651;
 cm_DisplayActivity  = 652;
 cm_DisplayMax       = 698;
 cm_DisplayFreedom   = 699;

 cm_Options          = 700;

 cm_Absolute         = 701;
 cm_DefaultLength    = 703;

 cm_HelpContents     = 800;
 cm_About            = 850;
 cm_Registration     = 870;
 cm_FillRegForm      = 871;

 id_Abort            = 3;
 id_Show             = 111;
 id_ShowOne          = 112;
 id_ShowFew          = 113;
 id_Update           = 104;
 id_Dump             = 103;
 id_ShowNone         = 102;
 id_SaveAll          = 105;
 id_Resume           = 199;
 id_Icon             = 'Icon_1';
 id_Small            = 400;
 id_Normal           = 401;
 id_Large            = 402;
 id_ChooseStart      = 100;

 id_Undef       = 200;
 id_Blue        = 201;
 id_Red         = 202;
 id_Green       = 203;
 id_Black       = 204;
 id_Cyan        = 205;
 id_Pink        = 206;
 id_Yellow      = 207;
 id_Gray        = 208;
 id_Pastel      = 209;
 id_Purple      = 210;
 id_Khaki       = 211;
 id_Neon        = 212;

 sv_Profile          = 10;
 sv_Direction        = 20;
 sv_NewProfile       = 100;

 MicroSize        = 5;
 SmallSize        = 8;
 NameSize         = 15;
 LongSize         = 60;
 HugeSize         = 240;
 MaxPlayerNumber  = 4;
 MaxDegree        = 10;
 MaxInfoDegree    = 4;
 MaxInfoNumber    = 12;
 MaxNodeNumber    = 48;
 MaxMoveNumber    = 96;
 MaxStratNumber   = 24;
 MaxStrategy      = 256;
 MaxEquilNumber   = 100;
 MaxDimension     = 48;
 MaxComp          = 19;
 MaxDim           = 36;
 MaxStrategySet   = 2000;
 MaxHistory       = 4;
 {BarrierConst     = 1.0E-3;}
 MaxDepth         = 18;
 FileDim          = 250;
 IntegZero        = 0;
 LinesPerPage     = 65;

 SafeZero         = 0.0;
 SafeP36          = 1.0E+36;
 SafeP30          = 1.0E+30;
 SafeP24          = 1.0E+24;
 SafeP18          = 1.0E+18;
 SafeP12          = 1.0E+12;
 SafeP06          = 1.0E+06;
 SafeOne          = 1.0;
 SafeM06          = 1.0E-06;
 SafeM12          = 1.0E-12;
 SafeM18          = 1.0E-18;
 SafeM24          = 1.0E-24;
 SafeM30          = 1.0E-30;
 SafeM36          = 1.0E-36;

 TopDefault       = 1.0E+32;
 StartDefault     = 1.0E+24;    {Changed from 1.0E+24 Feb 99}
 HighDefault      = 1.0E+16;
 SingletDefault   = 1.0E+08;
 MidHighDefault   = 1.0E+03;
 BayesDefault     = 1.0E-08;
 LowDefault       = 1.0E-16;
 VeryLowDefault   = 1.0E-24;
 TinyDefault      = 1.0E-32;
 MaxPayoff        = 1.0E+03;
 MinPayoff        = 1.0E-03;
 MatrixCheck      = 1.0E-06;
 LowTruncation    = 1.0E-06;
 Tolerance        = 1.0E-04;
 LowTolerance     = 1.0E-06;
 MidwayDefault    = 1.0E-07;    {Changed from 1.0E-08 to test Feb 99}
 LowThreshold     = 1.0E-03;    {Cutoff test for near optimality}
 HighThreshold    = 1.0E-07;    {Fine Test for optimality}
 CutoffThreshold  = 1.0E-07;    {Norm cut off mixedsolve iteration}
 NormThreshold    = 1.0E-16;    {Changed from 1.0E-17 to test Feb 99}
 MinStep          = 2.40E-01{5.0E-02};
 InitStep         = 0.5;
 MaxIteration     = 20{40};
 ProfileCutOff    = 35{30};
 TooSlow          = 4;
 SafetyDiscount   = 0.9999999999;
 DefaultHorizon   = 20;
 MaxHorizon       = 1000;
 DefaultNoise     = 0.0;
 DefaultGener     = 10;
 MaxGeneration    = 100;

 {Game Info types}
 gi_TooSmallBug   = 0;
 gi_DegreeBug     = 1;
 gi_OutcomeBug    = 2;

 gi_TwinStrat     = 21;
 gi_TwinEvol      = 22;

 {Display Mode}
 dm_Name          = 0;
 dm_Discount      = 1;
 dm_AllValues     = 2;
 dm_OneValue      = 3;
 dm_Proba         = 4;
 dm_Belief        = 5;
 dm_Incentive     = 6;
 dm_ShowColor     = 7;
 dm_GridOn        = 10;
 dm_Scientific    = 11;
 dm_Absolute      = 12;
 dm_Comments      = 13;
 dm_Start         = 100;
 dm_Edit          = 101;
 dm_EditXtensive  = 111;
 dm_EditNormal    = 121;
 dm_PerfectSolve  = 102;
 dm_NashSolve     = 103;

 {Logic Type}

 lt_OwnChce       = 100;  {Var types}
 lt_OppChce       = 101;
 lt_RealVar       = 102;

 lt_SetOwn        = 110;  {Assign types}
 lt_SetOpp        = 111;
 lt_SetReal       = 112;
 lt_SetOper       = 113;
 lt_SetResp       = 114;

 lt_TestOwn       = 120;  {Test types}
 lt_TestOpp       = 121;
 lt_TestReal      = 122;
 lt_TestBool      = 124;

 {lt_Execute       = 130;  {Step types}
 lt_IfThen        = 131;
 lt_IfThenElse    = 132;
 lt_Goto          = 134;
 lt_Exit          = 135;

 lt_Other         = 140;

 lc_Steps         = 1;
 lc_Msg           = 2;

 {Assign Type}
 at_ToVar         = 12;
 at_ToConst       = 13;
 at_ToTurn        = 14;
 at_ToRand        = 15;
 at_ToOwn         = 16;
 at_ToOpp         = 17;
 at_ToResp        = 18;

 {Oper Type}
 op_Plus          = 21;
 op_Minus         = 22;
 op_Times         = 23;
 op_DivBy         = 24;

 {Bool Type}
 bt_IsTurn        = 24;
 bt_IsOwn         = 25;
 bt_IsOpp         = 26;
 bt_EqualTo       = 18;
 bt_LessThan      = 19;
 bt_MoreThan      = 20;
 bt_DiffFrom      = 21;

 bt_None          = 30;
 bt_Or            = 31;
 bt_And           = 32;
 bt_Neg1          = 33;
 bt_Neg2          = 34;
 bt_NegTwice      = 35;
 bt_NoNeg         = 36;

 ModeSet         = [211,212,221,222,223,231,232,233];

 {Window Case}
 {wc_Graph         = 1;
 wc_Solution      = 2;
 wc_Table         = 6;
 wc_Evolve        = 7;
 wc_ShowEvolve    = 8;

 {Solution Mode used in file content and solution window display}
 sm_Undefined     = 000;
 sm_Rational      = 200;
 sm_Darwin        = 100;
 sm_Nash          = 001;
 sm_Perfect       = 002;
 sm_Sequential    = 003;
 sm_Pure          = 010;
 sm_Explore       = 020;
 sm_Sample        = 030;
 sm_Match         = 060;
 sm_Tournament    = 070;
 sm_Replicate     = 080;

 {GameForm}
 gf_Graph         = 1;
 gf_GraphSol      = 2;
 gf_Table         = 3;
 gf_TableSol      = 4;
 gf_Evolve        = 5;
 gf_EvolveSol     = 6;
 gf_Replicate     = 12;

 wc_List          = 7;
 wc_Audit         = 8;
 wc_Debug         = 9;
 wc_Match         = 10;
 wc_Replic        = 11;

 {Object Type}
 ot_GameObject    = 200;
 ot_GameInfo      = 206;
 ot_Player        = 201;
 ot_PreNode       = 202;
 ot_Move          = 203;
 ot_Outcome       = 204;
 ot_Info          = 205;
 ot_Choice        = 303;
 ot_Equilibrium   = 400;
 ot_Header        = 401;
{ ot_HeaderS       = 411; }
 ot_NodeS         = 402;
 ot_Node2         = 412;
 ot_Choice2       = 403;
 ot_Comment       = 501;
 ot_Protect       = 510;
 ot_Node          = 502;
 ot_EndGame       = 255;
 ot_GameUser      = 550;
 ot_LastDate      = 551;
 ot_Strategy      = 304;
 ot_StrategyS     = 314;
 ot_Cell          = 305;
 ot_Evolver       = 350;
 ot_EvBasic       = 351;
 ot_EvVar         = 352;
 ot_EvAssgn       = 353;
 ot_EvTest        = 354;
 ot_EvStep        = 355;

 NoFileStrX      = 'Extensive Form';
 NoFileStrN      = 'Normal Form';
 NoFileStrE      = 'Evolutionary';
 GracePeriod     = 60;
 GraceTurn       = 20;

 {Colors}
 cl_White       = $00000000;
 cl_Blue        = $00FF0000;
 cl_Red         = $000000FF;
 cl_Green       = $00008800;
 cl_Black       = $00000000;
 cl_Cyan        = $00FFFF00;
 cl_Pink        = $00FF00FF;
 cl_Yellow      = $0000FFFF;
 cl_Gray        = $00808080;
 cl_Pastel      = $00808000;
 cl_Purple      = $00800080;
 cl_Khaki       = $00008080;
 cl_Neon        = $0000FF00;

 {Sizes}
 sc_Small       = 1;
 sc_Medium      = 2;
 sc_Big         = 3;

type
 NameType       = array[0..NameSize] of Char;    {15 char}
 LongName       = array[0..LongSize] of Char;    {60 char}
 HugeName       = array[0..HugeSize] of Char;    {120 char}

const
 RsrvWrds       : array[0..44] of NameType =(' ','REAL VRBL','OWN CHCE','OPP CHCE','SET RESP',
                                      'SET REAL','SET OWN','SET OPP','TEST','STEP','EXIT',
                                      'OTHER','-','????','TO VRBL','TO CNST','TO RESP @TURN',
                                      'EQUAL TO SELF','PLUS','MINUS','TIMES','DIVBY',
                                      'TO VRBL','TO CNST','TO TURN','TO RAND','TO OWN PAY',
                                      'TO OPP PAY','IF','THEN','ELSE','GOTO','EXIT','IS',
                                      'SAME AS','NOT SAME AS','VRBL','CNST','EQUAL TO',
                                      'LESS THAN','MORE THAN','DIFF FROM','NOT','OR','AND');


 implementation

 end.
