program demo05;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes
  { you can add units after this }, ugoengine;

begin
  if GoEngine<>nil then begin
    GoEngine.Caption:='демо 05';
    GoEngine.Width:=640;
    GoEngine.Height:=480;
    GoEngine.Run;
  end;
end.

