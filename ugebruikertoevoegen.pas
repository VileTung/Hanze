unit uGebruikerToevoegen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, uOpenenGebruikers, uOpslaanGebruikers;

type

  { TGebruikerToevoegenFrm }

  TGebruikerToevoegenFrm = class(TForm)
    Btn_GebruikerToevoegen: TButton;
    Edit_Gebruikersnaam: TEdit;
    Edit_Wachtwoord: TEdit;
    Lbl_Gebruikersnaam: TLabel;
    Lbl_Wachtwoord: TLabel;
    procedure Btn_GebruikerToevoegenClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  GebruikerToevoegenFrm: TGebruikerToevoegenFrm;

implementation

uses uLoggen;

{$R *.lfm}

{ TGebruikerToevoegenFrm }

procedure TGebruikerToevoegenFrm.Btn_GebruikerToevoegenClick(Sender: TObject);
begin

  //We gaan kijken of deze gebruiker al bestaat
  if (OpenenGebruiker(ExtractFilePath(Application.ExeName) + 'gebruikers',
    Edit_Gebruikersnaam.Text, '', True) = 'true') then
  begin
    ShowMessage('De gekozen gebruikersnaam is al in gebruik. Kies een andere kiest.');
  end
  else
  begin
    //Kijken of wachtwoord lang genoeg is
    if (length(Edit_Wachtwoord.Text) < 10) then
    begin
      ShowMessage('Het gekozen wachtwoord is te kort!');
    end
    //En hier gaan we de gebruiker toevoegen aan ons bestand
    else
    begin

      //Eerst kijken of we al 5 gebruikers hebben
      if (GebruikersTellen(ExtractFilePath(Application.ExeName) +
        'gebruikers') >= 5) then
      begin
        ShowMessage('Het is niet mogelijk om meer gebruikers toe te voegen aan het syteem!');
      end
      else
      begin
        //Gebruiker toevoegen aan bestand
        uOpslaanGebruikers.OpslaanGebruiker(ExtractFilePath(Application.ExeName) +
          'gebruikers',
          Edit_Gebruikersnaam.Text, Edit_Wachtwoord.Text);

        //Loggen
        uLoggen.GegevensLoggen('De gebruiker "' + Edit_Gebruikersnaam.Text +
          '" is toegevoegd!');

        //Melding weergeven
        ShowMessage('De gebruiker "' + Edit_Gebruikersnaam.Text + '" is toegevoegd!');
      end;

      //Velden weer leegmaken
      Edit_Gebruikersnaam.Text := '';
      Edit_Wachtwoord.Text := '';

      //Form sluiten
      GebruikerToevoegenFrm.Close();
    end;
  end;

end;

end.
