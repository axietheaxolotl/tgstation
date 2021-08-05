#define MAX_NOTICES 5

/obj/structure/noticeboard
	name = "notice board"
	desc = "A board for pinning important notices upon. It is made of the finest Spanish cork."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "noticeboard"
	density = FALSE
	anchored = TRUE
	max_integrity = 150
	/// Current number of a pinned notices
	var/notices = 0

/obj/structure/noticeboard/directional/north
	dir = SOUTH
	pixel_y = 32

/obj/structure/noticeboard/directional/south
	dir = NORTH
	pixel_y = -32

/obj/structure/noticeboard/directional/east
	dir = WEST
	pixel_x = 32

/obj/structure/noticeboard/directional/west
	dir = EAST
	pixel_x = -32

/obj/structure/noticeboard/Initialize(mapload)
	. = ..()

	if(!mapload)
		return

	for(var/obj/item/I in loc)
		if(notices >= MAX_NOTICES)
			break
		if(istype(I, /obj/item/paper))
			I.forceMove(src)
			notices++
	update_icon()

	AddElement(/datum/element/wall_mount)

//attaching papers!!
/obj/structure/noticeboard/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/paper) || istype(O, /obj/item/photo))
		if(!allowed(user))
			to_chat(user, span_warning("You are not authorized to add notices!"))
			return
		if(notices < MAX_NOTICES)
			if(!user.transferItemToLoc(O, src))
				return
			notices++
			update_icon()
			to_chat(user, span_notice("You pin the [O] to the noticeboard."))
		else
			to_chat(user, span_warning("The notice board is full!"))
	else
		return ..()

/obj/structure/noticeboard/ui_state(mob/user)
	return GLOB.physical_state

/obj/structure/noticeboard/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NoticeBoard", name)
		ui.open()

/obj/structure/noticeboard/ui_data(mob/user)
	var/list/data = list()
	data["allowed"] = allowed(user)
	data["items"] = list()
	for(var/obj/item/content in contents)
		var/list/content_data = list(
			name = content.name,
			ref = REF(content)
		)
		data["items"] += list(content_data)
	return data

/obj/structure/noticeboard/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/auth = allowed(user)
	var/dat = "<B>[name]</B><BR>"
	for(var/obj/item/P in src)
		if(istype(P, /obj/item/paper))
			dat += "<A href='?src=[REF(src)];read=[REF(P)]'>[P.name]</A> [auth ? "<A href='?src=[REF(src)];write=[REF(P)]'>Write</A> <A href='?src=[REF(src)];remove=[REF(P)]'>Remove</A>" : ""]<BR>"
		else
			dat += "<A href='?src=[REF(src)];read=[REF(P)]'>[P.name]</A> [auth ? "<A href='?src=[REF(src)];remove=[REF(P)]'>Remove</A>" : ""]<BR>"
	user << browse("<HEAD><TITLE>Notices</TITLE></HEAD>[dat]","window=noticeboard")
	onclose(user, "noticeboard")

/obj/structure/noticeboard/Topic(href, href_list)
	..()
	usr.set_machine(src)
	if(href_list["remove"])
		if(usr.stat != CONSCIOUS || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED)) //For when a player is handcuffed while they have the notice window open
			return
		var/obj/item/I = locate(href_list["remove"]) in contents
		if(istype(I) && I.loc == src)
			I.forceMove(usr.loc)
			usr.put_in_hands(I)
			notices--
			update_icon()

	var/obj/item/item = locate(params["ref"]) in contents
	if(!istype(item) || item.loc != src)
		return

	var/mob/user = usr

	switch(action)
		if("examine")
			if(istype(item, /obj/item/paper))
				item.ui_interact(user)
			else
				user.examinate(item)
			return TRUE
		if("remove")
			if(!allowed(user))
				return
			remove_item(item, user)
			return TRUE

/**
 * Removes an item from the notice board
 *
 * Arguments:
 * * item - The item that is to be removed
 * * user - The mob that is trying to get the item removed, if there is one
 */
/obj/structure/noticeboard/proc/remove_item(obj/item/item, mob/user)
	item.forceMove(drop_location())
	if(user)
		user.put_in_hands(item)
		balloon_alert(user, "removed from board")
	notices--
	icon_state = "nboard0[notices]"

/obj/structure/noticeboard/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron (loc, 1)
	for(var/obj/item/content in contents)
		remove_item(content)
	qdel(src)

/obj/structure/noticeboard/update_overlays()
	. = ..()
	if(notices)
		. += "notices_[notices]"

// Notice boards for the heads of staff (plus the qm)

/obj/structure/noticeboard/captain
	name = "Captain's Notice Board"
	desc = "Important notices from the Captain."
	req_access = list(ACCESS_CAPTAIN)

/obj/structure/noticeboard/hop
	name = "Head of Personnel's Notice Board"
	desc = "Important notices from the Head of Personnel."
	req_access = list(ACCESS_HOP)

/obj/structure/noticeboard/ce
	name = "Chief Engineer's Notice Board"
	desc = "Important notices from the Chief Engineer."
	req_access = list(ACCESS_CE)

/obj/structure/noticeboard/hos
	name = "Head of Security's Notice Board"
	desc = "Important notices from the Head of Security."
	req_access = list(ACCESS_HOS)

/obj/structure/noticeboard/cmo
	name = "Chief Medical Officer's Notice Board"
	desc = "Important notices from the Chief Medical Officer."
	req_access = list(ACCESS_CMO)

/obj/structure/noticeboard/rd
	name = "Research Director's Notice Board"
	desc = "Important notices from the Research Director."
	req_access = list(ACCESS_RD)

/obj/structure/noticeboard/qm
	name = "Quartermaster's Notice Board"
	desc = "Important notices from the Quartermaster."
	req_access = list(ACCESS_QM)

/obj/structure/noticeboard/staff
	name = "Staff Notice Board"
	desc = "Important notices from the heads of staff."
	req_access = list(ACCESS_HEADS)

#undef MAX_NOTICES
