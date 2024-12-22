program demo03;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes
  { you can add units after this },sysutils, ugoengine;
var
  TestEngine : TGOEngine;


begin
  TestEngine:=TGOEngine.Create('Demo03',640,480);
  if TestEngine.Error then WriteLn(TestEngine.ErrorInfo)
   else
    while TestEngine.IsRun=true do begin
      TestEngine.DoEvents;
      TestEngine.GameLogic;
      TestEngine.Draw;
    end;
  FreeAndNil(TestEngine);
end.

