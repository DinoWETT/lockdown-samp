#pragma option -d3
/**
TODO:
 */

#define YSI_YES_HEAP_MALLOC

#define CGEN_MEMORY 60000

#include <a_samp>
#include <ysilib\YSI_Coding\y_hooks>
#include <ysilib\YSI_Core\y_utils.inc>
#include <ysilib\YSI_Storage\y_ini>
#include <ysilib\YSI_Coding\y_timers>
#include <ysilib\YSI_Visual\y_commands>
#include <ysilib\YSI_Data\y_foreach>
#include <ysilib\YSI_Data\y_iterate>
#include <sscanf2>
#include <streamer>
#include <mapfix>
#include <easyDialog>
#include <formatex>
#include <distance>

#define     c_server        "{0099ff}"
#define     c_red           "{ff1100}"
#define     c_blue          "{0099cc}"
#define     c_white         "{ffffff}"
#define     c_yellow        "{f2ff00}"
#define     c_green         "{009933}"
#define     c_pink          "{ff00bb}"
#define     c_ltblue        "{00f2ff}"
#define     c_orange        "{ffa200}"
#define     c_greey         "{787878}"

#define     x_server     0x0099FFFF
#define     x_red        0xFF1100FF
#define     x_blue       0x0099CCFF
#define     x_white      0xffffffFF
#define     x_yellow     0xf2ff00FF
#define     x_green      0x009933FF
#define     x_pink       0xff00bbFF
#define     x_ltblue     0x00f2ffFF
#define     x_orange     0xffa200FF
#define     x_greey      0x787878FF
#define     x_purple     0xC2A2DAAA

static stock const USER_PATH[64] = "/Users/%s.ini";

const MAX_PASSWORD_LENGTH = 64;
const MIN_PASSWORD_LENGTH = 6;
const MAX_LOGIN_ATTEMPTS = 	3;
const MAX_NAME_LENGTH = 20;

enum
{
	e_SPAWN_TYPE_REGISTER = 1,
    e_SPAWN_TYPE_LOGIN
};

static  
    player_Password[MAX_PLAYERS][MAX_PASSWORD_LENGTH],
    player_Sex[MAX_PLAYERS][2],
	player_Name[MAX_PLAYERS][MAX_NAME_LENGTH],
	player_Lastname[MAX_PLAYERS][MAX_NAME_LENGTH],
    player_Score[MAX_PLAYERS],
	player_Skin[MAX_PLAYERS],
    player_Money[MAX_PLAYERS],
    player_Ages[MAX_PLAYERS],
    player_LoginAttempts[MAX_PLAYERS],
	player_Staff[MAX_PLAYERS],
	player_Wanted[MAX_PLAYERS];

new stfveh[MAX_PLAYERS] = { INVALID_VEHICLE_ID, ... };

forward Account_Load(const playerid, const string: name[], const string: value[]);
public Account_Load(const playerid, const string: name[], const string: value[])
{
	INI_String("Password", player_Password[playerid]);
	INI_String("Sex", player_Sex[playerid]);
	INI_String("Name", player_Name[playerid]);
	INI_String("Lastname", player_Lastname[playerid]);
	INI_Int("Level", player_Score[playerid]);
	INI_Int("Skin", player_Skin[playerid]);
	INI_Int("Money", player_Money[playerid]);
	INI_Int("Staff", player_Staff[playerid]);
	INI_Int("Wanted", player_Wanted[playerid]);

	return 1;
}

new Float:camera_Locations[][3] = {

    {-2204.0217,-2309.4954,31.3750  }, // Bolnica
    { -2169.8269,-2319.3391,30.6325 }, // Prodavnica
    { -2165.7629,-2416.6877,30.8280 }  // Market
};

main()
{
    print("-                                     -");
	print(" Founder : realnaith");
	print(" Version : 1.0 - Stories of Angels");
	print(" Credits : realnaith, ");
	print("-                                     -");
	print("> Gamemode Starting...");
	print(">> Lockdown Gamemode Started");
    print("-                                     -");
}

#define PRESSED(%0) \
    ( newkeys & %0 == %0 && oldkeys & %0 != %0 )

