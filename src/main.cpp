#define SDL_MAIN_HANDLED

#include "gizmos.hpp"
#include "scarlet.hpp"

using namespace Scarlet;

SDL_mutex* mutex = nullptr;

//*
int handleUpdate(void*) {
  while (true) {
    SDL_LockMutex(mutex);
    if (!Engine::GetInstance().IsRunning()) {
      SDL_UnlockMutex(mutex);
      break;
    }
    Engine::GetInstance().Update();
    Engine::GetInstance().Draw();
    SDL_UnlockMutex(mutex);
    SDL_Delay(1);
  }
  return 0;
}
//*/

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
    SDL_UnlockMutex(mutex);
    SDL_Delay(1);
  }

  SDL_WaitThread(updateThread, nullptr);
  SDL_DestroyMutex(mutex);

  return 0;
}
