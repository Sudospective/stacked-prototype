#ifndef GIZMOS_HPP
#define GIZMOS_HPP

#include "gizmos/gizmo.hpp"

#include "gizmos/label.hpp"
#include "gizmos/sound.hpp"
//#include "gizmos/sprite.hpp"
#include "gizmos/quad.hpp"

void registerGizmos(sol::state* lua) {
  sol::usertype<Gizmo> luaGizmo = lua->new_usertype<Gizmo>("Gizmo");
  luaGizmo["name"] = &Gizmo::name;
  luaGizmo["aux"] = &Gizmo::aux;
  luaGizmo["x"] = &Gizmo::x;
  luaGizmo["y"] = &Gizmo::y;
  luaGizmo["Draw"] = &Gizmo::Draw;

  sol::usertype<Quad> luaQuad = lua->new_usertype<Quad>("Quad");
  luaQuad["name"] = &Quad::name;
  luaQuad["aux"] = &Quad::aux;
  luaQuad["color"] = &Quad::color;
  luaQuad["x"] = &Quad::x;
  luaQuad["y"] = &Quad::y;
  luaQuad["w"] = &Quad::w;
  luaQuad["h"] = &Quad::h;
  luaQuad["rot"] = &Quad::rot;
  luaQuad["Draw"] = &Quad::Draw;

  sol::usertype<Sound> luaSound = lua->new_usertype<Sound>("Sound");
  luaSound["name"] = &Sound::name;
  luaSound["aux"] = &Sound::aux;
  luaSound["x"] = &Sound::x;
  luaSound["y"] = &Sound::y;
  luaSound["LoadSource"] = &Sound::LoadSource;
  luaSound["Play"] = &Sound::Play;
  luaSound["SetPosition"] = &Sound::SetPosition;
  luaSound["volume"] = sol::property(&Sound::GetVolume, &Sound::SetVolume);

  /*
  sol::usertype<Sprite> luaSprite = lua->new_usertype<Sprite>("Sprite");
  luaSprite["name"] = &Sprite::name;
  luaSprite["aux"] = &Sprite::aux;
  luaSprite["color"] = &Sprite::color;
  luaSprite["x"] = &Sprite::x;
  luaSprite["y"] = &Sprite::y;
  luaSprite["w"] = &Sprite::w;
  luaSprite["h"] = &Sprite::h;
  luaSprite["rot"] = &Sprite::rot;
  luaSprite["Draw"] = &Sprite::Draw;
  luaSprite["LoadTexture"] = &Sprite::LoadTexture;
  */

  sol::usertype<Label> luaLabel = lua->new_usertype<Label>("Label");
  luaLabel["name"] = &Label::name;
  luaLabel["aux"] = &Label::aux;
  luaLabel["color"] = &Label::color;
  luaLabel["x"] = &Label::x;
  luaLabel["y"] = &Label::y;
  luaLabel["w"] = sol::readonly(&Label::w);
  luaLabel["h"] = sol::readonly(&Label::h);
  luaLabel["rot"] = &Label::rot;
  luaLabel["align"] = &Label::align;
  luaLabel["Draw"] = &Label::Draw;
  luaLabel["LoadFont"] = &Label::LoadFont;
  luaLabel["text"] = sol::property(&Label::GetText, &Label::SetText);
}

#endif // GIZMOS_HPP
