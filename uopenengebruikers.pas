unit uOpenenGebruikers;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

function OpenenGebruiker(bestandsLocatie: string; gebruiker: string;
  wachtwoord: string; Zoeken: boolean): string;
function gebruikerSplitsen(regel: string; variabel: integer): string;

implementation

function OpenenGebruiker(bestandsLocatie: string; gebruiker: string;
  wachtwoord: string; Zoeken: boolean): string;
var
  bestand: TextFile; //Bestands pointer
  bestandGebruiker: string;
  return: string;
begin

  //Standaard zetten we dit op false
  //om te voorkomen dat bij een fout
  //een gebruiker toch toegang krijgt.
  return := 'false';

  AssignFile(bestand, bestandsLocatie);

  reset(bestand);

  while not EOF(bestand) do
  begin
    //Variabelen vullen
    ReadLn(bestand, bestandGebruiker);

    //Kijken of dit de juiste gebruiker is
    if (gebruikerSplitsen(bestandGebruiker, 0) = gebruiker) then
    begin
      if (gebruikerSplitsen(bestandGebruiker, 1) = wachtwoord) or (Zoeken = True) then
      begin
        return := 'true';
        break;
      end
      else
      begin
        return := 'false';
      end;
    end;
  end;

  //Bestand afsluiten, zeer belangrijk
  CloseFile(bestand);

  //Waarde terug sturen
  Result := return;

end;

function gebruikerSplitsen(regel: string; variabel: integer): string;
var
  C: char;
  resultaat: string;
  positie: integer;
begin

  //Standaard waardes
  positie := 0;
  resultaat:='';

  for C in regel do
  begin

    if (positie = variabel) and (C <> #9) then
    begin
      resultaat += C;
    end;

    if (C = #9) then
    begin
      positie += 1;
    end;
  end;

  Result := resultaat;

end;

end.

