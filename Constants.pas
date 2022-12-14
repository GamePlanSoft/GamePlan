{Copyright (c), Jean-Pierre P. Langlois, 2007-2022}

unit Constants;

interface

Const

{For graphing}
NameGap    = 24;
PayGap     = 7;
PlaySize   = 4;
NeckSize   = 5;
ArmSize    = 6;
BodySize   = 12;
LegSize    = 5;
NodeSize   = 10;
CopySize   = 20;

ArrowLen   = 4;
ArcPrecis  = 20; {Number of segments in the move curve}
ArcStep    = 1/ArcPrecis;
ArrowStep  = 100;

ThinPen    = 1;
ThickPen   = 5;  {Info pen}

SideHeight = 20;
CellWidth  = 100;
MarginDim  = 10;
RoundDim   = 10; {Rounding of table rectangle}

InfoStep   = 50; {Determines number of dots in info line}

HiLiteSize = 12;
DriftSize  = 2;
MaxDrift   = 20;
GridStep   = 10; {Determines minimum space between object positions}
DfltPos    = 100;
RectSize   = 80;
MinZoom    = 0.8;
MaxZoom    = 1.6;
ZoomStep   = 0.05;

TenK       = 10000;
Hundred    = 100;
ScrmblSize = 8;
ScrmblMag  = 100000000;
DfltID     = 12345678;

MinScrmbl  = 0.0001;
PhiMag     = 4*(1-MinScrmbl); {Coeff of Phi function for Scramble}
PassMagn   = 10000; {password and serial 4-digit integer}
YearLength = 365;
MonthLength= 31;
TrialLength= 30;  {Need only to adjust # of trial days here}
MinPass    = 100;
NameLen    = 30;
floatdgts  = 6;


{For solving}

Trembling      = 1.0E-6;
StepTest       = 5;

Epsilon        = 1.0E-6;
InitStep       = 1;
StepGrowth     = 1.25;
StepShrink     = 0.75;
MinStepTol     = 0.9;
MaxStepTol     = 1.1;
MinStepSize    = 0.01;
MaxStepSize    = 100;
MidStepNumber  = 10;
MaxHitFacet    = 5;
{MaxStepNumber  = 15;}
MidShrink      = 0.1;

MaxAbsValue    = 1.0E+150;
MinAbsValue    = 1.0E-150;
TopValue       = 1.0E+5; {Upper and lower bounds for payoffs}
MinValue       = 1.0E-5;
FadeValue      = 1.0E-8; {To set beliefs, probas and expectations to zero}
TopPower       = 240;
DeltaPower     = 8;     {Gives frequency off equilibrium path. Can use 8 instead}
ArtDiscount    = 1.0E-12;
MidFrequency   = 1.0;
NilFrequency   = 0.0;
{Tolerance      = 1.0E-08; {For optimality}
MaxDistance    = 1.0E-05; {Between two solutions}
Convergence    = 1.0E-16; {Max Norm for a solution}
LowProba       = 1.0E-08;

MinProba       = 1.0E-12;

StartProba     = 0;

MaxNodeDegree  = 12;
MaxMoveNumber  = 128;
MaxNodeNumber  = 64;
MaxStratNumber = 64;
MaxInteger     = 2000000000;
MaxSpeed       = 1.0;
TopSpeed       = 1.0E+06;
MinSpeed       = 0.05;
StepFactor     = 0.5;
ConvTestMin    = 0.01;
DfltDscnt      = 1.0;
MaxDscnt       = 0.999000001;
MinDscnt       = 0.001;
LargeMu        = 1.0E+06; {Max extension factor}

sm_None        = 00;
sm_Pure        = 01;
sm_Mixed       = 02;
sm_Sample      = 03;
sm_Profile     = 04;
sm_Dominated   = 05;
sm_Group       = 06;
sm_Duplicate   = 07;

sc_None        = 00;
sc_Nash        = 10;
sc_Perfect     = 20;
sc_Sequent     = 30;
sc_TooLong     = 40;
sc_NoBest      = 50;
sc_NoAssoc     = 60;
sc_NoDirect    = 70;
sc_TooFast     = 80;
sc_Dominated   = 90;

sd_LowDepth    = 10;
sd_MidDepth    = 15;
sd_HighDepth   = 20;

{Tokens}
clMyColor  = $01234567;
ZeroName   = '00000000';

{For object types}
ot_Undef    = 0;
ot_All      = 0;
ot_Unclean  = -1;
ot_SelRect  = 100;
ot_Player   = 201;
ot_Node     = 502;
ot_ArtNode  = 902;
ot_Side     = 403;
ot_Table    = 503;
ot_Move     = 203;
ot_ArtMove  = 903;
ot_Cell     = 504;
ot_Info     = 205;
ot_Payoff   = 204;
ot_Choice   = 303;
ot_Strat    = 304;

ot_SolGroup = 798;
ot_Profile  = 799;
ot_Solution = 800;
ot_Belief   = 801; {used in TSolutionBit}
ot_Proba    = 802;
ot_Incent   = 803;
ot_Expect   = 804;
ot_Deriv    = 805;
ot_Max      = 810;
ot_Min      = 811;
ot_StrProb  = 812;
ot_StrInct  = 813;
ot_Depth    = 820; 

ot_Header   = 900; {Add sm and sc constants for solutions}

{For sizing in file operations}
sl_Short   = 8;
sl_Name    = 16;

{Game state}
gs_New      = 100;
gs_Solved   = 101;
gs_Edited   = 102;
gs_CanClose = 103;
gs_SavSol   = 104;
gs_Solving  = 105;


{Game parameters}
gp_Horz    = 200; {Number of objects on horizontal}
gp_Vert    = 200; {Number of objects on vertical}

{Window cases}
wc_MainGame = 1;
wc_Audit    = 2;
wc_Solution = 3;
wc_Profile  = 4;
wc_Debug    = 5;
wc_SolLog   = 6;
wc_Test     = 7;

{Audit cases}
fw_Bugs      = 1;
fw_ObjList   = 2;
fw_Test      = 3;
fw_Debug     = 4;
fw_SolLog    = 5;
fw_Saving    = 6;
fw_Audit     = 7;

{Command enabling}
ce_Edit      = 0;
ce_Solve     = 1;
ce_Slct      = 2;
ce_UnSlct    = 3;

{Display}
dc_Proba     = 1;
dc_Belief    = 2;
dc_Expect    = 3;

{Registration}
rc_NoInstall = 1;
rc_NeedReg   = 2;
rc_TryUser   = 3;
rc_FullUser  = 4;
rc_Forever   = 5;



var IsDebug  : Boolean;
    ZoomSize : Real;

function Fade(AReal:Real):Real;

function Minimum(First,Second:Real):Real;

function Positive(AReal:Real):Real;

function TrueProba(AReal:Real):Real;

implementation

function Fade(AReal:Real):Real;
begin
  if ABS(AReal)<=FadeValue
  then Fade:=0
  else Fade:=AReal;
end;

function Minimum(First,Second:Real):Real;
begin
  if First<Second
  then Minimum:=First
  else Minimum:=Second;
end;

function Positive(AReal:Real):Real;
begin
  if AReal>=0 then Positive:=AReal else Positive:=0;
end;

function TrueProba(AReal:Real):Real;
begin
  if AReal<0 then TrueProba:=0
             else if AReal>1 then TrueProba:=1
                  else TrueProba:=AReal;
end;

end.
