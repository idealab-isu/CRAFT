// Parameters
pulley_type = 0; //[0:1:1]
tooth_profile = 0; //[0:1:1]
tooth_count = 20; //[10:60:1]
outer_diameter_mm = 16; //[8:32:1]
width_mm = 6; //[3:20:1]
bore_diameter_mm = 5; //[2:12:0.5]
hub_diameter_mm = 12; //[6:24:1]
hub_length_mm = 10; //[0:25:1]
flange_diameter_mm = 18; //[10:40:1]
flange_thickness_mm = 1; //[0:4:0.5]
set_screw_count = 0; //[0:2:1]
set_screw_diameter_mm = 3; //[2:6:0.5]
set_screw_z_offset_mm = 0; //[-5:5:0.5]
overlap_mm = 1; //[0.5:2:0.5]
tooth_radial_height_mm = 1; //[0.5:2.5:0.25]
tooth_tangential_width_factor = 0.55; //[0.3:0.9:0.05]

$fn = 96;

module pulley() {
  // Guards / derived
  od_r     = max(outer_diameter_mm/2, 0.01);
  hub_r    = max(hub_diameter_mm/2, 0.01);
  flange_r = max(flange_diameter_mm/2, 0.01);

  body_h   = max(width_mm, 0.01);
  hub_h    = max(hub_length_mm, 0);
  flange_h = max(flange_thickness_mm, 0);

  ov = max(overlap_mm, 0.05);

  // Teeth sizing
  tooth_h = max(tooth_radial_height_mm, 0);
  pitch   = PI * (2*od_r) / max(tooth_count, 1);
  tooth_w = max(pitch * tooth_tangential_width_factor, 0.2);

  // Ensure hub is not smaller than bore
  bore_r = max(bore_diameter_mm/2, 0.01);
  hub_r_eff = max(hub_r, bore_r + ov);

  // Total extents for through-cuts
  total_h = max(body_h, hub_h) + 2*flange_h + 8*ov;

  difference() {
    union() {
      // Main body
      cylinder(r=od_r, h=body_h, center=true);

      // Hub (connected by overlap with body)
      if (hub_h > 0)
        cylinder(r=hub_r_eff, h=hub_h, center=true);

      // Flanges (connected by overlap)
      if (flange_h > 0) {
        translate([0, 0, body_h/2 + flange_h/2 - ov])
          cylinder(r=flange_r, h=flange_h, center=true);
        translate([0, 0, -(body_h/2 + flange_h/2 - ov)])
          cylinder(r=flange_r, h=flange_h, center=true);
      }

      // Teeth (protrude outward, overlap into body)
      if (pulley_type == 1 && tooth_h > 0) {
        for (i = [0 : tooth_count-1]) {
          rotate([0, 0, i*360/tooth_count])
            translate([od_r + tooth_h/2 - ov, 0, 0])
              cube([tooth_h + ov, tooth_w, body_h], center=true);
        }
      }
    }

    // Center bore (always through entire assembly)
    cylinder(r=bore_r, h=total_h, center=true);

    // Set screw holes (ensure they intersect hub by clamping Z inside hub)
    if (set_screw_count > 0 && hub_h > 0) {
      screw_len = 2*hub_r_eff + 8*ov;

      // Clamp requested offset so the hole stays within hub height
      screw_z = min(max(set_screw_z_offset_mm, -hub_h/2 + ov), hub_h/2 - ov);

      translate([0, 0, screw_z])
        rotate([0, 90, 0])
          cylinder(r=max(set_screw_diameter_mm/2, 0.01), h=screw_len, center=true);

      if (set_screw_count == 2) {
        translate([0, 0, screw_z])
          rotate([90, 0, 0])
            cylinder(r=max(set_screw_diameter_mm/2, 0.01), h=screw_len, center=true);
      }
    }
  }
}

pulley();