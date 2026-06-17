// Parameters
pulley_type_timing = 1; //[0:1:1]
tooth_count = 20; //[10:60:1]
outer_diameter_mm = 16; //[8:32:1]
belt_width_mm = 6; //[3:20:1]
bore_diameter_mm = 5; //[2:12:0.5]
hub_diameter_mm = 12; //[6:24:1]
hub_length_mm = 10; //[5:25:1]
flange_enabled = 1; //[0:1:1]
flange_diameter_mm = 18; //[10:40:1]
flange_thickness_mm = 1; //[0.5:4:0.5]
set_screw_count = 0; //[0:2:1]
set_screw_diameter_mm = 3; //[2:6:0.5]
set_screw_z_offset_mm = 0; //[-4:4:0.5]
tolerances_mm = 0.2; //[0.05:0.6:0.05]
overlap_mm = 1; //[0.5:2:0.5]
rim_wall_mm = 2; //[1:6:0.5]
tooth_radial_height_mm = 1.2; //[0.5:3:0.1]
tooth_tangential_width_factor = 0.55; //[0.3:0.8:0.05]

$fn = 120;

// Pulley module
module pulley() {
  // Derived dimensions
  rim_r = outer_diameter_mm/2;
  hub_r = hub_diameter_mm/2;
  flange_r = flange_diameter_mm/2;

  // Ensure rim exists and is not smaller than hub
  rim_r_eff = max(rim_r, hub_r + 0.5);

  // Total length includes flanges if enabled
  total_len = belt_width_mm + (flange_enabled ? 2*flange_thickness_mm : 0);

  // Groove (rope channel) parameters
  groove_depth = min(rim_wall_mm, rim_r_eff*0.35);
  groove_r = max(rim_r_eff - groove_depth, (bore_diameter_mm + tolerances_mm)/2 + 1.0);
  groove_z_half = max(belt_width_mm/2 - rim_wall_mm/2, belt_width_mm*0.25);

  // Teeth parameters (timing pulley)
  tooth_h = tooth_radial_height_mm;
  tooth_w = (2*PI*rim_r_eff/tooth_count) * tooth_tangential_width_factor;
  tooth_r_center = rim_r_eff - tooth_h/2 + overlap_mm; // overlaps into rim for connectivity

  difference() {
    union() {
      // Hub (centered)
      cylinder(r=hub_r, h=hub_length_mm, center=true);

      // Rim body (belt section)
      cylinder(r=rim_r_eff, h=belt_width_mm, center=true);

      // Flanges (connected with slight overlap)
      if (flange_enabled) {
        translate([0, 0, belt_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
          cylinder(r=flange_r, h=flange_thickness_mm, center=true);
        translate([0, 0, -belt_width_mm/2 - flange_thickness_mm/2 + overlap_mm])
          cylinder(r=flange_r, h=flange_thickness_mm, center=true);
      }

      // Timing teeth (protrude outward, overlap into rim)
      if (pulley_type_timing) {
        for (i = [0:tooth_count-1]) {
          rotate([0, 0, i*360/tooth_count])
            translate([tooth_r_center, 0, 0])
              cube([tooth_h + 2*overlap_mm, tooth_w, belt_width_mm], center=true);
        }
      }
    }

    // Central bore through entire pulley length
    cylinder(r=(bore_diameter_mm + tolerances_mm)/2, h=total_len + hub_length_mm + 4*overlap_mm, center=true);

    // Rope groove / channel (waisted profile) cut into rim
    // Use hull of two larger-radius cylinders near the faces to create a smooth concave groove.
    hull() {
      translate([0, 0, groove_z_half])
        cylinder(r=groove_r, h=rim_wall_mm, center=true);
      translate([0, 0, -groove_z_half])
        cylinder(r=groove_r, h=rim_wall_mm, center=true);
    }

    // Set screw holes (radial through hub)
    if (set_screw_count > 0) {
      for (j = [0:set_screw_count-1]) {
        rotate([0, 0, j*90])
          translate([0, 0, set_screw_z_offset_mm])
            rotate([0, 90, 0])
              cylinder(r=(set_screw_diameter_mm + tolerances_mm)/2,
                       h=hub_diameter_mm + 2*overlap_mm, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  pulley();
}

assembly();