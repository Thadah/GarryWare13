WARE.Author = "Hurricaaane (Ha3)"
WARE.Room = "empty"

function WARE:IsPlayable()
	if team.NumPlayers(TEAM_HUMANS) >= 3 then
		return true
	end
	
	return false
end

function WARE:Initialize()
	GAMEMODE:EnableFirstWinAward( )
	GAMEMODE:EnableFirstFailAward( )
	GAMEMODE:SetWinAwards( AWARD_FRENZY )
	GAMEMODE:SetFailAwards( AWARD_VICTIM )

	GAMEMODE:SetWareWindupAndLength(2, 3)

	GAMEMODE:SetPlayersInitialStatus( false )
	GAMEMODE:DrawInstructions( "Hit a player!" )

	return
end

function WARE:StartAction()	
	for _,v in pairs(team.GetPlayers(TEAM_HUMANS)) do
		v:Give( "weapon_crowbar" )
	end
	
	return
end

function WARE:EndAction()
	
end


function WARE:EntityTakeDamage(ent,info)
    local attacker = info:GetAttacker()

	if !IsValid( ent ) or !ent:IsPlayer() or !ent:IsWarePlayer() or ent:IsSimDead() then return end
	if !IsValid( attacker ) or !attacker:IsPlayer() or !attacker:IsWarePlayer() or (!attacker:GetAchieved() and attacker:GetLocked()) then return end
	
	attacker:ApplyWin( )
	attacker:SendHitConfirmation()
	ent:ApplyLose()
	
	ent:SimulateDeath()
	ent:StripWeapons()
end
