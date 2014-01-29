unit uSerialReadSplits;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs;

procedure serialSplitsen(regel: string);
procedure serialArrayLegen();

implementation

uses uMain;

procedure serialSplitsen(regel: string);
var
  C: char;
  resultaat: string;
begin

  //Standaard waardes
  resultaat := '';

  for C in regel do
  begin

    if (C <> #13) and (C <> #10) then
    begin
      resultaat += C;
    end;

    if (C = #13) then
    begin
      //Waarde in array zetten
      uMain.SerialArray[uMain.SerialReadSplitsI] := resultaat;

      //Resultaat resetten
      resultaat := '';

      uMain.SerialReadSplitsI += 1;
    end;

  end;

end;

procedure serialArrayLegen();
var
  i: integer;
begin

  //Standaard waarde herstellen
  uMain.SerialReadSplitsI := 1;

  //Loop leegdraaien
  for i := low(uMain.SerialArray) to high(uMain.SerialArray) do
  begin
    uMain.SerialArray[i] := '';
  end;

end;

end.
