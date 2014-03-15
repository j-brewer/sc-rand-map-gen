// ***************************************************************************************
// * Supreme Commander Random Map Generator
// * Copyright 2014  Jonathan Brewer
// * Filename: PreviewBuilder.cs
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
using System.IO.Compression;

public class PreviewBuilder
{
    private Tileset ts;
    private HeightMap hm;
    private Bitmap tmA;
    private Bitmap tmB;
    private WaterShader wd;
    private Color[] stratumColors = new Color[9];
    private Color waterColor;
    public PreviewBuilder(HeightMap h, Tileset t, Bitmap textureMapA, Bitmap textureMapB, WaterShader w, Device Device)
    {
        hm = h;
        ts = t;
        tmA = textureMapA;
        tmB = textureMapB;
        wd = w;
        stratumColors = LoadTextureColors(Device);

        //Water Color
        Color wc = default(Color);
        double waterRedAverage = (((1.0 - wd.ColorLerp.Y) * Convert.ToInt32(Color.Navy.R)) + (wd.ColorLerp.Y * wd.SurfaceColor.X * 255));
        double waterGreenAverage = (((1.0 - wd.ColorLerp.Y) * Convert.ToInt32(Color.Navy.G)) + (wd.ColorLerp.Y * wd.SurfaceColor.Y * 255));
        double waterBlueAverage = (((1.0 - wd.ColorLerp.Y) * Convert.ToInt32(Color.Navy.B)) + (wd.ColorLerp.Y * wd.SurfaceColor.Z * 255));
        waterColor = Color.FromArgb(255, (int)waterRedAverage, (int)waterGreenAverage, (int)waterBlueAverage);
    }
    public SlimDX.Direct3D9.Texture GetMapPreviewTexture(Device Device)
    {
        Bitmap bm = new Bitmap(hm.Height - 1, hm.Width - 1);
        for (int i = 0; i <= bm.Height - 1; i++)
        {
            for (int j = 0; j <= bm.Width - 1; j++)
            {
                bm.SetPixel(j, i, GetMapColorAtPosition(j, i));
            }
        }
        Bitmap bm2 = new Bitmap(256, 256);
        Graphics g = Graphics.FromImage(bm2);
        g.DrawImage(bm, 0, 0, 256, 256);

        MemoryStream ms = new MemoryStream();
        bm2.Save(ms, ImageFormat.Png);
        ms.Seek(0, SeekOrigin.Begin);
        return SlimDX.Direct3D9.Texture.FromStream(Device, ms, bm2.Width, bm2.Height, 1, Usage.None, Format.A8R8G8B8, Pool.Scratch, Filter.Linear, Filter.Linear, 0);
    }
    private Color GetMapColorAtPosition(int x, int y)
    {
        Color c = tmA.GetPixel(x / 2, y / 2);
        Color c2 = tmB.GetPixel(x / 2, y / 2);

        int remAlpha = 255;
        byte[] s = new byte[9];
        s[0] = 255;
        s[1] = c.R;
        s[2] = c.G;
        s[3] = c.B;
        s[4] = c.A;
        s[5] = c2.R;
        s[6] = c2.G;
        s[7] = c2.B;
        s[8] = c2.A;

        byte layerAlpha = 0;
        double redAverage = 0;
        double blueAverage = 0;
        double greenAverage = 0;

        
        if (hm.GetFAHeight(x, y) <= wd.Elevation)
        {
            int waterAlpha = (int)(127 + (((wd.Elevation - hm.GetFAHeight(x, y)) / wd.Elevation) * 128.0));
            redAverage = redAverage + waterAlpha * waterColor.R;
            greenAverage = greenAverage + waterAlpha * waterColor.G;
            blueAverage = blueAverage + waterAlpha * waterColor.B;
            remAlpha = remAlpha - waterAlpha;
        }

        //Texture Colors
        for (int i = 8; i >= 0; i += -1)
        {
            if (remAlpha > 0)
            {
                layerAlpha = (byte)Math.Min(s[i], remAlpha);
                remAlpha = remAlpha - s[i];
            }
            else
            {
                layerAlpha = 0;
            }
            redAverage = redAverage + Convert.ToDouble(layerAlpha) * stratumColors[i].R;
            greenAverage = greenAverage + Convert.ToDouble(layerAlpha) * stratumColors[i].G;
            blueAverage = blueAverage + Convert.ToDouble(layerAlpha) * stratumColors[i].B;
            if (remAlpha <= 0)
            {
                break;
            }
        }

        Color rt = Color.FromArgb(255, (int)(redAverage / 255), (int)(greenAverage / 255), (int)(blueAverage / 255));
        return rt;
    }
    private Color[] LoadTextureColors(SlimDX.Direct3D9.Device Device)
    {
        Color[] rt = new Color[9];
        string env = "C:\\Program Files (x86)\\THQ\\Gas Powered Games\\Supreme Commander - Forged Alliance\\gamedata\\env.scd";
        ZipArchive z = ZipFile.OpenRead(env);
        for (int i = 0; i <= 8; i++)
        {
            string texPath = ts.Stratum[i].PathTexture;
            if (texPath.Length > 0)
            {
                ZipArchiveEntry zae = FindEntry(texPath, z);
                if ((zae != null))
                {
                    SlimDX.Direct3D9.Texture tx = SlimDX.Direct3D9.Texture.FromStream(Device, zae.Open());
                    SlimDX.Direct3D9.Surface s = tx.GetSurfaceLevel(tx.LevelCount - 1);
                    SlimDX.DataStream ms = default(SlimDX.DataStream);
                    ms = SlimDX.Direct3D9.Surface.ToStream(s, ImageFileFormat.Png);
                    ms.Seek(0, SeekOrigin.Begin);
                    Bitmap bm = (Bitmap)Bitmap.FromStream(ms);
                    rt[i] = bm.GetPixel(0, 0);
                }
                else
                {
                    Console.WriteLine("WARNING: Specified texture (\"" + texPath + "\") not found in env.scd.");
                    rt[i] = Color.Black;
                }

            }
        }
        return rt;
    }
    private ZipArchiveEntry FindEntry(string path, ZipArchive za)
    {
        ZipArchiveEntry rt = null;
        System.Collections.ObjectModel.ReadOnlyCollection<ZipArchiveEntry> currEntryList = za.Entries;
        path = path.Remove(0, 1);
        foreach (ZipArchiveEntry entry in za.Entries)
        {
            if (entry.FullName.Equals(path, StringComparison.InvariantCultureIgnoreCase))
            {
                rt = entry;
                break;
            }
        }
        return rt;
    }
}