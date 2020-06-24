state("Pineapple-Win64-Shipping")
{
	bool isLoading: "Pineapple-Win64-Shipping.exe", 0x0338B8D0, 0x20, 0x1A0;
	int spatCount: "Pineapple-Win64-Shipping.exe", 0x03487038, 0x8, 0x6E0;
	string100  map: "Pineapple-Win64-Shipping.exe", 0x3488090, 0x8A8, 0x0;
}

startup
{
	vars.newRun = false;
	vars.startOffset = 137f/60f;
	vars.buildSpatList = false;
	vars.spatSplits = new List<int>();

	settings.Add("reset", true, "Reset");
	settings.Add("mainMenuReset", false, "Reset on Main Menu", "reset");
	settings.Add("newGameReset", true, "Reset on New Game", "reset");

	settings.Add("spatSplit", false, "Split on certain number of spatulas");
	for(int i = 1; i < 100; i++)
	{
	    settings.Add("spat"+(i).ToString(), false, (i).ToString()+" spatulas", "spatSplit");
	}

	vars.mainMenu = "/Game/Maps/MainMenu/MainMenu_P";
	vars.introCutscene = "/Game/Maps/IntroCutscene/IntroCutscene_P";
	vars.finalLevel = "/Game/Maps/ChumBucketLab/Part3/ChumBucketLab_03_P";
	
	if (timer.CurrentTimingMethod == TimingMethod.RealTime)
	{        
		var timingMessage = MessageBox.Show (
			"This game uses Time without Loads (Game Time) as the main timing method.\n"+
			"LiveSplit is currently set to show Real Time (RTA).\n"+
			"Would you like to set the timing method to Game Time?",
			"Livesplit | BFBB Rehydrated",
			MessageBoxButtons.YesNo,MessageBoxIcon.Question
		);
		
		if (timingMessage == DialogResult.Yes)
		{
			timer.CurrentTimingMethod = TimingMethod.GameTime;
		}
	}
}

update
{
	if (vars.buildSpatList)
	{
		vars.buildSpatList = false;
		vars.spatSplits = new List<int>();
		for(int i = 1; i < 100; i++)
		{
			if(settings["spat"+i.ToString()])
				vars.spatSplits.Add(i);
		}
		print("Spatulas to split for: "+string.Join(", ", vars.spatSplits));
	}
}

gameTime
{
	if (vars.newRun)
	{
		vars.newRun = false;
		return TimeSpan.FromSeconds(vars.startOffset);
	}
}

reset
{
	var reset = false;

	if(settings["mainMenuReset"])
	{
		reset = old.map != null && old.map != current.map && current.map == vars.mainMenu;
	}

	if(settings["newGameReset"] && !reset)
	{
		reset = !old.isLoading && current.isLoading && current.map == vars.introCutscene;
	}

	return reset;
}

start
{
	if(!old.isLoading && current.isLoading && current.map == vars.introCutscene)
	{
		if(settings["spatSplit"])
			vars.buildSpatList = true;
		vars.newRun = true;
		return true;
	}
}

isLoading
{
	return current.isLoading;
}

split
{
	if(current.spatCount > old.spatCount && vars.spatSplits.Count > 0)
	{
		if(current.spatCount >= vars.spatSplits[0])
		{
			print("Split for "+vars.spatSplits[0]+" spats");
			vars.spatSplits.RemoveAt(0);
			return true;
		}
	}
	return old.spatCount != current.spatCount && current.map == vars.finalLevel;
}
