unit ugoengine;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, sdl2;

type

  { TGOEngine }

  TGOEngine = class
  private
    FCaption: String;
    FHeight: Integer;
    FWidth: Integer;
    FWindow : PSDL_Window;
    FRenderer : PSDL_Renderer;
    FEvent : PSDL_Event;
    FError: Boolean;
    FErrorInfo: String;
    FIsRun: Boolean;

    constructor Create;
    procedure SetCaption(AValue: String);
    procedure SetHeight(AValue: Integer);
    procedure SetWidth(AValue: Integer);

  public
    destructor Destroy; override;

    procedure DoEvents;
    procedure GameLogic;
    procedure Draw;
    procedure Run;
  published

   property Error : Boolean read FError;//ознака збою в роботі класа
   property ErrorInfo : String read FErrorInfo; //текстовий опис помилки
   property Caption : String read FCaption write SetCaption;
   property Width : Integer read FWidth write SetWidth default 640;
   property Height : Integer read FHeight write SetHeight default 480;
  end;

var
  GoEngine : TGOEngine;


implementation
var CountInstances : Byte;

  { TGOEngine }

  constructor TGOEngine.Create;
  begin
   if CountInstances>0 then Exit;
    inherited Create;
    FError:=false;
    FErrorInfo:='';
    //ініціалізація бібліотеки SDL 2.0
    if SDL_Init(SDL_INIT_EVERYTHING)>=0 then begin
      //успішна ініціалізація - створюємо вікно
      FWindow:=SDL_CreateWindow('',
                                 SDL_WINDOWPOS_UNDEFINED,
                                 SDL_WINDOWPOS_UNDEFINED,
                                 0,
                                 0,
                                 SDL_WINDOW_SHOWN);
      //якщо вікно створене, створюємо візуалізатор
      if FWindow<>nil then begin
        FRenderer:=SDL_CreateRenderer(FWindow,-1,0);
        if FRenderer=nil then begin
          FErrorInfo:=SDL_GetError;
          FError:=true;
          WriteLn(FErrorInfo);
        end;
      //виділення пам'яті для структури обробки подій
      New(FEvent);
      //встановлення ознаки виконання циклу і його запуск
      FIsRun := true;
      end else begin
       FErrorInfo:=SDL_GetError;
       WriteLn(FErrorInfo);
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

  destructor TGOEngine.Destroy;
  begin
   //прибрати за собою - в оберненому порядку створення
   Dispose(FEvent);
   SDL_DestroyRenderer(FRenderer);
   SDL_DestroyWindow(FWindow);
   SDL_Quit();

   inherited Destroy;
  end;

  procedure TGOEngine.DoEvents;
  begin
      //намагаємось відловити подію закриття вікна
   if SDL_PollEvent(FEvent)=1 then begin
    if FEvent^.type_=SDL_QUITEV then FIsRun:=false;
   end;
  end;

  procedure TGOEngine.GameLogic;
  begin
    //тут буде прораховуватись ігрова логіка
  end;

  procedure TGOEngine.Draw;
  begin
      //встановимо колір вікна в голубий
    SDL_SetRenderDrawColor(FRenderer,0,128,255,255);
    //очистити вікно
    SDL_RenderClear(FRenderer);
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

