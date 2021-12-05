#include <iostream>
#include "SDL.h"

int main(int arc, char* argv[])
{
    if (SDL_Init(SDL_INIT_VIDEO) != 0)
    {
        std::cout << "SDL_Init Error: " << SDL_GetError() << std::endl;
        return 1;
    }
    else
    {
        std::cout << "Hello World!!";
    }
    SDL_Quit();
    return 0;
}
