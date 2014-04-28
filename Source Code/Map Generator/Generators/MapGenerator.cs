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


using SlimDX;
using System;
using System.Drawing;

public class MapGenerator
{
    public static Map GenerateMap(int w, int h, string inputPath, SlimDX.Direct3D9.Device Device, int rngSeed, Tileset ts)
    {
        Random r = new Random(rngSeed);

        //Setup
        Map m = new Map();

        //Dimensions
        m.Width = w;
        m.Height = h;
        m.Initialize();

        //Sun
        Program.timeStamp = DateTime.Now;
        Console.Write("  - Setting Map Values...");
        m.SunColor = GetRandomSunColor(r);
        m.SunDirection = GetRandomSunDirection(r);
        m.SunAmbience = GetRandomSunAmbienceColor(r);

        //Water
        
        m.Water.Elevation = 17.5f;
        m.Water.ElevationDeep = 15f;
        m.Water.ElevationAbyss = 2.5f;
        m.Water.ColorLerp = GetRandomWaterLerpColor(r);
        m.Water.SunColor = new Vector3(1.0f, 1.0f, 1.0f);
        m.Water.SunDirection = m.SunDirection;

        m.Water.SunReflection = GetRandomWaterSunReflection(r);
        m.Water.UnitReflection = m.Water.SunReflection;
        m.Water.SkyReflection = (float)Math.Max(m.Water.SunReflection / 2.0f, 0.25);

        m.Water.SunShininess = GetRandomWaterSunShininess(r);
        m.Water.SunStrength = 12.5f;
        m.Water.SunGlow = 0.5f;

        m.Water.TexPathCubemap = "/textures/engine/waterCubemap.dds";
        m.Water.TexPathWaterRamp = GetWaterRamp(ts.GetBaseTextureEnvironmentType(), r);

        m.Water.SurfaceColor = GetRandomWaterColor(r);
        m.Water.FresnelBias = GetRandomWaterFresnelBias(r);
        m.Water.FresnelPower = 1.0f;

        m.Water.RefractionScale = GetRandomWaterRefractionScale(r);
        m.Water.WaveTextures = GetWaveTextures();

        //Bloom
        m.Bloom = 0.08f;

        //Lighting
        m.LightingMultiplier = GetRandomLightingMultiplier(r);
        m.ShadowFillColor = new Vector3(0, 0, 0);
        m.SpecularColor = GetRandomSpecularColor(r);

        //Fog
        m.FogColor = new Vector3(1, 1, 1);
        m.FogStart = 4000;
        m.FogEnd = 4000;
        Console.WriteLine(" Done. " + Program.GetTimeStampDifference());

        m.TerrainShader = "TTerrainXP";

        //Texture Layers
        m.Layers = ts.Stratum;

        //Environment
        Array.Resize<string>(ref m.EnvCubemapsFile, 1);
        m.EnvCubemapsFile[0] = GetEnvironmentCube(ts.GetBaseTextureEnvironmentType(), r);
        
        Array.Resize<string>(ref m.EnvCubemapsName, 1);
        m.EnvCubemapsName[0] = "<default>";

        //Sky/Background Textures
        m.TexPathBackground = GetBackgroundTexture(ts.GetBaseTextureEnvironmentType(), r);
        m.TexPathSkyCubemap = GetSkyCube(m.EnvCubemapsFile[0]);

        //HeightMap
        Program.timeStamp = DateTime.Now;
        Console.Write("  - Building Height Map...");
        Program.MapHeightData = HeightMapLoader.LoadHeightmapWithNoExtension(inputPath + "\\heightmap");

        for (Int32 ix = 0; ix <= m.Height; ix++)
        {
            for (Int32 iy = 0; iy <= m.Width; iy++)
            {
                m.SetHeight(ix, iy, (short)Program.MapHeightData.GetHeight(ix, iy));
            }
        }
        Console.WriteLine(" Done. " + Program.GetTimeStampDifference());

        //Water Check
        m.Water.HasWater = Program.MapHeightData.MinimumHeightValue < 2240;
        

        Console.Write("  - Building Texture Map...");
        //Texture Maps
        TexturemapLoader tml = new TexturemapLoader();
        tml.LoadTextureMap(Device, inputPath, new Point(m.Width / 2, m.Height / 2));
        m.TexturemapTex = tml.LowerStratumTexture;
        m.TexturemapTex2 = tml.UpperStratumTexture;
        Console.WriteLine(" Done. " + Program.GetTimeStampDifference());

        Console.Write("  - Building Water Map...");
        m.WatermapTex = WaterMapBuilder.BuildWaterMap(Program.MapHeightData, m.Water, Device);
        Console.WriteLine(" Done. " + Program.GetTimeStampDifference());

        Console.Write("  - Building Terrain Type Map...");
        TerrainTypeBuilder ttb = new TerrainTypeBuilder(Program.MapHeightData, ts, tml.LowerStratumBitmap, tml.UpperStratumBitmap, m.Water.Elevation, m.Water.ElevationDeep, m.Water.ElevationAbyss);
        m.TerrainTypeData = ttb.GetTerrainTypeData();
        Console.WriteLine(" Done. " + Program.GetTimeStampDifference());

        Console.Write("  - Building Normal Map...");
        //Normal Map
        m.NormalmapTex = NormalMapBuilder.ComputeNormalMap(Program.MapHeightData, Device);
        Console.WriteLine(" Done. " + Program.GetTimeStampDifference());

        //Preview Texture
        Console.Write("  - Building Map Preview...");
        //m.PreviewTex = GetDummyPreviewTexture(Device)
        PreviewBuilder pb = new PreviewBuilder(Program.MapHeightData, ts, tml.LowerStratumBitmap, tml.UpperStratumBitmap, m.Water, Device);
        m.PreviewTex = pb.GetMapPreviewTexture(Device);
        Console.WriteLine(" Done. " + Program.GetTimeStampDifference());

        if (m.Water.HasWater)
        {
            Console.Write("  - Building Wave Generators...");
            WaveGenGenerator wgb = new WaveGenGenerator(r.Next(), Program.MapHeightData);
            m.WaveGenerators = wgb.BuildWaveGeneratorList(m.Water.Elevation);
            Console.WriteLine(" Done. " + Program.GetTimeStampDifference() + " Created " + m.WaveGenerators.Count + " wave generators.");
        }
        return m;
    }
    private static float GetRandomLightingMultiplier(Random r)
    {
        int a = (int)(r.NextDouble() / 2.0);
        return (float) (0.75 + a);
    }
    private static Vector3 GetRandomSunColor(Random r)
    {
        float a = 1.0f + (float)r.NextDouble();
        return new Vector3(a, a, a);
    }
    private static Vector3 GetRandomSunDirection(Random r)
    {
        double ra = (Convert.ToDouble(r.Next(0, 361)) / 180.0) * Math.PI;
        double dec = (Math.PI / 2) - (Convert.ToDouble(r.Next(20, 40)) / 180.0) * Math.PI;

        float a = (float)(Math.Sin(dec) * Math.Cos(ra));
        float b = (float)(Math.Cos(dec));
        float c = (float)(Math.Sin(dec) * Math.Sin(ra));

        return new Vector3(a, b, c);
    }
    private static Vector3 GetRandomFogColor(Random r)
    {
        return Utilities.GetRandomVector3(r);
    }
    private static Vector3 GetRandomShadowFillColor(Random r)
    {
        return Utilities.GetRandomVector3(r);
    }
    private static Vector4 GetRandomSpecularColor(Random r)
    {
        return Utilities.GetRandomVector4(r);
    }
    private static Vector3 GetRandomSunAmbienceColor(Random r)
    {
        return new Vector3(0.5f, 0.5f, 0.5f);
    }
    private static Vector3 GetRandomWaterColor(Random r)
    {
        return Utilities.GetRandomVector3(r);
    }
    private static Vector2 GetRandomWaterLerpColor(Random r)
    {
        return new Vector2((float)(r.NextDouble() / 2.0), (float)(r.NextDouble() / 2.0));
    }
    private static float GetRandomWaterUnitReflection(Random r)
    {
        return (float)r.NextDouble();
    }
    private static float GetRandomWaterFresnelBias(Random r)
    {
        return (float)r.NextDouble();
    }
    private static float GetRandomWaterFresnelPower(Random r)
    {
        return (float)r.NextDouble() * 2;
    }
    private static float GetRandomWaterSunGlow(Random r)
    {
        return (float)r.NextDouble() / 4;
    }
    private static float GetRandomWaterSunReflection(Random r)
    {
        return (float)r.NextDouble();
    }
    private static float GetRandomWaterSunShininess(Random r)
    {
        return (float)r.NextDouble();
    }
    private static float GetRandomWaterSunStrength(Random r)
    {
        return (float)r.NextDouble() * 20;
    }
    private static float GetRandomWaterSkyReflection(Random r)
    {
        return (float)r.NextDouble() / 50.0f;
    }
    private static float GetRandomWaterRefractionScale(Random r)
    {
        return (float)r.NextDouble() * 3;
    }
    private static WaveTexture[] GetWaveTextures()
    {
        WaveTexture[] rt = new WaveTexture[4];
        rt[0] = new WaveTexture();
        rt[0].NormalMovement = new Vector2(0.5f, -0.95f);
        rt[0].NormalRepeat = 0.0009f;
        rt[0].TexPath = "/textures/engine/waves.dds";

        rt[1] = new WaveTexture();
        rt[1].NormalMovement = new Vector2(0.05f, -0.095f);
        rt[1].NormalRepeat = 0.0009f;
        rt[1].TexPath = "/textures/engine/waves.dds";

        rt[2] = new WaveTexture();
        rt[2].NormalMovement = new Vector2(0.01f, 0.03f);
        rt[2].NormalRepeat = 0.05f;
        rt[2].TexPath = "/textures/engine/waves.dds";

        rt[3] = new WaveTexture();
        rt[3].NormalMovement = new Vector2(0.0005f, 0.0009f);
        rt[3].NormalRepeat = 0.5f;
        rt[3].TexPath = "/textures/engine/waves.dds";
        return rt;
    }
    private static string GetWaterRamp(EnvironmentType envType, Random r)
    {
        string rt = "/textures/engine/waterramp.dds";
        string[] waterEnvArr = null;
        if (envType == EnvironmentType.Desert)
        {
            waterEnvArr = new string[] {
				"/textures/engine/waterramp_desert.dds",
				"/textures/engine/waterramp_desert02.dds",
				"/textures/engine/waterramp_desert03.dds",
				"/textures/engine/waterramp_desert03a.dds"
			};
            rt = Utilities.ChooseRandomString(r, waterEnvArr);
        }
        else if (envType == EnvironmentType.Evergreen)
        {
            waterEnvArr = new string[] {
				"/textures/engine/waterramp_eg.dds",
				"/textures/engine/waterramp_evergreen02.dds"
			};
            rt = Utilities.ChooseRandomString(r, waterEnvArr);
        }
        else if (envType == EnvironmentType.Lava)
        {
            rt = "/textures/engine/waterramp_lava.dds";
        }
        else if (envType == EnvironmentType.Redrock)
        {
            waterEnvArr = new string[] {
				"/textures/engine/waterramp_redrock.dds",
				"/textures/engine/waterramp_redrock01.dds",
				"/textures/engine/waterramp_redrock02.dds",
				"/textures/engine/waterramp_redrock03.dds"
			};
            rt = Utilities.ChooseRandomString(r, waterEnvArr);
        }
        else if (envType == EnvironmentType.Tropical)
        {
            waterEnvArr = new string[] {
				"/textures/engine/waterramp_tropical.dds",
				"/textures/engine/waterramp_tropical02.dds"
			};
            rt = Utilities.ChooseRandomString(r, waterEnvArr);
        }
        else if (envType == EnvironmentType.Tundra)
        {
            rt = "/textures/engine/waterramp_tundra.dds";
        }
        else if (envType == EnvironmentType.Swamp)
        {
            waterEnvArr = new string[] {
				"/textures/engine/waterrampSwamp01.dds",
				"/textures/engine/waterrampSwamp02.dds"
			};
            rt = Utilities.ChooseRandomString(r, waterEnvArr);
        }
        else if (envType == EnvironmentType.Paradise)
        {
            waterEnvArr = new string[] {
				"/textures/engine/waterramp_tropical.dds",
				"/textures/engine/waterramp_tropical02.dds"
			};
            rt = Utilities.ChooseRandomString(r, waterEnvArr);
        }
        return rt;
    }
    private static string GetEnvironmentCube(EnvironmentType envType, Random r)
    {
        string rt = "/textures/environment/defaultenvcube.dds";
        string[] envArr = null;
        if (envType == EnvironmentType.Desert)
        {
            envArr = new string[] {
				"/textures/environment/EnvCube_Desert01a.dds",
				"/textures/environment/EnvCube_Desert02a.dds",
				"/textures/environment/EnvCube_Desert03a.dds"
			};
            rt = Utilities.ChooseRandomString(r, envArr);
        }
        else if (envType == EnvironmentType.Evergreen)
        {
            envArr = new string[] {
				"/textures/environment/EnvCube_Evergreen01a.dds",
				"/textures/environment/EnvCube_Evergreen03a.dds",
				"/textures/environment/EnvCube_Evergreen05a.dds"
			};
            rt = Utilities.ChooseRandomString(r, envArr);
        }
        else if (envType == EnvironmentType.Lava)
        {
            rt = "/textures/environment/EnvCube_Lava01a.dds";
        }
        else if (envType == EnvironmentType.Redrock)
        {
            envArr = new string[] {
				"/textures/environment/EnvCube_RedRocks05a.dds",
				"/textures/environment/EnvCube_RedRocks08a.dds",
				"/textures/environment/EnvCube_RedRocks09a.dds",
				"/textures/environment/EnvCube_RedRocks10.dds"
			};
            rt = Utilities.ChooseRandomString(r, envArr);
        }
        else if (envType == EnvironmentType.Tropical)
        {
            rt = "/textures/environment/EnvCube_Tropical01a.dds";
        }
        else if (envType == EnvironmentType.Tundra)
        {
            envArr = new string[] {
				"/textures/environment/EnvCube_Tundra02a.dds",
				"/textures/environment/EnvCube_Tundra03a.dds",
				"/textures/environment/EnvCube_Tundra04a.dds"
			};
            rt = Utilities.ChooseRandomString(r, envArr);
        }
        else if (envType == EnvironmentType.Geothermal)
        {
            rt = "/textures/environment/EnvCube_Geothermal02a.dds";
        }
        else if (envType == EnvironmentType.Paradise)
        {
            rt = "/textures/environment/EnvCube_Tropical01a.dds";
        }
        return rt;
    }

