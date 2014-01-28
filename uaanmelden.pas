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
    Label1: TLabel;
    Lbl_Gebruikersnaam: TLabel;
    Lbl_Wachtwoord: TLabel;
    procedure Btn_AanmeldenClick(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  AanmeldenFrm: TAanmeldenFrm;

implementation

uses uMain;

{$R *.lfm}

{ TAanmeldenFrm }

procedure TAanmeldenFrm.Btn_AanmeldenClick(Sender: TObject);
begin
  //Met behulp van een document waar de inloggegevens instaan, gaan we proberen in te loggen!
  if (OpenenGebruiker(ExtractFilePath(Application.ExeName) + 'gebruikers',
    Edit_Gebruikersnaam.Text, Edit_Wachtwoord.Text, False) = 'true') then
  begin
    //Aangegeven dat ingelog gelukt is
    ShowMessage('Succesvol ingelogd, we gaan over enkele seconden verder.');

    //Loggen
    MainFrm.ListBox_Log.Items.Add(uDateTimeStamp.OnzeDateTimeStampLog +
      ' Gebruiker ' + Edit_Gebruikersnaam.Text + ' is ingelogd.');

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
  end;

end;

end.
