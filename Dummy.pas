
Unit Dummy;

interface


implementation

procedure TSide32.RemoveAllChoices; {From game}
  procedure AddChoice(AChoice:TChoice32);
  begin
    TGameType32(Game).StratList.Remove(AChoice);
  end;
begin
  Choices.ForEach(@AddChoice);
end;

procedure TSide32.AddAllChoices; {To game}
  procedure RemoveChoice(AChoice:TChoice32);
  begin
    TGameType32(Game).StratList.Add(AChoice);
  end;
begin
  Choices.ForEach(@RemoveChoice);
end;

procedure TSide32.AssignTo;
  procedure DuplicateChoice(AChoice:TChoice32);
  var NewChoice:TStrat32;
  begin
    NewChoice:=TStrat32.Create(Game);
    NewChoice.SetName(AChoice.Name{+'*'});        {Replaces source (side/info)}
    NewChoice.SetSource(TSide32(Dest));
    AChoice.SetAssociate(NewChoice);            {For replacement steps in cells}
    NewChoice.SetAssociate(AChoice);
    TSide32(Dest).Choices.Add(NewChoice);
  end;
begin
  inherited AssignTo(Dest);           {Object.Assign for Name and Game}
  TSide32(Dest).SetOwner(Self.Owner); {Because no defined Info.Assign}
  TSide32(Dest).SetTable(Self.OwnTable);
  TSide32(Dest).Choices.FreeAll;
  Choices.ForEach(@DuplicateChoice);

  {Need to duplicate cells??}
end;

procedure TSide32.Remake;
begin
  inherited Remake;
  ObjType:=ot_Side;
  OwnTable:=nil;
  if Owner<>nil then SetName(Owner.Name) else SetName('No owner');
end;



end.



