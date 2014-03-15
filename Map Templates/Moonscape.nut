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
			GGen_AddIntArg("width","Width","Width of the map.", 1024, 128, 20000, 1);
			GGen_AddIntArg("height","Height","Width of the map.", 1024, 128, 20000, 1);
			GGen_AddEnumArg("smoothness","Smoothness","Affects amount of detail on the map.", 1, "Very Rough;Rough;Smooth;Very Smooth");			
			GGen_AddEnumArg("crater_count","Number of Craters","Affects the number of craters on the map.", 2, "Very Few;Few;Some;Many;Very Many");
			GGen_AddEnumArg("max_crater_size","Maximum Crater Size","Affects the size of craters on the map.", 2, "Very Small;Small;Medium;Large;Very Large");
			GGen_AddEnumArg("players","Number of players to fit on map","Affects the number of paths on map.", 1, "2;4;6;8");
			
			return 0;
	}
}

function Generate(){
	GGen_InitProgress(10);
	
	local width = GGen_GetArgValue("width");
	local height = GGen_GetArgValue("height");
	
	local player_count = 2 * (GGen_GetArgValue("players") + 1);
	local craterCount = (GGen_GetArgValue("crater_count") + 1) * 100 + 50;
	local maxCraterSize = (GGen_GetArgValue("max_crater_size") + 1) *  64;
	local smoothness = 1 << GGen_GetArgValue("smoothness");
	
	//Handle Player Starting Positions
	local startPos = GGen_Data_2D(player_count + 1, 3, GGEN_NATURAL_PROFILE.Min());
	
	
	
	if(player_count == 2)
	{
		startPos.SetValue(0,0, width/16)
		startPos.SetValue(0,1, height/2)
		startPos.SetValue(1,0, 15*width/16)
		startPos.SetValue(1,1, height/2)
		startPos.SetValue(2,0, 0)
		startPos.SetValue(2,1, 16384)
	}
	else if(player_count == 4)
	{
		startPos.SetValue(0,0, width/16)
		startPos.SetValue(0,1, height/4)
		startPos.SetValue(1,0, 15*width/16)
		startPos.SetValue(1,1, 3*height/4)
		startPos.SetValue(2,0, width/16)
		startPos.SetValue(2,1, 3*height/4)
		startPos.SetValue(3,0, 15*width/16)
		startPos.SetValue(3,1, height/4)
		startPos.SetValue(4,0, 0)
		startPos.SetValue(4,1, 16384)
		
	}
	else if(player_count == 6)
	{
		startPos.SetValue(0,0, width/16)
		startPos.SetValue(0,1, height/2)
		startPos.SetValue(1,0, 15*width/16)
		startPos.SetValue(1,1, height/2)
		startPos.SetValue(2,0, width/16)
		startPos.SetValue(2,1, height/6)
		startPos.SetValue(3,0, 15*width/16)
		startPos.SetValue(3,1, 5*height/6)
		startPos.SetValue(4,0, width/16)
		startPos.SetValue(4,1, 5*height/6)
		startPos.SetValue(5,0, 15*width/16)
		startPos.SetValue(5,1, height/6)
		startPos.SetValue(6,0, 0)
		startPos.SetValue(6,1, 16384)
	}
	else if(player_count == 8)
	{
		startPos.SetValue(0,0, width/32)
		startPos.SetValue(0,1, height/4)
		startPos.SetValue(1,0, 31*width/32)
		startPos.SetValue(1,1, 3*height/4)
		startPos.SetValue(2,0, width/32)
		startPos.SetValue(2,1, 3*height/4)
		startPos.SetValue(3,0, 31*width/32)
		startPos.SetValue(3,1, height/4)
		startPos.SetValue(4,0, width/16)
		startPos.SetValue(4,1, height/32)
		startPos.SetValue(5,0, 15*width/16)
		startPos.SetValue(5,1, 31*height/32)
		startPos.SetValue(6,0, width/16)
		startPos.SetValue(6,1, 31*height/32)
		startPos.SetValue(7,0, 15*width/16)
		startPos.SetValue(7,1, height/32)
		startPos.SetValue(8,0, 0)
		startPos.SetValue(8,1, 16384)
	}
	
	
	local base = GGen_Data_2D(width, height, 8192);
	
	
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
	
	local craterTile = GGen_Data_2D(a1, a1, 0);

	for(local j = 0; j < craterCount; j++)
	{
		//local scaleFactor = ((rand() % (craterSize - 10)) + 10)
		local scaleFactor = ((rand() % (maxCraterSize - 10)) + 10)
		local b1 = rand() % (width + scaleFactor - 1) - scaleFactor;
		local b2 = rand() % (height + scaleFactor - 1) - scaleFactor;		
		
		if(j> 0 && j % (craterCount/10) == 0)
		{
			GGen_IncreaseProgress();
		}		
		
		if(IsValidCraterPosition(b1 + scaleFactor/2, b2+ scaleFactor/2, scaleFactor/2 + 50, startPos))
		{
			craterTile.RadialGradientFromProfile(a2, a2, craterSize, crater, false);
			craterTile.ScaleTo(scaleFactor, scaleFactor, true);
			craterTile.Distort(scaleFactor-1, scaleFactor/8);
			craterTile.Smooth(4);
			craterTile.Multiply((1.0 * scaleFactor) / (1.0*craterSize));
			base.AddTo(craterTile, b1, b2);
			craterTile.ScaleTo(a1, a1, false);
		}
	}
	
	local mainNoise = GGen_Data_2D(width, height, GGEN_NATURAL_PROFILE.Min());
	mainNoise.Noise(smoothness, width > height ? height / 8 : width / 8, GGEN_STD_NOISE)
	mainNoise.ScaleValuesTo(0, 1024)
	
	local noiseLayer2 = GGen_Data_2D(width, height, GGEN_NATURAL_PROFILE.Min());
	noiseLayer2.Noise(1, 1, GGEN_STD_NOISE)
	noiseLayer2.ScaleValuesTo(0, 12)
	
	base.AddMap(mainNoise);
	base.AddMap(noiseLayer2);
	base.Add(-base.Min() + 450);
	
	local range = (base.Max() - base.Min()) / 10;
	local highTerrainStart = base.Max() - (range * 2);
	local midTerrainStart = base.Max() - (range * 3);
	//Texture Maps
	local slopeMap = GGen_Data_2D(width, height, GGEN_NATURAL_PROFILE.Min());
	slopeMap = base.Clone();
	slopeMap.SlopeMap();
	
	slopeMap.ScaleValuesTo(0,1024);
	slopeMap.Add(-128);
	slopeMap.Clamp(0, 512);
	slopeMap.ScaleValuesTo(0,255)
	slopeMap.ScaleTo(width/2,height/2,true)
	slopeMap.ReturnAs("Stratum4");
	
	local highTerrain = GGen_Data_2D(width, height, GGEN_NATURAL_PROFILE.Min());
	highTerrain = base.Clone();
	highTerrain.Add(-highTerrainStart);
	highTerrain.Clamp(0, range);
	highTerrain.ScaleValuesTo(0,255)
	highTerrain.ScaleTo(width/2,height/2,true)
	highTerrain.ReturnAs("Stratum3");
	
	local mediumTerrain = GGen_Data_2D(width, height, GGEN_NATURAL_PROFILE.Min());
	mediumTerrain = base.Clone();
	mediumTerrain.Add(-midTerrainStart);
	mediumTerrain.Clamp(0, range);
	mediumTerrain.ScaleValuesTo(0,255)
	mediumTerrain.ScaleTo(width/2,height/2,true)
	mediumTerrain.ReturnAs("Stratum2");
	
	local randomTerrain = GGen_Data_2D(width, height, GGEN_NATURAL_PROFILE.Min());
	randomTerrain.Noise(10, width > height ? height / 8 : width / 8, GGEN_STD_NOISE);	
	randomTerrain.ScaleValuesTo(0,1024);
	randomTerrain.Clamp(0, 896);
	randomTerrain.ScaleValuesTo(0,1024);
	randomTerrain.ScaleTo(width/2,height/2,true)
	randomTerrain.ReturnAs("Stratum1");
	
	startPos.ReturnAs("StartPositions");
	
	return base;
}