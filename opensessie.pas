unit OpenSessie;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TOpenSessieFrm }

  TOpenSessieFrm = class(TForm)
    Btn_Start: TButton;
    CBox_OpenSessies: TComboBox;
    procedure Btn_StartClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  OpenSessieFrm: TOpenSessieFrm;

implementation

uses main;

{$R *.lfm}

{ TOpenSessieFrm }

procedure TOpenSessieFrm.Btn_StartClick(Sender: TObject);
var
  bestand: TextFile; //Bestands pointer
  Data: string;
  Xas: integer;
  Max: integer;
  Min: integer;
begin

  try

    mainFrm.Lijn_Hartslag.Clear();

    Xas := 0;

    //Beginnen bij 0
    mainFrm.Chart.Extent.XMax := 1;
    mainFrm.Chart.Extent.XMin := 0;

    //Min/max
    Min := 220;
    Max := 0;

    AssignFile(bestand, ExtractFilePath(Application.ExeName) + 'Sessies\' +
      main.openSessiesArray[CBox_OpenSessies.ItemIndex]);

    reset(bestand);

    while not EOF(bestand) do
    begin
      ReadLn(bestand, Data);

      mainFrm.Lijn_Hartslag.AddXY(Xas, StrToInt(Data));

      Xas += 1;

      mainFrm.Chart.Extent.XMax := mainFrm.Chart.Extent.XMax + 1;

      if (StrToInt(Data) > Max) then
      begin
        Max := StrToInt(Data);
      end;

      if (StrToInt(Data) < Min) and (StrToInt(Data) > 10) then
      begin
        Min := StrToInt(Data);
      end;

      mainFrm.Lbl_Minimaal.Visible := True;
      mainFrm.Lbl_Minimaal.Caption := 'Minimaal: ' + IntToStr(Min);
      mainFrm.Lbl_Hartslag.Caption := 'Maximaal: ' + IntToStr(Max);

    end;

    //Bestand afsluiten, zeer belangrijk
    CloseFile(bestand);

    Close();

  except

    mainFrm.Lbl_Minimaal.Visible := True;
    mainFrm.Lbl_Minimaal.Caption := 'Minimaal: ?';
    mainFrm.Lbl_Hartslag.Caption := 'Maximaal: ?';

    ShowMessage('Geen geldig document!');

  end;

end;

end.
