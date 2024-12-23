program demo07;

{$mode objfpc}{$H+}{$M+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes
  { you can add units after this }, sysutils, ugoengine;

type

  { TPlayer }

  TPlayer = class(TGOBaseObject)
  private
    FFrame: integer;
    FDirectionX,
    FDirectionY: ShortInt; //-1 рухаємось вліво, +1 рухаємось вправо
  public
    constructor Create(const ObjLoader : TGOObjLoader);
    procedure Clear; override;

  published
    property Frame : integer read FFrame default 0;
    procedure Update; override;
  end;


{ TPlayer }

constructor TPlayer.Create(const ObjLoader: TGOObjLoader);
begin
  FDirectionX:=5;
  FDirectiony:=5;
  inherited Create(ObjLoader);
end;

procedure TPlayer.Clear;
begin
  FId:='';
end;

procedure TPlayer.Update;
begin
  //тут буде прораховуватись ігрова логіка
  //спочатку змінюємо за потреби напрямок руху
 if (FX>(GoEngine.Width-FW)) or (FDirectionX=0) then FDirectionX:=-5
    else if FX <=0 then FDirectionX:=5;
 if (FY>=(GoEngine.Height-FH))  or (FDirectionY=0) then FDirectionY:=-5
    else if FY <=0 then FDirectionY:=5;
 //а тепер координати
 FX:=FX+FDirectionX;
 FY:=FY+FDirectionY;
 //визначаємо віддзеркалення в залежності від напрямку руху
 if (FDirectionx>0) then
    if (FDirectionY>0) then FFlip:=GO_FLIP_NONE
    else FFlip:=GO_FLIP_V
 else if (FDirectionY>0) then FFlip:=GO_FLIP_D
    else FFlip:=GO_FLIP_H;
 //змінюємо поточний кадр анімації
 if FCol >=7 then begin
  FCol :=0;
  Inc(FRow);
  if FRow>=9 then FRow:=0
     else Inc(FRow);
 end else Inc(FCol);
end;


var
  i: Integer;
  aLoader : TGOObjLoader;
begin
  Randomize;
  if GoEngine<>nil then begin
    GoEngine.Caption:='демо 07';
    GoEngine.TextureManager.Load('assets'+DirectorySeparator+'tux.png','Tux');
    GoEngine.TextureManager.Load('assets'+DirectorySeparator+'tuxfire.png','Tux Fire');
    aLoader:=TGOObjLoader.Create(0,0,32,32,'Tux');
    for i :=0 to 10000 do begin
      aLoader.X := Random(GoEngine.Width);
      aLoader.Y := Random(GoEngine.Height);
      aLoader.Id := 'Tux';
      GoEngine.GameObjects.Add(TPlayer.Create(aLoader));
      aLoader.X := Random(GoEngine.Width);
      aLoader.Y := Random(GoEngine.Height);
      aLoader.Id := 'Tux Fire';
      GoEngine.GameObjects.Add(TPlayer.Create(aLoader));
    end;
    GoEngine.Run;
    FreeAndNil(aLoader);
  end;
end.
