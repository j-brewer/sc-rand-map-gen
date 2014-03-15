function GetDistance(x1, y1, x2, y2)
{
	local a = x1-x2;
	local b = y1-y2;
	return sqrt(a*a+b*b);
}

function IsValidCraterPosition(x, y, minDistance, startPositionList)
{
	for(local i = 0; i < startPositionList.GetWidth(); i=i+1)
	{
		local x2 = startPositionList.GetValue(i,0);
		local y2 = startPositionList.GetValue(i,1);
		local d = GetDistance(x,y,x2,y2);
		if(d < minDistance)
		{
			return false;
		}
	}
	return true;
}

function GetInfo(info_type){
	switch(info_type){
		case "name":
			return "Moonscape";
		case "description":
			return "Generate a cratered landscape.";
		case "args":
			GGen_AddIntArg("size","Size of the map","", 1024, 128, 20000, 1);
			GGen_AddEnumArg("smoothness","Smoothness","Affects amount of detail on the map.", 1, "Very Rough;Rough;Smooth;Very Smooth");			
			GGen_AddEnumArg("island_size","Island Size","Affects the size of islands on the map.", 2, "Very Small;Small;Medium;Large;Very Large");
			GGen_AddEnumArg("include_land_collar","Land Collar","Affects whether or not the map has a land collar.", 1, "No;Yes");
			GGen_AddEnumArg("land_collar_size","Land Collar Size","Affects the size of the land collar.", 1, "Very Small;Small;Medium;Large;Very Large");
			GGen_AddIntArg("players","Number of players to fit on map","Affects the number of paths on map.", 6, 5, 9, 1);
			GGen_AddIntArg("island_distance_from_center","Island Distance From Center","Affects the distance of the islands from the center of the map.", 8, 0, 16, 1);			
			GGen_AddEnumArg("include_middle_island","Island In Middle","Affects whether or not the map has an island in the middle.", 0, "No;Yes");
			GGen_AddEnumArg("middle_island_type","Middle Island Type","Contrls the type of island in the middle of the map.", 0, "Volcano;Flat");
			return 0;
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

function Generate(){
	GGen_InitProgress(10);
	
	
	//Map Variables
	local mapSize = GGen_GetArgValue("size");
	local player_count = (GGen_GetArgValue("players"));
	local islandSize = (GGen_GetArgValue("island_size") + 1) *  12 + 96;
	local islandDistance = ((GGen_GetArgValue("island_distance_from_center")+ 16) * mapSize) / 64;
	local smoothness = 1 << GGen_GetArgValue("smoothness");
	local land_collar = GGen_GetArgValue("include_land_collar");
	local land_collar_size = (GGen_GetArgValue("land_collar_size") + 1) * mapSize /32;
	local include_middle_island = GGen_GetArgValue("include_middle_island")
	local middle_island_type = GGen_GetArgValue("middle_island_type")
	
	
	
	//Handle Player Starting Positions
	local startPos = GGen_Data_2D(player_count + 1, 3, GGEN_NATURAL_PROFILE.Min());
	local posStep = (2.0 * PI) / player_count;
	for(local i = 0; i < startPos.GetWidth() - 1; i=i+1)
	{
		local s = (i * posStep) + (PI/2);
		local x = ((floor((cos(s) * islandDistance) + 0.5)) + "").tointeger() + (mapSize / 2);
		local y = ((floor((sin(s) * islandDistance) + 0.5)) + "").tointeger() + (mapSize / 2);
		
		startPos.SetValue(i,0, x);
		startPos.SetValue(i,1, y);
	}
	startPos.SetValue(startPos.GetWidth()-1,0, 0)
	startPos.SetValue(startPos.GetWidth()-1,1, 16384)
	
	//Map Construction
	local seaLevel = 0;
	local islandHeight = 2800;
	
	local base = GGen_Data_2D(mapSize, mapSize, seaLevel);
	
	//Create Island Tile
	local islandTile = GGen_Data_2D(islandSize * 2, islandSize * 2, 0);
	local beachSize = 24;
	
	local islandShape = rand() % 3;
	islandShape = 0;
	if(islandShape == 0)
	{
		islandTile.RadialGradient(islandSize, islandSize, islandSize - beachSize, islandHeight, islandHeight, false);
	}
	else if(islandShape == 1)
	{
		islandTile.SetValueInRect(beachSize, beachSize, islandSize * 2 - beachSize, islandSize * 2 - beachSize, islandHeight);
	}
	else if(islandShape == 2)
	{
		local tSize = islandSize - beachSize;
		local tx1 = (islandSize - (tSize * (sqrt(3)/2))).tointeger();
		local tx2 = (islandSize + (tSize * (sqrt(3)/2))).tointeger();
		local tx3 = islandSize;
		
		local ty1 = (islandSize +  (tSize * 0.5)).tointeger();
		local ty2 = (islandSize + (tSize * 0.5)).tointeger();
		local ty3 = islandSize - (tSize);

		local trianglePath = GGen_Path();
		trianglePath.AddPointByCoords(tx1, ty1);
		trianglePath.AddPointByCoords(tx2, ty2);
		trianglePath.AddPointByCoords(tx3, ty3);
		trianglePath.AddPointByCoords(tx1, ty1);
		
		islandTile.FillPolygon(trianglePath, islandHeight+25);
		islandTile.ScaleTo(islandTile.GetWidth() + 5* islandSize/3, islandTile.GetHeight() + 5 * islandSize/3, false)
		islandTile.Rotate(180, true);
	}
	islandTile.Smooth(6);	

	if(land_collar == 1)
	{
		base.Fill(islandTile.Max());
		base.SetValueInRect(land_collar_size, land_collar_size, mapSize - land_collar_size, mapSize - land_collar_size, seaLevel);
	}
	
	//Add island tiles to main map
	local angle = (floor(posStep * (360 / (2.0 * PI))) ).tointeger();
	//islandTile.Rotate(-angle, true);
	//return islandTile;
	local midIslandSize = (pow(2, ceil(log(4*islandSize)/log(2)))).tointeger();
	local middleIslandTile = GGen_Data_2D(midIslandSize,midIslandSize, 0);
	if(include_middle_island == 1)
	{
		if(middle_island_type == 1)
		{
			
			local x1 = mapSize/2;
			local y1 = mapSize/2;
			base.UnionTo(islandTile, x1 - islandTile.GetWidth()/2, y1 - islandTile.GetHeight()/2);	
		}
		else
		{
			//local profileSize = 5*islandSize/3;
			local profileSize = 5*islandSize/3;
			local profile = GGen_Data_1D(profileSize, 0);
			
			local a = 3.0 * profileSize / 16.0;
			local s = profileSize / 5.0;
			local t = 7.0 * profileSize / 8.0;
			
			local slope = 4.0;
			local vSlope = 6.0;
			local heightOffset = 0;
			for(local i=1; i <= profile.GetLength(); i = i +1)
			{
				local v = 0.0
				if(i < a){v = a/slope + i * heightOffset/a;}
				else if(i >= a && i < s){v = i/slope + heightOffset;}
				else if(i >= s && i < t){v = (i-s)*(i-s)/vSlope + s/slope + heightOffset;}
				else{v = (t-s)*(t-s)/vSlope + s/slope - (i-t)*(i-t) + heightOffset;}
				v = (3 * v);
				profile.SetValue(profile.GetLength() - i, (floor(v + 0.5)).tointeger());
			}
			profile.Smooth(6);
			profile.Smooth(6);			
			middleIslandTile.RadialGradientFromProfile(midIslandSize/2, midIslandSize/2, profileSize, profile, false);
			
			middleIslandTile.Distort(40, 15);
			middleIslandTile.Smooth(2);
			//return middleIslandTile;
			
			profile = null;
			
			base.RadialGradient(mapSize/2, mapSize/2, 2*islandSize - 2*beachSize, islandTile.Max(), islandTile.Max(), false);
			
		}
	}
	
	for(local i = 0; i < startPos.GetWidth() - 1; i=i+1)
	{
		local x1 = startPos.GetValue(i,0);
		local y1 = startPos.GetValue(i,1);
		//base.AddTo(islandTile, x1 - islandTile.GetWidth()/2, y1 - islandTile.GetHeight()/2);
		base.UnionTo(islandTile, x1 - islandTile.GetWidth()/2, y1 - islandTile.GetHeight()/2);
		islandTile.Rotate(-angle, true);
	}
	


	base.Smooth(40);
	base.Distort(islandSize / 4-1, islandSize/4);
	base.Smooth(2);
	base.ScaleValuesTo(base.Min(), 2329);
	
	
	//Add noise	
	local mainNoise = GGen_Data_2D(mapSize, mapSize, GGEN_NATURAL_PROFILE.Min());
	mainNoise.Noise(smoothness, mapSize / 8, GGEN_STD_NOISE)
	mainNoise.ScaleValuesTo(0, 768);
	
	// noise overlay
	local vNoise = GGen_Data_2D(islandSize*4, islandSize*4, 0);
	vNoise.Noise(smoothness, 64, GGEN_STD_NOISE);
	vNoise.ScaleValuesTo(0, 512);
	middleIslandTile.AddMapMasked(vNoise, middleIslandTile, true);
	vNoise = null;
	
	
	//middleIslandTile.AddMapMask(mainNoise, middleIslandTile, true);
	
	base.AddTo(middleIslandTile, mapSize/2 - midIslandSize/2, mapSize/2 - midIslandSize/2);
	middleIslandTile = null;
	islandTile = null;
	
	local noiseLayer2 = GGen_Data_2D(mapSize, mapSize, GGEN_NATURAL_PROFILE.Min());
	noiseLayer2.Noise(1, 1, GGEN_STD_NOISE)
	noiseLayer2.ScaleValuesTo(0, 4)
	
	base.Union(mainNoise);
	base.AddMap(noiseLayer2);
	//base.Add(-base.Min());
	
	
	
	local range = (base.Max() - base.Min()) / 10;
	local highTerrainStart = base.Max() - (range * 4);
	local midTerrainStart = base.Max() - (range * 4);
	local beachTerrainStart = 2257;
	
	//Texture Maps
	local slopeMap = GGen_Data_2D(mapSize, mapSize, GGEN_NATURAL_PROFILE.Min());
	slopeMap = base.Clone();
	slopeMap.SlopeMap();
	
	slopeMap.ScaleValuesTo(0,1024);
	slopeMap.Add(-128);
	slopeMap.Clamp(0, 350);
	slopeMap.ScaleValuesTo(0,16384)
	slopeMap.ScaleTo(mapSize/2,mapSize/2,false)
	slopeMap.ReturnAs("Stratum8");
	
	local veryhighTerrain = GGen_Data_2D(mapSize, mapSize, GGEN_NATURAL_PROFILE.Min());
	veryhighTerrain = base.Clone();
	veryhighTerrain.CropValues(6000, 10000);
	veryhighTerrain.Monochrome(1);
	veryhighTerrain.Distort(mapSize/64, mapSize/64);
	veryhighTerrain.AddMapMasked(mainNoise, veryhighTerrain, true);
	veryhighTerrain.Smooth(10);
	veryhighTerrain.ScaleTo(mapSize/2,mapSize/2,false)	
	veryhighTerrain.ScaleValuesTo(0,16384);
	veryhighTerrain.ReturnAs("Stratum7");
	
	local highTerrain = GGen_Data_2D(mapSize, mapSize, GGEN_NATURAL_PROFILE.Min());
	highTerrain = base.Clone();
	highTerrain.CropValues(4000, 7000);
	highTerrain.Monochrome(1);
	highTerrain.Distort(mapSize/64, mapSize/64);
	highTerrain.AddMapMasked(mainNoise, highTerrain, true);
	highTerrain.Smooth(10);
	highTerrain.ScaleTo(mapSize/2,mapSize/2,false)	
	highTerrain.ScaleValuesTo(0,16384);
	highTerrain.ReturnAs("Stratum6");
	
	local middleTerrain = GGen_Data_2D(mapSize, mapSize, GGEN_NATURAL_PROFILE.Min());
	middleTerrain = base.Clone();
	middleTerrain.CropValues(2600, 5000);
	middleTerrain.Monochrome(1);
	middleTerrain.Distort(mapSize/64, mapSize/64);
	middleTerrain.AddMapMasked(mainNoise, middleTerrain, true);
	middleTerrain.Smooth(10);
	middleTerrain.ScaleTo(mapSize/2,mapSize/2,false);	
	middleTerrain.ScaleValuesTo(0,16384);
	middleTerrain.ReturnAs("Stratum5");
	
	local beachTerrain = GGen_Data_2D(mapSize, mapSize, GGEN_NATURAL_PROFILE.Min());
	beachTerrain = base.Clone();
	beachTerrain.CropValues(beachTerrainStart-1024, 2328);
	beachTerrain.Clamp(beachTerrainStart-1024, 2328);
	beachTerrain.ScaleValuesTo(0,16384);
	beachTerrain.Invert();
	beachTerrain.Add(16384);
	beachTerrain.CropValues(0, 16383);
	beachTerrain.Add(12000);
	beachTerrain.Clamp(12000,16384);
	beachTerrain.CropValues(12001, 16384);
	beachTerrain.Smooth(2);
	beachTerrain.ScaleValuesTo(0,16384);
	beachTerrain.ScaleTo(mapSize/2,mapSize/2,false)	
	beachTerrain.ReturnAs("Stratum2");
	
	
	local rockMask = GGen_Data_2D(mapSize, mapSize, 0);
	local rockMask2 = GGen_Data_2D(mapSize, mapSize, 0);
	
	rockMask = base.Clone();
	rockMask.Clamp(0, 2400);
	rockMask.CropValues(2310, 2400);
		
	for(local i = 0; i < startPos.GetWidth() - 1; i=i+1)
	{
		local x1 = startPos.GetValue(i,0);
		local y1 = startPos.GetValue(i,1);
		rockMask2.RadialGradient(x1, y1, islandSize - 2 * beachSize, 2400, 2400, false);
		rockMask2.RadialGradient(x1, y1, 32, 0, 0, false);
		
	}
	rockMask2.Intersection(rockMask);
	rockMask2.Smooth(10);
		
	local rockNoise = GGen_Data_2D(mapSize, mapSize, GGEN_NATURAL_PROFILE.Min());
	rockNoise.Noise(10, mapSize / 8, GGEN_STD_NOISE);		
	rockNoise.ScaleValuesTo(0, 5000);	
	rockMask2.AddMapMasked(rockNoise, rockMask2, true);
	rockMask2.ScaleValuesTo(0, 512);
	rockMask2.ReturnAs("RockMask");
	
	local treeMask = GGen_Data_2D(mapSize, mapSize, 0);
	
	treeMask = base.Clone();
	treeMask.Clamp(0, 2400);
	treeMask.CropValues(2329, 2400);
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
	treeMask.Smooth(2);
	slopeMap.Invert();
	veryhighTerrain.Invert();
	treeMask.AddMap(slopeMap);
	treeMask.AddMap(veryhighTerrain);
	treeMask.Clamp(0, 2400);
	treeMask.ReturnAs("TreeMask");
	
	
	local randomTerrain = GGen_Data_2D(mapSize, mapSize, GGEN_NATURAL_PROFILE.Min());
	randomTerrain.Noise(10, mapSize / 8, GGEN_STD_NOISE);	
	randomTerrain.ScaleValuesTo(0,1024);
	randomTerrain.Clamp(0, 896);
	randomTerrain.ScaleValuesTo(0,16384);
	randomTerrain.ScaleTo(mapSize/2,mapSize/2,false)
	randomTerrain.ReturnAs("Stratum1");
	
	//Fix Start Positions for team play
	if(player_count == 6)
	{
		SwapStartLocation(startPos, 4, 5);
		SwapStartLocation(startPos, 3, 5);
		SwapStartLocation(startPos, 2, 5);
		SwapStartLocation(startPos, 1, 2);
	}
	else if(player_count == 8)
	{
		SwapStartLocation(startPos, 1, 2);
		SwapStartLocation(startPos, 1, 4);
		SwapStartLocation(startPos, 5, 6);
		SwapStartLocation(startPos, 3, 6);
	}	
	startPos.ReturnAs("StartPositions");
	print(base.Max());
	return base;
}
