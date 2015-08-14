WARE = {}
WARE.Author = "Hurricaaane (Ha3)"

WARE.Models = {
"models/items/item_item_crate.mdl",
"models/props_lab/tpplugholder_single.mdl",
"models/items/car_battery01.mdl",
"models/props_lab/tpplug.mdl",
"models/combine_camera/combine_camera.mdl"
 }
 
 local dirOffset = {
	Vector(  30, -13, -30 ),	Vector(  13,  30, -30 ),
	Vector( -30,  13, -30 ),	Vector( -13, -30, -30 )
}

WARE.IsPlugged = false

local MDL_CRATE = 1
local MDL_PLUGHOLDER = 2
local MDL_BATTERY = 3
local MDL_BATTERYDONGLE = 4

local MDLLIST = WARE.Models
 
function WARE:GetModelList()
	return self.Models
end

function WARE:Initialize()
	GAMEMODE:EnableFirstWinAward( )
	GAMEMODE:SetWinAwards( AWARD_FRENZY )

	self.Sockets = {}
	GAMEMODE:SetWareWindupAndLength(0,12)
	
	GAMEMODE:SetPlayersInitialStatus( false )
	GAMEMODE:DrawInstructions( "Find a battery and plug it!" )
	
	local ratio = 1
	local minimum = 1
	local num = math.Clamp(math.ceil(team.NumPlayers(TEAM_HUMANS)*ratio),minimum,64)
	local entposcopy = GAMEMODE:GetRandomLocations(num, ENTS_OVERCRATE)
	
	local cratelist = {}
	
	for k,v in pairs(entposcopy) do
		local ent = ents.Create ("prop_physics")
			ent:SetModel( self.Models[MDL_CRATE] )
			ent:SetPos(v:GetPos() + Vector(0,0,16))
			ent:Spawn()
		
		table.insert(cratelist,ent)
		
		local phys = ent:GetPhysicsObject()
			phys:ApplyForceCenter(VectorRand() * 256)
			phys:Wake()
		
		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
		
		ent.HasBattery = true
	end
	
	local ratio3 = 0.5
	local minimum3 = 1
	local num3 = math.Clamp(math.ceil(team.NumPlayers(TEAM_HUMANS)*ratio3),minimum3,64)
	local entposcopy3 = GAMEMODE:GetRandomLocations(num3, ENTS_ONCRATE)
	for k,v in pairs(entposcopy3) do
		local ent = ents.Create ("prop_physics")
			ent:SetModel( self.Models[MDL_PLUGHOLDER] )
			ent:PhysicsInit(SOLID_VPHYSICS)
			ent:SetSolid(SOLID_VPHYSICS)
		
		local side = math.random(1,4)
			ent:SetPos( v:GetPos() + dirOffset[side] )
			ent:SetAngles(Angle(0,(side-1)*90,0))
	
		
		ent:SetMoveType(MOVETYPE_NONE)
		ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		ent:Spawn()
		ent:GetPhysicsObject():EnableMotion(false)
		
		ent.IsOccupied = false
		table.insert(self.Sockets, ent)
		
		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
		
		
		local camera = ents.Create ("npc_combine_camera")
			camera:SetAngles(Angle(0,side*90,180))
			camera:SetPos( v:GetPos() )
			camera:SetKeyValue("spawnflags",208)
			camera:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			camera:Spawn()
		
		ent.LinkedCamera = camera
		
		GAMEMODE:AppendEntToBin(camera)
		GAMEMODE:MakeAppearEffect(camera:GetPos())
	end
	
	for _,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		v:Give( "weapon_physcannon" )
	end
	return
end

function WARE:GravGunOnPickedUp( ply, ent )
	if ( ent.IsBattery ) then 
		ent.BatteryOwner = ply
	end
end

function WARE:StartAction()
	return
end

function WARE:EndAction()
	for _,v in pairs(ents.FindByClass("prop_physics")) do
		if v:GetModel() == self.Models[MDL_PLUGHOLDER] and !v.IsOccupied then
			GAMEMODE:MakeLandmarkEffect(v:GetPos())
		end
	end
end

function WARE:PropBreak(pl,prop)
	if prop.HasBattery == true then
		local battery = ents.Create ("prop_physics")
			battery:SetModel( self.Models[MDL_BATTERY] )
			battery:SetPos(prop:GetPos())
			battery:Spawn()
		
		local plug = ents.Create ("prop_physics")
			plug:SetModel( MDLLIST[MDL_BATTERYDONGLE] )
			plug:SetPos(battery:GetPos() + battery:GetForward()*-8)
			plug:SetCollisionGroup( COLLISION_GROUP_WORLD )
			plug:Spawn()
			plug:SetParent(battery)

		local phys = battery:GetPhysicsObject()
			phys:AddAngleVelocity(VectorRand() * 50)
			phys:ApplyForceCenter(VectorRand() * 64)
		
		GAMEMODE:AppendEntToBin(battery)
		GAMEMODE:MakeAppearEffect(battery:GetPos())
		
		local trail_entity = util.SpriteTrail(battery,0,Color(255,255,255,92),false,0.9,1.5,1.2,1/((0.7+1.2)*0.5),"trails/physbeam.vmt")
		
		battery.Plug		= plug
		battery.IsBattery 	= true
	end
end

function WARE:PlugBatteryIn(socket, battery)
	battery.GravGunBlocked = true	

	battery:SetPos(socket:LocalToWorld( Vector( 13, 13, 10 ) ) )
	battery:SetAngles(socket:GetAngles())
	
	battery:SetCollisionGroup( COLLISION_GROUP_WORLD )
	battery:GetPhysicsObject():EnableMotion(false)
	battery:GetPhysicsObject():Sleep()
	
	socket.LinkedCamera:Fire("Enable")
	socket:EmitSound("npc/roller/mine/combine_mine_deploy1.wav")
	
	local data = EffectData()
		data:SetOrigin( battery:GetPos() )
		data:SetNormal( battery:GetForward() )
		data:SetMagnitude( 8 )
		data:SetScale( 1 )
		data:SetRadius( 16 )
	util.Effect("Sparks", data)
	
end

function WARE:PrePlugBatteryIn(socket, ent)
	if self.IsPlugged == false then
		self:PlugBatteryIn(socket,ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
	end
end

function WARE:Think()
	if !self.NextPlugThink or CurTime() < self.NextPlugThink then
		
		for key, socket in pairs(self.Sockets) do
			local pos = socket:GetPos()
			
			for _,ent in pairs(ents.FindInSphere(pos,24)) do
				if (ent.IsBattery) then
					local owner = ent.BatteryOwner
						
					if IsValid(owner) then
						owner:StripWeapons()
						owner:ApplyWin()
						socket.IsOccupied = true
							
						self:PrePlugBatteryIn(socket, ent)
						self.IsPlugged = true
					end
				end
			end			
		end	
		self.NextPlugThink = CurTime() + 0.1
	end
	
	for k,camera in pairs(ents.FindByClass("npc_combine_camera")) do
		local sphere = ents.FindInSphere(camera:GetPos(),24)
		
		for _,target in pairs(sphere) do
			if target:GetClass() == "prop_physics" then
				target:GetPhysicsObject():ApplyForceCenter((target:GetPos() - camera:GetPos()) * 500)
			end
		end
	end
end