public OnGameModeInit()
{
	DisableInteriorEnterExits();
	ManualVehicleEngineAndLights();
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
	SetNameTagDrawDistance(20.0);
	DisableNameTagLOS();
	LimitGlobalChatRadius(20.0);
	AllowInteriorWeapons(1);
	EnableVehicleFriendlyFire();
	EnableStuntBonusForAll(0);


	AddStaticPickup(19198, 0, -2093.6514,-2464.9531, 30.2250, 0);
 	Create3DTextLabel("AMMU-NATION", x_white, -2093.6514,-2464.9531,30.6250, 20, 0);

	AddStaticPickup(19198, 0, 2165.7629,-2416.6877,30.2280, 0);
 	Create3DTextLabel("BANK", x_white, 2165.7629,-2416.6877,30.8280, 20, 0);

	AddStaticPickup(19198, 0, -2148.5681,-2394.9456,30.2188, 0);
 	Create3DTextLabel("SHERIFF", x_white, -2148.5681,-2394.9456,30.7188, 20, 0);

	AddStaticPickup(19198, 0, -2161.3284,-2384.7927,30.2969, 0);
 	Create3DTextLabel("SHERIFF GARAGE", x_white, -2161.3284,-2384.7927,30.8969, 20, 0);

	AddStaticPickup(19198, 0, -1566.5302,-2730.2683,48.2435, 0);
 	Create3DTextLabel("DEALERSHIP", x_white, -1566.5302,-2730.2683,48.7435, 20, 0);

	AddStaticPickup(19198, 0, -2169.8269,-2319.3391,30.2325, 0);
 	Create3DTextLabel("SHOP", x_white, -2169.8269,-2319.3391,30.6325, 20, 0);

	AddStaticPickup(19198, 0, -2204.0217,-2309.4954,30.9750, 0);
 	Create3DTextLabel("MEDICAL CENTRE", x_white, -2204.0217,-2309.4954,31.3750, 20, 0);

	return 1;
}

