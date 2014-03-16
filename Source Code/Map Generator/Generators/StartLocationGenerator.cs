// ***************************************************************************************
// * Supreme Commander Random Map Generator
// * Copyright 2014  Jonathan Brewer
// * Filename: StartLocationGenerator.cs
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
using System.Drawing;

public class StartLocationGenerator
{
	private double  HeightTolerance = 20;
	private int  MaxAttemptsPerStartLocation = 500;
	private int  StartArea = 8;
    private int MaxVariance = 32;
	private HeightMap hMap;
	private HeightMap sList;
	private Random r;
	private List<Marker> rt;
	public StartLocationGenerator(HeightMap h, HeightMap startList, Random r)
	{
		hMap = h;
		this.r = r;
		this.sList = startList;
	}
	public List<Marker> BuildStartLocationList()
	{
		rt = new List<Marker>();
		for (int k = 0; k <= sList.Width - 2; k++) {
			int iX = sList.GetHeight(k, 0);
			int iY = sList.GetHeight(k, 1);
			int oX = 0;
			int oY = 0;
			bool done = false;
			int counter = 0;
			while (done == false & counter < MaxAttemptsPerStartLocation) {
				Rectangle sArea = new Rectangle(iX - StartArea + oX, iY - StartArea + oY, 2 * StartArea, 2 * StartArea);
				if (IsFlat(sArea)) {
					done = true;
					BlankMarker sp = new BlankMarker("ARMY_" + ((int)k + 1));
                    sp.Position = new Vector3((float)(iX + 0.5), (float)hMap.GetFAHeight(iX, iY), (float)(iY + 0.5));
					rt.Add(sp);
				} else {
					counter = counter + 1;
					oX = r.Next(-MaxVariance, MaxVariance);
					oY = r.Next(-MaxVariance, MaxVariance);

					if (counter >= MaxAttemptsPerStartLocation) {
						throw new Exception("Could not find a viable starting location for army " + k + 1 + "!  Attempted Coordinates: " + iX + "," + iY + ".");
					}
				}
			}
		}
		return rt;
	}
	private bool IsFlat(Rectangle bounds)
	{
		bool result = true;
		for (int j = bounds.Top; j <= bounds.Bottom; j++) {
			for (int i = bounds.Left; i <= bounds.Right - 1; i++) {
				if (Math.Abs(Convert.ToInt32(hMap.GetHeight(i, j)) - Convert.ToInt32(hMap.GetHeight(i + 1, j))) > HeightTolerance) {
					result = false;
				}
			}
		}
		for (int j = bounds.Top; j <= bounds.Bottom - 1; j++) {
			for (int i = bounds.Left; i <= bounds.Right; i++) {
				if (Math.Abs(Convert.ToInt32(hMap.GetHeight(i, j)) - Convert.ToInt32(hMap.GetHeight(i, j + 1))) > HeightTolerance) {
					result = false;
				}
			}
		}
		return result;
	}
}