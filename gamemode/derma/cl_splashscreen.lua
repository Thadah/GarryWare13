////////////////////////////////////////////////
// // GarryWare Gold                          //
// by Hurricaaane (Ha3)                       //
//  and Kilburn_                              //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// FILEOVERRIDE Splash Screen                 //
////////////////////////////////////////////////

local PANEL = {}

/*---------------------------------------------------------
   Init
---------------------------------------------------------*/
function PANEL:Init()

	self:SetText( "" )
	self.DoClick = function() RunConsoleCommand( "seensplash" ) self:Remove() end
	self:SetSkin( GAMEMODE.HudSkin )

	self.lblGamemodeName = vgui.Create( "DImage", self )  
	self.lblGamemodeName:SetImage( "vgui/ware/garryware_logo" )
		
	self.lblGamemodeAuthor = vgui.Create( "DLabel", self )
		self.lblGamemodeAuthor:SetText( GAMEMODE.Author )
		self.lblGamemodeAuthor:SetFont( "FRETTA_MEDIUM" )
		self.lblGamemodeAuthor:SetColor( color_white )
		
	self.lblServerName = vgui.Create( "DLabel", self )
		self.lblServerName:SetText( GetHostName() )
		self.lblServerName:SetFont( "FRETTA_MEDIUM" )
		self.lblServerName:SetColor( color_white )
		
	self.lblIP = vgui.Create( "DLabel", self )
		self.lblIP:SetText( "0.0.0.0" )
		self.lblIP:SetFont( "FRETTA_MEDIUM" )
		self.lblIP:SetColor( color_white )
		
	
	self:PerformLayout()
	
	self.FadeInTime = RealTime()
	
end

/*---------------------------------------------------------
   PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	self:SetSize( ScrW(), ScrH() )
	
	local CenterY = ScrH() / 2.0
	
	self.lblGamemodeName:SizeToContents()
	self.lblGamemodeName:SetPos( ScrW()/2 - self.lblGamemodeName:GetWide()/2, 10 )
	
	self.lblGamemodeAuthor:SizeToContents()
	self.lblGamemodeAuthor:SetPos( ScrW()/2 - self.lblGamemodeAuthor:GetWide()/2, 10 + self.lblGamemodeName:GetTall() * 0.5 )
	
	self.lblServerName:SizeToContents()
	self.lblServerName:SetPos( 100, CenterY + 200 )
	
	self.lblIP:SetText( GetConVarString( "ip" )  )
	self.lblIP:SizeToContents()
	self.lblIP:SetPos( self:GetWide() - 100 - self.lblIP:GetWide(), CenterY + 200 )
	
end

/*---------------------------------------------------------
   Paint
---------------------------------------------------------*/
function PANEL:Paint()

	Derma_DrawBackgroundBlur( self )
	
	local Fade = RealTime() - self.FadeInTime
	if ( Fade < 3 ) then
	
		Fade = 1- (Fade / 3)
		surface.SetDrawColor( 0,0, 0, Fade * 255 )
		surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	
	end
	
	
	local CenterY = ScrH() / 2.0
	
	surface.SetDrawColor( 0, 0, 0, 200 )
	surface.DrawRect( 0, 0, self:GetWide(), CenterY - 180 )
	
	surface.DrawRect( 0, CenterY + 180, self:GetWide(), self:GetTall() - ( CenterY+ 180 ) )
	
	GAMEMODE:PaintSplashScreen( self:GetWide(), self:GetTall() )

end

local vgui_Splash = vgui.RegisterTable( PANEL, "DButton" )

function GM:ShowSplash()

	local pnl = vgui.CreateFromTable( vgui_Splash )
	pnl:MakePopup()

end


function GM:PaintSplashScreen( w, h )
	-- Customised splashscreen render here ( The center bit! )

end
