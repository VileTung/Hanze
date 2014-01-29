unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Menus, ComCtrls, SdpoSerial, uArduinoConnect, uAanmelden,
  uIngelogd, uGebruikerToevoegen, uGebruikers, uDateTimeStamp,
  uSerialReadSplits, uLoggen;

type

  { TMainFrm }

  TMainFrm = class(TForm)
    Btn_Activeren: TButton;
    Btn_Deactiveren: TButton;
    Btn_Reset: TButton;
    HoofdMenu: TMainMenu;
    ListBox_Log: TListBox;
    Menu_Afmelden: TMenuItem;
    Menu_Menu: TMenuItem;
    Menu_Gebruikers: TMenuItem;
    Menu_Toevoegen: TMenuItem;
    Menu_Wijzigen: TMenuItem;
    Menu_Sluiten: TMenuItem;
    Menu_Aanmelden: TMenuItem;
    SdpoSerial: TSdpoSerial;
    StatusBar: TStatusBar;
    Timer_HeartBeat: TTimer;
    Timer_SleutelSchakelaar: TTimer;
    procedure Btn_ActiverenClick(Sender: TObject);
    procedure Btn_DeactiverenClick(Sender: TObject);
    procedure Btn_ResetClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Menu_AanmeldenClick(Sender: TObject);
    procedure Menu_AfmeldenClick(Sender: TObject);
    procedure Menu_SluitenClick(Sender: TObject);
    procedure Menu_ToevoegenClick(Sender: TObject);
    procedure Menu_WijzigenClick(Sender: TObject);
    procedure SdpoSerialRxData(Sender: TObject);
    procedure Timer_HeartBeatTimer(Sender: TObject);
    procedure Timer_SleutelSchakelaarTimer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  MainFrm: TMainFrm;
  ComPoort: string;
  Status: boolean;
  Ingelogd: string;
  Sleutel: boolean;
  SysteemBeheerder: boolean;
  StilleAlarm: boolean;
  SerialReadSplitsI: integer;
  SerialArray: array[1..10] of string;

implementation

{$R *.lfm}

{ TMainFrm }

procedure TMainFrm.FormCreate(Sender: TObject);
begin
  //Standaard
  SerialReadSplitsI := 1;

  //Standaard is er niemand ingelogd
  Ingelogd := '';
  SysteemBeheerder := False;
  StilleAlarm := False;

  //Als het goed gaat krijgen we de COM-poort terug
  ComPoort := verbinden(SdpoSerial);

  //Kijken of we verbinding hebben
  if (ComPoort = 'false') then
  begin
    Status := False;

    //Kijken of we toch verbinding kunnen krijgen
    Timer_HeartBeatTimer(Sender);
  end
  else
  begin
    Status := True;
  end;

end;

