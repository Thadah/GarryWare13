gws_AmbientMusic = {}
gws_AmbientMusic_dat = {}
gws_AmbientMusicIsOn = false

include("sh_tables.lua")

function GM:GetSpeedPercent()
	 return GetConVarNumber("host_timescale") * 100
end

function GM:SpecialFlourish(id)
	local dataRef = self.WADAT.GlobalWareningEpic[id]

	timer.Simple( dataRef.StartDelay + dataRef.MusicFadeDelay, function() gws_AmbientMusic[1]:ChangeVolume( 0.0, self:GetSpeedPercent() ) end )
	timer.Simple( dataRef.StartDelay, function() self:PlayEnding(id) end)
end

function GM:PlayEnding(id)
	local dataRef = self.WADAT.GlobalWareningEpic[id]
	
	--LocalPlayer():EmitSound( GAMEMODE.WASND.TBL_GlobalWareningEpic[1], 60, GAMEMODE:GetSpeedPercent() )
	sound.PlayFile(dataRef)
	
	gws_AmbientMusicIsOn = true
	
	for k, music in pairs( gws_AmbientMusic ) do
		music:Stop()
		gws_AmbientMusic_dat[k]._IsPlaying = false	
	end
	
	timer.Simple( dataRef.Length, function() self:EnableMusic(1) end)
end

function GM:EnableMusic(loop)
	if gws_AmbientMusicIsOn then
		for k, music in pairs( gws_AmbientMusic ) do
			music:Stop()
			gws_AmbientMusic_dat[k]._IsPlaying = false
		end
		PrintTable(gws_AmbientMusic)
		gws_AmbientMusic[loop]:Play()
		gws_AmbientMusic_dat[loop]._IsPlaying = true
		gws_AmbientMusic[loop]:ChangeVolume( 0.1, self:GetSpeedPercent() )
		gws_AmbientMusic[loop]:ChangePitch( self:GetSpeedPercent(), 1 )
		timer.Simple( self.WADAT.StartFlourishLength * 0.7 , function() self:EnableMusicVolume(loop) end)		
	end	
end

function GM:DisableMusic()
	if !gws_AmbientMusicIsOn then
		for k, music in pairs( gws_AmbientMusic ) do
			if gws_AmbientMusic_dat[k]._IsPlaying then
				music:ChangeVolume( 0.1, self:GetSpeedPercent() )	
			else
				music:Stop()	
			end
		end	
	end
end

function GM:EnableMusicVolume(loop)
	if gws_AmbientMusicIsOn then
		gws_AmbientMusic[loop]:ChangeVolume( 0.7, self:GetSpeedPercent() )	
	end
end