unit uDateTimeStamp;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs;

function OnzeDateTimeStamp(): string;
function OnzeDateTimeStampLog(): string;

implementation

function OnzeDateTimeStamp(): string;
var
  Nu: TDateTime;
begin

  Nu := Now;
  Result := FormatDateTime('hh;nn;DD;MM;YY', Nu);

end;

function OnzeDateTimeStampLog(): string;
var
  Nu: TDateTime;
begin

  Nu := Now;
  Result := FormatDateTime('[DD-MM-YY hh:nn:ss]', Nu);

end;

end.


