unit ugoengine;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, sdl2;

type

  { TGOEngine }

  TGOEngine = class
  private
    FError: Boolean;
    FErrorInfo: String;
    FIsRun: Boolean;

  public
    constructor Create(aCaption : PChar; _w,_h : Integer);
    destructor Destroy; override;

    procedure DoEvents;
    procedure GameLogic;
    Procedure Draw;
  published

   property IsRun : Boolean read FIsRun;//ознака виконання головного циклу
   property Error : Boolean read FError;//ознака збою в роботі класа
   property ErrorInfo : String read FErrorInfo; //текстовий опис помилки
  end;

implementation

  Var
  SDLWindow : PSDL_Window;     //вікно
  SDLRenderer : PSDL_Renderer; //візуалізатор
  SDLEvent : PSDL_Event;       //події

  { TGOEngine }

  constructor TGOEngine.Create(aCaption: PChar; _w, _h: Integer);
  begin
    inherited Create;
    FError:=false;
    FErrorInfo:='';
    //ініціалізація бібліотеки SDL 2.0
    if SDL_Init(SDL_INIT_EVERYTHING)>=0 then begin
      //успішна ініціалізація - створюємо вікно
      SDLWindow:=SDL_CreateWindow(aCaption,
                                 SDL_WINDOWPOS_UNDEFINED,
                                 SDL_WINDOWPOS_UNDEFINED,
                                 _w,
                                 _h,
                                 SDL_WINDOW_SHOWN);
      //якщо вікно створене, створюємо візуалізатор
      if SDLWindow<>nil then begin
        SDLRenderer:=SDL_CreateRenderer(SDLWindow,-1,0);
        if SDLRenderer=nil then begin
          FErrorInfo:=SDL_GetError;
          FError:=true;
        end;
      end;
      //виділення пам'яті для структури обробки подій
      New(SDLEvent);
      //встановлення ознаки виконання циклу і його запуск
      FIsRun := true;
  end;
  end;

  destructor TGOEngine.Destroy;
  begin
   //прибрати за собою - в оберненому порядку створення
   Dispose(SDLEvent);
   SDL_DestroyRenderer(SDLRenderer);
   SDL_DestroyWindow(SDLWindow);
   SDL_Quit();

   inherited Destroy;
  end;

  procedure TGOEngine.DoEvents;
  begin
      //намагаємось відловити подію закриття вікна
   if SDL_PollEvent(SDLEvent)=1 then begin
    if SDLEvent^.type_=SDL_QUITEV then FIsRun:=false;
   end;
  end;

  procedure TGOEngine.GameLogic;
  begin
    //тут буде прораховуватись ігрова логіка
  end;

  procedure TGOEngine.Draw;
  begin
      //встановимо колір вікна в голубий
    SDL_SetRenderDrawColor(SDLRenderer,0,128,255,255);
    //очисстити вікно
    SDL_RenderClear(SDLRenderer);
    //показати вікно на екран
    SDL_RenderPresent(SDLRenderer);
  end;

end.

