/datum/component/godtier
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/aspect/aspect
	var/permadeath_heuristic = 0
	var/ghost_votes = 0

/datum/component/godtier/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_DEATH, .proc/on_death)
	//ok so
	//this is going to be some weird shit
	//basically i need a million heuristics to determine if a death is heroic. i'd rather not just ask the admins?
	//this is gonna be fairly rare so hopefully it's not TOO much performance impact
	RegisterSignal(parent,COMSIG_MOB_ITEM_ATTACK,.proc/item_attack)
	RegisterSignal(parent,)

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
	ghost_votes = 0
	for(var/mob/dead/observer/G in GLOB.player_list)
		if(!G.key || !G.client)
			continue
		poll_ghost(G)
	sleep(101)
	return ghost_votes > 0

/datum/component/godtier/proc/god_tier_revive()
	var/mob/living/M = parent
	visible_message("[M] begins glowing!")
	sleep(10)
	visible_message("[M] has revived!")
	M.revive(full_heal = TRUE)
	return FALSE

/datum/component/godtier/proc/on_death(datum/source)
	var/mob/living/M = parent
	if(M.suiciding)
		return //neither heroic nor just, just leave
	if(permadeath_heuristic<0)
		return god_tier_revive()
	else if(permadeath_heuristic > 20 || poll_ghosts())
		if(M.mind.antag_datums.len || M.hellbound)
			send_to_playing_players("<span style='color: #bb01ff; font-weight: bold; font-size: 15;'>JUST</span>")
		else
			send_to_playing_players("<span style='color: #ff9926; font-weight: bold; font-size: 15;'>HEROIC</span>")
		return TRUE
	else 
		return god_tier_revive()
