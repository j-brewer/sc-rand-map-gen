function GetInfo(info_type){
	switch(info_type){
		case "name":
			return "The Clutch";
		case "description":
			return "Two mountainous regions are connected only by a narrow land bridge.";
		case "args":
			GGen_AddIntArg("size","Size","Width and height of the map.", 1024, 128, 20000, 1);
			GGen_AddEnumArg("players","Number of players to fit on map","Affects the number of players on players map.", 2, "2;4;6;8;10;12");
			GGen_AddEnumArg("feature_size","Feature Size","Size of map noise features.", 1, "Tiny;Medium;Large");
			GGen_AddEnumArg("bridge_size","Land Bridge Size","Size of the land bridge in the middle of the map.", 2, "Tiny;Small;Medium;Large;Very Large");
			GGen_AddEnumArg("flat_space","Available Build Area","Size of the flat area around player spawns.", 2, "Tiny;Small;Medium;Large;Very Large");
			GGen_AddEnumArg("smoothness","Smoothness","Affects amount of detail on the map.", 1, "Very Rough;Rough;Smooth;Very Smooth");
			GGen_AddEnumArg("orientation","Orientation","Affects the layout of the height map.", 2, "Vertical;Horizontal;Diagonal 1;Diagonal 2");
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
	local width = GGen_GetArgValue("size");
	local height = GGen_GetArgValue("size");
	local feature_size = GGen_GetArgValue("feature_size");
	local smoothness = 1 << GGen_GetArgValue("smoothness");
	local player_count = (GGen_GetArgValue("players") + 1) * 2;
	local bridge_size = GGen_GetArgValue("bridge_size");
	local flat_space = 96 + GGen_GetArgValue("flat_space") * 16;
	local orientation = GGen_GetArgValue("orientation");
	
	GGen_InitProgress(10);
	
	local baseHeight = 0;
	local waterDepth1 = 2800;
	local shoreHeight = 3400;
	local mountainHeight = 6500;
	
	local base = GGen_Data_2D(width, height, baseHeight);

	local radial_profile = GGen_Data_1D(4, 0);
	radial_profile.SetValue(2, waterDepth1);
	radial_profile.SetValue(3, shoreHeight);
	
	if(orientation == 0 || orientation == 1)
	{
		base.RadialGradientFromProfile(width/7, height /2, width / 2, radial_profile, true);
		
		// create the land bridge
		local bridge = GGen_Data_2D(width, height, 0);
		bridge.Gradient(38 * width / 100, 1, 48 * height / 100, 1, 0, shoreHeight, true);
		base.Union(bridge);
		
		
		// mirror the map along the axis going from bottom left corner to upper right corner
		local copy = base.Clone();
		copy.Flip(GGEN_VERTICAL);		
		base.Intersection(copy);
		
		base.Gradient(0, 97 * height / 100, 0, height - 1, shoreHeight, mountainHeight, false);
		base.Gradient(0, 3 * height / 100, 0, 0, shoreHeight, mountainHeight, false);
		
		if(orientation == 1)
		{
			base.Rotate(90, true);
		}
	}
	else
	{
		// create the upper radial basin
		base.RadialGradientFromProfile(width / 4, height / 4, width / 2, radial_profile, true);
		
		// create the land bridge
		local bridge = GGen_Data_2D(width, height, 0);
		bridge.Gradient(40 * width / 100, 40 * height / 100, 49 * width / 100, 49 * height / 100, 0, shoreHeight, true);
		base.Union(bridge);
		
		// mirror the map along the axis going from bottom left corner to upper right corner
		local copy = base.Clone();
		copy.Flip(GGEN_HORIZONTAL);
		copy.Flip(GGEN_VERTICAL);
		base.Intersection(copy);
		
		// make sure there is no land in the corners
		base.SetValueInRect(0, 0, width / 4, height / 4, 0);
		base.SetValueInRect(3 * width / 4, 3 * height / 4, width - 1, height - 1, 0);	
		
		local mStartA = 20;
		local mStartB = 80;
		local mEndA = 10;
		local mEndB = 90;
		
		base.Gradient(mStartA * width / 100, mStartB * height / 100, mEndA * width / 100, mEndB * height / 100, shoreHeight, mountainHeight, false);
		base.Gradient(mEndA * width / 100, mEndB * height / 100, 0, height-1 mountainHeight, mountainHeight, false);
		
		base.Gradient(mStartB * width / 100, mStartA * height / 100, mEndB * width / 100, mEndA * height / 100, shoreHeight, mountainHeight, false);
		base.Gradient(mEndB * width / 100, mEndA * height / 100, width-1, 0, mountainHeight, mountainHeight, false);
	
		if(orientation == 3)
		{
			base.Flip(GGEN_HORIZONTAL)
		}
	}
	base.Smooth(100);
	base.Distort(64, 48);
	base.Smooth(10);
	
	
	local mask = base.Clone();
	mask.ScaleValuesTo(0,GGEN_MAX_HEIGHT / 2);
	mask.Add(GGEN_MAX_HEIGHT / 10);
	mask.Clamp(0, GGEN_MAX_HEIGHT / 2);
	mask.ScaleValuesTo(GGEN_MAX_HEIGHT / 30, GGEN_MAX_HEIGHT);

	local noise = GGen_Data_2D(width, height, 0);
	noise.Noise(smoothness, width / (5 - feature_size), GGEN_STD_NOISE);
	
	noise.ScaleValuesTo(0, 128);

	base.AddMapMasked(noise, mask, false);
	

		

	// noise overlay
	local noise = GGen_Data_2D(width, height, 0);	
	noise.Noise(smoothness, ((width > height) ? height : width) / (60 - (15 * feature_size)), GGEN_STD_NOISE);
	noise.ScaleValuesTo(0, 64);	
	base.AddMap(noise);
	
	print(base.Max());
	print(base.Min());
	
	local beachTerrainStart = 2257;
	
	local randomTerrain = GGen_Data_2D(width, height, GGEN_NATURAL_PROFILE.Min());
	randomTerrain.Noise(10, ((width > height) ? height : width) / 8, GGEN_STD_NOISE);	
	randomTerrain.ScaleValuesTo(0,1024);
	randomTerrain.Clamp(0, 896);
	randomTerrain.ScaleValuesTo(0,16384);
	randomTerrain.ScaleTo(width/2,height/2,false)
	randomTerrain.ReturnAs("Stratum1");
	
	GGen_IncreaseProgress();
	
	local randomTerrain = GGen_Data_2D(width, height, GGEN_NATURAL_PROFILE.Min());
	randomTerrain.Noise(10, ((width > height) ? height : width) / 8, GGEN_STD_NOISE);	
	randomTerrain.ScaleValuesTo(0,1024);
	randomTerrain.Clamp(0, 896);
	randomTerrain.ScaleValuesTo(0,16384);
	randomTerrain.ScaleTo(width/2,height/2,false)
	randomTerrain.ReturnAs("Stratum2");
	
	GGen_IncreaseProgress();
	
	local beachTerrain = GGen_Data_2D(width, height, GGEN_NATURAL_PROFILE.Min());
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
	beachTerrain.ScaleTo(width/2,height/2,false)	
	beachTerrain.ReturnAs("Stratum3");
	
	local middleTerrain = GGen_Data_2D(width, height, GGEN_NATURAL_PROFILE.Min());
	middleTerrain = base.Clone();
	middleTerrain.CropValues(2600, 5000);
	middleTerrain.Monochrome(1);
	middleTerrain.Distort(width/64, height/64);
	middleTerrain.AddMapMasked(noise, middleTerrain, true);
	middleTerrain.Smooth(10);
	middleTerrain.ScaleTo(width/2,height/2,false);	
	middleTerrain.ScaleValuesTo(0,16384);
	middleTerrain.ReturnAs("Stratum5");
	
	local highTerrain = GGen_Data_2D(width, height, GGEN_NATURAL_PROFILE.Min());
	highTerrain = base.Clone();
	highTerrain.CropValues(4000, 7000);
	highTerrain.Monochrome(1);
	highTerrain.Distort(width/64, height/64);
	highTerrain.AddMapMasked(noise, highTerrain, true);
	highTerrain.Smooth(10);
	highTerrain.ScaleTo(width/2,height/2,false)	
	highTerrain.ScaleValuesTo(0,16384);
	highTerrain.ReturnAs("Stratum6");
	
	local veryhighTerrain = GGen_Data_2D(width, height, GGEN_NATURAL_PROFILE.Min());
	veryhighTerrain = base.Clone();
	veryhighTerrain.CropValues(veryhighTerrain.Max() - 384, veryhighTerrain.Max());
	veryhighTerrain.Smooth(5);
	veryhighTerrain.ScaleValuesTo(0, 192);
	//veryhighTerrain.Monochrome(1);
	veryhighTerrain.Distort(width/32, height/32);
	veryhighTerrain.AddMapMasked(noise, veryhighTerrain, true);
	veryhighTerrain.Smooth(10);
	veryhighTerrain.ScaleTo(width/2,height/2,false)	
	veryhighTerrain.ScaleValuesTo(0,16384);
	veryhighTerrain.ReturnAs("Stratum7");
	
	local slopeMap = GGen_Data_2D(width, height, GGEN_NATURAL_PROFILE.Min());
	slopeMap = base.Clone();
	slopeMap.Clamp(2350, 32767);
	slopeMap.SlopeMap();
	slopeMap.Smooth(5);
	slopeMap.ScaleValuesTo(0,512);
	slopeMap.Add(-128);
	slopeMap.Clamp(0, 350);
	slopeMap.ScaleValuesTo(0,16384)
	slopeMap.ScaleTo(width/2,height/2,false)
	slopeMap.ReturnAs("Stratum8");
	
	GGen_IncreaseProgress();
	
	//Masks for  Trees & Rocks
	local rockMask = GGen_Data_2D(width, height, 0);
	rockMask.ReturnAs("RockMask");
	
	local treeMask = GGen_Data_2D(width, height, 0);
	
	treeMask = base.Clone();
	treeMask.Clamp(0, 2400);
	treeMask.CropValues(2300, 16535);
	treeMask.ScaleValuesTo(0, 2400);	
	treeMask.Smooth(2);
		
	local treeNoise = GGen_Data_2D(width, height, GGEN_NATURAL_PROFILE.Min());
	treeNoise.Noise(10, ((width > height) ? height : width) / 8, GGEN_STD_NOISE);		
	treeNoise.ScaleValuesTo(0, 5000);		
	treeMask.AddMapMasked(treeNoise, treeMask, true);
	treeMask.ScaleValuesTo(0, 1800);
	
	/*
	for(local i = 0; i < startPos.GetWidth() - 1; i=i+1)
	{
		local x1 = startPos.GetValue(i,0);
		local y1 = startPos.GetValue(i,1);
		treeMask.RadialGradient(x1, y1,  32, 0, 0, false);
	}
	*/
	
	beachTerrain.Smooth(4);
	beachTerrain.Invert();
	slopeMap.Invert();
	slopeMap.ScaleValuesTo(-1800, 0);
	veryhighTerrain.Invert();
	veryhighTerrain.ScaleValuesTo(-1800, 0);
	treeMask.AddMap(slopeMap);
	treeMask.AddMap(veryhighTerrain);
	treeMask.AddMap(beachTerrain);
	treeMask.Smooth(2);
	treeMask.Clamp(0, 2400);
	treeMask.ReturnAs("TreeMask");
	
	GGen_IncreaseProgress();
	
	//startPos.ReturnAs("StartPositions");
	
	return base;
}