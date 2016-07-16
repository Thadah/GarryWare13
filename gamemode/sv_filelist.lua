////////////////////////////////////////////////
// // GarryWare Gold                          //
// by Hurricaaane (Ha3)                       //
//  and Kilburn_                              //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Files sent to players                      //
////////////////////////////////////////////////

AddCSLuaFile( "shared.lua" )

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_postprocess.lua" )
AddCSLuaFile( "cl_networking.lua" )


AddCSLuaFile( "cl_version.lua" )

--Libraries
AddCSLuaFile( "libs/sh_skin.lua" )
AddCSLuaFile( "libs/sh_tables.lua" )
AddCSLuaFile( "libs/cl_mapdecoration.lua" )
AddCSLuaFile( "libs/sh_garbagecollector.lua" )
AddCSLuaFile( "libs/sh_chat.lua" )

AddCSLuaFile( "ply_extension.lua" )


-- Fretta VGUI replacements :
AddCSLuaFile( "derma/cl_splashscreen.lua" )
AddCSLuaFile( "derma/vgui/cl_scoreboard.lua" )

AddCSLuaFile( "derma/vgui/cl_transitscreen.lua" )
AddCSLuaFile( "derma/vgui/cl_clock.lua" )
AddCSLuaFile( "derma/vgui/cl_clockgame.lua" )
AddCSLuaFile( "derma/vgui/cl_waitscreen.lua" )

--Garryware VGUI
AddCSLuaFile( "derma/garryware_vgui/cl_main.lua" )
AddCSLuaFile( "derma/garryware_vgui/cl_livescoreboard.lua" )
AddCSLuaFile( "derma/garryware_vgui/cl_instructions.lua" )
AddCSLuaFile( "derma/garryware_vgui/cl_status.lua" )
AddCSLuaFile( "derma/garryware_vgui/cl_ammo.lua" )
AddCSLuaFile( "derma/garryware_vgui/cl_awards.lua" )

AddCSLuaFile( "derma/cl_warelabel.lua" )
AddCSLuaFile( "derma/cl_arrow.lua" )
AddCSLuaFile( "derma/cl_message.lua" )
AddCSLuaFile( "derma/cl_playerlabel.lua" )
AddCSLuaFile( "derma/cl_finalplayerlabel.lua" )

-- Sound Resources
for k,stringOrTable in pairs(GM.WASND) do
	if type(stringOrTable) == "string" then
		resource.AddFile("sound/" .. stringOrTable)
		
	elseif type(stringOrTable) == "table" then
	    if type(stringOrTable[1]) == "string" then --If not, it's a bireferenced table
			for l,sString in pairs(stringOrTable) do
				resource.AddFile("sound/" .. sString)
			end
		end
		
	end
end

-- Gamemode Resources
resource.AddFile("materials/refract_ring.vmt")
resource.AddFile("materials/refract_ring.vtf")
resource.AddFile("materials/ware/interface/ware_clock_two.vmt")
resource.AddFile("materials/ware/interface/ware_clock_two.vtf") -- This has NOLOD
resource.AddFile("materials/ware/interface/ware_trotter.vmt")
resource.AddFile("materials/ware/interface/ware_trotter.vtf")
resource.AddFile("materials/ware/interface/ware_shade.vmt")
resource.AddFile("materials/ware/interface/ware_shade.vtf")
resource.AddFile("materials/ware/stickers/ware_sticker.vmt")
resource.AddFile("materials/ware/stickers/ware_sticker.vtf") -- This has NOLOD actually
resource.AddFile("materials/vgui/ware/garryware_logo.vmt")
resource.AddFile("materials/vgui/ware/garryware_logo.vtf")
resource.AddFile("materials/vgui/ware/garryware_logo_alone.vmt")
resource.AddFile("materials/vgui/ware/garryware_logo_alone.vtf")
resource.AddFile("materials/ware/interface/ui_scoreboard_failure_noloss.vmt")
resource.AddFile("materials/ware/interface/ui_scoreboard_failure_noloss.vtf")
resource.AddFile("materials/ware/interface/ui_scoreboard_winner_noloss.vmt")
resource.AddFile("materials/ware/interface/ui_scoreboard_winner_noloss.vtf")
resource.AddFile("materials/ware/interface/ui_scoreboard_arrow_right_inner.vmt")
resource.AddFile("materials/ware/interface/ui_scoreboard_arrow_right_inner.vtf")
resource.AddFile("materials/ware/interface/ui_scoreboard_arrow_right_outer.vmt")
resource.AddFile("materials/ware/interface/ui_scoreboard_arrow_right_outer.vtf")
resource.AddFile("materials/ware/interface/ui_scoreboard_arrow_left_inner.vmt")
resource.AddFile("materials/ware/interface/ui_scoreboard_arrow_left_inner.vtf")
resource.AddFile("materials/ware/interface/ui_scoreboard_arrow_left_outer.vmt")
resource.AddFile("materials/ware/interface/ui_scoreboard_arrow_left_outer.vtf")

-- Nonc Files
resource.AddFile("materials/ware/nonc/ware_bullseye.vmt")
resource.AddFile("materials/ware/nonc/ware_bullseye.vtf")
resource.AddFile("materials/ware/nonc/ware_facepunch.vmt")
resource.AddFile("materials/ware/nonc/ware_facepunch.vtf")
resource.AddFile("materials/ware/nonc/ware_file.vmt")
resource.AddFile("materials/ware/nonc/ware_file.vtf")
resource.AddFile("materials/ware/nonc/ware_mail.vmt")
resource.AddFile("materials/ware/nonc/ware_mail.vtf")
resource.AddFile("materials/ware/nonc/ware_zip.vmt")
resource.AddFile("materials/ware/nonc/ware_zip.vtf")

-- Map-related Resources
resource.AddFile("materials/ware/detail.vtf")
resource.AddFile("materials/ware/ware_crate.vmt")
resource.AddFile("materials/ware/ware_crate.vtf")
resource.AddFile("materials/ware/ware_crate2.vmt")
resource.AddFile("materials/ware/ware_crate2.vtf")
resource.AddFile("materials/ware/ware_floor.vtf")
resource.AddFile("materials/ware/ware_floorred.vmt")
resource.AddFile("materials/ware/ware_wallorange.vmt")
resource.AddFile("materials/ware/ware_wallwhite.vtf")

////////////////////////////////////////////////
////////////////////////////////////////////////