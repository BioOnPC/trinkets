#define init
    spr = {};
    
    with(spr) {
        /* TRINKETS */
        AmmunitionBox                                                           = sprite_add("sprites/sprAmmunitionBox.png", 1, 10, 10);
        BanditRags                                                              = sprite_add("sprites/sprBanditRags.png", 1, 10, 10);
        Bandolier                                                               = sprite_add("sprites/sprBandolier.png", 1, 10, 10);
        Battery                                                                 = sprite_add("sprites/sprBattery.png", 1, 10, 10);
        Blindfold                                                               = sprite_add("sprites/sprBlindfold.png", 1, 10, 10);
        FirstAidKit                                                             = sprite_add("sprites/sprFirstAidKit.png", 1, 10, 10);
        GasCan                                                                  = sprite_add("sprites/sprGasCan.png", 1, 10, 10);
        Glasses                                                                 = sprite_add("sprites/sprGlasses.png", 1, 10, 10);
        Magazine                                                                = sprite_add("sprites/sprMagazine.png", 1, 10, 10);
        Quiver                                                                  = sprite_add("sprites/sprQuiver.png", 1, 10, 10);
        RoseBud                                                                 = sprite_add("sprites/sprRoseBud.png", 1, 10, 10);
    }

#define trinket_names
    return ["AmmunitionBox", "BanditRags", "Bandolier", "Battery", "Blindfold", "FirstAidKit", "GasCan", "Glasses", "Magazine", "Quiver", "RoseBud"];
    
#define AmmunitionBox_name   return "AMMUNITION BOX";                           // Name
#define AmmunitionBox_text   return "@yAMMO PICKUPS@s LAST LONGER";             // Description
#define AmmunitionBox_area   return 0;                                          // Spawns anywhere
#define AmmunitionBox_sprite return spr.AmmunitionBox;                          // Sprite
#define AmmunitionBox_swap   return sndAmmoChest;                               // Swap sound
#define AmmunitionBox_step
    with(instances_matching(AmmoPickup, "trinket_ammunitionbox", null)) {
        trinket_ammunitionbox = true;
        alarm0 += 120 + (trinket_get(-1, "AmmunitionBox") * 15); // Ammo pickups last longer
    }
    
#define BanditRags_name   return "BANDIT RAGS";                                 // Name
#define BanditRags_text   return "START EACH LEVEL WITH AN @wALLY@s";           // Description
#define BanditRags_area   return 0;                                             // Spawns anywhere
#define BanditRags_sprite return spr.BanditRags;                                // Sprite
#define BanditRags_swap   return sndAllySpawn;                                  // Swap sound
#define BanditRags_level_start
    repeat(trinket_get(self, "BanditRags")) instance_create(x, y, Ally);

#define Bandolier_name   return "BANDOLIER";                                    // Name
#define Bandolier_text   return "GET MORE @ySHOTGUN AMMO@s";                    // Description
#define Bandolier_area   return 0;                                              // Spawns anywhere
#define Bandolier_sprite return spr.Bandolier;                                  // Sprite
#define Bandolier_swap   return sndShotReload;                                  // Swap sound
#define Bandolier_take(_scale)
    typ_ammo[2] += 4 * _scale;
#define Bandolier_lose(_scale)
    typ_ammo[2] -= 4 * _scale;
    
#define Battery_name   return "BATTERY";                                        // Name
#define Battery_text   return "GET MORE @yENERGY AMMO@s";                       // Description
#define Battery_area   return 0;                                                // Spawns anywhere
#define Battery_sprite return spr.Battery;                                      // Sprite
#define Battery_swap   return sndLightningReload;                               // Swap sound
#define Battery_take(_scale)
    typ_ammo[5] += 5 * _scale;
#define Battery_lose(_scale)
    typ_ammo[5] -= 5 * _scale;

#define Blindfold_name   return "BLINDFOLD";                                    // Name
#define Blindfold_text   return "WORSE @wACCURACY@s";                           // Description
#define Blindfold_area   return 0;                                              // Spawns anywhere
#define Blindfold_sprite return spr.Blindfold;                                  // Sprite
#define Blindfold_swap   return sndMoneyPileBreak;                                 // Swap sound
#define Blindfold_take(_scale)
    accuracy += 0.3 * _scale;
    trace("test")
#define Blindfold_lose(_scale)
    accuracy -= 0.3 * _scale;

