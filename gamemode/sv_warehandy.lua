////////////////////////////////////////////////
// // GarryWare Gold                          //
// by Hurricaaane (Ha3)                       //
//  and Kilburn_                              //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Functions used on Wares (but not only by)  //
////////////////////////////////////////////////

function GM:SetWareWindupAndLength(windup , len)
	self.Windup  = windup
	self.WareLen = len
end

function GM:OverrideAnnouncer( id )
    if (1 <= id) and (id <= #self.WASND[6]) then
		self.WareOverrideAnnouncer = id
	end
end

function GM:ForceNoAnnouncer( )
    self.WareShouldNotAnnounce = true
end

function GM:DrawToPlayersGeneralInstructions( tPlayersInput, bInvert, sInstructions , optColorPointer , optTextColorPointer )
	local rpPlayers = RecipientFilter()
	if bInvert then
		rpPlayers:AddAllPlayers()
		for k,ply in pairs( tPlayersInput ) do
			rpPlayers:RemovePlayer( ply )
		end
	
	else
		for k,ply in pairs( tPlayersInput ) do
			rpPlayers:AddPlayer( ply )
		end
		
	end
	
	self:DrawInstructions( sInstructions , optColorPointer , optTextColorPointer , rpPlayers )
end

function GM:DrawInstructions( sInstructions , optColorPointer , optTextColorPointer , optrpFilter )
	local rp = optrpFilter or nil

	if optColorPointer then
		if optTextColorPointer then
			netstream.Start(rp, "gw_instructions", {
				sInstructions, 
				true, 
				true, 
				optColorPointer.r, 
				optColorPointer.g, 
				optColorPointer.b,
				optColorPointer.a,
				optTextColorPointer.r,
				optTextColorPointer.g,
				optTextColorPointer.b,
				optTextColorPointer.a
			})
		else
			netstream.Start(rp, "gw_instructions", {
				sInstructions, 
				true, 
				false, 
				optColorPointer.r, 
				optColorPointer.g, 
				optColorPointer.b,
				optColorPointer.a
			})
		end
	else
		netstream.Start(rp, "gw_instructions", {
			sInstructions, 
			false, 
			false
		})
	end
end
			

function GM:SetPlayersInitialStatus(isAchievedNilIfMystery)
	-- nil as an achieved status then can only be set globally (start of game).
	-- Use it for games where the status is set on Epilogue (not Ending), while
	-- the players shouldn't know if they won or not.
	-- Example : Watch the props ! / Stand on the missing prop ! (ver.2)
	
	for k,v in pairs(player.GetAll()) do 
		v:SetAchievedSpecialInteger( ((isAchievedNilIfMystery == nil) and -1) or ((isAchievedNilIfMystery) and 1) or 0 )
	end
	
end

function GM:SendEntityTextColor( rpfilterOrPlayer, entity, r, g, b, a )

	netstream.Start(rpfilterOrPlayer, "EntityTextChangeColor", {entity, r, g, b, a})
end

////////////////////////////////////////////////
////////////////////////////////////////////////
-- Phases.

function GM:SetNextPhaseLength( fTime )
	self.WarePhase_NextLength = (fTime > 0) and fTime or 0
	
end

function GM:GetCurrentPhase( fTime )
	return self.WarePhase_Current
end

////////////////////////////////////////////////
////////////////////////////////////////////////
-- Special overrides.

function GM:SetNextGameEnd(time)
	if !self.WareHaveStarted or !self.ActionPhase then return end
	
	local t = CurTime()
	
	-- Prevents dividing by zero
	if (t - time ~= 0) and (t - self.NextgameEnd ~= 0) then
		self.WareLen = self.WareLen * (t - time) / (t - self.NextgameEnd)
	end
	
	self.NextgameEnd = time
	
	--local rp = RecipientFilter()
	--rp:AddAllPlayers()

	local random = math.random(1, #GAMEMODE.WASND[2] )
	netstream.Start(nil, "NextGameTimes", {0, self.NextgameEnd, self.Windup, self.WareLen, true, true, 1, random, self.WareOverrideAnnouncer})
end

////////////////////////////////////////////////
////////////////////////////////////////////////
-- Entity trash bin functions.

function GM:AppendEntToBin( ent )
	table.insert(GAMEMODE.WareEnts,ent)
end

function GM:RemoveEnts()
	for k,v in pairs(GAMEMODE.WareEnts) do
		if (IsValid(v)) then
			GAMEMODE:MakeDisappearEffect(v:GetPos())
			v:Remove()
		end
	end
end

////////////////////////////////////////////////
////////////////////////////////////////////////

--In init but useable
--function GM:RespawnAllPlayers( bNoMusicEvent, bForce )
--function GM:HookTriggers()
--function GM:PhaseIsPrelude()

////////////////////////////////////////////////
////////////////////////////////////////////////