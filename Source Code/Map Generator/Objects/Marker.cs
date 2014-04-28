// ***************************************************************************************
// * Supreme Commander Random Map Generator
// * Copyright 2014  Jonathan Brewer
// * Filename: Marker.cs
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
using System.Collections.Generic;

public abstract class Marker
{
    public string Name;
    public Dictionary<string, MarkerProperty> Properties = new Dictionary<string, MarkerProperty>();
    public new string ToString()
    {
        string s = null;
        s = "                ['" + Name + "'] = {" + Environment.NewLine;
        foreach (KeyValuePair<string, MarkerProperty> mp in Properties)
        {
            s = s + "                    ['" + mp.Key + "'] = " + mp.Value.ToString() + "," + Environment.NewLine;
        }
        s = s + "                },";
        return s;
    }
    public Vector3 Position
    {
        get
        {
            string[] temp = Properties["position"].value.Split(new char[]{','});
            return new Vector3(float.Parse(temp[0]), float.Parse(temp[1]), float.Parse(temp[2]));
        }
        set
        {
            string temp = value.X + ", " + value.Y + ", " + value.Z;
            Properties["position"].value = temp;
        }
    }
    public Vector3 Orientation
    {
        get
        {
            string[] temp = Properties["orientation"].value.Split(new char[] { ',' });
            return new Vector3(float.Parse(temp[0]), float.Parse(temp[1]), float.Parse(temp[2]));
        }
        set
        {
            string temp = value.X + ", " + value.Y + ", " + value.Z;
            Properties["orientation"].value = temp;
        }
    }

    internal Marker()
    {
        this.Properties.Add("color", new MarkerProperty(MarkerPropertyType.StringType, "ff800080"));
        this.Properties.Add("type", new MarkerProperty(MarkerPropertyType.StringType, "Blank Marker"));
        this.Properties.Add("prop", new MarkerProperty(MarkerPropertyType.StringType, "/env/common/props/markers/M_Blank_prop.bp"));
        this.Properties.Add("orientation", new MarkerProperty(MarkerPropertyType.Vector3Type, "0, -0, 0"));
        this.Properties.Add("position", new MarkerProperty(MarkerPropertyType.Vector3Type, "0, -0, 0"));
        this.Properties.Add("hint", new MarkerProperty(MarkerPropertyType.BooleanType, "true"));
    }
}

public class MarkerProperty
{
    public string value;
    public MarkerPropertyType datatype;
    public new string ToString()
    {
        string t = value;
        if (datatype.ToString() == "STRING")
        {
            t = "'" + t + "'";
        }
        return datatype.ToString() + "( " + t + " )";
    }
    public MarkerProperty(MarkerPropertyType datatype, string value)
    {
        this.value = value;
        this.datatype = datatype;
    }
}
public sealed class MarkerPropertyType
{

    private readonly string name;

    private readonly int value;
    public static readonly MarkerPropertyType BooleanType = new MarkerPropertyType(1, "BOOLEAN");
    public static readonly MarkerPropertyType StringType = new MarkerPropertyType(1, "STRING");
    public static readonly MarkerPropertyType Vector3Type = new MarkerPropertyType(1, "VECTOR3");

    public static readonly MarkerPropertyType FloatType = new MarkerPropertyType(1, "FLOAT");
    private MarkerPropertyType(int value, string name)
    {
        this.name = name;
        this.value = value;
    }
    public new string ToString()
    {
        return name;
    }
}





public class BlankMarker : Marker
{
    public BlankMarker(string name)
    {
        this.Name = name;
    }
}

public class CombatZoneMarker : Marker
{
    public CombatZoneMarker(string name)
    {
        this.Name = name;
        this.Properties["color"].value = "ff800000";
        this.Properties["type"].value = "Combat Zone";
        this.Properties["prop"].value = "/env/common/props/markers/M_CombatZone_prop.bp";
    }
}

public class NavalAreaMarker : Marker
{
    public NavalAreaMarker(string name)
    {
        this.Name = name;
        this.Properties["color"].value = "ff0000ff";
        this.Properties["type"].value = "Naval Area";
        this.Properties["prop"].value = "/env/common/props/markers/M_Expansion_prop.bp";
    }
}

public class ExpansionAreaMarker : Marker
{
    public ExpansionAreaMarker(string name)
    {
        this.Name = name;
        this.Properties["color"].value = "ff008080";
        this.Properties["type"].value = "Expansion Area";
        this.Properties["prop"].value = "/env/common/props/markers/M_Expansion_prop.bp";
    }
}

public class MassMarker : Marker
{
    public MassMarker(string name)
    {
        this.Name = name;
        this.Properties["color"].value = "ff808080";
        this.Properties["type"].value = "Mass";
        this.Properties["prop"].value = "/env/common/props/markers/M_Mass_prop.bp";

        this.Properties.Add("editorIcon", new MarkerProperty(MarkerPropertyType.StringType, "/textures/editor/marker_mass.bmp"));
        this.Properties.Add("amount", new MarkerProperty(MarkerPropertyType.FloatType, "100.000000"));
        this.Properties.Add("size", new MarkerProperty(MarkerPropertyType.FloatType, "1.000000"));
        this.Properties.Add("resource", new MarkerProperty(MarkerPropertyType.BooleanType, "true"));
        this.MassSpotScoreMatrix = new List<double>();
    }

    public bool IsStartingMassSpot;
    public List<double> MassSpotScoreMatrix;
    public int MassSpotNumber;
    public double GetMassSpotFairness()
    {
        return Utilities.CalculateFairnessScore(MassSpotScoreMatrix);
    }
}

