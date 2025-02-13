#ifndef SCARLET_HPP
#define SCARLET_HPP

#include <fstream>
#include <iostream>
#include <string>
#include <vector>

#include <SDL2/SDL.h>
#include <SDL2/SDL_mixer.h>
#include <sol/sol.hpp>

/*
Scarlet:
- Log
- File
- Lua
- Input
- Audio
- Graphics
- Engine
*/

namespace Scarlet {
  namespace Log {
    void Info(std::string msg) {
      std::cout << "INFO:  \t" << msg << std::endl;
    }
    void Warn(std::string msg) {
      std::cout << "WARN:  \t" << msg << std::endl;
    }
    void Error(std::string msg) {
      std::cerr << "ERROR: \t" << msg << std::endl;
    }
  };

  namespace File {
    std::vector<uint8_t> Read(const char* path) {
      std::vector<uint8_t> data;

      std::streampos begin, end;
      std::ifstream file(path);
      begin = file.tellg();
      file.seekg(0, std::ios::end);
      end = file.tellg();
      file.seekg(0, std::ios::beg);
      int size = begin - end;
      char* mem = new char[size];
      file.read(mem, size);
      file.close();

      for (int i = 0; i < size; i++) {
        data.push_back(static_cast<uint8_t>(mem[i]));
      }

      delete[] mem;

      return data;
    }
  };

  class Lua {

   public:
    sol::state* GetState() {
      return state;
    }

   public:
    static Lua& GetInstance() {
      if (!instance)
        instance = new Lua;
      return *instance;
    }
    Lua(const Lua&) = delete;
    Lua& operator=(const Lua&) = delete;

   private:
    Lua() {
      state = new sol::state;
      state->open_libraries(
        sol::lib::base,
        sol::lib::coroutine,
        sol::lib::math,
        sol::lib::package,
        sol::lib::string,
        sol::lib::table
      );
    }
    ~Lua() {
      delete state;
    }

   private:
    sol::state* state;
    inline static Lua* instance = nullptr;
  };

  class Input {
   public:
    void Init() {
      Log::Info("Initializing input component...");

      sol::state* lua = Lua::GetInstance().GetState();

      luaController = lua->new_usertype<Controller>("Controller", sol::no_constructor);
      luaController.set("id", sol::readonly(&Controller::id));
      luaController.set("type", sol::readonly(&Controller::type));

      controllers = lua->create_table();

      Log::Info("Input component initialized.");
    }
    void FindControllers() {
      Log::Info("Enumerating controllers...");

      Log::Info("Detected " + std::to_string(SDL_NumJoysticks()) + " joysticks...");

      for (int i = 0; i < SDL_NumJoysticks(); i++) {
        SDL_GameController* gamepad;
        if (SDL_IsGameController(i)) {
          gamepad = SDL_GameControllerOpen(i);
        }
        Controller c;
        c.gamepad = gamepad;
        c.id = SDL_JoystickGetDeviceInstanceID(i);
        c.type = SDL_GameControllerGetType(gamepad);
        controllers[i + 1] = c;
      }

      Log::Info("Controllers enumerated.");
      Log::Info(std::to_string(controllers.size()) + " controller(s) connected.");
    }
    void HandleEvent(SDL_Event* event) {
      sol::state* lua = Lua::GetInstance().GetState();
      sol::table luaEvent = lua->create_table();
      switch (event->type) {
        // Keyboard and Mouse
        case SDL_KEYDOWN: {
          luaEvent["type"] = event->key.repeat > 0 ? "KeyRepeat" : "KeyDown";
          luaEvent["button"] = SDL_GetKeyName(event->key.keysym.sym);
          break;
        }
        case SDL_KEYUP: {
          luaEvent["type"] = "KeyUp";
          luaEvent["button"] = SDL_GetKeyName(event->key.keysym.sym);
          break;
        }
        case SDL_MOUSEBUTTONDOWN: {
          luaEvent["type"] = "MouseDown";
          luaEvent["button"] = event->button.button;
          break;
        }
        case SDL_MOUSEBUTTONUP: {
          luaEvent["type"] = "MouseUp";
          luaEvent["button"] = event->button.button;
          break;
        }
        // Controller
        case SDL_CONTROLLERBUTTONDOWN: {
          luaEvent["type"] = "GamepadDown";
          luaEvent["id"] = event->cdevice.which;
          luaEvent["button"] = SDL_GameControllerGetStringForButton(static_cast<SDL_GameControllerButton>(event->cbutton.button));
          break;
        }
        case SDL_CONTROLLERBUTTONUP: {
          luaEvent["type"] = "GamepadUp";
          luaEvent["id"] = event->cdevice.which;
          luaEvent["button"] = SDL_GameControllerGetStringForButton(static_cast<SDL_GameControllerButton>(event->cbutton.button));
          break;
        }
        case SDL_CONTROLLERAXISMOTION: {
          luaEvent["type"] = "GamepadAxis";
          luaEvent["id"] = event->cdevice.which;
          luaEvent["axis"] = event->caxis.axis;
          luaEvent["value"] = event->caxis.value;
          break;
        }
      }
      (*lua)["input"](luaEvent);
    }

