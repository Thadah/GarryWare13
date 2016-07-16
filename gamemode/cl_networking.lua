////////////////////////////////////////////////
// // GarryWare Gold                          //
// by Hurricaaane (Ha3)                       //
//  and Kilburn_                              //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Usermessages and VGUI                      //
////////////////////////////////////////////////

include("modules/netstream2.lua")
include("modules/pon.lua")

gws_NextgameStart = 0
gws_NextwarmupEnd = 0
gws_NextgameEnd = 0
gws_WarmupLen = 0
gws_WareLen = 0
gws_TimeWhenGameEnds = 0
gws_TickAnnounce = 0

gws_PrecacheSequence = 0

gws_CurrentAnnouncer = 1

gws_AmbientMusic = {}
gws_AmbientMusic_dat = {}
gws_AmbientMusicIsOn = false

-- TODO DEBUG : SET TO FALSE AFTER EDITING !
gws_AtEndOfGame = false

/*
local function DecorationInfo( m )
	local origin  = m:ReadVector()
	local extrema = m:ReadVector()
	
	GAMEMODE:MapDecoration( origin, extrema )
end
usermessage.Hook( "DecorationInfo", DecorationInfo )
*/

netstream.Hook("DecorationInfo", function(data)
	GAMEMODE:MapDecoration( data[1], data[2] )
end)

/*
local function ModelList( m )
	local numberOfModels = m:ReadLong()
	local currentModelCount = #GAMEMODE.ModelPrecacheTable
	local model = ""
	
	for i=1,numberOfModels do
		table.insert( GAMEMODE.ModelPrecacheTable, m:ReadString() )
	end
	
	gws_PrecacheSequence = (gws_PrecacheSequence or 0) + 1
	
	print( "Precaching sequence #".. gws_PrecacheSequence .."." )
	for k=(currentModelCount + 1),(currentModelCount + numberOfModels) do
		model = GAMEMODE.ModelPrecacheTable[ k ]
		--print( "Precaching model " .. k .. " : " .. model )
		util.PrecacheModel( model )
	end
end
usermessage.Hook( "ModelList", ModelList )
*/

netstream.Hook("ModelList", function(data)
	local numberOfModels = data[1]
	local currentModelCount = #GAMEMODE.ModelPrecacheTable
	local model = ""
	
	for i=1,numberOfModels do
		table.insert( GAMEMODE.ModelPrecacheTable, data[2] )
	end
	
	gws_PrecacheSequence = (gws_PrecacheSequence or 0) + 1
	
	print( "Precaching sequence #".. gws_PrecacheSequence .."." )
	for k=(currentModelCount + 1),(currentModelCount + numberOfModels) do
		model = GAMEMODE.ModelPrecacheTable[ k ]
		--print( "Precaching model " .. k .. " : " .. model )
		util.PrecacheModel( model )
	end
end)

/*
local function GameStartTime( m )
	gws_NextgameStart = m:ReadLong()
end
usermessage.Hook( "GameStartTime", GameStartTime )
*/

netstream.Hook("GameStartTime", function(data)
	gws_NextgameStart = data
end)

/*
local function ServerJoinInfo( m )
	local didnotbegin = false

	gws_TimeWhenGameEnds = m:ReadFloat()
	didnotbegin = m:ReadBool()
	
	if didnotbegin == true then
		WaitShow()
	end
	print("Game ends on time : "..gws_TimeWhenGameEnds)
end
usermessage.Hook( "ServerJoinInfo", ServerJoinInfo )
*/

netstream.Hook("ServerJoinInfo", function(data)
	local didnotbegin = false

	gws_TimeWhenGameEnds = data[1]
	didnotbegin = data[2]
	
	if didnotbegin == true then
		netstream.Start("WaitShow")
	end
	print("Game ends on time : "..gws_TimeWhenGameEnds)
end)

local function EnableMusicVolume()
	if gws_AmbientMusicIsOn then
		gws_AmbientMusic[1]:ChangeVolume( 0.7, GAMEMODE:GetSpeedPercent() )
		
	end
end

