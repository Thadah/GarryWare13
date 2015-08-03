WARE.Author = "Kilburn"

local CrateColours = {
	{1,0,0},
	{0,1,0},
	{0,0,1},
	{1,1,0},
	{1,0,1},
	{0,1,1},
}

local CratePitches = {
	262,
	294,
	330,
	349,
	392,
	440,
}

WARE.Models = {
"models/props_junk/wood_crate001a.mdl"
 }

function WARE:GetModelList()
	local self = WARE
	return self.Models
end

function WARE:ResetCrate(i)
	local self = WARE
	if !self.Crates then return end
	
	local prop = self.Crates[i]
	if !(prop and prop:IsValid()) then return end
	
	local col = CrateColours[prop.num]
	
	prop:SetColor(Color(col[1]*100, col[2]*100, col[3]*100, 100))
end

function WARE:PlayCrate(i)
	local self = WARE
	if !self.Crates then return end
	
	local prop = self.Crates[i]
	if !(prop and prop:IsValid()) then return end
	
	local col = CrateColours[prop.num]
	
	prop:SetColor(Color(col[1]*255, col[2]*255, col[3]*255, 255))
	prop:SetHealth(100000)
	prop:EmitSound("buttons/button17.wav", 100, CratePitches[i]/3)
	
	GAMEMODE:MakeAppearEffect( prop:GetPos() )
	
	timer.Simple(0.5, function()
	local col = CrateColours[i]
	
	prop:SetColor(Color(col[1]*100, col[2]*100, col[3]*100, 100))
	end)
end

-----------------------------------------------------------------------------------

function WARE:Initialize()
	local self = WARE
	GAMEMODE:EnableFirstWinAward( )
	GAMEMODE:SetWinAwards( AWARD_IQ_WIN )
	GAMEMODE:SetFailAwards( AWARD_IQ_FAIL )
	GAMEMODE:OverrideAnnouncer( 2 )
	
	local numberSpawns = 5
	local delay = 4
	
	GAMEMODE:SetWareWindupAndLength(numberSpawns + delay, numberSpawns)
	
	GAMEMODE:SetPlayersInitialStatus( false )
	GAMEMODE:DrawInstructions( "Watch carefully!" )
	
	self.Crates = {}
	self.UsedColors = {}
	self.Sequence = {}
	for i=1,numberSpawns do self.Sequence[i] = i end
	
	local function getRandomColors()
		local rcolor = 1
		local used = true
		while (used) do
			rcolor = math.random(1,#CrateColours)
			used = false
			for i=1,#self.UsedColors do
				if (rcolor == self.UsedColors[i]) then
					used = true
				end
			end
		end
		self.UsedColors[#self.UsedColors+1] = rcolor
		return rcolor
	end
	
	for i,pos in ipairs(GAMEMODE:GetRandomPositions(numberSpawns, ENTS_ONCRATE)) do
		local num = getRandomColors()
		local col = CrateColours[num]
		local prop = ents.Create("prop_physics")
		prop:SetModel( self.Models[1] )
		prop:PhysicsInit(SOLID_VPHYSICS)
		prop:SetSolid(SOLID_VPHYSICS)
		prop:SetPos(pos + Vector(0,0,64))
		prop:Spawn()
		
		prop:SetColor(Color(col[1]*100, col[2]*100, col[3]*100, 100))
		prop:SetHealth(100000)
		prop:SetMoveType(MOVETYPE_NONE)
		prop:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		prop.CrateID = i
		prop.num = num
		
		self.Crates[i] = prop
		
		GAMEMODE:AppendEntToBin(prop)
		GAMEMODE:MakeAppearEffect(pos)
		
		local curTime = CurTime()
		
		timer.Simple(delay+i-1, function()
			if !self.Crates then return end
	
			if !(prop and prop:IsValid()) then return end
			
		
			prop:SetColor(Color(col[1]*255, col[2]*255, col[3]*255, 255))
			prop:SetHealth(100000)
			prop:EmitSound("buttons/button17.wav", 100, CratePitches[num]/3)
	
			GAMEMODE:MakeAppearEffect( prop:GetPos() )
	
			timer.Simple(0.5, function()
				if !self.Crates then return end
	
				local prop = self.Crates[i]
				if !(prop and prop:IsValid()) then return end
	
				local col = CrateColours[num]
	
				prop:SetColor(Color(col[1]*100, col[2]*100, col[3]*100, 100))
			end)
		end)
		
	end
	
	
	
	
end

function WARE:StartAction()
	local self = WARE
	GAMEMODE:DrawInstructions( "Repeat!" )
	
	self.PlayerCurrentCrate = {}
	
	for _,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		v:Give("sware_pistol")
		v:GiveAmmo(12, "Pistol", true)
		self.PlayerCurrentCrate[v] = 1
	end
end

function WARE:EndAction()
	
end

function WARE:EntityTakeDamage(ent,info)
	local pool = WARE
	local att = info:GetAttacker()
	
	if !att:IsPlayer() or !info:IsBulletDamage() then return end
	if !pool.PlayerCurrentCrate[att] then return end
	if !pool.Crates or !ent.CrateID then return end
	
	self:PlayCrate(ent.CrateID)
	
	if pool.Sequence[pool.PlayerCurrentCrate[att]] == ent.CrateID then
		pool.PlayerCurrentCrate[att] = pool.PlayerCurrentCrate[att] + 1
		att:SendHitConfirmation()
		if !pool.Sequence[pool.PlayerCurrentCrate[att]] then
			att:ApplyWin( )
			att:StripWeapons()
		end
	else
		att:ApplyLose( )
		att:StripWeapons()
	end
end