   public:
    static Input& GetInstance() {
      if (!instance) {
        instance = new Input;
      }
      return *instance;
    }
    Input(const Input&) = delete;
    Input& operator=(const Input&) = delete;

   private:
    Input() {}
    ~Input() {
      for (int i = 0; i < controllers.size(); i++) {
        Controller& c = controllers[i + 1];
        SDL_GameControllerClose(c.gamepad);
      }
    }

   private:
    struct Controller {
      std::string type;
      Sint32 id;
      SDL_GameController* gamepad;
    };
    sol::usertype<Controller> luaController;
    sol::table controllers;
    inline static Input* instance = nullptr;
  };

  class Audio {
   public:
    bool Init() {
      Log::Info("Initializing audio component...");
      Mix_Init(MIX_INIT_MP3 | MIX_INIT_OGG);
      if (Mix_OpenAudio(
        MIX_DEFAULT_FREQUENCY,
        MIX_DEFAULT_FORMAT,
        2, 1024
      ) < 0) {
        Log::Error("Failed to initialize audio component.");
        return false;
      }

      sol::state* lua = Lua::GetInstance().GetState();

      std::function getVol = [&]() { return this->GetVolume(); };
      std::function setVol = [&](float vol) { this->SetVolume(vol); };

      sol::table musicTable = lua->create_table_with(
        "play", [&](const char* path) { this->PlayMusic(path); },
        "stop", [&]() { if (this->music) this->StopMusic(); },
        "volume", sol::property(getVol, setVol)
      );
      (*lua)["scarlet"]["music"] = musicTable;

      Log::Info("Initialized audio component.");

      return true;
    }
    void PlayMusic(const char* path) {
      StopMusic();
      music = Mix_LoadMUS(path);
      Mix_PlayMusic(music, -1);
    }
    void StopMusic() {
      Mix_PauseMusic();
    }
    void SetVolume(float vol) {
      volume = vol;
      float logVol = log(1 + volume);
      Mix_VolumeMusic(MIX_MAX_VOLUME * logVol);
    }
    float GetVolume() const {
      return volume;
    }

   public:
    static Audio& GetInstance() {
      if (!instance) {
        instance = new Audio;
      }
      return *instance;
    }
    Audio(const Audio&) = delete;
    Audio& operator=(const Audio&) = delete;

   private:
    Audio() { music = nullptr; }
    ~Audio() {
      StopMusic();
      Mix_CloseAudio();
    }
    float volume;
    Mix_Music* music;
    inline static Audio* instance = nullptr;
  };