public OnGameModeExit()
{
	
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{

	return 1;
}

public OnPlayerConnect(playerid)
{
	TogglePlayerSpectating(playerid, 0);
	SetPlayerColor(playerid, x_white);

	if (fexist(Account_Path(playerid)))
	{
		INI_ParseFile(Account_Path(playerid), "Account_Load", true, true, playerid);
		Dialog_Show(playerid, "dialog_login", DIALOG_STYLE_PASSWORD,
			"Prijavljivanje",
			"%s, unesite Vasu tacnu lozinku: ",
			"Potvrdi", "Izlaz", ReturnPlayerName(playerid)
		);

		return 1;
	}

	Dialog_Show(playerid, "dialog_regpassword", DIALOG_STYLE_INPUT,
		"Registracija",
		"%s, unesite Vasu zeljenu lozinku: ",
		"Potvrdi", "Izlaz", ReturnPlayerName(playerid)
	);

	stfveh[playerid] = INVALID_VEHICLE_ID;

	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	new INI:File = INI_Open(Account_Path(playerid));
    INI_SetTag(File,"data");
    INI_WriteInt(File, "Level",GetPlayerScore(playerid));
    INI_WriteInt(File, "Skin",GetPlayerSkin(playerid));
    INI_WriteInt(File, "Money", GetPlayerMoney(playerid));
	INI_WriteInt(File, "Staff", player_Staff[playerid]);
    INI_WriteInt(File, "Wanted", player_Wanted[playerid]);
    INI_Close(File);

	DestroyVehicle(stfveh[playerid]);
	stfveh[playerid] = INVALID_PLAYER_ID;

	return 1;
}

public OnPlayerSpawn(playerid)
{
	SetPlayerTeam(playerid, NO_TEAM);

	if(player_Wanted[playerid] != 0) 
	{
	    SetPlayerWantedLevel(playerid, player_Wanted[playerid]);
//        PlayCrimeReportForPlayer(playerid, 0, 16);
	}

	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	DestroyVehicle(stfveh[playerid]);
	stfveh[playerid] = INVALID_PLAYER_ID;

	return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
{

    return 1;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{

    return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	if(issuerid != INVALID_PLAYER_ID && bodypart == 9)
    {
        SetPlayerHealth(playerid, 0.0);
    }

	if(player_Wanted[issuerid] == 6) return 1;
    for(new i = 0; i < sizeof camera_Locations; i++) 
	{
        if(IsPlayerInRangeOfPoint(issuerid, 40.0, camera_Locations[i][0], camera_Locations[i][1], camera_Locations[i][2])) 
		{
            player_Wanted[issuerid]++;
            SetPlayerWantedLevel(issuerid, player_Wanted[issuerid]);
//            PlayCrimeReportForPlayer(issuerid, 0, 16);

            new INI:File = INI_Open(Account_Path(issuerid));
            INI_SetTag(File,"data");
            INI_WriteInt(File, "Wanted", player_Wanted[issuerid]);
            INI_Close(File);

            break;
        }
    }

    return 1;
} 

public OnVehicleSpawn(vehicleid)
{
	new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

    if (IsVehicleBicycle(GetVehicleModel(vehicleid)))
    {
        SetVehicleParamsEx(vehicleid, 1, 0, 0, doors, bonnet, boot, objective);
    }
    else 
    {
        SetVehicleParamsEx(vehicleid, 0, 0, 0, doors, bonnet, boot, objective);
    }

	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	new veh = GetPlayerVehicleID(playerid),
            	engine,
            	lights,
            	alarm,
            	doors,
            	bonnet,
                boot,
                objective;

    GetVehicleParamsEx(veh, engine, lights, alarm, doors, bonnet, boot, objective);

	if (newstate == PLAYER_STATE_DRIVER) 
    {
        if(engine == VEHICLE_PARAMS_OFF)
        {   
            SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"Da upalite motor koristite tipku 'N'");
        }
	}

	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        if(newkeys & KEY_NO)
        {
            new veh = GetPlayerVehicleID(playerid),
                engine,
                lights,
                alarm,
                doors,
                bonnet,
                boot,
                objective;
            
            if(IsVehicleBicycle(GetVehicleModel(veh)))
            {
                return true;
            }
            
            GetVehicleParamsEx(veh, engine, lights, alarm, doors, bonnet, boot, objective);

            if(engine == VEHICLE_PARAMS_OFF)
            {
                SetVehicleParamsEx(veh, VEHICLE_PARAMS_ON, lights, alarm, doors, bonnet, boot, objective);
            }
            else
            {
                SetVehicleParamsEx(veh, VEHICLE_PARAMS_OFF, lights, alarm, doors, bonnet, boot, objective);
            }

            new str[60];
            format(str, sizeof(str),""c_server"Lockdown // "c_white"%s si motor.", (engine == VEHICLE_PARAMS_OFF) ? "Upalio" : "Ugasio");
            SendClientMessage(playerid, -1, str);

            return true;
        }
        if(newkeys & KEY_YES)
        {
            new veh = GetPlayerVehicleID(playerid),
                engine,
                lights,
                alarm,
                doors,
                bonnet,
                boot,
                objective;
            
            if(IsVehicleBicycle(GetVehicleModel(veh)))
            {
                return true;
            }
            
            GetVehicleParamsEx(veh, engine, lights, alarm, doors, bonnet, boot, objective);

            if(lights == VEHICLE_PARAMS_OFF)
            {
                SetVehicleParamsEx(veh, engine, VEHICLE_PARAMS_ON, alarm, doors, bonnet, boot, objective);
            }
            else
            {
                SetVehicleParamsEx(veh, engine, VEHICLE_PARAMS_OFF, alarm, doors, bonnet, boot, objective);
            }
            new str[60];
            format(str, sizeof(str),""c_server"Lockdown // "c_white"%s si svetla.", (lights == VEHICLE_PARAMS_OFF) ? "Upalio" : "Ugasio");
            SendClientMessage(playerid, -1, str);

            return true;
        }
    }
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

timer Spawn_Player[100](playerid, type)
{
	if (type == e_SPAWN_TYPE_REGISTER)
		{
			SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"Uspesno ste se registrovali!");
			SetSpawnInfo(playerid, 0, player_Skin[playerid],
				-2193.9375, -2256.1196, 30.6873, 151.0796,
				0, 0, 0, 0, 0, 0
			);
			SpawnPlayer(playerid);

			SetPlayerScore(playerid, player_Score[playerid]);
			GivePlayerMoney(playerid, player_Money[playerid]);
			SetPlayerSkin(playerid, player_Skin[playerid]);
		}

		else if (type == e_SPAWN_TYPE_LOGIN)
		{
			SendClientMessage(playerid, x_server,"Lockdown // "c_white"Uspesno ste se prijavli!");
			SetSpawnInfo(playerid, 0, player_Skin[playerid],
				-2193.9375, -2256.1196, 30.6873, 151.0796,
				0, 0, 0, 0, 0, 0
			);
			SpawnPlayer(playerid);

			SetPlayerScore(playerid, player_Score[playerid]);
			GivePlayerMoney(playerid, player_Money[playerid]);
			SetPlayerSkin(playerid, player_Skin[playerid]);
		}

}

Dialog: dialog_regpassword(playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return Kick(playerid);

	Dialog_Show(playerid, "dialog_regpassword", DIALOG_STYLE_INPUT,
			"Registracija",
			"%s, unesite Vasu zeljenu lozinku: ",
			"Potvrdi", "Izlaz", ReturnPlayerName(playerid)
		);

	strcopy(player_Password[playerid], inputtext);

	Dialog_Show(playerid, "dialog_regname", DIALOG_STYLE_INPUT,
		"Ime",
		"Upisite vase Ime: ",
		"Unesi", "Izlaz"
	);

	return 1;
}

Dialog: dialog_regname(playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return Kick(playerid);

	Dialog_Show(playerid, "dialog_regname", DIALOG_STYLE_INPUT,
			"Ime",
			"Upisite vase Ime: ",
			"Potvrdi", "Izlaz", ReturnPlayerName(playerid)
		);

	strcopy(player_Name[playerid], inputtext);

	Dialog_Show(playerid, "dialog_reglastname", DIALOG_STYLE_INPUT,
		"Registracija",
		"Upisite vase Prezime: ",
		"Unesi", "Izlaz"
	);

	return 1;
}

Dialog: dialog_reglastname(playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return Kick(playerid);

	Dialog_Show(playerid, "dialog_reglastname", DIALOG_STYLE_INPUT,
			"Prezime",
			"Upisite vase Prezime: ",
			"Potvrdi", "Izlaz", ReturnPlayerName(playerid)
		);

	strcopy(player_Lastname[playerid], inputtext);

	Dialog_Show(playerid, "dialog_regages", DIALOG_STYLE_INPUT,
		"Godine",
		"Koliko imate godina: ",
		"Unesi", "Izlaz"
	);

	return 1;
}

Dialog: dialog_regages(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return Kick(playerid);

	if (!(12 <= strval(inputtext) <= 50))
		return Dialog_Show(playerid, "dialog_regages", DIALOG_STYLE_INPUT,
			"Godine",
			"Koliko imate godina: ",
			"Unesi", "Izlaz"
		);

	player_Ages[playerid] = strval(inputtext);

	Dialog_Show(playerid, "dialog_regsex", DIALOG_STYLE_LIST,
	"Spol",
	"Musko\nZensko",
	"Odaberi", "Izlaz"
	);

	return 1;
}

Dialog: dialog_regsex(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return Kick(playerid);

	new tmp_int = listitem + 1;

	new INI:File = INI_Open(Account_Path(playerid));
	INI_SetTag(File,"data");
	INI_WriteString(File, "Password", player_Password[playerid]);
	INI_WriteString(File, "Name", player_Name[playerid]);
	INI_WriteString(File, "Lastname", player_Lastname[playerid]);
	INI_WriteString(File, "Sex", (tmp_int == 1 ? ("Musko") : ("Zensko")));
	INI_WriteInt(File, "Age", player_Ages[playerid]);
	INI_WriteInt(File, "Level", 0);
	INI_WriteInt(File, "Skin", 240);
	INI_WriteInt(File, "Money", 1000);
	INI_WriteInt(File, "Staff", 0);
	INI_Close(File);

	player_Money[playerid] = 1000;
	player_Skin[playerid] = 240;
	player_Score[playerid] = 0;

	defer Spawn_Player(playerid, 1);
	
	return 1;
}

Dialog: dialog_login(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return Kick(playerid);

	if (!strcmp(player_Password[playerid], inputtext, false))
		defer Spawn_Player(playerid, 2);
	else
	{
		if (player_LoginAttempts[playerid] == MAX_LOGIN_ATTEMPTS)
			return Kick(playerid);

		++player_LoginAttempts[playerid];
		Dialog_Show(playerid, "dialog_login", DIALOG_STYLE_PASSWORD,
			"Prijavljivanje",
			"%s, unesite Vasu tacnu lozinku: ",
			"Potvrdi", "Izlaz", ReturnPlayerName(playerid)
		);
	}

	return 1;
}

stock Account_Path(const playerid)
{
	new tmp_fmt[64];
	format(tmp_fmt, sizeof(tmp_fmt), USER_PATH, ReturnPlayerName(playerid));

	return tmp_fmt;
}

stock IsVehicleBicycle(m)
{
    if (m == 481 || m == 509 || m == 510) return true;
    
    return false;
}

stock GetVehicleSpeed(vehicleid)
{
	new Float:xPos[3];

	GetVehicleVelocity(vehicleid, xPos[0], xPos[1], xPos[2]);

	return floatround(floatsqroot(xPos[0] * xPos[0] + xPos[1] * xPos[1] + xPos[2] * xPos[2]) * 170.00);
}

YCMD:help(playerid, params[], help)
{
	if (help)
	{
		SendClientMessage(playerid, -1, "Use `/help <command>` to get information about the command.");
	}
	else if (IsNull(params))
	{
		SendClientMessage(playerid, -1, "Please enter a command.");
	}
	else
	{
		Command_ReProcess(playerid, params, true);
	}
	return 1;
}


YCMD:staffcmd(playerid, const string: params[], help)
{
	if(help)
    {
        SendClientMessage(playerid, x_blue, "HELP >> "c_white"Komanda koja vam prikazuje sve Staff Komande.");
        return 1;
    }

	if(!player_Staff[playerid])
		return SendClientMessage(playerid, x_red, "lockdown // "c_white"Samo staff moze ovo!");

	Dialog_Show(playerid, "dialog_staffcmd", DIALOG_STYLE_MSGBOX,
	""c_server"lockdown // "c_white"Staff Commands",
	""c_white"%s, Vi ste deo naseg "c_server"staff "c_white"tima!\n\
	"c_server"SLVL1 >> "c_white"/sduty\n\
	"c_server"SLVL1 >> "c_white"/sc\n\
	"c_server"SLVL1 >> "c_white"/staffcmd\n\
	"c_server"SLVL1 >> "c_white"/sveh\n\
	"c_server"SLVL1 >> "c_white"/goto\n\
	"c_server"SLVL1 >> "c_white"/cc\n\
	"c_server"SLVL1 >> "c_white"/fv\n\
	"c_server"SLVL2 >> "c_white"/gethere\n\
	"c_server"SLVL3 >> "c_white"/nitro\n\
	"c_server"SLVL4 >> "c_white"/jetpack\n\
	"c_server"SLVL4 >> "c_white"/setskin\n\
	"c_server"SLVL4 >> "c_white"/xgoto\n\
	"c_server"SLVL4 >> "c_white"/spanel\n\
	"c_server"SLVL4 >> "c_white"/setstaff",
	"U redu", "", ReturnPlayerName(playerid)
	);

    return 1;
}

YCMD:sc(playerid, const string: params[], help)
{
	if(help)
    {
        SendClientMessage(playerid, x_blue, "HELP >> "c_white"Komanda koja vam omogucava da pisete u Staff Chat.");
        return 1;
    }

	if (player_Staff[playerid] < 1)
		return SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"Samo staff moze ovo!");

	if (isnull(params))
		return SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"/sc [text]");

	static tmp_str[128];

	format(tmp_str, sizeof(tmp_str), "Staff - %s(%d): "c_white"%s", ReturnPlayerName(playerid), playerid, params);

	foreach (new i: Player)
		if (player_Staff[i])
			SendClientMessage(i, x_ltblue, tmp_str);
	
    return 1;
}

