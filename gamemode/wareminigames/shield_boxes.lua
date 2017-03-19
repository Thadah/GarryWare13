WARE = {}
WARE.Author = "Thadah D. Denyse"
 
WARE.Positions = {}

function WARE:IsPlayable()
	return true
end

function WARE:GetModelList()
	return self.Models
end

function WARE:FlashSpawns( iteration, delay )
	for k,pos in pairs( self.Positions ) do
		GAMEMODE:MakeAppearEffect( pos )
	end

	if (iteration > 0) then
		timer.Simple(delay , function() self:FlashSpawns(iteration - 1, delay) end)
	end	
end


function WARE:Initialize()
	GAMEMODE:EnableFirstFailAward( )
	GAMEMODE:SetFailAwards( AWARD_VICTIM )
	self.SpawnedNPCs = {}

	GAMEMODE:RespawnAllPlayers( true, true )
	
	GAMEMODE:SetWareWindupAndLength(2, 8)
	
	GAMEMODE:SetPlayersInitialStatus( true )
	GAMEMODE:DrawInstructions( "Shield with the boxes!" )
	
	local ratio = 0.7
	local minimum = 3
	local num = math.Clamp(math.ceil( team.NumPlayers(TEAM_HUMANS) * ratio) , minimum, 64)
	local entposcopy = GAMEMODE:GetRandomLocations(num, ENTS_ONCRATE)

	for k, v in pairs(entposcopy) do
		local ent = ents.Create( "npc_turret_floor" )
		ent:SetKeyValue("spawnflags", 32)
		ent:SetPos( v:GetPos()  )
		side = math.random(0,360)
		ent:SetAngles(Angle(0, side, 0))
		ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
		ent:SetMoveType(MOVETYPE_NONE)
		ent:SetSolid(SOLID_NONE)
		ent:Spawn()		
		ent:Fire("Enable")

		table.insert( self.SpawnedNPCs, ent )
		
		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
	end
		
end

function WARE:StartAction()		
	return
end

function WARE:EndAction()

end

function WARE:EntityTakeDamage( ent, dmginfo)
	local att = dmginfo:GetAttacker()
	if ent:IsPlayer() and ent:IsWarePlayer() and !ent:GetLocked() and att:IsNPC( ) then
		ent:StripWeapons()
		ent:ApplyLose()
		ent:SimulateDeath()
		
		for k,npc in pairs( self.SpawnedNPCs ) do
			npc:AddEntityRelationship( ent, D_NU, 99 )
		end
		
	end
end
