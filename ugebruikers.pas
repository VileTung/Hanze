unit uGebruikers;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Menus;

type

  { TGebruikersFrm }

  TGebruikersFrm = class(TForm)
    MainMenu_Gebruikers: TMainMenu;
    Memo_Lijst: TMemo;
    MenuItem: TMenuItem;
    MenuItemLaden: TMenuItem;
    MenuWijzigen: TMenuItem;
    MenuVerwijderen: TMenuItem;
    procedure MenuItemLadenClick(Sender: TObject);
    procedure MenuVerwijderenClick(Sender: TObject);
    procedure MenuWijzigenClick(Sender: TObject);
    procedure MemoVullen();
    procedure BestandBijwerken();
  private
    { private declarations }
  public
    { public declarations }
  end;

  Gebruikers = record
    gebruiker, wachtwoord, admin: string;
  end;

var
  GebruikersFrm: TGebruikersFrm;
  GebruikersArray: array[0..4] of Gebruikers;

implementation

uses uOpenenGebruikers;

{$R *.lfm}

{ TGebruikersFrm }

procedure TGebruikersFrm.MenuItemLadenClick(Sender: TObject);
var
  bestand: TextFile; //Bestands pointer
  i: integer;
  Data: string;
begin

  Memo_Lijst.Clear;

  AssignFile(bestand, ExtractFilePath(Application.ExeName) + 'gebruikers');

  reset(bestand);

  i := 0;

  while not EOF(bestand) do
  begin
    ReadLn(bestand, Data);

    GebruikersArray[i].gebruiker := uOpenenGebruikers.gebruikerSplitsen(Data, 0);
    GebruikersArray[i].wachtwoord := uOpenenGebruikers.gebruikerSplitsen(Data, 1);
    GebruikersArray[i].admin := uOpenenGebruikers.gebruikerSplitsen(Data, 2);

    if (GebruikersArray[i].gebruiker <> '') then
    begin
      Memo_Lijst.Lines.add(IntToStr(i) + #9 + GebruikersArray[i].gebruiker +
        #9 + GebruikersArray[i].wachtwoord);
    end;

    i += 1;

  end;

  //Bestand afsluiten, zeer belangrijk
  CloseFile(bestand);

end;

procedure TGebruikersFrm.MenuVerwijderenClick(Sender: TObject);
var
  Gebruiker: string;
  ID: integer;
begin

  Gebruiker := InputBox('Gebruiker verwijderen!', 'Welke gebruiker wilt u verwijderen?',
    'Voer het ID in!');

  try
    ID := StrToInt(Gebruiker);

    GebruikersArray[ID].gebruiker := '';

    GebruikersArray[ID].wachtwoord := '';

    GebruikersArray[ID].admin := '';

    MemoVullen();

  except
    ShowMessage('Geen geldige ID opgegeven!');
  end;

end;

procedure TGebruikersFrm.MenuWijzigenClick(Sender: TObject);
var
  Gebruiker: string;
  ID: integer;
begin

  Gebruiker := InputBox('Gebruiker wijzigen!', 'Welke gebruiker wilt u wijzigen?',
    'Voer het ID in!');

  try
    ID := StrToInt(Gebruiker);

    GebruikersArray[ID].gebruiker :=
      InputBox('Gebruikersnaam wijzigen!', 'Nieuwe gebruikersnaam:',
      GebruikersArray[ID].gebruiker);

    GebruikersArray[ID].wachtwoord :=
      InputBox('Wachtwoord wijzigen!', 'Nieuwe wachtwoord:',
      GebruikersArray[ID].wachtwoord);

    MemoVullen();

  except
    ShowMessage('Geen geldige ID opgegeven!');
  end;

end;

procedure TGebruikersFrm.MemoVullen();
var
  i: integer;
begin

  GebruikersFrm.Memo_Lijst.Clear;

  i := 1;

  for i := low(GebruikersArray) to high(GebruikersArray) do
  begin

    if (GebruikersArray[i].gebruiker <> '') then
    begin
      GebruikersFrm.Memo_Lijst.Lines.add(IntToStr(i) + #9 +
        GebruikersArray[i].gebruiker + #9 + GebruikersArray[i].wachtwoord);
    end;
  end;

  //Document bijwerken
  BestandBijwerken();

end;

procedure TGebruikersFrm.BestandBijwerken();
var
  bestand: TextFile; //Bestands pointer
  i: integer;
begin

  AssignFile(bestand, ExtractFilePath(Application.ExeName) + 'gebruikers');

  rewrite(bestand);

  i := 1;

  for i := low(GebruikersArray) to high(GebruikersArray) do
  begin
    WriteLn(bestand, GebruikersArray[i].gebruiker + #9 +
      GebruikersArray[i].wachtwoord + #9 + GebruikersArray[i].admin);

  end;

  //Bestand afsluiten, zeer belangrijk
  CloseFile(bestand);
end;

end.
