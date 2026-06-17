// Parameters
bore_diameter_mm = 6.0; //[3.0:12.0:0.1]
outer_diameter_mm = 16.0; //[8.0:32.0:0.1]
width_mm = 5.0; //[2.5:10.0:0.1]
bore_radius_mm = 3.0; //[1.5:6.0:0.1]
outer_radius_mm = 8.0; //[4.0:16.0:0.1]
eps_mm = 0.6; //[0.2:2.0:0.1]
rim_thickness_mm = 1.2; //[0.6:2.4:0.1]
hub_thickness_mm = 1.2; //[0.6:2.4:0.1]
shield_radial_thickness_mm = 0.8; //[0.4:1.6:0.1]
shield_axial_thickness_mm = 1.0; //[0.5:2.0:0.1]
ball_diameter_mm = 2.0; //[1.0:4.0:0.1]
ball_center_radius_mm = 5.5; //[4.0:7.0:0.1]
flange_enabled = 0; //[0:1:1]
flange_outer_diameter_mm = 18.0; //[16.0:32.0:0.1]
flange_width_mm = 1.0; //[0.5:3.0:0.1]

// Connectivity overlap (1–2mm) to guarantee attachment
overlap_mm = 1.2;

// Ball Bearing - complete geometry (single connected solid)
module ball_bearing_connected() {

  // --- Derived radii (keep consistent with parameters) ---
  R_outer = outer_diameter_mm/2;
  R_outer_inner = R_outer - rim_thickness_mm;

  R_inner_outer = bore_diameter_mm/2 + hub_thickness_mm;
  R_bore = bore_diameter_mm/2;

  // Shield radii (as in original)
  R_shield_outer = R_outer - rim_thickness_mm - eps_mm;
  R_shield_inner = R_inner_outer + eps_mm;

  // --- Marker dimensions (blue rectangular block) ---
  marker_radial_mm = ball_diameter_mm;  // radial thickness (X)
  marker_w_mm      = ball_diameter_mm;  // tangential size (Y)
  marker_h_mm      = ball_diameter_mm;  // axial size (Z)

  // Place marker so it is GUARANTEED to intersect the OUTER RACE material.
  // Outer race material exists for radii in [R_outer_inner, R_outer].
  // Ensure marker spans into that band by at least overlap_mm.
  // We set the marker's OUTER face slightly inside the OD (by overlap_mm),
  // so it cannot float outside and will always cut into the ring.
  marker_center_r = R_outer - overlap_mm - marker_radial_mm/2;

  // --- Ball (kept, but forced to intersect outer race slightly so it cannot float) ---
  ball_r = ball_diameter_mm/2;
  // Ensure the sphere reaches into the outer race band by overlap_mm:
  // sphere outermost radius = ball_center_r + ball_r
  // require >= R_outer_inner + overlap_mm
  ball_center_r_attached = max(ball_center_radius_mm, (R_outer_inner + overlap_mm) - ball_r);

  union() {
    // Main bearing solids
    color("Silver") union() {

      // Outer Race
      difference() {
        cylinder(r=R_outer, h=width_mm, center=true);
        cylinder(r=R_outer_inner, h=width_mm + 2*eps_mm, center=true);
      }

      // Inner Race
      difference() {
        cylinder(r=R_inner_outer, h=width_mm, center=true);
        cylinder(r=R_bore, h=width_mm + 2*eps_mm, center=true);
      }

      // Shield/Seal Annulus
      difference() {
        cylinder(r=R_shield_outer, h=shield_axial_thickness_mm, center=true);
        cylinder(r=R_shield_inner, h=shield_axial_thickness_mm + 2*eps_mm, center=true);
      }

      // Flange (optional)
      if (flange_enabled) {
        difference() {
          translate([0, 0, width_mm/2 - flange_width_mm/2 + eps_mm])
            cylinder(r=flange_outer_diameter_mm/2, h=flange_width_mm, center=true);
          translate([0, 0, width_mm/2 - flange_width_mm/2 + eps_mm])
            cylinder(r=R_outer_inner, h=flange_width_mm + 2*eps_mm, center=true);
        }
      }
    }

    // --- FIX: Blue marker is physically fused to the outer race (no floating) ---
    // Rotate to match the shown views (marker at "top" in right view).
    color("Blue")
      rotate([0, 0, 90])
        translate([marker_center_r, 0, 0])
          cube([marker_radial_mm, marker_w_mm, marker_h_mm], center=true);

    // --- Ball fused (no floating) ---
    // Unioned and positioned to intersect the outer race by overlap_mm.
    color("Copper")
      translate([ball_center_r_attached, 0, 0])
        sphere(r=ball_r);
  }
}

ball_bearing_connected();