YCMD:sveh(playerid, params[], help)
{
	if(help)
    {
        SendClientMessage(playerid, x_blue, "HELP >> "c_white"Komanda koja vam Kreira Staff Vozilo.");
        return 1;
    }

	if (player_Staff[playerid] < 1)
		return SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"Samo staff moze ovo!");

	new Float:x, Float:y, Float:z;

	GetPlayerPos(playerid, x, y, z);

	if (stfveh[playerid] == INVALID_VEHICLE_ID) 
	{
		if (isnull(params))
			return SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"/sveh [Model ID]");

		new modelid = strval(params);

		if (400 > modelid > 611)
			return SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"* Validni modeli su od 400 do 611.");

		new vehicleid = stfveh[playerid] = CreateVehicle(modelid, x, y, z, 0.0, 1, 0, -1);

		SetVehicleNumberPlate(vehicleid, "STAFF");
		PutPlayerInVehicle(playerid, vehicleid, 0);
		
	    new engine, lights, alarm, doors, bonnet, boot, objective;
	    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

	    if (IsVehicleBicycle(GetVehicleModel(vehicleid)))
	    {
	        SetVehicleParamsEx(vehicleid, 1, 0, 0, doors, bonnet, boot, objective);
	    }
	    else
	    {
	        SetVehicleParamsEx(vehicleid, 0, 0, 0, doors, bonnet, boot, objective);
	    }
		SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"Stvorili ste vozilo, da ga unistite kucajte '/sveh'.");
	}
	else 
	{
		DestroyVehicle(stfveh[playerid]);
		stfveh[playerid] = INVALID_PLAYER_ID;
		SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"Unistili ste vozilo, da ga stvorite kucajte '/veh [Model ID]'.");
	}
	
    return 1;
}

