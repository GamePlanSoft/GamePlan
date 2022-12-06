unit Registration;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Math, Constants, ExtCtrls, Utilities, PassUnit;


type

  TRegistrationForm = class(TForm)
    FirstEdit: TEdit;
    LastEdit: TEdit;
    OKButton: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Bevel1: TBevel;
    procedure OKButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure MakeSerial;
  end;

var
  RegCase:   Integer;

implementation

{$R *.DFM}

procedure TRegistrationForm.MakeSerial;
begin
  InstallDate:=TodaysDate;  {In Utilities: transforms date into 8-digit integer}
  DateName:=MyIntToStr(InstallDate);
  Randomize;
  SerialNumber:=Random(PassMagn*PassMagn); {Makes 8-digit random number}
  {ShowMessage('Serial = '+IntToStr(SerialNumber));  }
  SerialName:=MyIntToStr(SerialNumber); {Will be used to check that installation is legal}
  CrntPass:=MakeScramble(Trunc((SerialNumber+InstallDate)/2)); {Initiates 30-day license}
  PassName:=MyIntToStr(CrntPass);
end;

procedure TRegistrationForm.OKButtonClick(Sender: TObject);
var Buffer: array [0..NameLen] of Char;
begin
    UserName:=FirstEdit.Text+' '+LastEdit.Text;
    if (Length(UserName)<=5)
    then MessageDlg('Not Enough Name Characters', mtInformation, [mbOk], 0)
    else begin
      StrLCopy(Buffer,PChar(UserName),NameLen);
      Username:=String(Buffer);


      MakeSerial;
      ModalResult:=mrOk;
    end;
end;

end.
