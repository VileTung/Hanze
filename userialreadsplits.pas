unit uSerialReadSplits;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs;

procedure serialSplitsen(regel: string);

implementation

uses uMain;

procedure serialSplitsen(regel: string);
var
  C: char;
  resultaat: string;
  i: integer;
begin

  //Standaard waardes
  resultaat := '';
  i := 0;

  for C in regel do
  begin

    if (C <> #13) and (C <> #10) then
    begin
      resultaat += C;
    end;

    if (C = #13) then
    begin
      ShowMessage(resultaat);

      //Resultaat resetten
      resultaat := '';

      i += 1;
    end;

  end;

end;

end.
