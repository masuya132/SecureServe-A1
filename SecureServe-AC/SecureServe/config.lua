--[[≺━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━≻--
  (ASCII ART ต้นฉบับคงเดิม)
≺━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━≻--]]

-- เอกสาร: https://peleg.gitbook.io/secureserve/
-- ในเอกสารคุณจะเจอวิธีการติดตั้ง โปรดอ่านคอมเมนต์ในไฟล์นี้ด้วย (คอมเมนต์ = -- ทุกอย่างหลังจากนี้)

-- ห้ามแก้ตรงนี้! ไม่ใช่ที่สำหรับเปลี่ยน Webhook!
SecureServe = {}
SecureServe.Setup = {}
SecureServe.Webhooks = {}
SecureServe.Protection = {}

--  ______ _______ __   _ _______  ______ _______
-- |  ____ |______ | \  | |______ |_____/ |_____| |
-- |_____| |______ |  \_| |______ |    \_ |     | |_____
SecureServe.ServerName = ""            -- ชื่อของเซิร์ฟเวอร์
SecureServe.DiscordLink = ""           -- ลิงก์ Discord ของคุณ
SecureServe.RequireSteam = false       -- บังคับให้ผู้เล่นต้องเปิด Steam และล็อกอิน (ต้องมี Steam API Key ที่ถูกต้อง)
SecureServe.IdentifierCheck = true     -- ตรวจสอบ identifier ของผู้เล่น ถ้าไม่ผ่านจะไม่ให้เข้า
SecureServe.Debug = false              -- โหมดดีบั๊ก แสดงข้อความในคอนโซล

-- การตั้งค่าความปลอดภัยในตัว FiveM ป้องกันการโกง
-- ให้เปิดทุกตัวก่อน ถ้าเจอปัญหาค่อยปิด
SecureServe.ServerSecurity = {
    Enabled = true, -- เปิด/ปิดระบบความปลอดภัยหลัก

    Connection = { -- การเชื่อมต่อและการตรวจสอบตัวตน
        KickTimeout = 600,  -- เวลา (วินาที) ก่อนจะเตะผู้เล่นที่ไม่ตอบสนอง (10 นาที)
        UpdateRate = 60,    -- ความถี่ในการตรวจสอบสถานะผู้เล่น (60 วินาที)
        ConsecutiveFailures = 2, -- จำนวนครั้งล้มเหลวติดต่อกันก่อนจะเตะ
        AuthMaxVariance = 1,     -- ค่าความต่างที่อนุญาต (1 = เข้มงวด)
        AuthMinTrust = 5,        -- ระดับความเชื่อถือขั้นต่ำ (5 = ปลอดภัยสูง)
        VerifyClientSettings = true -- ตรวจสอบการเชื่อมต่อฝั่ง Client (adhesive)
    },

    NetworkEvents = { -- ความปลอดภัยเกี่ยวกับ Event
        FilterRequestControl = 2,    -- ป้องกัน REQUEST_CONTROL_EVENT (0=ปิด, 1=รถถูกครอบครอง, 2=ทั้งหมด)
        DisableNetworkedSounds = true, -- บล็อก NETWORK_PLAY_SOUND_EVENT
        DisablePhoneExplosions = true, -- บล็อก REQUEST_PHONE_EXPLOSION_EVENT
        DisableScriptEntityStates = false -- บล็อก SCRIPT_ENTITY_STATE_CHANGE_EVENT
    },

    ClientProtection = { -- ป้องกันการแก้ไข Client
        PureLevel = 0,               -- ป้องกันไฟล์เกมถูกแก้ไข (2=สูงสุด, 1=อนุญาตเสียง/กราฟิก, 0=ปิด)
        DisableClientReplays = true, -- ปิดระบบ Replay (กันโกงบางแบบ แต่ใช้ Rockstar Editor ไม่ได้)
        ScriptHookAllowed = false    -- ปิด Script Hook
    },

    Misc = { -- อื่นๆ
        EnableChatSanitization = true, -- ล้างข้อความแชทกัน exploit
        ResourceKvRateLimit = 20,      -- จำกัด KeyValue ต่อ resource
        EntityKvRateLimit = 20         -- จำกัด KeyValue ต่อ entity
    }
}

-- AutoConfig: ตั้งค่าปลอดภัยอัตโนมัติ (ห้ามเปิดตอนให้ผู้เล่นจริงเข้า เพราะจะไม่ถูกแบน)
SecureServe.AutoConfig = false

SecureServe.Module = {
    Events = {
        AutoSafeEvents = true, -- ปรับ Event อัตโนมัติเพื่อลด false ban
        Whitelist = {
            "TestEvent",
            "playerJoining",
        },
    },

    Entity = {
        LockdownMode = "inactive", -- โหมดป้องกัน entity (relaxed | strict | inactive)
        SecurityWhitelist = {
            { resource = "bob74_ipl", whitelist = true },
            { resource = "6x_houserobbery", whitelist = true },
        },
        Limits = { -- จำกัดการ spawn ต่อผู้เล่น
            Vehicles = 15,
            Peds = 15,
            Objects = 25,
            Entities = 50,
        },
    },

    Explosions = {
        ModuleEnabled = false,
        Whitelist = {
            ["resource_name_1"] = true,
            ["resource_name_2"] = true,
        },
    },
}

-- การตั้งค่า Logs
SecureServe.Logs = {
    Enabled = true,   -- เปิดปิดระบบบันทึก Discord
    system = "",      -- Log ระบบ
    detection = "",   -- Log ตรวจจับโกง
    ban = "",         -- Log แบน
    kick = "",        -- Log เตะ
    screenshot = "",  -- Log ภาพหน้าจอ
    admin = "",       -- Log การกระทำของแอดมิน
    debug = "",       -- Log ดีบั๊ก
    join = "",        -- Log เข้าระบบ
    leave = "",       -- Log ออกจากระบบ
    kill = "",        -- Log ฆ่า
    resource = ""     -- Log Resource start/stop
}