YCMD:goto(playerid, params[],help)
{
	if(help)
    {
        SendClientMessage(playerid, x_blue, "HELP >> "c_white"Komanda koja vam omogucava da odete do odredjenog igraca.");
        return 1;
    }

	if (player_Staff[playerid] < 1)
		return SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"Samo staff moze ovo!");

	new giveplayerid, giveplayer[MAX_PLAYER_NAME];

	new Float:plx,Float:ply,Float:plz;

	GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));

	if(!sscanf(params, "u", giveplayerid))
	{	
		GetPlayerPos(giveplayerid, plx, ply, plz);
			
		if (GetPlayerState(playerid) == 2)
		{
			new tmpcar = GetPlayerVehicleID(playerid);
			SetVehiclePos(tmpcar, plx, ply+4, plz);
		}
		else
		{
			SetPlayerPos(playerid,plx,ply+2, plz);
		}
		SetPlayerInterior(playerid, GetPlayerInterior(giveplayerid));
	}
    return 1;
}

YCMD:cc(playerid, params[], help)
{
	if(help)
    {
        SendClientMessage(playerid, x_blue, "HELP >> "c_white"Komanda koja ce Ocistiti Chat svim igracima.");
        return 1;
    }

	if (player_Staff[playerid] < 1)
		return SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"Samo staff moze ovo!");

	for(new cc; cc < 110; cc++)
	{
		SendClientMessageToAll(-1, "");
	}

	if(player_Staff[playerid] < 1)
	{
		static fmt_string[120];
		format(fmt_string, sizeof(fmt_string), ""c_server"Lockdown // "c_white"chat je ocistio"c_server" %s", ReturnPlayerName(playerid));
		SendClientMessageToAll(-1, fmt_string);
	}
    return 1;
}

