// ***************************************************************************************
// * Supreme Commander Random Map Generator
// * Copyright 2014  Jonathan Brewer
// * Filename: TerrainTypeBuilder.cs
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


using System.Collections.Generic;
using System.Drawing;

public class TerrainTypeBuilder
{
    private Tileset ts;
    private HeightMap hm;
    private Bitmap texMapA;
    private Bitmap texMapB;
    private float waterSurface;
    private float waterShore;
    private float waterDeep;
    private List<TerrainType> TextureTypeList;
    private List<EnvironmentType> EnvTypeList;
    public TerrainTypeBuilder(HeightMap h, Tileset t, Bitmap textureMapA, Bitmap textureMapB, float waterSurfaceElevation, float shoreDepth, float deepWater)
    {
        hm = h;
        ts = t;
        texMapA = textureMapA;
        texMapB = textureMapB;
        waterSurface = waterSurfaceElevation;
        waterShore = shoreDepth;
        waterDeep = deepWater;



        TextureTypeList = new List<TerrainType>();
        EnvTypeList = new List<EnvironmentType>();
        for (int i = 0; i <= ts.Stratum.Count - 1; i++)
        {
            TextureTypeList.Add(GetTextureTerrainType(ts.Stratum[i]));
            EnvTypeList.Add(GetTextureEnvironmentType(ts.Stratum[i]));
        }
    }
    public byte[] GetTerrainTypeData()
    {
        byte[] rt = new byte[(hm.Width - 1) * (hm.Height - 1)];
        int idx = 0;
        for (int i = 0; i <= hm.Height - 2; i++)
        {
            for (int j = 0; j <= hm.Width - 2; j++)
            {
                rt[idx] = FindTerrainTypeValue(j, i);
                idx += 1;
            }
        }
        return rt;
    }
    private byte FindTerrainTypeValue(int x, int y)
    {
        byte rt = 1;
        float e = (float)hm.GetFAHeight(x, y);

        if (e <= waterSurface)
        {
            rt = GetWaterTerrainType(EnvTypeList[0], e);
        }
        else
        {
            int priStratum = GetPrimaryStratumAtPosition(x, y);
            EnvironmentType environmentType = EnvTypeList[priStratum];
            TerrainType s = TextureTypeList[priStratum];

            if (s == TerrainType.Rock)
            {
                GetRockTerrainType(environmentType);
            }
            else if (s == TerrainType.Vegetation)
            {
                GetVegetationTerrainType(environmentType);
            }
            else if (s == TerrainType.Sand)
            {
                GetSandTerrainType(environmentType);
            }
            else if (s == TerrainType.Dirt)
            {
                GetDirtTerrainType(environmentType);
            }
            else if (s == TerrainType.Snow)
            {
                GetSnowTerrainType(environmentType);
            }
            else if (s == TerrainType.Lava)
            {
                GetLavaTerrainType(environmentType);
            }
        }
        return rt;
    }
    private byte GetWaterTerrainType(EnvironmentType envType, float e)
    {
        if (envType == EnvironmentType.Evergreen)
        {
            if (e < waterDeep)
            {
                return 222;
            }
            else if (e < waterShore)
            {
                return 223;
            }
            else
            {
                return 221;
            }
        }
        else if (envType == EnvironmentType.Redrock)
        {
            if (e < waterShore)
            {
                return 225;
            }
            else
            {
                return 224;
            }
        }
        else if (envType == EnvironmentType.Tropical)
        {
            if (e < waterDeep)
            {
                return 229;
            }
            else if (e < waterShore)
            {
                return 227;
            }
            else
            {
                return 226;
            }
        }
        else if (envType == EnvironmentType.Tundra)
        {
            if (e < waterDeep)
            {
                return 234;
            }
            else if (e < waterShore)
            {
                return 235;
            }
            else
            {
                return 233;
            }
        }
        else if (envType == EnvironmentType.Lava)
        {
            if (e < waterShore)
            {
                return 237;
            }
            else
            {
                return 236;
            }
        }
        else if (envType == EnvironmentType.Geothermal)
        {
            if (e < waterDeep)
            {
                return 239;
            }
            else if (e < waterShore)
            {
                return 240;
            }
            else
            {
                return 238;
            }
        }
        else if (envType == EnvironmentType.Desert)
        {
            if (e < waterShore)
            {
                return 232;
            }
            else
            {
                return 231;
            }
        }
        return 220;
    }
    private byte GetRockTerrainType(EnvironmentType envType)
    {
        byte rt = 150;
        if (envType == EnvironmentType.Evergreen)
        {
            rt = 152;
        }
        else if (envType == EnvironmentType.Redrock)
        {
            rt = 154;
        }
        else if (envType == EnvironmentType.Tropical)
        {
            rt = 160;
        }
        else if (envType == EnvironmentType.Tundra)
        {
            rt = 153;
        }
        else if (envType == EnvironmentType.Lava)
        {
            rt = 157;
        }
        else if (envType == EnvironmentType.Geothermal)
        {
            rt = 162;
        }
        else if (envType == EnvironmentType.Desert)
        {
            rt = 155;
        }
        return rt;
    }
    private byte GetVegetationTerrainType(EnvironmentType envType)
    {
        byte rt = 80;
        if (envType == EnvironmentType.Evergreen)
        {
            rt = 83;
        }
        else if (envType == EnvironmentType.Tropical)
        {
            rt = 84;
        }
        return rt;
    }
    private byte GetSandTerrainType(EnvironmentType envType)
    {
        byte rt = 40;
        if (envType == EnvironmentType.Evergreen)
        {
            rt = 41;
        }
        return rt;
    }
    private byte GetDirtTerrainType(EnvironmentType envType)
    {
        byte rt = 2;
        if (envType == EnvironmentType.Evergreen)
        {
            rt = 3;
        }
        else if (envType == EnvironmentType.Redrock)
        {
            rt = 5;
        }
        else if (envType == EnvironmentType.Desert)
        {
            rt = 7;
        }
        return rt;
    }
    private byte GetSnowTerrainType(EnvironmentType envType)
    {
        byte rt = 200;
        return rt;
    }
    private byte GetLavaTerrainType(EnvironmentType envType)
    {
        byte rt = 230;
        return rt;
    }
    private int GetPrimaryStratumAtPosition(int x, int y)
    {
        Color c = texMapA.GetPixel(x / 2, y / 2);
        Color c2 = texMapB.GetPixel(x / 2, y / 2);
        byte[] s = new byte[8];
        s[0] = c.R;
        s[1] = c.B;
        s[2] = c.G;
        s[3] = c.A;
        s[4] = c2.R;
        s[5] = c2.B;
        s[6] = c2.G;
        s[7] = c2.A;

        int priTexIdx = -1;
        for (int i = 7; i >= 0; i += -1)
        {
            if (s[i] > 127)
            {
                priTexIdx = i;
                break;
            }
        }
        priTexIdx = priTexIdx + 1;
        return priTexIdx;
    }
    private TerrainType GetTextureTerrainType(Layer layer)
    {
        string s = layer.PathTexture;
        if (s.Contains("rock") | s.Contains("gravel"))
        {
            return TerrainType.Rock;
        }
        else if (s.Contains("grass") | s.Contains("bush") | s.Contains("moss") | s.Contains("trans"))
        {
            return TerrainType.Vegetation;
        }
        else if (s.Contains("sand"))
        {
            return TerrainType.Sand;
        }
        else if (s.Contains("dirt"))
        {
            return TerrainType.Dirt;
        }
        else if (s.Contains("snow") | s.Contains("ice"))
        {
            return TerrainType.Snow;
        }
        else if (s.Contains("lava"))
        {
            return TerrainType.Lava;
        }
        return TerrainType.DefaultTerrain;
    }
    private EnvironmentType GetTextureEnvironmentType(Layer layer)
    {
        EnvironmentType rt = EnvironmentType.DefaultEnvironment;
        string s = layer.PathTexture;
        if (s.Length > 0)
        {
            int d1 = s.IndexOf("/", 1);
            int d2 = s.IndexOf("/", d1 + 1);
            if (d1 > 0 & d2 > 0)
            {
                string envType = s.Substring(d1 + 1, (d2 - d1) - 1).ToLowerInvariant();

                if (envType == "evergreen2" | envType == "evergreen")
                {
                    rt = EnvironmentType.Evergreen;
                }
                else if (envType == "desert")
                {
                    rt = EnvironmentType.Desert;
                }
                else if (envType == "redrock")
                {
                    rt = EnvironmentType.Redrock;
                }
                else if (envType == "geothermal")
                {
                    rt = EnvironmentType.Geothermal;
                }
                else if (envType == "tropical")
                {
                    rt = EnvironmentType.Tropical;
                }
                else if (envType == "tundra")
                {
                    rt = EnvironmentType.Tundra;
                }
                else if (envType == "lava")
                {
                    rt = EnvironmentType.Lava;
                }
            }
        }

        return rt;
    }
}
