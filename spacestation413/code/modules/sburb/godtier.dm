/datum/component/godtier
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/aspect/aspect
	var/mob/living/parentAsLiving
	var/polling_ghosts = FALSE
	var/permadeath_heuristic = 0
	var/ghost_votes = 0

/datum/component/godtier/RegisterWithParent()
	RegisterSignal(parent,COMSIG_MOB_DEATH,.proc/on_death)
	parentAsLiving = parent
	ADD_TRAIT(parentAsLiving, TRAIT_RESISTCOLD, "god_tier")
	ADD_TRAIT(parentAsLiving, TRAIT_RESISTLOWPRESSURE, "god_tier")
	//ok so
	//this is going to be some weird shit
	//basically i need a million heuristics to determine if a death is heroic. i'd rather not just ask the admins?
	//this is gonna be fairly rare so hopefully it's not TOO much performance impact
	RegisterSignal(parent,COMSIG_MOB_ITEM_ATTACK,.proc/item_attack)

/datum/component/godtier/proc/item_attack(datum/source,mob/living/M,mob/living/user)
	if(M.mind && ckey(M.mind.key) == ckey(mind.key) && M.ckey && M.client) // is a player being attacked
		permadeath_heuristic += (M.maxHealth - M.health) / (M.maxHealth/100) // so e.g. it's +100 per attack when health is below 0

/datum/component/godtier/proc/poll_ghost(mob/M)
	set waitfor = 0
	SEND_SOUND(M, 'sound/misc/notice2.ogg')
	window_flash(M.client)
	switch(askuser(M,"Was [parent]'s death heroic/just (yes for either, no for neither)?'","Please answer in [DisplayTimeText(100)]!","Yes","No","Abstain" StealFocus=0, Timeout=100))
		if(1)
			ghost_votes += 1
			to_chat("You have voted for death.")
		if(2)
			ghost_votes -= 1
			to_chat("You have voted for revival.")
		else
			to_chat("You have abstained from voting.")

/datum/component/godtier/proc/poll_ghosts()
	polling_ghosts = TRUE
	ghost_votes = 0
	for(var/mob/dead/observer/G in GLOB.player_list)
		if(!G.key || !G.client)
			continue
		poll_ghost(G)
	sleep(101)
	polling_ghosts = FALSE
	return ghost_votes > 0

/datum/component/godtier/proc/god_tier_revive()
	visible_message("[parentAsLiving] begins glowing!")
	sleep(10)
	visible_message("[parentAsLiving] has revived!")
	parentAsLiving.fully_heal()
	return FALSE

/datum/component/godtier/process()
	permadeath_heuristic = max(-100,permadeath_heuristic-0.05)
	if(permadeath_heuristic>100)
		REMOVE_TRAIT(parent,TRAIT_NODEATH,"god_tier")
	else
		ADD_TRAIT(parent,TRAIT_NODEATH,"god_tier")
	if(parentAsLiving.stat == UNCONSCIOUS)
		if(permadeath_heuristic > 0 )
			if(!polling_ghosts && parentAsLiving.health<=HEALTH_THRESHOLD_NEARDEATH && poll_ghosts())
				REMOVE_TRAIT(parent,TRAIT_NODEATH,"god_tier")
				REMOVE_TRAIT(parent, TRAIT_RESISTCOLD, "god_tier")
				REMOVE_TRAIT(parent, TRAIT_RESISTLOWPRESSURE, "god_tier")
			else
				god_tier_revive()
		else
			unconscious_timer+=0.05
			if(unconscious_timer>10)
				god_tier_revive()


/datum/component/godtier/proc/on_death(datum/source)
	if(parentAsLiving.suiciding)
		qdel(src)
		return //neither heroic nor just, just leave
	if(permadeath_heuristic<0)
		return god_tier_revive() // this shouldn't even be happening
	if(parentAsLiving.mind.antag_datums.len || parentAsLiving.hellbound)
		send_to_playing_players("<span style='color: #bb01ff; font-weight: bold; font-size: 15;'>JUST</span>")
	else
		send_to_playing_players("<span style='color: #ff9926; font-weight: bold; font-size: 15;'>HEROIC</span>")
	qdel(src)
