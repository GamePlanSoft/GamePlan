unit AuditUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Printers, Type32, Constants;

type
  TAuditWindow = class(TForm)
    Memo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    AuditList : TGameList;
    procedure AddLine(ALine:String);
    procedure DisplayList;
    procedure PrintMemo;
    procedure ClearAll;
  end;

var
  AuditWindow: TAuditWindow;
  PrintFile  : TextFile;

implementation

{$R *.DFM}

procedure TAuditWindow.PrintMemo;
  procedure PrintLine(ALine:TGameObject32);
  begin
    Writeln(PrintFile,ALine.TextLine);
  end;
begin
  AssignPrn(PrintFile);
  Rewrite(PrintFile);
  try
    AuditList.ForEach(@PrintLine);
  finally
    System.CloseFile(PrintFile);
  end;
end;

procedure TAuditWindow.AddLine(ALine:String);
var ABug:TBug;
begin
  ABug:=TBug.Create(nil);
  ABug.SetLine(ALine);
  AuditList.Add(ABug);
end;

procedure TAuditWindow.ClearAll;
begin
  Memo.Clear;
  AuditList.FreeAll(ot_All);
end;

procedure TAuditWindow.DisplayList;
  procedure DisplayLine(ALine:TGameObject32);
  begin
    Memo.Lines.Add(ALine.TextLine);
  end;
begin
  AuditList.ForEach(@DisplayLine);
end;

procedure TAuditWindow.FormCreate(Sender: TObject);
begin
  AuditList:=TGameList.Create;
end;

procedure TAuditWindow.FormDestroy(Sender: TObject);
begin
  AuditList.FreeAll(ot_All);
  AuditList.Free;
end;

end.
