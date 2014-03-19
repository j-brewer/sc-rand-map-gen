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

function GetInfo(info_type){
	switch(info_type){
		case "name":
			return "Moonscape II";
		case "description":
			return "Generate a cratered landscape.";
		case "args":
			GGen_AddIntArg("size","Size of the map","", 1024, 128, 20000, 1);
			GGen_AddEnumArg("players","Number of players to fit on map","Affects the number of paths on map.", 1, "2;4;6;8");
			GGen_AddEnumArg("smoothness","Smoothness","Affects amount of detail on the map.", 1, "Very Rough;Rough;Smooth;Very Smooth");			
			GGen_AddEnumArg("crater_count","Number of Craters","Affects the number of craters on the map.", 2, "Very Few;Few;Some;Many;Very Many");
			GGen_AddEnumArg("max_crater_size","Maximum Crater Size","Affects the size of craters on the map.", 2, "Very Small;Small;Medium;Large;Very Large");			
			GGen_AddIntArg("player_distance_from_center","Island Distance From Center","Affects the distance of the players from the center of the map.", 8, 0, 16, 1);			
			
			return 0;
	}
}

function Generate(){
	GGen_InitProgress(10);
	local mapSize = GGen_GetArgValue("size");
	local playerDistance = ((GGen_GetArgValue("player_distance_from_center")+ 16) * mapSize) / 64;
	local player_count = 2 * (GGen_GetArgValue("players") + 1);
	local craterCount = (GGen_GetArgValue("crater_count") + 1) * 100 + 50;
	local maxCraterSize = (GGen_GetArgValue("max_crater_size") + 2) *  64;
	local smoothness = 1 << GGen_GetArgValue("smoothness");
	
	//Handle Player Starting Positions
	local startPos = GGen_Data_2D(player_count + 1, 3, GGEN_NATURAL_PROFILE.Min());
	local posStep = (2.0 * PI) / player_count;
	for(local i = 0; i < startPos.GetWidth() - 1; i=i+1)
	{
		local s = (i * posStep) + (PI/2);
		local x = ((floor((cos(s) * playerDistance) + 0.5)) + "").tointeger() + (mapSize / 2);
		local y = ((floor((sin(s) * playerDistance) + 0.5)) + "").tointeger() + (mapSize / 2);
		
		startPos.SetValue(i,0, x);
		startPos.SetValue(i,1, y);
	}
	startPos.SetValue(startPos.GetWidth()-1,0, 0)
	startPos.SetValue(startPos.GetWidth()-1,1, 16384)
	
	
	
	local base = GGen_Data_2D(mapSize, mapSize, 8192);
	
	
	local craterSize = 144;
	local cutoff = 87;
	local centerpeak = 16;
	local peak = (cutoff - centerpeak) * (cutoff - centerpeak) - 4096
	local step = peak / (craterSize - cutoff - 1)
	local crater = GGen_Data_1D(craterSize, 0);
		
	for(local i =0; i < craterSize; i=i+1)
	{
		if(i <= cutoff){ crater.SetValue(i,  (i-centerpeak)*(i-centerpeak) - 4096)}
		else {  crater.SetValue(i, peak - (i - cutoff) * step )}
	}
	
	local a1 = craterSize*2 + 100;
	local a2 = a1/2;

	for(local j = 0; j < craterCount; j++)
	{
		//local scaleFactor = ((rand() % (craterSize - 10)) + 10)
		local scaleFactor = ((rand() % (maxCraterSize - 10)) + 10)
		local b1 = rand() % (mapSize + scaleFactor - 1) - scaleFactor;
		local b2 = rand() % (mapSize + scaleFactor - 1) - scaleFactor;		
		
		if(j> 0 && j % (craterCount/10) == 0)
		{
			GGen_IncreaseProgress();
		}		
		
		if(IsValidCraterPosition(b1 + scaleFactor/2, b2+ scaleFactor/2, scaleFactor/2 + 30, startPos))
		{
			local craterTileTemp = GGen_Data_2D(a1, a1, 0);
			craterTileTemp.RadialGradientFromProfile(a2, a2, craterSize, crater, false);
			craterTileTemp.ScaleTo(scaleFactor, scaleFactor, true);
			craterTileTemp.Distort(scaleFactor-1, scaleFactor/8);
			craterTileTemp.Smooth(4);
			craterTileTemp.Multiply((1.0 * scaleFactor) / (1.0*craterSize));
			base.AddTo(craterTileTemp, b1, b2);
			craterTileTemp = null;
		}
	}
	
	local mainNoise = GGen_Data_2D(mapSize, mapSize, GGEN_NATURAL_PROFILE.Min());
	mainNoise.Noise(smoothness, mapSize / 8, GGEN_STD_NOISE)
	mainNoise.ScaleValuesTo(0, 1024)
	
	local noiseLayer2 = GGen_Data_2D(mapSize, mapSize, GGEN_NATURAL_PROFILE.Min());
	noiseLayer2.Noise(1, 1, GGEN_STD_NOISE)
	noiseLayer2.ScaleValuesTo(0, 12)
	
	if(base.Min() < 2260)
	{
		base.ScaleValuesTo(2260, base.Max());
	}
	
	base.AddMap(mainNoise);
	base.AddMap(noiseLayer2);
	
	local range = (base.Max() - base.Min()) / 10;
	local highTerrainStart = base.Max() - (range * 2);
	local midTerrainStart = base.Max() - (range * 3);
	local lowTerrainStart = 7500;
	
	//Texture Maps
	local slopeMap = GGen_Data_2D(mapSize, mapSize, GGEN_NATURAL_PROFILE.Min());
	slopeMap = base.Clone();
	slopeMap.SlopeMap();
	
	slopeMap.ScaleValuesTo(0,1024);
	slopeMap.Add(-128);
	slopeMap.Clamp(0, 250);
	slopeMap.ScaleValuesTo(0,16384)
	slopeMap.Smooth(2);
	slopeMap.ScaleValuesTo(0,16384)
	slopeMap.ScaleTo(mapSize/2,mapSize/2,false)
	slopeMap.ReturnAs("Stratum8");
	
	local lowTerrain = GGen_Data_2D(mapSize, mapSize, GGEN_NATURAL_PROFILE.Min());
	lowTerrain = base.Clone();
	lowTerrain.CropValues(0, lowTerrainStart);
	lowTerrain.Monochrome(0);
	lowTerrain.Multiply(100.0);
	lowTerrain.Distort(50, 10);
	lowTerrain.Smooth(8);
	lowTerrain.ScaleValuesTo(0,10000)
	lowTerrain.ScaleTo(mapSize/2,mapSize/2,false)
	lowTerrain.ReturnAs("Stratum4");
	
	local randomTerrain = GGen_Data_2D(mapSize, mapSize, GGEN_NATURAL_PROFILE.Min());
	randomTerrain.Noise(10, mapSize / 8, GGEN_STD_NOISE);	
	randomTerrain.ScaleValuesTo(0,1024);
	randomTerrain.Clamp(0, 896);
	randomTerrain.ScaleValuesTo(0,16384);
	randomTerrain.ScaleTo(mapSize/2,mapSize/2,false)
	randomTerrain.ReturnAs("Stratum1");
	
	local randomTerrain2 = GGen_Data_2D(mapSize, mapSize, GGEN_NATURAL_PROFILE.Min());
	randomTerrain2.Noise(10, mapSize / 8, GGEN_STD_NOISE);	
	randomTerrain2.ScaleValuesTo(0,1024);
	randomTerrain2.Clamp(0, 896);
	randomTerrain2.ScaleValuesTo(0,16384);
	randomTerrain2.ScaleTo(mapSize/2,mapSize/2,false)
	randomTerrain2.ReturnAs("Stratum2");
	
	local rockMask2 = GGen_Data_2D(mapSize, mapSize, 0);;
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
	lowTerrain.Invert();
	treeMask.AddMap(slopeMap);
	treeMask.AddMap(lowTerrain);
	treeMask.Clamp(0, 2400);
	treeMask.ReturnAs("TreeMask");
	
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
	
	return base;
}