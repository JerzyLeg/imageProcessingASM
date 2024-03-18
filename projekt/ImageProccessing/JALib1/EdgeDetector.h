#pragma once
#include <iostream>
#include <vector>

struct RColor {
    unsigned char r;
    RColor() : r(0) {}
};

extern "C" 
{
    __declspec(dllexport)  void applyColorR(RColor* inputImage, int width, int height, unsigned char* outputImage);
}