// ***************************************************************************************
// * SCMAP Loader
// * Copyright Unknown
// * Filename: Map.cs
// * Source: http://www.hazardx.com/details.php?file=82
// ***************************************************************************************


using SlimDX;
using SlimDX.Direct3D9;
using System;
using System.Collections.Generic;
using System.Drawing;

public class Map
{

    // Map
    private const int MAP_MAGIC = 0x1a70614d;

    private const int MAP_VERSION = 2;


    public string Filename;

    public Bitmap PreviewBitmap;

    public Texture PreviewTex;
    private short[] HeightmapData = new short[0];
    public short HeightMin;
    public short HeightMax;

    public short HeightDiff;

    public WaterShader Water = new WaterShader();
    //texturemap for the "Strata" layers
    public Texture TexturemapTex;
    public Texture TexturemapTex2;
    public Texture NormalmapTex;

    public Texture WatermapTex;
    public byte[] WaterFoamMask = new byte[0];
    public byte[] WaterFlatnessMask = new byte[0];

    public byte[] WaterDepthBiasMask = new byte[0];
    public int Width = 0;
    public int Height = 0;

    public string TexPathBackground;
    public string TexPathSkyCubemap;
    public string[] EnvCubemapsName;

    public string[] EnvCubemapsFile;

    public byte[] TerrainTypeData;

    public List<WaveGenerator> WaveGenerators = new List<WaveGenerator>();
    public List<Layer> Layers = new List<Layer>();
    public List<Decal> Decals = new List<Decal>();
    public List<IntegerGroup> DecalGroups = new List<IntegerGroup>();

    public List<Prop> Props = new List<Prop>();
    public int VersionMinor;

    public int VersionMajor;
    public float HeightScale;

    public string TerrainShader;
    public float LightingMultiplier;
    public Vector3 SunDirection;
    public Vector3 SunAmbience;
    public Vector3 SunColor;
    public Vector3 ShadowFillColor;
    public Vector4 SpecularColor;

    public float Bloom;
    public Vector3 FogColor;
    public float FogStart;

    public float FogEnd;
    public int Unknown10;
    public int Unknown11;
    public int Unknown12;

    public short Unknown13;
    public int Unknown7;

    public int Unknown8;
    public float Unknown14;

    //Minimap Cartographic View Colors (Not in Hazard's Original Code)
    public int MinimapContourInterval;
    public Color MinimapDeepWaterColor;
    public Color MinimapShoreColor;
    public Color MinimapLandStartColor;
    public Color MinimapLandEndColor;
    public Color MinimapContourColor; //Not sure about this one
    

    public void Initialize()
    {
        TerrainTypeData = new byte[Height * Width];
        HeightmapData = new short[(Height + 1) * (Width + 1)];
        WaterDepthBiasMask = new byte[(Height * Width) / 4];
        WaterFlatnessMask = new byte[(Height * Width) / 4];
        WaterFoamMask = new byte[(Height * Width) / 4];
        for (int i = 0; i <= WaterDepthBiasMask.Length - 1; i++)
        {
            WaterDepthBiasMask[i] = 127;
            WaterFlatnessMask[i] = 255;
            WaterFoamMask[i] = 0;
        }

        //Version
        VersionMajor = 2;
        VersionMinor = 56;

        HeightScale = 0.0078125f;

        //Unknown Values

        Unknown8 = 0;
        Unknown10 = -1091567891;
        Unknown11 = 2;
        Unknown12 = 0;
        Unknown13 = 0;
        Unknown14 = 0;

        //Minimap Colors (Default)
        MinimapContourInterval = 24;
        MinimapDeepWaterColor = Color.FromArgb(71, 140, 181);
        MinimapContourColor = Color.FromArgb(112, 112, 112);
        MinimapShoreColor = Color.FromArgb(140, 201, 224);
        MinimapLandStartColor = Color.FromArgb(117, 99, 107);
        MinimapLandEndColor = Color.FromArgb(206, 206, 176);

    }

