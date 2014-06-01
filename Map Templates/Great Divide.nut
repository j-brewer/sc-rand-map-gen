function GetInfo(info_type){
	switch(info_type){
		case "name":
			return "Great Divide";
		case "description":
			return "A map with few narrow canyons connecting opposing teams.";
		case "args":
			GGen_AddIntArg("width","Width","Width of the map.", 1024, 256, 20000, 1);
			GGen_AddIntArg("height","Height","Width of the map.", 1024, 256, 20000, 1);
			GGen_AddEnumArg("players","Number of players to fit on map","Affects the number of players on players map.", 2, "2;4;6;8;10;12");
			GGen_AddEnumArg("feature_size","Feature Size","Size of map noise features.", 1, "Tiny;Medium;Large");
			GGen_AddEnumArg("canyon_size","Canyon Size","Size of the canyons between the players.", 2, "Tiny;Small;Medium;Large;Very Large");
			GGen_AddEnumArg("flat_space","Available Build Area","Size of the flat area around player spawns.", 2, "Tiny;Small;Medium;Large;Very Large");
			GGen_AddEnumArg("smoothness","Smoothness","Affects amount of detail on the map.", 1, "Very Rough;Rough;Smooth;Very Smooth");
			GGen_AddEnumArg("rotation","Map Rotation","Affects the orientation ofthe map.", 0, "0;90");
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
	local width = GGen_GetArgValue("width");
	local height = GGen_GetArgValue("height");
	local feature_size = GGen_GetArgValue("feature_size");
	local smoothness = 1 << GGen_GetArgValue("smoothness");
	local map_rotation = GGen_GetArgValue("rotation") * 90;
	local player_count = (GGen_GetArgValue("players") + 1) * 2;
	local canyon_size = GGen_GetArgValue("canyon_size");
	local flat_space = 32 + height/16 + GGen_GetArgValue("flat_space") * (height/64);
	
	GGen_InitProgress(10);

  	//Handle Player Starting Positions
	local startPos = GGen_Data_2D(player_count + 1, 3, 0);
	
	local d = 1;
	if(player_count < 8){ d = 4;}
	else if(player_count < 12){ d = 6;}
	else { d = 8;}
	
	local startY = 48;
	local iOffset = 1;
	local y1 = startY;
	local y2 = height - startY;
	
	if(player_count == 6 ||  player_count == 10)
	{
		iOffset = 3;
	}
	
	for(local i = 0; i < startPos.GetWidth()-iOffset; i=i+2)
	{
		local x1 = ((i + 2)/2) * (width / d);
		if(i >= (startPos.GetWidth() -iOffset)/2)
		{
			x1 = ((i + 4)/2) * (width / d);
		}
		
		startPos.SetValue(i,0, x1);
		startPos.SetValue(i,1, y1);
		startPos.SetValue(i+1,0, width - x1);
		startPos.SetValue(i+1,1, y2);
	}
	
	local lIdx = 0;
	if(player_count == 6){ lIdx = 4;}
	else if(player_count == 10){ lIdx = 8;}
	
	if(lIdx > 0)
	{	
		startPos.SetValue(lIdx,0, y1);
		startPos.SetValue(lIdx,1, height/2);
		startPos.SetValue(lIdx+1,0, y2);
		startPos.SetValue(lIdx+1,1, height/2);
	}
	startPos.SetValue(startPos.GetWidth()-1,0, 0);
	startPos.SetValue(startPos.GetWidth()-1,1, 16384);
	
	GGen_IncreaseProgress();
	
	local waterDepth = 1500;
	local baseHeight = 3600;
	local mountainHeight = 8500;
	local actualCanyonSize = 16 + 8 * (canyon_size + 1);
	if(actualCanyonSize > width/8)
	{
		actualCanyonSize = width/8;
	}
	else if(actualCanyonSize > height/8)
	{
		actualCanyonSize = height/8;
	}
	
	local base = GGen_Data_2D(width, height, baseHeight);
	
	//Mountains
	local m = GGen_Path();
	 	 
	m.AddPointByCoords(-10, flat_space);
	m.AddPointByCoords(width, flat_space);
	m.AddPointByCoords(width, height-flat_space);
	m.AddPointByCoords(-10, height-flat_space);
	
	base.FillPolygon(m, mountainHeight);
	
	GGen_IncreaseProgress();
	
	//Land Canyons
	local lcSize = actualCanyonSize * 2;
	local lx1 = width/4 - (lcSize/2);
	local lx2 = 3*width/4 - (lcSize/2);
	local ly3 = height/2 - (lcSize/2);
	local lc1 = GGen_Path();
	local lc2 = GGen_Path();
	local lc3 = GGen_Path();
	
	lc1.AddPointByCoords(lx1, 0);
	lc1.AddPointByCoords(lx1+lcSize, 0);
	lc1.AddPointByCoords(lx1+lcSize, height-1);
	lc1.AddPointByCoords(lx1, height-1);
	
	base.FillPolygon(lc1, baseHeight);
	
	lc2.AddPointByCoords(lx2, 0);
	lc2.AddPointByCoords(lx2+lcSize, 0);
	lc2.AddPointByCoords(lx2+lcSize, height-1);
	lc2.AddPointByCoords(lx2, height-1);
	
	base.FillPolygon(lc2, baseHeight);
	
	lc3.AddPointByCoords(0, ly3);
	lc3.AddPointByCoords(0, ly3+lcSize);
	lc3.AddPointByCoords(width, ly3+lcSize);
	lc3.AddPointByCoords(width, ly3);
	
	base.FillPolygon(lc3, baseHeight);
	
	GGen_IncreaseProgress();
	
	//River Canyon
	local waterTransition = actualCanyonSize;
	local x1 = width/2 - (actualCanyonSize/2);
	local x2 = width/2 + (actualCanyonSize/2);
	
	local h = GGen_Path();
	 	 
	h.AddPointByCoords(x1, 0);
	h.AddPointByCoords(x2, 0);
	h.AddPointByCoords(x2, height);
	h.AddPointByCoords(x1, height);
	
	base.FillPolygon(h, waterDepth);
	base.Gradient(x1-waterTransition, 0, x1, 0, baseHeight, waterDepth, false);
	base.Gradient(x2, 0, x2 + waterTransition, 0, waterDepth, baseHeight, false);
	
	GGen_IncreaseProgress();
	
	local buffer = 96;
	if(width < 1024 || height < 1024){buffer = 72;}
	else if(width < 512 || height < 512){buffer = 56;}
	
	
	
	//Start Position Buffers
	for(local i = 0; i < startPos.GetWidth() - 1; i=i+1)
	{
		local x1 = startPos.GetValue(i,0);
		local y1 = startPos.GetValue(i,1);
		base.RadialGradient(x1, y1, buffer, baseHeight, baseHeight, false);
	}
	
	base.Smooth(12);
	base.Distort(96, 80);
	base.Smooth(3);
	GGen_IncreaseProgress();
	
	//Mountain noise (mountain tops should be nearly unusable for buildings)
	local mNoise = GGen_Data_2D(width, height, 0);
	mNoise.Noise(smoothness, 4, GGEN_STD_NOISE);
	mNoise.ScaleValuesTo(-256, 256);
	local mask = base.Clone();
	mask.Monochrome(base.Max() - 48);
	base.AddMapMasked(mNoise, mask true);
	
	
	// noise overlay
	local noise = GGen_Data_2D(width, height, 0);	
	noise.Noise(smoothness, ((width > height) ? height : width) / (60 - (15 * feature_size)), GGEN_STD_NOISE);
	noise.ScaleValuesTo(-32, 32);	
	base.AddMap(noise);
	
	if(map_rotation > 0)
	{
		base.Rotate(map_rotation, true);
	
		//Adjust Player Starting Positions for map rotation
		for(local i = 0; i < startPos.GetWidth() - 1; i=i+1)
		{
			
			local x = startPos.GetValue(i,0);
			local y = startPos.GetValue(i,1);
			startPos.SetValue(i,0, y);
			startPos.SetValue(i,1, height - x);
		}
	}
	
	//print(base.Max());
	//print(base.Min());
	
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
	veryhighTerrain.ReturnAs("Stratum6");
	
	local slopeMap = GGen_Data_2D(width, height, GGEN_NATURAL_PROFILE.Min());
	slopeMap = base.Clone();
	slopeMap.Clamp(2350, 32767);
	slopeMap.SlopeMap();
	slopeMap.Smooth(5);
	slopeMap.ScaleValuesTo(0,1024);
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
	
	for(local i = 0; i < startPos.GetWidth() - 1; i=i+1)
	{
		local x1 = startPos.GetValue(i,0);
		local y1 = startPos.GetValue(i,1);
		treeMask.RadialGradient(x1, y1,  32, 0, 0, false);
	}
	
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
	
	startPos.ReturnAs("StartPositions");
	
	return base;
}