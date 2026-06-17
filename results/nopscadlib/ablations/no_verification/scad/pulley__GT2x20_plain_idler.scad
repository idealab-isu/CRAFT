// Parameters
pulley_type_timing = 1; //[0:1:1]
outer_diameter_mm = 16; //[8:32:1]
belt_width_mm = 6; //[3:15:1]
bore_diameter_mm = 5; //[2:12:0.5]
hub_diameter_mm = 12; //[6:24:1]
hub_length_mm = 10; //[5:20:1]
flanges_enabled = 1; //[0:1:1]
flange_diameter_mm = 18; //[10:36:1]
flange_thickness_mm = 1; //[0.5:3:0.5]
tooth_count = 20; //[10:80:1]
tooth_radial_height_mm = 1.2; //[0.6:2.4:0.1]
tooth_tangential_width_factor = 0.55; //[0.3:0.8:0.05]
set_screw_enabled = 1; //[0:1:1]
set_screw_count = 2; //[1:4:1]
set_screw_diameter_mm = 3; //[2:6:0.5]
set_screw_z_offset_mm = 5; //[0:20:0.5]
set_screw_hole_length_mm = 30; //[10:80:1]
overlap_mm = 1; //[0.5:2:0.5]

$fn = 96;

// Helpers (avoid blank renders due to missing functions)
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

module pulley() {
  // Sanity/derived dimensions
  rim_h   = max(0.1, belt_width_mm);
  flange_t = max(0.1, flange_thickness_mm);
  hub_h   = max(hub_length_mm, rim_h + (flanges_enabled ? 2*flange_t : 0));
  rim_r   = max(0.1, outer_diameter_mm/2);
  hub_r   = max(0.1, hub_diameter_mm/2);
  flange_r = max(flange_diameter_mm/2, rim_r);

  // Ensure hub actually connects to rim (avoid floating/empty due to hub smaller than rim)
  core_r = max(hub_r, rim_r - overlap_mm);

  // Teeth sizing
  pitch    = PI*outer_diameter_mm/max(1, tooth_count);
  tooth_w  = max(0.2, pitch*tooth_tangential_width_factor);
  tooth_len = max(0.2, tooth_radial_height_mm);

  difference() {
    union() {
      // Core cylinder that guarantees connectivity between hub and rim
      cylinder(r=core_r, h=hub_h, center=true);

      // Rim body (belt surface)
      cylinder(r=rim_r, h=rim_h, center=true);

      // Teeth (protrude outward, overlap into rim for connectivity)
      if (pulley_type_timing == 1) {
        for (i = [0:tooth_count-1]) {
          rotate([0, 0, i*360/tooth_count])
            translate([rim_r + tooth_len/2 - overlap_mm, 0, 0])
              cube([tooth_len, tooth_w, rim_h], center=true);
        }
      }

      // Flanges (connected to rim by overlap)
      if (flanges_enabled == 1) {
        zf = rim_h/2 + flange_t/2 - overlap_mm;
        translate([0, 0,  zf]) cylinder(r=flange_r, h=flange_t, center=true);
        translate([0, 0, -zf]) cylinder(r=flange_r, h=flange_t, center=true);
      }
    }

    // Bore (through entire hub/core)
    cylinder(r=bore_diameter_mm/2, h=hub_h + 2*overlap_mm, center=true);

    // Set screw holes (radial, cut through core)
    if (set_screw_enabled == 1) {
      z_ss = clamp(set_screw_z_offset_mm, 0, hub_h) - hub_h/2;
      for (i = [0:set_screw_count-1]) {
        rotate([0, 0, i*360/set_screw_count])
          translate([0, 0, z_ss])
            rotate([0, 90, 0])
              cylinder(r=set_screw_diameter_mm/2,
                       h=2*core_r + 2*overlap_mm,
                       center=true);
      }
    }
  }
}

pulley();