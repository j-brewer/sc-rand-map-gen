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
    Stack<int> availableMassSpotIds;
	private float waterElevation;
	private bool _allowUnderwaterMassSpots;
	private List<Marker> startingPositionList;
    private double maxPossibleDistance;
	public bool AllowUnderwaterMassSpots {
		get { return _allowUnderwaterMassSpots; }
		set { _allowUnderwaterMassSpots = value; }
	}
    private int goalMassSpotsPerPlayer;
    public double FinalMassPlacementScore;

    private int MassSpotCount
    {
        get { return massMarkerList.Count; }
    }

	public MassSpotGenerator(HeightMap h, int desiredMassSpotsPerPlayer, float mapWaterElevation, List<Marker> startPositionList, int rngSeed)
	{
        FinalMassPlacementScore = 0.0;
        goalMassSpotsPerPlayer = desiredMassSpotsPerPlayer;
		massMarkerList = new List<Marker>();
		hMap = h;
		this.r = new Random(rngSeed);
		this.generationDone = false;
		waterElevation = mapWaterElevation;
		AllowUnderwaterMassSpots = true;
		startingPositionList = startPositionList;
        maxPossibleDistance = Math.Sqrt((hMap.Width * hMap.Width) + (hMap.Height * hMap.Height));

        availableMassSpotIds = new Stack<int>();
        for (int k = 1024; k > 0; k--)
        {
             availableMassSpotIds.Push(k);
        }
	}
    public List<Marker> GenerateMassSpots()
    {
        int massDensity = r.Next(0, 14);
        int massDensityA = r.Next(0, massDensity);
        //int massDensityB = r.Next(0, Math.Max(0, massDensity - massDensityA));
        int massDensityB = r.Next(0, Math.Max(0, massDensity - massDensityA));
        int massDensityC = Math.Max(0, massDensity - massDensityA - massDensityB);

        int TotalAttempts = 200;
        double bestScore = 0;

        AddStartLocationMassSpots();
        AddStartLocationBasedMassSpots(massDensityA, 8, 60);
        AddRadialPositionedMassSpots(massDensityB);

        List<Marker> tempListMS = new List<Marker>();

        for (int i = 0; i < TotalAttempts; i++)
        {
            BuildRandomDisributionMassSpotList(startingPositionList.Count * massDensityC, 60);

            double thisScore = MassSpotFairnessScore();
            if (thisScore > bestScore)
            {
                tempListMS = RemoveRandomDistributionMassSpots();
                bestScore = thisScore;
            }
            else
            {
                RemoveRandomDistributionMassSpots();
            }

            if (bestScore > .97)
            {
                break;
            }
        }

        AddRandomDisributionMassSpots(tempListMS);
        ImproveMassSpotFairness((massDensityB * startingPositionList.Count), 1);
        ImproveMassSpotFairness((massDensityB * startingPositionList.Count), 1);
        ImproveMassSpotFairness((massDensityB * startingPositionList.Count), 1);
        ImproveMassSpotFairness((massDensityB * startingPositionList.Count), 1);
        ImproveMassSpotFairness((massDensityB * startingPositionList.Count), 1);

        List<Marker> mList = GetFinalMassSpotList();

        for (int j = 0; j < mList.Count; j++)
        {
            MassMarker mm = (MassMarker)mList[j];
            if (mm.MassSpotScoreMatrix.Count > 0)
            {
                Console.WriteLine(mm.Name + ": " + mm.GetMassSpotFairness());
            }
        }
        PrintMassSpotFairnessScores();
        FinalMassPlacementScore = MassSpotFairnessScore();

        return mList;
    }
    private List<Marker> GetFinalMassSpotList()
	{
		if (generationDone) {
			throw new InvalidOperationException("The final mass spot list cannot be retrieved more than once.");
		}
		generationDone = true;
		return massMarkerList;
	}
    private void AddStartLocationMassSpots()
	{
		if (MassSpotCount > 0) {
			throw new InvalidOperationException("Starting location mass spots can only be added to an empty mass spot list.");
		}
		foreach (Marker startPoint in startingPositionList) {
			if (startPoint.Name.StartsWith("ARMY_")) {
                int mId = availableMassSpotIds.Pop();
                MassMarker ms = new MassMarker("Mass " + mId.ToString("D3"));
                ms.MassSpotNumber = mId;
				float iX = startPoint.Position.X;
                float iY = startPoint.Position.Z;

                ms.Position = new Vector3((iX + 4), (float)hMap.GetFAHeight((int)(iX + 4), (int)iY),iY);
                ms.IsStartingMassSpot = true;
				massMarkerList.Add(ms);

                mId = availableMassSpotIds.Pop();
                ms = new MassMarker("Mass " + mId.ToString("D3"));
                ms.MassSpotNumber = mId;
                ms.Position = new Vector3((iX - 4), (float)hMap.GetFAHeight((int)(iX - 4), (int)iY), iY);
                ms.IsStartingMassSpot = true;
				massMarkerList.Add(ms);

                mId = availableMassSpotIds.Pop();
                ms = new MassMarker("Mass " + mId.ToString("D3"));
                ms.MassSpotNumber = mId;
                ms.Position = new Vector3(iX, (float)hMap.GetFAHeight((int)iX, (int)(iY + 4)), iY + 4);
                ms.IsStartingMassSpot = true;
				massMarkerList.Add(ms);

                mId = availableMassSpotIds.Pop();
                ms = new MassMarker("Mass " + mId.ToString("D3"));
                ms.MassSpotNumber = mId;
                ms.Position = new Vector3(iX, (float)hMap.GetFAHeight((int)iX, (int)(iY - 4)), iY - 4);
                ms.IsStartingMassSpot = true;
				massMarkerList.Add(ms);
			}
		}
	}
    private void AddStartLocationBasedMassSpots(int MassSpotsPerStartLocation, int MinDistance, int MaxDistance)
	{
		int windowSize = 16;
		double radius = 0;
		double theta = 0;
		int a = 0;
		int b = 0;
		int tries = 0;
		bool placed = false;
		Point p = Point.Empty;
        double[] distanceArray = new double[MassSpotsPerStartLocation];
        for (int m = 0; m < MassSpotsPerStartLocation; m++)
        {
            distanceArray[m] = r.NextDouble() * (MaxDistance - MinDistance) + MinDistance;
        }
		for (int k = 0; k <= startingPositionList.Count - 1; k++) {
			int iX = (int)startingPositionList[k].Position.X;
			int iY = (int)startingPositionList[k].Position.Z;

			for (int i = 1; i <= MassSpotsPerStartLocation; i++) {
				placed = false;
				tries = 0;

				while (!placed & tries < MaxAttemptsPerMassSpot) {
                    radius = distanceArray[i - 1];
					theta = r.NextDouble() * Math.PI * 2;
					a = (int)(Math.Round(radius * Math.Cos(theta)) + iX);
					b = (int)(Math.Round(radius * Math.Sin(theta)) + iY);

					if (!(a - windowSize / 2 < 0 | a + windowSize / 2 > hMap.Width | b - windowSize / 2 < 0 | b + windowSize / 2 > hMap.Height)) {
						Rectangle rect = new Rectangle(a - windowSize / 2, b - windowSize / 2, windowSize, windowSize);
						p = FindSuitableLocation(rect, 0);
						if (!p.Equals(Point.Empty)) {
                            int mId = availableMassSpotIds.Pop();
                            MassMarker ms = new MassMarker("Mass " + mId.ToString("D3"));
                            ms.MassSpotNumber = mId;
                            ms.IsStartingMassSpot = true;
                            ms.Position = new Vector3((float)(p.X + 0.5), (float)hMap.GetFAHeight(p.X, p.Y), (float)(p.Y + 0.5));
							massMarkerList.Add(ms);						
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
    private void AddRadialPositionedMassSpots(int MassSpotsPerStartLocation)
    {
        int halfWindowSize = 10;

        Vector2 p = GetCenterPointOfStartLocations();
        Vector2[] v = GetVectorsFromCenterToStartPositions(p);
        int[] PositionList = Utilities.GetShuffledIntegerArray(25, 75, r);

        int numberPlaced = 0;

        //Loop through the list and try to place mass spots
        for (int i = 0; i < PositionList.Length && numberPlaced < MassSpotsPerStartLocation; i++)
        {
            //Calculate vector length to use
            float a = (float)(PositionList[i]) / 100.0f;

            try
            {
                Point[] mpList = new Point[startingPositionList.Count];

                for (int j = 0; j < v.Length; j++)
                {
                    //Determine center point for mass spot placement window
                    Vector2 cp = v[j] * a + p;
                    Rectangle rect = new Rectangle((int)(cp.X - halfWindowSize), (int)(cp.Y - halfWindowSize), (int)(halfWindowSize * 2), (int)(halfWindowSize * 2));
                    Point massPoint = FindSuitableLocation(rect, 0);

                    //Check to make sure we found a viable mass spot
                    if (massPoint == Point.Empty)
                    {
                        throw new RadialMassSpotPlacementException();
                    }
                    mpList[j] = massPoint;

                }

                //If placement was successful, add mass spots to list
                for (int k = 0; k < startingPositionList.Count; k++)
                {
                    Point pos = mpList[k];
                    int mId = availableMassSpotIds.Pop();
                    MassMarker ms = new MassMarker("Mass " + mId.ToString("D3"));
                    ms.MassSpotNumber = mId;
                    ms.IsStartingMassSpot = true;
                    ms.Position = new Vector3((float)(pos.X + 0.5), (float)hMap.GetFAHeight(pos.X, pos.Y), (float)(pos.Y + 0.5));
                    massMarkerList.Add(ms);
                }
                numberPlaced++;
            }
            catch (RadialMassSpotPlacementException) { }
        }
    }

    private Vector2[] GetVectorsFromCenterToStartPositions(Vector2 centerPoint)
    {
        Vector2[] temp = new Vector2[startingPositionList.Count];

        for (int i = 0; i < startingPositionList.Count; i++)
        {
            Vector3 v = startingPositionList[i].Position;
            temp[i] = new Vector2(centerPoint.X - (int)(v.X + 0.5f), centerPoint.Y - (int)(v.Z + 0.5f));
        }

        return temp;
    }
    private Vector2 GetCenterPointOfStartLocations()
    {
        Vector3 temp = new Vector3();
        for (int i = 0; i < startingPositionList.Count; i++)
        {
            temp = temp + startingPositionList[i].Position;
        }

        return new Vector2((int)((temp.X / startingPositionList.Count) + 0.5f), (int)((temp.Z / startingPositionList.Count) + 0.5f));
    }

    private List<Marker> RemoveRandomDistributionMassSpots()
    {
        List<Marker> rtVal = new List<Marker>();

        int currIndex = 0;
        while (currIndex < massMarkerList.Count)
        {
            MassMarker mm = (MassMarker)massMarkerList[currIndex];
            if (!mm.IsStartingMassSpot)
            {
                availableMassSpotIds.Push(mm.MassSpotNumber);
                rtVal.Add(mm);
                massMarkerList.RemoveAt(currIndex);
                currIndex--;
            }
            currIndex++;
        }
        return rtVal;
    }
    private void AddRandomDisributionMassSpots(List<Marker> listToAdd)
    {
        foreach (MassMarker mm in listToAdd)
        {
            if (!mm.IsStartingMassSpot)
            {
                int mId = availableMassSpotIds.Pop();
                MassMarker ms = new MassMarker("Mass " + mId.ToString("D3"));
                ms.MassSpotNumber = mId;
                ms.MassSpotScoreMatrix = mm.MassSpotScoreMatrix;
                ms.Position = mm.Position;
                
                massMarkerList.Add(ms);
            }
        }        
    }
    private void BuildRandomDisributionMassSpotList(int massSpots, int minDistanceFromStartPoint)
	{
        int placedCount = 0;
        int loopCount = 0;
		while(placedCount < massSpots && loopCount < 4000)
        {
			Rectangle rect = new Rectangle(0, 0, hMap.Width, hMap.Height);
			Point p = FindSuitableLocation(rect, minDistanceFromStartPoint);
			if (!p.Equals(Point.Empty))
            {
                int mId = availableMassSpotIds.Pop();
                MassMarker ms = new MassMarker("Mass " + mId.ToString("D3"));
                ms.MassSpotNumber = mId;
                ms.Position = new Vector3((float)(p.X + 0.5), (float)hMap.GetFAHeight(p.X, p.Y), (float)(p.Y + 0.5));
                ms.MassSpotScoreMatrix = GetFairnessMatrixByPoint(new PointF((float)(p.X + 0.5), (float)(p.Y + 0.5)));
				massMarkerList.Add(ms);
                placedCount++;
			}
            loopCount++;
		}
    }
    private void BuildRandomDisributionMassSpotList(int MassDensity, int MassDensityVariance, int minDistanceFromStartPoint)
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
                            int mId = availableMassSpotIds.Pop();
                            MassMarker ms = new MassMarker("Mass " + mId.ToString("D3"));
                            ms.MassSpotNumber = mId;
                            ms.Position = new Vector3((float)(p.X + 0.5), (float)hMap.GetFAHeight(p.X, p.Y), (float)(p.Y + 0.5));
                            ms.MassSpotScoreMatrix = GetFairnessMatrixByPoint(new PointF((float)(p.X + 0.5), (float)(p.Y + 0.5)));
							massMarkerList.Add(ms);
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
                if (store1 & store2 & store3 & store4 & isNotCollision & (AllowUnderwaterMassSpots | !initialIsInWater) & isNotToCloseToStartPosition & isNotShore)
                {
					return new Point(initialX, initialY);
				}
			}
			tries = tries + 1;
		}
		return Point.Empty;
	}
	private bool IsNotShoreline(int posX, int posY)
	{
		bool rt = true;

        //Check area around point for any cells below water elevation
        for(int i = posX-4; i <= posX + 4; i++)
        {
            for(int j = posY-4;j <= posY + 4; j++)
            {
                int xP = Math.Min(Math.Max(0, i), hMap.Width - 1);
                int yP = Math.Min(Math.Max(0, j), hMap.Height - 1);
                double cellHeight = hMap.GetFAHeight(xP, yP);
                if (cellHeight <= waterElevation)
                {
                    rt = false;
                }
            }
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
        if (bounds.Left < 2 || bounds.Right > hMap.Width-2 || bounds.Top < 2 || bounds.Bottom > hMap.Height-2)
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
    private List<double> GetFairnessMatrixByPoint(PointF position)
    {
        List<double> rtVal = new List<double>();

        for (int k = 0; k < startingPositionList.Count; k++)
        {
            PointF sp = new PointF(startingPositionList[k].Position.X, startingPositionList[k].Position.Z);
            rtVal.Add(GetDistance(position, sp));
        }
        return rtVal;
    }
    private Point FindNearestLand(Point startingPoint)
    {
        int maxDimension = Math.Max(hMap.Width, hMap.Height);
        for (int i = 1; i < 2 * maxDimension; i++)
        {
            double increment = Math.Acos(Math.Sqrt(2) / (2 * i));
            for (double j = 0; j < 2 * Math.PI; j += increment)
            {
                int tX = (int)(Math.Cos(j) * i + startingPoint.X);
                int tY = (int)(Math.Sin(j) * i + startingPoint.Y);
                if (tX > 0 && tX < hMap.Width && tY > 0 && tY < hMap.Height)
                {
                    if (!IsWater(tX, tY))
                    {
                        Point p = FindSuitableLocation(new Rectangle(tX - 8, tY - 8, 16, 16), 0);
                        if (p != Point.Empty)
                        {
                            return p;
                        }
                    }
                }
            }
        }
        return Point.Empty;
    }
    private Point FindIdealPlacementSpot(int idx, int collarSize)
    {
        double[] sm = GetScoreMatrix(idx);
        Rectangle sArea = new Rectangle(collarSize, collarSize, hMap.Width - 2*collarSize, hMap.Height - 2*collarSize);

        while (sArea.Width > 16)
        {
            PointF p1 = new PointF(sArea.Width / 4 + sArea.X, sArea.Height / 4 + sArea.Y);
            PointF p2 = new PointF((3 * sArea.Width) / 4 + sArea.X, sArea.Height / 4 + sArea.Y);
            PointF p3 = new PointF((3 * sArea.Width) / 4 + sArea.X, (3 * sArea.Height) / 4 + sArea.Y);
            PointF p4 = new PointF(sArea.Width / 4 + sArea.X, (3 * sArea.Height) / 4 + sArea.Y);

            double s1 = GetScoreMetric(sm, GetFairnessMatrixByPoint(p1));
            double s2 = GetScoreMetric(sm, GetFairnessMatrixByPoint(p2));
            double s3 = GetScoreMetric(sm, GetFairnessMatrixByPoint(p3));
            double s4 = GetScoreMetric(sm, GetFairnessMatrixByPoint(p4));

            if (s1 > s2 && s1 > s3 && s1 > s4)
            {
                sArea.Height = sArea.Height / 2;
                sArea.Width = sArea.Width / 2;
            }
            else if (s2 > s3 && s2 > s4)
            {
                int temp1 = sArea.Width;
                sArea.Height = sArea.Height / 2;
                sArea.Width = sArea.Width / 2;
                sArea.X = sArea.X + temp1 / 2;
                
            }
            else if (s3 > s4)
            {
                int temp1 = sArea.Width;
                int temp2 = sArea.Height;
                sArea.Height = sArea.Height / 2;
                sArea.Width = sArea.Width / 2;
                sArea.X = sArea.X + temp1 / 2;
                sArea.Y = sArea.Y + temp2 / 2;
            }
            else if(s4 > 0)
            {
                int temp2 = sArea.Height;
                sArea.Height = sArea.Height / 2;
                sArea.Width = sArea.Width / 2;
                sArea.Y = sArea.Y + temp2 / 2;
            }
            else
            {
                int temp1 = sArea.Width;
                int temp2 = sArea.Height;
                sArea.Height = sArea.Height / 2;
                sArea.Width = sArea.Width / 2;
                sArea.X = sArea.X + temp1 / 4;
                sArea.Y = sArea.Y + temp2 / 4;
            }
        }
        Point iP = new Point(sArea.X + sArea.Width / 2, sArea.Y + sArea.Height / 2);
        if (!this.AllowUnderwaterMassSpots)
        {
            iP = FindNearestLand(iP);
        }
        return iP;
    }      
    private int GetWorstMassScoreIndex()
    {
        int worstIdx = -1;
        double worstScore = double.MaxValue;

        for (int j = 0; j < massMarkerList.Count; j++)
        {
            MassMarker mm = (MassMarker)massMarkerList[j];
            if (!mm.IsStartingMassSpot)
            {
                double msf = mm.GetMassSpotFairness();
                if (msf >= 0 && msf < worstScore)
                {
                    worstScore = msf;
                    worstIdx = j;
                }
            }
        }
        return worstIdx;
    }
    private double[] GetScoreMatrix(int excludedIndex)
    {
        double[] scoreMatrix = new double[startingPositionList.Count];
        for (int i = 0; i < massMarkerList.Count; i++)
        {
            MassMarker mm = (MassMarker)massMarkerList[i];
            if (mm.MassSpotScoreMatrix.Count > 0 && i != excludedIndex && !mm.IsStartingMassSpot)
            {
                for (int k = 0; k <= startingPositionList.Count - 1; k++)
                {
                    scoreMatrix[k] += mm.MassSpotScoreMatrix[k];
                }
            }
        }
        return scoreMatrix;
    }
    private double GetScoreMetric(double[] scoreMatrix, List<double> additionalValue)
    {
        double[] tempScoreMatrix = new double[startingPositionList.Count];
        Array.Copy(scoreMatrix, tempScoreMatrix, startingPositionList.Count);

        if (additionalValue != null && additionalValue.Count > 0)
        {
            for (int k = 0; k <= startingPositionList.Count - 1; k++)
            {
                tempScoreMatrix[k] += additionalValue[k];
            }
        }

        double min = double.MaxValue;
        double max = double.MinValue;

        for (int k = 0; k <= startingPositionList.Count - 1; k++)
        {
            min = Math.Min(min, tempScoreMatrix[k]);
            max = Math.Max(max, tempScoreMatrix[k]);
        }
        return 1.0 - ((max - min)/max);
    }
    private void ImproveMassSpotFairness(int iterations, int attemptsPerMassSpot)
    {
        attemptsPerMassSpot = 1;
        int windowSize = hMap.Width / 32;
        int a;
        int b;
        double fs = -1 ;

        List<int> massSpotsToFix = new List<int>();
        for (int j = 0; j < massMarkerList.Count; j++)
        {
            MassMarker mm = (MassMarker)massMarkerList[j];
            if (!mm.IsStartingMassSpot)
            {
                massSpotsToFix.Add(j);
            }
        }

        int i = 0;
        while(i < iterations && i < massSpotsToFix.Count)
        {
            int idx = massSpotsToFix[r.Next(0, massSpotsToFix.Count)];

            double[] sm = GetScoreMatrix(idx);
            double cs = GetScoreMetric(sm, ((MassMarker)massMarkerList[idx]).MassSpotScoreMatrix);
            Console.WriteLine(i.ToString() + ": " + cs.ToString());
            if (i == 0)
            {
                Console.WriteLine("Start: " + cs.ToString());
            }

            Vector3 bestSpot = new Vector3();
            double bestScore = cs;
            List<double> bestMatrix = new List<double>();
            Point pI = FindIdealPlacementSpot(idx, windowSize/2);
            //a = r.Next(2, hMap.Width - 2);
            //b = r.Next(2, hMap.Height - 2);
            a = pI.X;
            b = pI.Y;

            if (!(a - windowSize / 2 < 0 | a + windowSize / 2 > hMap.Width | b - windowSize / 2 < 0 | b + windowSize / 2 > hMap.Height))
            {
                Rectangle rect = new Rectangle(a, b - windowSize / 2, windowSize, windowSize);
                Point p = FindSuitableLocation(rect, 10);
                if (!p.Equals(Point.Empty))
                {
                    PointF pF = new PointF((float)p.X + 0.5f, (float)p.Y + 0.5f);
                    List<double> fm = GetFairnessMatrixByPoint(pF);
                    fs = GetScoreMetric(sm, fm);
                    if (fs > bestScore)
                    {
                        bestScore = fs;
                        bestSpot = new Vector3(pF.X, (float)hMap.GetFAHeight(p.X, p.Y), pF.Y);
                        bestMatrix = fm;
                    }
                }
            }

            if (bestScore > cs)
            {
                ((MassMarker)massMarkerList[idx]).MassSpotScoreMatrix = bestMatrix;
                massMarkerList[idx].Position = bestSpot;
            }
            i++;
        }
        Console.WriteLine("End: " + fs.ToString());
    }
    private double MassSpotFairnessScore()
    {
        double rt = 0;
        double[] distScore = new double[startingPositionList.Count];
        int massSpotCount = 0;

        //for (int j = 0; j < massMarkerList.Count; j++)
        //{
        //    ((MassMarker)massMarkerList[j]).MassSpotScoreMatrix.Clear();
        //}

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
                    //mm.MassSpotScoreMatrix.Add(distScore[k]);
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
    private double PrintMassSpotFairnessScores()
    {
        double rt = 0;
        double[] distScore = new double[startingPositionList.Count];
        int massSpotCount = 0;

        //for (int j = 0; j < massMarkerList.Count; j++)
        //{
        //    ((MassMarker)massMarkerList[j]).MassSpotScoreMatrix.Clear();
        //}

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
                    //mm.MassSpotScoreMatrix.Add(distScore[k]);
                    massSpotCount++;
                }
            }
        }
        double minScore = double.MaxValue;
        double maxScore = double.MinValue;

        for (int k = 0; k <= startingPositionList.Count - 1; k++)
        {
            distScore[k] = distScore[k] / massSpotCount;
            Console.WriteLine(k.ToString() + ": " + distScore[k].ToString());
            minScore = Math.Min(distScore[k], minScore);
            maxScore = Math.Max(distScore[k], maxScore);
        }
        rt = Math.Max(0, 1.0 - ((maxScore - minScore) / minScore));

        return rt;
    }
}