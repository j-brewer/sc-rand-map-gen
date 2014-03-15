// ***************************************************************************************
// * Supreme Commander Random Map Generator
// * Copyright 2014  Jonathan Brewer
// * Filename: WaveGenGenerator.cs
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

public class WaveGenGenerator
{
    private Random r;
    private HeightMap h;
    private int generatorDensity = 2;
    public WaveGenGenerator(int rngSeed, HeightMap hmap)
    {
        r = new Random(rngSeed);
        h = hmap;
    }
    public List<WaveGenerator> BuildWaveGeneratorList(float waterElevation)
    {
        float waveStart = waterElevation - 0.5f;
        float waveEnd = waterElevation - 0.25f;
        List<WaveGenerator> rt = new List<WaveGenerator>();

        //Find all viable wave generator locations
        ushort ws = Convert.ToUInt16((waveStart / 127) * 16384);
        ushort we = Convert.ToUInt16((waveEnd / 127) * 16384);
        List<Point> pointList = new List<Point>();
        for (Int32 iy = 0; iy <= h.Height - 2; iy++)
        {
            for (Int32 ix = 0; ix <= h.Width - 2; ix++)
            {
                if (h.GetHeight(ix, iy) > ws & h.GetHeight(ix, iy) < we)
                {
                    pointList.Add(new Point(ix, iy));
                }
            }
        }

        //Determine which ones to place waves in
        WaveGenerator wg = default(WaveGenerator);
        for (int i = 0; i <= pointList.Count - 1; i += generatorDensity)
        {
            double gradientActual = h.Gradient(pointList[i].X, pointList[i].Y);
            if (r.Next(0, 2) == 0)
            {
                wg = Turbulance2Wave(pointList[i], gradientActual, waterElevation);
            }
            else
            {
                wg = Turbulance3Wave(pointList[i], gradientActual, waterElevation);
            }
            rt.Add(wg);
        }

        return rt;
    }
    public WaveGenerator Turbulance3Wave(Point position,  double gradientValue, float waterElevation)
    {
        WaveGenerator rt = new WaveGenerator();
        rt.TextureName = "/env/common/decals/shoreline/turbulance03_albedo.dds";
        rt.StripCount = 1.0f;
        rt.RampName = "/env/common/decals/shoreline/waveramptest.dds";
        rt.FrameCount = 1.0f;
        rt.FrameRateFirst = 1.0f;
        rt.FrameRateSecond = 0.0f;
        rt.PeriodFirst = 8.0f;
        rt.PeriodSecond = 12.0f;
        rt.LifetimeFirst = 110.0f;
        rt.LifetimeSecond = 150.0f;
        rt.ScaleFirst = (float)(0.0 + r.NextDouble());
        rt.ScaleSecond = (float)(4.5 + r.NextDouble());
        double mag = (0.015 + (r.NextDouble() / 100.0));
        rt.Velocity = new Vector3((float)(mag * Math.Cos(gradientValue)), 0, (float)(-mag * Math.Sin(gradientValue)));
        rt.Position = new Vector3(position.X - 200 * rt.Velocity.X, waterElevation, position.Y - 200 * rt.Velocity.Y);
        rt.Rotation = ConvertToFARadians(gradientValue);
        return rt;
    }
    public WaveGenerator Turbulance2Wave(Point position,  double gradientValue, float waterElevation)
    {
        WaveGenerator rt = new WaveGenerator();
        rt.TextureName = "/env/common/decals/shoreline/turbulance02_albedo.dds";
        rt.StripCount = 1.0f;
        rt.RampName = "/env/common/decals/shoreline/waveramptest.dds";
        rt.FrameCount = 1.0f;
        rt.FrameRateFirst = 1.0f;
        rt.FrameRateSecond = 0.0f;
        rt.PeriodFirst = 4.5f;
        rt.PeriodSecond = 5.5f;
        rt.LifetimeFirst = 30.0f;
        rt.LifetimeSecond = 70.0f;
        rt.ScaleFirst = (float)(0.3 + r.NextDouble());
        rt.ScaleSecond = (float)(1.0 + r.NextDouble());
        double mag = (-0.012 + (r.NextDouble() / 100.0));
        rt.Velocity = new Vector3((float)(mag * Math.Cos(gradientValue)), 0, (float)(-mag * Math.Sin(gradientValue)));
        rt.Rotation = ConvertToFARadians(gradientValue);
        rt.Position = new Vector3(position.X, waterElevation, position.Y);
        return rt;
    }
    private float ConvertToFARadians(double actualGradient)
    {
        float rt = 0;

        //Fix for FA radian system (were they drunk when they looked at the unit circle?)
        if (actualGradient >= (-Math.PI / 2) & actualGradient <= (Math.PI / 2))
        {
            rt = (float)(Math.PI / 2 + (-actualGradient));
        }
        else if (actualGradient < -Math.PI / 2)
        {
            rt = (float)((-3.0 * Math.PI) / 2.0 - actualGradient);
        }
        else if (actualGradient > Math.PI / 2)
        {
            rt = (float)(Math.PI / 2 - actualGradient);
        }

        return rt;
    }
}
