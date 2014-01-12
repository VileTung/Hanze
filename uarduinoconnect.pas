unit uArduinoConnect;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SdpoSerial, ExtCtrls, Dialogs;

function verbinden(Serial: TSdpoSerial): string;

implementation

function verbinden(Serial: TSdpoSerial): string;
var
  i: integer;
  resultaat: string;
begin

  //Als we geen verbinding krijgen,
  //willen we dat ook weten!
  resultaat := 'false';

  //We gaan door 10 COM poorten loopen
  //om te kijken of de onze er tussen zit :)
  for i := 1 to 10 do
  begin
    try
      Serial.Device := 'COM' + IntToStr(i);
      Serial.Active := True;

      //Onze COM poort
      resultaat := IntToStr(i);

      //Even wachten
      Sleep(1000); //1 sec

      //Bericht sturen naar COM poort
      Serial.WriteData('1');

      break;
    except
      //We hoeven niets te laten zien ;)
    end;
  end;

  Result := resultaat;

end;

end.
