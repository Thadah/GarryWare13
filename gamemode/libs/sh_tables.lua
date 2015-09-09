//////////////////////////////////////////////////////
// GarryWare Reloaded                      			//
// by Hurricaaane (Ha3), modified vastly by Cyumus 	//
// http://www.youtube.com/user/Hurricaaane    		//
// https://www.youtube.com/c/CyumusAduni			//
//--------------------------------------------------//
// Shared Tables                              		//
//////////////////////////////////////////////////////

GM.WADAT = {}
GM.WADAT.EndFlourishTime = 2.50
GM.WADAT.StartFlourishLength = 2.50
GM.WADAT.TransitFlourishTime = 1.3

GM.WADAT.GlobalWareningEpic = 
{
	// Prologue Data
	{
		MusicFadeDelay = 0.4,
		StartDelay = 2.0,
		Length = 10.24
	},
	// Epilogue Data
	{
		MusicFadeDelay = 0.0,
		StartDelay = 2.0,
		Length = 20.10
	}
}

// Epilogue flourish delay after end of gamemode
GM.WADAT.EpiFlourishDelay = 2.26

GM.WASND = 
{
	// 1. Ambient Sound
	{
		{"Loop1", Sound("ware/exp_loop_1.wav")},
		{"Loop2", Sound("ware/exp_loop_2.wav")}
	},
	// 2. Phase Sound
	{
		{"GamePhase1", Sound("ware/exp_game_new_1.mp3")},
		{"GamePhase2", Sound("ware/exp_game_new_2.mp3")},
		{"GamePhase3", Sound("ware/exp_game_new_3.mp3")},
		{"GamePhase4", Sound("ware/exp_game_new_4.mp3")},
		{"GamePhase5", Sound("ware/exp_game_new_5.mp3")}
	},
	// 3. Win Sound
	{
		{"GameWin1", Sound("ware/exp_game_win_1.mp3")},
		{"GameWin2", Sound("ware/exp_game_win_2.mp3")},
		{"GameWin3", Sound("ware/exp_game_win_3.mp3")}
	},
	// 4. Lose Sound
	{
		{"GameLose1", Sound("ware/exp_game_lose_1.mp3")},
		{"GameLose2", Sound("ware/exp_game_lose_2.mp3")},
		{"GameLose3", Sound("ware/exp_game_lose_3.mp3")}
	},
	// 5. Teleport Sound
	{
		{"Tele1", Sound("ware/exp_game_transit_1.mp3")},
		{"Tele2", Sound("ware/exp_game_transit_2.mp3")},
		{"Tele3", Sound("ambient/machines/teleport1.wav")},
		{"Tele4", Sound("ambient/machines/teleport3.wav")},
		{"Tele5", Sound("ambient/machines/teleport4.wav")}
	},
	// 6. Countdown Sound
	{
		// Ann Sound
		{"Ann1", Sound("ware/countdown_ann_sec1.mp3")},
		{"Ann2", Sound("ware/countdown_ann_sec2.mp3")},
		{"Ann3", Sound("ware/countdown_ann_sec3.mp3")},
		{"Ann4", Sound("ware/countdown_ann_sec4.mp3")},
		{"Ann5", Sound("ware/countdown_ann_sec5.mp3")},
		// Dos Sound
		{"Dos1", Sound("ware/countdown_ann_sec1.mp3")},
		{"Dos2", Sound("ware/countdown_ann_sec2.mp3")},
		{"Dos3", Sound("ware/countdown_ann_sec3.mp3")},
		{"Dos4", Sound("ware/countdown_ann_sec4.mp3")},
		{"Dos5", Sound("ware/countdown_ann_sec5.mp3")}		
	},
	// 7. Tick Sound
	{
		{"TickHigh", Sound("ware/countdown_tick_high.wav")},
		{"TickLow", Sound("ware/countdown_tick_low.wav")}		
	},
	// 8. Clientside Win Sound
	{
		{"CliWin1", Sound("ware/local_exo_won1.wav")},
		{"CliWin2", Sound("ware/local_exo_won2.wav")},
		{"CliWin3", Sound("ware/local_exo_won3.wav")}
	},
	// 9. Clientside Lose Sound
	{
		{"CliLose1", Sound("ware/local_lose2.wav")},
		{"CliLose2", Sound("ware/local_lose3.wav")},
		{"CliLose3", Sound("ware/local_lose4.wav")},
	},
	// 10. Misc Sound
	{
		{"Info", Sound("ware/game_information.mp3")},
		{"Prologue", Sound("ware/game_prologue.mp3")},
		{"Epilogue", Sound("ware/game_epilogue.mp3")},
		{"TargetHit", Sound("ware/local_exo_target_hit.wav")},
		{"CliOtherWin", Sound("ware/other_exo_won1.wav")},
		{"CliOtherLose", Sound("ware/other_lose1.wav")},
		{"EveryoneWin", Sound("ware/everyone_won3.wav")},
		{"EveryoneLose", Sound("ware/everyone_lose2.wav")}
	},
}

GM.WACOLS = {}
GM.WACOLS["unknown"]  = Color(255,255,255,255)
GM.WACOLS["topic"]    = Color(220,210,92,255)
GM.WACOLS["link"]     = Color(255,255,255,255)
GM.WACOLS["info"]     = Color(170,255,170,255)
GM.WACOLS["dom_outline"] = Color(0,0,0,255)
GM.WACOLS["dom_text"]    = Color(255,255,255,255)

GM.WareEnts = {}

GM.ColorTable = {
	{ "black"		, Color(0,0,0,255) 		    , "twirl"	 },
	{ "grey"		, Color(138,138,138,255)	, "cross" 	 },
	{ "white"		, Color(255,255,255,255)	, "triangle" },
	{ "red"			, Color(220,0,0,255)		, "square"   },
	{ "green"		, Color(0,220,0,255)		, "circle"	 },
	{ "blue"		, Color(64,64,255,255)		, "star" 	 },
	{ "pink"		, Color(255,0,255,255)		, "flower"	 }
}

G_GWI_SKIN = "ware"

ENTS_ONCRATE = "oncrate"
ENTS_OVERCRATE = "overcrate"
ENTS_INAIR = "inair"
ENTS_CROSS = "cross"


DTVAR_PLAYER_ACHIEVED_INT  = 0
DTVAR_PLAYER_LOCKED_INT    = 1
DTVAR_PLAYER_COMBO_INT     = 2
DTVAR_PLAYER_BESTCOMBO_INT = 3


AWARD_IQ_WIN    = "iq_win"
AWARD_IQ_FAIL   = "iq_fail"
AWARD_REFLEX    = "reflex"
AWARD_MOVES     = "moves"
AWARD_FRENZY    = "frenzy"
AWARD_AIM       = "aim"
AWARD_VICTIM    = "victim"


if false then
	GAMEMODE:EnableFirstWinAward( )
	GAMEMODE:EnableFirstFailAward( )
	GAMEMODE:SetWinAwards( AWARD_FRENZY )
	GAMEMODE:SetFailAwards( AWARD_VICTIM )
	

	GAMEMODE:EnableFirstWinAward( )
	GAMEMODE:SetWinAwards( AWARD_IQ_WIN )
	GAMEMODE:SetFailAwards( AWARD_IQ_FAIL )
	
end






