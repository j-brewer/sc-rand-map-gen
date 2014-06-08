//***************************************************************************************
//* Supreme Commander Random Map Generator
//* Copyright 2014  Jonathan Brewer
//* Filename: Program.cs
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

        string path = Utilities.GetScDir();
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
        Console.WriteLine(" Done.  (" + ts.Name + ")");

        //Load Start Positions
        Console.Write("Loading Start Position Data...");
        StartPositions = HeightMapLoader.LoadHeightmapWithNoExtension(argInputPath + "\\StartPositions");
        Console.WriteLine(" Done.");

        //Generate Map
        Console.Write("Generating SCMAP data...");
        m = MapGenerator.GenerateMap(argHeight, argWidth, argInputPath, Device, r.Next(), ts);
        Console.WriteLine(" Done.");

        //Assign Start Positions
        Console.Write("Adding Start Positions...");
        StartLocationGenerator slg = new StartLocationGenerator(Program.MapHeightData, StartPositions, r);
        List<Marker> sList = slg.BuildStartLocationList();
        m.MarkerList = sList;
        Console.WriteLine(" " + sList.Count + " start positions added.");

        //Props
        PropGenerator pg = new PropGenerator(Program.MapHeightData, ts, argInputPath, m.Water.Elevation, r.Next());
        Program.timeStamp = DateTime.Now;
        Console.Write("  - Adding Rocks...");
        int rockCount = pg.PlaceRocksAroundStartPositions(r.Next(1000, 5000), 30, 70, sList);
        Console.WriteLine(" Done. " + GetTimeStampDifference() + " Created " + rockCount + " rocks.");

        Console.Write("  - Adding Trees...");
        int treeCount = pg.PlaceTrees();
        Console.WriteLine(" Done. " + GetTimeStampDifference() + " Created " + treeCount + " trees.");

        m.Props = pg.PropList;

        //Mass Spots
        Console.Write("Adding Mass Spots...");
        int TotalAttempts = 200;       
        double bestScore = 0;
        
        int massDensityA = r.Next(0, 5);
        int massDensityB = r.Next(0, 7);

        MassSpotGenerator mSpotGen = new MassSpotGenerator(Program.MapHeightData, m.Water.Elevation, sList, r.Next());
        mSpotGen.AllowUnderwaterMassSpots = false;
        mSpotGen.AddStartLocationMassSpots();
        mSpotGen.AddStartLocationBasedMassSpots(massDensityA, 8, 60);
        List<Marker> tempListMS = new List<Marker>();
        for(int i= 0; i < TotalAttempts; i++)
        {
            mSpotGen.BuildRandomDisributionMassSpotList(sList.Count * massDensityB, 60);

            double thisScore = mSpotGen.MassSpotFairnessScore();
            if (thisScore > bestScore)
            {
                tempListMS = mSpotGen.RemoveRandomDisributionMassSpots();
                bestScore = thisScore;
            }
            else
            {
                mSpotGen.RemoveRandomDisributionMassSpots();
            }

            if (bestScore > .97)
            {
                break;
            }
        }
        mSpotGen.AddRandomDisributionMassSpots(tempListMS);       
        mSpotGen.ImproveMassSpotFairness((massDensityB * sList.Count), 1);
        mSpotGen.ImproveMassSpotFairness((massDensityB * sList.Count), 1);
        mSpotGen.ImproveMassSpotFairness((massDensityB * sList.Count), 1);
        mSpotGen.ImproveMassSpotFairness((massDensityB * sList.Count), 1);
        mSpotGen.ImproveMassSpotFairness((massDensityB * sList.Count), 1);

        List<Marker> mList = mSpotGen.GetFinalMassSpotList();

        for (int j = 0; j < mList.Count; j++)
        {
            MassMarker mm = (MassMarker)mList[j];
            if (mm.MassSpotScoreMatrix.Count > 0)
            {
                Console.WriteLine(mm.Name + ": " + mm.GetMassSpotFairness());
            }
        }
        mSpotGen.PrintMassSpotFairnessScores();
        double mScore = mSpotGen.MassSpotFairnessScore();
        m.MarkerList.AddRange(mList);
        Console.WriteLine(" " + mList.Count + " mass spots added.  Placement Score is " + (100 * mScore).ToString() + "%");

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

        //Save SCMAP File
        Console.Write("Saving SCMAP file...");
        m.Save(argOutputPath);
        Console.WriteLine(" Done.");

        //Save text dump of map information
        Console.Write("Saving map information file...");
        m.SaveMapInformation(argInputPath + "\\mapdata.txt");
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
    private static void CreateDevice()
    {
        PresentParameters PP = new PresentParameters();
        PP.BackBufferFormat = Format.X8R8G8B8;
        Device = new Device(new Direct3D(), 0, DeviceType.Hardware, DummyControl.Handle, CreateFlags.HardwareVertexProcessing, PP);
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
