unit ugoengine;

{$mode ObjFPC}{$H+}{$M+}

interface

uses
  Classes, SysUtils, fgl, sdl2, sdl2_image, sdl2_ttf;

const
  GO_MAX_FPS = 120;

  //константи для віддзеркалення зображень
  GO_FLIP_NONE = SDL_FLIP_NONE;
  GO_FLIP_H = SDL_FLIP_HORIZONTAL;
  GO_FLIP_V = SDL_FLIP_VERTICAL;
  GO_FLIP_D = SDL_FLIP_HORIZONTAL OR SDL_FLIP_VERTICAL;

type

  { TSDLTextureWrapper }

  TSDLTextureWrapper = class
  private
    FBgColor: TSDL_Color;
    FFontColor: TSDL_Color;
    FFontFile: TFileName;
    FFontName: String;
    FFontSize: Integer;
    FTexture: PSDL_Texture;
    procedure SetBgColor(AValue: TSDL_Color);
    procedure SetFontColor(AValue: TSDL_Color);
    procedure SetFontFile(AValue: TFileName);
    procedure SetFontSize(AValue: Integer);
  public
    property Texture: PSDL_Texture read FTexture;
    constructor Create(aFilename : TFileName);
    // створити текстуру з файла зображення
    constructor Create(aText : String);
    // створити текстуру з тексту з заданим шрифтом, кольором і розміром
    destructor Destroy; override;

    property FontName : String read FFontName; //назва шрифту визначається з назви файлу
    property FontFile : TFileName read FFontFile write SetFontFile; //файл зі шрифтом
    property FontSize : Integer read FFontSize write SetFontSize default 20; //розмір шрифту (по замовчуванню 20px)
    property FontColor : TSDL_Color read FFontColor write SetFontColor; //колір тексту
    property BgColor : TSDL_Color read FBgColor write SetBgColor; //колір фону для тексту

  end;


  TGOTextureMap = specialize TFPGMapObject<String, TSDLTextureWrapper>;


  { TGOTextureManager }

  TGOTextureManager = class
  private
    FTextureMap: TGoTextureMap;
    constructor Create;
  public
    destructor Destroy; override;
    function Add(const aTexture : TSDLTextureWrapper; aID: String): Boolean; //додати зображення з файлу в карту текстур

    procedure Draw(aID: String; x, y, w, h: Integer; Flip: Integer = SDL_FLIP_NONE); //намалювати зображення в потрібній позиції
    procedure DrawFrame(aID: String; x, y, w, h, r, c: Integer; Flip: Integer = SDL_FLIP_NONE); //намалювати кадр зображення в потрібній позиції
  end;

  { TGOObjLoader }

  TGOObjLoader = class
   protected
    FX, FY: Integer;  //позиція об'єкта
    FW, FH: Integer;  //розміри об'єкта
    FCol, FRow: Integer; //стовбець і рядок фрагмента зображення
    FFlip: Integer; //ознака віддзеркалення для малювання
    FId: String;
   public
    constructor Create(x, y, Width, Height: Integer; Id: String);
    property X : Integer read FX write FX default 0;
    property Y : Integer read FY write FY default 0;
    property Width : Integer read FW write FW default 0;
    property Height : Integer read FH write FH default 0;
    property Column : Integer read FCol write FCol default 1;
    property Row : Integer read FRow write FRow default 1;
    property Id : String read FId write FId;
    property Flip : Integer read FFlip write FFlip default GO_FLIP_NONE;
  end;

  { TGOBaseObject }

  TGOBaseObject = class
  protected
    FX, FY: Integer;  //позиція об'єкта
    FW, FH: Integer;  //розміри об'єкта
    FCol, FRow: Integer; //стовбець і рядок фрагмента зображення
    FFlip: Integer; //ознака віддзеркалення для малювання
    FId: String;
  public
    constructor Create(const ObjLoader : TGOObjLoader);
    procedure Draw(); virtual;
    procedure Update(); virtual; abstract;
    procedure Clear(); virtual; abstract;
  end;

  TGOObjectsList = specialize TFPGObjectList<TGOBaseObject>;

  { TGOEngine }

  TGOEngine = class
  private
    FCaption: String;
    FFPSLimit: Integer;
    FFrameDelay: Integer;

    FHeight: Integer;
    FTextureManager: TGOTextureManager;
    FGameObjects: TGOObjectsList;
    FWidth: Integer;
    FWindow: PSDL_Window;
    FRenderer: PSDL_Renderer;
    FEvent: PSDL_Event;
    FError: Boolean;
    FErrorInfo: String;
    FIsRun: Boolean;
    Ffullscreen: Boolean;
    Factive: Boolean;
    FWindowFlags: Integer; //прапорці для вікна
    FRendererFlags: Integer; //прапорці для візуалізатора
    Fhardwareacceleration: Boolean;
    FFileName: TFileName; // ім'я файлу налаштувань
    FSection: String; //назва секції налаштувань фреймворка


    constructor Create(Afile: Tfilename = 'goengine.ini'; Asection: String = 'ENGINE');
    procedure SetCaption(AValue: String);
    procedure SetFPSLimit(AValue: Integer);
    procedure SetHeight(AValue: Integer);
    procedure SetWidth(AValue: Integer);
    procedure Setfullscreen(Avalue: Boolean);
    procedure Sethardwareacceleration(Avalue: Boolean);
    procedure LoadSettings;
    function SaveSettings: Boolean;
  public
    destructor Destroy; override;

    procedure DoEvents;
    procedure Update;
    procedure Draw;
    procedure Run;
  published

    property Error: Boolean read FError;//ознака збою в роботі класа
    property ErrorInfo: String read FErrorInfo; //текстовий опис помилки
    property Caption: String read FCaption write SetCaption;//заголовок вікна
    property Width: Integer read FWidth write SetWidth default 640; //ширина вікна
    property Height: Integer read FHeight write SetHeight default 480; //висота вікна
    property FullScreen: Boolean read FFullScreen write SetFullScreen default False; //повноекранний режим
    property Active: Boolean read FActive default True;//чи вікно має фокус
    property HardwareAcceleration: Boolean read FHardwareAcceleration write SetHardwareAcceleration default True; //апаратне прикорення
    property FPSLimit: Integer read FFPSLimit write SetFPSLimit default 60; //обмеження частоти кадрів

    property TextureManager: TGOTextureManager read FTextureManager; //менеджер текстур
    property GameObjects: TGOObjectsList read FGameObjects;        //список об'єктів

  end;