SecureServe.Permissions = {
    Enabled = true,
    Groups = {
        ["admin"] = true,
        ["moderator"] = true,
        ["staff"] = true
    },
    DefaultAce = "secure.admin",
    GroupAces = {
        ["admin"] = "secure.admin",
        ["moderator"] = "secure.moderator",
        ["staff"] = "secure.staff"
    },
    BypassPermissions = {
        ["teleport"] = "secure.bypass.teleport",
        ["visions"] = "secure.bypass.visions",
        ["speedhack"] = "secure.bypass.speedhack",
        ["spectate"] = "secure.bypass.spectate",
        ["noclip"] = "secure.bypass.noclip",
        ["ocr"] = "secure.bypass.ocr",
        ["playerblips"] = "secure.bypass.playerblips",
        ["invisible"] = "secure.bypass.invisible",
        ["godmode"] = "secure.bypass.godmode",
        ["freecam"] = "secure.bypass.freecam",
        ["superjump"] = "secure.bypass.superjump",
        ["noragdoll"] = "secure.bypass.noragdoll",
        ["infinitestamina"] = "secure.bypass.infinitestamina",
        ["magicbullet"] = "secure.bypass.magicbullet",
        ["norecoil"] = "secure.bypass.norecoil",
        ["aimassist"] = "secure.bypass.aimassist",
        ["all"] = "secure.bypass.all"
    }
}

-- ระยะเวลาแบนที่ตั้งไว้ล่วงหน้า
SecureServe.BanTimes = {
	["Ban"] = 2147483647, -- แบนถาวร
	["Kick"] = -1,        -- เตะออก
	["Warn"] = 0,         -- แค่เตือน
}


SecureServe.Webhooks.Simple = ""
SecureServe.Protection.Simple = {
	{ protection = "Anti Give Weapon",            time = "Ban", webhook = "",       enabled = true },                     -- Takes action if player used excutor to spawn a weapon.
	{ protection = "Anti Player Blips",           time = "Ban", webhook = "",       enabled = true },                     -- Takes action if player has player blips enabled.
	{ protection = "Anti Car Fly",                time = "Ban", webhook = "",       enabled = true },                     -- Takes action if player uses car fly in the server
	{ protection = "Anti Particles",              time = "Ban", webhook = "",       enabled = true, limit = 5 },          -- Takes action if particles are spawning.
	{ protection = "Anti Damage Modifier",        time = "Ban", webhook = "",       enabled = true, default = 1.5, },     -- Takes action if weapon does more damage than it should.
	{ protection = "Anti Weapon Pickup",          time = "Ban", webhook = "",       enabled = true },                     -- Removes all weapons from the floor every couple of seconds.
	{ protection = "Anti Remove From Car",        time = "Ban", webhook = "",       enabled = true },                     -- Takes action if player has been removed from the car.
	{ protection = "Anti Spectate",               time = "Ban", webhook = "",       enabled = true },                     -- Takes action if player is spectating
	{ protection = "Anti Freecam",                time = "Ban", webhook = "",       enabled = true },                     -- Takes action if player is using freecam
	{ protection = "Anti Explosion Bullet",       time = "Ban", webhook = "",       enabled = true },                     -- Takes action if weapon has explosive bullets
	{ protection = "Anti Night Vision",           time = "Ban", webhook = "",       enabled = true },                     -- Takes action if player is using night vision.
	{ protection = "Anti Thermal Vision",         time = "Ban", webhook = "",       enabled = true },                     -- Takes action if player is using thermal vision.
	{ protection = "Anti God Mode",               time = "Ban", webhook = "",       enabled = true },                     -- Takes action if player has god mode.
	{ protection = "Anti Infinite Ammo",          time = "Ban", webhook = "",       enabled = true },                     -- Disables infinite ammo for the player every couple of seconds.
	{ protection = "Anti Teleport",               time = "Ban", webhook = "",       enabled = true },                     -- Takes action if the player teleported.
	{ protection = "Anti Invisible",              time = "Ban", webhook = "",       enabled = true },                     -- Takes action if the player is invisible
	{ protection = "Anti Resource Stopper",       time = "Ban", webhook = "",       enabled = true },                     -- Takes action if a resouce is stopped (Do not stop any resource if this feature is enabled).
	{ protection = "Anti Resource Starter",       time = "Ban", webhook = "",       enabled = true },                     -- Takes action if a resouce is started (Do not start any resource if this feature is enabled).
	{ protection = "Anti Vehicle God Mode",       time = "Ban", webhook = "",       enabled = true },                     -- Takes action if vehicle has god mode.
	{ protection = "Anti Vehicle Power Increase", time = "Ban", webhook = "",       enabled = true },                     -- Takes action if torque power changed.
	{ protection = "Anti Speed Hack",             time = "Ban", webhook = "",       enabled = true, defaultr = 8, defaults = 4.5, }, -- Takes action if a vehicle is using speedhack.
	{ protection = "Anti Plate Changer",          time = "Ban", webhook = "",       enabled = true },                     -- Takes action if player changed his plate.
	{ protection = "Anti Cheat Engine",           time = "Ban", webhook = "",       enabled = true },                     -- Takes action if player stopped values from changing (Expiremental).
	{ protection = "Anti Rage",                   time = "Ban", webhook = "",       enabled = true },                     -- Takes action if player killed someone that is not on their screen.
	{ protection = "Anti Aim Assist",             time = "Ban", webhook = "",       enabled = true },                     -- Disables aim assist for the player every millisecond.
	{ protection = "Anti Kill All",               time = "Ban", webhook = "",       enabled = true },                     -- Takes action if player tried to kill everyone.
	{ protection = "Anti Solo Session",           time = "Ban", webhook = "",       enabled = true },                     -- Takes action if player is in solo session.
	{ protection = "Anti AI",                     time = "Ban", webhook = "",       enabled = true, default = 1.5, },     -- Takes action if player has modified his ai files (Expiremental).
	{ protection = "Anti No Reload",              time = "Ban", webhook = "",       enabled = true },                     -- Takes action if player uses no reload.
	{ protection = "Anti Rapid Fire",             time = "Ban", webhook = "",       enabled = true },                     -- Takes action if player has modified his fire rate .
	{ protection = "Anti Bigger Hitbox",          time = "Ban", webhook = "",       enabled = true },                     -- Takes action if player has bigger hitbox.
	{ protection = "Anti No Recoil",              time = "Ban", webhook = "",       enabled = true },                     -- Takes action if player has no recoil on.
	{ protection = "Anti State Bag Overflow",     time = "Ban", webhook = "",       enabled = true },                     -- Takes action if player has modified his state bag (Expiremental).
	{ protection = "Anti Extended NUI Devtools",  time = "Ban", webhook = "",       enabled = true },                     -- Takes action if player opened dev tools and extends the anti-cheat (Expiremental).
	{ protection = "Anti No Ragdoll",             time = "Ban", webhook = "",       enabled = true },                     -- Takes action if a disabled ragdolls.
	{ protection = "Anti Super Jump",             time = "Ban", webhook = "",       enabled = true },                     -- Takes action if a player is super jumping.
	{ protection = "Anti Noclip",                 time = "Ban", webhook = "",       enabled = true },                     -- Takes action if a player is using noclip.
	{ protection = "Anti Infinite Stamina",       time = "Ban", webhook = "",       enabled = true },                     -- Takes action if a has infinite stamina.
	{ protection = "Anti Play Sound",             time = "Ban", webhook = "",       enabled = true },                     -- Disables Sound Routing Event
	{ protection = "Anti AFK Injection",          time = "Ban", webhook = "",       enabled = true },                     -- Takes action if player uses afk injection usally used while dumping
	{ protection = "Anti Car Ram",                time = "Ban", webhook = "",       enabled = false },                    -- Takes action if player tries to ram player with a mod menu
	{ protection = "Anti Magic Bullet",           time = "Ban", webhook = "",       enabled = true, tolerance = 3 },      -- If the player kills more than the number of times you set and does not see it, they will be banned from the server
}

