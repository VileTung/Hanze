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

{$R *.lfm}

{ TGebruikerToevoegenFrm }

procedure TGebruikerToevoegenFrm.Btn_GebruikerToevoegenClick(Sender: TObject);
begin

  //We gaan kijken of deze gebruiker al bestaat
  if (OpenenGebruiker('C:\Users\Kevin\Desktop\testje', Edit_Gebruikersnaam.Text,
    '', True) = 'true') then
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

      uOpslaanGebruikers.OpslaanGebruiker('C:\Users\Kevin\Desktop\testje',
        Edit_Gebruikersnaam.Text, Edit_Wachtwoord.Text);

      ShowMessage('De gebruiker "' + Edit_Gebruikersnaam.Text + '" is toegevoegd!');
    end;
  end;

end;

end.