var
  GoEngine: TGOEngine;


implementation

uses IniFiles;

var
  CountInstances: Byte;

{ TGOObjLoader }

constructor TGOObjLoader.Create(x, y, Width, Height: Integer; Id: String);
begin
  FX := x;
  FY := y;
  FW := Width;
  FH := Height;
  FId := Id;
  FRow := 1;
  FCol := 1;
  FFlip := SDL_FLIP_NONE;
end;

{ TSDLTextureWrapper }

procedure TSDLTextureWrapper.SetFontFile(AValue: TFileName);
begin
  if FFontFile=AValue then Exit;
  FFontFile:=AValue;
  FFontName:=ChangeFileExt(ExtractFileName(FFontFile),'');
end;

procedure TSDLTextureWrapper.SetFontColor(AValue: TSDL_Color);
begin
  FFontColor.a:=AValue.a;
  FFontColor.b:=AValue.b;
  FFontColor.g:=AValue.g;
  FFontColor.r:=AValue.r;
end;

procedure TSDLTextureWrapper.SetBgColor(AValue: TSDL_Color);
begin
  FBgColor.a:=AValue.a;
  FBgColor.b:=AValue.b;
  FBgColor.g:=AValue.g;
  FBgColor.r:=AValue.r;
end;

procedure TSDLTextureWrapper.SetFontSize(AValue: Integer);
begin
  if FFontSize=AValue then Exit;
  FFontSize:=AValue;