SecureServe.OCR = { -- Words on scrren that will get player banned
	"FlexSkazaMenu","SidMenu","Lynx8","LynxEvo","Maestro Menu","redEngine","HamMafia","HamHaxia","Dopameme","redMENU","Desudo","explode","gamesense","Anticheat","Tapatio","Malossi","RedStonia","Chocohax",
	"skin changer","torque multiple","override player speed","colision proof","explosion proof","copy outfit","play single particle","infinite ammo","rip server","remove ammo","remove all weapons",
	"V1s_u4l","D3str_0y","D3str_Oy","S3tt1ngs","P4rt1cl_3s","Pl4y3rz","D3l3t3","Sp4m","V3h1cl3s","T4ze","1nv1s1bll3","R41nb_0w","Sp33d","R41nb_Ow","F_ly","3xpl_0d3","Pr0pz","D3str_0y","M4p","G1v3",
	"Convert Vehicle Into Ramps","injected at","Explode Players","Ram Players","Force Third Person","fallout","godmode","ANTI-CHEAT","god mode","modmenu","esx money","give armor","aimbot","trigger",
	"triggerbot","rage bot","ragebot","rapidfire","freecam","execute","noclip","ckgangisontop","lumia1","ISMMENU","TAJNEMENUMenu","rootMenu","Outcasts666","WaveCheat","NacroxMenu","MarketMenu","topMenu",
	"Flip Vehicle","Rainbow Paintjob","Combat Assiters","Damage Multiplier","Give All Weapons","Teleport To","Explosive Impact","Server Nuke Options","No Ragdoll","Super Powers",
	"invisible all vehicles","Spam Message","Destroy Map","Give RPG","max Speed Vehicles","Rainbow All Vehicles","Delete Props","Cobra Menu","Bind Menu Key","Clone Outfit","Give Health",
	"Rp_GG","V3h1cl3","Sl4p","D4nce","3mote","D4nc3","no-clip","injected","Money Options","Nuke Options","Razer","Aimbot","TriggerBot","RageBot","RapidFire",
	"Force Player Blips","Force Radar","Force Gamertags","ESX Money Options","press AV PAG","TP to Waypoint","S elf Options","Vehicle options","Weapon Options","spam Vehicles","taze All",
	"explosive ammo","super damage","rapid fire","Super Jump","Infinite Roll","No Criticals","Move On Water","Disable Ragdoll","CutzuSD","Vertisso","M3ny00","Pl4y_3r","W34p_On","W34p_0n","V3h1_cl3",
	"fuck server","lynx","absolute","Lumia","Gamesense","Fivesense","SkidMenu","Dopamine","Explode","Teleport Options","infnite combat roll","Hydro Menu","Enter Menu Open Key",
	"Give Single Weapon","Airstrike Player","Taze Player","Razer Menu","Swagamine","Visual Options","d0pamine","Infinite Stamina","Blackout","Delete Vehicles Within Radius","Engine Power Boost",
	"Teleport Into Player's Vehicle","fivesense","menu keybind","nospread","transparent props","bullet tracers","model chams","reload images","fade out in speed","cursor size","custom weapons texture",
	"Inyection","Inyected","Dumper","LUA Executor","Executor","Lux Menu","Event Blocker","Spectate","Wallhack","triggers","crosshair","Alokas66","Hacking System!","Destroy Menu","Server IP","Teleport To",
	"Butan Premium", "RAIDEN", "Give All Weapons", "Miscellaneous", "World Menu", "Sex Adanc", "Tapatio®"
}

