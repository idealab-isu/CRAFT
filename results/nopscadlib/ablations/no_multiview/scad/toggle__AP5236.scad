// Parameters
body_diameter_mm = 7; //[3.5:14:0.1]
overall_height_mm = 13.6; //[6.8:27.2:0.1]
body_height_mm = 10; //[5:20:0.1]
actuator_height_mm = 3.6; //[1.8:7.2:0.1]
actuator_diameter_mm = 3; //[1.5:6:0.1]
lever_length_mm = 8; //[4:16:0.1]
lever_diameter_mm = 2; //[1:4:0.1]
bushing_diameter_mm = 7; //[3.5:14:0.1]
bushing_height_mm = 3; //[1.5:6:0.1]
panel_thickness_mm = 3; //[1.5:6:0.1]
seat_overhang_mm = 1.5; //[0.75:3:0.1]
seat_thickness_mm = 0.8; //[0.4:1.6:0.1]
nut_seat_diameter_mm = 11; //[5.5:22:0.1]
overlap_mm = 1; //[0.5:2:0.1]
lever_tilt_deg = 15; //[0:30:1]

// Toggle switch - complete geometry (all parts physically connected)
module toggle() {
  color("DimGray")
  union() {

    // Main cylindrical body (centered at Z=0)
    cylinder(r=body_diameter_mm/2, h=body_height_mm, center=true);

    // --- FIX: Bottom circular plate/flange must intersect the body (no gap) ---
    // Place so its TOP face is inside the body by overlap_mm.
    // Body bottom face: z = -body_height_mm/2
    // Plate center z = body_bottom - plate_h/2 + overlap
    translate([0, 0, -body_height_mm/2 - seat_thickness_mm/2 + overlap_mm])
      cylinder(r=(bushing_diameter_mm/2) + seat_overhang_mm, h=seat_thickness_mm, center=true);

    // Threaded bushing/collar (attached to top of body with overlap)
    // Body top face: z = +body_height_mm/2
    // Bushing center z = body_top + bushing_h/2 - overlap
    translate([0, 0, body_height_mm/2 + bushing_height_mm/2 - overlap_mm])
      cylinder(r=bushing_diameter_mm/2, h=bushing_height_mm, center=true);

    // Panel mount washer seat (top circular cap/washer) attached to TOP of bushing with overlap
    // Bushing top face (with overlap already): z = body_top + bushing_h - overlap
    // Washer center z = bushing_top + washer_h/2 - overlap
    translate([0, 0, body_height_mm/2 + bushing_height_mm + seat_thickness_mm/2 - 2*overlap_mm])
      cylinder(r=(bushing_diameter_mm/2) + seat_overhang_mm, h=seat_thickness_mm, center=true);

    // Panel mount nut seat (kept above washer seat, but overlapping it to ensure connection)
    // Washer top face: z = body_top + bushing_h + seat_thickness - 2*overlap
    // Nut seat center z = washer_top + panel_thickness + nut_h/2 - overlap
    translate([0, 0,
      (body_height_mm/2 + bushing_height_mm + seat_thickness_mm - 2*overlap_mm)
      + panel_thickness_mm
      + seat_thickness_mm/2
      - overlap_mm
    ])
      cylinder(r=nut_seat_diameter_mm/2, h=seat_thickness_mm, center=true);

    // Top actuator cylinder (attached to top of body with overlap)
    // Actuator center z = body_top + actuator_h/2 - overlap
    translate([0, 0, body_height_mm/2 + actuator_height_mm/2 - overlap_mm])
      cylinder(r=actuator_diameter_mm/2, h=actuator_height_mm, center=true);

    // Toggle pivot ball (overlaps actuator/body region)
    translate([0, 0, body_height_mm/2 + overlap_mm])
      sphere(r=actuator_diameter_mm/2);

    // Lever (kept intersecting the pivot ball/actuator region)
    rotate([0, 90, 0])
      translate([lever_length_mm/2 - overlap_mm, 0,
        body_height_mm/2 + actuator_height_mm - lever_diameter_mm/2 - overlap_mm
      ])
      rotate([0, lever_tilt_deg, 0])
      cylinder(r=lever_diameter_mm/2, h=lever_length_mm, center=true);
  }
}

// Assembly
module assembly() {
  toggle();
}

assembly();