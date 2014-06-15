// ***************************************************************************************
// * Supreme Commander Random Map Generator
// * Copyright 2014  Jonathan Brewer
// * Filename: NormalMapBuilder.cs
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
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;

public class NormalMapBuilder
{
    public static SlimDX.Direct3D9.Texture ComputeNormalMap(HeightMap h, Device Device)
    {
        Bitmap map = new Bitmap(h.Width - 1, h.Height - 1);
        int G = 0;
        int A = 0;
        Color clr = default(Color);
        for (int iy = 0; iy <= h.Height - 2; iy++)
        {
            for (int ix = 0; ix <= h.Width - 2; ix++)
            {
                G = 127 + h.GetHeight(ix, iy) - h.GetHeight(ix, iy + 1);
                if ((G < 0))
                {
                    G = 0;
                }
                else if ((G > 255))
                {
                    G = 255;
                }

                A = 127 + h.GetHeight(ix, iy) - h.GetHeight(ix + 1, iy);
                if ((A < 0))
                {
                    A = 0;
                }
                else if ((A > 255))
                {
                    A = 255;
                }
                clr = Color.FromArgb(A, 0, G, 0);
                map.SetPixel(ix, iy, clr);
            }
        }

        MemoryStream ms = new MemoryStream();
        map.Save(ms, ImageFormat.Png);
        ms.Seek(0, SeekOrigin.Begin);

        return SlimDX.Direct3D9.Texture.FromStream(Device, ms, map.Width, map.Height, 1, Usage.None, Format.Dxt5, Pool.Scratch, Filter.None, Filter.None, 0);
    }
}