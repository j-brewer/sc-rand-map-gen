function GetInfo(info_type){
	switch(info_type){
		case "name":
			return "Voronoi";
		case "description":
			return "VornoiNoise usage demonstration (that actually gives guite nice results).";
		case "args":
			GGen_AddIntArg("width","Width","Width of the map.", 1024, 128, 20000, 1);
			GGen_AddIntArg("height","Height","Width of the map.", 1024, 128, 20000, 1);
			GGen_AddEnumArg("tile_distortion","Amount of distorion applied after tiling.","Affects how heavily the tile patterns are distorted.", 2, "None;Little;Some;Moderate;Very");
			GGen_AddEnumArg("ridge_size","Width of pattern ridges.","Affects how wide ridges are.", 2, "Very Narrow;Narrow;Average;Wide;Very Wide");
			GGen_AddEnumArg("smoothness","Smoothness","Affects amount of detail on the map.", 1, "Very Rough;Rough;Smooth;Very Smooth");			
			GGen_AddEnumArg("tile_size","Truchet Tile Size","Affects size of Truchet tiles.", 1, "Tiny;Small;Medium;Large;Huge");
			GGen_AddEnumArg("players","Number of players to fit on map","Affects the number of paths on map.", 1, "2;4;6;8");
			
			return 0;
	}
}

function Generate(){
	local width = GGen_GetArgValue("width");
	local height = GGen_GetArgValue("height");
	local tilesize = (GGen_GetArgValue("tile_size") + 1) * 64 + 1
	local ridge_size = GGen_GetArgValue("ridge_size") + 1;
	local player_count = GGen_GetArgValue("players");

	local smoothness = 1 << GGen_GetArgValue("smoothness");
	local distortion = GGen_GetArgValue("tile_distortion") * 35 + 1;
	
	
	local base = GGen_Data_2D(width, height, GGEN_NATURAL_PROFILE.Min());
	local mainNoise = GGen_Data_2D(width, height, GGEN_NATURAL_PROFILE.Min());
	mainNoise.Noise(smoothness, width > height ? height / 8 : width / 8, GGEN_STD_NOISE)
	
	local tileRotate = GGen_Data_1D( ((width / tilesize)+1) * ((height / tilesize)+1), GGEN_NATURAL_PROFILE.Min());
	tileRotate.Noise(1,15,GGEN_STD_NOISE)
	//return tileRotate;
	local counterA = 0;
	//local counterB = 0;
	
	local lineSize = ridge_size * 15;
	
	local tile = GGen_Data_2D(tilesize, tilesize, GGEN_NATURAL_PROFILE.Min());
	
	local tg1 = tilesize/4;
	local tg2 = lineSize/2;
	local tg3 = 3 * tilesize / 4;
	tile.Gradient(tg1-tg2,tg1-tg2, tg1, tg1, 0, 1000, false);
	tile.Gradient(tg1,tg1, tg1+tg2, tg1+tg2, 1000, 0, false);
	
	tile.Gradient(tg3-tg2,tg3-tg2, tg3, tg3, 0, 1000, false);
	tile.Gradient(tg3,tg3, tg3+tg2, tg3+tg2, 1000, 0, false);		
	
	//return tile;	
	
	
	local temp = tile.Clone()
	temp.Rotate(90);
	for(local i =0; i < width; i=i+tilesize)
	{
		for(local j =0; j < width; j=j+tilesize)
		{
			if(tileRotate.GetValue(counterA) % 2 == 0)
			{
				base.AddTo(temp, i, j);
			}
			else
			{
			base.AddTo(tile, i, j);
			}
			counterA++;
			
			
		}
		//counterA = 0;
		//counterB++;
	}
	//return base;
	local startPos = GGen_Data_2D(2*(player_count+1) + 1, 3, GGEN_NATURAL_PROFILE.Min());
		
	if(player_count == 0)
	{
		base.SetValueInRect(0, height/2 - height/16, width-1, height/2 + height/16, 0);
		startPos.SetValue(0,0, width/16)
		startPos.SetValue(0,1, height/2)
		startPos.SetValue(1,0, 15*width/16)
		startPos.SetValue(1,1, height/2)
		startPos.SetValue(2,0, 0)
		startPos.SetValue(2,1, 16384)
	}
	else if(player_count == 1)
	{
		base.SetValueInRect(0, height/4 - height/16, width-1, height/4 + height/16, 0);
		base.SetValueInRect(0, (3*height/4) - height/16, width-1, (3*height/4) + height/16, 0);
		
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
	else if(player_count == 2)
	{
		base.SetValueInRect(0, height/6 - height/16, width-1, height/6 + height/16, 0);
		base.SetValueInRect(0, height/2 - height/16, width-1, height/2 + height/16, 0);
		base.SetValueInRect(0, (5*height/6) - height/16, width-1, (5*height/6) + height/16, 0);
		
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
	else if(player_count == 3)
	{
		base.SetValueInRect(0, height/4 - height/16, width-1, height/4 + height/16, 0);
		base.SetValueInRect(0, (3*height/4) - height/16, width-1, (3*height/4) + height/16, 0);
		base.SetValueInRect(width/4 - width/16, 0 , width/4 + width/16, height-1,  0);
		base.SetValueInRect((3*width/4) - width/16, 0 , (3*width/4) + width/16, height-1,  0);
		
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
	
	base.Distort(distortion, distortion)
	base.Smooth(10)
	base.ScaleValuesTo(0,1000)
	
	local mask = GGen_Data_2D(width, height, GGEN_NATURAL_PROFILE.Min());
	mask = base.Clone();
	mask.Smooth(25);
	mask.Monochrome(0);
	local baseNoise = GGen_Data_2D(width, height, GGEN_NATURAL_PROFILE.Min());
	baseNoise.Noise(1, 5, GGEN_STD_NOISE);
	baseNoise.ScaleValuesTo(0, 100);
	base.AddMapMasked(baseNoise, mask);
	//return baseNoise;
	
	mainNoise.ScaleValuesTo(0,300)
	base.Union(mainNoise);
	base.Add(450);
	
	//Texture Maps
	local slopeMap = GGen_Data_2D(width, height, GGEN_NATURAL_PROFILE.Min());
	slopeMap = base.Clone();
	slopeMap.SlopeMap();
	slopeMap.ScaleValuesTo(0,1024);
	slopeMap.Clamp(256, 512);	
	slopeMap.ScaleValuesTo(0,1024);
	slopeMap.ScaleTo(width/2,height/2,true)
	slopeMap.ReturnAs("Stratum4");
	
	local highTerrain = GGen_Data_2D(width, height, GGEN_NATURAL_PROFILE.Min());
	highTerrain = base.Clone();
	highTerrain.Add(-900);
	highTerrain.CropValues(0, 1000);
	highTerrain.ScaleValuesTo(0,255)
	highTerrain.ScaleTo(width/2,height/2,true)
	highTerrain.ReturnAs("Stratum3");
	
	local mediumTerrain = GGen_Data_2D(width, height, GGEN_NATURAL_PROFILE.Min());
	mediumTerrain = base.Clone();
	mediumTerrain.Add(-700);
	mediumTerrain.CropValues(0, 1000);
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