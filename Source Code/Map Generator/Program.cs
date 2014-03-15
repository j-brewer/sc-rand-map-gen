//***************************************************************************************
//* Supreme Commander Random Map Generator
//* Copyright 2014  Jonathan Brewer
// * Filename: Program.cs
//***************************************************************************************
//* 
//* This program is free software; you can redistribute it and/or modify
//* it under the terms of the GNU General Public License as published by
//* the Free Software Foundation; either version 3 of the License, or
//* (at your option) any later version.
//* 
//* This program is distributed in the hope that it will be useful,
//* but WITHOUT ANY WARRANTY; without even the implied warranty of
//* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//* GNU General Public License for more details.
//*
//* You should have received a copy of the GNU General Public License
//* along with this program; if not, write to the Free Software Foundation,
//* Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
//***************************************************************************************

using SlimDX;
using SlimDX.Direct3D9;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Windows.Forms;

static class Program
{
    private static Direct3D Direct3d = new Direct3D();
    private static Device Device;
    private static Control DummyControl = new Control();
    private static Map m;
    public static HeightMap MapHeightData;
    public static int lastMassId = 1;
    public static int randomSeed;
    public static System.DateTime timeStamp;
    public static HeightMap StartPositions;
    public static void Main(string[] args)
    {
        WriteConsoleInfo();
        CreateDevice();
        string path = GetScDir();
        if (args[0] == "-BuildTileSet")
        {
            BuildTileSetData();
        }
        else
        {
            //MapTest()
            string argInputPath = args[0];
            string argTilesetPath = args[4];
            string argOutputPath = args[3];
            int argHeight = int.Parse(args[1]);
            int argWidth = int.Parse(args[2]);

            //Generate Map
            if (args.Length > 5)
            {
                randomSeed = int.Parse(args[5]);
            }
            else
            {
                Random a = new Random();
                randomSeed = a.Next();
            }
            timeStamp = DateTime.Now;
            Console.WriteLine("Starting Map Generation...");
            Console.WriteLine("Random Seed: " + randomSeed);
            Random r = new Random(randomSeed);

            Console.WriteLine(argTilesetPath);
            Console.Write("Choosing Tileset...");
            Tileset ts = Tileset.GetRandomTileset(argTilesetPath, r);
            Console.WriteLine(" Done.");

            //Load Start Positions
            Console.Write("Loading Start Position Data...");
            StartPositions = HeightMapLoader.LoadPGMHeightmap(argInputPath + "\\StartPositions.pgm");
            Console.WriteLine(" Done.");

            //Generate Map
            Console.Write("Generating SCMAP data...");
            m = MapGenerator.GenerateMap(argHeight, argWidth, argInputPath, Device, r.Next(), ts);
            Console.WriteLine(" Done.");

            Console.Write("Saving map information...");
            m.SaveMapInformation(argInputPath + "\\mapdata.txt");
            Console.WriteLine(" Done.");

            Console.Write("Adding Start Positions...");
            StartLocationGenerator slg = new StartLocationGenerator(Program.MapHeightData, StartPositions, r);
            List<Marker> sList = slg.BuildStartLocationList();
            m.MarkerList = sList;
            Console.WriteLine(" " + sList.Count + " start positions added.");

            //Props
            PropGenerator pg = new PropGenerator(Program.MapHeightData, ts, argInputPath, m.Water.Elevation, r.Next());
            Program.timeStamp = DateTime.Now;
            Console.Write("  - Adding Rocks...");
            int rockCount = pg.PlaceRocksAroundStartPositions(r.Next(2000, 5000), 30, 70, sList);
            Console.WriteLine(" Done. " + GetTimeStampDifference() + " Created " + rockCount + " rocks.");

            Console.Write("  - Adding Trees...");
            int treeCount = pg.PlaceTrees();
            Console.WriteLine(" Done. " + GetTimeStampDifference() + " Created " + treeCount + " trees.");

            m.Props = pg.PropList;


            Console.Write("Adding Mass Spots...");
            int massDensity = r.Next(1, 9);
            int massVariance = r.Next(0, (massDensity / 3) + 1);
            MassSpotGenerator msg = new MassSpotGenerator(Program.MapHeightData, m.Water.Elevation, sList, r.Next());
            msg.AllowUnderwaterMassSpots = false;
            msg.AddStartLocationMassSpots();
            msg.AddStartLocationBasedMassSpots(massDensity, 8, 60);
            msg.BuildRandomDisributionMassSpotList(massDensity, massVariance, 120);

            List<Marker> mList = msg.GetFinalMassSpotList();
            m.MarkerList.AddRange(mList);
            Console.WriteLine(" " + mList.Count + " mass spots added.");

            //Generate Scenario File
            Console.WriteLine("Creating Scenario File...");
            ScenarioFile s = new ScenarioFile(StartPositions.Width - 1, new Point(m.Width, m.Height), args[3]);
            PlanetNameGenerator png = new PlanetNameGenerator(r.Next());
            s.Name = png.NextName();
            s.Description = "Computer Generated Map #" + randomSeed + ".  Produced by Duck_42s Map Generator.";
            s.Save();
            Console.WriteLine(" Done.");

            //Generate Script File
            Console.Write("Creating Script File...");
            ScriptFile.SaveScriptFile(s.MapScriptPath);
            Console.WriteLine(" Done.");

            //Generate Save File
            Console.Write("Creating Save File...");
            SaveFile sf = new SaveFile(s, m.MarkerList);
            sf.SaveScriptFile();
            Console.WriteLine(" Done.");

            Console.Write("Saving SCMAP file...");
            m.Save(argOutputPath);
            Console.WriteLine(" Done.");

            //Dump Texture Files
            Console.Write("Dumping Texture Files...");
            Texture.ToFile(m.WatermapTex, args[0] + "\\Watermap.dds", ImageFileFormat.Dds);
            Texture.ToFile(m.NormalmapTex, args[0] + "\\NormalMap.dds", ImageFileFormat.Dds);
            Texture.ToFile(m.PreviewTex, args[0] + "\\Preview.dds", ImageFileFormat.Dds);
            Texture.ToFile(m.TexturemapTex, args[0] + "\\TextureMap.dds", ImageFileFormat.Dds);
            Texture.ToFile(m.TexturemapTex2, args[0] + "\\TextureMap2.dds", ImageFileFormat.Dds);
            Console.WriteLine(" Done.");
            Console.WriteLine("Map Generation Complete!");
        }
    }
    private static void CreateDevice()
    {
        PresentParameters PP = new PresentParameters();
        PP.BackBufferFormat = Format.X8R8G8B8;
        Device = new Device(new Direct3D(), 0, DeviceType.Hardware, DummyControl.Handle, CreateFlags.HardwareVertexProcessing, PP);
    }
    private static string GetScDir()
    {
        Microsoft.Win32.RegistryKey rk = null;
        rk = Microsoft.Win32.Registry.LocalMachine.OpenSubKey("SOFTWARE\\THQ\\Gas Powered Games\\Supreme Commander", false);
        if (rk == null)
            return "";
        return rk.GetValue("InstallationDirectory").ToString();
    }