YCMD:fv(playerid, params[], help)
{
	if(help)
    {
        SendClientMessage(playerid, x_blue, "HELP >> "c_white"Komanda koja vam Popravlja Vozilo.");
        return 1;
    }

	if (player_Staff[playerid] < 1)
		return SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"Samo staff moze ovo!");

	new vehicleid = GetPlayerVehicleID(playerid);

	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"Niste u vozilu!");

	RepairVehicle(vehicleid);

	SetVehicleHealth(vehicleid, 999.0);

	return 1;
}

YCMD:gethere(playerid, const params[], help)
{
	if(help)
    {
        SendClientMessage(playerid, x_blue, "HELP >> "c_white"Komanda koja teleportuje igraca do vas.");
        return 1;
    }

	if (player_Staff[playerid] < 1)
		return SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"Samo staff moze ovo!");

	new targetid = INVALID_PLAYER_ID;

	if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"/gethere [id]");

	if(targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid, x_server, "Lockdown // "c_white"Taj ID nije konektovan.");

	new Float:x, Float:y, Float:z;

	GetPlayerPos(playerid, x, y, z);

	SetPlayerPos(targetid, x+1, y, z+1);

	SetPlayerInterior(targetid, GetPlayerInterior(playerid));

	SetPlayerVirtualWorld(targetid, GetPlayerVirtualWorld(playerid));

	new name[MAX_PLAYER_NAME];
	GetPlayerName(targetid, name, sizeof(name));

	static fmt_string[60];

	format(fmt_string, sizeof(fmt_string),""c_server"Lockdown // "c_white"Teleportovali ste igraca %s do sebe.", name);
	SendClientMessage(playerid, -1, fmt_string);

	GetPlayerName(playerid, name, sizeof(name));

	format(fmt_string, sizeof(fmt_string), ""c_server"Lockdown // "c_white"Staff %s vas je teleportovao do sebe.", name);
	SendClientMessage(targetid, -1, fmt_string);

    return 1;
}

