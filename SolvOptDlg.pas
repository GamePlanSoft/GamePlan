{Copyright (c), Jean-Pierre P. Langlois, 2007-2022}

unit SolvOptDlg;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Constants;

type
  TSolveOptionsDlg = class(TForm)
    OKBtn: TButton;
    MethodGroup: TRadioGroup;
    procedure FormActivate(Sender: TObject);
    procedure MethodGroupClick(Sender: TObject);
    procedure ConceptGroupClick(Sender: TObject);
    {procedure DepthGroupClick(Sender: TObject); }
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    procedure InitSolveOptions;
    { Public declarations }
  end;

var
  SolveOptionsDlg  : TSolveOptionsDlg;
  SolveOptions     : record
                       SolveMethod  : Integer;
                       SolveConcept : Integer;
                       SolveDepth   : Integer;
                     end;

implementation



{$R *.DFM}

procedure TSolveOptionsDlg.InitSolveOptions;
begin
  with SolveOptions do begin
    SolveMethod:=sm_Mixed;
    SolveConcept:=sc_Perfect;
    SolveDepth:=sd_HighDepth;
  end;
end;

procedure TSolveOptionsDlg.FormActivate(Sender: TObject);
begin
  case SolveOptions.SolveMethod of
    sm_Pure   : (MethodGroup.Controls[0] as TRadioButton).Checked:=True;
    sm_Mixed  : (MethodGroup.Controls[1] as TRadioButton).Checked:=True;
    sm_Sample : (MethodGroup.Controls[2] as TRadioButton).Checked:=True;
  end;
  {case SolveOptions.SolveDepth of
    {sd_LowDepth  : (DepthGroup.Controls[0] as TRadioButton).Checked:=True; }
    {sd_MidDepth : (DepthGroup.Controls[0] as TRadioButton).Checked:=True;
    sd_HighDepth : (DepthGroup.Controls[1] as TRadioButton).Checked:=True;
    {sc_Sequent  : (ConceptGroup.Controls[2] as TRadioButton).Checked:=True;}
  {end;}
end;

procedure TSolveOptionsDlg.MethodGroupClick(Sender: TObject);
begin
  if (MethodGroup.Controls[0] as TRadioButton).Checked
  then SolveOptions.SolveMethod:=sm_Pure
  else if (MethodGroup.Controls[1] as TRadioButton).Checked
       then SolveOptions.SolveMethod:=sm_Mixed
       else SolveOptions.SolveMethod:=sm_Sample;
end;

procedure TSolveOptionsDlg.ConceptGroupClick(Sender: TObject);
begin
  {if (ConceptGroup.Controls[0] as TRadioButton).Checked
  then SolveOptions.SolveConcept:=sc_Nash
  else if (ConceptGroup.Controls[1] as TRadioButton).Checked
       then SolveOptions.SolveConcept:=sc_Perfect
       else SolveOptions.SolveConcept:=sc_Sequent; }
end;

{procedure TSolveOptionsDlg.DepthGroupClick(Sender: TObject);
begin
  if (DepthGroup.Controls[0] as TRadioButton).Checked
  then SolveOptions.SolveDepth:=sd_LowDepth
  else if (DepthGroup.Controls[1] as TRadioButton).Checked
       then SolveOptions.SolveDepth:=sd_HighDepth;
end;}

procedure TSolveOptionsDlg.FormCreate(Sender: TObject);
begin
  InitSolveOptions;
end;

end.
