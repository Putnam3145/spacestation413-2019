/datum/status_effect/questbed
	id = "questbed"
	alert_type = /obj/screen/alert/status_effect/questbed
	var/datum/aspect/aspect = /datum/aspect

/datum/status_effect/questbed/on_creation(mob/living/new_owner, newaspect)
	aspect = newaspect

/datum/status_effect/questbed/tick()
	if(owner.stat==DEAD)
		owner.AddComponent(/datum/component/godtier,aspect)
		owner.revive(1)
		qdel(src)

/obj/screen/alert/status_effect/questbed
	name = "On a quest bed"
	desc = "You feel like you could rest here til you die."
	icon = 'spacestation413/icons/mob/screen_alert.dmi'
	icon_state = "questbed"

/obj/structure/bed/quest
	icon = 'spacestation413/icons/obj/bed.dmi'
	var/aspect = /datum/aspect

/obj/structure/bed/quest/post_buckle_mob(mob/living/M)
	..()
	if(ishuman(M))
		M.apply_status_effect(STATUS_EFFECT_QUESTBED,aspect)

/obj/structure/bed/quest/post_unbuckle_mob(mob/living/M)
	..()
	M.remove_status_effect(STATUS_EFFECT_QUESTBED)

