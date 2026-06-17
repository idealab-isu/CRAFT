// Parameters
pulley_type_timing = 1; //[0:1:1]
teeth_count = 20; //[10:60:1]
outer_diameter_mm = 16; //[8:32:0.5]
belt_pitch_mm = 2; //[1:5:0.1]
width_mm = 6; //[3:20:0.5]
bore_diameter_mm = 5; //[2:12:0.1]
hub_diameter_mm = 12; //[6:30:0.5]
hub_length_mm = 10; //[5:25:0.5]
flange_enabled = 1; //[0:1:1]
flange_diameter_mm = 18; //[10:40:0.5]
flange_thickness_mm = 1; //[0.5:4:0.1]
set_screw_enabled = 1; //[0:1:1]
set_screw_count = 2; //[1:4:1]
set_screw_diameter_mm = 3; //[2:6:0.1]
set_screw_z_offset_mm = 5; //[1:20:0.5]
tooth_depth_mm = 0.8; //[0.3:2:0.1]
tooth_width_factor = 0.55; //[0.3:0.8:0.01]
overlap_mm = 1; //[0.5:2:0.1]
mount_child_post_diameter_mm = 6; //[3:15:0.5]
mount_child_post_height_mm = 2; //[1:10:0.5]

$fn = 96;

// Pulley module
module pulley() {
  // Derived dimensions / guards
  body_r   = max(0.1, outer_diameter_mm/2);
  hub_r    = max(0.1, hub_diameter_mm/2);
  flange_r = max(body_r, flange_diameter_mm/2);
  bore_r   = max(0.05, bore_diameter_mm/2);

  // Ensure teeth protrude outward from body
  tooth_len = max(0.01, tooth_depth_mm);
  tooth_w   = max(0.01, belt_pitch_mm * tooth_width_factor);
  tooth_overlap_into_body = min(overlap_mm, tooth_len*0.9);

  // Z positions (all computed from dimensions; small overlaps ensure connectivity)
  z_hub_center   = width_mm/2 + hub_length_mm/2 - overlap_mm;
  z_flange_top   = width_mm/2 + flange_thickness_mm/2 - overlap_mm;
  z_flange_bot   = -width_mm/2 - flange_thickness_mm/2 + overlap_mm;
  z_mount_center = (width_mm/2 + hub_length_mm - overlap_mm) + mount_child_post_height_mm/2;

  color("Silver")
  difference() {
    // SOLID union (one connected solid)
    union() {
      // Pulley body
      cylinder(r=body_r, h=width_mm, center=true);

      // Hub section (connected to body)
      translate([0, 0, z_hub_center])
        cylinder(r=hub_r, h=hub_length_mm, center=true);

      // Flanges (connected to body)
      if (flange_enabled) {
        translate([0, 0, z_flange_top])
          cylinder(r=flange_r, h=flange_thickness_mm, center=true);
        translate([0, 0, z_flange_bot])
          cylinder(r=flange_r, h=flange_thickness_mm, center=true);
      }

      // Teeth (protrude outward, overlap into body)
      if (pulley_type_timing) {
        for (i = [0:teeth_count-1]) {
          rotate([0, 0, i*360/teeth_count])
            translate([body_r + tooth_len/2 - tooth_overlap_into_body, 0, 0])
              cube([tooth_len, tooth_w, width_mm], center=true);
        }
      }

      // Mounting children interface (connected to hub)
      translate([0, 0, z_mount_center])
        cylinder(r=mount_child_post_diameter_mm/2, h=mount_child_post_height_mm, center=true);
    }

    // SUBTRACT features (bore + set screw holes)
    union() {
      // Shaft bore through entire assembly
      total_h = width_mm + hub_length_mm + 2*flange_thickness_mm + mount_child_post_height_mm + 8*overlap_mm;
      cylinder(r=bore_r, h=total_h, center=true);

      // Set screw holes through hub (radial)
      if (set_screw_enabled) {
        // Place within hub length, referenced from hub center
        z_set = z_hub_center + (set_screw_z_offset_mm - hub_length_mm/2);
        for (i = [0:set_screw_count-1]) {
          rotate([0, 0, i*360/set_screw_count])
            translate([0, 0, z_set])
              rotate([0, 90, 0])
                cylinder(r=set_screw_diameter_mm/2, h=hub_diameter_mm + 4*overlap_mm, center=true);
        }
      }
    }
  }
}

// Assembly
module assembly() {
  pulley();
}

assembly();