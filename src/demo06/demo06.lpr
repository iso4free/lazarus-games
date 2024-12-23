program demo06;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes
  { you can add units after this }, ugoengine;

begin
  if GoEngine<>nil then begin
    GoEngine.Caption:='демо 06';
    GoEngine.Width:=640;
    GoEngine.Height:=480;
    GoEngine.TextureManager.Load('assets'+DirectorySeparator+'tux.png','Tux');
    GoEngine.TextureManager.Load('assets'+DirectorySeparator+'tuxfire.png','Tux Fire');

    GoEngine.Run;
  end;
end.


