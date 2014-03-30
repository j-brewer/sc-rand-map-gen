function GetInfo(info_type){
	switch(info_type){
		case "name":
			return "Volcano";
		case "description":
			return "A single volcano in the middle with ocean around.";
		case "args":
			GGen_AddIntArg("mapsize","Map Size","Size of the map.", 1024, 128, GGen_GetMaxMapSize(), 1);
			GGen_AddIntArg("players","Number of players to fit on map","Affects the number of paths on map.", 6, 2, 9, 1);
			GGen_AddEnumArg("feature_size","Island Size","Size of individual islands.", 1, "Tiny;Medium;Large");
			GGen_AddEnumArg("smoothness","Smoothness","Affects amount of detail on the map.", 1, "Very Rough;Rough;Smooth;Very Smooth");
			
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
	local width = GGen_GetArgValue("mapsize");
	local height = GGen_GetArgValue("mapsize");
	local mapSize = height;
	local feature_size = GGen_GetArgValue("feature_size");
	local smoothness = 1 << GGen_GetArgValue("smoothness");
	local player_count = (GGen_GetArgValue("players"));
	local playerDistance = (3 * mapSize) / 8;
	GGen_InitProgress(6);

	// we must decide the smaller dimension to fit the circle into the map
	local size = mapSize / 2;
  
  	//Handle Player Starting Positions
	local startPos = GGen_Data_2D(player_count + 1, 3, 0);
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
	
	
	GGen_IncreaseProgress();

	local base = GGen_Data_2D(width, height,9000);
	
	//base.RadialGradientFromProfile(size, size, 400, profile, false);
	local valleyCount = 7
	local stepSize = width/valleyCount;
	local valleySize = height/(valleyCount * 4);
	for(local i = 0; i < valleyCount+1; i++)
	{
		local x1 = (i * stepSize - valleySize >= 0) ? i * stepSize - valleySize : 0;
		local x2 = (i * stepSize + valleySize < width) ? i * stepSize + valleySize : width-1;
		base.SetValueInRect(x1, 0, x2, height-1, 3500);
	}
	for(local i =0; i < valleyCount +1; i++)
	{
		local y1 = (i * stepSize - valleySize >= 0) ? i * stepSize - valleySize : 0;
		local y2 = (i * stepSize + valleySize < height) ? i * stepSize + valleySize : height-1;
		base.SetValueInRect(0, y1, width-1, y2, 3500);
	}
	
	for(local i = 0; i < startPos.GetWidth() - 1; i=i+1)
	{
		local x1 = startPos.GetValue(i,0);
		local y1 = startPos.GetValue(i,1);
		base.RadialGradient(x1, y1, 96, 3500, 3500, false);
	}
	
	base.Smooth(25);
	
	base.Distort(96, 80);
	base.Smooth(3);
	
	
	GGen_IncreaseProgress();
	
	// noise overlay
	local noise = GGen_Data_2D(width, height, 0);
	noise.Noise(smoothness, ((width > height) ? height : width) / (60 - (15 * feature_size)), GGEN_STD_NOISE);
	
	GGen_IncreaseProgress();
	
	noise.ScaleValuesTo(0, 192);
	
	base.AddMapMasked(noise, base, true);
	
	noise.ScaleValuesTo(0, 128);	
	base.AddMap(noise);
	
	GGen_IncreaseProgress();
	
	//base.Flood(0.03);
	
	GGen_IncreaseProgress();
	//base.TransformValues(GGEN_NATURAL_PROFILE, true);
	//base.Multiply(2.1);
	//base.ScaleValuesTo(0, 8192);
	//base.Add(600);
	print(base.Max());
	print(base.Min());
	
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
	
	local veryhighTerrain = GGen_Data_2D(mapSize, mapSize, GGEN_NATURAL_PROFILE.Min());
	veryhighTerrain = base.Clone();
	veryhighTerrain.CropValues(6000, 10000);
	veryhighTerrain.ScaleValuesTo(0, 192);
	//veryhighTerrain.Monochrome(1);
	veryhighTerrain.Distort(mapSize/32, mapSize/32);
	veryhighTerrain.AddMapMasked(noise, veryhighTerrain, true);
	veryhighTerrain.Smooth(10);
	veryhighTerrain.ScaleTo(mapSize/2,mapSize/2,false)	
	veryhighTerrain.ScaleValuesTo(0,16384);
	veryhighTerrain.ReturnAs("Stratum7");
	
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
	veryhighTerrain.Invert();
	veryhighTerrain.ScaleValuesTo(-1800, 0);
	beachTerrain.Smooth(4);
	beachTerrain.Invert();
	treeMask.AddMap(slopeMap);
	treeMask.AddMap(veryhighTerrain);
	treeMask.AddMap(beachTerrain);
	treeMask.Smooth(2);
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