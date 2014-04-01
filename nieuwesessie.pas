unit NieuweSessie;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TsessieFrm }

  TsessieFrm = class(TForm)
    Btn_Start: TButton;
    Btn_Annuleren: TButton;
    Edit_Voornaam: TEdit;
    Edit_Achternaam: TEdit;
    Lbl_Voornaam: TLabel;
    Lbl_Achternaam: TLabel;
    procedure Btn_AnnulerenClick(Sender: TObject);
    procedure Btn_StartClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  sessieFrm: TsessieFrm;

implementation

uses main;

{$R *.lfm}

{ TsessieFrm }

procedure TsessieFrm.Btn_StartClick(Sender: TObject);
var
  datum: TDateTime;
  bestand: TextFile;
begin

  //Variabel setten
  datum := Now;
  main.bestandsNaam := edit_voornaam.Text + ' ' + edit_achternaam.Text +
    '-' + FormatDateTime('hh-nn-DD-MM-YYYY', datum);
  main.T_Start := 0;
  main.Xas := 0;

  //Ongeldige invoer
  if (Edit_Voornaam.Text = '') or (Edit_Achternaam.Text = '') then
  begin
    //Melding weergeven
    ShowMessage('Ongeldige invoer!');
  end
  else
  begin
    //Form sluiten
    Close();

    AssignFile(bestand, ExtractFilePath(Application.ExeName) + 'Sessies\' +
      main.BestandsNaam + '.hart');

    //Als het bestand niet bestaat, maken we die aan :)
    if FileExists(ExtractFilePath(Application.ExeName) + 'Sessies\' +
      main.BestandsNaam + '.hart') then
    begin
      Append(bestand);
    end
    else
    begin
      Rewrite(bestand);
    end;

    //Document afsluiten
    Closefile(bestand);

    //Zichtbaar maken van onderdelen
    MainFrm.Chart.Visible := True;
    MainFrm.Lbl_Hartslag.Visible := True;

    //Ontzichtbaar maken knop 'start'
    MainFrm.ItemStartSessie.Visible := False;
    MainFrm.ItemStopSessie.Visible := True;

    //Timer van Chart starten
    MainFrm.Tmr_Chart.Enabled := True;

    mainFrm.Lijn_Hartslag.Clear();

    mainFrm.Chart.Extent.XMax := 30;
    mainFrm.Chart.Extent.XMin := -30;

    mainFrm.Lbl_Minimaal.Visible := False;
    mainFrm.Lbl_Minimaal.Caption := 'Minimaal: ?';
    mainFrm.Lbl_Hartslag.Caption := 'Hartslag: ?';

  end;
end;

procedure TsessieFrm.Btn_AnnulerenClick(Sender: TObject);
begin
  Close();
end;

end.

