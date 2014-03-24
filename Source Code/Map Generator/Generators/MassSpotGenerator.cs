// ***************************************************************************************
// * Supreme Commander Random Map Generator
// * Copyright 2014  Jonathan Brewer
// * Filename: MassSpotGenerator.cs
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

public class MassSpotGenerator
{
	private double  HeightTolerance = 15;
	private int  MaxAttemptsPerMassSpot = 100;
	private HeightMap hMap;
	private Random r;
	private List<Marker> massMarkerList;
	private bool generationDone;
	private int lastMassId;
	private float waterElevation;
	private bool _allowUnderwaterMassSpots;
	private List<Marker> startingPositionList;
	public bool AllowUnderwaterMassSpots {
		get { return _allowUnderwaterMassSpots; }
		set { _allowUnderwaterMassSpots = value; }
	}
	public MassSpotGenerator(HeightMap h, float mapWaterElevation, List<Marker> startPositionList, int rngSeed)
	{
		massMarkerList = new List<Marker>();
		hMap = h;
		this.r = new Random(rngSeed);
		this.generationDone = false;
		lastMassId = 1;
		waterElevation = mapWaterElevation;
		AllowUnderwaterMassSpots = true;
		startingPositionList = startPositionList;
	}
	public List<Marker> GetFinalMassSpotList()
	{
		if (generationDone) {
			throw new InvalidOperationException("The final mass spot list cannot be retrieved more than once.");
		}
		generationDone = true;
		return massMarkerList;
	}
	public int MassSpotCount {
		get { return massMarkerList.Count; }
	}
	public void AddStartLocationMassSpots()
	{
		if (MassSpotCount > 0) {
			throw new InvalidOperationException("Starting location mass spots can only be added to an empty mass spot list.");
		}
		foreach (Marker startPoint in startingPositionList) {
			if (startPoint.Name.StartsWith("ARMY_")) {
				MassMarker ms = new MassMarker("Mass " + lastMassId.ToString("D3"));
				float iX = startPoint.Position.X;
                float iY = startPoint.Position.Z;

                ms.Position = new Vector3((iX + 4), (float)hMap.GetFAHeight((int)(iX + 4), (int)iY),iY);
                ms.IsStartingMassSpot = true;
				massMarkerList.Add(ms);
				lastMassId = lastMassId + 1;

				ms = new MassMarker("Mass " + lastMassId.ToString("D3"));
                ms.Position = new Vector3((iX - 4), (float)hMap.GetFAHeight((int)(iX - 4), (int)iY), iY);
                ms.IsStartingMassSpot = true;
				massMarkerList.Add(ms);
				lastMassId = lastMassId + 1;

				ms = new MassMarker("Mass " + lastMassId.ToString("D3"));
                ms.Position = new Vector3(iX, (float)hMap.GetFAHeight((int)iX, (int)(iY + 4)), iY + 4);
                ms.IsStartingMassSpot = true;
				massMarkerList.Add(ms);
				lastMassId = lastMassId + 1;

				ms = new MassMarker("Mass " + lastMassId.ToString("D3"));
                ms.Position = new Vector3(iX, (float)hMap.GetFAHeight((int)iX, (int)(iY - 4)), iY - 4);
                ms.IsStartingMassSpot = true;
				massMarkerList.Add(ms);
				lastMassId = lastMassId + 1;
			}
		}
	}
	public void AddStartLocationBasedMassSpots(int MassSpotsPerStartLocation, int MinDistance, int MaxDistance)
	{
		int windowSize = 16;
		double radius = 0;
		double theta = 0;
		int a = 0;
		int b = 0;
		int tries = 0;
		bool placed = false;
		Point p = Point.Empty;
		for (int k = 0; k <= startingPositionList.Count - 1; k++) {
			int iX = (int)startingPositionList[k].Position.X;
			int iY = (int)startingPositionList[k].Position.Z;

			for (int i = 1; i <= MassSpotsPerStartLocation; i++) {
				placed = false;
				tries = 0;

				while (!placed & tries < MaxAttemptsPerMassSpot) {
					radius = r.NextDouble() * (MaxDistance - MinDistance) + MinDistance;
					theta = r.NextDouble() * Math.PI * 2;
					a = (int)(Math.Round(radius * Math.Cos(theta)) + iX);
					b = (int)(Math.Round(radius * Math.Sin(theta)) + iY);

					if (!(a - windowSize / 2 < 0 | a + windowSize / 2 > hMap.Width | b - windowSize / 2 < 0 | b + windowSize / 2 > hMap.Height)) {
						Rectangle rect = new Rectangle(a - windowSize / 2, b - windowSize / 2, windowSize, windowSize);
						p = FindSuitableLocation(rect, 0);
						if (!p.Equals(Point.Empty)) {
							MassMarker ms = new MassMarker("Mass " + lastMassId.ToString("D3"));
                            ms.Position = new Vector3((float)(p.X + 0.5), (float)hMap.GetFAHeight(p.X, p.Y), (float)(p.Y + 0.5));
							massMarkerList.Add(ms);
							lastMassId = lastMassId + 1;
							placed = true;
						}
					}
					tries = tries + 1;
				}
				if (p.Equals(Point.Empty)) {
					Console.WriteLine("Warning: Placement of a mass spot failed for start point at " + iX + ", " + iY + ".");
				}
			}
		}
	}
    public void BuildRandomDisributionMassSpotList(int massSpots, int minDistanceFromStartPoint)
	{
        int placedCount = 0;
        int loopCount = 0;
		while(placedCount < massSpots && loopCount < 4000)
        {
			Rectangle rect = new Rectangle(0, 0, hMap.Width, hMap.Height);
			Point p = FindSuitableLocation(rect, minDistanceFromStartPoint);
			if (!p.Equals(Point.Empty))
            {
				MassMarker ms = new MassMarker("Mass " + lastMassId.ToString("D3"));
                ms.Position = new Vector3((float)(p.X + 0.5), (float)hMap.GetFAHeight(p.X, p.Y), (float)(p.Y + 0.5));
				massMarkerList.Add(ms);
				lastMassId++;
                placedCount++;
			}
            loopCount++;
		}
    }
	public void BuildRandomDisributionMassSpotList(int MassDensity, int MassDensityVariance, int minDistanceFromStartPoint)
	{
		int md = Math.Max(Math.Min(MassDensity, 100), 1);
		int windowSize = 256;
		if (MassDensity > 0) {
			for (int j = windowSize / 2; j <= hMap.Height - (windowSize / 2 + 1); j += windowSize) {
				for (int i = windowSize / 2; i <= hMap.Width - (windowSize / 2 + 1); i += windowSize) {
					int l = 0;
					if (MassDensityVariance > 0) {
						l = md + r.Next(-MassDensityVariance, MassDensityVariance + 1);
					} else {
						l = md;
					}
					for (int k = 1; k <= l; k++) {
						Rectangle rect = new Rectangle(i - windowSize / 2, j - windowSize / 2, windowSize, windowSize);
						Point p = FindSuitableLocation(rect, minDistanceFromStartPoint);
						if (!p.Equals(Point.Empty)) {
							MassMarker ms = new MassMarker("Mass " + lastMassId.ToString("D3"));
                            ms.Position = new Vector3((float)(p.X + 0.5), (float)hMap.GetFAHeight(p.X, p.Y), (float)(p.Y + 0.5));
							massMarkerList.Add(ms);
							lastMassId = lastMassId + 1;
						} else {
							//Console.WriteLine("Warning: Placement of a mass spot failed in the range " + rect.Left + ", " + rect.Top + " " + rect.Right + ", " + rect.Bottom + ".");
						}
					}
				}
			}
		}
	}
	private Point FindSuitableLocation(Rectangle bounds, double minDistanceFromStartPoint)
	{
		int realMinX = Math.Max(0, bounds.Left);
		int realMinY = Math.Max(0, bounds.Top);

		int realMaxX = Math.Min(bounds.Right, hMap.Width);
		int realMaxY = Math.Min(bounds.Bottom, hMap.Height);
		int tries = 0;
		while (tries < MaxAttemptsPerMassSpot) {
			int initialX = r.Next(realMinX + 2, realMaxX - 2);
			int initialY = r.Next(realMinY + 2, realMaxY - 2);

			if (IsFlat(new Rectangle(initialX, initialY, 2, 2))) {
				//Check flatness
				bool store1 = IsFlat(new Rectangle(initialX - 2, initialY, 2, 2));
				bool store2 = IsFlat(new Rectangle(initialX + 2, initialY, 2, 2));
				bool store3 = IsFlat(new Rectangle(initialX, initialY - 2, 2, 2));
				bool store4 = IsFlat(new Rectangle(initialX, initialY + 2, 2, 2));

				//Check water
				bool initialIsInWater = IsWater(initialX, initialY);
				store1 = store1 & (initialIsInWater | !IsWater(initialX - 2, initialY));
				store2 = store2 & (initialIsInWater | !IsWater(initialX + 2, initialY));
				store3 = store3 & (initialIsInWater | !IsWater(initialX, initialY - 2));
				store4 = store4 & (initialIsInWater | !IsWater(initialX, initialY + 2));

                bool isNotCollision = !this.IsMassSpotCollision((float)(initialX + 0.5f), (float)(initialY + 0.5f));
				bool isNotShore = IsNotShoreline(initialX, initialY);
				bool isNotToCloseToStartPosition = DistanceToClosestStartPosition(initialX, initialY) > minDistanceFromStartPoint;
				if (store1 & store2 & store3 & store4 & isNotCollision & (AllowUnderwaterMassSpots | !initialIsInWater) & isNotToCloseToStartPosition) {
					return new Point(initialX, initialY);
				}
			}
			tries = tries + 1;
		}
		return Point.Empty;
	}
	private bool IsNotShoreline(int posX, int posY)
	{
		bool rt = false;
		double cellHeight = hMap.GetFAHeight(posX, posY);
		if (cellHeight <= waterElevation - 3 | cellHeight > waterElevation + 1.0) {
			rt = true;
		}
		return rt;
	}
	private bool IsWater(int posX, int posY)
	{
		double cellHeight = hMap.GetFAHeight(posX, posY);
		return cellHeight <= waterElevation;
	}
	private bool IsFlat(Rectangle bounds)
	{
		bool result = true;
        if (bounds.Left < 0 || bounds.Right > hMap.Width || bounds.Top < 0 || bounds.Bottom > hMap.Height)
        {
            result = false;
        }
        else
        {
            for (int j = bounds.Top; j <= bounds.Bottom; j++)
            {
                for (int i = bounds.Left; i <= bounds.Right - 1; i++)
                {
                    if (Math.Abs(Convert.ToInt32(hMap.GetHeight(i, j)) - Convert.ToInt32(hMap.GetHeight(i + 1, j))) > HeightTolerance)
                    {
                        result = false;
                    }
                }
            }
            for (int j = bounds.Top; j <= bounds.Bottom - 1; j++)
            {
                for (int i = bounds.Left; i <= bounds.Right; i++)
                {
                    if (Math.Abs(Convert.ToInt32(hMap.GetHeight(i, j)) - Convert.ToInt32(hMap.GetHeight(i, j + 1))) > HeightTolerance)
                    {
                        result = false;
                    }
                }
            }
        }
		return result;
	}
	public static List<Marker> RemoveDuplicateMassSpots(List<Marker> listToCheck)
	{
		List<Marker> rtVal = new List<Marker>();
		for (int i = 0; i <= listToCheck.Count - 1; i++) {
			if ((listToCheck[i]) is MassMarker) {
				MassMarker a = (MassMarker)listToCheck[i];
				bool b = IsMassSpotCollision(a.Position.X, a.Position.Z, listToCheck, i + 1);
				if (b) {
					rtVal.Add(listToCheck[i]);
				}
			} else {
				rtVal.Add(listToCheck[i]);
			}
		}
		return rtVal;
	}
	private bool IsMassSpotCollision(float x, float y)
	{
		return MassSpotGenerator.IsMassSpotCollision(x, y, massMarkerList, 0);
	}
	private static bool IsMassSpotCollision(float x, float y, List<Marker> listToCheck, int startingIndex)
	{
		bool rtVal = false;
		for (int i = startingIndex; i <= listToCheck.Count - 1; i++) {
			if ((listToCheck[i]) is MassMarker) {
				MassMarker a = (MassMarker)listToCheck[i];
				int diffX = (int)Math.Abs(a.Position.X - x);
				int diffY = (int)Math.Abs(a.Position.Z - y);
				bool isCollision = true;
				if (Math.Abs(a.Position.X - x) < 6 & Math.Abs(a.Position.Z - y) < 6) {
					//If mass spots are close, certain configurations are allowed
					//Check to see if this is one...
					if ((diffX == 0 & diffY == 4) | (diffY == 0 & diffX == 4)) {
						isCollision = false;
					} else if ((diffX == 2 & (diffY == 2 | diffY == 4 | diffY == 5)) | (diffY == 2 & (diffX == 2 | diffX == 5 | diffX == 5))) {
						isCollision = false;
					} else if ((diffX == 3 & diffY == 5) | (diffY == 3 & diffX == 5)) {
						isCollision = false;
					} else if ((diffX == 4 & diffY != 1) | (diffY == 4 & diffX != 1)) {
						isCollision = false;
					} else if ((diffX == 5 & diffY > 1) | (diffY == 5 & diffX > 1)) {
						isCollision = false;
					}
				} else {
					isCollision = false;
				}
				rtVal = rtVal | isCollision;
			}
		}
		return rtVal;
	}
	private double DistanceToClosestStartPosition(int pX, int pY)
	{
		double rt = double.MaxValue;
		for (int k = 0; k <= startingPositionList.Count - 1; k++) {
			double d = GetDistance(new PointF(pX, pY), new PointF(startingPositionList[k].Position.X, startingPositionList[k].Position.Z));
			rt = Math.Min(rt, d);
		}
		return rt;
	}
	private static double GetDistance(PointF point1, PointF point2)
	{
		//pythagorean theorem c^2 = a^2 + b^2
		//thus c = square root(a^2 + b^2)
		double a = Convert.ToDouble(point2.X - point1.X);
		double b = Convert.ToDouble(point2.Y - point1.Y);
		return Math.Sqrt(a * a + b * b);
	}
    public double MassSpotFairnessScore()
    {
        double rt = 0;
        double[] distScore = new double[startingPositionList.Count];
        int massSpotCount = 0;
        for (int k = 0; k <= startingPositionList.Count - 1; k++)
        {
            distScore[k] = 0;
            PointF sp = new PointF(startingPositionList[k].Position.X, startingPositionList[k].Position.Z);
            foreach (MassMarker mm in massMarkerList)
            {
                //Exclude starting mass spots for scoring purposes.
                if (!mm.IsStartingMassSpot)
                {
                    distScore[k] += GetDistance(new PointF(mm.Position.X, mm.Position.Z), sp);
                    massSpotCount++;
                }
            }
        }
        double minScore = double.MaxValue;
        double maxScore = double.MinValue;

        for (int k = 0; k <= startingPositionList.Count - 1; k++)
        {
            distScore[k] = distScore[k] / massSpotCount;
            minScore = Math.Min(distScore[k], minScore);
            maxScore = Math.Max(distScore[k], maxScore);
        }
        rt = Math.Max(0, 1.0 - ((maxScore - minScore) / minScore));

        return rt;
    }
}