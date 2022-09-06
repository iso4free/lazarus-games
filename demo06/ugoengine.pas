unit ugoengine;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fgl, sdl2, sdl2_image;

type

  TGoTextureMap = specialize TFPGMap<String, PSDL_Texture>;

  { TGoTextureManager }

  TGoTextureManager = class
   private
    FTextureMap : TGoTextureMap;
    constructor Create;
   public
    function Load(aFileName : String; aID : String) : Boolean;
    procedure Draw(aID : String; x,y,w,h : Integer; Flip : Integer = SDL_FLIP_NONE);
    procedure DrawFrame(aID : String; x,y,w,h : Integer; CurrentRow, CurrentFrame : Integer; Flip : Integer = SDL_FLIP_NONE);
    destructor Destroy; override;
  end;



  { TGOEngine }

  TGOEngine = class
  private
    FCaption: String;
    FHeight: Integer;
    FTexturemanager: TGoTextureManager;
    FWidth: Integer;
    FWindow : PSDL_Window;
    FRenderer : PSDL_Renderer;
    FEvent : PSDL_Event;
    FError: Boolean;
    FErrorInfo: String;
    FIsRun: Boolean;
    Ffullscreen: Boolean;
    Factive: Boolean;
    FWindowFlags : Integer; //прапорці для вікна
    FRendererFlags: Integer; //прапорці для візуалізатора
    Fhardwareacceleration: Boolean;
    FFileName : TFileName; // ім'я файлу налаштувань
    FSection : String; //назва секції налаштувань фреймворка

    fr,fc : Integer;

    constructor Create(Afile: Tfilename = 'goengine.ini'; Asection: String = 'ENGINE');
    procedure SetCaption(AValue: String);
    procedure SetHeight(AValue: Integer);
    procedure SetWidth(AValue: Integer);
    procedure Setfullscreen(Avalue: Boolean);
    procedure Sethardwareacceleration(Avalue: Boolean);
    procedure LoadSettings;
    function SaveSettings : Boolean;

  public
    destructor Destroy; override;

    procedure DoEvents;
    procedure GameLogic;
    procedure Draw;
    procedure Run;
  published

   property Error : Boolean read FError;//ознака збою в роботі класа
   property ErrorInfo : String read FErrorInfo; //текстовий опис помилки
   property Caption : String read FCaption write SetCaption;//заголовок вікна
   property Width : Integer read FWidth write SetWidth default 640; //ширина вікна
   property Height : Integer read FHeight write SetHeight default 480; //висота вікна
   property FullScreen : Boolean read FFullScreen write SetFullScreen default False; //повноекранний режим
   property Active : Boolean read FActive default True;//чи вікно має фокус
   property HardwareAcceleration : Boolean read FHardwareAcceleration write SetHardwareAcceleration default True; //апаратне прикорення

   //Texture manager
   property Texturemanager : TGoTextureManager read FTexturemanager;

  end;



var
  GoEngine : TGOEngine;


implementation

uses IniFiles;

