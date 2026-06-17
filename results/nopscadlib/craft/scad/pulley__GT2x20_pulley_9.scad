$fn = 220;

// Parameters
tooth_count = 20; //[10:60:1]
pitch_diameter_mm = 12.22; //[6.11:24.44:0.01]
pulley_width_mm = 10; //[5:20:1]
tolerance_mm = 0.2; //[0.0:0.6:0.05]
belt_pitch_mm = 2; //[1:5:0.1]
tooth_radial_height_mm = 0.8; //[0.4:1.6:0.05]
tooth_tangential_width_mm = 1.2; //[0.6:2.4:0.05]
root_radius_offset_mm = 0.9; //[0.3:2.0:0.05]
bore_diameter_mm = 5; //[2:10:0.1]
hub_diameter_mm = 16; //[8:32:0.5]
hub_length_mm = 6; //[0:20:1]
flange_diameter_mm = 18; //[10:40:0.5]
flange_thickness_mm = 1.5; //[0:4:0.1]
flange_enable_top = 1; //[0:1:1]
flange_enable_bottom = 1; //[0:1:1]
set_screw_count = 1; //[0:2:1]
set_screw_diameter_mm = 3; //[2:6:0.1]
set_screw_z_offset_mm = 2.5; //[0:10:0.1]
set_screw_length_mm = 20; //[10:60:1]
overlap_mm = 0.8; //[0.5:2:0.1]

// Derived radii
pitch_r = pitch_diameter_mm/2;
root_r  = pitch_r - root_radius_offset_mm;
outer_r = root_r + tooth_radial_height_mm;

// Tooth geometry (rectangular tooth, centered on pitch circle for visibility)
tooth_len = tooth_radial_height_mm;
circ_pitch = PI * pitch_diameter_mm / tooth_count;
tooth_w_eff = min(tooth_tangential_width_mm, circ_pitch * 0.85);

// Safety clamps
root_r_safe = max(root_r, 0.2);
tooth_len_safe = max(tooth_len, 0.01);
overlap_safe = min(overlap_mm, tooth_len_safe*0.9);

// Main assembly (ONE connected solid)
module timing_pulley() {
  difference() {
    union() {
      // Toothed body: root cylinder + outward teeth (teeth centered at pitch radius)
      union() {
        cylinder(h=pulley_width_mm, r=root_r_safe, center=true);

        for (i = [0:tooth_count-1]) {
          rotate([0, 0, i*360/tooth_count])
            // Place tooth so its inner face overlaps into root cylinder,
            // and its centerline sits at pitch radius (verifiable pitch diameter).
            translate([pitch_r + tooth_len_safe/2 - overlap_safe, 0, 0])
              cube([tooth_len_safe, tooth_w_eff, pulley_width_mm], center=true);
        }
      }

      // Hub (connected to bottom of pulley body)
      translate([0, 0, -(pulley_width_mm/2 + hub_length_mm/2 - overlap_mm)])
        cylinder(h=hub_length_mm, r=hub_diameter_mm/2, center=true);

      // Flanges (connected to pulley body with overlap)
      if (flange_enable_top)
        translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
          cylinder(h=flange_thickness_mm, r=flange_diameter_mm/2, center=true);

      if (flange_enable_bottom)
        translate([0, 0, -(pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm)])
          cylinder(h=flange_thickness_mm, r=flange_diameter_mm/2, center=true);
    }

    // Bore through entire part
    total_h = pulley_width_mm + hub_length_mm + 2*flange_thickness_mm + 8*overlap_mm;
    cylinder(h=total_h, r=(bore_diameter_mm + tolerance_mm)/2, center=true);

    // Optional set screw hole(s) through hub (radial)
    if (set_screw_count > 0) {
      for (k = [0:set_screw_count-1]) {
        rotate([0, 0, k*180])
          translate([0, 0, -(pulley_width_mm/2 + hub_length_mm/2 - overlap_mm) + set_screw_z_offset_mm])
            rotate([0, 90, 0])
              cylinder(h=hub_diameter_mm + 2*overlap_mm, r=set_screw_diameter_mm/2, center=true);
      }
    }
  }
}

timing_pulley();