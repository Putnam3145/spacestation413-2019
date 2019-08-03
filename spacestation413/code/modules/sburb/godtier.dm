/datum/component/godtier
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/aspect/aspect
	var/mob/living/host_mob
	var/polling_ghosts = FALSE
	var/permadeath_heuristic = 0
	var/ghost_votes = 0
	var/last_health
	var/lastattacker

/datum/component/godtier/Initialize(datum/aspect/newAspect)
	if(!isliving(parent)
		return COMPONENT_INCOMPATIBLE
	host_mob = parent
	aspect = newAspect
	START_PROCESSING(SSsburb, src)

/datum/component/godtier/RegisterWithParent()
	RegisterSignal(parent,COMSIG_MOB_DEATH,.proc/on_death)
	RegisterSignal(parent,COMSIG_MOB_ITEM_ATTACK,.proc/item_attack)
	RegisterSignal(parent,COMSIG_ATOM_BULLET_ACT,.proc/bullet_act)
	ADD_TRAIT(host_mob, TRAIT_RESISTCOLD, "god_tier")
	ADD_TRAIT(host_mob, TRAIT_RESISTLOWPRESSURE, "god_tier")
	aspect.applyToMob(host_mob)
	last_health = host_mob.health

/datum/component/godtier/UnregisterFromParent()
	UnregisterSignal(parent,COMSIG_MOB_DEATH)
	UnregisterSignal(parent,COMSIG_MOB_ITEM_ATTACK)
	UnregisterSignal(parent,COMSIG_ATOM_BULLET_ACT)
	REMOVE_TRAIT(host_mob, TRAIT_RESISTCOLD, "god_tier")
	REMOVE_TRAIT(host_mob, TRAIT_RESISTLOWPRESSURE, "god_tier")
	aspect.removeFromMob(host_mob)


/datum/component/godtier/proc/bullet_act(datum/source,obj/item/projectile/P,def_zone)
	if(isliving(P.firer))
		last_attack_timer = 0

/datum/component/godtier/proc/item_attack(datum/source,mob/living/M,mob/living/user)
	if(M.mind && ckey(M.mind.key) == ckey(mind.key) && M.ckey && M.client) // is a player being attacked
		last_attack_timer = 0
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
	visible_message("[host_mob] begins glowing!")
	sleep(10)
	visible_message("[host_mob] has revived!")
	host_mob.fully_heal()
	return FALSE

/datum/component/godtier/process()
	last_attack_timer += 1
	if(!isliving(host_mob.pulling))
		permadeath_heuristic = max(-100,permadeath_heuristic-((last_attack_timer/20)**2)
	else
		pulling_timer += 1
		permadeath_heuristic += 1 // might could be 
	if(permadeath_heuristic>200)
		REMOVE_TRAIT(parent,TRAIT_NODEATH,"god_tier")
	else
		ADD_TRAIT(parent,TRAIT_NODEATH,"god_tier")
	if(lastattacker != host_mob.lastattacker || last_attack_timer<20)	
		permadeath_heuristic += abs(last_health - host_mob.health)
		last_attack_timer = 0
		lastattacker = host_mob.lastattacker
	if(host_mob.stat == UNCONSCIOUS)
		if(permadeath_heuristic > 0 )
			if(!polling_ghosts && host_mob.health<=HEALTH_THRESHOLD_NEARDEATH && poll_ghosts())
				REMOVE_TRAIT(parent, TRAIT_NODEATH,"god_tier")
				REMOVE_TRAIT(parent, TRAIT_RESISTCOLD, "god_tier")
				REMOVE_TRAIT(parent, TRAIT_RESISTLOWPRESSURE, "god_tier")
			else
				god_tier_revive()
		else
			unconscious_timer+=1
			if(unconscious_timer>10)
				god_tier_revive()


/datum/component/godtier/proc/on_death(datum/source)
	if(host_mob.suiciding)
		qdel(src)
		return //neither heroic nor just, just leave
	if(permadeath_heuristic<0)
		return god_tier_revive() // this shouldn't even be happening
	if(host_mob.mind.antag_datums.len || host_mob.hellbound)
		send_to_playing_players("<span style='color: #bb01ff; font-weight: bold; font-size: 15;'>JUST</span>")
	else
		send_to_playing_players("<span style='color: #ff9926; font-weight: bold; font-size: 15;'>HEROIC</span>")
	qdel(src)
