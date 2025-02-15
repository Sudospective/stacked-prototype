#ifndef GIZMO_QUAD_HPP
#define GIZMO_QUAD_HPP

#include "scarlet.hpp"

#include "gizmos/gizmo.hpp"

class Quad : public Gizmo {
 public:
  Quad() : Gizmo() {
    sol::state* lua = Scarlet::Lua::GetInstance().GetState();
    color = lua->create_table_with(
      "r", 1.0f,
      "g", 1.0f,
      "b", 1.0f,
      "a", 1.0f
    );

    w = h = 0.0f;
  }
  void Draw() {
    Scarlet::Graphics::DrawQuad(
      x - w * 0.5, y - h * 0.5,
      w, h,
      rot, color
    );
  };

 public:
  float w, h;
};

#endif // GIZMO_QUAD_HPP