local function EnableMusic()	
	if gws_AmbientMusicIsOn then
		for k, music in pairs( gws_AmbientMusic ) do
			music:Stop()
			gws_AmbientMusic_dat[k]._IsPlaying = false
			
		end
		
		gws_AmbientMusic[1]:Play()
		gws_AmbientMusic_dat[1]._IsPlaying = true
		gws_AmbientMusic[1]:ChangeVolume( 0.1, GAMEMODE:GetSpeedPercent() )
		gws_AmbientMusic[1]:ChangePitch( GAMEMODE:GetSpeedPercent(), 1 )
		timer.Simple( GAMEMODE.WADAT.StartFlourishLength * 0.7 , EnableMusicVolume )
		
		
	end
	
end


local function DisableMusic()
	if !gws_AmbientMusicIsOn then
		for k, music in pairs( gws_AmbientMusic ) do
			if gws_AmbientMusic_dat[k]._IsPlaying then
				music:ChangeVolume( 0.1, GAMEMODE:GetSpeedPercent() )
				
			else
				music:Stop()
				
			end
			
		end
		
	end
end

local function PlayEnding( musicID )
	local dataRef = GAMEMODE.WADAT.GlobalWareningEpic[1]
	
	LocalPlayer():EmitSound( GAMEMODE.WASND[10][2][2], 60, GAMEMODE:GetSpeedPercent() )
	gws_AmbientMusicIsOn = true
	
	for k, music in pairs( gws_AmbientMusic ) do
		music:Stop()
		gws_AmbientMusic_dat[k]._IsPlaying = false
		
	end
	
	timer.Simple( dataRef.Length, EnableMusic)
end

/*
local function NextGameTimes( m )
	gws_NextwarmupEnd = m:ReadFloat()
	gws_NextgameEnd   = m:ReadFloat()
	gws_WarmupLen     = m:ReadFloat()
	gws_WareLen       = m:ReadFloat()
	local bShouldKeepAnnounce = m:ReadBool()
	local bShouldPlayMusic = m:ReadBool()
	
	if  !bShouldKeepAnnounce then
		gws_TickAnnounce = 5
	else
		gws_TickAnnounce = 0
	end
	
	if bShouldPlayMusic then
		local libraryID = m:ReadChar()
		local musicID = m:ReadChar()
		gws_CurrentAnnouncer = m:ReadChar()
		local loopToPlay = m:ReadChar()
		if musicID != nil then
			LocalPlayer():EmitSound( GAMEMODE.WASND[libraryID][musicID][2] , 60, GAMEMODE:GetSpeedPercent() )
			gws_AmbientMusicIsOn = true
			EnableMusic()
		end	
	end	
end
usermessage.Hook( "NextGameTimes", NextGameTimes )
*/

netstream.Hook("NextGameTimes", function(data)
	print("NS")
	gws_NextwarmupEnd = data[1]
	gws_NextgameEnd   = data[2]
	gws_WarmupLen     = data[3]
	gws_WareLen       = data[4]
	local bShouldKeepAnnounce = data[5]
	local bShouldPlayMusic = data[6]
	
	if  !bShouldKeepAnnounce then
		gws_TickAnnounce = 5
	else
		gws_TickAnnounce = 0
	end
	print("NS3")
	if bShouldPlayMusic then
		local libraryID = data[7]
		local musicID = data[8]
		gws_CurrentAnnouncer = data[9]
		local loopToPlay = data[10]
		print("NS4")
		if musicID != nil then
			print("NS5")
			LocalPlayer():EmitSound( GAMEMODE.WASND[libraryID][musicID][2] , 60, GAMEMODE:GetSpeedPercent() )
			print("NS6")
			gws_AmbientMusicIsOn = true
			EnableMusic()
			print("NS7")
		end	
	end	
end)

local function EventEndgameTrigger( m )
	local achieved = m:ReadBool()
	local musicID = m:ReadChar()
	
	gws_AmbientMusicIsOn = false
	timer.Simple( 0.5, DisableMusic )
	
	if (achieved) then
		LocalPlayer():EmitSound( GAMEMODE.WASND[3][musicID][2] , 60, GAMEMODE:GetSpeedPercent() )
	else
		LocalPlayer():EmitSound( GAMEMODE.WASND[4][musicID][2] , 60, GAMEMODE:GetSpeedPercent() )
	end
