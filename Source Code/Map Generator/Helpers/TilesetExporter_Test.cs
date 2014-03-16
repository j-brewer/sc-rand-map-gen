//***************************************************************************************
//* Supreme Commander Random Map Generator
//* Copyright 2014  Jonathan Brewer
// * Filename: TilesetExporter_Test.cs
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


using SlimDX.Direct3D9;
using System;
using System.Collections.Generic;
using System.IO;

/// <summary>
/// This class is currently not used.  It is being retained in case this code becomes useful at some point.
/// </summary>
class TilesetExporter_Test
{
    private static void BuildTileSetData(Device device, string scPath)
    {
        DirectoryInfo[] dirList = new DirectoryInfo(scPath + "\\Supreme Commander\\maps").GetDirectories("SC*", SearchOption.TopDirectoryOnly);
        List<string> wgList = new List<string>();
        Map m = new Map();

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
                    m.Load(scMapPath.FullName, device);
                }
                catch (Exception)
                {
                    Console.WriteLine("Error Occurred Loading Map: " + di.Name + ".scmap");
                }
                fs.WriteLine(DumpTilesetData(m, di.Name));
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
}