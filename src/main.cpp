#define SDL_MAIN_HANDLED

#include "gizmos.hpp"
#include "scarlet.hpp"

using namespace Scarlet;

SDL_mutex* mutex = nullptr;

int handleUpdate(void*) {
  /*
  SDL_LockMutex(mutex);
  SDL_GL_MakeCurrent(Graphics::GetMainWindow(), Graphics::GetGLContext());
  SDL_UnlockMutex(mutex);
  */
  while (true) {
    SDL_LockMutex(mutex);
    if (!Engine::GetInstance().IsRunning()) {
      SDL_UnlockMutex(mutex);
      break;
    }
    Engine::GetInstance().Update();
    SDL_UnlockMutex(mutex);
    SDL_Delay(0);
  }
  return 0;
}

int main(int argc, char* argv[]) {
  std::cout << "----------------------" << std::endl;
  std::cout << "--- SCARLET ENGINE ---" << std::endl;
  std::cout << "----------------------" << std::endl;
  
  sol::state* lua = Lua::GetInstance().GetState();

  registerGizmos(lua);

  if (Engine::GetInstance().Init("STACKED", 640, 360)) {
    Engine::GetInstance().Start();
  }

  mutex = SDL_CreateMutex();

  SDL_Thread* updateThread = SDL_CreateThread(handleUpdate, "UpdateThread", nullptr);

  while (true) {
    SDL_LockMutex(mutex);
    if (!Engine::GetInstance().IsRunning()) {
      SDL_UnlockMutex(mutex);
      break;
    }
    Engine::GetInstance().HandleEvents();
    Engine::GetInstance().Draw();
    SDL_UnlockMutex(mutex);
    SDL_Delay(0);
  }

  SDL_WaitThread(updateThread, nullptr);
  SDL_DestroyMutex(mutex);

  return 0;
}
