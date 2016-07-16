////////////////////////////////////////////////
// GarryWare Reloaded                         //
// by Hurricaaane (Ha3)                       //
//  and Kilburn_                              //
// Fixed by Thadah and Cyumus                 //
// http://www.youtube.com/user/Hurricaaane    //
// https://www.youtube.com/c/CyumusAduni	  //
//--------------------------------------------//
-- Clientside Initialization                  --
////////////////////////////////////////////////

include( 'shared.lua' )

surface.CreateFont("garryware_instructions", {
    font = "Trebuchet MS",
	size = 36,
	weight = 0,
	antialiasing = true,
	additive = false
} )

surface.CreateFont("garryware_largetext", {
    font = "Trebuchet MS",
	size = 36,
	weight = 0,
	antialiasing = true,
	additive = false
} )

surface.CreateFont("garryware_mediumtext", {
    font = "Trebuchet MS",
	size = 24,
	weight = 0,
	antialiasing = true,
	additive = false
} )

surface.CreateFont("garryware_averagetext", {
    font = "Trebuchet MS",
	size = 20,
	weight = 0,
	antialiasing = true,
	additive = false
} )

surface.CreateFont("garryware_smalltext", {
    font = "Trebuchet MS",
	size = 16,
	weight = 400,
	antialiasing = true,
	additive = false
} )

include( 'derma/cl_warelabel.lua' )
include( 'derma/cl_arrow.lua' )
include( 'derma/cl_message.lua' )
include( 'derma/cl_playerlabel.lua' )
include( 'derma/cl_finalplayerlabel.lua' )

include( 'cl_hud.lua' )
include( 'cl_postprocess.lua' )
include( 'cl_networking.lua' )


--Libraries
include( "libs/sh_tables.lua" )
include( "libs/sh_skin.lua" )
include( "libs/sh_chat.lua" )
include( "libs/cl_mapdecoration.lua" )

--Modules
include("modules/netstream2.lua")
include("modules/pon.lua")

include( "cl_version.lua" )

include( 'derma/cl_splashscreen.lua' )
include( 'derma/vgui/cl_scoreboard.lua' )

include( 'libs/sh_garbagecollector.lua' )


function WARE_SortTable( plyA, plyB )
	if ( !(plyA) or !(plyB) ) then return false end
	if ( !(IsValid(plyA)) or !(IsValid(plyB)) ) then return false end
	
	local tokenA = plyA:GetAchieved() and (plyA:GetLocked() and (plyA:IsFirst() and 5 or 4) or 3) or (plyA:GetLocked() and (plyA:IsFirst() and 1 or 0) or 2)
	local tokenB = plyB:GetAchieved() and (plyB:GetLocked() and (plyB:IsFirst() and 5 or 4) or 3) or (plyB:GetLocked() and (plyB:IsFirst() and 1 or 0) or 2)
	
	if ( tokenA == tokenB ) then
		if ( plyA:Frags() == plyB:Frags() ) then
			if ( plyA:GetBestCombo() == plyB:GetBestCombo() ) then
				return plyA:Nick() < plyB:Nick()
			else
				return plyA:GetBestCombo() > plyB:GetBestCombo()
			end
		else
			return plyA:Frags() > plyB:Frags()
		end
	else
		return tokenA > tokenB
		
	end
end

function WARE_SortTableStateBlind( plyA, plyB )
	if ( !(plyA) or !(plyB) ) then return false end
	if ( !(IsValid(plyA)) or !(IsValid(plyB)) ) then return false end
	
	if ( plyA:Frags() == plyB:Frags() ) then
		if ( plyA:GetBestCombo() == plyB:GetBestCombo() ) then
			return plyA:Nick() < plyB:Nick()
		else
			return plyA:GetBestCombo() > plyB:GetBestCombo()
		end
	else
		return plyA:Frags() > plyB:Frags()
	end
end

function GM:CreateAmbientMusic()
	for k,path in pairs(GAMEMODE.WASND[1]) do
		gws_AmbientMusic[k] = CreateSound(LocalPlayer(), path[2])
		gws_AmbientMusic_dat[k] = {}
	end
	
end

function GM:InitPostEntity()
	self.BaseClass:InitPostEntity()
	
	self:CreateAmbientMusic()
	
end

function GM:Think()
	self.BaseClass:Think()
	
	-- Announcer ticks.
	if (gws_TickAnnounce > 0 and CurTime() < gws_NextgameEnd ) then
		if (CurTime() > (gws_NextgameEnd - (gws_WareLen / 6) * gws_TickAnnounce )) then
						
			local nameOfFile = ""
			
			if gws_CurrentAnnouncer == 1 then
				nameOfFile = GAMEMODE.WASND[6][gws_TickAnnounce][1]
			elseif gws_CurrentAnnouncer == 2 then
				nameOfFile = GAMEMODE.WASND[6][gws_TickAnnounce+5][1]
			else
				nameOfFile = GAMEMODE.WASND[7][(gws_TickAnnounce%2)+1][1]
			end
			
			
			LocalPlayer():EmitSound(nameOfFile)
			
			gws_TickAnnounce = gws_TickAnnounce - 1
		end
	end
end


--print( "GAMEMODE : " .. tostring(gmod.GetGamemode and gmod.GetGamemode().Name or "<ERROR>") )
