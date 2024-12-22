program demo08;

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

  { TCounter }

  TCounter = class(TGOBaseObject)
  private
    FCount: Integer;
    procedure SetCount(AValue: Integer);
  published
    constructor Create(const ObjLoader: TGOObjLoader);
    property Count : Integer read FCount write SetCount default 0;
    procedure Update; override;
    procedure Draw; override;
  end;

{ TCounter }

procedure TCounter.SetCount(AValue: Integer);
begin
  if FCount=AValue then Exit;
  FCount:=AValue;
end;

constructor TCounter.Create(const ObjLoader: TGOObjLoader);
begin
  inherited Create(ObjLoader);
  FCount:=0;
end;

procedure TCounter.Update;
begin

end;

procedure TCounter.Draw;
var
  i: Integer;
  s: String;
begin
 fx:=20;
 s:=IntToStr(FCount);
 for i:=0 to Length(s)-1 do begin
   WriteLn('Try draw: ',s.Chars[i]);
  GoEngine.TextureManager.Draw(s.Chars[i], Fx, Fy, Fw, Fh, GO_FLIP_NONE);
  fx:=fx+30;
 end;
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
  aCounter : TCounter;
begin
  Randomize;
  if GoEngine<>nil then begin
    GoEngine.Caption:='демо 08';
    GoEngine.TextureManager.Add(TSDLTextureWrapper.Create('assets'+DirectorySeparator+'tux.png'),'Tux');
    GoEngine.TextureManager.Add(TSDLTextureWrapper.Create('assets'+DirectorySeparator+'tuxfire.png'),'Tux Fire');
    //створюємо текстури цифр
    for i:=0 to 9 do begin
      GoEngine.TextureManager.Add(TSDLTextureWrapper.Create(IntToStr(i)),IntToStr(i));
      if GoEngine.Error then begin
       WriteLn('Error: ', GoEngine.ErrorInfo);
       Halt(-1);
      end;
    end;

    aLoader:=TGOObjLoader.Create(20,20,32,32,'Counter');
    aCounter:=TCounter.Create(aLoader);
    for i :=1 to 10000 do begin
      aLoader.X := Random(GoEngine.Width);
      aLoader.Y := Random(GoEngine.Height);
      aLoader.Id := 'Tux';
      GoEngine.GameObjects.Add(TPlayer.Create(aLoader));
      aLoader.X := Random(GoEngine.Width);
      aLoader.Y := Random(GoEngine.Height);
      aLoader.Id := 'Tux Fire';
      GoEngine.GameObjects.Add(TPlayer.Create(aLoader));
    end;
    GoEngine.GameObjects.Add(aCounter);
    aCounter.Count:=GoEngine.GameObjects.Count;
    GoEngine.Run;
    FreeAndNil(aLoader);
  end;
end.