  class Graphics {
   public:
    static bool Init(const char* title, int width, int height) {
      Log::Info("Initializing graphics component...");

      if (SDL_Init(SDL_INIT_EVERYTHING) < 0) {
        Log::Error("Unable to initialize SDL.");
        return false;
      }

      window = SDL_CreateWindow(title,
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
        width, height,
        0
      );
      if (!window) {
        Log::Error("Unable to create SDL window.");
        return false;
      }

      int rendererIndex = -1;
      for (int i = 0; i < SDL_GetNumRenderDrivers(); i++) {
        SDL_RendererInfo info;
        SDL_GetRenderDriverInfo(i, &info);
        if (strcmp(info.name, "opengl")) {
          rendererIndex = i;
          break;
        }
      }
      if (rendererIndex < 0) {
        Log::Error("OpenGL not found.");
        return false;
      }

      renderer = SDL_CreateRenderer(window, rendererIndex, SDL_RENDERER_ACCELERATED);
      if (!renderer) {
        Log::Error("Unable to create SDL renderer.");
        return false;
      }

      SDL_RenderSetLogicalSize(renderer, width, height);
      SDL_SetWindowFullscreen(window, SDL_WINDOW_FULLSCREEN_DESKTOP);
      SDL_RenderSetVSync(renderer, 1);

      SDL_Surface* surface = SDL_CreateRGBSurfaceWithFormat(
        0,
        1, 1,
        32, SDL_PIXELFORMAT_RGB888
      );
      SDL_FillRect(surface, nullptr, SDL_MapRGB(
        surface->format,
        255u, 255u, 255u
      ));

      texture = SDL_CreateTextureFromSurface(renderer, surface);
      SDL_FreeSurface(surface);

      sol::state* lua = Lua::GetInstance().GetState();

      sol::table windowTable = lua->create_table_with(
        "width", width,
        "height", height,
        "title", title,
        "fullscreen", sol::property(&Graphics::IsFullscreen, &Graphics::SetFullscreen)
      );

      sol::table graphicsTable = lua->create_table_with(
        "drawQuad", &Graphics::DrawQuad
      );

      (*lua)["scarlet"] = lua->create_table_with(
        "window", windowTable,
        "graphics", graphicsTable
      );

      Log::Info("Graphics component initialized.");

      return true;
    }
    static void Destroy() {
      Log::Info("Destroying graphics related objects...");
      SDL_DestroyTexture(texture);
      SDL_DestroyRenderer(renderer);
      SDL_DestroyWindow(window);
      SDL_Quit();
    }
    static void PreDraw() {
      SDL_SetRenderDrawColor(renderer, 0u, 0u, 0u, 255u);
      SDL_RenderClear(renderer);
    }
    static void PostDraw() {
      SDL_RenderPresent(renderer);
    }
    static void DrawQuad(float x, float y, float w, float h, float rot, sol::table color) {
      SDL_FRect rect;
      rect.x = x;
      rect.y = y;
      rect.w = w;
      rect.h = h;

      SDL_Color newColor;
      newColor.r = static_cast<Uint8>(255u * static_cast<float>(color["r"]));
      newColor.g = static_cast<Uint8>(255u * static_cast<float>(color["g"]));
      newColor.b = static_cast<Uint8>(255u * static_cast<float>(color["b"]));
      newColor.a = static_cast<Uint8>(255u * static_cast<float>(color["a"]));

      SDL_Color oldColor;
      SDL_BlendMode oldBlend;
      SDL_GetTextureColorMod(texture, &oldColor.r, &oldColor.g, &oldColor.b);
      SDL_GetTextureAlphaMod(texture, &oldColor.a);
      SDL_GetTextureBlendMode(texture, &oldBlend);
      SDL_SetTextureColorMod(texture, newColor.r, newColor.g, newColor.b);
      SDL_SetTextureAlphaMod(texture, newColor.a);
      SDL_SetTextureBlendMode(texture, SDL_BLENDMODE_BLEND);
      SDL_RenderCopyExF(
        renderer,
        texture,
        nullptr,
        &rect,
        rot,
        nullptr,
        SDL_FLIP_NONE
      );
      SDL_SetTextureColorMod(texture, oldColor.r, oldColor.g, oldColor.b);
      SDL_SetTextureAlphaMod(texture, oldColor.a);
      SDL_SetTextureBlendMode(texture, oldBlend);
    }
    static void SetFullscreen(bool on) {
      fullscreen = on;
      SDL_SetWindowFullscreen(window, fullscreen ? SDL_WINDOW_FULLSCREEN_DESKTOP : 0);
    }
    static bool IsFullscreen() {
      return fullscreen;
    }
    static SDL_Renderer* GetMainRenderer() { return renderer; }
    static SDL_Texture* GetDefaultTexture() { return texture; }
    static SDL_Window* GetMainWindow() { return window; }

