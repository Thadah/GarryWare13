WARE = {}
WARE.Author = "Kilburn"

WARE.CrateColours = {
	{1,0,0},
	{0,1,0},
	{0,0,1},
	{1,1,0},
	{1,0,1},
	{0,1,1}
}

WARE.CratePitches = {
	262,
	294,
	330,
	349,
	392,
	440
}

WARE.Models = {"models/props_junk/wood_crate001a.mdl"}

function WARE:GetModelList()
	return self.Models
end

function WARE:GetModelFromList(i)
	return self.Models[i]
end

function WARE:ResetCrate(i)
	if !self.Crates then return end
	
	local prop = self.Crates[i]
	if !(prop and prop:IsValid()) then return end
	
	local col = self.CrateColours[prop.num]
	
	prop:SetColor(Color(col[1]*100, col[2]*100, col[3]*100, 100))
end

function WARE:PlayCrate(i)
	if !self.Crates then return end
	
	local prop = self.Crates[i]
	if !(prop and IsValid(prop)) then return end
	
	local col = self.CrateColours[prop.num]
	
	prop:SetColor(Color(col[1]*255, col[2]*255, col[3]*255, 255))
	prop:SetHealth(100000)
	prop:EmitSound("buttons/button17.wav", 100, self.CratePitches[i]/3)
	
	GAMEMODE:MakeAppearEffect( prop:GetPos() )
	
	timer.Simple(0.5, function()
	local col = self.CrateColours[i]
	
	prop:SetColor(Color(col[1]*100, col[2]*100, col[3]*100, 100))
	end)
end


function WARE:Initialize()
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
			rcolor = math.random(1,#self.CrateColours)
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
		local col = self.CrateColours[num]
		local prop = ents.Create("prop_physics")
		prop:SetModel( self:GetModelFromList(1) )
		prop:PhysicsInit(SOLID_VPHYSICS)
		prop:SetSolid(SOLID_VPHYSICS)
		prop:SetPos(pos + Vector(0,0,64))
		prop:Spawn()
		
		prop:SetColor(Color(col[1]*100, col[2]*100, col[3]*100, 100))
		prop:SetRenderMode(RENDERMODE_TRANSALPHA)
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
			prop:EmitSound("buttons/button17.wav", 100, self.CratePitches[num]/3)
	
			GAMEMODE:MakeAppearEffect( prop:GetPos() )
	
			timer.Simple(0.5, function()
				if !self.Crates then return end
	
				local prop = self.Crates[i]
				if !(prop and prop:IsValid()) then return end
	
				local col = self.CrateColours[num]
	
				prop:SetColor(Color(col[1]*100, col[2]*100, col[3]*100, 100))
			end)
		end)
		
	end
	
	
	
	
end

function WARE:StartAction()
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
	local att = info:GetAttacker()
	
	if !att:IsPlayer() or !info:IsBulletDamage() then return end
	if !self.PlayerCurrentCrate[att] then return end
	if !self.Crates or !ent.CrateID then return end
	
	self:PlayCrate(ent.CrateID)
	
	if self.Sequence[self.PlayerCurrentCrate[att]] == ent.CrateID then
		self.PlayerCurrentCrate[att] = self.PlayerCurrentCrate[att] + 1
		att:SendHitConfirmation()
		if !self.Sequence[self.PlayerCurrentCrate[att]] then
			att:ApplyWin()
			att:StripWeapons()
		end
	else
		att:ApplyLose()
		att:StripWeapons()
	end
end