    public short GetHeight(int x, int y)
    {
        return HeightmapData[(y * (Width + 1)) + x];
    }
    public void SetHeight(int x, int y, short value)
    {
       HeightmapData[(y * (Width + 1)) + x] = value;
    }

    public byte GetTerrainTypeValue(int x, int y)
    {
        return TerrainTypeData[(y * Width) + x];
    }
    public void SetTerrainTypeValue(int x, int y, byte value)
    {
        TerrainTypeData[(y * Width) + x] = value;
    }


    public void Clear()
    {
        if (PreviewBitmap != null) { PreviewBitmap.Dispose(); PreviewBitmap = null; }
        if (PreviewTex != null) { PreviewTex.Dispose(); PreviewTex = null; }
        if (TexturemapTex != null) { TexturemapTex.Dispose(); TexturemapTex = null; }
        if (TexturemapTex2 != null) { TexturemapTex2.Dispose(); TexturemapTex2 = null; }
        if (NormalmapTex != null) { NormalmapTex.Dispose(); NormalmapTex = null; }

        HeightmapData = new short[0];

        Width = 0;
        Height = 0;

        TexPathBackground = "";
        TexPathSkyCubemap = "";
        EnvCubemapsName = new string[0];
        EnvCubemapsFile = new string[0];

        Water.Clear();

        WaterFoamMask = new byte[0];
        WaterFlatnessMask = new byte[0];
        WaterDepthBiasMask = new byte[0];

        WaveGenerators.Clear();
        Layers.Clear();
        Decals.Clear();
        DecalGroups.Clear();
        Props.Clear();
    }


    #region " Load/Save Functions "

