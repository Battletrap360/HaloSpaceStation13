
/obj/machinery/overmap_vehicle/bullet_act(obj/item/projectile/P, def_zone)
	//todo: chance of component damage on hit
	//todo: targetting of specific components via def_zone
	P.penetrating = 0
	. = 1
	if(P.damage >= armour)
		hull_remaining -= P.damage / armour
		health_update()

/obj/machinery/overmap_vehicle/ex_act(severity)
	var/damage = 250 * (4 - severity)
	if(damage >= armour)
		hull_remaining -= damage / armour
		health_update()

//todo: emag to shutdown engines etc
/obj/machinery/overmap_vehicle/emp_act(severity)
	return

/obj/machinery/overmap_vehicle/proc/health_update()
	if(hull_remaining <= 0)

		disable_cruise()

		//destroy the vehicle
		var/turf/centre_turf = get_step(src.loc, NORTHEAST)		//spawn the explosion on the centre turf
		for(var/mob/M in contents)
			M.loc = get_step_rand(centre_turf)
			M.unset_machine()

		qdel(src)
		explosion(centre_turf, 2, 3, 4, 5)

/obj/machinery/overmap_vehicle/Destroy()
	. = ..()

	disable_cruise()

	//clean up references
	qdel(pixel_transform)
	qdel(overmap_object.pixel_transform)
	qdel(overmap_object)
	qdel(vehicle_controls)
	qdel(internal_atmosphere)

	//recycle the cruise transit area
	if(transit_area)
		transit_area.sprite_area_dark()
		transit_area.overmap_eject_object = null

		overmap_controller.virtual_areas_used -= transit_area
		overmap_controller.virtual_areas_unused += transit_area
		transit_area = null

	for(var/obj/machinery/overmap_vehicle/V in tracked_vehicles)
		stop_tracking_vehicle(V)