#ifndef GIZMO_LABEL_HPP
#define GIZMO_LABEL_HPP

#include <SDL2/SDL_ttf.h>

#include "scarlet.hpp"

#include "gizmos/gizmo.hpp"

class Label : public Gizmo {
 public:
  Label() : Gizmo() {
    broken = false;
    font = nullptr;

    if (TTF_Init() > 0) {
      Scarlet::Log::Error("Unable to intiailize TTF: " + std::string(TTF_GetError()));
      broken = true;
      return;
    }
    sol::state* lua = Scarlet::Lua::GetInstance().GetState();
    color = lua->create_table_with(
      "r", 1.0f,
      "g", 1.0f,
      "b", 1.0f,
      "a", 1.0f
    );
    align = lua->create_table_with(
      "h", 0.5f,
      "v", 0.5f
    );
  }
  ~Label() {
    if (font)
      TTF_CloseFont(font);
    TTF_Quit();
  }
  void LoadFont(const char* path, int size = 12) {
    if (font)
      TTF_CloseFont(font);
    font = TTF_OpenFont(path, size);
    if (!font) {
      Scarlet::Log::Error("Unable to open font: " + std::string(TTF_GetError()));
      broken = true;
      TTF_CloseFont(font);
    }
  }
  void SetText(const char* newText) {
    text = newText;
  }
  std::string GetText() const {
    return text;
  }
  void Draw() {
    if (broken || !font || text.empty())
      return;
    Scarlet::Graphics::DrawText(
      x, y,
      text.c_str(), font,
      align, rot, color
    );
  }

 public:
  std::string text;
  sol::table align;
  float w, h;

 private:
  bool broken;
  TTF_Font* font;
};

#endif // GIZMO_LABEL_HPP
