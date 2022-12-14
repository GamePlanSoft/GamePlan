{Copyright (c), Jean-Pierre P. Langlois, 2007-2022}

unit OptionsDlg;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls;

type
  TSolveOptionsDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    ConceptGroup: TRadioGroup;
    MethodGroup: TRadioGroup;
    PureRadioButton: TRadioButton;
    MixedRadioButton: TRadioButton;
    NashRadioButton: TRadioButton;
    PerfectRadioButton: TRadioButton;
    SequentialRadioButton: TRadioButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SolveOptionsDlg: TSolveOptionsDlg;

implementation

{$R *.DFM}

end.
