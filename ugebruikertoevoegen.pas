unit uGebruikerToevoegen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, uOpenenGebruikers;

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

  end;

end;

end.

