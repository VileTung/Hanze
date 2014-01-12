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
    MenuItem1: TMenuItem;
    MenuWijzigen: TMenuItem;
    MenuVerwijderen: TMenuItem;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  GebruikersFrm: TGebruikersFrm;

implementation

{$R *.lfm}

end.