YCMD:nitro(playerid, params[], help)
{
	if(help)
    {
		SendClientMessage(playerid, x_blue, "HELP >> "c_white"Komanda koja vam daje Nitro.");
        return 1;
    }

	if (player_Staff[playerid] < 1)
		return SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"Samo staff moze ovo!");

	AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);

	SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"Ugradili ste nitro u vase vozilo.");

	return 1;
}

YCMD:jetpack(playerid, params[], help)
{
	if(help)
    {
		SendClientMessage(playerid, x_blue, "HELP >> "c_white"Komanda koja vam daje Jetpack.");
        return 1;
    }

	if (player_Staff[playerid] < 1)
		return SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"Samo staff moze ovo!");

	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);

	SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"Uzeli ste Jetpack.");

	return 1;
}

YCMD:setskin(playerid, const string: params[], help)
{
	if(help)
    {
		SendClientMessage(playerid, x_blue, "HELP >> "c_white"Komanda koja vam omogucava da postavite odredjeni skin od 1 do 311.");
        return 1;
    }

	if (player_Staff[playerid] < 1)
		return SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"Samo staff moze ovo!");

	static
		targetid,
		skinid;

	if (sscanf(params, "ri", targetid, skinid))
		return SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"/setskin [targetid] [skinid]");

	if (!(1 <= skinid <= 311))
		return SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"Pogresan ID skina!");

	if (GetPlayerSkin(targetid) == skinid)
		return SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"Taj igrac vec ima taj skin!");

	SetPlayerSkin(targetid, skinid);

	player_Skin[targetid] = skinid;

    new INI:File = INI_Open(Account_Path(playerid));
	INI_SetTag( File, "data" );
    INI_WriteInt(File, "Skin", GetPlayerSkin(playerid));
	INI_Close( File );

    return 1;
}

YCMD:xgoto(playerid, params[], help)
{
	if(help)
    {
		SendClientMessage(playerid, x_blue, "HELP >> "c_white"Komanda koja vam pruza mogucnost teleportiranja na odredjene koordinate.");
        return 1;
    }

	if (player_Staff[playerid] < 1)
		return SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"Samo staff moze ovo!");

	new Float:x, Float:y, Float:z;

	static fmt_string[100];

	if (sscanf(params, "fff", x, y, z)) SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"xgoto <X Float> <Y Float> <Z Float>");
	else
	{
		if(IsPlayerInAnyVehicle(playerid))
		{
		    SetVehiclePos(GetPlayerVehicleID(playerid), x,y,z);
		}
		else
		{
		    SetPlayerPos(playerid, x, y, z);
		}
		format(fmt_string, sizeof(fmt_string), ""c_server"Lockdown // "c_white"Postavili ste koordinate na %f, %f, %f", x, y, z);
		SendClientMessage(playerid, x_ltblue, fmt_string);
	}
 	return 1;
}

