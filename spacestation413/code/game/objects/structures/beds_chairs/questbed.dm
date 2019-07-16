#define STATUS_EFFECT_QUESTBED /datum/status_effect/questbed

#define STATUS_EFFECT_GODTIER /datum/status_effect/godtier

#define ASPECT_NONE = 0 //nothing for now, don't worry about it

/datum/status_effect/questbed
	var/id = "questbed"
	var/aspect = ASPECT_NONE
	alert_type = /obj/screen/alert/status_effect/questbed

/datum/status_effect/questbed/on_creation(mob/living/new_owner, newaspect)
	aspect = newaspect

/datum/status_effect/questbed/tick()
	if(owner.stat==DEAD)
		owner.apply_status_effect(STATUS_EFFECT_GODTIER,aspect)

/obj/screen/alert/status_effect/questbed
	name = "On a quest bed"
	desc = "You feel like you could rest here til you die."
	icon = 'spacestation413/icons/mob/screen_alert.dmi'
	icon_state = "questbed"

/obj/structure/bed/quest
	icon = 'spacestation413/icons/obj/bed.dmi'
	var/aspect = ASPECT_NONE // we're gonna do some shit.

/obj/structure/bed/quest/post_buckle_mob(mob/living/M)
	..()
	if(ishuman(M))
		M.apply_status_effect(STATUS_EFFECT_QUESTBED,aspect)

/obj/structure/bed/quest/post_unbuckle_mob(mob/living/M)
	..()
	M.remove_status_effect(STATUS_EFFECT_QUESTBED)

