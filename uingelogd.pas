unit uIngelogd;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

procedure gebruikerIngelogd(Gebruiker: string);
procedure gebruikerUitgelogd();

implementation

uses uMain;

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

end;

procedure gebruikerUitgelogd();
begin

  //Uitgelogd
  uMain.Ingelogd := '';
  MainFrm.StatusBar.Panels.Items[1].Text := 'Ingelogd: Nee';

  //Menu - Alleen als het een Systeembeheerder is
  if (uMain.SysteemBeheerder = True) then
  begin
    MainFrm.Menu_Gebruikers.Visible := False;
  end;

  //Menu - Restant
  MainFrm.Menu_Aanmelden.Visible := True;
  MainFrm.Menu_Afmelden.Visible := False;
end;

end.