    private static void BuildTileSetData()
    {
        DirectoryInfo[] dirList = new DirectoryInfo(GetScDir() + "\\Supreme Commander\\maps").GetDirectories("SC*", SearchOption.TopDirectoryOnly);
        List<string> wgList = new List<string>();
        System.IO.StreamWriter fs = new System.IO.StreamWriter("TilesetData-GPGMaps.txt", false);
        System.IO.StreamWriter fs2 = new System.IO.StreamWriter("TilesetData-GPGWaves.csv", false);
        foreach (DirectoryInfo di in dirList)
        {
            FileInfo scMapPath = new FileInfo(di.FullName + "\\" + di.Name + ".scmap");
            if (scMapPath.Exists)
            {
                Console.WriteLine("Starting: " + di.Name + ".scmap");
                try
                {
                    m = new Map();
                    m.Load(scMapPath.FullName, Device);
                }
                catch (Exception)
                {
                    Console.WriteLine("Error Occurred Loading Map: " + di.Name + ".scmap");
                }
                fs.WriteLine(DumpTilesetData(m, di.Name));
                foreach (WaveGenerator wg in m.WaveGenerators)
                {
                    string tmp = "";
                    tmp += wg.FrameCount + "," + wg.FrameRateFirst + "," + wg.FrameRateSecond + ",";
                    tmp += wg.LifetimeFirst + "," + wg.LifetimeSecond + ",";
                    tmp += wg.PeriodFirst + "," + wg.PeriodSecond + "," + wg.RampName + ",";
                    tmp += wg.StripCount + ",";
                    tmp += wg.ScaleFirst + ",";
                    tmp += wg.ScaleSecond + ",";
                    tmp += wg.Velocity.X + ",";
                    tmp += wg.Velocity.Y + ",";
                    tmp += wg.Velocity.Z + ",";
                    tmp += wg.Rotation + ",";
                    tmp += wg.TextureName;
                    if (!wgList.Contains(tmp))
                    {
                        wgList.Add(tmp);
                        fs2.WriteLine(tmp);
                    }
                }
            }
            else
            {
                Console.WriteLine("Map Not Found: " + scMapPath.FullName);
            }
            fs.Flush();
            fs2.Flush();
        }
        fs.Close();
        fs2.Close();
    }
    private static string DumpTilesetData(Map m, string folderName)
    {
        string rt = "";
        rt = rt + "    <Tileset name=\"" + folderName + "\">" + Environment.NewLine;
        for (int i = 0; i <= m.Layers.Count - 1; i++)
        {
            rt = rt + "        <Stratum" + i + ">" + Environment.NewLine;
            rt = rt + "            <TexturePath>" + m.Layers[i].PathTexture + "</TexturePath>" + Environment.NewLine;
            rt = rt + "            <TextureScale>" + m.Layers[i].ScaleTexture + "</TextureScale>" + Environment.NewLine;
            rt = rt + "            <NormalPath>" + m.Layers[i].PathNormalmap + "</NormalPath>" + Environment.NewLine;
            rt = rt + "            <NormalScale>" + m.Layers[i].ScaleNormalmap + "</NormalScale>" + Environment.NewLine;
            rt = rt + "        </Stratum" + i + ">" + Environment.NewLine;
        }

        List<string> pList = new List<string>();
        for (int j = 0; j <= m.Props.Count - 1; j++)
        {
            if (!pList.Contains(m.Props[j].BlueprintPath))
            {
                pList.Add(m.Props[j].BlueprintPath);
            }
        }
        rt = rt + "        <Props>" + Environment.NewLine;
        for (int k = 0; k <= pList.Count - 1; k++)
        {
            rt = rt + "        <Prop>" + pList[k] + "</Prop>" + Environment.NewLine;
        }
        rt = rt + "        </Props>" + Environment.NewLine;
        rt = rt + "    </Tileset>" + Environment.NewLine;
        return rt;
    }
    public static void MapTest()
    {
        string path = GetScDir();
        if (!string.IsNullOrEmpty(path))
        {
            m = new Map();
            m.Load("c:\\program files (x86)\\thq\\gas powered games\\supreme commander\\maps\\scmp_020\\scmp_020.scmap", Device);
            //m.Load("c:\users\jonathan\documents\my games\gas powered games\supreme commander forged alliance\maps\test 7\test 7.scmap", Device)

            //Dim textures As List(Of String) = New List(Of String)()
            //Dim fc As List(Of Single) = New List(Of Single)()
            //Dim fr1 As List(Of Single) = New List(Of Single)()
            //Dim fr2 As List(Of Single) = New List(Of Single)()
            //Dim lt1 As List(Of Single) = New List(Of Single)()
            //Dim lt2 As List(Of Single) = New List(Of Single)()

            //Dim p1 As List(Of Single) = New List(Of Single)()
            //Dim p2 As List(Of Single) = New List(Of Single)()

            //Dim rn As List(Of String) = New List(Of String)()



            //Dim sc As List(Of Single) = New List(Of Single)()

            //Dim rtMin As Double = 0
            //Dim rtMax As Double = 0

            //Dim s1Min As Double = 0
            //Dim s1Max As Double = 0

            //Dim s2Min As Double = 0
            //Dim s2Max As Double = 0

            //For Each wGen In m.WaveGenerators
            //    If Not textures.Contains(wGen.TextureName) Then
            //        textures.Add(wGen.TextureName)
            //    End If
            //    If Not fc.Contains(wGen.FrameCount) Then
            //        fc.Add(wGen.FrameCount)
            //    End If
            //    If Not fr1.Contains(wGen.FrameRateFirst) Then
            //        fr1.Add(wGen.FrameRateFirst)
            //    End If
            //    If Not fr2.Contains(wGen.FrameRateSecond) Then
            //        fr2.Add(wGen.FrameRateSecond)
            //    End If
            //    If Not lt1.Contains(wGen.LifetimeFirst) Then
            //        lt1.Add(wGen.LifetimeFirst)
            //    End If
            //    If Not lt2.Contains(wGen.LifetimeSecond) Then
            //        lt2.Add(wGen.LifetimeSecond)
            //    End If

            //    If Not p1.Contains(wGen.PeriodFirst) Then
            //        p1.Add(wGen.PeriodFirst)
            //    End If

            //    If Not p2.Contains(wGen.PeriodSecond) Then
            //        p2.Add(wGen.PeriodSecond)
            //    End If

            //    If Not rn.Contains(wGen.RampName) Then
            //        rn.Add(wGen.RampName)
            //    End If
            //    If wGen.Rotation < rtMin Then
            //        rtMin = wGen.Rotation
            //    End If
            //    If wGen.Rotation > rtMax Then
            //        rtMax = wGen.Rotation
            //    End If

            //    If wGen.ScaleFirst < s1Min Then
            //        s1Min = wGen.ScaleFirst
            //    End If
            //    If wGen.ScaleFirst > s1Max Then
            //        s1Max = wGen.ScaleFirst
            //    End If
            //    If wGen.ScaleSecond < s2Min Then
            //        s2Min = wGen.ScaleSecond
            //    End If
            //    If wGen.ScaleSecond > s2Max Then
            //        s2Max = wGen.ScaleSecond
            //    End If

            //    If Not sc.Contains(wGen.StripCount) Then
            //        sc.Add(wGen.StripCount)
            //    End If
            //Next
            //m.Load(args(3), Device)
            Texture.ToFile(m.WatermapTex, "Watermap.png", ImageFileFormat.Png);
            Texture.ToFile(m.NormalmapTex, "NormalMap.dds", ImageFileFormat.Dds);
            Texture.ToFile(m.NormalmapTex, "NormalMap.png", ImageFileFormat.Png);
            Texture.ToFile(m.PreviewTex, "Preview.dds", ImageFileFormat.Dds);
            Texture.ToFile(m.TexturemapTex, "TextureMap.dds", ImageFileFormat.Dds);
            Texture.ToFile(m.TexturemapTex2, "TextureMap2.dds", ImageFileFormat.Dds);
        }
    }

    private static void WriteConsoleInfo()
    {
        Console.WriteLine("*******************************************************************************");
        Console.WriteLine("*                                                                             *");
        Console.WriteLine("*                  Supreme Commander Random Map Generator                     *");
        Console.WriteLine("*                                  v0.1                                       *");
        Console.WriteLine("*                          Author(s): Duck_42                                 *");
        Console.WriteLine("*                                                                             *");
        Console.WriteLine("*******************************************************************************");
    }
    public static string GetTimeStampDifference()
    {
        System.DateTime lastTimeStamp = timeStamp;
        timeStamp = DateTime.Now;
        TimeSpan elapsedTime = timeStamp.Subtract(lastTimeStamp);
        return "(" + string.Format("{0:0.000}", (elapsedTime.TotalSeconds)) + " seconds)";
    }
}
