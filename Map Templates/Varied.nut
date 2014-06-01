function GetInfo(info_type){
	switch(info_type){
		case "name":
			return "Generic Battleground";
		case "description":
			return "A map varied geography including mountains, rivers, craters, and lakes.";
		case "args":
			GGen_AddIntArg("size","Size of the map","", 1024, 128, 20000, 1);
			GGen_AddEnumArg("players","Number of players to fit on map","Affects the number of players on players map.", 2, "2;4;6;8;10;12");
			GGen_AddEnumArg("feature_size","Feature Size","Size of map noise features.", 1, "Tiny;Medium;Large");
			GGen_AddEnumArg("smoothness","Smoothness","Affects amount of detail on the map.", 1, "Very Rough;Rough;Smooth;Very Smooth");
			GGen_AddIntArg("start_distance_from_center","Player Distance From Center","Affects the distance of the islands from the center of the map.", 8, 0, 13, 1);			
			GGen_AddEnumArg("rotation","Map Rotation (degrees)","Affects the overall orientation of the map islands.", 0, "0;15;30;45;60;75;90;105;120;135;150;165");
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

function CreateMountainLayer(rH, rW, rA)
{
	local num_mountains = rand() % 60;
	
	local mountains = GGen_Data_2D(rW, rH, 0);
	for(local i = 0; i < num_mountains; i=i+1)
	{
		local m = GGen_Path();
	 	local mX = rand() % rW;
	 	local mY = rand() % rH;
	 	local mS = rand() % 25 + 25;
	 	
	 	local mShp = rand() % 2;
	 	if(mShp == 1)
	 	{
			m.AddPointByCoords(mX-mS, mY-mS);
			m.AddPointByCoords(mX+mS, mY-mS);
			m.AddPointByCoords(mX+mS, mY+mS);
			m.AddPointByCoords(mX-mS, mY+mS);
		
			mountains.FillPolygon(m, rA);
		}
		else
		{
			mountains.RadialGradient(mX, mY, mS, rA, rA, false);
		}
	}
	return mountains;
}

function CreateVolcanoLayer(rH, rW, rA)
{
	local num_vol = rand() % 20;
	
	local vol = GGen_Data_2D(rW, rH, 0);
	for(local i = 0; i < num_vol; i=i+1)
	{
	 	local mX = rand() % rW;
	 	local mY = rand() % rH;
	 	local mS = rand() % 25 + 25;
	 	
	 	local mShp = rand() % 2;
	 	if(mShp == 1)
	 	{
	 		local m = GGen_Path();
			m.AddPointByCoords(mX-mS, mY-mS);
			m.AddPointByCoords(mX+mS, mY-mS);
			m.AddPointByCoords(mX+mS, mY+mS);
			m.AddPointByCoords(mX-mS, mY+mS);
			
			local m2 = GGen_Path();
			local crater = mS / 2;
			m2.AddPointByCoords(mX-crater, mY-crater);
			m2.AddPointByCoords(mX+crater, mY-crater);
			m2.AddPointByCoords(mX+crater, mY+crater);
			m2.AddPointByCoords(mX-crater, mY+crater);
		
			vol.FillPolygon(m, rA);
			vol.FillPolygon(m2, rA-2000);
		}
		else
		{
			vol.RadialGradient(mX, mY, mS, rA, rA, false);
			vol.RadialGradient(mX, mY, mS/4, rA - 1000, rA - 1000, false);
		}
	}
	return vol;
}

function CreateOceanLayer(rH, rW, rA, rL, mW)
{
	local num_oceans = rand() % 9;
	local ocean_size = (rand() % mW/3) + 50
	local shoreline = 100;
	
	local oceans = GGen_Data_2D(rW, rH, 0);
	if(num_oceans == 1 || num_oceans == 4 || num_oceans > 5)
	{
		oceans.SetValueInRect(0,0, ocean_size, rH-1, rA);
		oceans.Gradient(ocean_size, 0, ocean_size + shoreline, 0, rA, rL, false);
	}
	if(num_oceans == 2 || num_oceans == 5 || num_oceans > 5)
	{
		oceans.SetValueInRect(rW-ocean_size,0, rW-1, rH-1, rA);
		oceans.Gradient(rW-ocean_size, 0, rW-ocean_size - shoreline, 0, rA, rL, false);
	}
	
	return oceans;
}


function CreateLakeLayer(rH, rW, rA, rL)
{
	local num_lakes = rand() % 10;
	local lakes = GGen_Data_2D(rW, rH, 0);
	
	for(local i = 0; i < num_lakes; i=i+1)
	{
		local l = GGen_Path();
	 	local lX = rand() % rW;
	 	local lY = rand() % rH;
	 	local lS = rand() % 25 + 25;
	 	
	 	local lShp = rand() % 2;
	 	if(lShp == 1)
	 	{
			l.AddPointByCoords(lX-lS, lY-lS);
			l.AddPointByCoords(lX+lS, lY-lS);
			l.AddPointByCoords(lX+lS, lY+lS);
			l.AddPointByCoords(lX-lS, lY+lS);
		
			lakes.FillPolygon(l, rA);
		}
		else
		{
			lakes.RadialGradient(lX, lY, lS, rA, rA, false);
		}
	}
	lakes.ReplaceValue(0, rL);
	lakes.Smooth(40);
	lakes.CropValues(0, lakes.Max()-1);
	
	return lakes;
}

function CreateRiverLayer(rH, rW, rA, rL)
{
	local num_rivers = rand() % 5;
	local rivers = GGen_Data_2D(rW, rH, 0);
	local riverWidth = rand() % 40 + 20;
	local waterTransition = riverWidth*2;
	local y1 = rH/2 - (riverWidth/2);
	local y2 = rH/2 + (riverWidth/2);
	
	local h = GGen_Path();
 	 
	h.AddPointByCoords(-1, y1);
	h.AddPointByCoords(-1, y2);
	h.AddPointByCoords(rW, y2);
	h.AddPointByCoords(rW, y1);

	rivers.FillPolygon(h, rA);
	rivers.Gradient(0, y1-waterTransition, 0, y1, rL, rA, false);
	rivers.Gradient(0, y2, 0, y2 + waterTransition, rA, rL, false);	
	
	if(num_rivers == 1)
	{
		rivers.SetValueInRect(0,0, rW/2, rH-1, 0);
	}
	if(num_rivers == 2)
	{
		rivers.SetValueInRect(rW/2, 0, rW-1, rH-1, 0);
	}
	
	return rivers;	
}

function Generate(){
	local width = GGen_GetArgValue("size");
	local height = GGen_GetArgValue("size");
	local feature_size = GGen_GetArgValue("feature_size");
	local smoothness = 1 << GGen_GetArgValue("smoothness");
	local player_count = (GGen_GetArgValue("players") + 1) * 2;
	local startPosDistance = ((GGen_GetArgValue("start_distance_from_center")+ 16) * width) / 64;
	local rotation = GGen_GetArgValue("rotation") * (PI/12);
	
	GGen_InitProgress(11);
	
	local angle2 = (floor(rotation * (360 / (2.0 * PI))) ).tointeger();

	//Handle Player Starting Positions
	local startPos = GGen_Data_2D(player_count + 1, 3, GGEN_NATURAL_PROFILE.Min());
	local posStep = PI;
	local player_buffer = 72 + (rand() % 96);
	
	local s1 = (PI/2) + rotation;
	local px1 = ((floor((cos(s1) * startPosDistance) + 0.5)) + "").tointeger() + (width / 2);
	local py1 = ((floor((sin(s1) * startPosDistance) + 0.5)) + "").tointeger() + (height / 2);
	
	local s2 = posStep + (PI/2) + rotation;
	local px2 = ((floor((cos(s2) * startPosDistance) + 0.5)) + "").tointeger() + (width / 2);
	local py2 = ((floor((sin(s2) * startPosDistance) + 0.5)) + "").tointeger() + (height / 2);
	
	local pOffsetA = player_buffer/2 * (((player_count/2)+1) % 2);
	local pOffsetB = player_buffer/2 + player_buffer/2 * ((player_count/2) % 2);
	if(player_count == 2){pOffsetA = 0;}
	
	local p1vpcd = (player_count + 2) / 4;	
	local p1vpcu = player_count / 4;	
	local p2vpcd = player_count / 4;
	local p2vpcu = (player_count + 2) / 4;
	
	local vd = s1 + PI/2;
	local vu = s1 - PI/2;

	for(local i = 0; i < p1vpcd; i++)
	{
		local idx = i *4;
		local d = pOffsetA + i * player_buffer;
		local x = ((floor((cos(vd) * d) + 0.5)) + "").tointeger() + px1;
		local y = ((floor((sin(vd) * d) + 0.5)) + "").tointeger() + py1;

		startPos.SetValue(idx,0, x);
		startPos.SetValue(idx,1, y);
	}
	for(local i = 0; i < p1vpcu; i++)
	{
		local idx = (i * 4) + 2;
		local d = pOffsetB + i * player_buffer;
		local x = ((floor((cos(vu) * d) + 0.5)) + "").tointeger() + px1;
		local y = ((floor((sin(vu) * d) + 0.5)) + "").tointeger() + py1;

		startPos.SetValue(idx,0, x);
		startPos.SetValue(idx,1, y);
	}
	for(local i = 0; i < p2vpcu; i++)
	{
		local idx = (i * 4) + 1;
		local d = pOffsetA + i * player_buffer;
		local x = ((floor((cos(vu) * d) + 0.5)) + "").tointeger() + px2;
		local y = ((floor((sin(vu) * d) + 0.5)) + "").tointeger() + py2;

		startPos.SetValue(idx,0, x);
		startPos.SetValue(idx,1, y);
	}
	for(local i = 0; i < p2vpcd; i++)
	{
		local idx = (i * 4) + 3;
		local d = pOffsetB + i * player_buffer;
		local x = ((floor((cos(vd) * d) + 0.5)) + "").tointeger() + px2;
		local y = ((floor((sin(vd) * d) + 0.5)) + "").tointeger() + py2;

		startPos.SetValue(idx,0, x);
		startPos.SetValue(idx,1, y);
	}
	
	startPos.SetValue(startPos.GetWidth()-1,0, 0)
	startPos.SetValue(startPos.GetWidth()-1,1, 16384)
	
	GGen_IncreaseProgress();
	
	local lakeDepth = 1700;
	local oceanDepth = 1000;
	local baseHeight = 3600;
	local mountainHeight = 6500;
	
	local base = GGen_Data_2D(width, height, baseHeight);
	
	local num_craters = rand() % 5;
	
	
	local rW = ((sqrt(2) * width) + 1).tointeger();
	local rH = ((sqrt(2) * height) + 1).tointeger();
	
	local mask = GGen_Data_2D(width, height, 0);
	
	//Mountains
	local mountains = CreateMountainLayer(rH, rW, mountainHeight);	
	mountains.Rotate(-angle2, true);
	mountains.ResizeCanvas(width, height, (rW - width)/2, (rH - height)/2);
	mask = mountains.Clone();
	mask.Monochrome(1);
	mask.Invert();
	mask.Add(1);
	base.Combine(mountains, mask, true);	
	mask = null;
	mountains = null;
	GGen_IncreaseProgress();
	
	//Volcanos
	local volcanos = CreateVolcanoLayer(rH, rW, mountainHeight + 500);
	
	volcanos.Rotate(-angle2, true);
	volcanos.ResizeCanvas(width, height, (rW - width)/2, (rH - height)/2);
	mask = volcanos.Clone();
	mask.Monochrome(1);
	mask.Invert();
	mask.Add(1);
	base.Combine(volcanos, mask, true);	
	mask = null;
	volcanos = null;
	GGen_IncreaseProgress();
	
	
	
	//Lakes
	local lakes = CreateLakeLayer(rH, rW, lakeDepth, baseHeight);
	lakes.Rotate(-angle2, true);
	lakes.ResizeCanvas(width, height, (rW - width)/2, (rH - height)/2);
	mask = lakes.Clone();
	mask.Monochrome(1);
	mask.Invert();
	mask.Add(1);
	base.Combine(lakes, mask, true);
	
	mask = null;
	lakes = null;
	
	//Rivers & Oceans
	local oceans = CreateOceanLayer(rW, rH, oceanDepth, baseHeight, width);
	oceans.Rotate(-angle2, true);
	oceans.ResizeCanvas(width, height, (rW - width)/2, (rH - height)/2);

	local rivers = CreateRiverLayer(rW, rH, lakeDepth, baseHeight);
	rivers.Rotate(-angle2, true);
	rivers.ResizeCanvas(width, height, (rW - width)/2, (rH - height)/2);
	
	//Combine Rivers and Oceans while preserving the lowest height values.
	rivers.ReplaceValue(0,10000);
	rivers.Invert();
	oceans.ReplaceValue(0,10000);
	oceans.Invert();
	rivers.Union(oceans);	
	
	
	base.Invert();
	base.Union(rivers);
	base.Invert();
	
	/*
	mask = rivers.Clone();
	mask.Monochrome(1);
	mask.Invert();
	mask.Add(1);
	base.Combine(rivers, mask, true);
	*/
	mask = null;
	rivers = null;
	oceans = null;
	
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
	
	// noise overlay
	local noise = GGen_Data_2D(width, height, 0);	
	noise.Noise(smoothness, ((width > height) ? height : width) / (60 - (15 * feature_size)), GGEN_STD_NOISE);
	noise.ScaleValuesTo(-32, 32);	
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