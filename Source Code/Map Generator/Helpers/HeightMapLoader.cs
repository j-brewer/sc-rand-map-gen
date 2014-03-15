// ***************************************************************************************
// * Supreme Commander Random Map Generator
// * Copyright 2014  Jonathan Brewer
// * Filename: HeightMapLoader.cs
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


using System.IO;

public class HeightMapLoader
{
    public static HeightMap LoadPGMHeightmap(string filename)
    {
        HeightMap h = default(HeightMap);
        StreamReader fsIn = new StreamReader(filename);
        string[] currArr = null;
        int currPosition = 0;
        int globalPosition = 0;

        string header = fsIn.ReadLine();
        if (!(header == "P2"))
        {
            throw new InvalidDataException("Input file is not a recognized PGM file format!");
        }


        string[] d = fsIn.ReadLine().Split(new char[] { ' ' });
        int mw = int.Parse(d[0]);
        int mh = int.Parse(d[1]);
        int max = int.Parse(fsIn.ReadLine());

        double scaleRatio = 1;
        h = new HeightMap(mw, mh);

        currArr = fsIn.ReadLine().Split(new char[] { ' ' });

        for (int j = 0; j <= mh; j++)
        {
            for (int i = 0; i <= mw - 1; i++)
            {
                globalPosition += 1;
                ushort v = (ushort)(scaleRatio * float.Parse(currArr[currPosition]));
                currPosition = currPosition + 1;
                if (currPosition == currArr.Length)
                {
                    currPosition = 0;
                    if (!fsIn.EndOfStream)
                    {
                        currArr = fsIn.ReadLine().Split(new char[] { ' ' });
                    }
                }
                h.SetHeight(i, j, v);
            }
        }
        fsIn.Close();

        return h;
    }
}