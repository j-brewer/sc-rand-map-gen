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

function Generate(){
	local width = GGen_GetArgValue("mapsize");
	local height = GGen_GetArgValue("mapsize");
	local mapSize = height;
	local feature_size = GGen_GetArgValue("feature_size");
	local smoothness = 1 << GGen_GetArgValue("smoothness");
	local player_count = (GGen_GetArgValue("players"));

	GGen_InitProgress(6);

	// we must decide the smaller dimension to fit the circle into the map
	local size = mapSize / 2;
  
	// set up radial profile of the archipelago
	local profile = GGen_Data_1D(320, 0);
	
	local a = 40;
	local s = 160;
	local t = 198;
	local u = 260;
	local slope = 4;
	local slopeB = 2.0;
	local heightOffset = 3150;
	for(local i=1; i <= profile.GetLength(); i = i +1)
	{
		local val = 0.0;
		if(i < a){val = a/slope + i * heightOffset/a;}
		else if(i >= a && i < s){val = i/slope + heightOffset;}
		else if(i >= s && i < t){val = (slopeB)*(i-s)*(i-s) + s/slope + heightOffset;}
		else if(i >= t && i < u){val = (i-t)/slope + (slopeB)*(t-s)*(t-s) + s/slope + heightOffset;}
		else{val = -1*(slopeB)*(i-u)*(i-u)/2 + (u-t)/slope + (slopeB)*(t-s)*(t-s) + s/slope + heightOffset;}
		profile.SetValue(profile.GetLength() - i, val.tointeger());
	}
	profile.Smooth(6);
	profile.Smooth(6);
	
	GGen_IncreaseProgress();
	
	local base = GGen_Data_2D(width, height, 0);
	base.RadialGradientFromProfile(size, size, 400, profile, false);	
	base.Distort(64, 48);
	base.Distort(128, 100);
	base.Smooth(6);	
	profile = null;
	
	
	GGen_IncreaseProgress();
	
	// noise overlay
	local noise = GGen_Data_2D(width, height, 0);
	noise.Noise(smoothness, ((width > height) ? height : width) / (60 - (15 * feature_size)), GGEN_STD_NOISE);
	
	GGen_IncreaseProgress();
	
	noise.ScaleValuesTo(0, 512);
	
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
	
	
	
	//Find Starting locations
	local startPos = GGen_Data_2D(player_count + 1, 3, GGEN_NATURAL_PROFILE.Min());
	local posStep = (2.0 * PI) / player_count;
	for(local i = 0; i < startPos.GetWidth() - 1; i=i+1)
	{
		local s = (i * posStep) + (PI/2);
		local s1 = 0;
		local s2 = 0;
		local x = 0;
		local y = 0;
		for(local j = 10; j < size; j = j + 10)
		{
			x = ((floor((cos(s) * j) + 0.5)) + "").tointeger() + (mapSize / 2);
			y = ((floor((sin(s) * j) + 0.5)) + "").tointeger() + (mapSize / 2);
			local h = base.GetValue(x,y);
			if(h < 2600 && s1 == 0)
			{
				s1 = j;
			}
			else if(s2 == 0 && h < 2325)
			{
				s2 = j;
				x = ((floor((cos(s) * ((s2 + s1) / 2)) + 0.5)) + "").tointeger() + (mapSize / 2);
				y = ((floor((sin(s) * ((s2 + s1) / 2)) + 0.5)) + "").tointeger() + (mapSize / 2);
				break;
			}
		}
		startPos.SetValue(i,0, x);
		startPos.SetValue(i,1, y);
	}
	startPos.SetValue(startPos.GetWidth()-1,0, 0)
	startPos.SetValue(startPos.GetWidth()-1,1, 16384)
	startPos.ReturnAs("StartPositions");
	
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
	
	return base;
}