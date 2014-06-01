function GetInfo(info_type){
	switch(info_type){
		case "name":
			return "Hexagons";
		case "description":
			return "An array of interconnected hexagons.";
		case "args":
			GGen_AddIntArg("mapsize","Map Size","Size of the map.", 1024, 128, GGen_GetMaxMapSize(), 1);
			GGen_AddEnumArg("players","Number of players to fit on map","Affects the number of players on map.", 2, "2;4;6");
			GGen_AddEnumArg("smoothness","Smoothness","Affects amount of detail on the map.", 1, "Very Rough;Rough;Smooth;Very Smooth");
			GGen_AddEnumArg("feature_size","Feature Size","Size of map features.", 1, "Tiny;Medium;Large");
			
			return 0;
	}
}

function MakeRamp(base, posX, posY, v, dir, mapSize, RampSize)
{
	local cellH1 = base.GetValue(posX, posY);
	local tX = posX + (cos(dir) * 2 * v).tointeger();
	local tY = posY + (sin(dir) * 2 * v).tointeger();
	if(tX > 0 && tX < mapSize && tY > 0 && tY < mapSize)
	{
		local cellH2 = base.GetValue(tX, tY);
		local r1 = (cellH1-cellH2) / (4*v/3);
		for(local k = v/3; k < 5*v/3;k= k + 0.1)
		{
			local pX = posX + (cos(dir) * k).tointeger();
			local pY = posY + (sin(dir) * k).tointeger();
			base.SetValueInRect(pX-RampSize, pY-RampSize, pX+RampSize, pY+RampSize, cellH1 - (r1 * (k-v/3)).tointeger());
		}
	}
}

function SwapStartLocation(data, positionOne, positionTwo)
{
		local tempX = 0;
		local tempY = 0;
		
		tempX = data.GetValue(positionOne,0);
		tempY = data.GetValue(positionOne,1);
		
		data.SetValue(positionOne,0, data.GetValue(positionTwo,0));
		data.SetValue(positionOne,1, data.GetValue(positionTwo,1));
		
		data.SetValue(positionTwo,0, tempX);
		data.SetValue(positionTwo,1, tempY);
}

function MakeHexagonPath(edgeLength, centerX, centerY)
{
	 local h = GGen_Path();
	 local halfEl = edgeLength/2;
	 local quarterEl = edgeLength/4;
	 local v = (sin(PI/3) * edgeLength).tointeger();
	 
	 h.AddPointByCoords(centerX - halfEl, centerY - v);
	 h.AddPointByCoords(centerX - edgeLength, centerY);
	 h.AddPointByCoords(centerX - halfEl, centerY + v);
	 
	 h.AddPointByCoords(centerX + halfEl, centerY + v);
	 h.AddPointByCoords(centerX + edgeLength, centerY);
	 h.AddPointByCoords(centerX + halfEl, centerY - v);
	 return h;
}