end;

constructor TSDLTextureWrapper.Create(aFilename: TFileName);
var
  Tmpsurface: PSDL_Surface;
  TmpTexture: PSDL_Texture;
begin
  Tmpsurface := IMG_Load(PChar(aFilename));
  if Tmpsurface = nil then
  begin
    WriteLn(SDL_GetError, ' Error loading ' + aFilename);
    Exit;
  end;
  TmpTexture := SDL_CreateTextureFromSurface(GoEngine.FRenderer, Tmpsurface);
  SDL_FreeSurface(Tmpsurface);
  if TmpTexture <> nil then
  begin
    FTexture:=TmpTexture;
  end;
end;

constructor TSDLTextureWrapper.Create(aText: String);
var
  aSurface : PSDL_Surface;
  aFont : PTTF_Font;
begin
  if TTF_Init()=-1 then begin
    GoEngine.FError:=True;
    GoEngine.FErrorInfo:='SDL_TTF not initialized!';
    Exit;
  end;
  aFont:=TTF_OpenFont(PChar(FFontFile),FFontSize);
  aSurface:=TTF_RenderText_Solid(aFont,PChar(aText),FFontColor);
  if aSurface=nil then begin
    GoEngine.FError:=True;
    GoEngine.FErrorInfo:='SDL_TTF can''t render text!';
    Exit;
  end;
  FTexture:=SDL_CreateTextureFromSurface(GoEngine.FRenderer,aSurface);
  WriteLn('debug: text height:',aSurface^.h, ' text width:',aSurface^.w);
  SDL_FreeSurface(aSurface);
  TTF_CloseFont(aFont);
end;

destructor TSDLTextureWrapper.Destroy;
begin
  SDL_DestroyTexture(Texture);
  inherited Destroy;
end;

{ TGOBaseObject }

constructor TGOBaseObject.Create(const ObjLoader: TGOObjLoader);
begin
  FX := ObjLoader.X;
  FY := ObjLoader.Y;
  FW := ObjLoader.Width;
  FH := ObjLoader.Height;
  FId := ObjLoader.Id;
  FRow := ObjLoader.Row;
  FCol := ObjLoader.Column;
  FFlip := ObjLoader.Flip;
end;

procedure TGOBaseObject.Draw;
begin
 if fID<>'' then
 GoEngine.TextureManager.DrawFrame(FId, Fx, Fy, Fw, Fh, FRow, FCol, FFlip);
end;

{ TGOBaseObject }

{ TGOTextureManager }

constructor TGOTextureManager.Create;
begin
  inherited Create;
  FTextureMap := TGOTextureMap.Create;
end;

destructor TGOTextureManager.Destroy;
begin
  FreeAndNil(FTextureMap);
  inherited Destroy;
end;

function TGOTextureManager.Add(const aTexture: TSDLTextureWrapper; aID: String
  ): Boolean;
begin
  Result := False;
  FTextureMap[aID] := aTexture;
  Result := True;
end;

procedure TGOTextureManager.Draw(aID: String; x, y, w, h: Integer; Flip: Integer);
var
  srcRect, dstRect: TSDL_Rect;
begin
  srcRect.x := 0;
  srcRect.y := 0;
  srcRect.w := w;
  srcRect.h := h;
  dstRect.x := x;
  dstRect.y := y;
  dstRect.w := w;
  dstRect.h := h;
  SDL_RenderCopyEx(GoEngine.FRenderer, FTextureMap[aID].Texture, @srcRect, @dstRect, 0, nil, Flip);
end;

procedure TGOTextureManager.DrawFrame(aID: String; x, y, w, h, r, c: Integer; Flip: Integer);
var
  srcRect, dstRect: TSDL_Rect;