end
usermessage.Hook( "EventEndgameTrigger", EventEndgameTrigger )
/*
local function BestStreakEverBreached( m )
	GAMEMODE:SetBestStreak( m:ReadLong() )
end
usermessage.Hook( "BestStreakEverBreached", BestStreakEverBreached )
*/

netstream.Hook("BestStreakEverBreached", function(BestStreakEver)
	 GAMEMODE:SetBestStreak(BestStreakEver)
end)

/*
local function EventEveryoneState( m )
	local achieved = m:ReadBool()

	if (achieved) then
		LocalPlayer():EmitSound( GAMEMODE.WASND[10][7][2], 100, GAMEMODE:GetSpeedPercent() )
	else
		LocalPlayer():EmitSound( GAMEMODE.WASND[10][8][2], 100, GAMEMODE:GetSpeedPercent() )
	end
end
*/
netstream.Hook( "EventEveryoneState", function(data)
	local achieved = data

	if (achieved) then
		LocalPlayer():EmitSound( GAMEMODE.WASND[10][7][2], 100, GAMEMODE:GetSpeedPercent() )
	else
		LocalPlayer():EmitSound( GAMEMODE.WASND[10][8][2], 100, GAMEMODE:GetSpeedPercent() )
	end
end)

/*
local function PlayerTeleported( m )
	if  !m:ReadBool() then
		local musicID = m:ReadChar()
		LocalPlayer():EmitSound( GAMEMODE.WASND[5][math.Clamp(musicID, 1, 2)][2] , 60, GAMEMODE:GetSpeedPercent() )
	end
	LocalPlayer():EmitSound(GAMEMODE.WASND[5][math.random(3,5)][2], 40, GAMEMODE:GetSpeedPercent() )
end
usermessage.Hook( "PlayerTeleported", PlayerTeleported )
*/

netstream.Hook("PlayerTeleported", function(data)
	local bool = data[1] or false
	if  !bool then
		local musicID = data[2]
		LocalPlayer():EmitSound( GAMEMODE.WASND[5][math.Clamp(musicID, 1, 2)][2] , 60, GAMEMODE:GetSpeedPercent() )
	end
	LocalPlayer():EmitSound(GAMEMODE.WASND[5][math.random(3,5)][2], 40, GAMEMODE:GetSpeedPercent() )
end)



/*
local function EntityTextChangeColor( m )
	local target = m:ReadEntity()
	local r,g,b,a = m:ReadChar() + 128, m:ReadChar() + 128, m:ReadChar() + 128, m:ReadChar() + 128
	
	if IsValid(target) and target.SetEntityColor then
		target:SetEntityColor(r,g,b,a)
	else
		timer.Simple( 0, function(target,r,g,b,a) if IsValid(target) and target.SetEntityColor then target:SetEntityColor(r,g,b,a) end end )
	end
end
usermessage.Hook( "EntityTextChangeColor", EntityTextChangeColor )
*/

netstream.Hook("EntityTextChangeColor", function(data)
	local target = data[1]
	local r,g,b,a = data[2], data[3], data[4], data[5]

	if IsValid(target) and target.SetEntityColor then
		target:SetEntityColor(r,g,b,a)
	else
		timer.Simple( 0, function(target,r,g,b,a) 
			if IsValid(target) and target.SetEntityColor then 
				target:SetEntityColor(r,g,b,a) 
			end 
		end)
	end
end)

/*----------------------------------
VGUI Includes
------------------------------------*/


