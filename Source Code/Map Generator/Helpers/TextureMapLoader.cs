// ***************************************************************************************
// * Supreme Commander Random Map Generator
// * Copyright 2014  Jonathan Brewer
// * Filename: MapGenerator.cs
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




using SlimDX.Direct3D9;
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Globalization;
using System.IO;
public class TexturemapLoader
{
    public Bitmap LowerStratumBitmap;
    public Bitmap UpperStratumBitmap;
    public SlimDX.Direct3D9.Texture LowerStratumTexture;
    public SlimDX.Direct3D9.Texture UpperStratumTexture;

    public TexturemapLoader()
    {
    }
    public void LoadTextureMap(Device device, string inputPath, Point strataSize)
    {
        SlimDX.Direct3D9.Texture[] arr = new SlimDX.Direct3D9.Texture[2];

        LowerStratumBitmap = LoadTextureBitmap(inputPath, strataSize, 0);
        MemoryStream ms = new MemoryStream();
        LowerStratumBitmap.Save(ms, ImageFormat.Png);
        ms.Seek(0, SeekOrigin.Begin);
        LowerStratumTexture = SlimDX.Direct3D9.Texture.FromStream(device, ms, LowerStratumBitmap.Width, LowerStratumBitmap.Height, 0, Usage.None, Format.A8R8G8B8, Pool.Scratch, Filter.Linear, Filter.Linear, 0);


        UpperStratumBitmap = LoadTextureBitmap(inputPath, strataSize, 4);
        MemoryStream ms2 = new MemoryStream();
        UpperStratumBitmap.Save(ms2, ImageFormat.Png);
        ms2.Seek(0, SeekOrigin.Begin);
        UpperStratumTexture = SlimDX.Direct3D9.Texture.FromStream(device, ms2, UpperStratumBitmap.Width, UpperStratumBitmap.Height, 0, Usage.None, Format.A8R8G8B8, Pool.Scratch, Filter.Linear, Filter.Linear, 0);
    }
    private static Bitmap LoadTextureBitmap(string inputPath, Point strataSize, int startPoint)
    {
        HeightMap[] tArr = new HeightMap[4];
        for (int i = 0; i <= 3; i++)
        {
            try
            {
                tArr[i] = HeightMapLoader.LoadHeightmapWithNoExtension(inputPath + "\\Stratum" + (i + startPoint + 1).ToString(CultureInfo.InvariantCulture));
                if (!(tArr[i].Height == strataSize.Y) | !(tArr[i].Width == strataSize.X))
                {
                    throw new InvalidDataException("Stratum " + (i + startPoint + 1) + " dimensions do not match those provided.");
                }
            }
            catch (FileNotFoundException)
            { 
                tArr[i] = new HeightMap(strataSize.X, strataSize.Y);
            }
        }
        return CombineTextureMaps(tArr[0], tArr[1], tArr[2], tArr[3]);
    }
    private static Bitmap CombineTextureMaps(HeightMap t1, HeightMap t2, HeightMap t3, HeightMap t4)
    {
        Bitmap rt = new Bitmap(t1.Height, t1.Width);
        for (int i = 0; i <= t1.Height - 1; i++)
        {
            for (int j = 0; j <= t1.Width - 1; j++)
            {
                int r = ConvertHeightToByteValue(t1.GetHeight(j, i), 16384);
                int g = ConvertHeightToByteValue(t2.GetHeight(j, i), 16384);
                int b = ConvertHeightToByteValue(t3.GetHeight(j, i), 16384);
                int a = ConvertHeightToByteValue(t4.GetHeight(j, i), 16384);

                Color c = default(Color);
                c = Color.FromArgb(a, r, g, b);
                rt.SetPixel(j, i, c);
            }
        }
        return rt;
    }
    private static int ConvertHeightToByteValue(int value, int maxValue)
    {
        return Convert.ToInt32((Convert.ToDouble(value) / Convert.ToDouble(maxValue)) * 255);
    }
}
