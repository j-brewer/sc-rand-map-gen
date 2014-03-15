// ***************************************************************************************
// * Tileset Utility
// * Copyright 2014  Jonathan Brewer
// * Filename: Program.cs
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


using Microsoft.VisualBasic;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Xml;

namespace TilesetUtillity
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length > 0)
            {
                if (args[0].ToLowerInvariant() == "-gettilesetlist" && args.Length > 1)
                {                    
                    GetTilesetList(args[1]);
                }
                else if (args[0].ToLowerInvariant() == "-combinetilesets" && args.Length > 2)
                {
                    CombineTilesetFiles(args[1], args[2]);
                }
                else
                {
                    BuildNewTileset(args[0]);
                }
            }
        }
        static void GetTilesetList(string xmlFilePath)
        {
            FileInfo fi = new FileInfo(xmlFilePath);
            if (fi.Exists)
            {
                XmlDocument xd = new XmlDocument();
                xd.Load(xmlFilePath);
                XmlNodeList ts = xd.SelectNodes("/Tilesets/Tileset");
                Console.WriteLine("Tilesets in " + fi.FullName + ":");
                Console.WriteLine("----------------------------------------------------------");
                for (int i = 0; i < ts.Count; i++)
                {
                    XmlNode sts = ts[i];
                    Console.WriteLine("  " + sts.Attributes["name"].Value);
                }
                Console.WriteLine("----------------------------------------------------------");
                Console.WriteLine("Total Number of tilesets: " + ts.Count.ToString());
            }
            else
            {
                Console.WriteLine("ERROR: Specified file not found!");
            }
        }
        static void CombineTilesetFiles(string sourcePath, string destinationPath)
        {
            FileInfo fileInput = new FileInfo(sourcePath);
            FileInfo fileOutput = new FileInfo(destinationPath);
            if (fileInput.Exists)
            {
                if (fileOutput.Exists)
                {
                    XmlDocument xdI = new XmlDocument();
                    xdI.Load(sourcePath);
                    XmlNodeList tsI = xdI.SelectNodes("/Tilesets/Tileset");
                    XmlDocument xdO = new XmlDocument();
                    xdO.Load(destinationPath);
                    XmlNode tsO = xdO.SelectSingleNode("/Tilesets");
                    int duplicates = 0;
                    for (int i = 0; i < tsI.Count; i++)
                    {
                        XmlNode duplicateCheck = tsO.SelectSingleNode("//*[@name='" + tsI[i].Attributes["name"].Value + "']");
                        if (duplicateCheck != null)
                        {
                            duplicates++;
                        }
                        else
                        {
                            XmlNode importNodeO = xdO.ImportNode(tsI[i], true);
                            tsO.AppendChild(importNodeO);
                        }
                    }
                    xdO.Save(destinationPath);
                    if(duplicates >0)
                    {
                        Console.WriteLine("Note: " + duplicates + " duplicate tileset(s) were filtered out!");
                    }
                }
                else
                {
                    Console.WriteLine("ERROR: Specified output file not found!");
                }
            }
            else
            {
                Console.WriteLine("ERROR: Specified input file not found!");
            }
        }
        static void BuildNewTileset(string strataPath)
        {
            string inputFileStratum = strataPath;
            string inputFileProps = Strings.Replace(strataPath, ".lua", "-Props.lua", Compare: CompareMethod.Text);
            string outputFile = Strings.Replace(strataPath, ".lua", ".xml", Compare: CompareMethod.Text);
            string tilesetName = Strings.Replace(strataPath, ".lua", "", Compare: CompareMethod.Text);

            StreamReader inFile = new StreamReader(inputFileStratum);
            string temp = inFile.ReadToEnd();
            LuaInterface.Lua li = new LuaInterface.Lua();
            temp = FixLuaThemeFile(temp);
            li.DoString(temp, "DataFile");

            List<Stratum> sList = new List<Stratum>();            

            for(int i = -1; i < 9; i++)
            {
                string layerAlbedoId = "strata.Albedo" + i.ToString(CultureInfo.InvariantCulture);
                string layerNormalId = "strata.Normal" + i.ToString(CultureInfo.InvariantCulture);
                
                if (i == -1)
                {
                    layerAlbedoId = "strata.LowerAlbedo";
                    layerNormalId = "strata.LowerNormal";
                }
                else if (i == 8)
                {
                    layerAlbedoId = "strata.UpperAlbedo";
                    layerNormalId = "strata.LowerNormal";
                }

                LuaInterface.LuaTable lt_albedo = (LuaInterface.LuaTable)li[layerAlbedoId];
                LuaInterface.LuaTable lt_normal = (LuaInterface.LuaTable)li[layerNormalId];

                double ts; 
                double ns;
                Double.TryParse(lt_albedo[2].ToString(), out ts);
                Double.TryParse(lt_normal[2].ToString(), out ns);

                Stratum var = new Stratum();
                var.NormalScale = ns;
                var.TextureScale = ts;
                var.TexturePath = lt_albedo[1].ToString();
                if (i != 8)
                {
                    var.NormalPath = lt_normal[1].ToString();
                }
                sList.Add(var);
            }

            List<string> pList = new List<string>();
            StreamReader inFileProps = new StreamReader(inputFileProps);
            LuaInterface.Lua liProps = new LuaInterface.Lua();
            string propData = inFileProps.ReadToEnd();
            liProps.DoString(propData, "DataFile");

            LuaInterface.LuaTable prop_table = (LuaInterface.LuaTable)liProps["Props"];
            foreach (LuaInterface.LuaTable a in prop_table.Values)
            {
                string bp = a["blueprint"].ToString();
                if (!pList.Contains(bp))
                {
                    pList.Add(bp);
                }
            }

            string data = BuildTilesetData(tilesetName, sList, pList);

            StreamWriter sw = new StreamWriter(outputFile, false );
            sw.WriteLine("<Tilesets>");
            sw.WriteLine(data);
            sw.WriteLine("</Tilesets>");
            sw.Close();
            sw.Dispose();
        }
        static string BuildTilesetData(string TilesetName, List<Stratum> sList, List<string> pList)
        {
            string rt = "";
            rt = rt + "  <Tileset name=\"" + TilesetName + "\">" + Environment.NewLine;
            for(int i = 0; i < sList.Count; i++)
            {
                rt = rt + "    <Stratum" + i + ">" +  Environment.NewLine;
                rt = rt + "      <TexturePath>" + sList[i].TexturePath + "</TexturePath>" +  Environment.NewLine;
                rt = rt + "      <TextureScale>" + sList[i].TextureScale + "</TextureScale>" +  Environment.NewLine;
                rt = rt + "      <NormalPath>" + sList[i].NormalPath + "</NormalPath>" +  Environment.NewLine;
                rt = rt + "      <NormalScale>" + sList[i].NormalScale + "</NormalScale>" +  Environment.NewLine;
                rt = rt + "    </Stratum" + i + ">" +  Environment.NewLine;
            }
            rt = rt + "    <Props>" + Environment.NewLine;
            
            for(int k = 0; k < pList.Count; k++)
            {
                rt = rt + "      <Prop>" + pList[k] + "</Prop>" + Environment.NewLine;
            }
            rt = rt + "    </Props>" + Environment.NewLine;
            rt = rt + "  </Tileset>";
            return rt;
        }
        static string FixLuaThemeFile(string input)
        {
            string rt = input;
            rt = rt.Replace("'LowerAlbedo'", "LowerAlbedo");
            rt = rt.Replace("'LowerNormal'", "LowerNormal");
            rt = rt.Replace("'UpperAlbedo'", "UpperAlbedo");

            for (int i = 0; i < 8; i++)
            {
                string id = i.ToString(CultureInfo.InvariantCulture);
                rt = rt.Replace("'Albedo"+ id +"'", "Albedo"+ id);
                rt = rt.Replace("'Normal"+ id +"'", "Normal"+ id);
            }
            rt = rt.Replace("}", "},");
            rt = rt.Remove(rt.LastIndexOf(","));
            return rt;
        }
    }
    struct Stratum
    {
        public string TexturePath;
        public string NormalPath;
        public double TextureScale;
        public double NormalScale;
    }
    
}
