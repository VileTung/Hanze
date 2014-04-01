unit ArduinoConnect;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SdpoSerial,dialogs;

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
  for i := 4 to 10 do
  begin
    try
      Serial.Device := 'COM' + IntToStr(i);
      Serial.Active := True;

      //Onze COM poort
      resultaat := IntToStr(i);

      break;
    except
      //We hoeven niets te laten zien ;)
    end;
  end;

  Result := resultaat;

end;

end.

