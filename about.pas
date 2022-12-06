unit About;

interface

uses Windows, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, SysUtils, Constants;

type
  TAboutBox = class(TForm)
    OKButton: TButton;
    Panel1: TPanel;
    ProgramIcon: TImage;
    ProductName: TLabel;
    Version: TLabel;
    Copyright: TLabel;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure MakeSplash;
    procedure Delay;
  end;

var
  AboutBox: TAboutBox;

implementation

uses Registration, PassUnit;

{$R *.DFM}

procedure TAboutBox.MakeSplash;
begin
  BorderStyle:=bsNone;
  Height:=185;
  OkButton.Visible:=False;
  Show; Update;
end;

procedure TAboutBox.Delay;
var TimeOut:TDateTime;
begin
  TimeOut:=Now+EncodeTime(0,0,3,0);
  while Now<=TimeOut do Application.ProcessMessages;
end;

procedure TAboutBox.FormShow(Sender: TObject);
begin
  {if RegCase=rc_FullUser
  then UserLabel.Caption:='Licensed to '+UserName
  else UserLabel.Caption:='Unregistered user';  }
end;

end.

