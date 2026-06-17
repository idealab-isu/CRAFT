// Timing pulley: 20 teeth, pitch diameter 12.22mm (pitch radius 6.11mm)
// One connected solid (union) with bore and set-screw hole(s) subtracted.

$fn = 180;

// ---------------- Parameters ----------------
tooth_count = 20;                 // must be 20
pitch_diameter_mm = 12.22;        // must be 12.22mm
pitch_radius_mm = pitch_diameter_mm/2;

pulley_width_mm = 10;             // toothed section axial width

// Simple timing-tooth approximation (rectangular tooth blocks)
// (Not a specific belt standard profile; but teeth are clearly defined and countable.)
tooth_radial_height_mm = 1.2;     // protrusion beyond pitch radius
tooth_tangential_width_mm = 1.0;  // tooth thickness around circumference
tooth_overlap_mm = 0.8;           // overlaps into core for connectivity

// Core sized so that tooth inner face overlaps into it
core_radius_offset_mm = 0.6;      // core radius = pitch_radius - offset

bore_diameter_mm = 5;

hub_diameter_mm = 16;
hub_length_mm = 12;

flange_diameter_mm = 18;
flange_thickness_mm = 1.5;

set_screw_count = 1;
set_screw_hole_diameter_mm = 3;
set_screw_z_offset_mm = 6;        // from hub bottom face upward
set_screw_hole_length_mm = 30;

overlap_mm = 0.6;                 // general overlap for unions/differences

// ---------------- Derived ----------------
core_r = pitch_radius_mm - core_radius_offset_mm;
tooth_depth = tooth_radial_height_mm + tooth_overlap_mm;

// Total height (for bore cut)
total_h = hub_length_mm + pulley_width_mm + 2*flange_thickness_mm + 6*overlap_mm;

// ---------------- Geometry ----------------
module pulley_body() {
  union() {
    // Toothed section core
    cylinder(r=core_r, h=pulley_width_mm, center=true);

    // Hub attached to bottom of toothed section (connected via computed translate)
    translate([0, 0, -(pulley_width_mm/2 + hub_length_mm/2 - overlap_mm)])
      cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

    // Flanges attached to both ends of toothed section (connected via computed translate)
    translate([0, 0, +(pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm)])
      cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);

    translate([0, 0, -(pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm)])
      cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
  }
}

module tooth_block() {
  // Tangential width (x), radial depth (y), axial width (z)
  cube([tooth_tangential_width_mm, tooth_depth, pulley_width_mm], center=true);
}

module pulley_teeth() {
  // Teeth centered on the pitch circle:
  // inner face at (pitch_radius - tooth_overlap), outer face at (pitch_radius + tooth_radial_height)
  // Place tooth center at pitch_radius + (tooth_radial_height - tooth_overlap)/2
  tooth_center_r = pitch_radius_mm + (tooth_radial_height_mm - tooth_overlap_mm)/2;

  for (i = [0:tooth_count-1]) {
    rotate([0, 0, i*360/tooth_count])
      translate([0, tooth_center_r, 0])
        tooth_block();
  }
}

module solid_pulley() {
  union() {
    pulley_body();
    pulley_teeth();
  }
}

module cut_bore_and_set_screws() {
  // Bore through entire part
  cylinder(r=bore_diameter_mm/2, h=total_h, center=true);

  // Set screw hole(s) through hub (radial)
  if (set_screw_count > 0) {
    // Hub spans z: [-(pulley_width/2 + hub_length) .. -(pulley_width/2)]
    hub_bottom_z = -(pulley_width_mm/2 + hub_length_mm);
    z_pos = hub_bottom_z + set_screw_z_offset_mm;

    for (i = [0:set_screw_count-1]) {
      rotate([0, 0, i*90])
        translate([hub_diameter_mm/2 - set_screw_hole_diameter_mm/2 - overlap_mm, 0, z_pos])
          rotate([0, 90, 0])
            cylinder(r=set_screw_hole_diameter_mm/2, h=set_screw_hole_length_mm, center=true);
    }
  }
}

// ---------------- Assembly ----------------
difference() {
  solid_pulley();
  cut_bore_and_set_screws();
}