   private:
    Graphics();

   private:
    inline static bool fullscreen = false;
    inline static SDL_Renderer* renderer = nullptr;
    inline static SDL_Texture* texture = nullptr;
    inline static SDL_Window* window = nullptr;
  };

  class Engine {
   public:
    bool Init(const char* title, int width, int height) {
      Log::Info("Initializing engine...");

      if (!Graphics::Init(title, width, height)) {
        Log::Error("Failed to initialize engine.");
        return false;
      }

      if (!Audio::GetInstance().Init()) {
        Log::Error("Failed to initialize engine.");
        return false;
      }

      (*lua)["scarlet"]["exit"] = [&]() { this->Stop(); };

      Log::Info("Engine initialized.");

      return true;
    }
    void Start() {
      Log::Info("Starting engine...");

      Input::GetInstance().Init();
      Input::GetInstance().FindControllers();

      running = true;

      (*lua)["init"] = []() {};
      (*lua)["input"] = [](sol::table) {};
      (*lua)["update"] = [](float) {};
      (*lua)["draw"] = []() {};

      lua->safe_script_file("main.lua");
      (*lua)["init"]();
    }
    void Stop() {
      Log::Info("Stopping engine...");
      Graphics::Destroy();
      running = false;
      Log::Info("Engine stopped.");
    }
    bool IsRunning() { return running; }
    void HandleEvents() {
      SDL_Event event;

      SDL_PumpEvents();

      while (SDL_PeepEvents(&event, 1, SDL_GETEVENT, SDL_FIRSTEVENT, SDL_LASTEVENT) > 0) {
        switch (event.type) {
          case SDL_QUIT: {
            Stop();
            break;
          }
          case SDL_CONTROLLERDEVICEADDED: {
            break;
          }
          case SDL_CONTROLLERDEVICEREMOVED: {
            break;
          }
          default: {
            Input::GetInstance().HandleEvent(&event);
            break;
          }
        }
      }
    }
    void Update() {
      last = now;
      now = SDL_GetPerformanceCounter();
      float dt = static_cast<float>(
        (now - last) * 1000 / static_cast<float>(
          SDL_GetPerformanceFrequency()
        )
      ) * 0.001;

      (*lua)["update"](dt);
    }
    void Draw() {
      Graphics::PreDraw();
      (*lua)["draw"]();
      Graphics::PostDraw();
    }

   public:
    static Engine& GetInstance() {
      if (instance == nullptr)
        instance = new Engine;
      return *instance;
    }
    Engine(const Engine&) = delete;
    Engine& operator=(const Engine&) = delete;

   private:
    Engine() {
      running = false;
      lua = Lua::GetInstance().GetState();
      now = SDL_GetPerformanceCounter();
      last = 0;
    }
    ~Engine() { if (running) Stop(); }

   private:
    bool running;
    sol::state* lua;
    Uint64 last;
    Uint64 now;
    inline static Engine* instance = nullptr;
  };
};

#endif // SCARLET_HPP
