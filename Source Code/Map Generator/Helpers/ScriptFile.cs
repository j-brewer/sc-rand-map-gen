// ***************************************************************************************
// * Supreme Commander Random Map Generator
// * Copyright 2014  Jonathan Brewer
// * Filename: ScriptFile.cs
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


public class ScriptFile
{
    public static void SaveScriptFile(string path)
    {
        System.IO.StreamWriter sf = new System.IO.StreamWriter(path, false);
        sf.WriteLine("local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')");
        sf.WriteLine("local ScenarioFramework = import('/lua/ScenarioFramework.lua')");
        sf.WriteLine("");
        sf.WriteLine("function OnPopulate()");
        sf.WriteLine("    ScenarioUtils.InitializeArmies()");
        sf.WriteLine("end");
        sf.WriteLine("function OnStart(self)");
        sf.WriteLine("");
        sf.WriteLine("end");
        sf.Close();
    }
}