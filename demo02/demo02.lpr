program demo02;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes
  { you can add units after this },sdl2;
var
  SDLWindow : PSDL_Window;     //вікно
  SDLRenderer : PSDL_Renderer; //візуалізатор
  SDLEvent : PSDL_Event;       //події
  isRun : Boolean;             //ознака виконання циклу

function Initialize(aCaption : PChar; _w,_h : Integer) : Boolean;
begin
  result:=false;
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
        WriteLN('SDL error: ',SDL_GetError);
        Exit;
      end;
    end;
    //виділення пам'яті для структури обробки подій
    New(SDLEvent);
    //встановлення ознаки виконання циклу і його запуск
    isRun := true;
    result:=true;
    end;
end;

procedure DoEvents;
begin
  //намагаємось відловити подію закриття вікна
  if SDL_PollEvent(SDLEvent)=1 then begin
    if SDLEvent^.type_=SDL_QUITEV then isRun:=false;
  end;
end;

procedure GameLogic;
begin
  //тут в майбутньому буде щось прораховуватись
end;

procedure Draw;
begin
  //встановимо колір вікна в голубий
  SDL_SetRenderDrawColor(SDLRenderer,0,128,255,255);
  //очисстити вікно
  SDL_RenderClear(SDLRenderer);
  //показати вікно на екран
  SDL_RenderPresent(SDLRenderer);
end;

procedure Cleanup;
begin
  //прибрати за собою - в оберненому порядку створення
  Dispose(SDLEvent);
  SDL_DestroyRenderer(SDLRenderer);
  SDL_DestroyWindow(SDLWindow);
  SDL_Quit();
end;

begin
  if Initialize('Demo02',640,480) then
    while isRun=true do begin
      DoEvents;
      GameLogic;
      Draw;
    end;
    Cleanup;
end.

