////////////////////////////////////////////////
// // GarryWare Gold                          //
// by Hurricaaane (Ha3)                       //
//  and Kilburn_                              //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Player Handle and Model Precache           //
////////////////////////////////////////////////

function GM:PlayerCanHearPlayersVoice( pListener, pTalker )
	return true
end

function GM:PlayerInitialSpawn( ply, id )
	self.BaseClass:PlayerInitialSpawn( ply, id )
	
	ply.m_tokens = {}

	-- Give him info about the current status of the game
	local didnotbegin = false
	if (self.NextgameStart > CurTime()) then
		didnotbegin = true
	end

	netstream.Start(ply, "ServerJoinInfo", {self.TimeWhenGameEnds, didnotbegin})

	netstream.Start(ply, "BestStreakEverBreached", self.BestStreakEver)

	if self.Decoration_Origin then
		netstream.Start(ply, "DecorationInfo", {self.Decoration_Origin, self.Decoration_Extrema})
	end

	self:SendModelList( ply )
	
	ply:SetComboSpecialInteger( 0 )
	
	-- TOKEN_GW_STATS : Need to add player if not already done NOW !
end

function GM:PlayerDisconnected( ply )
	-- TOKEN_GW_STATS : Need to store last data NOW !

end

function GM:PlayerSpawn(ply)
	self.BaseClass:PlayerSpawn( ply )
	
	ply:CrosshairDisable()
	ply:RestoreDeath()
	
	if (ply._forcespawntime or 0) < (CurTime() - 0.3) then
		ply:SetAchievedSpecialInteger( -1 )
		ply:SetLockedSpecialInteger( 1 )
	end
	
	-- TODO
	-- Double send it because sometime it crashes
	/*
	if self.Decoration_Origin then
		umsg.Start("DecorationInfo", ply )
			umsg.Vector( self.Decoration_Origin )
			umsg.Vector( self.Decoration_Extrema )
		umsg.End()
	end
	*/
end

function GM:PlayerSelectSpawn(ply)
	if ply.ForcedSpawn then
		local spawn = ply.ForcedSpawn
		ply.ForcedSpawn = nil
		return spawn
	end
	
	local spawns
	
	if self.CurrentEnvironment then
		spawns = self.CurrentEnvironment.PlayerSpawns
	end
	
	if !spawns or #spawns==0 then
		spawns = ents.FindByClass("info_player_start")
	end
	
	return spawns[math.random(1,#spawns)]
end


function GM:PlayerDeath( victim, weapon, killer )
	self.BaseClass:PlayerDeath( victim, weapon, killer )
	victim:RestoreDeath()
	victim:ApplyLose()
	
end

function GM:RespawnAllPlayers( bNoMusicEvent, bForce )
	if !self.CurrentEnvironment then return end

	local randomsound = math.random(1, math.Clamp(#GAMEMODE.WASND[5], 1, 2))
	
	local spawns = {}	
	-- Priority goes to active players, so they don't spawn in each other
	for _,v in pairs( team.GetPlayers(TEAM_HUMANS) ) do
		if bForce or (v:GetEnvironment() ~= self.CurrentEnvironment) then
			if #spawns == 0 then
				spawns = table.Copy( self.CurrentEnvironment.PlayerSpawns )
			end
		
			--No need to draw the effect no one sees them
			--self:MakeDisappearEffect( v:GetPos() )
			local loc = table.remove(spawns, math.random(1, #spawns) )
			
			v.ForcedSpawn = loc
			if bForce then v._forcespawntime = CurTime() end
			v:Spawn( )
			
		end
	end
	
	for _,v in pairs(team.GetPlayers(TEAM_SPECTATOR)) do
		if v:GetEnvironment() ~= self.CurrentEnvironment then
			if #spawns == 0 then
				spawns = table.Copy(self.CurrentEnvironment.PlayerSpawns)
			end
		
			local loc = table.remove( spawns, math.random(1, #spawns) )
			
			v.ForcedSpawn = loc
			v:Spawn()
			
		end
	end
	
	netstream.Start(rp, "PlayerTeleported", {bNoMusicEvent, randomsound})
	
	/*
	umsg.Start("PlayerTeleported", rp)
		umsg.Bool(bNoMusicEvent or false)
		umsg.Char( math.random(1, math.Clamp(#GAMEMODE.WASND[5], 1, 2)))
	umsg.End()
	*/
end

////////////////////////////////////////////////
////////////////////////////////////////////////
-- Model List.

function GM:SendModelList( ply )
	if #self.ModelPrecacheTable <= 0 then return end
	
	local messageSplit = 3
	
	local count = #self.ModelPrecacheTable
	local splits = math.ceil(#self.ModelPrecacheTable / messageSplit)
	
	local lastSplit = #self.ModelPrecacheTable % messageSplit
	local model = ""
	
	for i=1,splits do
		local toSend = ((i < splits) and messageSplit) or lastSplit

		for k=1,toSend do
			model = self.ModelPrecacheTable[ (i - 1) * messageSplit + k ]
		end
		
		netstream.Start(ply, "ModelList", {toSend, model})
	end
end
