unit PassUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,Utilities;

type
  TPassForm = class(TForm)
    OkButton: TButton;
    UserLabel: TLabel;
    SerialLabel: TLabel;
    PassLabel: TLabel;
    EnterPass: TEdit;
    Bevel1: TBevel;
    EmailButton: TButton;
    DateLabel: TLabel;
    Button1: TButton;
    procedure FormShow(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PassForm: TPassForm;
  CrntPass,InstallDate,SerialNumber,UpdateCode: Integer;
  UserName, SerialName, DateName,PassName,UpdateName: String;

implementation

{$R *.DFM}

procedure TPassForm.FormShow(Sender: TObject);
begin
  UserLabel.Caption:='User: '+UserName;
  SerialLabel.Caption:='Serial Number: '+MyIntToStr(SerialNumber);
  DateLabel.Caption:='Install Date: '+MyIntToStr(InstallDate);
  EnterPass.Text:=PassName;
  FocusControl(EnterPass);
end;

procedure TPassForm.OkButtonClick(Sender: TObject);
var EC:Integer;
begin
  UpdateName:=EnterPass.Text;
  Val(UpdateName,UpdateCode,EC);
  if EC<>0 then UpdateCode:=0; 
end;

end.