SecureServe.Weapons = { -- Add all your weapons to here most of the weapons should arlready be here make sure u added all of them if you are using qbcore if not u can delete this
	[GetHashKey('WEAPON_FLASHLIGHT')] = 'WEAPON_FLASHLIGHT',
	[GetHashKey('weapon_flashbang')] = 'weapon_flashbang',
	[GetHashKey('WEAPON_KNIFE')] = 'WEAPON_KNIFE',
	[GetHashKey('WEAPON_MACHETE')] = 'WEAPON_MACHETE',
	[GetHashKey('WEAPON_NIGHTSTICK')] = 'WEAPON_NIGHTSTICK',
	[GetHashKey('WEAPON_HAMMER')] = 'WEAPON_HAMMER',
	[GetHashKey('WEAPON_BATS')] = 'WEAPON_BATS',
	[GetHashKey('WEAPON_GOLFCLUB')] = 'WEAPON_GOLFCLUB',
	[GetHashKey('WEAPON_CROWBAR')] = 'WEAPON_CROWBAR',
	[GetHashKey('WEAPON_BOTTLE')] = 'WEAPON_BOTTLE',
	[GetHashKey('WEAPON_HATCHET')] = 'WEAPON_HATCHET',
	[GetHashKey('WEAPON_DAGGER')] = 'WEAPON_DAGGER',
	[GetHashKey('WEAPON_KATANA')] = 'WEAPON_KATANA',
	[GetHashKey('WEAPON_SHIV')] = 'WEAPON_SHIV',
	[GetHashKey('WEAPON_WRENCH')] = 'WEAPON_WRENCH',
	[GetHashKey('WEAPON_BOOK')] = 'WEAPON_BOOK',
	[GetHashKey('WEAPON_CASH')] = 'WEAPON_CASH',
	[GetHashKey('WEAPON_BRICK')] = 'WEAPON_BRICK',
	[GetHashKey('WEAPON_SHOE')] = 'WEAPON_SHOE',
	[GetHashKey('WEAPON_PISTOL')] = 'WEAPON_PISTOL',
	[GetHashKey('WEAPON_PISTOL_MK2')] = 'WEAPON_PISTOL_MK2',
	[GetHashKey('WEAPON_COMBATPISTOL')] = 'WEAPON_COMBATPISTOL',
	[GetHashKey('WEAPON_FN57')] = 'WEAPON_FN57',
	[GetHashKey('WEAPON_APPISTOL')] = 'WEAPON_APPISTOL',
	[GetHashKey('WEAPON_PISTOL50')] = 'WEAPON_PISTOL50',
	[GetHashKey('WEAPON_SNSPISTOL')] = 'WEAPON_SNSPISTOL',
	[GetHashKey('WEAPON_HEAVYPISTOL')] = 'WEAPON_HEAVYPISTOL',
	[GetHashKey('WEAPON_NAILGUN')] = 'WEAPON_NAILGUN',
	[GetHashKey('WEAPON_GLOCK17')] = 'WEAPON_GLOCK17',
	[GetHashKey('WEAPON_GLOCK')] = 'WEAPON_GLOCK',
	[GetHashKey('WEAPON_BROWNING')] = 'WEAPON_BROWNING',
	[GetHashKey('WEAPON_DP9')] = 'WEAPON_DP9',
	[GetHashKey('WEAPON_MICROSMG')] = 'WEAPON_MICROSMG',
	[GetHashKey('weapon_microsmg2')] = 'weapon_microsmg2',
	[GetHashKey('weapon_microsmg3')] = 'weapon_microsmg3',
	[GetHashKey('WEAPON_MP7')] = 'WEAPON_MP7',
	[GetHashKey('WEAPON_SMG')] = 'WEAPON_SMG',
	[GetHashKey('WEAPON_MINISMG2')] = 'WEAPON_MINISMG2',
	[GetHashKey('WEAPON_MACHINEPISTOL')] = 'WEAPON_MACHINEPISTOL',
	[GetHashKey('WEAPON_COMBATPDW')] = 'WEAPON_COMBATPDW',
	[GetHashKey('WEAPON_PUMPSHOTGUN')] = 'WEAPON_PUMPSHOTGUN',
	[GetHashKey('WEAPON_PUMPSHOTGUN_MK2')] = 'WEAPON_PUMPSHOTGUN_MK2',
	[GetHashKey('WEAPON_SAWNOFFSHOTGUN')] = 'WEAPON_SAWNOFFSHOTGUN',
	[GetHashKey('WEAPON_AK47')] = 'WEAPON_AK47',
	[GetHashKey('weapon_assaultrifle2')] = 'weapon_assaultrifle2',
	[GetHashKey('weapon_assaultrifle_mk2')] = 'weapon_assaultrifle_mk2',
	[GetHashKey('weapon_stungun')] = 'weapon_stungun',
	[GetHashKey('WEAPON_CARBINERIFLE')] = 'WEAPON_CARBINERIFLE',
	[GetHashKey('WEAPON_CARBINERIFLE_MK2')] = 'WEAPON_CARBINERIFLE_MK2',
	[GetHashKey('WEAPON_ADVANCEDRIFLE')] = 'WEAPON_ADVANCEDRIFLE',
	[GetHashKey('WEAPON_M4')] = 'WEAPON_M4',
	[GetHashKey('WEAPON_HK416')] = 'WEAPON_HK416',
	[GetHashKey('WEAPON_AR15')] = 'WEAPON_AR15',
	[GetHashKey('WEAPON_M110')] = 'WEAPON_M110',
	[GetHashKey('WEAPON_M14')] = 'WEAPON_M14',
	[GetHashKey('WEAPON_SPECIALCARBINE_MK2')] = 'WEAPON_SPECIALCARBINE_MK2',
	[GetHashKey('WEAPON_DRAGUNOV')] = 'WEAPON_DRAGUNOV',
	[GetHashKey('WEAPON_COMPACTRIFLE')] = 'WEAPON_COMPACTRIFLE',
	[GetHashKey('WEAPON_MG')] = 'WEAPON_MG',
	[GetHashKey('WEAPON_SNIPERRIFLE')] = 'WEAPON_SNIPERRIFLE',
	[GetHashKey('WEAPON_SNIPERRIFLE2')] = 'WEAPON_SNIPERRIFLE2',
	[GetHashKey('WEAPON_GRENADELAUNCHER_SMOKE')] = 'WEAPON_GRENADELAUNCHER_SMOKE',
	[GetHashKey('WEAPON_RPG')] = 'WEAPON_RPG',
	[GetHashKey('WEAPON_MINIGUN')] = 'WEAPON_MINIGUN',
	[GetHashKey('WEAPON_GRENADE')] = 'WEAPON_GRENADE',
	[GetHashKey('WEAPON_STICKYBOMB')] = 'WEAPON_STICKYBOMB',
	[GetHashKey('WEAPON_SMOKEGRENADE')] = 'WEAPON_SMOKEGRENADE',
	[GetHashKey('WEAPON_BZGAS')] = 'WEAPON_BZGAS',
	[GetHashKey('WEAPON_MOLOTOV')] = 'WEAPON_MOLOTOV',
	[GetHashKey('WEAPON_FIREWORK')] = 'WEAPON_FIREWORK',
	[GetHashKey('WEAPON_TASER')] = 'WEAPON_TASER',
	[GetHashKey('WEAPON_RAILGUN')] = 'WEAPON_RAILGUN',
	[GetHashKey('WEAPON_DBSHOTGUN')] = 'WEAPON_DBSHOTGUN',
	[GetHashKey('WEAPON_LTL')] = 'WEAPON_LTL',
	[GetHashKey('WEAPON_PIPEBOMB')] = 'WEAPON_PIPEBOMB',
	[GetHashKey('WEAPON_DOUBLEACTION')] = 'WEAPON_DOUBLEACTION',
	[GetHashKey('WEAPON_ASSAULTRIFLE')] = 'WEAPON_ASSAULTRIFLE',
	[GetHashKey('WEAPON_PISTOL')] = 'WEAPON_PISTOL',
	[GetHashKey('WEAPON_PISTOL_MK2')] = 'WEAPON_PISTOL_MK2',
	[GetHashKey('WEAPON_COMBATPISTOL')] = 'WEAPON_COMBATPISTOL',
	[GetHashKey('WEAPON_APPISTOL')] = 'WEAPON_APPISTOL',
	[GetHashKey('WEAPON_PISTOL50')] = 'WEAPON_PISTOL50',
	[GetHashKey('WEAPON_SNSPISTOL')] = 'WEAPON_SNSPISTOL',
	[GetHashKey('WEAPON_HEAVYPISTOL')] = 'WEAPON_HEAVYPISTOL'
}