local vgui_transit = vgui.RegisterFile( "derma/vgui/cl_transitscreen.lua" )
local vgui_wait = vgui.RegisterFile( "derma/vgui/cl_waitscreen.lua" )
local vgui_clock = vgui.RegisterFile( "derma/vgui/cl_clock.lua" )
local vgui_clockgame = vgui.RegisterFile( "derma/vgui/cl_clockgame.lua" )
local vgui_stupidboard = vgui.RegisterFile( "derma/garryware_vgui/cl_main.lua")
local vgui_livescoreboard = vgui.RegisterFile( "derma/garryware_vgui/cl_livescoreboard.lua")
local vgui_instructions = vgui.RegisterFile( "derma/garryware_vgui/cl_instructions.lua")
local vgui_status = vgui.RegisterFile( "derma/garryware_vgui/cl_status.lua")
local vgui_ammo = vgui.RegisterFile( "derma/garryware_vgui/cl_ammo.lua")
local vgui_awards = vgui.RegisterFile( "derma/garryware_vgui/cl_awards.lua")

local TransitVGUI = vgui.CreateFromTable( vgui_transit )
local WaitVGUI = vgui.CreateFromTable( vgui_wait )
local ClockVGUI = vgui.CreateFromTable( vgui_clock )
local ClockGameVGUI = vgui.CreateFromTable( vgui_clockgame )
local StupidBoardVGUI = vgui.CreateFromTable( vgui_stupidboard )
local LiveScoreBoardVGUI = vgui.CreateFromTable( vgui_livescoreboard )
local InstructionsVGUI = vgui.CreateFromTable( vgui_instructions )
local StatusVGUI = vgui.CreateFromTable( vgui_status )
local AmmoVGUI = vgui.CreateFromTable( vgui_ammo )
local AwardVGUI = vgui.CreateFromTable( vgui_awards )

local function ForceRefreshVGUI()
	LiveScoreBoardVGUI:LabelRefresh( true )
end
concommand.Add("ware_forcerefresh_vgui", ForceRefreshVGUI)

function GM:ScoreboardShow()
	if  !gws_AtEndOfGame then
		--GAMEMODE:GetScoreboard():SetVisible( true )
		--GAMEMODE:PositionScoreboard( GAMEMODE:GetScoreboard() )
		LiveScoreBoardVGUI:UseSecondarySort()
		
	else
		AwardVGUI:Show()
		
	end
	
end

function GM:ScoreboardHide()
	if  !gws_AtEndOfGame then
		--GAMEMODE:GetScoreboard():SetVisible( false )
		--GAMEMODE:PositionScoreboard( GAMEMODE:GetScoreboard() )
		LiveScoreBoardVGUI:UseNormalSort()
		
	else
		AwardVGUI:Hide()
		
	end
	
end

StupidBoardVGUI:Show()
LiveScoreBoardVGUI:Show()
AmmoVGUI:Show()

local tWinEvalutaion = {
{5, "Epic FAIL"}, -- --> 0 to 5
{11, "Massive FAIL"},
{16, "Huge fail"},
{31, "Fail"},
{46, "Okay"}, ---
{65, "Success"},
{80, "Huge success"},
{95, "Massive WIN"},
{100, "Epic WIN"}
}

