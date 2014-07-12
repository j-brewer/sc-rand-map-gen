// ***************************************************************************************
// * Supreme Commander Random Map Generator
// * Copyright 2014  Jonathan Brewer
// * Filename: Tileset.cs
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


using System;
using System.Collections.Generic;
using System.Xml;

public class Tileset
{
    public List<Layer> Stratum;
    public List<string> TreeProps;
    public List<string> RockProps;
    public List<string> OtherProps;
    public string Name;
    public Tileset()
    {
        Stratum = new List<Layer>();
        TreeProps = new List<string>();
        RockProps = new List<string>();
        OtherProps = new List<string>();
    }
    public EnvironmentType GetBaseTextureEnvironmentType()
    {
        EnvironmentType rt = EnvironmentType.DefaultEnvironment;
        string s = Stratum[0].PathTexture;
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
                else if (envType == "redrock" || envType == "red barrens")
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
                else if (envType == "swamp")
                {
                    rt = EnvironmentType.Swamp;
                }
                else if (envType == "crystalline")
                {
                    rt = EnvironmentType.Crystalline;
                }
                else if (envType == "paradise")
                {
                    rt = EnvironmentType.Paradise;
                }
            }
        }

        return rt;
    }
    public static Tileset GetRandomTileset(string tilesetListPath, Random r)
    {
        Tileset rt = new Tileset();
        XmlDocument xd = new XmlDocument();
        xd.Load(tilesetListPath);
        XmlNodeList ts = xd.SelectNodes("/Tilesets/Tileset");
        int rndTs = r.Next(0, ts.Count);

        XmlNode sts = ts[rndTs];
        rt.Name  = sts.Attributes["name"].InnerText;
        for (int i = 0; i <= 9; i++)
        {
            XmlNode temp = sts["Stratum" + i];
            Layer sVal = new Layer();
            sVal.PathTexture = temp["TexturePath"].InnerText;
            sVal.ScaleTexture = (float)Convert.ToDouble(temp["TextureScale"].InnerText);
            sVal.PathNormalmap = temp["NormalPath"].InnerText;
            sVal.ScaleNormalmap = (float)Convert.ToDouble(temp["NormalScale"].InnerText);
            rt.Stratum.Add(sVal);
        }

        XmlNodeList pList = sts["Props"].SelectNodes("Prop");
        for (int j = 0; j <= pList.Count - 1; j++)
        {
            XmlNode temp = pList[j];
            string propPath = temp.InnerText.ToLowerInvariant();
            string propPathTemp = propPath.Replace("redrocks", "rr");
            if (propPathTemp.Contains("tree") || propPathTemp.Contains("log") || propPathTemp.Contains("bush") || propPathTemp.Contains("pod"))
            {
                rt.TreeProps.Add(propPath);
            }
            else if (propPathTemp.Contains("rock") || propPathTemp.Contains("berg") || propPathTemp.Contains("boulder"))
            {
                rt.RockProps.Add(propPath);
            }
            else
            {
                rt.OtherProps.Add(propPath);
            }

        }
        return rt;
    }
}