YCMD:setstaff(playerid, const string: params[], help)
{
	if(help)
    {
        SendClientMessage(playerid, x_blue, "HELP >> "c_white"0 - Skinut Admin | 1. Assistent | 2. Admin | 3. Manager | 4. High Command.");
        return 1;
    }

	if(!IsPlayerAdmin(playerid))
		return SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"Morate biti RCON!");

	static
		targetid,
		level;

	if (sscanf(params, "ri", targetid, level))
		return SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"/setstaff [targetid] [0/1]");

	if (!level && !player_Staff[targetid])
		return SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"Taj igrac nije u staff-u.");

	if (level == player_Staff[targetid])
		return SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"Taj igrac je vec u staff-u.");

	player_Staff[targetid] = level;
	
	if (!level)
	{
		static fmt_string[64];

		format(fmt_string, sizeof(fmt_string), ""c_server"Lockdown // "c_white"%s Vas je izbacio iz staff-a.", ReturnPlayerName(playerid));
		SendClientMessage(targetid, -1, fmt_string);

		format(fmt_string, sizeof(fmt_string), ""c_server"Lockdown // "c_white"Izbacili ste %s iz staff-a.", ReturnPlayerName(targetid));
		SendClientMessage(playerid, -1, fmt_string);
	}
	else if(level < 0 || level > 4) return SendClientMessage(playerid, x_blue, "Lockdown // "c_white"Molimo vas koristite "c_blue"-/help setstaff- "c_white"kako bi ste videli validne staff levele.");
	{
		static fmt_string[64];

		format(fmt_string, sizeof(fmt_string), ""c_server"Lockdown // "c_white"%s Vas je ubacio u staff.", ReturnPlayerName(playerid));
		SendClientMessage(targetid, -1, fmt_string);

		format(fmt_string, sizeof(fmt_string), ""c_server"Lockdown // "c_white"Ubacili ste %s u staff.", ReturnPlayerName(targetid));
		SendClientMessage(playerid, -1, fmt_string);
	}

    new INI:File = INI_Open(Account_Path(playerid));
	INI_SetTag( File, "data" );
    INI_WriteInt(File, "Staff", player_Staff[playerid]);
	INI_Close( File );
	
    return 1;
}

YCMD:kick(playerid, params[],help)
{
	if(help)
    {
        SendClientMessage(playerid, x_blue, "HELP >> "c_white"Komanda koja vam omogucava da izbacite igraca sa servera.");
        return 1;
    }

	if (player_Staff[playerid] < 1)
		return SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"Samo staff moze ovo!");

	static 
		targetid;

	if (sscanf(params, "ri", targetid))
		return SendClientMessage(playerid, -1, ""c_server"Lockdown // "c_white"/kick [targetid]");

	static fmt_string[64];

	format(fmt_string, sizeof(fmt_string), ""c_server"Lockdown // "c_white"%s Vas je izbacio sa servera.", ReturnPlayerName(playerid));
	SendClientMessage(targetid, -1, fmt_string);

	format(fmt_string, sizeof(fmt_string), ""c_server"Lockdown // "c_white"Izbacili ste %s sa servera.", ReturnPlayerName(targetid));
	SendClientMessage(playerid, -1, fmt_string);

	SetTimerEx("DelayedKick", 1000, false, "i", targetid);

    return 1;
}

forward DelayedKick(targetid);
public DelayedKick(targetid)
{
    Kick(targetid);
    return 1;
}

//testcmd

YCMD:clearwl(playerid, const string: params[], help)
{
	SetPlayerWantedLevel(playerid, 0);

	player_Wanted[playerid] = 0;

    new INI:File = INI_Open(Account_Path(playerid));
	INI_SetTag(File,"data");
    INI_WriteInt(File, "Wanted", player_Wanted[playerid]);
    INI_Close(File);

	return 1;
}


YCMD:deagle(playerid, const string: params[], help)
{
	GivePlayerWeapon(playerid, 24, 64);

	return 1;
}

YCMD:m4(playerid, const string: params[], help)
{
	GivePlayerWeapon(playerid, 31, 64);

	return 1;
}

YCMD:restart(playerid, const string: params[], help)
{
	SendRconCommand("gmx");

    return 1;
}

