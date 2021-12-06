/*
	- trinkets should natively support scaling, and if you have duplicates it should combine scales
	- collects all trinkets on game_start from a 'trinket_names' script
	- variable trinket max per player
*/

#define init
    TRINKETS = {
    	None : { // dummy trinket
    		trinket_mod  : mod_current,
    		trinket_type : "mod"
    	}
    };
    
    global.trinket_step     = script_bind_step(trinket_step, 0);
    global.prompt_collision = script_bind_step(prompt_collision, 0);
    global.level_loading    = false;

	if(fork()) { // Make sure it captures sample trinkets, if loaded
		wait 0;
		trinkets_find();
		trace(TRINKETS);
		exit;
	}

#macro TRINKET_SCRIPTS															["step", "enter", "take", "lose", "destroy"]
#macro TRINKETS 																global.trinkets

#define chat_command
	switch(argument0){
		case "trinket_spawn":
			trinket_create(mouse_x, mouse_y, argument1, 1);
			return true;
		break;
	}
	
	return false;

#define game_start
	trinkets_find();

#define level_start
	with(instances_matching_ne(Player, "trinket_list", null)) {
		if(array_length(trinket_list)) for(var i = 0; i < array_length(trinket_list); i++) {
			script_ref_call([trinket_get_type(trinket_list[i][0]), trinket_get_mod(trinket_list[i][0]), `${trinket_list[i][0]}_level_start`]);
		}
	}

#define step
	if(!instance_exists(global.trinket_step))     global.trinket_step = script_bind_step(trinket_step, 0);
	if(!instance_exists(global.prompt_collision)) global.prompt_collision = script_bind_step(prompt_collision, 0);
	
	 // Thanks Golden Epsilon! //
	if(instance_exists(GenCont) || instance_exists(Menu)){
		global.level_loading = true;
	}
	else if(global.level_loading){
		global.level_loading = false;
		level_start();
	}

#define trinket_step
	with(instances_matching_ne(Player, "trinket_list", null)) {
		if(array_length(trinket_list)) for(var i = 0; i < array_length(trinket_list); i++) {
			script_ref_call([trinket_get_type(trinket_list[i][0]), trinket_get_mod(trinket_list[i][0]), `${trinket_list[i][0]}_step`]);
		}
	}

