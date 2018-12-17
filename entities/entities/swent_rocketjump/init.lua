AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Weapons/W_missile_launch.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetOwner(self.Owner)
	self:EnableCustomCollisions(true)

	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

	local phys = self:GetPhysicsObject()
	phys:EnableDrag(true)
	phys:EnableGravity(false)
	phys:EnableCollisions(true)
	phys:SetMass(80)
	phys:SetMaterial("crowbar")
	if (phys:IsValid()) then
		phys:Wake()
	end

	if (CLIENT) then return end
	GAMEMODE:AppendEntToBin(self)

	return
end

function ENT:Use(activator,caller)
end

function ENT:OnTakeDamage( dmginfo )
	self:TakePhysicsDamage( dmginfo )
end

function ENT:PhysicsCollide( data, physobj )
	self:EmitSound("ambient/levels/labs/electric_explosion1.wav")

	local effectdata = EffectData( )
		effectdata:SetOrigin( self:GetPos( ) + data.HitNormal * 16 )
		effectdata:SetNormal(Vector(self:GetPos() - data.HitPos))
	util.Effect( "waveexplo", effectdata, true, true )

	--Old fucking hard rocketjump code by Hurricaaane
	/*for _,ent in pairs(ents.FindInSphere(self.Entity:GetPos(),64)) do
		if ent:IsPlayer() == true then
			ent:SetGroundEntity( NULL )
			ent:SetVelocity(ent:GetVelocity() + (ent:GetPos() - self.Entity:GetPos()):GetNormalized() * 350)
		end
	end*/

	--New code from BlackOps
	for i,v in ipairs(ents.FindInSphere( self:GetPos(), 60 )) do
		if (v == self:GetOwner()) then
			v:SetVelocity(v:GetAimVector() * -500, 0)
		end
	end
	self:Remove()
end

function ENT:Think()
end