var CountInstances : Byte;

  { TGoTextureManager }

    constructor TGoTextureManager.Create;
    begin
      inherited Create;
      FTextureMap:=TGoTextureMap.Create;
    end;

        function TGoTextureManager.Load(aFileName: String; aID: String): Boolean;
    var TmpSurface : PSDL_Surface;
        TmpTexture : PSDL_Texture;
  begin
     Result := False;
     TmpSurface:=IMG_Load(PChar(aFileName));
     if TmpSurface=nil then begin
      WriteLN( SDL_GetError(),' Error loading '+aFileName);
      Exit;
     end;
     TmpTexture:=SDL_CreateTextureFromSurface(GoEngine.FRenderer,TmpSurface);
     SDL_FreeSurface(TmpSurface);
     if TmpTexture<>nil then begin
      FTextureMap[aID]:=TmpTexture;
      Result:=True;
     end;
  end;

        procedure TGoTextureManager.Draw(aID: String; x, y, w, h: Integer;
      Flip: Integer);
    var srcRect, dstRect : TSDL_Rect;
        p : TSDL_Point;
  begin
     srcRect.x := 0;
     srcRect.y := 0;
     srcRect.w := w;
     dstRect.w := w;
     srcRect.h := h;
     dstRect.h := h;
     dstRect.x := x;
     dstRect.y := y;
     p.x:=0;
     p.y:=0;
     SDL_RenderCopyEx(GoEngine.FRenderer,FTextureMap[aId],@srcRect,@dstRect,0.0,@p,Flip);
  end;

        procedure TGoTextureManager.DrawFrame(aID: String; x, y, w, h: Integer;
      CurrentRow, CurrentFrame: Integer; Flip: Integer);
    var srcRect, dstRect : TSDL_Rect;
      p : TSDL_Point;
  begin
     srcRect.x := w*CurrentFrame;
     srcRect.y := h*CurrentRow;
     srcRect.w := w;
     dstRect.w := w;
     srcRect.h := h;
     dstRect.h := h;
     dstRect.x := x;
     dstRect.y := y;
     p.x:=0;
     p.y:=0;
     SDL_RenderCopyEx(GoEngine.FRenderer,FTextureMap[aId],@srcRect,@dstRect,0.0,@p,Flip);
  end;

    destructor TGoTextureManager.Destroy;
    var
      i: Integer;
    begin
      for i:= FTextureMap.Count-1 downto 0 do begin
          SDL_DestroyTexture(FTextureMap.Data[i]);
          FTextureMap.Delete(i);
      end;
      FreeAndNil(FTextureMap);
      inherited Destroy;
    end;

  { TGOEngine }

    constructor TGOEngine.Create(Afile: Tfilename; Asection: String);
  begin
   if CountInstances>0 then Exit;
    inherited Create;
    FError:=false;
    FErrorInfo:='';
    FFileName:=AFile;
    FSection:=ASection;
    LoadSettings;
    //ініціалізація бібліотеки SDL 2.0
    if SDL_Init(SDL_INIT_EVERYTHING)>=0 then begin
     //прописуємо відповідні прапорці для вікна
     FWindowFlags:=SDL_WINDOW_SHOWN;
     if Ffullscreen then FWindowFlags:=FWindowFlags OR SDL_WINDOW_FULLSCREEN;
      //успішна ініціалізація - створюємо вікно
      FWindow:=SDL_CreateWindow('',
                                 SDL_WINDOWPOS_UNDEFINED,
                                 SDL_WINDOWPOS_UNDEFINED,
                                 FWidth,
                                 FHeight,
                                 FWindowFlags);
      //якщо вікно створене, створюємо візуалізатор
      if FWindow<>nil then begin
        FRendererFlags:=0;
        if Fhardwareacceleration then FRendererFlags:=FRendererFlags OR SDL_RENDERER_ACCELERATED;
        FRenderer:=SDL_CreateRenderer(FWindow,-1,0);
        if FRenderer=nil then begin
          FErrorInfo:=SDL_GetError;
          FError:=true;
          WriteLn(FErrorInfo);
        end else begin
          FTexturemanager:= TGoTextureManager.Create;
          fr:=0;
          fc:=0;
        end;
      //виділення пам'яті для структури обробки подій
      New(FEvent);
      //встановлення ознаки виконання циклу і його запуск
      FIsRun := true;
      end else begin
       FErrorInfo:=SDL_GetError;
       WriteLn(FErrorInfo);
       Exit;
      end;
    end;
  end;

procedure TGOEngine.SetCaption(AValue: String);
begin
  if FCaption=AValue then Exit;
  FCaption:=AValue;
  SDL_SetWindowTitle(FWindow,PChar(UTF8String(FCaption)));
end;

procedure TGOEngine.SetHeight(AValue: Integer);
begin
  if FHeight=AValue then Exit;
  FHeight:=AValue;
  if (FWindow<>nil) then begin
   SDL_SetWindowSize(FWindow, FWidth, FHeight);
   SDL_SetWindowPosition(FWindow,0,0);
  end;
end;

procedure TGOEngine.SetWidth(AValue: Integer);
begin
  if FWidth=AValue then Exit;
  FWidth:=AValue;
  if (FWindow<>nil) then begin
   SDL_SetWindowSize(FWindow, FWidth, FHeight);
   SDL_SetWindowPosition(FWindow,0,0);
  end;
end;

procedure TGOEngine.Setfullscreen(Avalue: Boolean);
begin
  if Ffullscreen=Avalue then Exit;
  Ffullscreen:=Avalue;
  if Ffullscreen then SDL_SetWindowFullscreen(FWindow,SDL_WINDOW_FULLSCREEN)
     else SDL_SetWindowFullscreen(FWindow,0);
  SDL_UpdateWindowSurface(FWindow);
  SDL_SetWindowTitle(FWindow,PChar(UTF8String(FCaption)));
