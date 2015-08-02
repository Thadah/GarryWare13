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

function WARE:Initialize()
	GAMEMODE:EnableFirstWinAward( )
	GAMEMODE:SetWinAwards( AWARD_IQ_WIN )
	GAMEMODE:SetFailAwards( AWARD_IQ_FAIL )
	
	GAMEMODE:OverrideAnnouncer( 2 )
	
	self.NumberSpawns = math.random( 3, 7 )

	self.croissant = math.random(0,1)
	GAMEMODE:SetWareWindupAndLength(self.NumberSpawns * 0.4, self.NumberSpawns * 1.7 * 1.5 * ((self.croissant ~= 1) and 1.3 or 1))
	
	GAMEMODE:SetPlayersInitialStatus( false )
	--GAMEMODE:DrawInstructions("Shoot all " .. self.NumberSpawns .." crates in the right order!" )
	GAMEMODE:DrawInstructions("Shoot in the right order!" )
	
	self.Crates = {}
	self.Numbers = {}
	self.Sequence = {}
	
	local leftchars = "ABCDEFGHJKMNPRSTUVWXYZ"
	local tableseq = {}
	
	for i=1,self.NumberSpawns do
		local selector = math.random(1, string.len(leftchars))
		table.insert( tableseq, string.sub(leftchars, selector, selector) )
		
		local previous = (selector > 1) and string.sub(leftchars, 1, selector - 1) or ""
		local follow   = (selector < string.len(leftchars)) and string.sub(leftchars, selector + 1) or ""
		leftchars = previous .. follow
		
	end
	
	local cseq = ""
	table.sort(tableseq)
	for i=1,#tableseq do
		cseq = cseq .. tableseq[i]
	end
	
	
	
	for i,pos in ipairs(GAMEMODE:GetRandomPositions(self.NumberSpawns, ENTS_ONCRATE)) do
		local prop = ents.Create("prop_physics")
		prop:SetModel( self.Models[1] )
		prop:PhysicsInit(SOLID_VPHYSICS)
		prop:SetSolid(SOLID_VPHYSICS)
		prop:SetPos(pos+Vector(0,0,64))
		prop:Spawn()
		
		prop:SetColor(255, 255, 255, 100)
		prop:SetHealth(100000)
		prop:SetMoveType(MOVETYPE_NONE)
		prop:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		prop.CrateID = i
		
		self.Crates[i] = prop
		
		local charq = string.sub(cseq, i, i)
		
		local textent = ents.Create("ware_ascii")
		textent:SetPos(pos + Vector(0,0,64))
		textent:Spawn()
		textent:SetEntityInteger( string.byte( charq ) )
		
		table.insert( self.Numbers , charq )
		
		prop.AssociatedText = textent
		
		GAMEMODE:AppendEntToBin(prop)
		GAMEMODE:AppendEntToBin(textent)
		GAMEMODE:MakeAppearEffect(pos)
	end
	
end

function WARE:StartAction()
	if (self.croissant == 1) then
		for k=1,self.NumberSpawns do
			table.insert( self.Sequence , k )
		end
		GAMEMODE:DrawInstructions( "In the alphabetical order! (A , B , C...)" )
		GAMEMODE:PrintInfoMessage( "Sequence order", " is ", "alphabetical (A , B , C...)!" )
	else
		for k=self.NumberSpawns,1,-1 do
			table.insert( self.Sequence , k )
		end
		GAMEMODE:DrawInstructions( "In the reverse order! (C , B , A...)" )
		GAMEMODE:PrintInfoMessage( "Sequence order", " is ", "reverse (C , B , A...)!" )
	end
	
	self.PlayerCurrentCrate = {}
	self.PlayerAlreadyHitCrate = {}
	
	for _,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		self.PlayerAlreadyHitCrate[v] = {}
		v:Give("sware_pistol")
		v:GiveAmmo(12, "Pistol", true)
		self.PlayerCurrentCrate[v] = 1
	end
end

function WARE:EndAction()
	local message = ""
	
	for k,seqK in pairs( self.Sequence ) do
		message = message .. self.Numbers[ seqK ]
		if k < #self.Sequence then
			message = message .. " , "
		end
	end
	
	GAMEMODE:PrintInfoMessage( "Sequence", " was ", message .."!" )
	GAMEMODE:DrawInstructions( "Sequence was ".. message .."!" , self.CorrectColor)
end

function WARE:EntityTakeDamage(ent,info)
	local pool = self
	local att = info:GetAttacker()
	
	if !att:IsPlayer() or !info:IsBulletDamage() then return end
	if !pool.PlayerCurrentCrate[att] then return end
	if !pool.Crates or !ent.CrateID then return end
	
	if (self.PlayerAlreadyHitCrate[att][ent.CrateID] == true) then return end
	self.PlayerAlreadyHitCrate[att][ent.CrateID] = true
	
	GAMEMODE:MakeAppearEffect( ent:GetPos() )
	
	if pool.Sequence[pool.PlayerCurrentCrate[att]] == ent.CrateID then
		pool.PlayerCurrentCrate[att] = pool.PlayerCurrentCrate[att] + 1
		
		att:SendHitConfirmation( )
		GAMEMODE:SendEntityTextColor( att , ent.AssociatedText , 0, 192, 0, 255 )
		
		if !pool.Sequence[pool.PlayerCurrentCrate[att]] then
			att:ApplyWin( )
			att:StripWeapons()
		end
		
	else
		local goodent = pool.Crates[pool.Sequence[pool.PlayerCurrentCrate[att]]]
		GAMEMODE:SendEntityTextColor( att , goodent.AssociatedText , 255, 0, 0, 255 )
		GAMEMODE:SendEntityTextColor( att , ent.AssociatedText     , 96, 96, 96, 255 )
	
		att:ApplyLose( )
		att:StripWeapons()
		
	end
end
