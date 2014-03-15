// ***************************************************************************************
// * Supreme Commander Random Map Generator
// * Copyright 2014  Jonathan Brewer
// * Filename: ReclaimableProp.cs
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


using System.IO.Compression;
using System.IO;
using System;

public class ReclaimableProp : Prop
{
    private double _massValue;
    private double _energyValue;
    private double reclaimTime;
    public double MassValue
    {
        get { return _massValue; }
        set { _massValue = value; }
    }
    public double EnergyValue
    {
        get { return _energyValue; }
        set { _energyValue = value; }
    }

    public ReclaimableProp(string path)
    {
        this.BlueprintPath = path;
        GetPropReclaimValues();
    }
    private void GetPropReclaimValues()
    {
        string env = "C:\\Program Files (x86)\\THQ\\Gas Powered Games\\Supreme Commander - Forged Alliance\\gamedata\\env.scd";
        ZipArchive z = ZipFile.OpenRead(env);
        ZipArchiveEntry zae = FindEntry(this.BlueprintPath, z);
        if ((zae != null))
        {
            StreamReader bp = new StreamReader(zae.Open());
            string temp = bp.ReadToEnd();
            temp = temp.Replace("PropBlueprint", "PropBlueprint=");
            temp = temp.Replace("Sound", "");
            temp = temp.Replace("#", "--");
            LuaInterface.Lua a = new LuaInterface.Lua();
            a.DoString(temp, "DataFile");
            double mVal, eVal;
            double.TryParse(a["PropBlueprint.Economy.ReclaimMassMax"].ToString(), out mVal);
            double.TryParse(a["PropBlueprint.Economy.ReclaimEnergyMax"].ToString(), out eVal);
            MassValue = mVal;
            EnergyValue = eVal;
        }
    }
    private ZipArchiveEntry FindEntry(string path, ZipArchive za)
    {
        ZipArchiveEntry rt = null;
        System.Collections.ObjectModel.ReadOnlyCollection<ZipArchiveEntry> currEntryList = za.Entries;
        path = path.Remove(0, 1);
        foreach (ZipArchiveEntry entry in za.Entries)
        {
            if (entry.FullName.Equals(path, StringComparison.InvariantCultureIgnoreCase))
            {
                rt = entry;
                break;
            }
        }
        return rt;
    }

}