unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Menus, ComCtrls, SdpoSerial, uArduinoConnect, uAanmelden,
  uIngelogd, uGebruikerToevoegen, uGebruikers;

type

  { TMainFrm }

  TMainFrm = class(TForm)
    Btn_Activeren: TButton;
    Btn_Deactiveren: TButton;
    HoofdMenu: TMainMenu;
    Memo_Log: TMemo;
    Menu_Afmelden: TMenuItem;
    Menu_Menu: TMenuItem;
    Menu_Gebruikers: TMenuItem;
    Menu_Toevoegen: TMenuItem;
    Menu_Wijzigen: TMenuItem;
    Menu_Sluiten: TMenuItem;
    Menu_Aanmelden: TMenuItem;
    SdpoSerial: TSdpoSerial;
    StatusBar: TStatusBar;
    Timer_HeartBeat: TTimer;
    Timer_SleutelSchakelaar: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Menu_AanmeldenClick(Sender: TObject);
    procedure Menu_AfmeldenClick(Sender: TObject);
    procedure Menu_SluitenClick(Sender: TObject);
    procedure Menu_ToevoegenClick(Sender: TObject);
    procedure Menu_WijzigenClick(Sender: TObject);
    procedure SdpoSerialRxData(Sender: TObject);
    procedure Timer_HeartBeatTimer(Sender: TObject);
    procedure Timer_SleutelSchakelaarTimer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  MainFrm: TMainFrm;
  ComPoort: string;
  Status: boolean;
  Ingelogd: string;
  Sleutel: boolean;
  SysteemBeheerder: boolean;

implementation

{$R *.lfm}

{ TMainFrm }

procedure TMainFrm.FormCreate(Sender: TObject);
begin

  //Standaard is er niemand ingelogd
  Ingelogd := '';
  SysteemBeheerder := False;

  //Als het goed gaat krijgen we de COM-poort terug
  ComPoort := verbinden(SdpoSerial);

  //Kijken of we verbinding hebben
  if (ComPoort = 'false') then
  begin
    Status := False;

    //Kijken of we toch verbinding kunnen krijgen
    Timer_HeartBeatTimer(Sender);
  end
  else
  begin
    Status := True;
  end;

end;

procedure TMainFrm.SdpoSerialRxData(Sender: TObject);
var
  i: integer;
  s, s1: string;
begin

  s := '';
  for i := 1 to 20000 do
  begin
    s := SdpoSerial.ReadData;
    if s <> '' then
    begin
      s1 := s1 + s;
    end;

  end; //for
  Memo_Log.Lines.Add(s1);

  case s1 of
    'Verbonden'#13#10:
    begin
      Status := True;

      //Status weergeven
      StatusBar.Panels.Items[0].Text := 'We zijn verbonden';
    end;
    'Actief'#13#10:
    begin
      Status := True;

      //Status weergeven
      StatusBar.Panels.Items[0].Text := 'We zijn nog steeds verbonden';
    end;
    'Sleutel'#13#10:
    begin
      //Timer starten, gebruiker heeft 60 seconden
      Timer_SleutelSchakelaar.Enabled := True;

      //Variabel voor aanmeld form
      Sleutel := True;

      //Knop actief maken
      AanmeldenFrm.Btn_Aanmelden.Enabled := True;

      //Status weergeven
      StatusBar.Panels.Items[0].Text := 'Sleutelschakelaar';
    end;
    else
    //Er is iets verkeerd gegaan?
  end;

end;

procedure TMainFrm.Timer_HeartBeatTimer(Sender: TObject);
begin

  if (Status = True) then
  begin
    status := False;

    //Bericht sturen naar COM poort
    SdpoSerial.WriteData('2');
  end
  else
  begin
    //Seriale verbingen stoppen
    SdpoSerial.Active := False;

    //Status weergeven
    StatusBar.Panels.Items[0].Text := 'GEEN VERBINDING!!';

    //Opnieuw verbinding maken
    verbinden(SdpoSerial);
  end;

end;

procedure TMainFrm.Timer_SleutelSchakelaarTimer(Sender: TObject);
begin

  ShowMessage('60 secjes voorbij, stille alarm, of gewone alarm gaat nu :)');

  timer_Sleutelschakelaar.Enabled := False;

end;

procedure TMainFrm.Menu_AanmeldenClick(Sender: TObject);
begin
  //Aanmeld scherm laten zien
  AanmeldenFrm.Show();
end;

procedure TMainFrm.Menu_AfmeldenClick(Sender: TObject);
begin
  //Gebruiker uitloggen/opties verbergen!
  uIngelogd.gebruikerUitgelogd();
end;

procedure TMainFrm.Menu_SluitenClick(Sender: TObject);
begin

  SdpoSerial.WriteData('3');

  //Seriële verbinding uitzetten.
  //SdpoSerial.active := False;

  //Applicatie sluiten
  //MainFrm.Close();
end;

procedure TMainFrm.Menu_ToevoegenClick(Sender: TObject);
begin
  //Gebruiker toevoegen scherm laten zien
  GebruikerToevoegenFrm.Show();
end;

procedure TMainFrm.Menu_WijzigenClick(Sender: TObject);
begin

  //Gebruiker wijzigen/verwijderen scherm laten zien
  GebruikersFrm.Show();
end;

end.