local function EvaluateFailure( iPercent )
	local iPos = 1
	while (iPos < #tWinEvalutaion) and ( iPercent > tWinEvalutaion[iPos][1] ) do
		iPos = iPos + 1
	end
	return tWinEvalutaion[iPos][2]
end
/*
local function Transit( m )
	if m then
		local theoWinFailNum = tonumber( m:ReadChar() )
		TransitVGUI:SetSubtitle("Server Fail-o-meter : " .. tostring( 100 - theoWinFailNum ) .. "% ... " .. EvaluateFailure( theoWinFailNum ) .. "!"  )
		
		local fWinFailBlend = theoWinFailNum / 100
		fWinFailBlend = math.Clamp((fWinFailBlend - 0.5) * 1.5 + 0.5, 0, 1)
		TransitVGUI:SetBlend( fWinFailBlend )
		
	end
	
	TransitVGUI:Show()
	RunConsoleCommand("r_cleardecals")
	
	timer.Simple( 2.7, function() TransitVGUI:Hide() end )
end
usermessage.Hook( "Transit", Transit )
*/
netstream.Hook("Transit", function(data)
	if data then
		local theoWinFailNum = tonumber(data)
		TransitVGUI:SetSubtitle("Server Fail-o-meter : " .. tostring( 100 - theoWinFailNum ) .. "% ... " .. EvaluateFailure( theoWinFailNum ) .. "!"  )
		
		local fWinFailBlend = theoWinFailNum / 100
		fWinFailBlend = math.Clamp((fWinFailBlend - 0.5) * 1.5 + 0.5, 0, 1)
		TransitVGUI:SetBlend( fWinFailBlend )
		
	end
	
	TransitVGUI:Show()
	RunConsoleCommand("r_cleardecals")
	
	timer.Simple( 2.7, function() TransitVGUI:Hide() end )
end)

/*
function WaitShow( m ) --used in ServerJoinInfo
	WaitVGUI:Show()
end
usermessage.Hook( "WaitShow", WaitShow )
*/

netstream.Hook("WaitShow", function()
	WaitVGUI:Show()
end)

/*
local function WaitHide( m )
	WaitVGUI:Hide()
end
usermessage.Hook( "WaitHide", WaitHide )
*/

netstream.Hook("WaitHide", function()
	WaitVGUI:Hide()
end)

netstream.Hook("EndOfGamemode", function()
	ClockVGUI:Hide()
	ClockGameVGUI:Hide()
	StupidBoardVGUI:Hide()
	LiveScoreBoardVGUI:Hide()
	AmmoVGUI:Show()
	
	AwardVGUI:Show()
	AwardVGUI:PerformScoreData()
	
	GAMEMODE:GetScoreboard():SetVisible( false )
	
	gws_AtEndOfGame = true
	
	--timer.Simple( GAMEMODE.WADAT.EpilogueFlourishDelayAfterEndOfGamemode, PlayEnding, 2 )
end)

/*
local function EndOfGamemode( m )
	ClockVGUI:Hide()
	ClockGameVGUI:Hide()
	StupidBoardVGUI:Hide()
	LiveScoreBoardVGUI:Hide()
	AmmoVGUI:Show()
	
	AwardVGUI:Show()
	AwardVGUI:PerformScoreData()
	
	GAMEMODE:GetScoreboard():SetVisible( false )
	
	gws_AtEndOfGame = true
	
	--timer.Simple( GAMEMODE.WADAT.EpilogueFlourishDelayAfterEndOfGamemode, PlayEnding, 2 )
end
usermessage.Hook( "EndOfGamemode", EndOfGamemode )
*/

/*
local function SpecialFlourish( m )
	local musicID = m:ReadChar()
	local dataRef = GAMEMODE.WADAT.GlobalWareningEpic[musicID]
	timer.Simple( dataRef.StartDelay + dataRef.MusicFadeDelay, function() gws_AmbientMusic[1]:ChangeVolume( 0.0, GAMEMODE:GetSpeedPercent() ) end )
	timer.Simple( dataRef.StartDelay, PlayEnding, musicID )
end
*/

netstream.Hook("SpecialFlourish", function(data)
	local musicID = data
	if musicID then
		local dataRef = GAMEMODE.WADAT.GlobalWareningEpic[musicID]
		if dataRef then
			timer.Simple( dataRef.StartDelay + dataRef.MusicFadeDelay, function() gws_AmbientMusic[1]:ChangeVolume( 0.0, GAMEMODE:GetSpeedPercent() ) end )
			timer.Simple( dataRef.StartDelay, PlayEnding, musicID )
		end
	end
end)

/*
local function HitConfirmation( m )
	LocalPlayer():EmitSound( GAMEMODE.WASND[10][4][2], GAMEMODE:GetSpeedPercent() )
end
usermessage.Hook( "HitConfirmation", HitConfirmation )
*/

netstream.Hook("HitConfirmation", function()
	LocalPlayer():EmitSound( GAMEMODE.WASND[10][4][2], GAMEMODE:GetSpeedPercent() )
end)

local function DoRagdollEffect( ply, optvectPush, optiObjNumber, iIter)
	if  !IsValid( ply ) then return end
	
	local ragdoll = ply:GetRagdollEntity()
	if ragdoll then
		local physobj = nil
		if optiObjNumber >= 0 then
			physobj = ragdoll:GetPhysicsObjectNum( optiObjNumber )
			
		else
			physobj = ragdoll:GetPhysicsObject( )
			
		end
		
		--print(ply:GetModel(), physobj:GetMass() )
		
		if physobj and physobj:IsValid() and physobj ~= NULL then
			physobj:SetVelocity( 10^6 * optvectPush )
			
		else
			timer.Simple(0, function() DoRagdollEffect( ply, optvectPush, optiObjNumber, iIter - 1) end)
		
		end
		
	else
		if iIter > 0 then
			timer.Simple(0, function() DoRagdollEffect( ply, optvectPush, optiObjNumber, iIter - 1) end)
		end
	end
	
end

/*
local function PlayerRagdollEffect( m )
	local ply = m:ReadEntity()
	local optvectPush = m:ReadVector()
	local optiObjNumber = m:ReadChar()
	
	if  !IsValid( ply ) then return end
	
	DoRagdollEffect( ply, optvectPush, optiObjNumber, 20)
end
usermessage.Hook( "PlayerRagdollEffect", PlayerRagdollEffect )
*/

netstream.Hook("PlayerRagdollEffect", function(data)
	local ply = data[1]
	local optvectPush = data[2]
	local optiObjNumber = nil
	if data[3] then
		optiObjNumber = data[3]
	else
		optiObjNumber = -1
	end
	
	if  !IsValid( ply ) then return end
	
	DoRagdollEffect( ply, optvectPush, optiObjNumber, 20)
end)

/*
local function ReceiveInstructions( usrmsg )
	local sText = usrmsg:ReadString()
	local bUseCustomBG  = usrmsg:ReadBool()
	
	local cFG_Builder = nil
	local cBG_Builder = nil
	
	if bUseCustomBG then
		local bUseCustomFG = usrmsg:ReadBool()
		
		cBG_Builder = Color(usrmsg:ReadChar() + 128, usrmsg:ReadChar() + 128, usrmsg:ReadChar() + 128, usrmsg:ReadChar() + 128)
		
		if bUseCustomFG then
			cFG_Builder = Color( usrmsg:ReadChar() + 128, usrmsg:ReadChar() + 128, usrmsg:ReadChar() + 128, usrmsg:ReadChar() + 128)
			
		end
	
	end
	InstructionsVGUI:PrepareDrawData( sText, cFG_Builder, cBG_Builder )
	
end
usermessage.Hook( "gw_instructions", ReceiveInstructions )
*/

netstream.Hook("gw_instructions", function(data)
	local sText = data[1]
	local bUseCustomBG  = data[2]
	
	local cFG_Builder = nil
	local cBG_Builder = nil
	
	if bUseCustomBG then
		local bUseCustomFG = data[3]
		
		cBG_Builder = Color(data[4], data[5], data[6], data[7])
		
		if bUseCustomFG then
			cFG_Builder = Color(data[8], data[9], data[10], data[11])
		end
	
	end
	InstructionsVGUI:PrepareDrawData( sText, cFG_Builder, cBG_Builder )
end)
	
local cStatusBackWinColorSet  = Color(0, 164, 237,192)
local cStatusBackLoseColorSet = Color(255,  87,  87,192)
local cStatusTextColorSet = Color(255,255,255,255)

local tWinParticles = {
	{"effects/yellowflare.vtf",35,2,ScrW()*0,ScrH(),20,20,50,70,-45,-60,60,64,256,Color(0, 164, 237,255),Color(0, 164, 237,0),5,1},
	{"effects/yellowflare.vtf",5,2,ScrW()*0,ScrH(),10,10,20,30,-45,-60,60,256,512,Color(255,255,255,255),Color(255,255,255,0),10,1},
	{"icon16/tick.png",5,2,ScrW()*0,ScrH(),16,16,32,32,-45,-60,60,64,128,Color(255,255,255,255),Color(255,255,255,0),0,0.2}
}
local tFailParticles = {
	{"effects/yellowflare.vtf",35,2,ScrW()*0,ScrH(),20,20,50,70,-45,-60,60,64,256,Color(255,87,87,255),Color(255,87,87,0),5,1},
	{"effects/yellowflare.vtf",5,2,ScrW()*0,ScrH(),10,10,20,30,-45,-60,60,256,512,Color(255,255,255,255),Color(255,255,255,0),10,1},
	{"icon16/cross.png",5,2,ScrW()*0,ScrH(),16,16,32,32,-45,-60,60,64,128,Color(255,255,255,255),Color(255,255,255,0),0,0.2}
}

local function MakeParticlesFromTable( myTablePtr )
	for k,particle in pairs(myTablePtr) do
		GAMEMODE:OnScreenParticlesMake(particle)
	end
	
end
/*
local function ReceiveStatuses( usrmsg )	
	local sText = ""
	
	local yourStatus = usrmsg:ReadBool() or false
	local isServerGlobal = usrmsg:ReadBool() or false
	
	if !isServerGlobal then
		sText = ((yourStatus and "Success!") or "Failure!") -- MaxOfS2D you fail
		if yourStatus then
			LocalPlayer():EmitSound( table.Random(GAMEMODE.WASND[8])[2], 100, GAMEMODE:GetSpeedPercent() )
		
			MakeParticlesFromTable( tWinParticles )
			
		else
			LocalPlayer():EmitSound( table.Random(GAMEMODE.WASND[9])[2], 100, GAMEMODE:GetSpeedPercent() )
		
			MakeParticlesFromTable( tFailParticles )
		end
		
	else
		sText = ((yourStatus and "Everyone won!") or "Everyone failed!")
		
	end

	local colorSelect = yourStatus and cStatusBackWinColorSet or cStatusBackLoseColorSet

	StatusVGUI:PrepareDrawData( sText, nil, colorSelect, 3.0 )
end
usermessage.Hook( "gw_yourstatus", ReceiveStatuses )
*/
netstream.Hook("gw_yourstatus", function(data)
	local sText = ""
	
	local yourStatus = data[1] or false
	local isServerGlobal = data[2] or false
	
	if !isServerGlobal then
		sText = ((yourStatus and "Success!") or "Failure!") -- MaxOfS2D you fail
		if yourStatus then
			LocalPlayer():EmitSound( table.Random(GAMEMODE.WASND[8])[2], 100, GAMEMODE:GetSpeedPercent() )
		
			MakeParticlesFromTable( tWinParticles )
		else
			LocalPlayer():EmitSound( table.Random(GAMEMODE.WASND[9])[2], 100, GAMEMODE:GetSpeedPercent() )
		
			MakeParticlesFromTable( tFailParticles )
		end
		
	else
		sText = ((yourStatus and "Everyone won!") or "Everyone failed!")
		
	end

	local colorSelect = yourStatus and cStatusBackWinColorSet or cStatusBackLoseColorSet

	StatusVGUI:PrepareDrawData( sText, nil, colorSelect, 3.0 )

	print("gw_yourstatus NetStream sent correctly")
end)

/*
local function ReceiveSpecialStatuses( usrmsg )	
	local specialStatus = usrmsg:ReadChar() or 0
	local positive = false
	
	local sText = ""
	
	if specialStatus == 1 then
		positive = true
		
		sText = "Done!"
		LocalPlayer():EmitSound( table.Random(GAMEMODE.WASND[8])[2], 100, GAMEMODE:GetSpeedPercent() )
		
	end

	local colorSelect = positive and cStatusBackWinColorSet or cStatusBackLoseColorSet

	StatusVGUI:PrepareDrawData( sText, nil, colorSelect, 1.0 )
end
usermessage.Hook( "gw_specialstatus", ReceiveSpecialStatuses )
*/

netstream.Hook("gw_specialstatus", function(data)
	local specialStatus = data or 0
	local positive = false
	
	local sText = ""
	
	if specialStatus == 1 then
		positive = true
		
		sText = "Done!"
		LocalPlayer():EmitSound( table.Random(GAMEMODE.WASND[8])[2], 100, GAMEMODE:GetSpeedPercent() )
		
	end

	local colorSelect = positive and cStatusBackWinColorSet or cStatusBackLoseColorSet

	StatusVGUI:PrepareDrawData( sText, nil, colorSelect, 1.0 )
end)
