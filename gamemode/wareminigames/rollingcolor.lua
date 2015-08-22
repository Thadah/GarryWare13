WARE = {}
WARE.Author = "Kilburn"

WARE.PossibleColors = {
	{ "black" , Color(0,0,0,255) },
	{ "grey" , Color(138,138,138,255)},
	{ "white" , Color(255,255,255,255)},
	{ "red" , Color(220,0,0,255) },
	{ "green" , Color(0,220,0,255) },
	{ "blue" , Color(64,64,255,255) },
	{ "pink" , Color(255,0,255,255) }
}

WARE.Models = {"models/props_c17/furniturewashingmachine001a.mdl"}
 
WARE.MagicSequence = {}
 
WARE.Props = {}

function WARE:GetModelList()
	return self.Models
end

function WARE:SwitchAllToNextColor( )
	for k,prop in pairs(self.Props) do
		if IsValid( prop ) then
			self:SwitchToNextColor( prop )
			GAMEMODE:MakeAppearEffect(prop:GetPos())
		end
	end
end

function WARE:SwitchToNextColor( prop )
	if (CurTime() < (prop.LastHitDirect + 1.0)) or prop.HitCorrect then return end

	local sequenceID = 1 + ((prop.SequenceID or 1) % #self.MagicSequence)
	prop.SequenceID = sequenceID
	
	local colorID = self.MagicSequence[sequenceID]
	
	prop:SetColor(Color(self.PossibleColors[colorID][2].r, self.PossibleColors[colorID][2].g, self.PossibleColors[colorID][2].b, self.PossibleColors[colorID][2].a))
end

local function RemoveProp( prop )
	if IsValid(prop) then
		GAMEMODE:MakeDisappearEffect( prop:GetPos() )
		prop:Remove()
	end
end

function WARE:Initialize()
	GAMEMODE:EnableFirstWinAward( )
	GAMEMODE:SetWinAwards( AWARD_REFLEX )
	GAMEMODE:SetWareWindupAndLength(0.7, 7)
	
	
	self.MagicSequence = {}
	for k=1,#self.PossibleColors do
		self.MagicSequence[k] = k
	end
	
	if #self.MagicSequence > 1 then --Should always happen
		for i=1,#self.MagicSequence do
			table.insert( self.MagicSequence , table.remove( self.MagicSequence, math.random(1, #self.MagicSequence - 1) ) )
		end
	end
	
	
	local ratio = 0.5
	local minimum = 4
	local num = math.Clamp(math.ceil(team.NumPlayers(TEAM_HUMANS)*ratio), minimum, 64)
	local entposcopy = GAMEMODE:GetRandomLocations(num, ENTS_OVERCRATE)
	
	for k,v in pairs(entposcopy) do
		local ent = ents.Create("prop_physics")
		ent:SetModel( self.Models[1] )
		ent:SetPos(v:GetPos())
		ent:SetAngles(Angle(0,math.Rand(0,360),0) )
		ent:Spawn()
		
		ent.LastHitDirect = 0
		ent.HitCorrect    = false
		
		ent:GetPhysicsObject():EnableMotion(false)
		GAMEMODE:AppendEntToBin(ent)
		
		table.insert( self.Props , ent )
		
		ent.SequenceID = math.random( 1, #self.MagicSequence )
		self:SwitchToNextColor( ent )

		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
	end
	
	local selected = table.Random(self.MagicSequence)
	self.SelectedColorID = selected
	
	GAMEMODE:SetPlayersInitialStatus( false )
	GAMEMODE:DrawInstructions( "Wait and shoot the ".. self.PossibleColors[selected][1] .." prop!" , self.PossibleColors[selected][2] or nil, self.PossibleColors[selected][3] or nil )
	
end

function WARE:StartAction()
	for _,ply in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		ply:Give("sware_pistol")
		ply:GiveAmmo(12, "Pistol", true)
	end
	
	timer.Create("WAREChangeColor", 0.7, 0, function() self:SwitchAllToNextColor() end)
end

function WARE:EndAction()
	timer.Destroy("WAREChangeColor")
end

function WARE:EntityTakeDamage(ent,info)
    local att = info:GetAttacker()

	if att:IsPlayer() == false or info:IsBulletDamage() == false then return end
	if !ent.SequenceID then return end
	
	ent.LastHitDirect = CurTime()
	
	if self.MagicSequence[ent.SequenceID] == self.SelectedColorID then
		att:ApplyWin( )
		ent.HitCorrect = true
		timer.Simple(1, function() RemoveProp(ent) end)
	else
		att:ApplyLose( )
	end
	
	att:StripWeapons()
	
end
