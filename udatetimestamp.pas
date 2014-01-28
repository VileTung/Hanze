unit uDateTimeStamp;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs;

function OnzeDateTimeStamp(): string;

implementation

function OnzeDateTimeStamp(): string;
var
  Nu: TDateTime;
begin

  Nu := Now;
  Result := FormatDateTime('nn;hh;DD;MM;YY', Nu);

end;

end.