SecureServe.Webhooks.BlacklistedExplosions = ""  -- Takes action if an explosion with the id got detected.
SecureServe.Protection.BlacklistedExplosions = {
    { id = 0, time = "Ban",  webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Grenades
    { id = 1, time = "Ban",  webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Sticky Bombs
    { id = 2, time = "Ban",  webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Grenade Launcher
    { id = 3, time = "Ban",  webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Molotov Cocktails
    { id = 4, time = "Ban",  webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Rockets
    { id = 5, time = "Ban",  webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Tank Shells
    { id = 6, time = "Ban",  webhook = "", limit = 4, audio = true, scale = 1.0, invisible = false }, -- Hi Octane
    { id = 7, time = "Ban",  webhook = "", limit = 5, audio = true, scale = 1.0, invisible = false }, -- Car Explosions
    { id = 18, time = "Ban", webhook = "", limit = 12, audio = true, scale = 1.0, invisible = false }, -- Bullet Explosions
    { id = 19, time = "Ban", webhook = "", limit = 12, audio = true, scale = 1.0, invisible = false }, -- Smoke Grenade Launcher
    { id = 20, time = "Ban", webhook = "", limit = 5, audio = true, scale = 1.0, invisible = false }, -- Smoke Grenades
    { id = 21, time = "Ban", webhook = "", limit = 5, audio = true, scale = 1.0, invisible = false }, -- BZ Gas
    { id = 22, time = "Ban", webhook = "", limit = 5, audio = true, scale = 1.0, invisible = false }, -- Flares
    { id = 25, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Programmable AR
    { id = 36, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Railgun
    { id = 37, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Blimp 2
    { id = 38, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Fireworks
    { id = 40, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Proximity Mines
    { id = 43, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Pipe Bombs
    { id = 44, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Vehicle Mines
    { id = 45, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Explosive Ammo
    { id = 46, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- APC Shells
    { id = 47, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Cluster Bombs
    { id = 48, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Gas Bombs
    { id = 49, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Incendiary Bombs
    { id = 50, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Standard Bombs
    { id = 51, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Torpedoes
    { id = 52, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Underwater Torpedoes
    { id = 53, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Bombushka Cannon
    { id = 54, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Cluster Bomb Secondary Explosions
    { id = 55, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Hunter Barrage
    { id = 56, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Hunter Cannon
    { id = 57, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Rogue Cannon
    { id = 58, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Underwater Mines
    { id = 59, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Orbital Cannon
    { id = 60, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Wide Standard Bombs
    { id = 61, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Explosive Shotgun Ammo
    { id = 62, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Oppressor 2 Cannon
    { id = 63, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Kinetic Mortar
    { id = 64, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Kinetic Vehicle Mine
    { id = 65, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- EMP Vehicle Mine
    { id = 66, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Spike Vehicle Mine
    { id = 67, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Slick Vehicle Mine
    { id = 68, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Tar Vehicle Mine
    { id = 69, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Script Drone
    { id = 70, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Raygun
	{ id = 71, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Buried Mine
	{ id = 72, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Script Missle
	{ id = 82, time = "Ban", webhook = "", limit = 1, audio = true, scale = 1.0, invisible = false }, -- Submarine
}

SecureServe.Webhooks.BlacklistedCommands = ""
SecureServe.Protection.BlacklistedCommands = { -- Takes action if a blacklisted command is registered.
	{ command = "jd",                        time = "Ban", webhook = "" },
	{ command = "KP",                        time = "Ban", webhook = "" },
	{ command = "opk",                       time = "Ban", webhook = "" },
	{ command = "ham",                       time = "Ban", webhook = "" },
	{ command = "lol",                       time = "Ban", webhook = "" },
	{ command = "hoax",                      time = "Ban", webhook = "" },
	{ command = "vibes",                     time = "Ban", webhook = "" },
	{ command = "haha",                      time = "Ban", webhook = "" },
	{ command = "panik",                     time = "Ban", webhook = "" },
	{ command = "brutan",                    time = "Ban", webhook = "" },
	{ command = "panic",                     time = "Ban", webhook = "" },
	{ command = "hyra",                      time = "Ban", webhook = "" },
	{ command = "hydro",                     time = "Ban", webhook = "" },
	{ command = "lynx",                      time = "Ban", webhook = "" },
	{ command = "tiago",                     time = "Ban", webhook = "" },
	{ command = "desudo",                    time = "Ban", webhook = "" },
	{ command = "ssssss",                    time = "Ban", webhook = "" },
	{ command = "redstonia",                 time = "Ban", webhook = "" },
	{ command = "dopamine",                  time = "Ban", webhook = "" },
	{ command = "dopamina",                  time = "Ban", webhook = "" },
	{ command = "purgemenu",                 time = "Ban", webhook = "" },
	{ command = "WarMenu",                   time = "Ban", webhook = "" },
	{ command = "lynx9_fixed",               time = "Ban", webhook = "" },
	{ command = "injected",                  time = "Ban", webhook = "" },
	{ command = "hammafia",                  time = "Ban", webhook = "" },
	{ command = "hamhaxia",                  time = "Ban", webhook = "" },
	{ command = "chocolate",                 time = "Ban", webhook = "" },
	{ command = "Information",               time = "Ban", webhook = "" },
	{ command = "Maestro",                   time = "Ban", webhook = "" },
	{ command = "FunCtionOk",                time = "Ban", webhook = "" },
	{ command = "TiagoModz",                 time = "Ban", webhook = "" },
	{ command = "jolmany",                   time = "Ban", webhook = "" },
	{ command = "SovietH4X",                 time = "Ban", webhook = "" },
	{ command = "killmenu",                  time = "Ban", webhook = "" },
	{ command = "panickey",                  time = "Ban", webhook = "" },
	{ command = "d0pamine",                  time = "Ban", webhook = "" },
	{ command = "[dopamine]",                time = "Ban", webhook = "" },
	{ command = "brutanpremium",             time = "Ban", webhook = "" },
	{ command = "www.d0pamine.xyz",          time = "Ban", webhook = "" },
	{ command = "d0pamine v1.1 by Nertigel", time = "Ban", webhook = "" },
	{ command = "TiagoModz#1478",            time = "Ban", webhook = "" },
}

SecureServe.Webhooks.BlacklistedSprites = ""
SecureServe.Protection.BlacklistedSprites = { -- Takes action if a blacklisted sprite is detected.
	{ sprite = "deadline",           name = "Dopamine",            time = "Ban", webhook = "" },
	{ sprite = "Dopameme",           name = "Dopamine Menu",       time = "Ban", webhook = "" },
	{ sprite = "dopamine",           name = "Dopamine Menu",       time = "Ban", webhook = "" },
	{ sprite = "dopamemes",          name = "Dopameme Menu",       time = "Ban", webhook = "" },
	{ sprite = "wm2",                name = "WM Menu",             time = "Ban", webhook = "" },
	{ sprite = "KentasCheckboxDict", name = "Kentas Menu Synapse", time = "Ban", webhook = "" },
	{ sprite = "KentasMenu",         name = "Kentas Menu Synapse", time = "Ban", webhook = "" },
	{ sprite = "HydroMenuHeader",    name = "HydroMenu",           time = "Ban", webhook = "" },
	{ sprite = "godmenu",            name = "God Menu",            time = "Ban", webhook = "" },
	{ sprite = "redrum",             name = "Redrum Menu",         time = "Ban", webhook = "" },
	{ sprite = "beautiful",          name = "Beautiful Menu",      time = "Ban", webhook = "" },
	{ sprite = "Absolut",            name = "Absolute Menu",       time = "Ban", webhook = "" },
	{ sprite = "hoaxmenu",           name = "Hoax Menu",           time = "Ban", webhook = "" },
	{ sprite = "fendin",             name = "Fendinx Menu",        time = "Ban", webhook = "" },
	{ sprite = "Ham",                name = "Ham Menu",            time = "Ban", webhook = "" },
	{ sprite = "hammafia",           name = "Ham Mafia Menu",      time = "Ban", webhook = "" },
	{ sprite = "Fallout",            name = "Fallout",             time = "Ban", webhook = "" },
	{ sprite = "menu_bg",            name = "Fallout Menu",        time = "Ban", webhook = "" },
	{ sprite = "DefaultMenu",        name = "Default Menu",        time = "Ban", webhook = "" },
	{ sprite = "ISMMENUHeader",      name = "ISMMENU",             time = "Ban", webhook = "" },
	{ sprite = "fivesense",          name = "Fivesense Menu",      time = "Ban", webhook = "" },
	{ sprite = "maestro",            name = "Maestro Menu",        time = "Ban", webhook = "" },
	{ sprite = "kekhack",            name = "KekHack Menu",        time = "Ban", webhook = "" },
	{ sprite = "trolling",           name = "Trolling Menu",       time = "Ban", webhook = "" },
	{ sprite = "mm",                 name = "MM Menu",             time = "Ban", webhook = "" },
	{ sprite = "MmPremium",          name = "MM Premium Menu",     time = "Ban", webhook = "" },
	{ sprite = "Fallout",            name = "Fallout",             time = "Ban", webhook = "" },
	{ sprite = "dopatest",           name = "Dopa Menu",           time = "Ban", webhook = "" },
	{ sprite = "deadline",           name = "Dopamine",            time = "Ban", webhook = "" },
	{ sprite = "dopamine",           name = "Dopamine Menu",       time = "Ban", webhook = "" },
	{ sprite = "cat",                name = "Cat Menu",            time = "Ban", webhook = "" },
	{ sprite = "John2",              name = "SugarMenu",           time = "Ban", webhook = "" },
	{ sprite = "bartowmenu",         name = "Bartow Menu",         time = "Ban", webhook = "" },
	{ sprite = "duiTex",             name = "Copypaste Menu",      time = "Ban", webhook = "" },
	{ sprite = "Mafins",             name = "Mafins Menu",         time = "Ban", webhook = "" },
	{ sprite = "__REAPER24__",       name = "Repear Menu",         time = "Ban", webhook = "" },
	{ sprite = "__REAPER5__",        name = "Repear Menu",         time = "Ban", webhook = "" },
	{ sprite = "__REAPER7__",        name = "Repear Menu",         time = "Ban", webhook = "" },
	{ sprite = "__REAPER8__",        name = "Repear Menu",         time = "Ban", webhook = "" },
	{ sprite = "__REAPER10__",       name = "Repear Menu",         time = "Ban", webhook = "" },
	{ sprite = "__REAPER3__",        name = "Repear Menu",         time = "Ban", webhook = "" },
	{ sprite = "__REAPER2__",        name = "Repear Menu",         time = "Ban", webhook = "" },
	{ sprite = "__REAPER1__",        name = "Repear Menu",         time = "Ban", webhook = "" },
	{ sprite = "__REAPER23__",       name = "Repear Menu",         time = "Ban", webhook = "" },
	{ sprite = "__REAPER17__",       name = "Repear Menu",         time = "Ban", webhook = "" },
	{ sprite = "skidmenu",           name = "Skid Menu",           time = "Ban", webhook = "" },
	{ sprite = "skidmenu",           name = "Skid Menu",           time = "Ban", webhook = "" },
	{ sprite = "Urubu3",             name = "Urubu Menu",          time = "Ban", webhook = "" },
	{ sprite = "Urubu",              name = "Urubu Menu",          time = "Ban", webhook = "" },
	{ sprite = "love",               name = "Love Menu",           time = "Ban", webhook = "" },
	{ sprite = "brutan",             name = "Brutan Menu",         time = "Ban", webhook = "" },
	{ sprite = "auttaja",            name = "Auttaja Menu",        time = "Ban", webhook = "" },
	{ sprite = "oblivious",          name = "Oblivious Menu",      time = "Ban", webhook = "" },
	{ sprite = "malossimenu",        name = "Malossi Menu",        time = "Ban", webhook = "" },
	{ sprite = "Memeeee",            name = "Memeeee Menu",        time = "Ban", webhook = "" },
	{ sprite = "Tiago",              name = "Tiago Menu",          time = "Ban", webhook = "" },
	{ sprite = "fantasy",            name = "Fantasy Menu",        time = "Ban", webhook = "" },
	{ sprite = "Vagos",              name = "Vagos Menu",          time = "Ban", webhook = "" },
	{ sprite = "simplicity",         name = "Simplicity Menu",     time = "Ban", webhook = "" },
	{ sprite = "WarMenu",            name = "War Menu",            time = "Ban", webhook = "" },
	{ sprite = "Darkside",           name = "Darkside Menu",       time = "Ban", webhook = "" },
	{ sprite = "antario",            name = "Antario Menu",        time = "Ban", webhook = "" },
	{ sprite = "kingpin",            name = "Kingpin Menu",        time = "Ban", webhook = "" },
	{ sprite = "Wave (alt.)",        name = "Wave (alt.)",         time = "Ban", webhook = "" },
	{ sprite = "Wave",               name = "Wave",                time = "Ban", webhook = "" },
	{ sprite = "Alokas66",           name = "Alokas66",            time = "Ban", webhook = "" },
	{ sprite = "Guest Menu",         name = "Guest Menu",          time = "Ban", webhook = "" },
}

SecureServe.Webhooks.BlacklistedAnimDicts = ""
SecureServe.Protection.BlacklistedAnimDicts = { -- Takes action if a blacklisted anim dict got loaded.
	{ dict = "rcmjosh2",       time = "Ban", webhook = "" },
	{ dict = "rcmpaparazzo_2", time = "Ban", webhook = "" },
}

SecureServe.Webhooks.BlacklistedWeapons = ""
SecureServe.Protection.BlacklistedWeapons = { -- Weapons Names can be found here: https://gtahash.ru/weapons/
	{ name = "weapon_rayminigun",      time = "Ban", webhook = "" },
	{ name = "weapon_raycarbine",      time = "Ban", webhook = "" },
	{ name = "weapon_rpg",             time = "Ban", webhook = "" },
	{ name = "weapon_grenadelauncher", time = "Ban", webhook = "" },
	{ name = "weapon_minigun",         time = "Ban", webhook = "" },
	{ name = "weapon_railgun",         time = "Ban", webhook = "" },
	{ name = "weapon_firework",        time = "Ban", webhook = "" },
	{ name = "weapon_hominglauncher",  time = "Ban", webhook = "" },
	{ name = "weapon_compactlauncher", time = "Ban", webhook = "" },
}

SecureServe.Webhooks.BlacklistedVehicles = ""
SecureServe.Protection.BlacklistedVehicles = { -- Vehicles List can be found here: https://wiki.rage.mp/index.php?title=Vehicles
	{ name = "dinghy5",       time = "Ban", webhook = "" },
	{ name = "kosatka",       time = "Ban", webhook = "" },
	{ name = "patrolboat",    time = "Ban", webhook = "" },
	{ name = "cerberus",      time = "Ban", webhook = "" },
	{ name = "cerberus2",     time = "Ban", webhook = "" },
	{ name = "cerberus3",     time = "Ban", webhook = "" },
	{ name = "phantom2",      time = "Ban", webhook = "" },
	{ name = "akula",         time = "Ban", webhook = "" },
	{ name = "annihilator",   time = "Ban", webhook = "" },
	{ name = "buzzard",       time = "Ban", webhook = "" },
	{ name = "savage",        time = "Ban", webhook = "" },
	{ name = "annihilator2",  time = "Ban", webhook = "" },
	{ name = "cutter",        time = "Ban", webhook = "" },
	{ name = "apc",           time = "Ban", webhook = "" },
	{ name = "barrage",       time = "Ban", webhook = "" },
	{ name = "chernobog",     time = "Ban", webhook = "" },
	{ name = "halftrack",     time = "Ban", webhook = "" },
	{ name = "khanjali",      time = "Ban", webhook = "" },
	{ name = "minitank",      time = "Ban", webhook = "" },
	{ name = "rhino",         time = "Ban", webhook = "" },
	{ name = "thruster",      time = "Ban", webhook = "" },
	{ name = "trailersmall2", time = "Ban", webhook = "" },
	{ name = "oppressor",     time = "Ban", webhook = "" },
	{ name = "oppressor2",    time = "Ban", webhook = "" },
	{ name = "dukes2",        time = "Ban", webhook = "" },
	{ name = "ruiner2",       time = "Ban", webhook = "" },
	{ name = "dune3",         time = "Ban", webhook = "" },
	{ name = "dune4",         time = "Ban", webhook = "" },
	{ name = "dune5",         time = "Ban", webhook = "" },
	{ name = "insurgent",     time = "Ban", webhook = "" },
	{ name = "insurgent3",    time = "Ban", webhook = "" },
	{ name = "menacer",       time = "Ban", webhook = "" },
	{ name = "rcbandito",     time = "Ban", webhook = "" },
	{ name = "technical3",    time = "Ban", webhook = "" },
	{ name = "technical2",    time = "Ban", webhook = "" },
	{ name = "technical",     time = "Ban", webhook = "" },
	{ name = "avenger",       time = "Ban", webhook = "" },
	{ name = "avenger2",      time = "Ban", webhook = "" },
	{ name = "bombushka",     time = "Ban", webhook = "" },
	{ name = "cargoplane",    time = "Ban", webhook = "" },
	{ name = "cargoplane2",   time = "Ban", webhook = "" },
	{ name = "hydra",         time = "Ban", webhook = "" },
	{ name = "lazer",         time = "Ban", webhook = "" },
	{ name = "molotok",       time = "Ban", webhook = "" },
	{ name = "nokota",        time = "Ban", webhook = "" },
	{ name = "pyro",          time = "Ban", webhook = "" },
	{ name = "rogue",         time = "Ban", webhook = "" },
	{ name = "starling",      time = "Ban", webhook = "" },
	{ name = "strikeforce",   time = "Ban", webhook = "" },
	{ name = "limo2",         time = "Ban", webhook = "" },
	{ name = "scramjet",      time = "Ban", webhook = "" },
	{ name = "vigilante",     time = "Ban", webhook = "" },
}

SecureServe.Protection.BlacklistedPeds = { -- Add blacklisted ped models here
    { name = "s_m_y_swat_01", hash = GetHashKey("s_m_y_swat_01") },
    { name = "s_m_y_hwaycop_01", hash = GetHashKey("s_m_y_hwaycop_01") },
    { name = "s_m_m_movalien_01", hash = GetHashKey("s_m_m_movalien_01") },
}

SecureServe.Webhooks.BlacklistedObjects = ""
SecureServe.Protection.BlacklistedObjects = {
	{ name = "prop_logpile_07b",                                               webhook = "" },
	{ name = "prop_logpile_07",                                                webhook = "" },
	{ name = "prop_logpile_06b",                                               webhook = "" },
	{ name = "prop_logpile_06",                                                webhook = "" },
	{ name = "prop_logpile_05",                                                webhook = "" },
	{ name = "prop_logpile_04",                                                webhook = "" },
	{ name = "prop_logpile_03",                                                webhook = "" },
	{ name = "prop_logpile_02",                                                webhook = "" },
	{ name = "prop_logpile_01",                                                webhook = "" },
	{ name = "hei_prop_carrier_radar_1_l1",                                    webhook = "" },
	{ name = "v_res_mexball",                                                  webhook = "" },
	{ name = "prop_rock_1_a",                                                  webhook = "" },
	{ name = "prop_rock_1_b",                                                  webhook = "" },
	{ name = "prop_rock_1_c",                                                  webhook = "" },
	{ name = "prop_rock_1_d",                                                  webhook = "" },
	{ name = "prop_player_gasmask",                                            webhook = "" },
	{ name = "prop_rock_1_e",                                                  webhook = "" },
	{ name = "prop_rock_1_f",                                                  webhook = "" },
	{ name = "prop_rock_1_g",                                                  webhook = "" },
	{ name = "prop_rock_1_h",                                                  webhook = "" },
	{ name = "prop_test_boulder_01",                                           webhook = "" },
	{ name = "prop_test_boulder_02",                                           webhook = "" },
	{ name = "prop_test_boulder_03",                                           webhook = "" },
	{ name = "prop_test_boulder_04",                                           webhook = "" },
	{ name = "apa_mp_apa_crashed_usaf_01a",                                    webhook = "" },
	{ name = "ex_prop_exec_crashdp",                                           webhook = "" },
	{ name = "apa_mp_apa_yacht_o1_rail_a",                                     webhook = "" },
	{ name = "apa_mp_apa_yacht_o1_rail_b",                                     webhook = "" },
	{ name = "apa_mp_h_yacht_armchair_01",                                     webhook = "" },
	{ name = "apa_mp_h_yacht_armchair_03",                                     webhook = "" },
	{ name = "apa_mp_h_yacht_armchair_04",                                     webhook = "" },
	{ name = "apa_mp_h_yacht_barstool_01",                                     webhook = "" },
	{ name = "apa_mp_h_yacht_bed_01",                                          webhook = "" },
	{ name = "apa_mp_h_yacht_bed_02",                                          webhook = "" },
	{ name = "apa_mp_h_yacht_coffee_table_01",                                 webhook = "" },
	{ name = "apa_mp_h_yacht_coffee_table_02",                                 webhook = "" },
	{ name = "apa_mp_h_yacht_floor_lamp_01",                                   webhook = "" },
	{ name = "apa_mp_h_yacht_side_table_01",                                   webhook = "" },
	{ name = "apa_mp_h_yacht_side_table_02",                                   webhook = "" },
	{ name = "apa_mp_h_yacht_sofa_01",                                         webhook = "" },
	{ name = "apa_mp_h_yacht_sofa_02",                                         webhook = "" },
	{ name = "apa_mp_h_yacht_stool_01",                                        webhook = "" },
	{ name = "apa_mp_h_yacht_strip_chair_01",                                  webhook = "" },
	{ name = "apa_mp_h_yacht_table_lamp_01",                                   webhook = "" },
	{ name = "apa_mp_h_yacht_table_lamp_02",                                   webhook = "" },
	{ name = "apa_mp_h_yacht_table_lamp_03",                                   webhook = "" },
	{ name = "prop_flag_columbia",                                             webhook = "" },
	{ name = "apa_mp_apa_yacht_o2_rail_a",                                     webhook = "" },
	{ name = "apa_mp_apa_yacht_o2_rail_b",                                     webhook = "" },
	{ name = "apa_mp_apa_yacht_o3_rail_a",                                     webhook = "" },
	{ name = "apa_mp_apa_yacht_o3_rail_b",                                     webhook = "" },
	{ name = "apa_mp_apa_yacht_option1",                                       webhook = "" },
	{ name = "proc_searock_01",                                                webhook = "" },
	{ name = "apa_mp_h_yacht_",                                                webhook = "" },
	{ name = "apa_mp_apa_yacht_option1_cola",                                  webhook = "" },
	{ name = "apa_mp_apa_yacht_option2",                                       webhook = "" },
	{ name = "apa_mp_apa_yacht_option2_cola",                                  webhook = "" },
	{ name = "apa_mp_apa_yacht_option2_colb",                                  webhook = "" },
	{ name = "apa_mp_apa_yacht_option3",                                       webhook = "" },
	{ name = "apa_mp_apa_yacht_option3_cola",                                  webhook = "" },
	{ name = "apa_mp_apa_yacht_option3_colb",                                  webhook = "" },
	{ name = "apa_mp_apa_yacht_option3_colc",                                  webhook = "" },
	{ name = "apa_mp_apa_yacht_option3_cold",                                  webhook = "" },
	{ name = "apa_mp_apa_yacht_option3_cole",                                  webhook = "" },
	{ name = "apa_mp_apa_yacht_jacuzzi_cam",                                   webhook = "" },
	{ name = "apa_mp_apa_yacht_jacuzzi_ripple003",                             webhook = "" },
	{ name = "apa_mp_apa_yacht_jacuzzi_ripple1",                               webhook = "" },
	{ name = "apa_mp_apa_yacht_jacuzzi_ripple2",                               webhook = "" },
	{ name = "apa_mp_apa_yacht_radar_01a",                                     webhook = "" },
	{ name = "apa_mp_apa_yacht_win",                                           webhook = "" },
	{ name = "prop_crashed_heli",                                              webhook = "" },
	{ name = "apa_mp_apa_yacht_door",                                          webhook = "" },
	{ name = "prop_shamal_crash",                                              webhook = "" },
	{ name = "xm_prop_x17_shamal_crash",                                       webhook = "" },
	{ name = "apa_mp_apa_yacht_door2",                                         webhook = "" },
	{ name = "apa_mp_apa_yacht",                                               webhook = "" },
	{ name = "prop_flagpole_2b",                                               webhook = "" },
	{ name = "prop_flagpole_2c",                                               webhook = "" },
	{ name = "prop_flag_canada",                                               webhook = "" },
	{ name = "apa_prop_yacht_float_1a",                                        webhook = "" },
	{ name = "apa_prop_yacht_float_1b",                                        webhook = "" },
	{ name = "apa_prop_yacht_glass_01",                                        webhook = "" },
	{ name = "apa_prop_yacht_glass_02",                                        webhook = "" },
	{ name = "apa_prop_yacht_glass_03",                                        webhook = "" },
	{ name = "prop_beach_fire",                                                webhook = "" },
	{ name = "prop_rock_4_big2",                                               webhook = "" },
	{ name = "prop_beachflag_le",                                              webhook = "" },
	{ name = "freight",                                                        webhook = "" },
	{ name = "stt_prop_race_start_line_03b",                                   webhook = "" },
	{ name = "stt_prop_stunt_soccer_sball",                                    webhook = "" }
}