procedure TMainFrm.Btn_ActiverenClick(Sender: TObject);
begin
  //Het systeem actieveren
  //Stuur: Sl;minuut;uur;dag;ja(ar)

  SdpoSerial.WriteData('SA;' + uDateTimeStamp.OnzeDateTimeStamp() + #13#10);
end;

procedure TMainFrm.Btn_DeactiverenClick(Sender: TObject);
begin
  //Het systeem de-activeren
  SdpoSerial.WriteData('SD;' + uDateTimeStamp.OnzeDateTimeStamp() + #13#10);
end;

procedure TMainFrm.Btn_ResetClick(Sender: TObject);
begin
  //Het systeem resetten, de alarmen
  SdpoSerial.WriteData('RS;' + uDateTimeStamp.OnzeDateTimeStamp() + #13#10);
end;

procedure TMainFrm.SdpoSerialRxData(Sender: TObject);
var
  i, teller: integer;
  serial, waarde, gesplitst: string;
begin

  serial := '';
  waarde := '';

  //Zodra we hier aankomen even wachten, om alles te bufferen.
  for i := 1 to 20000 do
  begin
    serial := SdpoSerial.ReadData;

    if serial <> '' then
    begin
      waarde := waarde + serial;
    end;
  end;

  //Waarde sturen om te splitsen :)
  uSerialReadSplits.serialSplitsen(waarde);

  for teller := low(SerialArray) to high(SerialArray) do
  begin

    gesplitst := SerialArray[teller];

    if (gesplitst <> '') then
    begin

      case (gesplitst[1] + gesplitst[2]) of
        'VB': //Verbonden
        begin
          Status := True;

          //Loggen
          uLoggen.GegevensLoggen('Verbonden');

          //Status weergeven
          StatusBar.Panels.Items[0].Text := 'We zijn verbonden';
        end;
        'HB': //Actief
        begin
          Status := True;

          //Loggen
          uLoggen.GegevensLoggen('Heartbeat');

          //Status weergeven
          StatusBar.Panels.Items[0].Text := 'We zijn nog steeds verbonden';
        end;
        'SL': //Sleutelschakelaar
        begin
          //Eerst kijken of we niet al ingelogd zijn
          if (Ingelogd = '') then
          begin
            //Het response geven
            //sleep(1000);
            SdpoSerial.WriteData('SL;' + uDateTimeStamp.OnzeDateTimeStamp() + #13#10);

            //Timer starten, gebruiker heeft 60 seconden
            Timer_SleutelSchakelaar.Enabled := True;

            //Loggen
            uLoggen.GegevensLoggen('Sleutelschakelaar');

            //Knop actief maken
            AanmeldenFrm.Btn_Aanmelden.Enabled := True;

            //Status weergeven
            StatusBar.Panels.Items[0].Text := 'Sleutelschakelaar';
          end;
        end;
        'SA': //Systeem actief
        begin
          //Loggen
          uLoggen.GegevensLoggen('Systeem geactiveerd');

          //Status weergeven
          StatusBar.Panels.Items[0].Text := 'Systeem geactiveerd';
          Btn_Activeren.Enabled := False;
          Btn_Deactiveren.Enabled := True;
        end;
        'AM': //Systeem actiever mislukt
        begin
          //Loggen
          uLoggen.GegevensLoggen('Activeren mislukt!');

          //Status weergeven
          StatusBar.Panels.Items[0].Text := 'Activeren mislukt';
        end;
        'SD': //Systeem de-actieveren
        begin
          //Loggen
          uLoggen.GegevensLoggen('Systeem gedeactiveerd');

          //Status weergeven
          StatusBar.Panels.Items[0].Text := 'Systeem gedeactiveerd';
          Btn_Activeren.Enabled := True;
          Btn_Deactiveren.Enabled := False;
        end;
        'AL': //Alarm
        begin
          //Loggen
          case (gesplitst[4] + gesplitst[5]) of
            'Re':
            begin
              //Reset
              Btn_Reset.Enabled := False;
              Btn_Deactiveren.Enabled := True;

              //Loggen
              uLoggen.GegevensLoggen('Reset');
              ListBox_Log.Items.Add(uDateTimeStamp.OnzeDateTimeStampLog +
                ' Reset');
            end;
            'La':
            begin
              //Break beam / Laserpointer
              Btn_Reset.Enabled := True;
              Btn_Deactiveren.Enabled := False;

              //Loggen
              uLoggen.GegevensLoggen('Laser');
            end;
            'Pi':
            begin
              //Pir
              Btn_Reset.Enabled := True;
              Btn_Deactiveren.Enabled := False;

              //Loggen
              uLoggen.GegevensLoggen('PIR');

            end;
            'Gl':
            begin
              //Glasbreuk
              Btn_Reset.Enabled := True;
              Btn_Deactiveren.Enabled := False;

              //Loggen
              uLoggen.GegevensLoggen('Glasbreuk');
            end;
            'Ra':
            begin
              //Openraam
              Btn_Reset.Enabled := True;
              Btn_Deactiveren.Enabled := False;

              //Loggen
              uLoggen.GegevensLoggen('Openraam');
            end;
          end;
        end;
        else
        //Er is iets verkeerd gegaan?
      end;

    end;

  end;

  //Array leeg maken
  serialArrayLegen();

end;

procedure TMainFrm.Timer_HeartBeatTimer(Sender: TObject);
begin

  if (Status = True) then
  begin
    status := False;

    //Bericht sturen naar COM poort
    SdpoSerial.WriteData('HB;' + uDateTimeStamp.OnzeDateTimeStamp() + #13#10);
  end
  else
  begin
    //Seriale verbingen stoppen
    SdpoSerial.Active := False;

    //Status weergeven
    uLoggen.GegevensLoggen('Verbinding verbroken!');
    StatusBar.Panels.Items[0].Text := 'Verbinding verbroken!';

    //Opnieuw verbinding maken
    verbinden(SdpoSerial);
  end;

end;

procedure TMainFrm.Timer_SleutelSchakelaarTimer(Sender: TObject);
begin

  //var voor resetten
  StilleAlarm := True;

  //Het (stille) alarm word geactiveerd
  SdpoSerial.WriteData('ST;' + uDateTimeStamp.OnzeDateTimeStamp() + #13#10);

  //Timer uitschakelen
  Timer_Sleutelschakelaar.Enabled := False;

  //Knop actief maken
  AanmeldenFrm.Btn_Aanmelden.Enabled := False;

end;

procedure TMainFrm.Menu_AanmeldenClick(Sender: TObject);
begin
  //Aanmeld scherm laten zien
  AanmeldenFrm.Show();
end;

procedure TMainFrm.Menu_AfmeldenClick(Sender: TObject);
begin
  //Gebruiker uitloggen/opties verbergen!
  uIngelogd.gebruikerUitgelogd();
end;

procedure TMainFrm.Menu_SluitenClick(Sender: TObject);
begin
  //Seriële verbinding uitzetten.
  SdpoSerial.active := False;

  //Applicatie sluiten
  MainFrm.Close();
end;

procedure TMainFrm.Menu_ToevoegenClick(Sender: TObject);
begin
  //Gebruiker toevoegen scherm laten zien
  GebruikerToevoegenFrm.Show();
end;

procedure TMainFrm.Menu_WijzigenClick(Sender: TObject);
begin

  //Gebruiker wijzigen/verwijderen scherm laten zien
  GebruikersFrm.Show();
end;

end.
