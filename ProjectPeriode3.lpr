program ProjectPeriode3;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, tachartlazaruspkg, main, sdposeriallaz, ArduinoConnect, NieuweSessie,
  OpenSessie, splitsen;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TmainFrm, mainFrm);
  Application.CreateForm(TsessieFrm, sessieFrm);
  Application.CreateForm(TOpenSessieFrm, OpenSessieFrm);
  Application.Run;
end.

