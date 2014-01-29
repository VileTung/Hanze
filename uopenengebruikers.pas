unit uOpenenGebruikers;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

function OpenenGebruiker(bestandsLocatie: string; gebruiker: string;
  wachtwoord: string; Zoeken: boolean): string;
function gebruikerSplitsen(regel: string; variabel: integer): string;
function GebruikersTellen(bestandsLocatie: string): integer;

implementation

uses uMain;

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

  //Als het bestand niet bestaat, maken we die aan :)
  if not FileExists(bestandsLocatie) then
  begin
    //Bestand aanmaken
    Rewrite(bestand);

    //Standaard gebruiker schrijven
    WriteLn(bestand, 'Admin' + #9 + 'Admin' + #9 + '1');

    //Asluiten
    CloseFile(bestand);

    //Opnieuw openen
    AssignFile(bestand, bestandsLocatie);
  end;

  Reset(bestand);

  while not EOF(bestand) do
  begin
    //Variabelen vullen
    ReadLn(bestand, bestandGebruiker);

    //Kijken of dit de juiste gebruiker is
    if (gebruikerSplitsen(bestandGebruiker, 0) = gebruiker) then
    begin
      if (gebruikerSplitsen(bestandGebruiker, 1) = wachtwoord) or (Zoeken = True) then
      begin

        //Kijken of het een Systeembeheerder is
        if (gebruikerSplitsen(bestandGebruiker, 2) = '1') then
        begin
          uMain.SysteemBeheerder := True;
        end;

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

function GebruikersTellen(bestandsLocatie: string): integer;
var
  bestand: TextFile; //Bestands pointer
  rijen: integer;
  Data: string;
begin

  //Standaard
  rijen := 0;

  AssignFile(bestand, bestandsLocatie);

  reset(bestand);

  while not EOF(bestand) do
  begin
    ReadLn(bestand, Data);

    if (gebruikerSplitsen(Data, 0) <> '') then
    begin
      rijen += 1;
    end;

  end;

  //Bestand afsluiten, zeer belangrijk
  CloseFile(bestand);

  //Waarde terug sturen
  Result := rijen;

end;


function gebruikerSplitsen(regel: string; variabel: integer): string;
var
  C: char;
  resultaat: string;
  positie: integer;
begin

  //Standaard waardes
  positie := 0;
  resultaat := '';

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


