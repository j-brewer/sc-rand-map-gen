// ***************************************************************************************
// * Supreme Commander Random Map Generator
// * Copyright 2014  Jonathan Brewer
// * Filename: WaterMapBuilder.cs
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
using System.IO;

public class WaterMapBuilder
{
    public static SlimDX.Direct3D9.Texture BuildWaterMap(HeightMap h, WaterShader w, SlimDX.Direct3D9.Device Device)
    {
        Bitmap wt = BuildWaterMap(h, w);
        MemoryStream ms = new MemoryStream();
        wt.Save(ms, ImageFormat.Png);
        ms.Seek(0, SeekOrigin.Begin);

        return SlimDX.Direct3D9.Texture.FromStream(Device, ms, wt.Width, wt.Height, 1, Usage.None, Format.Dxt5, Pool.Scratch, Filter.None, Filter.None, 0);
    }
    private static Bitmap BuildWaterMap(HeightMap h, WaterShader w)
    {
        Bitmap rt = new Bitmap(Convert.ToInt32((h.Height - 1) / 2), Convert.ToInt32((h.Width - 1) / 2));
        int a = 0;
        int r = 255;
        int g = 0;
        int b = 255;
        Color c = default(Color);

        if (!w.HasWater)
        {
            for (int i = 0; i <= rt.Height - 1; i++)
            {
                for (int j = 0; j <= rt.Width - 1; j++)
                {
                    c = Color.FromArgb(a, r, g, b);
                    rt.SetPixel(j, i, c);
                }
            }
        }
        else
        {
            double scale = 255 / w.Elevation;

            for (int i = 0; i <= rt.Height - 1; i++)
            {
                for (int j = 0; j <= rt.Width - 1; j++)
                {
                    //Bilinear downsample
                    int x = j * 2;
                    int y = i * 2;
                    double e1 = h.GetFAHeight(x, y);
                    double e2 = h.GetFAHeight(x + 1, y);
                    double e3 = h.GetFAHeight(x, y + 1);
                    double e4 = h.GetFAHeight(x + 1, y + 1);
                    float e = (float)((e1 + e2 + e3 + e4) / 4.0);

                    if (e > w.Elevation)
                    {
                        g = 0;
                        b = 255;
                    }
                    else
                    {
                        b = 0;
                        g = (int)((w.Elevation - e) * scale);
                    }

                    c = Color.FromArgb(a, r, g, b);
                    rt.SetPixel(j, i, c);
                }
            }
        }
        return rt;
    }
}