end;

procedure TGOEngine.Sethardwareacceleration(Avalue: Boolean);
begin
  if Fhardwareacceleration=Avalue then Exit;
  Fhardwareacceleration:=Avalue;
  If (FRenderer<>nil) then begin
    SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_INFORMATION,
       'Warning!!!',
       'Налаштування будуть задіяні після перезапуску!!!',
       FWindow);
  end;
end;

procedure TGOEngine.LoadSettings;
var INI : TINIFile;
begin
 INI := TIniFile.Create(FFileName);

 FHeight:=INI.ReadInteger(FSection,'HEIGHT',640);
 FWidth:=INI.ReadInteger(FSection,'WIDTH',480);
 FCaption:=INI.ReadString(FSection,'CAPTION','');
 Ffullscreen:=INI.ReadBool(FSection,'FULLSCREEN',True);
 Fhardwareacceleration:=INI.ReadBool(FSection,'HARDWARE ACCELERATION',True);

 FreeAndNil(INI);
end;

function TGOEngine.SaveSettings: Boolean;
var INI : TINIFile;
begin
 Result := False;
 try
  INI := TIniFile.Create(FFileName);

  INI.WriteInteger(FSection,'HEIGHT',FHeight);
  INI.WriteInteger(FSection,'WIDTH',FWidth);
  INI.WriteString(FSection,'CAPTION',FCaption);
  INI.WriteBool(FSection,'FULLSCREEN',Ffullscreen);
  INI.WriteBool(FSection,'HARDWARE ACCELERATION',Fhardwareacceleration);
  Result := True;
 finally
  FreeAndNil(INI);
 end;
end;

        destructor TGOEngine.Destroy;
  begin
   //зберігаємо налаштування в файл
   if not  SaveSettings then WriteLN('Не вдалось записати налаштування!');
   //прибрати за собою - в оберненому порядку створення

   FreeAndNil(FTexturemanager);
   Dispose(FEvent);
   SDL_DestroyRenderer(FRenderer);
   SDL_DestroyWindow(FWindow);
   SDL_Quit();

   inherited Destroy;
  end;

  procedure TGOEngine.DoEvents;
  begin
   if SDL_PollEvent(FEvent)=1 then begin
    case FEvent^.type_ of
    //намагаємось відловити подію закриття вікна
SDL_QUITEV: FIsRun:=false;
SDL_KEYUP: begin
    //відловлюємо клавішу F11
    if (FEvent^.key.keysym.sym = SDLK_F11) then FullScreen:=not FullScreen;
    end;
    //втрата фокусу, згортання вікна
SDL_WINDOWEVENT_FOCUS_LOST, SDL_WINDOWEVENT_MINIMIZED: begin
     Factive:=False;
     WriteLN('Focus Lost!!!');
    end;
    //отримання фокусу
SDL_WINDOWEVENT_TAKE_FOCUS: begin
     Factive:=True;
     WriteLN('Focus Gained!!!');
    end;
   end;
  end;
end;

        procedure TGOEngine.GameLogic;
  begin
    //тут буде прораховуватись ігрова логіка
   if fc=7 then begin
    fc:=0;
    Inc(fr);
    if fr>9 then fr:=0;
   end else inc(fc);
   SDL_Delay(75);
  end;

        procedure TGOEngine.Draw;
  begin
      //встановимо колір вікна в голубий
    SDL_SetRenderDrawColor(FRenderer,0,128,255,255);
    //очистити вікно
    SDL_RenderClear(FRenderer);

    //temporary draw
    Texturemanager.DrawFrame('Tux',0,0,32,32,fr,fc);
    Texturemanager.DrawFrame('Tux',64,0,32,32,9-fr,7-fc);

    Texturemanager.DrawFrame('Tux earth',0,64,32,32,fr,fc);
    Texturemanager.DrawFrame('Tux earth',64,64,32,32,9-fr,7-fc);
    //показати вікно на екран
    SDL_RenderPresent(FRenderer);
  end;

        procedure TGOEngine.Run;
  begin
    if (FError=true) then begin
      WriteLn(FErrorInfo);
    end else while FIsRun do begin
      DoEvents;
      GameLogic;
      Draw;
    end;
  end;

initialization
CountInstances:=0;
GoEngine:=TGOEngine.Create;

finalization
FreeAndNil(GoEngine);
end.

