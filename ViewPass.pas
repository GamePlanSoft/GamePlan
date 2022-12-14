{Copyright (c), Jean-Pierre P. Langlois, 2007-2022}

unit ViewPass;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,Utilities;

type
  TViewPassForm = class(TForm)
    Button1: TButton;
    MakeButton: TButton;
    Label1: TLabel;
    Label2: TLabel;
    InputSerial: TEdit;
    OneYearPass: TEdit;
    Bevel1: TBevel;
    Label3: TLabel;
    InputDate: TEdit;
    Label4: TLabel;
    PermanentPass: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure MakeButtonClick(Sender: TObject);
    procedure InputSerialChange(Sender: TObject);
    procedure InputDateChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ViewPassForm: TViewPassForm;
  InSerial,InDate,OutPass: Integer;
  InSerialTxt,InDateTxt: String;

implementation

{$R *.DFM}

procedure TViewPassForm.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TViewPassForm.MakeButtonClick(Sender: TObject);
begin
  OutPass:=MakeScramble(Trunc((2*InSerial+InDate)/3));
  OneYearPass.Text:=MyIntToStr(OutPass);
  OutPass:=MakeScramble(Trunc((InSerial+2*InDate)/3){(InSerial+InDate)/2) for 30day});
  PermanentPass.Text:=MyIntToStr(OutPass);

end;

procedure TViewPassForm.InputSerialChange(Sender: TObject);
var EC:Integer;
begin
  InSerialTxt:=InputSerial.Text;
  Val(InSerialTxt,InSerial,EC);
  if EC<>0 then InSerial:=0;
end;

procedure TViewPassForm.InputDateChange(Sender: TObject);
var EC:Integer;
begin
  InDateTxt:=InputDate.Text;
  Val(InDateTxt,InDate,EC);
  if EC<>0 then InDate:=0;
end;

end.
