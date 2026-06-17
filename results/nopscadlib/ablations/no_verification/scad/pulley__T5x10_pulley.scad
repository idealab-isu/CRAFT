// Timing pulley: 10 teeth, 15.0mm pitch diameter (parametric, connected solid)
// Fixes:
// - Teeth are explicit protrusions (radial array), not rotate_extrude sectors that blend away
// - Tooth count is exactly tooth_count
// - Pitch diameter is enforced: tooth centerline is placed on pitch radius
// - All parts are connected with formula-based overlaps

$fn = 180;

// Parameters
tooth_count = 10; //[5:40:1]
pitch_diameter_mm = 15; //[7.5:30:0.1]
pulley_width_mm = 10; //[5:30:0.5]
bore_diameter_mm = 5; //[2:12:0.1]
tolerance_mm = 0.2; //[0:0.6:0.05]

// Tooth geometry (simple GT2-like approximation)
tooth_radial_height_mm = 1.2; //[0.6:2.4:0.1]   // tooth height above root cylinder
tooth_root_relief_mm = 0.6; //[0.3:1.5:0.1]     // root cylinder is inside pitch radius by this amount
tooth_tangential_width_factor = 0.55; //[0.35:0.75:0.01] // fraction of circular pitch used as tooth width
tooth_overlap_mm = 0.8; //[0.3:2:0.1]           // tooth overlaps into root cylinder for watertight union

hub_diameter_mm = 18; //[9:36:0.5]
hub_length_mm = 8; //[0:30:0.5]
flange_diameter_mm = 20; //[10:50:0.5]
flange_thickness_mm = 1.5; //[0:5:0.1]

set_screw_count = 1; //[0:2:1]
set_screw_hole_diameter_mm = 3; //[1.5:6:0.1]
set_screw_z_offset_mm = 0; //[-10:10:0.5]

overlap_mm = 1; //[0.5:2:0.1]

// Derived radii
pitch_r = pitch_diameter_mm/2;
root_r  = pitch_r - tooth_root_relief_mm;
outer_r = root_r + tooth_radial_height_mm;

// Circular pitch and tooth width along tangent
circular_pitch = PI * pitch_diameter_mm / tooth_count;
tooth_w = circular_pitch * tooth_tangential_width_factor;

// Tooth radial thickness (including overlap into root)
tooth_radial_total = tooth_radial_height_mm + tooth_overlap_mm;

// Place tooth so its centerline (mid radial thickness) lies on pitch radius
tooth_center_r = pitch_r;
tooth_translate_r = tooth_center_r - tooth_radial_total/2; // cube is centered, so translate to inner face

// Root cylinder
module pulley_body() {
  cylinder(h=pulley_width_mm, r=root_r, center=true);
}

// Teeth as radial array of rounded-ish blocks (connected by overlap)
module pulley_teeth() {
  tooth_ang = 360/tooth_count;

  // Slightly reduce tooth width to guarantee a gap between teeth (avoid merging into a ring)
  gap_factor = 0.92;
  tooth_w_eff = tooth_w * gap_factor;

  for (i = [0:tooth_count-1]) {
    rotate([0,0,i*tooth_ang])
      translate([tooth_translate_r + tooth_radial_total/2, 0, 0])
        // Use hull of two cylinders to soften edges a bit while staying robust
        hull() {
          translate([-(tooth_radial_total/2 - 0.15), 0, 0])
            cylinder(h=pulley_width_mm, r=max(0.15, tooth_w_eff/2 - 0.25), center=true, $fn=48);
          translate([ +(tooth_radial_total/2 - 0.15), 0, 0])
            cylinder(h=pulley_width_mm, r=max(0.15, tooth_w_eff/2 - 0.25), center=true, $fn=48);
        }
  }
}

// Hub (connected to pulley body with overlap)
module hub() {
  if (hub_length_mm > 0) {
    translate([0, 0, -pulley_width_mm/2 - hub_length_mm/2 + overlap_mm])
      cylinder(h=hub_length_mm, r=hub_diameter_mm/2, center=true);
  }
}

// Flanges (connected with overlap)
module flanges() {
  if (flange_thickness_mm > 0) {
    translate([0, 0,  pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
      cylinder(h=flange_thickness_mm, r=flange_diameter_mm/2, center=true);

    translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + overlap_mm])
      cylinder(h=flange_thickness_mm, r=flange_diameter_mm/2, center=true);
  }
}

// Central bore (through everything)
module central_bore() {
  total_h = pulley_width_mm + hub_length_mm + 2*flange_thickness_mm + 8*overlap_mm;
  cylinder(h=total_h, r=(bore_diameter_mm + tolerance_mm)/2, center=true);
}

// Set screw holes (radial through hub)
module set_screw_holes() {
  if (set_screw_count > 0 && hub_length_mm > 0) {
    hub_center_z = -pulley_width_mm/2 - hub_length_mm/2 + overlap_mm + set_screw_z_offset_mm;

    for (i = [0:set_screw_count-1]) {
      rotate([0, 0, i*(360/max(1,set_screw_count))])
        translate([0, 0, hub_center_z])
          rotate([0, 90, 0])
            cylinder(h=hub_diameter_mm + 6*overlap_mm,
                     r=(set_screw_hole_diameter_mm + tolerance_mm)/2,
                     center=true);
    }
  }
}

// Pulley Assembly (single connected solid)
module pulley() {
  difference() {
    union() {
      pulley_body();
      pulley_teeth();
      hub();
      flanges();
    }
    central_bore();
    set_screw_holes();
  }
}

pulley();