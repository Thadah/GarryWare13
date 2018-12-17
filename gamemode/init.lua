////////////////////////////////////////////////
// // GarryWare Gold                          //
// by Hurricaaane (Ha3)                       //
//  and Kilburn_                              //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Serverside Initialization                  //
////////////////////////////////////////////////

-- Defaulted OFF !

resource.AddWorkshop("302361226")

include( "shared.lua")


include( "sv_awards.lua" )
include( "sv_effects.lua" )
include( "sv_entitygathering.lua" )

--Libraries
include( "libs/sh_tables.lua" )
include( "libs/sh_chat.lua" )

--Modules
include("modules/netstream2.lua")
include("modules/pon.lua")
include("modules/minigames_module.lua")
include("modules/environment_module.lua")
include("modules/entitymap_module.lua")

include( "sv_filelist.lua" )
include( "sv_warehandy.lua" )
include( "sv_playerhandle.lua" )

GM.TakeFragOnSuicide = false

-- Serverside Vars
GM.GamesArePlaying = false
GM.GameHasEnded = false
GM.WareHaveStarted = false
GM.ActionPhase = false

GM.WareOverrideAnnouncer = false
GM.WareShouldNotAnnounce = false
GM.WarePhase_Current = 0
GM.WarePhase_NextLength = 0

GM.WareLen = 100
GM.Windup = 2
GM.NextgameStart = 0
GM.NextgameEnd = 0

GM.NumberOfWaresPlayed = -1

-- Ware internal functions.

