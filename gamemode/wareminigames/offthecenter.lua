WARE = {}
WARE.Author = "Hurricaaane (Ha3)"
WARE.Room = "hexaprism"
 
WARE.CircleRadius = 0
WARE.HeightLimit = 0

WARE.CenterEntity = nil

WARE.CenterPos = nil
WARE.Apos = nil
WARE.CircleRadius = nil
WARE.Mposz = nil
WARE.PitPosz = nil
WARE.HeightLimit = nil

function WARE:IsPlayable()
	if team.NumPlayers(TEAM_HUMANS) >= 2 then
		return true
	end
	return false
end

function WARE:Initialize()
	GAMEMODE:SetFailAwards( AWARD_FRENZY )
	self.LastThinkDo = 0
	
	GAMEMODE:RespawnAllPlayers( true, true )
	
	GAMEMODE:SetWareWindupAndLength(4, 4)
	
	GAMEMODE:SetPlayersInitialStatus( true )
	GAMEMODE:DrawInstructions( "Away from the center! Don't fall!" )
	
	self.CenterPos = GAMEMODE:GetEnts("center")[1]:GetPos()
	self.Apos = GAMEMODE:GetEnts("land_a")[1]:GetPos()
	self.CircleRadius = (self.CenterPos - self.Apos):Length() - 24
	self.Mposz = GAMEMODE:GetEnts("land_measure")[1]:GetPos().z
	self.PitPosz = GAMEMODE:GetEnts("pit_measure")[1]:GetPos().z
	self.HeightLimit = self.PitPosz + (self.Mposz - self.PitPosz) * 0.8
	
	local effectRadius = self.CircleRadius + 32
		
	local effectdata = EffectData()
	effectdata:SetOrigin( self.CenterPos )
	effectdata:SetStart( self.Apos )
	effectdata:SetRadius( effectRadius )
	effectdata:SetMagnitude( 15 )
	effectdata:SetAngles(Angle(119, 199, 255))
	effectdata:SetScale( 9 )
	util.Effect( "ware_prisma_harmonics", effectdata, true, true )
	effectdata:SetOrigin( self.CenterPos + Vector(0,0,16) )
	util.Effect( "ware_prisma_harmonics_floor", effectdata, true, true)
		
	local ent = ents.Create("ware_ringzone")
		ent:SetPos( self.CenterPos + Vector(0,0,8) )
		ent:SetAngles( Angle(0,0,0) )
		ent:Spawn()
		ent:Activate()
		
		ent.LastActTime = 0
		
		ent:SetZSize(self.CircleRadius * 2)
		ent:SetZColor(  Color(185,220,255)  )
		
		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
		
	self.CenterEntity = ent
end

function WARE:StartAction()	
	for k,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		v:Give( "sware_crowbar" )
	end
	return
end

function WARE:EndAction()

end

function WARE:Think( )
	for k,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		if !v:GetLocked() and (v:GetPos().z < self.HeightLimit) then
			v:ApplyLose( )
			v:SimulateDeath( )
			v:EjectWeapons(nil, 100)
		end
	end
	
	
	
	if (CurTime() < (self.LastThinkDo + 0.1)) then return end
	self.LastThinkDo = CurTime()
	
	local ring = self.CenterEntity
	local sphere = ents.FindInSphere(ring:GetPos(), self.CircleRadius * 0.95)
	for _,target in pairs(sphere) do
		if target:IsPlayer() and target:IsWarePlayer() then
			if (CurTime() > (ring.LastActTime + 0.2)) then
				ring.LastActTime = CurTime()
				if !target:GetLocked() then
					ring:EmitSound("ambient/levels/labs/electric_explosion1.wav")
					
					local effectdata = EffectData( )
						effectdata:SetOrigin( ring:GetPos( ) )
						effectdata:SetNormal( Vector(0,0,1) )
					util.Effect( "waveexplo", effectdata, true, true )
				end
				
				target:SetGroundEntity( NULL )
				target:SetVelocity(target:GetVelocity()*(-1) + (target:GetPos() + Vector(0,0,32) - ring:GetPos()):GetNormalized() * 500 )
			
			end
		end
	
		if target:IsPlayer() and target:IsWarePlayer() and !target:GetLocked() then
			local dir = (target:GetPos() + Vector(0, 0, 128) - ring:GetPos()):GetNormalized()
			target:ApplyLose()
			target:SimulateDeath( dir * 100 )
			target:EjectWeapons( dir * 200, 100 ) 
		end
		
		
	end
end
