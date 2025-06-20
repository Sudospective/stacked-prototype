cmake_minimum_required(VERSION 3.25)

project(stacked)

set(CMAKE_CXX_STANDARD 20)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

find_package(Lua 5.4 REQUIRED)
find_package(SDL2 REQUIRED)
find_package(SDL2_mixer REQUIRED)
find_package(SDL2_ttf REQUIRED)
find_package(sol2 REQUIRED)

set(MAIN_SRC "${CMAKE_SOURCE_DIR}/src")
set(MAIN_INC "${CMAKE_SOURCE_DIR}/include")

add_definitions(-DLUA)

add_subdirectory(src)

target_include_directories(${PROJECT_NAME} PUBLIC
  ${MAIN_SRC}
  ${MAIN_INC}

  ${LUA_INCLUDE_DIR}
)

target_link_libraries(${PROJECT_NAME} PRIVATE
  SDL2::SDL2
  SDL2_mixer::SDL2_mixer
  SDL2_ttf::SDL2_ttf
  sol2::sol2

  ${LUA_LIBRARY}
)