    public bool Load(string Filename, Device Device)
    {
        if (string.IsNullOrEmpty(Filename))
            return false;
        if (!System.IO.File.Exists(Filename))
            return false;

        this.Filename = Filename;

        Clear();

        System.IO.FileStream fs = new System.IO.FileStream(Filename, System.IO.FileMode.Open, System.IO.FileAccess.Read);
        BinaryReader Stream = new BinaryReader(fs);

        byte[] PreviewData = new byte[0];
        byte[] TexturemapData = new byte[0];
        byte[] TexturemapData2 = new byte[0];
        byte[] NormalmapData = new byte[0];
        byte[] WatermapData = new byte[0];
        int Count = 0;

        var _with1 = Stream;
        //# Header Section #
        if (_with1.ReadInt32() == MAP_MAGIC)
        {
            VersionMajor = _with1.ReadInt32();
            //? always 2
            Unknown10 = _with1.ReadInt32();
            //? always EDFE EFBE
            Unknown11 = _with1.ReadInt32();
            //? always 2
            _with1.ReadSingle();
            //Map Width (in float)
            _with1.ReadSingle();
            //Map Height (in float)
            Unknown12 = _with1.ReadInt32();
            //? always 0
            Unknown13 = _with1.ReadInt16();
            //? always 0
            int ImageLength = _with1.ReadInt32();
            PreviewData = _with1.ReadBytes(ImageLength);

            VersionMinor = _with1.ReadInt32();
            if (VersionMinor <= 0)
                VersionMinor = 56;

            if (VersionMinor > 56)
            {
                Console.WriteLine("This map uses SCMAP file version" + VersionMinor + " which is not yet supported by this editor. I will try to load it with the newest known version (" + 56 + "), but it is very likely to fail or cause errors.");
            }

            //# Heightmap Section #
            Width = _with1.ReadInt32();
            Height = _with1.ReadInt32();

            HeightScale = _with1.ReadSingle();
            //Height Scale, usually 1/128
            HeightmapData = _with1.ReadInt16Array((Height + 1) * (Width + 1));
            //heightmap dimension is always 1 more than texture dimension!

            if (VersionMinor >= 56)
                _with1.ReadByte();
            //Always 0?

            //# Texture Definition Section #
            TerrainShader = _with1.ReadStringNull();
            //Terrain Shader, usually "TTerrain"
            TexPathBackground = _with1.ReadStringNull();
            TexPathSkyCubemap = _with1.ReadStringNull();

            if (VersionMinor >= 56)
            {
                Count = _with1.ReadInt32();
                //always 1?
                EnvCubemapsName = new string[Count + 1];
                EnvCubemapsFile = new string[Count + 1];
                for (int i = 0; i <= Count - 1; i++)
                {
                    EnvCubemapsName[i] = _with1.ReadStringNull();
                    EnvCubemapsFile[i] = _with1.ReadStringNull();
                }
            }
            else
            {
                EnvCubemapsName = new string[2];
                EnvCubemapsName[0] = "<default>";
                EnvCubemapsFile = new string[2];
                EnvCubemapsFile[0] = _with1.ReadStringNull();
            }

            LightingMultiplier = _with1.ReadSingle();
            SunDirection = _with1.ReadVector3();
            SunAmbience = _with1.ReadVector3();
            SunColor = _with1.ReadVector3();
            ShadowFillColor = _with1.ReadVector3();
            SpecularColor = _with1.ReadVector4();
            Bloom = _with1.ReadSingle();

            FogColor = _with1.ReadVector3();
            FogStart = _with1.ReadSingle();
            FogEnd = _with1.ReadSingle();


            Water.Load(Stream);

            Count = _with1.ReadInt32();
            WaveGenerators.Clear();
            for (int i = 0; i <= Count - 1; i++)
            {
                WaveGenerator WaveGen = new WaveGenerator();
                WaveGen.Load(Stream);
                WaveGenerators.Add(WaveGen);
            }

            if (VersionMinor < 56)
            {
                _with1.ReadStringNull();
                // always "No Tileset"
                Count = _with1.ReadInt32();
                //always 6
                for (int i = 0; i <= 4; i++)
                {
                    Layer Layer = new Layer();
                    Layer.Load(Stream);
                    Layers.Add(Layer);
                }
                for (int i = 5; i <= 8; i++)
                {
                    Layers.Add(new Layer());
                }
                for (int i = 9; i <= 9; i++)
                {
                    Layer Layer = new Layer();
                    Layer.Load(Stream);
                    Layers.Add(Layer);
                }
            }
            else
            {
                MinimapContourInterval = _with1.ReadInt32();
                MinimapDeepWaterColor = Color.FromArgb(_with1.ReadInt32());
                MinimapContourColor = Color.FromArgb(_with1.ReadInt32());
                MinimapShoreColor = Color.FromArgb(_with1.ReadInt32());
                MinimapLandStartColor = Color.FromArgb(_with1.ReadInt32());
                MinimapLandEndColor = Color.FromArgb(_with1.ReadInt32());
                
                if (VersionMinor > 56)
                {
                    Unknown14 = _with1.ReadSingle(); //Not sure what this is.
                }
                Count = 10;
                for (int i = 0; i <= Count - 1; i++)
                {
                    Layer Layer = new Layer();
                    Layer.LoadAlbedo(Stream);
                    Layers.Add(Layer);
                }
                for (int i = 0; i <= Count - 2; i++)
                {
                    Layers[i].LoadNormal(Stream);
                }
            }

            Unknown7 = _with1.ReadInt32();
            //?
            Unknown8 = _with1.ReadInt32();
            //?

            int DecalCount = _with1.ReadInt32();
            for (int i = 0; i <= DecalCount - 1; i++)
            {
                Decal Feature = new Decal();
                Feature.Load(Stream);
                Decals.Add(Feature);
            }

            int GroupCount = _with1.ReadInt32();
            for (int i = 0; i <= GroupCount - 1; i++)
            {
                IntegerGroup Group = new IntegerGroup();
                Group.Load(Stream);
                DecalGroups.Add(Group);
            }

            _with1.ReadInt32();
            //Width again
            _with1.ReadInt32();
            //Height again

            int Length = 0;
            int NormalmapCount = _with1.ReadInt32();
            //always 1
            for (int i = 0; i <= NormalmapCount - 1; i++)
            {
                Length = _with1.ReadInt32();
                if (i == 0)
                {
                    NormalmapData = _with1.ReadBytes(Length);
                }
                else
                {
                    _with1.BaseStream.Position += Length;
                    // just to make sure that it doesn't crash if it is not just 1 normalmap for some reason
                }
            }


            if (VersionMinor < 56)
                _with1.ReadInt32();
            //always 1
            Length = _with1.ReadInt32();
            TexturemapData = _with1.ReadBytes(Length);

            if (VersionMinor >= 56)
            {
                Length = _with1.ReadInt32();
                TexturemapData2 = _with1.ReadBytes(Length);
            }

            //Watermap
            _with1.ReadInt32();
            //always 1
            Length = _with1.ReadInt32();
            WatermapData = _with1.ReadBytes(Length);

            int HalfSize = (Width / 2) * (Height / 2);
            WaterFoamMask = _with1.ReadBytes(HalfSize);
            WaterFlatnessMask = _with1.ReadBytes(HalfSize);
            WaterDepthBiasMask = _with1.ReadBytes(HalfSize);

            TerrainTypeData = _with1.ReadBytes(Width * Height);

            if (VersionMinor <= 52)
                _with1.ReadInt16();
            //always 0

            int PropCount = _with1.ReadInt32();
            for (int i = 0; i <= PropCount - 1; i++)
            {
                Prop Prop = new Prop();
                Prop.Load(Stream);
                Props.Add(Prop);
            }
        }
        _with1.Close();
        fs.Close();
        fs.Dispose();

        PreviewTex = Texture.FromMemory(Device, PreviewData);
        PreviewData = new byte[0];
        PreviewBitmap = TextureToBitmap(PreviewTex);

        TexturemapTex = Texture.FromMemory(Device, TexturemapData);
        TexturemapData = new byte[0];

        if (TexturemapData2.Length > 0)
        {
            TexturemapTex2 = Texture.FromMemory(Device, TexturemapData2);
            TexturemapData2 = new byte[0];
        }
        else
        {
            TexturemapTex2 = new Texture(Device, Width / 2, Height / 2, 1, Usage.None, Format.A8R8G8B8, Pool.Managed);
        }

        NormalmapTex = Texture.FromMemory(Device, NormalmapData);
        NormalmapData = new byte[0];

        WatermapTex = Texture.FromMemory(Device, WatermapData);
        WatermapData = new byte[0];

        return true;
    }
    public void SaveMapInformation(string Filename, int randomSeed)
    {
        System.IO.StreamWriter fs = new System.IO.StreamWriter(Filename, false);
        fs.WriteLine("FA Map Information");
        fs.WriteLine("----------------------------------------------------------------");
        fs.WriteLine("    Random Number Seed: " + randomSeed);
        fs.WriteLine("    Dimensions: " + this.Width + "x" + this.Height);
        fs.WriteLine("    Map Data Version: " + this.VersionMajor + "." + this.VersionMinor);
        fs.WriteLine("    Height Scale: " + this.HeightScale);
        fs.WriteLine("    Decal Count: " + this.Decals.Count);
        fs.WriteLine("    Prop Count: " + this.Props.Count);
        fs.WriteLine("    Wave Generator Count: " + this.WaveGenerators.Count);

        fs.WriteLine("");
        fs.WriteLine("    Lighting");
        fs.WriteLine("        Terrain Shader: " + this.TerrainShader);
        fs.WriteLine("        Background: " + this.TexPathBackground);
        fs.WriteLine("        Sky Cube: " + this.TexPathSkyCubemap);
        fs.WriteLine("        Enviroment Lookup Textures");
        for (int i = 0; i <= this.EnvCubemapsFile.Length - 1; i++)
        {
            fs.WriteLine("            Texture " + i + 1);
            fs.WriteLine("                Texture Label: " + this.EnvCubemapsName[i]);
            fs.WriteLine("                Texture Path: " + this.EnvCubemapsFile[i]);
            fs.WriteLine("");
        }
        fs.WriteLine("        Light Direction: RA=" + (180 / Math.PI) * Math.Acos(this.SunDirection.Z) + " Dec=" + (180 / Math.PI) * Math.Atan2(this.SunDirection.Y, this.SunDirection.X) + " Vector=" + this.SunDirection.ToString());
        fs.WriteLine("        Multiplier: " + this.LightingMultiplier);
        fs.WriteLine("        Light Color: R=" + this.SunColor.X + " G=" + this.SunColor.Y + " B=" + this.SunColor.Z);
        fs.WriteLine("        Ambient Light Color: R=" + this.SunAmbience.X + " G=" + this.SunAmbience.Y + " B=" + this.SunAmbience.Z);
        fs.WriteLine("        Shadow Color: R=" + this.ShadowFillColor.X + " G=" + this.ShadowFillColor.Y + " B=" + this.ShadowFillColor.Z);
        fs.WriteLine("        Specular: ");
        fs.WriteLine("        Glow: ");
        fs.WriteLine("        Bloom: " + this.Bloom);
        fs.WriteLine("        Fog Color: R=" + this.FogColor.X + " G=" + this.FogColor.Y + " B=" + this.FogColor.Z);
        fs.WriteLine("        Fog Start: " + this.FogStart);
        fs.WriteLine("        Fog End: " + this.FogEnd);
        fs.WriteLine("    Water");
        fs.WriteLine("        Enabled: " + this.Water.HasWater);
        fs.WriteLine("        Surface Elevation: " + this.Water.Elevation);
        fs.WriteLine("        Deep Elevation: " + this.Water.ElevationDeep);
        fs.WriteLine("        Abyss Elevation: " + this.Water.ElevationAbyss);
        fs.WriteLine("        Reflected Sun Color: R=" + this.Water.SunColor.X + " G=" + this.Water.SunColor.Y + " B=" + this.Water.SunColor.Z);
        fs.WriteLine("        Water Surface Color: R=" + this.Water.SurfaceColor.X + " G=" + this.Water.SurfaceColor.Y + " B=" + this.Water.SurfaceColor.Z);
        fs.WriteLine("        Color Lerp: Max=" + this.Water.ColorLerp.Y + " Min=" + this.Water.ColorLerp.X);
        fs.WriteLine("        Sun Reflection: " + this.Water.SunReflection);
        fs.WriteLine("        Sky Reflection: " + this.Water.SkyReflection);
        fs.WriteLine("        Unit Reflection: " + this.Water.UnitReflection);
        fs.WriteLine("        Refraction: " + this.Water.RefractionScale);
        fs.WriteLine("        Sun Shininess: " + this.Water.SunShininess);
        fs.WriteLine("        Sun Strength: " + this.Water.SunStrength);
        fs.WriteLine("        Sun Glow: " + this.Water.SunGlow);
        fs.WriteLine("        Fresnel Bias: " + this.Water.FresnelBias);
        fs.WriteLine("        Fresnel Power: " + this.Water.FresnelPower);
        fs.WriteLine("        Texture-Environment: " + this.Water.TexPathCubemap);
        fs.WriteLine("        Texture-Water Ramp: " + this.Water.TexPathWaterRamp);
        fs.WriteLine("        Wave Normals");
        for (int i = 0; i <= this.Water.WaveTextures.Length - 1; i++)
        {
            fs.WriteLine("            Wave Normal " + i + 1);
            fs.WriteLine("                Texture: " + this.Water.WaveTextures[i].TexPath);
            fs.WriteLine("                Direction Vector: X=" + this.Water.WaveTextures[i].NormalMovement.X + " " + this.Water.WaveTextures[i].NormalMovement.Y);
            fs.WriteLine("                Frequency: " + this.Water.WaveTextures[i].NormalRepeat);
            fs.WriteLine("");
        }

        fs.WriteLine("    Stratum");
        for (int i = 0; i <= this.Layers.Count - 1; i++)
        {
            Layer stratum = this.Layers[i];
            fs.WriteLine("        Stratum " + i + 1);
            fs.WriteLine("                Texture Path: " + stratum.PathTexture);
            fs.WriteLine("                Texture Scale: " + stratum.ScaleTexture);
            fs.WriteLine("                Normal Map Path: " + stratum.PathNormalmap);
            fs.WriteLine("                Normal Map Scale: " + stratum.ScaleNormalmap);
            fs.WriteLine("");
        }

        fs.WriteLine("    Unknown Settings");
        fs.WriteLine("        Unknown Value 7:" + this.Unknown7);
        fs.WriteLine("        Unknown Value 8:" + this.Unknown8);
        fs.WriteLine("        Unknown Value 10:" + this.Unknown10);
        fs.WriteLine("        Unknown Value 11:" + this.Unknown11);
        fs.WriteLine("        Unknown Value 12:" + this.Unknown12);
        fs.WriteLine("        Unknown Value 13:" + this.Unknown13);
        fs.WriteLine("        Unknown Value 14:" + this.Unknown14);

        fs.Close();
    }
    public bool Save(string Filename = "", int MapFileVersion = -1)
    {
        if (!string.IsNullOrEmpty(Filename) & Filename != this.Filename)
        {
            this.Filename = Filename;
        }
        else
        {
            Filename = this.Filename;
        }
        if (MapFileVersion <= 0)
            MapFileVersion = VersionMinor;
        if (MapFileVersion <= 0)
            MapFileVersion = 56;
        if (MapFileVersion != VersionMinor)
            VersionMinor = MapFileVersion;


        System.IO.FileStream fs = new System.IO.FileStream(Filename, System.IO.FileMode.Create, System.IO.FileAccess.Write);
        BinaryWriter Stream = new BinaryWriter(fs);

        var _with2 = Stream;
        //# Header Section #
        _with2.Write(MAP_MAGIC);
        _with2.Write(MAP_VERSION);

        _with2.Write(Unknown10);
        //? always EDFE EFBE
        _with2.Write(Unknown11);
        //? always 2
        _with2.Write(Width);
        //Map Width (in float)
        _with2.Write(Height);
        //Map Height (in float)
        _with2.Write(Unknown12);
        //? always 0
        _with2.Write(Unknown13);
        //? always 0

        SaveTexture(Stream, PreviewTex);

        //# Heightmap Section #
        _with2.Write(MapFileVersion);
        _with2.Write(Width);
        _with2.Write(Height);
        _with2.Write(HeightScale);
        //Height Scale, usually 1/128
        _with2.Write(HeightmapData);

        if (MapFileVersion >= 56)
            _with2.Write(Convert.ToByte(0));
        //Always 0?

        //# Texture Definition Section #
        _with2.Write(TerrainShader, true);
        //usually "TTerrain"
        _with2.Write(TexPathBackground, true);
        _with2.Write(TexPathSkyCubemap, true);
        if (VersionMinor >= 56)
        {
            _with2.Write(EnvCubemapsName.Length);
            for (int i = 0; i < EnvCubemapsName.Length; i++)
            {
                _with2.Write(EnvCubemapsName[i], true);
                _with2.Write(EnvCubemapsFile[i], true);
            }
        }
        else
        {
            if (EnvCubemapsFile.Length >= 1)
            {
                _with2.Write(EnvCubemapsFile[0], true);
            }
            else
            {
                _with2.Write(Convert.ToByte(0));
            }
        }

        _with2.Write(LightingMultiplier);
        _with2.Write(SunDirection);
        _with2.Write(SunAmbience);
        _with2.Write(SunColor);
        _with2.Write(ShadowFillColor);
        _with2.Write(SpecularColor);
        _with2.Write(Bloom);

        _with2.Write(FogColor);
        _with2.Write(FogStart);
        _with2.Write(FogEnd);

        Water.Save(Stream);

        _with2.Write(WaveGenerators.Count);
        for (int i = 0; i < WaveGenerators.Count; i++)
        {
            WaveGenerators[i].Save(Stream);
        }

        if (VersionMinor < 56)
        {
            _with2.Write("No Tileset", true);

            _with2.Write(6);
            for (int i = 0; i <= 4; i++)
            {
                Layers[i].Save(Stream);
            }
            Layers[Layers.Count - 1].Save(Stream);
        }
        else
        {
            _with2.Write(MinimapContourInterval);
            _with2.Write(MinimapDeepWaterColor.ToArgb());
            _with2.Write(MinimapContourColor.ToArgb());
            _with2.Write(MinimapShoreColor.ToArgb());
            _with2.Write(MinimapLandStartColor.ToArgb());
            _with2.Write(MinimapLandEndColor.ToArgb());

            if (VersionMinor > 56)
            {
                _with2.Write(Unknown14);
            }

            for (int i = 0; i <= Layers.Count - 1; i++)
            {
                Layers[i].SaveAlbedo(Stream);
            }
            for (int i = 0; i <= Layers.Count - 2; i++)
            {
                Layers[i].SaveNormal(Stream);
            }
        }

        _with2.Write(Unknown7);
        //?
        _with2.Write(Unknown8);
        //?

        _with2.Write(Decals.Count);
        for (int i = 0; i <= Decals.Count - 1; i++)
        {
            Decals[i].Save(Stream, i);
        }

        _with2.Write(DecalGroups.Count);
        for (int i = 0; i <= DecalGroups.Count - 1; i++)
        {
            DecalGroups[i].Save(Stream);
        }

        _with2.Write(Width);
        //Width again
        _with2.Write(Height);
        //Height again

        _with2.Write(1);
        SaveTexture(Stream, NormalmapTex);
        //Format.Dxt5

        if (VersionMinor < 56)
            _with2.Write(1);
        SaveTexture(Stream, TexturemapTex);

        if (VersionMinor >= 56)
        {
            SaveTexture(Stream, TexturemapTex2);
        }

        _with2.Write(1);
        SaveTexture(Stream, WatermapTex);

        _with2.Write(WaterFoamMask);
        _with2.Write(WaterFlatnessMask);
        _with2.Write(WaterDepthBiasMask);

        _with2.Write(TerrainTypeData);

        if (MapFileVersion <= 52)
            _with2.Write(Convert.ToInt16(0));

        _with2.Write(Props.Count);
        for (int i = 0; i <= Props.Count - 1; i++)
        {
            Props[i].Save(Stream);
        }

        _with2.Close();
        fs.Close();
        fs.Dispose();
        return true;
    }

