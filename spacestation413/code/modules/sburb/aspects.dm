/datum/aspect
	var/name = "null" // used for icon states for various things too
	var/desc = "Ceci n'est pas une aspect."
	var/list/spells
	var/list/active_spells
	var/list/traits
	var/list/passive_traits

/datum/aspect/proc/applyToMob(var/mob/living/M,active=0)
	for(var/T in traits)
		M.add_trait(T,"god_tier")
	if(!active)
		for(var/T in passive_traits)
			M.add_trait(T,"god_tier")
	if(M.mind)
		for(var/S in spells)
			var/obj/effect/proc_holder/spell/spell = new S(null)
			spell.charge_counter = 0
			M.mind.AddSpell(spell)
		if(active)
			for(var/S in active_spells)
				var/obj/effect/proc_holder/spell/spell = new S(null)
				spell.charge_counter = 0
				M.mind.AddSpell(spell)
	else
		for(var/S in spells)
			var/obj/effect/proc_holder/spell/spell = new S(null)
			spell.charge_counter = 0
			M.AddSpell(spell)
		if(active)
			for(var/S in active_spells)
				var/obj/effect/proc_holder/spell/spell = new S(null)
				spell.charge_counter = 0
				M.AddSpell(spell)

/datum/aspect/proc/removeFromMob(var/mob/living/M)
	for(var/T in traits | passive_traits)
		M.remove_trait(T,"god_tier")
	if(M.mind)
		for(var/S in spells | active_spells)
			var/obj/effect/proc_holder/spell/spell = S
			M.mind.RemoveSpell(spell)
	else
		for(var/S in spells | active_spells)
			var/obj/effect/proc_holder/spell/spell = S
			M.RemoveSpell(spell)

/datum/aspect/breath
	name = "breath"
	desc = "Nothing to do with freedom."
	spells = list(
		/obj/effect/proc_holder/spell/aoe_turf/repulse/breath
	)
	active_spells = list(
		/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/breath
	)
	traits = list(
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTHEAT
	)
	passive_traits = list(
		TRAIT_NOBREATH, // ironic.
		TRAIT_PUSHIMMUNE
	)

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/breath
	name = "Wind form"
	clothes_req = FALSE
	desc = "You turn into air, temporarily making you invisible and move anywhere the wind can."
	charge_max = 200
	jaunt_phased_mob = /obj/effect/dummy/phased_mob/spell_jaunt/breath

/obj/effect/dummy/phased_mob/spell_jaunt/breath/relaymove(var/mob/user, direction)
	if ((movedelay > world.time) || reappearing || !direction)
		return
	var/turf/newLoc = get_step(src,direction)
	setDir(direction)

	movedelay = world.time + movespeed

	if(newLoc.flags_1 & NOJAUNT_1 )
		to_chat(user, "<span class='warning'>Some strange aura is blocking the way.</span>")
		return

	if(newLoc.blocks_air)
		to_chat(user, "<span class='warning'>Air can't pass through that!</span>")
		return

	forceMove(newLoc)

/obj/effect/proc_holder/spell/aoe_turf/repulse/breath
	name = "Blow away"
	desc = "Throw back attackers using your breath powers."
	charge_max = 100
	clothes_req = FALSE
	antimagic_allowed = TRUE
	range = 7
	invocation_type = "none"
	sound = 'sound/effects/space_wind.ogg'
	anti_magic_check = FALSE

/datum/aspect/light
	name = "light"
	desc = "Luck, fortune, knowledge, what isn't it?"
	traits = list(
		TRAIT_SURGEON, // no technology req for surgery
		TRAIT_NOSLIPALL, // think contessa i guess
		TRAIT_XRAY_VISION // duh
	)

/datum/aspect/time
	name = "time"
	desc = "DO NOT MESS WITH TIME."
	spells = list(
		/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/time_aspect,
		/obj/effect/proc_holder/spell/self/dejavu
	)

/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/time_aspect
	invocation_type = "none"
	clothes_req = FALSE
	charge_max = 200

/obj/effect/proc_holder/spell/self/dejavu
	name = "Revert" //magic the gathering joke here
	desc = "Saves the current moment, then brings you back to it in 10 seconds."
	clothes_req = FALSE
	charge_max = 200
	invocation_type = "none"
	action_icon = 'spacestation413/icons/mob/actions.dmi'
	action_icon_state = "time"

/obj/effect/proc_holder/spell/self/dejavu/can_cast(mob/user = usr)
	. = ..()
	if(!isturf(user.loc))
		return FALSE

/obj/effect/proc_holder/spell/self/dejavu/cast(mob/user = usr)
	. = ..()
	target.AddComponent(/datum/component/dejavu,1)

/datum/aspect/space
	name = "space"
	desc = "You know. The... not-thing... around you."
	spells = list(
		/obj/effect/proc_holder/spell/targeted/area_teleport/space_aspect
	)

/obj/effect/proc_holder/spell/targeted/area_teleport/space_aspect
	say_destination = FALSE
	invocation_area = FALSE
	name = "Teleport"
	desc = "Use your space powers to go to a place of your choice."
	var/obj/effect/temp_visual/dir_setting/ninja/phase/out/spot1
	var/obj/effect/temp_visual/dir_setting/ninja/phase/spot2

/obj/effect/proc_holder/spell/targeted/area_teleport/space_aspect/invocation(area/chosenarea = null,mob/living/user = usr)
	..()
	spot1 = new(get_turf(user), user.dir)

/obj/effect/proc_holder/spell/targeted/area_teleport/space_aspect/cast(list/targets,area/thearea,mob/user = usr)
	..()
	spot2 = new(get_turf(user), user.dir)

/obj/effect/proc_holder/spell/targeted/touch/green_sun_blink
	name = "Target Blink"
	desc = "Teleports to a nearby location."
	hand_path = /obj/item/melee/touch_attack/rathens

	school = "evocation"
	charge_max = 400
	clothes_req = TRUE
	cooldown_min = 40 //90 deciseconds reduction per rank

	action_icon_state = "gib"

/obj/item/green_sun_blink
	var/datum/action/innate/dash/space/jaunt

/datum/action/innate/dash/space
	current_charges = 2
	max_charges = 2
	charge_rate = 500
	recharge_sound = null

/obj/item/green_sun_blink/Initialize()
	. = ..()
	jaunt = new(src)

/obj/item/green_sun_blink/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	jaunt.Teleport(user, target)
	if(jaunt.charges == 0)
		QDEL_NULL(src)

/obj/effect/proc_holder/spell/targeted/touch/superblink
	hand_path = obj/item/green_sun_blink
	name = "Targeted blink"
	desc = "Lets you teleport to a location of your choosing in your line of sight twice."
	charge_max = 100
	action_state_icon = "space"

/datum/aspect/life
	name = "life"
	desc = "Hopefully something you have some of."

/datum/aspect/hope
	name = "hope"
	desc = "Gay space magic."

/datum/aspect/void
	name = "void"
	desc = "You know. The... not-thing... not... around you."

/datum/aspect/heart
	name = "heart"
	desc = "You ever wonder about cloning?"

/datum/aspect/doom
	name = "doom"
	desc = "Where you'll end up."

/datum/aspect/blood
	name = "blood"
	desc = "Every sense of the word."

/datum/aspect/mind
	name = "mind"
	desc = "Its distinction from heart is dubious, given cloning and MMIs, but hey."

/datum/aspect/rage
	name = "rage"
	desc = "HNNNNNNNNNGGGGGGH!"
