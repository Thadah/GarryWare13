WARE.Author = "Hurricaaane (Ha3)"
WARE.Room = "hexaprism"

WARE.Models = {
"models/Combine_turrets/Ceiling_turret.mdl",
"models/props_c17/gravestone003a.mdl",
"models/props_junk/TrashBin01a.mdl",
"models/props_c17/FurnitureFridge001a.mdl",
"models/props_c17/oildrum001.mdl",
"models/props_debris/metal_panel02a.mdl",
"models/props_interiors/Radiator01a.mdl",
"models/props_interiors/refrigeratorDoor01a.mdl",
"models/props_junk/wood_crate001a.mdl"
}
 
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
	GAMEMODE:DrawInstructions( "Shield! Don't fall!" )
	
	local pitposz = GAMEMODE:GetEnts("pit_measure")[1]:GetPos().z
	local aposz   = GAMEMODE:GetEnts("land_measure")[1]:GetPos().z
	self.zlimit = pitposz + (aposz - pitposz) * 0.8
	
	local ratio = 0.7
	local minimum = 3
	local num = math.Clamp(math.ceil( team.NumPlayers(TEAM_HUMANS) * ratio) , minimum, 64)
	
	self.Positions = {}
	local centerpos    = GAMEMODE:GetEnts("center")[1]:GetPos()
	local alandmeasure = math.floor((GAMEMODE:GetEnts("land_a")[1]:GetPos() - centerpos):Length() * 0.5)
	for i=1,num do
		table.insert( self.Positions, Vector(0,0,0) + centerpos + Angle(0, math.random(0,360), 0):Forward() * math.random(alandmeasure * 0.5, alandmeasure) )
	end
	
	self:FlashSpawns( 6 , 0.3 )
	
	for _,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		v:Give( "weapon_physcannon" )
	end
	
	for i=1,num do
		local newpos = Vector(0,0,256) + centerpos + Angle(0, math.random(0,360), 0):Forward() * math.random(alandmeasure * 0.5, alandmeasure)
		
		local prop = ents.Create("prop_physics")
		prop:SetModel( self.Models[ math.random(2, #self.Models) ] )
		prop:PhysicsInit(SOLID_VPHYSICS)
		prop:SetSolid(SOLID_VPHYSICS)
		prop:SetPos(newpos)
		prop:Spawn()
		
		prop:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
	
		local physobj = prop:GetPhysicsObject()
		physobj:EnableMotion(true)
		physobj:ApplyForceCenter(VectorRand() * 256 * physobj:GetMass())

		GAMEMODE:AppendEntToBin(prop)
		GAMEMODE:MakeAppearEffect(newpos)
	end
	
	
end

function WARE:StartAction()	
	local centerpos  = GAMEMODE:GetEnts("center")[1]:GetPos()
	
	for k,pos in pairs(self.Positions) do
		local ent = ents.Create( "npc_turret_floor" )
		ent:SetKeyValue("spawnflags", 32)
		ent:SetPos( pos + (pos - centerpos) * 0.05 )
		side = math.random(0,360)
		ent:SetAngles(Angle(0, side, 0))
		ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
		ent:SetMoveType(MOVETYPE_NONE)
		ent:SetSolid(SOLID_NONE)
		ent:Spawn()

		physobj = ent:GetPhysicsObject()
		physobj:EnableMotion(false)
		physobj:Sleep()
		
		ent:Fire("Enable")
		
		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
	end
end

function WARE:EndAction()

end

function WARE:EntityTakeDamage( ent, dmginfo)
	local att = dmginfo:GetAttacker()
	if ent:IsPlayer() and ent:IsWarePlayer() and !ent:GetLocked() and att:IsNPC( ) then
		ent:StripWeapons()
		ent:ApplyLose()
		
		for k,npc in pairs( self.SpawnedNPCs ) do
			npc:AddEntityRelationship( ent, D_NU, 99 )
		end
		
	end
end

function WARE:Think()
	for k,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		if v:GetPos().z < self.zlimit then
			ent:StripWeapons()
			v:ApplyLose()
			
			for k,npc in pairs( self.SpawnedNPCs ) do
				npc:AddEntityRelationship( ent, D_NU, 99 )
			end
			
		end
	end
end
