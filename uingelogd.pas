unit uIngelogd;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uDateTimeStamp;

procedure gebruikerIngelogd(Gebruiker: string);
procedure gebruikerUitgelogd();

implementation

uses uMain, uLoggen;

procedure gebruikerIngelogd(Gebruiker: string);
begin

  //Ingelogde gebruikersnaam
  uMain.Ingelogd := Gebruiker;
  MainFrm.StatusBar.Panels.Items[1].Text := 'Ingelogd: ' + Gebruiker;

  //Menu - Alleen als het een Systeembeheerder is
  if (uMain.SysteemBeheerder = True) then
  begin
    MainFrm.Menu_Gebruikers.Visible := True;
  end;

  //Menu - Restant
  MainFrm.Menu_Aanmelden.Visible := False;
  MainFrm.Menu_Afmelden.Visible := True;
  MainFrm.Menu_Sluiten.Visible := False;

  //Activeren/Resetten/Deactiveren
  MainFrm.Btn_Activeren.Enabled := True;

  //Als stille alarm getriggerd is,
  //moeten we dit na inloggen
  //wel kunnen resetten
  if (uMain.StilleAlarm = True) then
  begin
    MainFrm.Btn_Reset.Enabled := True;
  end;

end;

procedure gebruikerUitgelogd();
begin

  //Uitgelogd
  uMain.Ingelogd := '';
  MainFrm.StatusBar.Panels.Items[1].Text := 'Ingelogd: Nee';

  //Loggen
  uLoggen.GegevensLoggen('Gebruiker is uitgelogd');

  //Menu - Alleen als het een Systeembeheerder is
  if (uMain.SysteemBeheerder = True) then
  begin
    MainFrm.Menu_Gebruikers.Visible := False;
  end;

  //Menu - Restant
  MainFrm.Menu_Aanmelden.Visible := True;
  MainFrm.Menu_Afmelden.Visible := False;
  MainFrm.Menu_Sluiten.Visible := True;

  //Activeren/Resetten/Deactiveren
  MainFrm.Btn_Activeren.Enabled := False;
  MainFrm.Btn_Reset.Enabled := False;
  MainFrm.Btn_Deactiveren.Enabled := False;
end;

end.
