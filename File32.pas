{Copyright (c), Jean-Pierre P. Langlois, 2007-2022}

unit File32;

interface

uses Type32, Game32Type, Game32Solve, Utilities, Constants, Classes;

const
  BMPFile='Graphics.bmp';
  UserFile='gameplan.ini';

var
 TF                : Text;

function FileExists(AFileName:String):Boolean;
function FileOpen(AFileName:String;AGame:TGameType32):Boolean;
procedure FileSave(AFileName:String;AGame:TGameType32);
procedure SaveSolutionFile(AFileName:String;AGame:TGameType32);

implementation

function FileExists(AFileName:String):Boolean;
begin   {Needed when opening or appending}
  Assign(TF,AFileName);
  {$I-} Reset(TF); {$I+}
  if IoResult<>0 then FileExists:=False
  else begin
    FileExists:=True;
    Close(TF);
  end;
end;

function FileOpen(AFileName:String;AGame:TGameType32):Boolean;
var AStr:String; AnObject:TGameObject32;
   procedure Interpret;
   var SubStr: String;
   begin
     AnObject:=nil;
     SubStr:=ShowStringPart(AStr,sl_Name+3*sl_Short+1,sl_Short); {Changed!!!}
     case ValidInt(SubStr) of
       ot_Header   : AnObject:=TGameObject32.Create(AGame);
       ot_Player   : AnObject:=TPlayer32.Create(AGame);
       ot_Node     : AnObject:=TNode32.Create(AGame);
       ot_Move     : AnObject:=TMove32.Create(AGame);
       ot_Info     : AnObject:=TInfo32.Create(AGame);
       ot_Payoff   : AnObject:=TPayoff32.Create(AGame);
       ot_Table    : AnObject:=TTable32.Create(AGame);
       ot_Side     : AnObject:=TSide32.Create(AGame);
       ot_Strat    : AnObject:=TStrat32.Create(AGame);
       ot_Cell     : AnObject:=TCell32.Create(AGame);
       ot_Solution : AnObject:=TSolution32.Create(AGame);
       ot_Belief,
       ot_Proba,
       ot_Incent,
       ot_Expect,
       ot_StrProb,
       ot_StrInct  : begin AnObject:=TSolutionBit.Create(AGame);
                     TSolutionBit(AnObject).SetData(ValidInt(SubStr),nil,nil,nil,0); end;
     end;
     if AnObject<>nil then begin
       AnObject.SetLine(AStr);   {Crashes when opening gp.files}
       AGame.DispatchObject(AnObject);
     end;
   end;
begin
  FileOpen:=False;
  if FileExists(AFileName)
  then begin
    FileOpen:=True;
    Assign(TF,AFileName);
    Reset(TF);
    repeat
      Readln(TF,AStr);
      Interpret;
    until Eof(TF);
    AGame.ResetTies; {Reconnect objects. Reconstruct solutions}
    Close(TF);
    AGame.SetFileName(AFileName);
  end;
end;

procedure FileSave(AFileName:String;AGame:TGameType32);
  procedure WriteLine(AnObject:TGameObject32);
  begin
    if not AnObject.IsArtificial
    then Writeln(TF,AnObject.Description(fw_Saving));
  end;
begin
  AssignFile(TF, AFileName);
  Rewrite(TF);
  with AGame do begin
    //WriteLine(GameHeader);
    PlayerList.ForEach(@WriteLine);
    NodeList.ForEach(@WriteLine);
    MoveList.ForEach(@WriteLine);
    InfoList.ForEach(@WriteLine);
    ChoiceList.ForEach(@WriteLine);
    PayList.ForEach(@WriteLine);
    SetState(gs_CanClose);
  end;
  Close(TF);
  AGame.SetFileName(AFileName);
end;

procedure SaveSolutionFile(AFileName:String;AGame:TGameType32);
  procedure SolutionToFile(ASolution:TSolution32);
    procedure SaveBit(ABit:TSolutionBit);
    begin
      Writeln(TF,ABit.Description(fw_Saving));
    end;
  begin
    Writeln(TF,ASolution.Description(fw_Saving));
    ASolution.BitList.ForEach(@SaveBit);
  end;
begin
  if not FileExists(AFileName) then Exit;
  AssignFile(TF, AFileName);
  Reset(TF);
  Append(TF);
  AGame.SolutionList.ForEach(@SolutionToFile);
  AGame.SetState(gs_SavSol);
  Close(TF);
end;

end.
