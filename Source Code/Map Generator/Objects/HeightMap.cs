// ***************************************************************************************
// * Supreme Commander Random Map Generator
// * Copyright 2014  Jonathan Brewer
// * Filename: HeightMap.cs
// ***************************************************************************************
// * 
// * This program is free software; you can redistribute it and/or modify
// * it under the terms of the GNU General Public License as published by
// * the Free Software Foundation; either version 3 of the License, or
// * (at your option) any later version.
// * 
// * This program is distributed in the hope that it will be useful,
// * but WITHOUT ANY WARRANTY; without even the implied warranty of
// * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// * GNU General Public License for more details.
// *
// * You should have received a copy of the GNU General Public License
// * along with this program; if not, write to the Free Software Foundation,
// * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
// ***************************************************************************************


using System;
using System.Drawing;

public class HeightMap
{
    private ushort[,] heightMapData;
    private int mapHeight;
    private int mapWidth;
    private ushort maxValue;
    public HeightMap(int sizeX, int sizeY)
    {
        heightMapData = new ushort[sizeX + 1, sizeY + 1];
        mapHeight = sizeY;
        mapWidth = sizeX;
        maxValue = 0;
    }
    public int Height
    {
        get { return mapHeight; }
    }
    public int Width
    {
        get { return mapWidth; }
    }
    public void SetHeight(int posX, int posY, ushort val)
    {
        if (posX > mapWidth | posY > mapHeight | posX < 0 | posY < 0)
        {
            throw new IndexOutOfRangeException();
        }
        else
        {
            heightMapData[posX, posY] = val;
            if ((val > maxValue))
            {
                maxValue = val;
            }
        }
    }
    public ushort GetHeight(int posX, int posY)
    {
        if (posX > mapWidth | posY > mapHeight | posX < 0 | posY < 0)
        {
            throw new IndexOutOfRangeException();
        }
        else
        {
            return heightMapData[posX, posY];
        }
    }
    public ushort MaximumHeightValue
    {
        get { return maxValue; }
    }
    public Bitmap CreateBitmap()
    {
        Bitmap b = new Bitmap(mapWidth, mapHeight);
        for (int i = 0; i <= mapHeight - 1; i++)
        {
            for (int j = 0; j <= mapWidth - 1; j++)
            {
                double v = GetHeight(j, i);
                byte a = (byte)((v / maxValue) * 255);
                Color c = default(Color);
                c = Color.FromArgb(255, a, a, a);
                b.SetPixel(j, i, c);
            }
        }
        return b;
    }
    public void MultiplyScalar(double s)
    {
        for (int i = 0; i <= mapHeight - 1; i++)
        {
            for (int j = 0; j <= mapWidth - 1; j++)
            {
                SetHeight(j, i, Convert.ToUInt16(s * GetHeight(j, i)));
            }
        }
    }
    public double Gradient(int posX, int posY)
    {
        if (posX > mapWidth | posY > mapHeight | posX < 0 | posY < 0)
        {
            throw new IndexOutOfRangeException();
        }
        else if (this.Width < 3 | this.Height < 3)
        {
            throw new Exception("Cannot perform a gradient operation on a heightmap with width or height less than three.");
        }
        else
        {
            int[] SobelX = {-1,0,1,-2,0,2,-1,0,1};
            int[] SobelY = {1,2,1,0,0,0,-1,-2,-1};

            int aX = -1;
            int aY = -1;
            int bX = 1;
            int bY = 1;
            if (posX == 0)
            {
                aX = 0;
            }
            if (posY == 0)
            {
                aY = 0;
            }

            if (posX == this.Width)
            {
                bX = 0;
            }
            if (posY == this.Height)
            {
                bY = 0;
            }

            int[] target = new int[9];
            target[0] = this.GetHeight(posX + aX, posY + aY);
            target[1] = this.GetHeight(posX, posY + aY);
            target[2] = this.GetHeight(posX + bX, posY + aY);
            target[3] = this.GetHeight(posX + aX, posY);
            target[4] = this.GetHeight(posX, posY);
            target[5] = this.GetHeight(posX + bX, posY);
            target[6] = this.GetHeight(posX + aX, posY + bY);
            target[7] = this.GetHeight(posX, posY + bY);
            target[8] = this.GetHeight(posX + bX, posY + bY);

            double resultX = 0;
            double resultY = 0;
            for (int i = 0; i <= 8; i++)
            {
                resultX = resultX + SobelX[i] * target[i];
                resultY = resultY + SobelY[i] * target[i];
            }
            resultX = resultX / 8;
            resultY = resultY / 8;
            return Math.Atan2(resultY, resultX);
        }
    }
    public double GetFAHeight(int x, int y)
    {
        return (Convert.ToDouble(this.GetHeight(x, y)) / 16384.0) * 127.0;
    }
}