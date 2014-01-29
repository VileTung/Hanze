unit uLoggen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms;

procedure GegevensLoggen(tekst: string);

implementation

uses uMain, uDateTimeStamp;

procedure GegevensLoggen(tekst: string);
var
  bestand: TextFile;
begin

  AssignFile(bestand, ExtractFilePath(Application.ExeName) + 'loggen.txt');

  //Als het bestand niet bestaat, maken we die aan :)
  if FileExists(ExtractFilePath(Application.ExeName) + 'loggen.txt') then
  begin
    Append(bestand);
  end
  else
  begin
    Rewrite(bestand);
  end;

  //Lijn naar document sturen
  WriteLn(bestand, uDateTimeStamp.OnzeDateTimeStampLog + ' ' + tekst);

  //Document afsluiten
  Closefile(bestand);

  //Ook weergeven in Memo!
  MainFrm.ListBox_Log.Items.Add(uDateTimeStamp.OnzeDateTimeStampLog + ' ' + tekst);
end;

end.

