// ***************************************************************************************
// * Supreme Commander Random Map Generator
// * Copyright 2014  Jonathan Brewer
// * Filename: PropGenerator.cs
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
using System.IO.Compression;

public class PropGenerator
{
    private HeightMap hMap;
    private HeightMap rockMask;
    private HeightMap treeMask;
    private Random r;
    public List<Prop> PropList;
    private Tileset _ts;
    private List<ReclaimableProp> _rockList;
    private List<ReclaimableProp> _treeList;
    private double waterElevation;
    public PropGenerator(HeightMap h, Tileset ts, string inputPath, double wElev, int rngSeed)
    {
        PropList = new List<Prop>();
        _rockList = new List<ReclaimableProp>();
        _treeList = new List<ReclaimableProp>();
        hMap = h;
        this.r = new Random(rngSeed);
        _ts = ts;
        rockMask = HeightMapLoader.LoadHeightmapWithNoExtension(inputPath + "\\RockMask");
        treeMask = HeightMapLoader.LoadHeightmapWithNoExtension(inputPath + "\\TreeMask");
        waterElevation = wElev;
        foreach (string bpPath_loopVariable in _ts.RockProps)
        {
            _rockList.Add(new ReclaimableProp(bpPath_loopVariable));
        }
        foreach (string bpPath_loopVariable in _ts.TreeProps)
        {
            _treeList.Add(new ReclaimableProp(bpPath_loopVariable));
        }
    }
    public int PlaceRocksByMask()
    {
        int rt = 0;
        if (_ts.RockProps.Count > 0)
        {
            for (int i = 0; i <= hMap.Height - 2; i++)
            {
                for (int j = 0; j <= hMap.Width - 2; j++)
                {
                    if (Convert.ToInt32(rockMask.GetHeight(j, i)) + r.Next(0, 16384) > 16384)
                    {
                        PropList.Add(CreateProp(j, i, PropType.Rock));
                        rt = rt + 1;
                    }
                }
            }
        }
        return rt;
    }
    public int PlaceRocksAroundStartPositions(double MassPerStartLocation, int MinDistance, int MaxDistance, List<Marker> startList)
    {
        double radius = 0;
        double theta = 0;
        int a = 0;
        int b = 0;
        int totalNumberPlaced = 0;
        if (_ts.RockProps.Count > 0)
        {
            for (int k = 0; k <= startList.Count - 1; k++)
            {
                double amtPlaced = 0;
                int iX = (int)startList[k].Position.X;
                int iY = (int)startList[k].Position.Z;
                int currNumberPlaced = 0;
                while (amtPlaced < MassPerStartLocation & currNumberPlaced < 500)
                {
                    radius = r.NextDouble() * (MaxDistance - MinDistance) + MinDistance;
                    theta = r.NextDouble() * Math.PI * 2;
                    a = (int)Math.Round(radius * Math.Cos(theta)) + iX;
                    b = (int)Math.Round(radius * Math.Sin(theta)) + iY;
                    a = Math.Max(Math.Min(a, hMap.Width - 2), 0);
                    b = Math.Max(Math.Min(b, hMap.Height - 2), 0);

                    ReclaimableProp rp = GetRandomRockBluePrint();
                    amtPlaced = amtPlaced + rp.MassValue;
                    PropList.Add(CreateProp(a, b, rp.BlueprintPath));
                    totalNumberPlaced += 1;
                    currNumberPlaced += 1;
                }
            }
        }
        return totalNumberPlaced;
    }
    public int PlaceTrees()
    {
        int rt = 0;
        if (_ts.TreeProps.Count > 0)
        {
            for (int i = 0; i <= hMap.Height - 2; i++)
            {
                for (int j = 0; j <= hMap.Width - 2; j++)
                {
                    if (Convert.ToInt32(treeMask.GetHeight(j, i)) + r.Next(0, 16384) > 16384)
                    {
                        //Don't place trees in the water
                        if (hMap.GetFAHeight(j, i) > waterElevation)
                        {
                            PropList.Add(CreateProp(j, i, PropType.Tree));
                            rt = rt + 1;
                        }
                    }
                }
            }
        }
        return rt;
    }
    private Prop CreateProp(int positionX, int positionY, PropType t)
    {
        string bp = null;
        if (t == PropType.Rock)
        {
            bp = GetRandomRockBluePrint().BlueprintPath;
        }
        else
        {
            bp = GetRandomTreeBluePrint().BlueprintPath;
        }
        return CreateProp(positionX, positionY, bp);
    }
    private Prop CreateProp(int positionX, int positionY, string bPath)
    {
        Prop rt = new Prop();
        rt.BlueprintPath = bPath;
        rt.Position = new Vector3((float)positionX, (float)hMap.GetFAHeight(positionX, positionY), (float)positionY);
        double theta = r.NextDouble() * 2.0 * Math.PI;
        rt.RotationX = new Vector3((float)Math.Cos(theta), 0.0f, (float)Math.Sin(theta));
        rt.RotationY = new Vector3(0.0f, 1.0f, 0.0f);
        rt.RotationZ = new Vector3(-rt.RotationX.Z, 0, rt.RotationX.X);
        return rt;
    }
    private ReclaimableProp GetRandomTreeBluePrint()
    {
        return _treeList[r.Next(0, _treeList.Count)];
    }
    private ReclaimableProp GetRandomRockBluePrint()
    {
        return _rockList[r.Next(0, _rockList.Count)];
    }
}
