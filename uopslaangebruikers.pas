unit uOpslaanGebruikers;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

procedure OpslaanGebruiker(bestandsLocatie: string; gebruiker: string;
  wachtwoord: string);

implementation

procedure OpslaanGebruiker(bestandsLocatie: string; gebruiker: string;
  wachtwoord: string);
var
  bestand: TextFile;
begin

  AssignFile(bestand, bestandsLocatie);

  //Gebruiker toevoegen aan bestand (dus append)
  Append(bestand);

  WriteLn(bestand, gebruiker + #9 + wachtwoord + #9 + '0');

  CloseFile(bestand);

end;

end.