public class DefensivePointMarker : Marker
{
    public DefensivePointMarker(string name)
    {
        this.Name = name;
        this.Properties["color"].value = "ff008000";
        this.Properties["type"].value = "Defensive Point";
        this.Properties["prop"].value = "/env/common/props/markers/M_Defensive_prop.bp";
    }
}

public class ProtectedExperimentalConstructionMarker : Marker
{
    public ProtectedExperimentalConstructionMarker(string name)
    {
        this.Name = name;
        this.Properties["color"].value = "ff0000AA";
        this.Properties["type"].value = "Protected Experimental Construction";
        this.Properties["prop"].value = "/env/common/props/markers/M_Expansion_prop.bp";
    }
}

public class IslandMarker : Marker
{
    public IslandMarker(string name)
    {
        this.Name = name;
        this.Properties["color"].value = "ff0000AA";
        this.Properties["type"].value = "Island";
        this.Properties["prop"].value = "/env/common/props/markers/M_CombatZone_prop.bp";
    }
}

public class RallyPointMarker : Marker
{
    public RallyPointMarker(string name)
    {
        this.Name = name;
        this.Properties["color"].value = "FF808000";
        this.Properties["type"].value = "Rally Point";
        this.Properties["prop"].value = "/env/common/props/markers/M_Defensive_prop.bp";
    }
}

public class HydrocarbonMarker : Marker
{
    public HydrocarbonMarker(string name)
    {
        this.Name = name;
        this.Properties["color"].value = "ff008000";
        this.Properties["type"].value = "Hydrocarbon";
        this.Properties["prop"].value = "/env/common/props/markers/M_Hydrocarbon_prop.bp";

        this.Properties.Add("amount", new MarkerProperty(MarkerPropertyType.FloatType, "100.000000"));
        this.Properties.Add("size", new MarkerProperty(MarkerPropertyType.FloatType, "3.000000"));
        this.Properties.Add("resource", new MarkerProperty(MarkerPropertyType.BooleanType, "true"));
    }
}

public class CameraInfoMarker : Marker
{
    public CameraInfoMarker(string name)
    {
        this.Name = name;
        this.Properties["color"].value = "ff808000";
        this.Properties["type"].value = "Camera Info";
        this.Properties["prop"].value = "/env/common/props/markers/M_Camera_prop.bp";

        this.Properties.Remove("hint");

        this.Properties.Add("zoom", new MarkerProperty(MarkerPropertyType.FloatType, "0"));
        this.Properties.Add("canSetCamera", new MarkerProperty(MarkerPropertyType.BooleanType, "true"));
        this.Properties.Add("canSyncCamera", new MarkerProperty(MarkerPropertyType.BooleanType, "true"));
    }
}

public class WeatherGeneratorMarker : Marker
{
    public WeatherGeneratorMarker(string name)
    {
        this.Name = name;
        this.Properties["color"].value = "FF808000";
        this.Properties["type"].value = "Weather Generator";
        this.Properties["prop"].value = "/env/common/props/markers/M_Defensive_prop.bp";

        this.Properties.Add("cloudCountRange", new MarkerProperty(MarkerPropertyType.FloatType, "0.000000"));
        this.Properties.Add("ForceType", new MarkerProperty(MarkerPropertyType.StringType, "None"));
        this.Properties.Add("cloudHeightRange", new MarkerProperty(MarkerPropertyType.FloatType, "15.000000"));
        this.Properties.Add("cloudSpread", new MarkerProperty(MarkerPropertyType.FloatType, "150.000000"));
        this.Properties.Add("spawnChance", new MarkerProperty(MarkerPropertyType.FloatType, "1.000000"));
        this.Properties.Add("cloudEmitterScaleRange", new MarkerProperty(MarkerPropertyType.FloatType, "0.000000"));
        this.Properties.Add("cloudEmitterScale", new MarkerProperty(MarkerPropertyType.FloatType, "1.000000"));
        this.Properties.Add("cloudCount", new MarkerProperty(MarkerPropertyType.FloatType, "10"));
        this.Properties.Add("cloudHeight", new MarkerProperty(MarkerPropertyType.FloatType, "180"));
    }
}

public class WeatherDefinitionMarker : Marker
{
    public WeatherDefinitionMarker(string name)
    {
        this.Name = name;
        this.Properties["color"].value = "FF808000";
        this.Properties["type"].value = "Weather Definition";
        this.Properties["prop"].value = "/env/common/props/markers/M_Defensive_prop.bp";

        this.Properties.Add("MapStyle", new MarkerProperty(MarkerPropertyType.StringType, "Tundra"));
        this.Properties.Add("WeatherDriftDirection", new MarkerProperty(MarkerPropertyType.Vector3Type, "1, 0, 0"));

        this.Properties.Add("WeatherType01", new MarkerProperty(MarkerPropertyType.StringType, "SnowClouds"));
        this.Properties.Add("WeatherType01Chance", new MarkerProperty(MarkerPropertyType.FloatType, "0.300000"));
        this.Properties.Add("WeatherType02", new MarkerProperty(MarkerPropertyType.StringType, "WhiteThickClouds"));
        this.Properties.Add("WeatherType02Chance", new MarkerProperty(MarkerPropertyType.FloatType, "0.300000"));
        this.Properties.Add("WeatherType03", new MarkerProperty(MarkerPropertyType.StringType, "WhitePatchyClouds"));
        this.Properties.Add("WeatherType03Chance", new MarkerProperty(MarkerPropertyType.FloatType, "0.300000"));
        this.Properties.Add("WeatherType04", new MarkerProperty(MarkerPropertyType.StringType, "None"));
        this.Properties.Add("WeatherType04Chance", new MarkerProperty(MarkerPropertyType.FloatType, "0.100000"));
    }
}