#define prompt_collision
	 // Prompts:
	//Note: This code IS basically just taken from TE, but it means that it works alongside TE prompts.
	var _inst = instances_matching(CustomObject, "name", "TrinketPrompt");
	if(array_length(_inst)){
		 // Reset:
		var _instReset = instances_matching_ne(_inst, "pick", -1);
		if(array_length(_instReset)){
			with(_instReset){
				pick = -1;
			}
		}
		
		 // Player Collision:
		if(instance_exists(Player)){
			_inst = instances_matching(_inst, "visible", true);
			if(array_length(_inst)){
				with(instances_matching(Player, "visible", true)){
					var _id = id;
					if(
						place_meeting(x, y, CustomObject)
						&& !place_meeting(x, y, IceFlower)
						&& !place_meeting(x, y, CarVenusFixed)
					){
						var _noVan = true;
						
						 // Van Check:
						if(instance_exists(Van) && place_meeting(x, y, Van)){
							with(instances_meeting(x, y, instances_matching(Van, "drawspr", sprVanOpenIdle))){
								if(place_meeting(x, y, other)){
									_noVan = false;
									break;
								}
							}
						}
						
						if(_noVan){
							var	_nearest  = noone,
								_maxDis   = null,
								_maxDepth = null;
								
							// Find Nearest Touching Indicator:
							if(instance_exists(nearwep)){
								_maxDis   = point_distance(x, y, nearwep.x, nearwep.y);
								_maxDepth = nearwep.depth;
							}
							with(instances_meeting(x, y, _inst)){
								if(place_meeting(x, y, other)){
									if(!instance_exists(creator) || creator.visible){
										if(!is_array(on_meet) || mod_script_call(on_meet[0], on_meet[1], on_meet[2])){
											if(_maxDepth == null || depth < _maxDepth){
												_maxDepth = depth;
												_maxDis   = null;
											}
											if(depth == _maxDepth){
												var _dis = point_distance(x, y, other.x, other.y);
												if(_maxDis == null || _dis < _maxDis){
													_maxDis  = _dis;
													_nearest = self;
												}
											}
										}
									}
								}
							}
							
							 // Secret IceFlower:
							with(_nearest){
								if(!instance_exists(nearwep)) {
									nearwep = instance_create(x + xoff, y + yoff, IceFlower);
									with(nearwep){
										name         = _nearest.text;
										x            = xstart;
										y            = ystart;
										xprevious    = x;
										yprevious    = y;
										visible      = false;
										mask_index   = mskNone;
										sprite_index = mskNone;
										spr_idle     = mskNone;
										spr_walk     = mskNone;
										spr_hurt     = mskNone;
										spr_dead     = mskNone;
										spr_shadow   = -1;
										snd_hurt     = -1;
										snd_dead     = -1;
										size         = 0;
										team         = 0;
										my_health    = 99999;
										nexthurt     = current_frame + 99999;
									}
								}
								with(_id){
									nearwep = _nearest.nearwep;
									if(button_pressed(index, "pick")){
										_nearest.pick = index;
										if(instance_exists(_nearest.creator) && "on_pick" in _nearest.creator){
											with(_nearest.creator){
												script_ref_call(on_pick, _id.index, _nearest.creator, _nearest);
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}

#define draw_shadows
	with(instances_matching(CustomObject, "name", "Trinket")) {
		draw_sprite_ext(spr_shadow, -1, x + spr_shadow_x, y + spr_shadow_y, image_xscale * right, image_yscale, image_angle, c_white, 1);
	}

//#region TRINKET OBJECTS
#define trinket_create(_x, _y, _trinket, _scale)
	with(TrinketPickup_create(_x, _y)) {
		 // Vars:
		trinket = _trinket;
		scale   = _scale;
		prompt.text = trinket_get_name(_trinket);
		
		 // Visuals
		sprite_index = trinket_get_sprite(trinket);
		
		 // Destroy script:
		if(mod_script_exists(trinket_get_type(trinket), trinket_get_mod(trinket), `${trinket}_destroy`)) {
			on_destroy = script_ref_create_ext(trinket_get_type(trinket), trinket_get_mod(trinket), `${trinket}_destroy`);
		}
		
		return self;
	}
	
	return noone;

#define TrinketPickup_create(_x, _y)
	with(instance_create(_x, _y, CustomObject)) {
		 // Vars:
		name    = "Trinket";
		trinket = "None";
		scale   = 1;
		noinput = 0;
		
		// Visuals:
		depth        = -1;
		mask_index   = mskWepPickup;
		image_speed  = 0.4;
		image_alpha  = -1;
		spr_shadow   = shd24;
		spr_shadow_x = 0;
		spr_shadow_y = -2;
		right   	 = choose(1, -1);
		prompt       = prompt_create("TRINKET");
		
		on_step = script_ref_create(TrinketPickup_step);
		on_pick = script_ref_create(TrinketPickup_pick);
		on_draw = script_ref_create(TrinketPickup_draw);
		
		return self;
	}
	
	return noone;

#define TrinketPickup_draw
	// Account for 'right' variable:
	image_alpha = abs(image_alpha);
	draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * right, image_yscale, image_angle, image_blend, image_alpha);
	image_alpha *= -1;

#define TrinketPickup_step
	noinput -= current_time_scale;

#define TrinketPickup_pick
	if(!noinput) {
		 // Swap trinkets when interacted:
		var _trinket = trinket;
		
		with(prompt.pick) {
			if("trinket_list" in self and "trinket_max" in self) if(array_length(trinket_list) = trinket_max) {
				with(trinket_create(x, y, trinket_list[0][0], trinket_list[0][1])) {
					noinput = 1;
				}
				
				with(instance_create(x, y + 6, RabbitPaw)) {
					image_yscale = 0.6;
				}
			}
			
			trinket_set(_trinket, other.scale);
			
			with(instance_create(x, y, PopupText)) {
				text = `${trinket_get_name(_trinket)}!`
			}
			
			sound_play_pitch(trinket_get_swap(_trinket), 1 + random(0.3));
			
			with(other) {
				instance_destroy();
			}
		}
	}
	
#define TrinketPickup_destroy
	script_ref_call([trinket_get_type(trinket), trinket_get_mod(trinket), `${trinket}_destroy`]);
	
//#endregion



//#region TRINKET SCRIPTS
#define trinket_get(_player, _trinket)
	/*
		Returns whether the chosen Player (or any player, if -1 is given instead of an object index) holds the given trinket. If the trinket 
		has been scaled up, or if the Player holds multiple of the same trinket, it instead returns the combined scale of the given trinket.
		
		Ex:
			trinket_get(self, "Cigarettes");
	*/

	var _s = 0,
		_p = _player = -1 ? Player : _player;
	
	with(_p) {
		if("trinket_list" in self) with(trinket_list) {
			if(self[0] = _trinket) _s += self[1];
		}
	}
	
	return _s;

#define trinket_get_area(_trinket)												
	var _a = mod_script_call(trinket_get_type(_trinket), trinket_get_mod(_trinket), `${_trinket}_area`);
	
	return (!is_undefined(_a) and is_real(_a) ? _a : -1);  
	
#define trinket_get_mod(_trinket)												
	var _m = lq_get(lq_get(TRINKETS, _trinket), "trinket_mod");
	
	return (!is_undefined(_m) ? _m : "mod");
	
#define trinket_get_name(_trinket)												
	var _n = mod_script_call(trinket_get_type(_trinket), trinket_get_mod(_trinket), `${_trinket}_name`);
	
	return (!is_undefined(_n) ? _n : _trinket);
	
#define trinket_get_sprite(_trinket)												
	var _s = mod_script_call(trinket_get_type(_trinket), trinket_get_mod(_trinket), `${_trinket}_sprite`);
	
	return (!is_undefined(_s) ? _s : mskNone);  

#define trinket_get_swap(_trinket)
	var _s = mod_script_call(trinket_get_type(_trinket), trinket_get_mod(_trinket), `${_trinket}_swap`);
	
	return (!is_undefined(_s) ? _s : sndPizzaBoxBreak);

#define trinket_get_text(_trinket)												
	var _t = mod_script_call(trinket_get_type(_trinket), trinket_get_mod(_trinket), `${_trinket}_text`);

	return (!is_undefined(_t) ? _t : "mod");
	
#define trinket_get_type(_trinket)												
	var _t = lq_get(lq_get(TRINKETS, _trinket), "trinket_type");

	return (!is_undefined(_t) ? _t : "mod");

#define trinket_set(_trinket, _scale)
    /* 
        Called from a Player object. Grants the Player the given trinket, and removes the oldest trinket if the Player has the maximum amount.
        
        Ex:
        	with(Player) {
            	trinket_set("Cigarettes", 1);
        	}
    */

    if("trinket_list" in self and "trinket_max" in self) {
         // Remove the oldest trinket if at the maximum amount:
        if(array_length(trinket_list) >= trinket_max) {
             // Call the drop script:
            script_ref_call([trinket_get_type(trinket_list[0][0]), trinket_get_mod(trinket_list[0][0]), `${trinket_list[0][0]}_lose`, _scale]);
            
             // Remove the oldest trinket:
            trinket_list = array_delete(trinket_list, 0);
        }
        
         // Call the pickup script:
        script_ref_call([trinket_get_type(_trinket), trinket_get_mod(_trinket), `${_trinket}_take`, _scale]);
        
         // Add the trinket to your list of available trinkets:
        array_push(trinket_list, [_trinket, _scale]);
    }
    
    else {
        trinket_list = [[_trinket, _scale]];
        trinket_max  = 1;
    }
    
#define trinkets_find
	/*
		Gets all of the available trinkets and puts them into the trinket list
	*/
	TRINKETS = {};

	var _mods  = ["mod", "weapon", "race", "skin", "area", "skill", "crown"],
		_names = [], 
		_type  = "";
	
	with(_mods) {
		_type = self; // Track current mod type
		_names = mod_get_names(_type); // Get all mods of that type
		
		if(array_length(_names)) with(_names) { // Check if there are any mods of that type
			if(mod_script_exists(_type, self, "trinket_names")) with(mod_script_call(other, self, "trinket_names")) { // Get all of the names of the trinkets from those mods
			
				 // Add the trinkets to the list
				lq_set(TRINKETS, self, {
					trinket_mod  : other,
					trinket_type : _type
				});
			}
		}
	}
//#endregion



//#region GENERIC SCRIPTS
#define array_delete(_array, _index)
	/*
		Returns a new array with the value at the given index removed
		
		Ex:
			array_delete([1, 2, 3], 1) == [1, 3]
	*/
	
	var _new = array_slice(_array, 0, _index);
	
	array_copy(_new, array_length(_new), _array, _index + 1, array_length(_array) - (_index + 1));
	
	return _new;

#define instances_meeting(_x, _y, _obj)
	/*
		Returns all instances whose bounding boxes overlap the calling instance's bounding box at the given position
		Much better performance than manually performing 'place_meeting(x, y, other)' on every instance
	*/
	
	var	_tx = x,
		_ty = y;
		
	x = _x;
	y = _y;
	
	var _inst = instances_matching_ne(instances_matching_le(instances_matching_ge(instances_matching_le(instances_matching_ge(_obj, "bbox_right", bbox_left), "bbox_left", bbox_right), "bbox_bottom", bbox_top), "bbox_top", bbox_bottom), "id", id);
	
	x = _tx;
	y = _ty;
	
	return _inst;

#define prompt_create(_text)
	/*
		Creates an E key prompt with the given text that targets the current instance
	*/
	
	with(TrinketPrompt_create(x, y)){
		text    = _text;
		creator = other;
		depth   = other.depth;
		
		return self;
	}
	
	return noone;
	
#define TrinketPrompt_create(_x, _y)
	with(instance_create(_x, _y, CustomObject)){
		 // Vars:
		name       = "TrinketPrompt";
		mask_index = mskWepPickup;
		persistent = true;
		creator    = noone;
		nearwep    = noone;
		depth      = 0; // Priority (0==WepPickup)
		pick       = -1;
		xoff       = 0;
		yoff       = 0;
		
		 // Events:
		on_begin_step = script_ref_create(TrinketPrompt_begin_step);
		on_end_step   = script_ref_create(TrinketPrompt_end_step);
		on_cleanup    = script_ref_create(TrinketPrompt_cleanup);
		on_meet = null;
		
		return self;
	}
	
#define TrinketPrompt_begin_step
	with(nearwep){
		instance_delete(self);
	}
	
#define TrinketPrompt_end_step
	 // Follow Creator:
	if(creator != noone){
		if(instance_exists(creator)){
			if(instance_exists(nearwep)){
				with(nearwep){
					x += other.creator.x - other.x;
					y += other.creator.y - other.y;
					visible = true;
				}
			}
			x = creator.x;
			y = creator.y;
		}
		else instance_destroy();
	}
	
#define TrinketPrompt_cleanup
	with(nearwep){
		instance_delete(self);
	}
//#endregion