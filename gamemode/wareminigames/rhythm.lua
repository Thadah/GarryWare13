WARE = {}
WARE.Author = "Hurricaaane (Ha3)"

WARE.Models = {
"models/props_junk/wood_crate001a.mdl"
 }
 
WARE.CorrectColor = Color(0,0,0,255)

function WARE:GetModelList()
	return self.Models
end

WARE.Numbers = {}
WARE.NumberSpawns = 7
WARE.Tempo = 140
WARE.TestTempo = 4

function WARE:Initialize()
	self.FailmessageColor = Color(64, 0, 0)
	
	//GAMEMODE:EnableFirstWinAward( )
	GAMEMODE:SetWinAwards( AWARD_IQ_WIN )
	GAMEMODE:SetFailAwards( AWARD_IQ_FAIL )
	
	GAMEMODE:OverrideAnnouncer( 4 )
	
	self.Tempo = math.random( 40, 70 )
	self.NumberSpawns = math.random( 4, 5 )
	
	self.TolerenceSeconds = 0.25
	self.TolerenceSecondsBound = self.TolerenceSeconds/2

	GAMEMODE:SetWareWindupAndLength(60/self.Tempo*self.TestTempo, 60/self.Tempo*(self.NumberSpawns+1))
	
	GAMEMODE:SetPlayersInitialStatus( true )
	GAMEMODE:DrawInstructions("To the rhythm!" )
	
	self.Crates = {}
	
	for i,pos in ipairs(GAMEMODE:GetRandomPositions(self.NumberSpawns, ENTS_ONCRATE)) do
		local prop = ents.Create("prop_physics")
		prop:SetModel( self.Models[1] )
		prop:PhysicsInit(SOLID_VPHYSICS)
		prop:SetSolid(SOLID_VPHYSICS)
		prop:SetPos(pos+Vector(0,0,64))
		prop:Spawn()
		
		prop:SetColor(Color(255, 255, 255, 100))
		prop:SetRenderMode(RENDERMODE_TRANSALPHA)
		prop:SetHealth(100000)
		prop:SetMoveType(MOVETYPE_NONE)
		prop:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		prop.CrateID = i
		
		self.Crates[i] = prop
		
		local textent = ents.Create("ware_text")
		textent:SetPos(pos + Vector(0,0,64))
		textent:Spawn()
		textent:SetEntityInteger( i )
		
		prop.AssociatedText = textent
		
		GAMEMODE:AppendEntToBin(prop)
		GAMEMODE:AppendEntToBin(textent)
		GAMEMODE:MakeAppearEffect(pos)
		
	end
	
	self.PlayerStates = {}
	for k,ply in pairs(team.GetPlayers(TEAM_HUMANS)) do
		self.PlayerStates[ply] = 0
		
	end
	
	self.IsOpenForRhythm = false
	self.CurrentRhythm = 1
	
	for i=1,self.TestTempo do
		timer.Simple( i*60/self.Tempo, function() self:RhythmSignal() end )
		
	end
	umsg.Start("SpecialFlourish")
		umsg.Char( 3 )
	umsg.End()
	
end

function WARE:OpenForRhythm()
	self.IsOpenForRhythm = true
	timer.Simple( self.TolerenceSeconds, function() self:LateForRhythm() end )
	timer.Simple( self.TolerenceSecondsBound, function() self:RhythmSignal() end )	
end

function WARE:StartAction()
	for _,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		v:Give("sware_pistol")
		v:GiveAmmo(12, "Pistol", true)
	end
	
	for i=1,self.NumberSpawns do
		timer.Simple( i*60/self.Tempo - self.TolerenceSecondsBound, function() self:OpenForRhythm() end )
		
	end
	
end

function WARE:EndAction()
end

function WARE:RhythmSignal()
	for k,v in pairs( self.Crates ) do
		GAMEMODE:MakeAppearEffect( v:GetPos() )
	end
	self.Crates[self.CurrentRhythm]:EmitSound("doors/vent_open3.wav", 100, GAMEMODE:GetSpeedPercent() )
	
	
end

function WARE:LateForRhythm()
	self.IsOpenForRhythm = false
	
	local hasLate = false
	local rpLate = RecipientFilter()
	for k,ply in pairs(team.GetPlayers(TEAM_HUMANS)) do
		if self.PlayerStates[ply] ~= self.CurrentRhythm then
			if !ply:GetLocked() then
				hasLate = true
				rpLate:AddPlayer( ply )
				
			end
			ply:ApplyLose()
			ply:StripWeapons()
			
		end
		
	end
	
	if hasLate then
		GAMEMODE:SendEntityTextColor( rpLate , self.Crates[self.CurrentRhythm].AssociatedText     , 192, 0, 0, 255 )
		GAMEMODE:DrawInstructions( "Too late!" , self.FailmessageColor , nil , rpLate )
		
	end
	self.CurrentRhythm = self.CurrentRhythm + 1
	
end

function WARE:EntityTakeDamage(ent, dmginfo)
	local inf = dmginfo:GetInflictor()
	local att = dmginfo:GetAttacker()
	local amount = dmginfo:GetDamage()
	local pool = self
	
	if !att:IsPlayer() or !dmginfo:IsBulletDamage() then return end
	if !pool.Crates or !ent.CrateID then return end
	
	if !self.PlayerStates[att] then return end
	
	GAMEMODE:MakeAppearEffect( ent:GetPos() )
	
	if self.IsOpenForRhythm and (ent.CrateID == self.CurrentRhythm) and (self.PlayerStates[att] == self.CurrentRhythm-1) then
		GAMEMODE:SendEntityTextColor( att , ent.AssociatedText     , 255, 255, 0, 255 )
		
		self.PlayerStates[att] = self.CurrentRhythm
		if (self.PlayerStates[att] == self.NumberSpawns) then
			att:ApplyWin( )
			att:StripWeapons()
		end
		
	else
		GAMEMODE:SendEntityTextColor( att , ent.AssociatedText     , 96, 96, 96, 255 )
		if (ent.CrateID == self.CurrentRhythm) then
			GAMEMODE:DrawInstructions( "Too early!" , self.FailmessageColor , nil , att )
		end
		
		att:ApplyLose()
		att:StripWeapons()
		
	end
	
end
