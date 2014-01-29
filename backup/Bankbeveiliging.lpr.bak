program Bankbeveiliging;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, sdposeriallaz, uMain, uArduinoConnect, uAanmelden, uOpenenGebruikers,
  uIngelogd, uGebruikers, uGebruikerToevoegen, uOpslaanGebruikers,
uDateTimeStamp, uSerialReadSplits
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.CreateForm(TAanmeldenFrm, AanmeldenFrm);
  Application.CreateForm(TGebruikersFrm, GebruikersFrm);
  Application.CreateForm(TGebruikerToevoegenFrm, GebruikerToevoegenFrm);
  Application.Run;
end.

