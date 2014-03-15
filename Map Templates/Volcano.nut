function GetInfo(info_type){
	switch(info_type){
		case "name":
			return "Atoll";
		case "description":
			return "A ring shaped archipelago of small islands.";
		case "args":
			GGen_AddIntArg("width","Width","Width of the map.", 1024, 128, GGen_GetMaxMapSize(), 1);
			GGen_AddIntArg("height","Height","Width of the map.", 1024, 128, GGen_GetMaxMapSize(), 1);
			GGen_AddEnumArg("feature_size","Island Size","Size of individual islands.", 1, "Tiny;Medium;Large");
			GGen_AddEnumArg("smoothness","Smoothness","Affects amount of detail on the map.", 1, "Very Rough;Rough;Smooth;Very Smooth");
			
			return 0;
	}
}

function Generate(){
	local width = GGen_GetArgValue("width");
	local height = GGen_GetArgValue("height");
	local feature_size = GGen_GetArgValue("feature_size");
	local smoothness = 1 << GGen_GetArgValue("smoothness");

	GGen_InitProgress(6);

	// we must decide the smaller dimension to fit the circle into the map
	local size = height > width ? width / 2 : height / 2;
  
	// set up radial profile of the archipelago
	local profile = GGen_Data_1D(320, 0);
	
	local a = 15;
	local s = 64;
	local t = 280;
	local slope = 4;
	local heightOffset = 2325;
	for(local i=1; i <= profile.GetLength(); i = i +1)
	{
		if(i < a){profile.SetValue(profile.GetLength() - i, a/slope + i * heightOffset/a);}
		else if(i >= a && i < s){profile.SetValue(profile.GetLength() - i, i/slope + heightOffset);}
		else if(i >= s && i < t){profile.SetValue(profile.GetLength() - i, (i-s)*(i-s)/10 + s/slope + heightOffset);}
		else{profile.SetValue(profile.GetLength() - i, (t-s)*(t-s)/10 + s/slope - (i-t)*(i-t) + heightOffset);}
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

	base.TransformValues(GGEN_NATURAL_PROFILE, true);
	
	return base;
}