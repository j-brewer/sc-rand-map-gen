// ***************************************************************************************
// * Supreme Commander Random Map Generator
// * Copyright 2014  Jonathan Brewer
// * Filename: PlanetNameGenerator.cs
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
using System.IO;

public class PlanetNameGenerator
{
    private List<string> suffixListA;
    private List<string> suffixListB;
    private List<string> baseNameList;
    private MarkovNameGenerator mng;
    private Random r;
    public PlanetNameGenerator(int rngSeed)
    {
        this.r = new Random(rngSeed);
        suffixListA = new List<string>();
        suffixListB = new List<string>();
        baseNameList = new List<string>();
        GetNameLists();
        mng = new MarkovNameGenerator(baseNameList, 3, 5, r);
    }
    public string NextName()
    {
        string tName = "";
        tName = tName + mng.NextName;
        if (r.Next(0, 2) == 1)
        {
            tName = tName + " " + suffixListA[r.Next(0, suffixListA.Count)];
        }
        tName = tName + " " + suffixListB[r.Next(0, suffixListB.Count)];
        return tName;
    }
    private void GetNameLists()
    {
        string strPath = System.AppDomain.CurrentDomain.BaseDirectory;
        StreamReader s = new StreamReader(strPath + "\\..\\..\\..\\Misc Data\\PlanetNameList.txt");
        int listNumber = 1;
        while (!s.EndOfStream)
        {
            string temp = s.ReadLine();
            if (string.IsNullOrEmpty(temp))
            {
                listNumber = listNumber + 1;
            }
            else if (listNumber == 1)
            {
                suffixListA.Add(temp);
            }
            else if (listNumber == 2)
            {
                baseNameList.Add(temp);
            }
            else if (listNumber == 3)
            {
                suffixListB.Add(temp);
            }
        }
    }
}