#define FirstAidKit_name   return "FIRST AID KIT";                              // Name
#define FirstAidKit_text   return "@rHEALTH PICKUPS@s LAST LONGER";             // Description
#define FirstAidKit_area   return 0;                                            // Spawns anywhere
#define FirstAidKit_sprite return spr.FirstAidKit;                              // Sprite
#define FirstAidKit_swap   return sndHealthChest;                               // Swap sound
#define FirstAidKit_step
    with(instances_matching(HPPickup, "trinket_firstaidkit", null)) {
        trinket_firstaidkit = true;
        alarm0 += 120 + (trinket_get(-1, "FirstAidKit") * 15); // Health pickups last longer
    }

#define GasCan_name   return "GAS CAN";                                         // Name
#define GasCan_text   return "GET MORE @yEXPLOSIVE AMMO@s";                     // Description
#define GasCan_area   return 0;                                                 // Spawns anywhere
#define GasCan_sprite return spr.GasCan;                                        // Sprite
#define GasCan_swap   return sndSwapFlame;                                      // Swap sound
#define GasCan_take(_scale)
    typ_ammo[4] += 3 * _scale;
#define GasCan_lose(_scale)
    typ_ammo[4] -= 3 * _scale;

#define Glasses_name   return "GLASSES";                                        // Name
#define Glasses_text   return "BETTER @wACCURACY@s";                            // Description
#define Glasses_area   return 0;                                                // Spawns anywhere
#define Glasses_sprite return spr.Glasses;                                      // Sprite
#define Glasses_swap   return sndMeleeFlip;                                     // Swap sound
#define Glasses_take(_scale)
    accuracy -= 0.3 * _scale;
#define Glasses_lose(_scale)
    accuracy += 0.3 * _scale;

#define Magazine_name   return "MAGAZINE";                                      // Name
#define Magazine_text   return "GET MORE @yBULLET AMMO@s";                      // Description
#define Magazine_area   return 0;                                               // Spawns anywhere
#define Magazine_sprite return spr.Magazine;                                    // Sprite
#define Magazine_swap   return sndSwapMachinegun;                               // Swap sound
#define Magazine_take(_scale)
    typ_ammo[1] += 16 * _scale;
    trace("test")
#define Magazine_lose(_scale)
    typ_ammo[1] -= 16 * _scale;
    
#define Quiver_name   return "QUIVER";                                          // Name
#define Quiver_text   return "GET MORE @yBOLT AMMO@s";                          // Description
#define Quiver_area   return 0;                                                 // Spawns anywhere
#define Quiver_sprite return spr.Quiver;                                        // Sprite
#define Quiver_swap   return sndCrossReload;                                    // Swap sound
#define Quiver_take(_scale)
    typ_ammo[3] += 3 * _scale;
#define Quiver_lose(_scale)
    typ_ammo[3] -= 3 * _scale;

#define RoseBud_name   return "ROSE BUD";                                       // Name
#define RoseBud_text   return "START EACH LEVEL WITH AN @wSAPLING@s";           // Description
#define RoseBud_area   return 0;                                                // Spawns anywhere
#define RoseBud_sprite return spr.RoseBud;                                      // Sprite
#define RoseBud_swap   return sndSaplingSpawn;                                  // Swap sound
#define RoseBud_level_start
    repeat(trinket_get(self, "RoseBud")) instance_create(x, y, Sapling);

#define trinket_get(_player, _trinket)                                          return mod_script_call("mod", "trinkets", "trinket_get", _player, _trinket)
#define trinket_get_area(_trinket)                                              return mod_script_call("mod", "trinkets", "trinket_get_area", _trinket)
#define trinket_get_mod(_trinket)                                               return mod_script_call("mod", "trinkets", "trinket_get_mod", _trinket)
#define trinket_get_name(_trinket)                                              return mod_script_call("mod", "trinkets", "trinket_get_name", _trinket)
#define trinket_get_sprite(_trinket)                                            return mod_script_call("mod", "trinkets", "trinket_get_sprite", _trinket)
#define trinket_get_swap(_trinket)                                              return mod_script_call("mod", "trinkets", "trinket_get_swap", _trinket)
#define trinket_get_text(_trinket)                                              return mod_script_call("mod", "trinkets", "trinket_get_text", _trinket)
#define trinket_get_type(_trinket)                                              return mod_script_call("mod", "trinkets", "trinket_get_type", _trinket)
#define trinket_set(_trinket, _scale)                                           return mod_script_call("mod", "trinkets", "trinket_set", _trinket, _scale)

#macro spr                                                                      global.spr