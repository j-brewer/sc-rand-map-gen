// ***************************************************************************************
// * Supreme Commander Random Map Generator
// * Copyright 2014  Jonathan Brewer
// * Filename: ScenarioFile.cs
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

public class ScenarioFile
{
    public string Name;
    public string Description;
    public ScenarioTypes ScenarioType;
    public string Preview;
    public int MapWidth;
    public int MapHeight;
    public int NoRushRadius;
    private int _ArmyCount;
    private string MapFolderName;
    private string MapFileName;
    public Vector2[] ArmyNoRushOffset = new Vector2[0];

    public int ArmyCount
    {
        get { return _ArmyCount; }
        set
        {
            if (ArmyCount == 1 | ArmyCount > 12)
            {
                throw new ArgumentException("Invalid Army Count!  Army count must be greater than 1 and less than 13");
            }
            else
            {
                int aCount = _ArmyCount;
                _ArmyCount = value;
                Array.Resize(ref ArmyNoRushOffset, _ArmyCount);
                for (int i = aCount; i <= value - 1; i++)
                {
                    ArmyNoRushOffset[i] = new Vector2(0, 0);
                }
            }
        }
    }
    private string _MapPath;
    private string _MapSavePath;
    private string _MapScriptPath;
    private string _ScenarioPath;
    public string MapPath
    {
        get { return _MapPath; }
        set
        {
            System.IO.FileInfo f = new System.IO.FileInfo(value);
            MapFolderName = f.DirectoryName.Substring(f.DirectoryName.LastIndexOf("\\") + 1, (f.DirectoryName.Length - 1) - f.DirectoryName.LastIndexOf("\\"));
            MapFileName = f.Name.Replace(f.Extension, "");
            _MapPath = value;
            _MapSavePath = f.DirectoryName + "\\" + MapFileName + "_save.lua";
            _MapScriptPath = f.DirectoryName + "\\" + MapFileName + "_script.lua";
            _ScenarioPath = f.DirectoryName + "\\" + MapFileName + "_scenario.lua";
        }
    }
    public string MapSavePath
    {
        get { return _MapSavePath; }
    }
    public string MapScriptPath
    {
        get { return _MapScriptPath; }
    }
    public string FormattedMapPath
    {
        get { return "/maps/" + MapFolderName + "/" + MapFileName + ".scmap"; }
    }
    public string FormattedMapSavePath
    {
        get { return "/maps/" + MapFolderName + "/" + MapFileName + "_save.lua"; }
    }
    public string FormattedMapScriptPath
    {
        get { return "/maps/" + MapFolderName + "/" + MapFileName + "_script.lua"; }
    }
    public int ScenarioFileSpecVersion
    {
        get { return 3; }
    }
    public ScenarioFile(int playerCount, Point mapSize, string mapPath)
    {
        ArmyCount = playerCount;
        MapWidth = mapSize.X;
        MapHeight = mapSize.Y;
        this.MapPath = mapPath;
        NoRushRadius = Math.Max(MapWidth, MapHeight) / 5;
        ScenarioType = ScenarioTypes.skirmish;
    }
    public void Save()
    {
        System.IO.StreamWriter sf = new System.IO.StreamWriter(_ScenarioPath, false);
        sf.WriteLine("version = " + ScenarioFileSpecVersion);
        sf.WriteLine("ScenarioInfo =");
        sf.WriteLine("{");
        sf.WriteLine("    name = '" + this.Name + "',");
        sf.WriteLine("    description = '" + this.Description + "',");
        sf.WriteLine("    type = '" + this.ScenarioType.ToString() + "',");
        sf.WriteLine("    starts = true,");
        sf.WriteLine("    preview = '" + this.Preview + "',");
        sf.WriteLine("    size = {" + this.MapWidth + ", " + this.MapHeight + "},");
        sf.WriteLine("    norushradius = " + Convert.ToInt32(Math.Max(this.MapHeight, this.MapWidth) / 5) + ",");

        for (int i = 1; i <= ArmyCount; i++)
        {
            Vector2 temp = ArmyNoRushOffset[i - 1];
            sf.WriteLine("    norushoffsetX_ARMY_" + i + " = " + temp.X + ",");
            sf.WriteLine("    norushoffsetY_ARMY_" + i + " = " + temp.Y + ",");
        }
        sf.WriteLine("    map = '" + this.FormattedMapPath + "',");
        sf.WriteLine("    save = '" + this.FormattedMapSavePath + "',");
        sf.WriteLine("    script = '" + this.FormattedMapScriptPath + "',");
        sf.WriteLine("    Configurations = {");
        sf.WriteLine("        ['standard'] = {");
        sf.WriteLine("            teams =");
        sf.WriteLine("            {");
        sf.WriteLine("                {");
        sf.WriteLine("                    name = 'FFA',");
        sf.Write("                    armies = {");
        for (int j = 1; j <= ArmyCount; j++)
        {
            sf.Write("'ARMY_" + j + "'");
            if (j < ArmyCount)
            {
                sf.Write(",");
            }
        }
        sf.WriteLine("},");
        sf.WriteLine("                },");
        sf.WriteLine("            },");
        sf.WriteLine("            customprops =");
        sf.WriteLine("            {");
        sf.WriteLine("                ['ExtraArmies'] = STRING( 'ARMY_20 NEUTRAL_CIVILIAN' ),");
        sf.WriteLine("            },");
        sf.WriteLine("        },");
        sf.WriteLine("    }");
        sf.WriteLine("}");
        sf.Close();
    }

}