    private static string GetSkyCube(string EnvCubemapsFile)
    {
        string rt = EnvCubemapsFile.Replace("/Env", "/Sky");
        rt = rt.Replace("defaultenvcube", "defaultskycube");
        return rt;
    }

    private static string GetBackgroundTexture(EnvironmentType envType, Random r)
    {
        string rt = "/textures/environment/defaultbackground.dds";
        string[] bkgArr = null;
        if (envType == EnvironmentType.Desert)
        {
            bkgArr = new string[] {
				"/textures/environment/defaultbackground.dds",
				"/textures/environment/Matar_bmp.dds",
				"/textures/environment/Thiban_bmp.dds",
				"/textures/environment/Zeta Canis_bmp.dds",
				"/textures/environment/Rigel_bmp.dds"
			};
            rt = Utilities.ChooseRandomString(r, bkgArr);
        }
        else if (envType == EnvironmentType.Evergreen)
        {
            bkgArr = new string[] {
				"/textures/environment/Capella_bmp.dds",
				"/textures/environment/defaultbackground.dds",
				"/textures/environment/Minerva_bmp.dds",
				"/textures/environment/Matar_bmp.dds"
			};
            rt = Utilities.ChooseRandomString(r, bkgArr);
        }
        else if (envType == EnvironmentType.Lava)
        {
            bkgArr = new string[] {
				"/textures/environment/Orionis_bmp.dds",
				"/textures/environment/Pisces IV_bmp.dds"
			};
            rt = Utilities.ChooseRandomString(r, bkgArr);
        }
        else if (envType == EnvironmentType.Redrock)
        {
            bkgArr = new string[] {
				"/textures/environment/Pollux_bmp.dds",
				"/textures/environment/Thiban_bmp.dds",
				"/textures/environment/Zeta Canis_bmp.dds"
			};
            rt = Utilities.ChooseRandomString(r, bkgArr);
        }
        else if (envType == EnvironmentType.Tropical)
        {
            bkgArr = new string[] {
				"/textures/environment/defaultbackground.dds",
				"/textures/environment/Matar_bmp.dds"
			};
            rt = Utilities.ChooseRandomString(r, bkgArr);
        }
        else if (envType == EnvironmentType.Tundra)
        {
            bkgArr = new string[] {
				"/textures/environment/defaultbackground.dds",
				"/textures/environment/Luthien_bmp.dds",
				"/textures/environment/Procyon_bmp.dds",
				"/textures/environment/Rigel_bmp.dds",
				"/textures/environment/Eridani_bmp.dds"
			};
            rt = Utilities.ChooseRandomString(r, bkgArr);
        }
        else if (envType == EnvironmentType.Geothermal)
        {
            bkgArr = new string[] {
				"/textures/environment/Orionis_bmp.dds",
				"/textures/environment/Pisces IV_bmp.dds"
			};
            rt = Utilities.ChooseRandomString(r, bkgArr);
        }
        else if (envType == EnvironmentType.Paradise)
        {
            bkgArr = new string[] {
				"/textures/environment/defaultbackground.dds",
				"/textures/environment/Matar_bmp.dds"
			};
            rt = Utilities.ChooseRandomString(r, bkgArr);
        }
        else if (envType == EnvironmentType.Swamp)
        {
            bkgArr = new string[] {
				"/textures/environment/Minerva_bmp.dds",
				"/textures/environment/Capella_bmp.dds",
				"/textures/environment/Zeta Canis_bmp.dds"
			};
            rt = Utilities.ChooseRandomString(r, bkgArr);
        }
        return rt;
    }

}