begin
  srcRect.x := w * c;
  srcRect.y := h * r;
  srcRect.w := w;
  srcRect.h := h;
  dstRect.x := x;
  dstRect.y := y;
  dstRect.w := w;
  dstRect.h := h;
  SDL_RenderCopyEx(GoEngine.FRenderer, FTextureMap[aID].Texture, @srcRect, @dstRect, 0, nil, Flip);
end;

{ TGOEngine }

constructor TGOEngine.Create(Afile: Tfilename; Asection: String);
begin
  if CountInstances > 0 then Exit;
  inherited Create;
  FError := False;
  FErrorInfo := '';
  FFileName := AFile;
  FSection := ASection;
  LoadSettings;
  //ініціалізація бібліотеки SDL 2.0
  if SDL_Init(SDL_INIT_EVERYTHING) >= 0 then
  begin
    //прописуємо відповідні прапорці для вікна
    FWindowFlags := SDL_WINDOW_SHOWN;
    if Ffullscreen then FWindowFlags := FWindowFlags or SDL_WINDOW_FULLSCREEN;
    //успішна ініціалізація - створюємо вікно
    FWindow := SDL_CreateWindow('', SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, FWidth, FHeight, FWindowFlags);
    //якщо вікно створене, створюємо візуалізатор
    if FWindow <> nil then
    begin
      FRendererFlags := 0;
      if Fhardwareacceleration then FRendererFlags := FRendererFlags or SDL_RENDERER_ACCELERATED;
      FRenderer := SDL_CreateRenderer(FWindow, -1, 0);
      if FRenderer = nil then
      begin
        FErrorInfo := SDL_GetError;
        FError := True;
        WriteLn(FErrorInfo);
      end
      else
      begin
        FTextureManager := TGOTextureManager.Create;
        FGameObjects := TGOObjectsList.Create;
      end;
      //виділення пам'яті для структури обробки подій
      New(FEvent);
      //встановлення ознаки виконання циклу і його запуск
      FIsRun := True;
    end
    else
    begin
      FErrorInfo := SDL_GetError;
      WriteLn(FErrorInfo);
    end;
  end;
end;

procedure TGOEngine.SetCaption(AValue: String);
begin
  FCaption := AValue;
  SDL_SetWindowTitle(FWindow, PChar(Utf8string(FCaption)));
end;

procedure TGOEngine.SetFPSLimit(AValue: Integer);
begin
  if FFPSLimit = AValue then Exit;
  FFPSLimit := AValue;
end;

procedure TGOEngine.SetHeight(AValue: Integer);
begin
  if FHeight = AValue then Exit;
  FHeight := AValue;
  if (FWindow <> nil) then
  begin
    SDL_SetWindowSize(FWindow, FWidth, FHeight);
    SDL_SetWindowPosition(FWindow, 0, 0);
  end;
end;

procedure TGOEngine.SetWidth(AValue: Integer);
begin
  if FWidth = AValue then Exit;
  FWidth := AValue;
  if (FWindow <> nil) then
  begin
    SDL_SetWindowSize(FWindow, FWidth, FHeight);
    SDL_SetWindowPosition(FWindow, 0, 0);
  end;
end;

procedure TGOEngine.Setfullscreen(Avalue: Boolean);
begin
  if Ffullscreen = Avalue then Exit;
  Ffullscreen := Avalue;
  if Ffullscreen then SDL_SetWindowFullscreen(FWindow, SDL_WINDOW_FULLSCREEN)
  else
    SDL_SetWindowFullscreen(FWindow, 0);
  SDL_UpdateWindowSurface(FWindow);
end;

procedure TGOEngine.Sethardwareacceleration(Avalue: Boolean);
begin
  if Fhardwareacceleration = Avalue then Exit;
  Fhardwareacceleration := Avalue;
  if (FRenderer <> nil) then
  begin
    SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_INFORMATION,
      'Warning!!!',
      'Налаштування будуть задіяні після перезапуску!!!',
      FWindow);
  end;
end;

