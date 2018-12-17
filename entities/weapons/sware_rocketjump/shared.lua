
if (SERVER) then
   AddCSLuaFile ("shared.lua")
end

SWEP.Base			      = "gmdm_base"
SWEP.PrintName	    = "SWARE Rocketjump"
SWEP.Slot				    = 1
SWEP.SlotPos			  = 0
SWEP.DrawAmmo			  = false
SWEP.DrawCrosshair  = true
SWEP.ViewModel			= "models/weapons/v_rpg.mdl"
SWEP.WorldModel			= "models/weapons/w_rocket_launcher.mdl"

SWEP.HoldType = "rpg"

SWEP.ShootSound = Sound ("npc/env_headcrabcanister/launch.wav")

SWEP.RunArmAngle  = Angle( -20, 0, 0 )
SWEP.RunArmOffset = Vector( 0, -4, 0 )
SWEP.Delay = 0.75
SWEP.TickDelay = 0.1

SWEP.ProjectileEntity = "swent_rocketjump"
SWEP.ProjectileForce = 5000000


function SWEP:Throw( shotPower )
  if (!SERVER) then return end

  local ent = ents.Create( self.ProjectileEntity )

  ent:SetPos( self.Owner:GetShootPos() + self.Owner:GetAimVector() * 16 )
  ent:SetAngles(self.Owner:EyeAngles())
  ent:Spawn()
  ent:SetOwner(self.Owner)
  ent:Activate()
  local tr = self.Owner:GetEyeTrace()
  util.SpriteTrail( ent,
                    0,
                    Color( 255, 255, 255, 255 ),
                    false,
                    8,
                    0,
                    0.2,
                    1 / 0.95,
                    "trails/tube.vmt")
  local phys = ent:GetPhysicsObject()

  if !(phys && IsValid(phys)) then ent:Remove() return end

  phys:ApplyForceCenter(self.Owner:GetAimVector():GetNormalized() *  math.pow(tr.HitPos:Length(), 3))
end

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

function SWEP:PrimaryAttack()
  self:SetNextPrimaryFire( CurTime() + self.Delay )
  self:SetNextSecondaryFire( CurTime() + self.TickDelay )

  self:EmitSound(self.ShootSound)

  self:TakePrimaryAmmo( 1 )

  if (CLIENT) then return end

  self:Throw( self.ProjectileForce )
end

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:SecondaryAttack()
end
