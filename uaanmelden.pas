unit uAanmelden;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, uOpenenGebruikers, uIngelogd, uDateTimeStamp;

type

  { TAanmeldenFrm }

  TAanmeldenFrm = class(TForm)
    Btn_Aanmelden: TButton;
    Edit_Gebruikersnaam: TEdit;
    Edit_Wachtwoord: TEdit;
    Lbl_Gebruikersnaam: TLabel;
    Lbl_Wachtwoord: TLabel;
    procedure Btn_AanmeldenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  AanmeldenFrm: TAanmeldenFrm;
  stilAlarm: integer;

implementation

uses uMain, uLoggen;

{$R *.lfm}

{ TAanmeldenFrm }

procedure TAanmeldenFrm.Btn_AanmeldenClick(Sender: TObject);
begin
  //Met behulp van een document waar de inloggegevens instaan, gaan we proberen in te loggen!
  if (OpenenGebruiker(ExtractFilePath(Application.ExeName) + 'gebruikers',
    Edit_Gebruikersnaam.Text, Edit_Wachtwoord.Text, False) = 'true') and
    (Edit_Gebruikersnaam.Text <> '') and (Edit_Wachtwoord.Text <> '') then
  begin
    //Aangegeven dat ingelog gelukt is
    ShowMessage('Succesvol ingelogd, we gaan over enkele seconden verder.');

    //Loggen
    uLoggen.GegevensLoggen('Gebruiker ' + Edit_Gebruikersnaam.Text + ' is ingelogd');

    //Opties voor ingelogde gebruikers weergeven
    uIngelogd.gebruikerIngelogd(Edit_Gebruikersnaam.Text);

    //Sleutelschakelaar Timer uitzetten
    //anders gaat het alarm alsnog af ;P
    MainFrm.Timer_SleutelSchakelaar.Enabled := False;

    //Variabel Sleutel ook op False zetten
    uMain.Sleutel := False;

    //Knop weer uitschakelen
    Btn_Aanmelden.Enabled := False;

    //Velden leegmaken
    Edit_Gebruikersnaam.Text := '';
    Edit_Wachtwoord.Text := '';

    //Form sluiten
    AanmeldenFrm.Close();

  end
  else
  begin
    //Verkeerde ongeldige gegevens!
    ShowMessage('Ongeldige inloggegevens ingevoerd. Controleer je ingevoerde gegevens en probeer het opnieuw!');

    //Moeten we stil alarm triggeren?
    if (stilAlarm >= 1) then
    begin
      //Reset knop actief maken als gebruiker goed inlogd
      uMain.StilleAlarm := True;

      //Het (stille) alarm word geactiveerd
      MainFrm.SdpoSerial.WriteData('ST;' + uDateTimeStamp.OnzeDateTimeStamp() + #13#10);

      //Reset teller
      stilAlarm := 0;
    end
    else
    begin
      //Teller +1
      stilAlarm += 1;
    end;
  end;

end;

procedure TAanmeldenFrm.FormCreate(Sender: TObject);
begin
  //Stil alarm
  stilAlarm := 0;

end;

end.