procedure TGOEngine.LoadSettings;
var
  INI: TINIFile;
begin
  INI := TIniFile.Create(FFileName);

  FHeight := INI.ReadInteger(FSection, 'HEIGHT', 640);
  FWidth := INI.ReadInteger(FSection, 'WIDTH', 480);
  FCaption := INI.ReadString(FSection, 'CAPTION', '');
  Ffullscreen := INI.ReadBool(FSection, 'FULLSCREEN', True);
  Fhardwareacceleration := INI.ReadBool(FSection, 'HARDWARE ACCELERATION', True);

  FreeAndNil(INI);
end;

function TGOEngine.SaveSettings: Boolean;
var
  INI: TINIFile;
begin
  Result := False;
  try
    INI := TIniFile.Create(FFileName);

    INI.WriteInteger(FSection, 'HEIGHT', FHeight);
    INI.WriteInteger(FSection, 'WIDTH', FWidth);
    INI.WriteString(FSection, 'CAPTION', FCaption);
    INI.WriteBool(FSection, 'FULLSCREEN', Ffullscreen);
    INI.WriteBool(FSection, 'HARDWARE ACCELERATION', Fhardwareacceleration);
    Result := True;
  finally
    FreeAndNil(INI);
  end;
end;

destructor TGOEngine.Destroy;
begin
  //зберігаємо налаштування в файл
  if not SaveSettings then WriteLN('Не вдалось записати налаштування!');
  //прибрати за собою - в оберненому порядку створення
  FreeAndNil(FGameObjects);
  FreeAndNil(FTextureManager);
  Dispose(FEvent);
  SDL_DestroyRenderer(FRenderer);
  SDL_DestroyWindow(FWindow);
  SDL_Quit();

  inherited Destroy;
end;

procedure TGOEngine.DoEvents;
begin
  if SDL_PollEvent(FEvent) = 1 then
  begin
    case FEvent^.type_ of
      //намагаємось відловити подію закриття вікна
      SDL_QUITEV: FIsRun := False;
      SDL_KEYUP: begin
        //відловлюємо клавішу F11
        if (FEvent^.key.keysym.sym = SDLK_F11) then FullScreen := not FullScreen;
      end;
      //втрата фокусу, згортання вікна
      SDL_WINDOWEVENT_FOCUS_LOST, SDL_WINDOWEVENT_MINIMIZED: begin
        Factive := False;
        WriteLN('Focus Lost!!!');
      end;
      //отримання фокусу
      SDL_WINDOWEVENT_TAKE_FOCUS: begin
        Factive := True;
        WriteLN('Focus Gained!!!');
      end;
    end;
  end;
end;

procedure TGOEngine.Update;
var
  gobj: TGOBaseObject;
begin
  //якщо список об'єктів порожній, виходимо з метода
  if FGameObjects.Count = 0 then Exit;
  for gobj in FGameObjects do
  begin
    gobj.Update();
    //if gobj.FId='' then FGameObjects.Remove(gobj);
  end;
  //SDL_Delay(100);
end;

procedure TGOEngine.Draw;
var
  gobj: TGOBaseObject;
begin
  //встановимо колір вікна в голубий
  SDL_SetRenderDrawColor(FRenderer, 0, 128, 255, 255);
  //очистити вікно
  SDL_RenderClear(FRenderer);

  //вивести потрібні об'єкти, якщо список не порожній
  if FGameObjects.Count <> 0 then
    for gobj in FGameObjects do gobj.Draw();

  //показати вікно на екран
  SDL_RenderPresent(FRenderer);
end;

procedure TGOEngine.Run;
begin
  if (FError = True) then
  begin
    WriteLn(FErrorInfo);
  end
  else
    while FIsRun do
    begin

      DoEvents;
      Update;
      Draw;
    end;
end;

initialization
  CountInstances := 0;
  GoEngine := TGOEngine.Create;

finalization
  FreeAndNil(GoEngine);
end.