function Generate(){
	local width = GGen_GetArgValue("mapsize");
	local height = GGen_GetArgValue("mapsize");
	local mapSize = height;
	local feature_size = GGen_GetArgValue("feature_size");
	local smoothness = 1 << GGen_GetArgValue("smoothness");
	local player_count = ((GGen_GetArgValue("players")) + 1)*2;
	GGen_InitProgress(6);

	// we must decide the smaller dimension to fit the circle into the map
	local size = mapSize / 2;
	
  	//Handle Player Starting Positions
	local startPos = GGen_Data_2D(player_count+1, 3, 0);
	startPos.SetValue(startPos.GetWidth()-1,0, 0)
	startPos.SetValue(startPos.GetWidth()-1,1, 16384)
	
	
	GGen_IncreaseProgress();

	local base = GGen_Data_2D(width, height,2600);
	local hexagonSize = mapSize/32 + 32;
	local v = (sin(PI/3) * hexagonSize).tointeger();
	local hVCount = mapSize / (2 * v);
	local hHCount = (mapSize - hexagonSize)  / ((3*hexagonSize / 2));
	if(hHCount % 2 == 0){hHCount = hHCount - 1;}
	
	local iCount = 0;
	if((hHCount-1) % 4 == 0)
	{
		iCount = -1;
	}	
		
	local posX = mapSize/2 - hHCount * (3*hexagonSize / 2)/2 + (3*hexagonSize / 2)/2; 
	local posYs = mapSize/2 - hVCount * v + v;
	local posY = 0;
	
	for(local i = 0; i < hHCount; i++)
	{
		iCount++;
		if(iCount % 2 == 0){posY = posYs;}
		else {posY = posYs + v;}
		
		local cellsThisColumn =  hVCount - iCount % 2;
		local firstCell = 1;
		for(local j = 0; j < cellsThisColumn; j++)
		{
			local hToRemove = abs((hHCount / 2) - i) / 2 ;
			
			if(j+1 > hToRemove && j < cellsThisColumn - hToRemove)
			{
				local hHeight = 3000 + (rand() % 4000);
				local h1 = MakeHexagonPath(hexagonSize, posX, posY);
				
				//Detect start cells
				if(firstCell == 1)
				{
					firstCell = 0;
					if(i == 0)
					{
						startPos.SetValue(0,0, posX)
						startPos.SetValue(0,1, posY)
						hHeight = 5000;
					}
					else if(i == (hHCount/2) && player_count == 6)
					{
						startPos.SetValue(4,0, posX)
						startPos.SetValue(4,1, posY)
						hHeight = 5000;
					}
					else if(i == hHCount-1 && player_count > 2)
					{
						startPos.SetValue(2,0, posX)
						startPos.SetValue(2,1, posY)
						hHeight = 5000;
					}
				}
				else if(j == cellsThisColumn - hToRemove - 1)
				{
					if(i == 0 && player_count > 2)
					{
						startPos.SetValue(3,0, posX)
						startPos.SetValue(3,1, posY)
						hHeight = 5000;
					}
					else if(i == (hHCount/2) && player_count == 6)
					{
						startPos.SetValue(5,0, posX)
						startPos.SetValue(5,1, posY)
						hHeight = 5000;
					}
					else if(i == hHCount-1)
					{
						startPos.SetValue(1,0, posX)
						startPos.SetValue(1,1, posY)
						hHeight = 5000;
					}
				}
				base.FillPolygon(h1, hHeight);
			}
			posY = posY + 2 * v;
		}

		posX = posX + 3*hexagonSize / 2;
	}
	
	
	posX = mapSize/2 - hHCount * (3*hexagonSize / 2)/2 + (3*hexagonSize / 2)/2; 
	
	
	base.Smooth(mapSize/256);
	
	iCount = 0;
	if((hHCount-1) % 4 == 0)
	{
		iCount = -1;
	}
	local RampSize = hexagonSize/6;
	for(local i = 0; i < hHCount; i++)
	{
		iCount++;
		if(iCount % 2 == 0){posY = posYs;}
		else {posY = posYs + v;}
		local firstCell = 1;
		local cellsThisColumn =  hVCount - iCount % 2;
		for(local j = 0; j < cellsThisColumn; j++)
		{
			local hToRemove = abs((hHCount / 2) - i) / 2 ;
			if(j+1 > hToRemove && j < cellsThisColumn - hToRemove)
			{
				local dir = PI/3 * (rand() % 6) + PI/6;
				
				//Start cells get specific paths
				if(firstCell == 1)
				{
					firstCell = 0;
					if(i == 0)
					{
						MakeRamp(base, posX, posY, v, 9*PI/6, mapSize, RampSize);
						MakeRamp(base, posX, posY, v, 13*PI/6, mapSize, RampSize);
					}
					else if(i == (hHCount/2) && player_count == 6)
					{
						MakeRamp(base, posX, posY, v, 11*PI/6, mapSize, RampSize);
						MakeRamp(base, posX, posY, v, 15*PI/6, mapSize, RampSize);
					}
					else if(i == hHCount-1 && player_count > 2)
					{
						MakeRamp(base, posX, posY, v, 9*PI/6, mapSize, RampSize);
						MakeRamp(base, posX, posY, v, 5*PI/6, mapSize, RampSize);
					}
				}
				else if(j == cellsThisColumn - hToRemove - 1)
				{
					if(i == 0 && player_count > 2)
					{
						MakeRamp(base, posX, posY, v, 11*PI/6, mapSize, RampSize);
						MakeRamp(base, posX, posY, v, 15*PI/6, mapSize, RampSize);
					}
					else if(i == (hHCount/2) && player_count == 6)
					{
						MakeRamp(base, posX, posY, v, 9*PI/6, mapSize, RampSize);
						MakeRamp(base, posX, posY, v, 5*PI/6, mapSize, RampSize);
					}
					else if(i == hHCount-1)
					{
						MakeRamp(base, posX, posY, v, 7*PI/6, mapSize, RampSize);
						MakeRamp(base, posX, posY, v, 15*PI/6, mapSize, RampSize);
					}
				}
				else
				{
					MakeRamp(base, posX, posY, v, dir, mapSize, RampSize);
				}
			}
			posY = posY + 2 * v;
		}

		posX = posX + 3*hexagonSize / 2;
	}
	
	//base.Distort(16, 14);
	base.Smooth(2);	
	
	base.ScaleValuesTo(1300, 5000);
	GGen_IncreaseProgress();
	
	// noise overlay
	local noise = GGen_Data_2D(width, height, 0);
	noise.Noise(smoothness, ((width > height) ? height : width) / (60 - (15 * feature_size)), GGEN_STD_NOISE);
	
	GGen_IncreaseProgress();
	
	noise.ScaleValuesTo(0, 128);
	
	base.AddMapMasked(noise, base, true);
	
	base.AddMap(noise);
	
	GGen_IncreaseProgress();
	
	GGen_IncreaseProgress();
	
	//Stratum
	//local range = (base.Max() - base.Min()) / 10;
	//local highTerrainStart = base.Max() - (range * 4);
	//local midTerrainStart = base.Max() - (range * 4);
	local beachTerrainStart = 2257;
	
	local randomTerrain = GGen_Data_2D(mapSize, mapSize, GGEN_NATURAL_PROFILE.Min());
	randomTerrain.Noise(10, mapSize / 8, GGEN_STD_NOISE);	
	randomTerrain.ScaleValuesTo(0,1024);
	randomTerrain.Clamp(0, 896);
	randomTerrain.ScaleValuesTo(0,16384);
	randomTerrain.ScaleTo(mapSize/2,mapSize/2,false)
	randomTerrain.ReturnAs("Stratum1");
	
	local randomTerrain = GGen_Data_2D(mapSize, mapSize, GGEN_NATURAL_PROFILE.Min());
	randomTerrain.Noise(10, mapSize / 8, GGEN_STD_NOISE);	
	randomTerrain.ScaleValuesTo(0,1024);
	randomTerrain.Clamp(0, 896);
	randomTerrain.ScaleValuesTo(0,16384);
	randomTerrain.ScaleTo(mapSize/2,mapSize/2,false)
	randomTerrain.ReturnAs("Stratum2");
	
	local beachTerrain = GGen_Data_2D(mapSize, mapSize, GGEN_NATURAL_PROFILE.Min());
	beachTerrain = base.Clone();
	beachTerrain.CropValues(1024, 2335);
	if(beachTerrain.Max() > 0)
	{
		beachTerrain.Clamp(1024, 2335);
		beachTerrain.ScaleValuesTo(0,16384);
		beachTerrain.Invert();
		beachTerrain.Add(16384);
		beachTerrain.CropValues(0, 16383);
		beachTerrain.Add(12000);
		beachTerrain.Clamp(12000,16384);
		beachTerrain.CropValues(12001, 16384);
		beachTerrain.Smooth(2);
		beachTerrain.ScaleValuesTo(0,16384);
		
	}
	beachTerrain.ScaleTo(mapSize/2,mapSize/2,false)	
	beachTerrain.ReturnAs("Stratum3");
	
	local middleTerrain = GGen_Data_2D(mapSize, mapSize, GGEN_NATURAL_PROFILE.Min());
	middleTerrain = base.Clone();
	middleTerrain.CropValues(2600, 5000);
	middleTerrain.Monochrome(1);
	middleTerrain.Distort(mapSize/64, mapSize/64);
	middleTerrain.AddMapMasked(noise, middleTerrain, true);
	middleTerrain.Smooth(10);
	middleTerrain.ScaleTo(mapSize/2,mapSize/2,false);	
	middleTerrain.ScaleValuesTo(0,16384);
	middleTerrain.ReturnAs("Stratum5");
		
	local highTerrain = GGen_Data_2D(mapSize, mapSize, GGEN_NATURAL_PROFILE.Min());
	highTerrain = base.Clone();
	highTerrain.CropValues(4000, 7000);
	highTerrain.Monochrome(1);
	highTerrain.Distort(mapSize/64, mapSize/64);
	highTerrain.AddMapMasked(noise, highTerrain, true);
	highTerrain.Smooth(10);
	highTerrain.ScaleTo(mapSize/2,mapSize/2,false)	
	highTerrain.ScaleValuesTo(0,16384);
	highTerrain.ReturnAs("Stratum6");
	
	local slopeMap = GGen_Data_2D(mapSize, mapSize, GGEN_NATURAL_PROFILE.Min());
	slopeMap = base.Clone();
	slopeMap.Clamp(2350, 32767);
	slopeMap.SlopeMap();
	slopeMap.ScaleValuesTo(0,1024);
	slopeMap.Add(-128);
	slopeMap.Clamp(0, 350);
	slopeMap.ScaleValuesTo(0,16384)
	slopeMap.ScaleTo(mapSize/2,mapSize/2,false)
	slopeMap.ReturnAs("Stratum8");
	
	//Masks for  Trees & Rocks
	local rockMask = GGen_Data_2D(mapSize, mapSize, 0);
	rockMask.ReturnAs("RockMask");
	
	local treeMask = GGen_Data_2D(mapSize, mapSize, 0);
	
	treeMask = base.Clone();
	treeMask.Clamp(0, 2400);
	treeMask.CropValues(2300, 16535);
	treeMask.ScaleValuesTo(0, 2400);	
	treeMask.Smooth(2);
		
	local treeNoise = GGen_Data_2D(mapSize, mapSize, GGEN_NATURAL_PROFILE.Min());
	treeNoise.Noise(10, mapSize / 8, GGEN_STD_NOISE);		
	treeNoise.ScaleValuesTo(0, 5000);		
	treeMask.AddMapMasked(treeNoise, treeMask, true);
	treeMask.ScaleValuesTo(0, 1800);
	
	for(local i = 0; i < startPos.GetWidth() - 1; i=i+1)
	{
		local x1 = startPos.GetValue(i,0);
		local y1 = startPos.GetValue(i,1);
		treeMask.RadialGradient(x1, y1,  32, 0, 0, false);
	}
	
	slopeMap.Invert();
	slopeMap.ScaleValuesTo(-1800, 0);
	beachTerrain.Smooth(4);
	beachTerrain.Invert();
	treeMask.AddMap(slopeMap);
	treeMask.AddMap(beachTerrain);
	treeMask.Smooth(2);
	treeMask.Clamp(0, 2000);
	treeMask.ReturnAs("TreeMask");
	
	startPos.ReturnAs("StartPositions");
	
	return base;
}