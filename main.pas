unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, Forms, Controls, Graphics,
  Dialogs, StdCtrls, Menus, ExtCtrls, SdpoSerial, ArduinoConnect,
  NieuweSessie, OpenSessie, splitsen;

type

  { TmainFrm }

  TmainFrm = class(TForm)
    Chart: TChart;
    Image_Logo: TImage;
    Lbl_Minimaal: TLabel;
    Lijn_Hartslag: TLineSeries;
    Lbl_Verbinding: TLabel;
    Lbl_Hartslag: TLabel;
    MainMenu: TMainMenu;
    ItemStopSessie: TMenuItem;
    ItemOpenSessie: TMenuItem;
    MenuItem_Menu: TMenuItem;
    ItemStartSessie: TMenuItem;
    SdpoSerial: TSdpoSerial;
    Tmr_Chart: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure ItemOpenSessieClick(Sender: TObject);
    procedure ItemStartSessieClick(Sender: TObject);
    procedure ItemStopSessieClick(Sender: TObject);
    procedure SdpoSerialRxData(Sender: TObject);
    procedure Tmr_ChartTimer(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  mainFrm: TmainFrm;
  bestandsNaam: string;
  hartslag: string;
  openSessiesArray: array[1..999999] of string;
  openSessiesArrayNummer: integer;

  //Tmr_Chart van Chart variabelen
  T_Start: integer;
  Xas: integer;

implementation

{$R *.lfm}

{ TmainFrm }

procedure TmainFrm.FormCreate(Sender: TObject);
var
  status: string;
begin
  status := verbinden(SdpoSerial);

  if (status = 'false') then
  begin
    Lbl_Verbinding.Caption := 'Status: Geen verbinding';
  end
  else
  begin
    Lbl_Verbinding.Caption := 'Status: Verbonden';
  end;

  hartslag := '0';
  bestandsNaam := '';
  openSessiesArrayNummer := 0;

end;

procedure TmainFrm.SdpoSerialRxData(Sender: TObject);
var
  bestand: TextFile;
begin

  hartslag := SdpoSerial.ReadData();

  if (hartslag = '') then
  begin
    hartslag := '0';
  end;

  Lbl_Hartslag.Caption := 'Hartslag: ' + hartslag+ ' bpm';

  if (bestandsNaam <> '') then
  begin

    //Opslaan van logging
    AssignFile(bestand, ExtractFilePath(Application.ExeName) + 'Sessies\' +
      BestandsNaam + '.hart');

    //Gebruiker toevoegen aan bestand (dus append)
    Append(bestand);

    WriteLn(bestand, hartslag);

    CloseFile(bestand);
  end;

end;

procedure TmainFrm.Tmr_ChartTimer(Sender: TObject);
begin

  Lijn_Hartslag.AddXY(Xas, StrToInt(hartslag));

  Chart.Extent.XMax := Chart.Extent.XMax + 1;
  Chart.Extent.XMin := Chart.Extent.XMin + 1;

  Xas += 1;

end;

procedure TmainFrm.ItemStartSessieClick(Sender: TObject);
begin
  sessieFrm.Show();
end;

procedure TmainFrm.ItemStopSessieClick(Sender: TObject);
begin
  Tmr_Chart.Enabled := False;
  ItemStartSessie.Visible := True;
  ItemStopSessie.Visible := False;
end;

procedure TmainFrm.ItemOpenSessieClick(Sender: TObject);
var
  SR: TSearchRec;
begin
  if FindFirst(ExtractFilePath(Application.ExeName) + 'Sessies\*.hart',
    faAnyFile, SR) = 0 then
  begin
    repeat
      if (SR.Attr <> faDirectory) then
      begin
        OpenSessieFrm.CBox_OpenSessies.Items.Add(splitsen.Splisten(SR.Name, 0) +
          ' ' + splitsen.Splisten(SR.Name, 1) + ':' +
          splitsen.Splisten(SR.Name, 2) + ' ' + splitsen.Splisten(SR.Name, 3) +
          '-' + splitsen.Splisten(SR.Name, 4) + '-2014');
        openSessiesArray[openSessiesArrayNummer] := SR.Name;

        openSessiesArrayNummer += 1;

      end;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;

  OpenSessieFrm.Show();

end;

end.
