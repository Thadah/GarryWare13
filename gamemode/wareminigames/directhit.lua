WARE.Author = "Hurricaaane (Ha3)"
WARE.Room = "hexaprism"
 
WARE.CircleRadius = 0
WARE.HeightLimit = 0

WARE.CenterEntity = nil

WARE.CenterPos = nil
WARE.Apos = nil
WARE.CircleRadius = nil

function WARE:IsPlayable()
	if team.NumPlayers(TEAM_HUMANS) >= 2 then
		return true
	end
	return false
end

function WARE:Initialize()
	local self = WARE
	GAMEMODE:SetFailAwards( AWARD_VICTIM )
	self.LastThinkDo = 0
	
	GAMEMODE:RespawnAllPlayers( true, true )
	
	GAMEMODE:SetWareWindupAndLength(2, 6)
	
	GAMEMODE:SetPlayersInitialStatus( true )
	GAMEMODE:DrawInstructions("Don't contact!")
	
	self.CenterPos = GAMEMODE:GetEnts("center")[1]:GetPos()
	self.Apos = GAMEMODE:GetEnts("land_a")[1]:GetPos()
	self.CircleRadius = (self.CenterPos - self.Apos):Length() - 24
	
	
	local effectdata = EffectData()
		effectdata:SetOrigin( self.CenterPos )
		effectdata:SetStart( self.Apos )
		effectdata:SetRadius( self.CircleRadius )
		effectdata:SetMagnitude( 15 )
		effectdata:SetAngles(Angle(119, 199, 255))
		effectdata:SetScale( 9 )
	util.Effect( "ware_prisma_harmonics", effectdata , true, true )	
end

function WARE:StartAction()	
	for k,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		v:Give( "sware_rocketjump" )
	end
	return
end

function WARE:EndAction()

end

function WARE:Think( )
	local self = WARE
	for k,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		if v:IsWarePlayer() and !v:GetLocked() then
			local calctor = v:GetPos()
			local bactor  = self.CenterPos
			calctor.z = self.CenterPos.z
			
			if (calctor - bactor):Length() > self.CircleRadius then
				v:ApplyLose( )
				local dir = (self.CenterPos - v:GetPos() + Vector(0,0,100))
				v:SimulateDeath( dir * 10000)
				v:EjectWeapons(dir * 300, 100)
				
				v:EmitSound("ambient/levels/labs/electric_explosion1.wav")
				
				local effectdata = EffectData( )
					effectdata:SetOrigin( v:GetPos() )
					effectdata:SetNormal((v:GetPos() - self.CenterPos))
				util.Effect( "waveexplo", effectdata, true, true )
			end
		end
	end


end