    public static int GetMapVersion(string Filename)
    {
        if (string.IsNullOrEmpty(Filename))
            return 0;
        if (!System.IO.File.Exists(Filename))
            return 0;

        System.IO.FileStream fs = new System.IO.FileStream(Filename, System.IO.FileMode.Open, System.IO.FileAccess.Read);
        BinaryReader Stream = new BinaryReader(fs);

        int MapFileVersion = 0;

        var _with3 = Stream;
        //# Header Section #
        if (_with3.ReadInt32() == MAP_MAGIC)
        {
            fs.Position += 26;
            int ImageLength = _with3.ReadInt32();
            fs.Position += ImageLength;

            //# Heightmap Section #
            MapFileVersion = _with3.ReadInt32();
        }

        _with3.Close();
        fs.Close();
        fs.Dispose();

        return MapFileVersion;
    }

    private void SaveTexture(BinaryWriter Stream, Texture Texture)
    {
        System.IO.Stream Data = BaseTexture.ToStream(Texture, ImageFileFormat.Dds);
        Stream.Write(Convert.ToInt32(Data.Length));
        CopyStream(Data, Stream.BaseStream);
    }

    private Bitmap TextureToBitmap(Texture Texture)
    {
        System.IO.Stream gs = BaseTexture.ToStream(Texture, ImageFileFormat.Bmp);
        if (gs == null || gs.Length == 0)
            return null;
        Bitmap bmp = new Bitmap(gs);
        gs.Close();
        gs.Dispose();
        return bmp;
    }

    private void CopyStream(System.IO.Stream Source, System.IO.Stream Target)
    {
        byte[] buffer = new byte[2049];
        int read = 0;
        do
        {
            read = Source.Read(buffer, 0, buffer.Length);
            if (read > 0)
                Target.Write(buffer, 0, read);
        } while ((read > 0));
    }

    #endregion

}
