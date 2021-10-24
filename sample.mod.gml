#define init
    spr = {};
    
    with(spr) {
        /* TRINKETS */
        AmmunitionBox                                                           = sprite_add("sprites/sprAmmunitionBox.png", 1, 10, 10);
        FirstAidKit                                                             = sprite_add("sprites/sprFirstAidKit.png", 1, 10, 10);
    }

#define trinket_names
    return ["AmmunitionBox", "FirstAidKit"];
    
#define AmmunitionBox_name   return "AMMUNITION BOX";                           // Name
#define AmmunitionBox_text   return "@yAMMO PICKUPS@s LAST LONGER";             // Description
#define AmmunitionBox_area   return 0;                                          // Spawns anywhere
#define AmmunitionBox_sprite return spr.AmmunitionBox;                          // Sprite
#define AmmunitionBox_swap   return sndAmmoChest;                               // Swap sound
#define AmmunitionBox_step
    with(instances_matching(AmmoPickup, "trinket_ammunitionbox", null)) {
        trinket_ammunitionbox = true;
        alarm0 += 120; // Ammo pickups last longer
        trace(alarm0);
    }

#define FirstAidKit_name   return "FIRST AID KIT";                              // Name
#define FirstAidKit_text   return "@rHEALTH PICKUPS@s LAST LONGER";             // Description
#define FirstAidKit_area   return 0;                                            // Spawns anywhere
#define FirstAidKit_sprite return spr.FirstAidKit;                              // Sprite
#define FirstAidKit_swap   return sndHealthChest;                               // Swap sound
#define FirstAidKit_step
    with(instances_matching(HPPickup, "trinket_firstaidkit", null)) {
        trinket_firstaidkit = true;
        alarm0 += 120; // Ammo pickups last longer
    }

#macro spr                                                                      global.spr