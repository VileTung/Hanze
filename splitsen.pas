unit splitsen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

function Splisten(regel: string; variabel: integer): string;

implementation

function Splisten(regel: string; variabel: integer): string;
var
  C: char;
  resultaat: string;
  positie: integer;
begin

  positie := 0;

  for C in regel do
  begin

    if (positie = variabel) and (C <> '-') then
    begin
      resultaat += C;
    end;

    if (C = '-') then
    begin
      positie += 1;
    end;
  end;

  Result := resultaat;

end;

end.

