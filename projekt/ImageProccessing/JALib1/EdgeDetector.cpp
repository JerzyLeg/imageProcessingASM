#include "pch.h"
#include "EdgeDetector.h"

/*
 * *****************************************************************************
 * Temat: Sobel operator
 * Semestr: Zimowy, Rok: 2023/2024
 * Autor: Jerzy Legaszewski
 *
 * Algorytm s³u¿y do wykrywania krawêdzi. Sk³ada siê z 3 procedur:
 * 1) obliczeniu gradientu poziomego
 *
 *         |1  0  -1|
 *    Gx = |2  0  -2| * A
 *         |1  0  -1|
 *
 *   Procedura w c++: horizontalGradientColorR
 *
 * 2) obliczenie gradientu pionowego
 *
 *         | 1  2  1|
 *    Gy = | 0  0  0| * A
 *         |-1 -2 -1|
 *
 *   Procedura w c++: verticalGradientColorR
 *
 * 3) obliczenie gradientu wynikowego
 *
 *    G = |Gx| + |Gy|
 *
 *   Procedura w c++: applyColorR
 * 
 * 
 * *****************************************************************************
 */

int horizontalGradientColorR(const RColor* image, int width, int height, int x, int y) {
    int gx = (-1 * image[(y - 1) * width + x - 1].r) + (1 * image[(y - 1) * width + x + 1].r) +
        (-2 * image[y * width + x - 1].r) + (2 * image[y * width + x + 1].r) +
        (-1 * image[(y + 1) * width + x - 1].r) + (1 * image[(y + 1) * width + x + 1].r);

    return gx;
}

int verticalGradientColorR(const RColor* image, int width, int height, int x, int y)
{
    int gy = (-1 * image[(y - 1) * width + x - 1].r) + (-2 * image[(y - 1) * width + x].r) + (-1 * image[(y - 1) * width + x + 1].r) +
        (1 * image[(y + 1) * width + x - 1].r) + (2 * image[(y + 1) * width + x].r) + (1 * image[(y + 1) * width + x + 1].r);

    return gy;
}

void applyColorR(RColor* image, int width, int height, unsigned char* outputImage) {
    for (int y = 1; y < height - 1; y++) {
        for (int x = 1; x < width - 1; x++) {
            int gx = (-1 * image[(y - 1) * width + x - 1].r) + (1 * image[(y - 1) * width + x + 1].r) +
                (-2 * image[y * width + x - 1].r) + (2 * image[y * width + x + 1].r) +
                (-1 * image[(y + 1) * width + x - 1].r) + (1 * image[(y + 1) * width + x + 1].r);

            int gy = (-1 * image[(y - 1) * width + x - 1].r) + (-2 * image[(y - 1) * width + x].r) + (-1 * image[(y - 1) * width + x + 1].r) +
                (1 * image[(y + 1) * width + x - 1].r) + (2 * image[(y + 1) * width + x].r) + (1 * image[(y + 1) * width + x + 1].r);

            int gradient = std::abs(gx) + std::abs(gy);
            // Ogranicz gradient do zakresu 0-255
            gradient = min(255, max(0, gradient));

            // Zapisz wynik do obrazu wyjœciowego
            outputImage[y * width + x] = gradient;
        }
    }
}