// ***************************************************************************************
// * Supreme Commander Random Map Generator
// * Copyright 2014  Jonathan Brewer
// * Filename: Utilities.cs
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
using System.Collections;
using System.Collections.Generic;

public sealed class Utilities
{
    private Utilities()
    {
    }
    public static string ChooseRandomString(Random r, string[] arrayToChooseFrom)
    {
        if (arrayToChooseFrom.Length > 0)
        {
            return arrayToChooseFrom[r.Next(0, arrayToChooseFrom.Length - 1)];
        }
        else
        {
            return "";
        }
    }
    public static Vector2 GetRandomVector2(Random r)
    {
        float a = (float)r.NextDouble();
        float b = (float)r.NextDouble();
        return new Vector2(a, b);
    }
    public static Vector3 GetRandomVector3(Random r)
    {
        float a = (float)r.NextDouble();
        float b = (float)r.NextDouble();
        float c = (float)r.NextDouble();
        return new Vector3(a, b, c);
    }
    public static Vector4 GetRandomVector4(Random r)
    {
        float a = (float)r.NextDouble();
        float b = (float)r.NextDouble();
        float c = (float)r.NextDouble();
        float d = (float)r.NextDouble();
        return new Vector4(a, b, c, d);
    }
    public static bool GetRandomBoolean(Random r)
    {
        int a = r.Next(2);
        return (a == 1);
    }
    public static string GetScDir()
    {
        Microsoft.Win32.RegistryKey rk = null;
        rk = Microsoft.Win32.Registry.LocalMachine.OpenSubKey("SOFTWARE\\THQ\\Gas Powered Games\\Supreme Commander", false);
        if (rk == null)
            return "";
        return rk.GetValue("InstallationDirectory").ToString();
    }
    public static double CalculateFairnessScore(List<double> MassSpotScoreMatrix)
    {
        double rtVal = 0;
        if(MassSpotScoreMatrix.Count > 0)
        {
            double min = double.MaxValue;
            double max = double.MinValue;
            double total = 0;
            foreach (double a in MassSpotScoreMatrix)
            {
                min = Math.Min(a, min);
                max = Math.Max(a, max);
                total += a;
            }
            rtVal = 1.0 - ((max - min) / total);
        }
        return rtVal;
    }

    public static int[] GetShuffledIntegerArray(int start, int end, Random r)
    {
        int[] arr = new int[end - start + 1];
        for (int i = 0; i < arr.Length; i++)
        {
            arr[i] = start + i;
        }
        return (int[])Shuffle(arr, r);
    }
    public static IList<T> Shuffle<T>(IList<T> list, Random rnd)
    {
        for (var i = 0; i < list.Count; i++)
        {
            int j = rnd.Next(i, list.Count);
            var temp = list[i];
            list[i] = list[j];
            list[j] = temp;
        }

        return list;
    }
}