/datum/component/godtier
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/aspect/aspect

/datum/component/godtier/RegisterWithParent()
	RegisterSignal(parent, COMSIG_JUST_DEATH, .proc/just_death)
	RegisterSignal(parent, COMSIG_HEROIC_DEATH, .proc/heroic_death)
	RegisterSignal(parent, COMSIG_GODTIER_REVIVE, .proc/godtier_revive)
	RegisterSignal(parent, COMSIG_MOB_DEATH, .proc/on_death)
	//ok so
	//this is going to be some weird shit
	//basically i need a million heuristics to determine if a death is heroic. i'd rather not just ask the admins?
	//this is gonna be fairly rare so hopefully it's not TOO much performance impact
	//doubt it'll be worse than atmospherics anyway (i know this is a poor excuse)

/datum/component/godtier/proc/on_death(datum/source)
	if(C.mind.antag_datums.len || C.mind.damnation_type)
		return SEND_SIGNAL(COMSIG_JUST_DEATH)
