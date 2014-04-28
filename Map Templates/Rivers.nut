function GetInfo(info_type){
	switch(info_type){
		case "name":
			return "Volcano";
		case "description":
			return "A single volcano in the middle with ocean around.";
		case "args":
			GGen_AddIntArg("mapsize","Map Size","Size of the map.", 1024, 128, GGen_GetMaxMapSize(), 1);
			GGen_AddIntArg("players","Number of players to fit on map","Affects the number of players on players map.", 6, 6, 6, 1);
			GGen_AddEnumArg("feature_size","Island Size","Size of individual islands.", 1, "Tiny;Medium;Large");
			GGen_AddEnumArg("smoothness","Smoothness","Affects amount of detail on the map.", 1, "Very Rough;Rough;Smooth;Very Smooth");
			GGen_AddEnumArg("rotation","Map Rotation","Affects the orientation ofthe map.", 0, "0;90;180;270");
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

function MakeRiverPath2(startX, startY, riverWidth, slopeX, slopeY, base, depth, baseHeight)
{
	local currX = startX;
	local currY = startY;
	local mRiverWidth = riverWidth;
	
	local c = 1;
	while(c == 1)
	{
		if(currX >= 0 && currX < base.GetWidth() && currY >= 0 && currY < base.GetHeight())
		{
			local h = base.GetValue(currX, currY);			
			
			if(h <= depth)
			{
				c = 0;
			}
		}
		else if(currX < -base.GetWidth() || currX > 2*base.GetWidth() || currY < -base.GetHeight() || currY > 2*base.GetHeight())
		{
			c = 0;
		}
		currX += slopeX;// + (rand() % (abs(slopeX))) - (abs(slopeX) / 2);
		currY += slopeY;// + (rand() % (abs(slopeY))) - (abs(slopeY) / 2);
	}
	
	if(slopeX == 0)
	{
		//vertical line
		local p3 = GGen_Path()
		local y1 = startY;
		local y2 = currY;
		if(startY > currY)
		{
			y1 = currY;
			y2 = startY;
		}
		p3.AddPointByCoords(startX-mRiverWidth, y1-mRiverWidth);
		p3.AddPointByCoords(startX+mRiverWidth, y1-mRiverWidth);
		p3.AddPointByCoords(currX+mRiverWidth, y2+mRiverWidth);
		p3.AddPointByCoords(currX-mRiverWidth, y2+mRiverWidth);
		
		base.FillPolygon(p3, depth);
	}
	else
	{
	 	if(slopeY != 0)
	 	{
			mRiverWidth = abs((riverWidth / cos(atan2(slopeX, slopeY))).tointeger());
		}
					
		local x1 = startX;
		local x2 = currX;
		local y1 = startY;
		local y2 = currY;
		if(startX > currX)
		{
			x1 = currX;
			x2 = startX;
			y1 = currY;
			y2 = startY;
		}
		
		local p3 = GGen_Path()
		p3.AddPointByCoords(x1-mRiverWidth, y1-mRiverWidth);
		p3.AddPointByCoords(x1-mRiverWidth, y1+mRiverWidth);
		p3.AddPointByCoords(x2+mRiverWidth, y2+mRiverWidth);
		p3.AddPointByCoords(x2+mRiverWidth, y2-mRiverWidth);
		
		base.FillPolygon(p3, depth);
	}
}

function Generate(){
	local width = GGen_GetArgValue("mapsize");
	local height = GGen_GetArgValue("mapsize");
	local mapSize = height;
	local feature_size = GGen_GetArgValue("feature_size");
	local smoothness = 1 << GGen_GetArgValue("smoothness");
	local map_rotation = GGen_GetArgValue("rotation") * 90;
	local player_count = 6; //This map is designed for 6 players
	local playerDistance = (3 * mapSize) / 8;
	GGen_InitProgress(9);

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
	
	local waterDepth = 1500;
	local baseHeight = 3300;
	local base = GGen_Data_2D(width, height,baseHeight);
	
	local valleyCount = 5;
	local stepSize = width/valleyCount;
	local valleySize = (height)/(valleyCount * 4);
		
	local waterTransition = valleySize;
	local y1 = (height/2 - (5*valleySize/3) + waterTransition);
	local y2 = (height/2 + (5*valleySize/3) - waterTransition);
	
	local h = GGen_Path();
	 	 
	h.AddPointByCoords(0, y1 + valleySize / 4);
	h.AddPointByCoords(0, y2 - valleySize / 4);
	h.AddPointByCoords(width-1, y2);
	h.AddPointByCoords(width-1, y1);
	
	base.FillPolygon(h, waterDepth);
	
	local heightOffset = 2000;
	local slopeRingWidth = 30;
	local innerRingWidth = 80;
	local sVar1 = (heightOffset/slopeRingWidth) * innerRingWidth + heightOffset;
	for(local i = 0; i < startPos.GetWidth() - 1; i=i+1)
	{
		local x1 = startPos.GetValue(i,0);
		local y1 = startPos.GetValue(i,1);
		base.RadialGradient(x1, y1, innerRingWidth+slopeRingWidth, baseHeight+sVar1, baseHeight, false);
		base.RadialGradient(x1, y1, innerRingWidth, baseHeight+heightOffset, baseHeight+heightOffset, false);
	}
	
	GGen_IncreaseProgress();
	
	local rWidth = valleySize/3;
	local angleOffset = mapSize / 2;
	local svn = 6*rWidth/16;
	local svn2 = 8*rWidth/16;
	local tributaryDepth = waterDepth + 384;
	MakeRiverPath2(mapSize/16, 0, rWidth, svn, svn, base, tributaryDepth, baseHeight)
	MakeRiverPath2(mapSize/16, mapSize-1, rWidth, svn, -svn, base, tributaryDepth, baseHeight)
	
	MakeRiverPath2(3*mapSize/5, 9*mapSize/32, rWidth, svn, svn, base, tributaryDepth, baseHeight)
	MakeRiverPath2(3*mapSize/5,23*mapSize/32, rWidth, svn, -svn, base, tributaryDepth, baseHeight)
	
	MakeRiverPath2(7*mapSize/8, 0, rWidth, -svn, svn, base, tributaryDepth, baseHeight)
	MakeRiverPath2(7*mapSize/8, mapSize-1, rWidth, -svn, -svn, base, tributaryDepth, baseHeight)
	
	MakeRiverPath2(0, mapSize/8, rWidth, svn2, 0, base, tributaryDepth, baseHeight)
	MakeRiverPath2(0, 7*mapSize/8, rWidth, svn2, 0, base, tributaryDepth, baseHeight)
	
	MakeRiverPath2(mapSize-1 , mapSize/8, rWidth, -svn2, 0, base, tributaryDepth, baseHeight)
	MakeRiverPath2(mapSize-1, 7*mapSize/8, rWidth, -svn2, 0, base, tributaryDepth, baseHeight)
	
	MakeRiverPath2(mapSize/3,  mapSize-1, rWidth, 0, -svn2, base, tributaryDepth, baseHeight)
	MakeRiverPath2(mapSize/3,  0, rWidth, 0, svn2, base, tributaryDepth, baseHeight)
	MakeRiverPath2(2*mapSize/3,  mapSize-1, rWidth, 0, -svn2, base, tributaryDepth, baseHeight)
	MakeRiverPath2(2*mapSize/3,  0, rWidth, 0, svn2, base, tributaryDepth, baseHeight)
	
	MakeRiverPath2(0, 11*mapSize/16, rWidth, svn, -svn, base, tributaryDepth, baseHeight)
	MakeRiverPath2(0, 5*mapSize/16, rWidth, svn, svn, base, tributaryDepth, baseHeight)
	
	base.FillPolygon(h, waterDepth);
	
	//for(local i = -angleOffset; i < mapSize; i = i + stepSize)
	//{
		
		
		//local path1 = MakeRiverPath(i, i + angleOffset, mapSize-1, mapSize/2, rWidth);
		//local path2 = MakeRiverPath(i+angleOffset/2, i + angleOffset+angleOffset/2, 0, mapSize/2, rWidth);
		//base.FillPolygon(path1, waterDepth + 512);
		//base.FillPolygon(path2, waterDepth + 512);
	//}
	base.Smooth(25);
	base.Distort(96, 80);
	base.Smooth(3);
	
	GGen_IncreaseProgress();
	
	// noise overlay
	local noise = GGen_Data_2D(width, height, 0);
	noise.Noise(smoothness, ((width > height) ? height : width) / (60 - (15 * feature_size)), GGEN_STD_NOISE);
	noise.ScaleValuesTo(0, 64);	
	base.AddMap(noise);
	base.Rotate(map_rotation, true);
	
	//Adjust Player Starting Positions for map rotation
	for(local i = 0; i < startPos.GetWidth() - 1; i=i+1)
	{
		local s = (i * posStep) + (map_rotation / 180.0) * PI + PI/2;
		local x = ((floor((cos(s) * playerDistance) + 0.5)) + "").tointeger() + (mapSize / 2);
		local y = ((floor((sin(s) * playerDistance) + 0.5)) + "").tointeger() + (mapSize / 2);
		startPos.SetValue(i,0, x);
		startPos.SetValue(i,1, y);
	}
	
	//Fix Start Positions for team play
	if(player_count == 6)
	{
		SwapStartLocation(startPos, 4, 5);
		SwapStartLocation(startPos, 3, 5);
		SwapStartLocation(startPos, 2, 5);
		SwapStartLocation(startPos, 1, 2);
	}
	
	GGen_IncreaseProgress();
	
	//print(base.Max());
	//print(base.Min());
	
	local beachTerrainStart = 2257;
	
	local randomTerrain = GGen_Data_2D(mapSize, mapSize, GGEN_NATURAL_PROFILE.Min());
	randomTerrain.Noise(10, mapSize / 8, GGEN_STD_NOISE);	
	randomTerrain.ScaleValuesTo(0,1024);
	randomTerrain.Clamp(0, 896);
	randomTerrain.ScaleValuesTo(0,16384);
	randomTerrain.ScaleTo(mapSize/2,mapSize/2,false)
	randomTerrain.ReturnAs("Stratum1");
	
	GGen_IncreaseProgress();
	
	local randomTerrain = GGen_Data_2D(mapSize, mapSize, GGEN_NATURAL_PROFILE.Min());
	randomTerrain.Noise(10, mapSize / 8, GGEN_STD_NOISE);	
	randomTerrain.ScaleValuesTo(0,1024);
	randomTerrain.Clamp(0, 896);
	randomTerrain.ScaleValuesTo(0,16384);
	randomTerrain.ScaleTo(mapSize/2,mapSize/2,false)
	randomTerrain.ReturnAs("Stratum2");
	
	GGen_IncreaseProgress();
	
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
	
	GGen_IncreaseProgress();
	
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
	
	beachTerrain.Smooth(4);
	beachTerrain.Invert();
	treeMask.AddMap(beachTerrain);
	treeMask.Smooth(2);
	treeMask.Clamp(0, 2400);
	treeMask.ReturnAs("TreeMask");
	
	GGen_IncreaseProgress();
	
	startPos.ReturnAs("StartPositions");
	
	return base;
}