function GM:HasEveryoneLocked()
	local playertable = team.GetPlayers(TEAM_HUMANS)

	local i = 1
	while ( (i <= #playertable) and playertable[i]:GetLocked() ) do
		i = i + 1
	end
	if (i <= #playertable) then
		return false
	end
	
	return true
end

function GM:CheckGlobalStatus( endOfGameBypassValidation )
	if team.NumPlayers(TEAM_HUMANS) < 2 then return false end
	
	local playertable = team.GetPlayers(TEAM_HUMANS)
	
	
	-- Has everyone validated their status ?
	-- (Don't do that if it's the end of the game. Call Check first ONCE, then validate
	-- with bypass of the lock if that function returned true.)
	if !(endOfGameBypassValidation) then
		if !GAMEMODE:HasEveryoneLocked() then return false end
	end
	
	-- Do everyone have the same status ?
	local probableStatus = playertable[1]:GetAchieved()
	i = 2
	while ( (i <= #playertable) and (playertable[i]:GetAchieved() == probableStatus) ) do
		i = i + 1
	end
	if (i <= #playertable) then
		return false
	elseif probableStatus == nil then
		return false
	end
	
	-- TEST : Re-test this.
	if !(endOfGameBypassValidation and GAMEMODE:HasEveryoneLocked()) then
		-- Note from Ha3 : OMG, check the usermessage types next time. 1 hour waste
		--local rp = RecipientFilter()
		--rp:AddAllPlayers( )

		netstream.Start(nil, "gw_yourstatus", {probableStatus, true})
		
	end
	
	return true , probableStatus
end

function GM:SendEveryoneEvent( probable )
	--local rpAll = RecipientFilter()
	--rpAll:AddAllPlayers()
	netstream.Start(team.GetPlayers(TEAM_HUMANS), "EventEveryoneState", probable)
end

////////////////////////////////////////////////
////////////////////////////////////////////////
-- Ware cycles.

function GM:PickRandomGame()
	self.WareHaveStarted = true
	self.WareOverrideAnnouncer = false

	self.WarePhase_Current = 1
	self.WarePhase_NextLength = 0
	
	self:ResetWareAwards( )
	
	-- Standard initialization
	for k,v in pairs(player.GetAll()) do 
		v:SetLockedSpecialInteger(0)
		v:RemoveFirst( )
		v:StripWeapons()
	end
	
	self.Minigame = ware_mod.CreateInstance(self.NextGameName)
	
	-- Ware is initialized
	if self.Minigame and self.Minigame.Initialize and self.Minigame.StartAction then
		self.Minigame:Initialize()
		
	else
		self.Minigame = ware_mod.CreateInstance("_empty")
		self:SetWareWindupAndLength(0, 3)
		
		GAMEMODE:SetPlayersInitialStatus( false )
		GAMEMODE:DrawInstructions( "Error with minigame \""..self.NextGameName.."\"." )
	end
	self.NextgameEnd = CurTime() + self.Windup + self.WareLen
	
	self.NumberOfWaresPlayed = self.NumberOfWaresPlayed + 1
	
	if !self.WareOverrideAnnouncer then
		self.WareOverrideAnnouncer = self.DefaultAnnouncerID or math.random(1, 2)
	end
	
	local iLoopToPlay = ( (self.Windup + self.WareLen) >= 10 ) and 2 or 1


	local newWindup = CurTime() + self.Windup
	
	-- Send info about ware
	netstream.Start(team.GetPlayers(TEAM_HUMANS), "NextGameTimes", {
		newWindup,
		self.NextgameEnd,
		self.Windup,
		self.WareLen,
		self.WareShouldNotAnnounce,
		true,
		2,
		math.random(1, 5),
		self.WareOverrideAnnouncer,
		iLoopToPlay
	})

	self.WareShouldNotAnnounce = false
end

function GM:TryNextPhase( )
	if self.WarePhase_NextLength <= 0 then return false end
	
	self.WarePhase_Current = self.WarePhase_Current + 1
	
	self.WareLen = self.WarePhase_NextLength
	self.NextgameEnd = CurTime() + self.WarePhase_NextLength
	
	self.WarePhase_NextLength = 0
	
	-- self.Minigame == nil should never happen
	if self.Minigame and self.Minigame.PhaseSignal then
		self.Minigame:PhaseSignal( self.WarePhase_Current )
		
	end
	
	local iLoopToPlay = ( (self.Windup + self.WareLen) >= 10 ) and 2 or 1
	
	netstream.Start(nil, "NextGameTimes", {
		0, 
		self.NextgameEnd, 
		self.Windup, 
		self.WareLen, 
		self.WareShouldNotAnnounce,
		true,
		2,
		math.random(1, #GAMEMODE.WASND[2]),
		self.WareOverrideAnnouncer,
		iLoopToPlay
	})
	
	self.WareShouldNotAnnounce = false
	
	return true
end

function GM:GetCurrentMinigameName()
	return (self.Minigame and self.Minigame.Name) or ""
end

function GM:EndGame()
	winners = {}
	losers = {}
	if self.WareHaveStarted == true then
	
		-- Destroy all
		if self.ActionPhase == true then
			GAMEMODE:UnhookTriggers()
			self.ActionPhase = false
		end
		if self.Minigame and self.Minigame.EndAction then self.Minigame:EndAction() end
		self:RemoveEnts()
		
		local everyoneStatusIsSame, probable = GAMEMODE:CheckGlobalStatus( true )
		if (everyoneStatusIsSame and !GAMEMODE:HasEveryoneLocked()) then
			self:SendEveryoneEvent( probable )
		end

		for _, v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
			v:ApplyLock( everyoneStatusIsSame )
			local bAchieved = v:GetAchieved()
			if (bAchieved) then
				table.insert(winners, v)
			else
				table.insert(losers, v)
			end

			-- Reinit player
			v:RestoreDeath()
			v:StripWeapons()
			v:RemoveAllAmmo( )
			v:Give("weapon_physcannon")
		end
		
		-- Send positive message to the RP list of winners.
		for _, v in pairs(winners) do
			netstream.Start(v, "EventEndgameTrigger", {
				true,
				math.random(1, #GAMEMODE.WASND[3])
			})
		end

		for _, v2 in pairs(losers) do
			netstream.Start(v2, "EventEndgameTrigger", {
				false, 
				math.random(1, #GAMEMODE.WASND[4])
			})
		end

		if (team.NumPlayers(TEAM_SPECTATOR) != 0) then
			for _, v3 in pairs(team.GetPlayers(TEAM_SPECTATOR)) do
				netstream.Start(v3, "EventEndgameTrigger", {
					false, 
					math.random(1, #GAMEMODE.WASND[4])
				})
			end
		end
	end
	
	self.NextgameStart = CurTime() + self.WADAT.EndFlourishTime
	local tCount = team.GetPlayers( TEAM_HUMANS )
	if #tCount >= 5 then
		local iWinFailPercent = 0
		local iCount = 0
		for k,ply in pairs( team.GetPlayers( TEAM_HUMANS ) ) do
			if ply:GetAchieved() then
				iCount = iCount + 1
			end
		end
		
		iWinFailPercent = math.floor( iCount / #tCount * 100 )
		
		netstream.Start(nil, "Transit", iWinFailPercent)
	end
	
	-- Reinitialize
	self.WareHaveStarted = false
	
	--Enough time to play ?
	if ((self.TimeWhenGameEnds - CurTime()) < self.NotEnoughTimeCap) then
		self:EndOfGame( true )
	else
		--Ware is picked up now
		self:PickRandomGameName()
	end
end

function GM:PickRandomGameName( bFirst )
	local env

	if bFirst then
		self.NextGameName = "_intro"
		env = ware_env.FindEnvironment(ware_mod.Get(self.NextGameName).Room) or self.CurrentEnvironment
	else
		self.NextGameName, env = ware_mod.GetRandomGameName()
	end	
	
	if env != self.CurrentEnvironment then
		self.CurrentEnvironment = env
		self.NextgameStart = self.NextgameStart + self.WADAT.TransitFlourishTime
		self.NextPlayerRespawn = CurTime() + self.WADAT.EndFlourishTime
	end
	
end

function GM:PhaseIsPrelude()
	return CurTime() < (self.NextgameStart + self.Windup)
end

function GM:HookTriggers()
	local hooks = self.Minigame.Hooks
	if !hooks then return end
	
	for hookname,callback in pairs(hooks) do
		hook.Add(hookname, "WARE"..self.Minigame.Name..hookname,callback)
	end
end

function GM:UnhookTriggers()
	local hooks = self.Minigame.Hooks
	if !hooks then return end
	
	for hookname,_ in pairs(hooks) do
		hook.Remove(hookname, "WARE"..self.Minigame.Name..hookname)
	end
end



////////////////////////////////////////////////
////////////////////////////////////////////////
-- Ware game times.

function GM:SetNextGameStartsIn( delay )
	self.NextgameStart = CurTime() + delay
	netstream.Start(nil, "GameStartTime", self.NextgameStart)
	--SendUserMessage( "GameStartTime" , nil, self.NextgameStart )
end	

function GM:Think()
	self.BaseClass:Think()
	
	if (self.GamesArePlaying == true) then
		if (self.WareHaveStarted == false) then
			-- Starts a new ware
			if (CurTime() > self.NextgameStart) then
				self:PickRandomGame()
				netstream.Start(nil, "WaitHide")
			end
			
			-- Eventually, respawn all players
			if self.NextPlayerRespawn and CurTime() > self.NextPlayerRespawn then
				self:RespawnAllPlayers()
				self.NextPlayerRespawn = nil
			end
		
		else
			-- Starts the action
			if CurTime() > (self.NextgameStart + self.Windup) and self.ActionPhase == false then
				if self.Minigame then
					self:HookTriggers()
					if self.Minigame.StartAction then
						self.Minigame:StartAction()
					end
				end
				
				self.ActionPhase = true
			end
			
			-- Ends the current ware
			if (CurTime() > self.NextgameEnd) then
				if self.Minigame.PreEndAction then
					self.Minigame:PreEndAction()
				end
				
				-- TOKEN_GW_STATS : Stats are gathered separately either in (TryNextPhase XOR EndGame), NEVER BOTH.
				if !self:TryNextPhase( ) then
					self:EndGame()
				end
				
			end
			
		end
		
		
		
		-- Ends a current game, because of lack of players
		if team.NumPlayers(TEAM_HUMANS) == 0 then
			self.GamesArePlaying = false
			GAMEMODE:EndGame()
			
			-- Send info about ware
			--local rp = RecipientFilter()
			--rp:AddAllPlayers()
			netstream.Start(nil, "NextGameTimes", {
				0,
				0,
				0,
				0,
				false,
				false
			})
		elseif self.FirstTimePickGame and CurTime() > self.FirstTimePickGame then
			-- Game has just started, pick the first game
			self:PickRandomGameName( true )
			self.FirstTimePickGame = nil
		end
	
	else
		-- Starts a new game
		if team.NumPlayers(TEAM_HUMANS) > 0 and self.GameHasEnded == false then
			self.GamesArePlaying = true
			self.WareHaveStarted = false
			self.ActionPhase = false

			self:SetNextGameStartsIn( 10 )
			self.FirstTimePickGame = 19.3
				
			netstream.Start(nil, "WaitShow")
		end
	end
	
	self:TryFindStuck()
	
end

function GM:TryFindStuck()
	for k,ply in pairs(team.GetPlayers( TEAM_HUMANS )) do
		if IsValid(ply) then
			local plyPhys = ply:GetPhysicsObject()
			if plyPhys:IsValid() and plyPhys != NULL then
				if plyPhys:IsPenetrating() then
					ply:SetNoCollideWithTeammates( true )
					if !ply._WasStuckOneTime then
						ply._WasStuckOneTime = true
						print("Found player " .. ply:Nick() .. " stuck!")
					end
					
				elseif ply:GetNoCollideWithTeammates( ) then
					ply:SetNoCollideWithTeammates( false )
				
				end
				
			end
		
		end
		
	end
	
end

function GM:WareRoomCheckup()
	if #ents.FindByClass("func_wareroom") == 0 then
		for _,v in pairs(ents.FindByClass("gmod_warelocation")) do
			v:SetNotSolid(true)
			
		end
	
	else
		for _,v in pairs(ents.FindByClass("info_player_start")) do
			-- That's not a real ware location, but a dummy entity
			-- for making info_player_start entities detectable by the trigger
			local temp = ents.Create("gmod_warelocation")
			temp:SetPos(v:GetPos())
			temp:Spawn()
			temp.PlayerStart = v
			
		end
		
	end
	
end

function GM:InitPostEntity( )
	self.BaseClass:InitPostEntity()
	
	self:WareRoomCheckup()
	
	RemoveUnplayableMinigames()

	self.GamesArePlaying = false
	self.WareHaveStarted = false
	self.ActionPhase = false
	self.GameHasEnded = false
	
	self.NextgameStart = CurTime() + 8
	
	self.TimeWhenGameEnds = CurTime() + self.GameLength * 60.0
	
	for _,v in pairs(ents.FindByClass("func_wareroom")) do
		ware_env.Create(v)
	end
	
	-- No environment found, create the default one
	if #ware_env.GetTable() then
		ware_env.Create()
	end
	
	-- Start with a generic environment
	self.CurrentEnvironment = ware_env.FindEnvironment("generic")
	
	-- Create the precache table
	for k,name in pairs(ware_mod.GetNamesTable()) do
		if (ware_mod.Get(name).GetModelList) then
			for j,model in pairs(ware_mod.Get(name):GetModelList() or {}) do
				if (type(model) == "string") and (!table.HasValue( self.ModelPrecacheTable , model )) then
					table.insert( self.ModelPrecacheTable , model )
					
				end
				
			end
			
		end
		
	end
	
	-- Search for decoration
	local tOriginEnt = ents.FindByName("deco_center")
	local tExtremaEnt = ents.FindByName("deco_extrema")
	if #tOriginEnt > 0 and #tExtremaEnt > 0 then
		local origin  = tOriginEnt[1]
		local extrema = tExtremaEnt[1]
		self.Decoration_Origin  = origin:GetPos()
		self.Decoration_Extrema = extrema:GetPos()
	end
	
end

/*
-- (Ha3) Silent fall damage leg break sound ? Didn't work.
function GM:EntityTakeDamage( ent, inflictor, attacker, amount, dmginfo )
	if ent:IsPlayer() and dmginfo:IsFallDamage() then
		dmginfo:ScaleDamage( 0 )
		return false
	end
end
*/


////////////////////////////////////////////////
////////////////////////////////////////////////
-- Minigame Inclusion.

function IncludeMinigames()
	--local path = "./wareminigames/"
	local names = {}
	local authors = {}
	local str = ""
	
	for _, file in pairs( file.Find("gamemodes/garryware13/gamemode/wareminigames/*.lua", "GAME")) do
		WARE = {}
		
		include("wareminigames/"..file)
		
		local gamename = string.Replace(file, ".lua", "")
		ware_mod.Register(gamename, WARE)
	end
	
	print("__________\n")
	names = ware_mod.GetNamesTable()
	str = "Added wares ("..#names..") : "
	for k,v in pairs(names) do
		str = str.."\""..v.."\" "
	end
	print(str)
	
	authors = ware_mod.GetAuthorTable()
	str = "Author [wares] : "
	for k,v in pairs(authors) do
		str = str.." "..k.." ["..v.." wares]  "
	end
	print(str)
	print("__________\n")
end

function RemoveUnplayableMinigames()
	local names = ware_mod.GetNamesTable()
	local removed = {}
	
	for _,v in pairs(ware_mod.GetNamesTable()) do
		if !ware_env.HasEnvironment(ware_mod.Get(v).Room) then
			table.insert(removed,v)
			ware_mod.Remove(v)
		end
	end
	
	print("__________\n")
	str = "Removed wares ("..#removed..") : "
	for k,v in pairs(removed) do
		str = str.."\""..v.."\" "
	end
	print(str)
	print("__________\n")
end


////////////////////////////////////////////////
////////////////////////////////////////////////
-- Start up.

IncludeMinigames()