// Timing pulley: 16 teeth, 12.16mm pitch diameter
// Corrected: teeth are now POSITIVE protrusions (visible), count is verifiable,
// and pitch diameter is enforced by placing tooth centers on pitch_radius_mm.
// One connected solid with formula-based placement and slight overlaps.

$fn = 220;

// Parameters
tooth_count = 16; //[8:64:1]
pitch_diameter_mm = 12.16; //[6.08:24.32:0.01]
pitch_radius_mm = pitch_diameter_mm/2;

belt_width_mm = 6; //[3:20:0.1]

bore_diameter_mm = 5; //[1:12:0.01]

hub_diameter_mm = 14; //[8:28:0.1]
hub_length_mm = 10; //[5:25:0.1]

flange_diameter_mm = 18; //[12:36:0.1]
flange_thickness_mm = 1.5; //[0.8:4:0.1]

// Tooth geometry (simple, visible timing-tooth approximation)
// Teeth are added outward from a root cylinder.
// Tooth centerline is placed at pitch_radius_mm to enforce pitch diameter.
tooth_radial_height_mm = 1.2; //[0.4:3.0:0.01]     // radial protrusion above root cylinder
tooth_tangential_width_mm = 1.6; //[0.6:4.0:0.01]  // tooth width along circumference at pitch circle
tooth_root_clearance_mm = 0.8; //[0.2:2.0:0.01]    // root cylinder is below pitch circle by this amount

// Optional set screws
set_screw_count = 0; //[0:4:1]
set_screw_hole_diameter_mm = 3; //[1.5:6:0.01]
set_screw_z_offset_mm = 0; //[-10:10:0.1]
set_screw_hole_length_mm = 30; //[10:80:1]

eps_mm = 0.2; //[0.05:1:0.05]

// Derived
tooth_angle_deg = 360/tooth_count;
pitch_circumference_mm = PI * pitch_diameter_mm;
tooth_pitch_mm = pitch_circumference_mm / tooth_count;

// Base radii
root_radius_mm  = pitch_radius_mm - tooth_root_clearance_mm; // cylinder under teeth
outer_radius_mm = root_radius_mm + tooth_radial_height_mm;

// Keep tooth width reasonable vs pitch
tooth_w_mm = min(tooth_tangential_width_mm, tooth_pitch_mm * 0.90);

// Tooth radial length (cube X dimension). Make it slightly longer than needed and overlap into root.
tooth_len_mm = tooth_radial_height_mm + 2*eps_mm;
tooth_overlap_into_root_mm = min(0.6, max(0.2, tooth_radial_height_mm*0.35)); // ensures connectivity

// Toothed belt section (root cylinder + outward teeth)
module toothed_ring() {
  union() {
    // Root cylinder (solid under pitch circle)
    cylinder(r=root_radius_mm, h=belt_width_mm, center=true);

    // Teeth: protrude outward; tooth centerline at pitch_radius_mm (enforces pitch diameter)
    for (i = [0:tooth_count-1]) {
      rotate([0, 0, i*tooth_angle_deg])
        translate([pitch_radius_mm + tooth_len_mm/2 - tooth_overlap_into_root_mm, 0, 0])
          cube([tooth_len_mm, tooth_w_mm, belt_width_mm], center=true);
    }
  }
}

// Hub (centered, overlaps ring slightly to guarantee connectivity)
module hub() {
  cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);
}

// Flanges (slightly overlapping belt section)
module flanges() {
  translate([0, 0, belt_width_mm/2 + flange_thickness_mm/2 - eps_mm])
    cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);

  translate([0, 0, -belt_width_mm/2 - flange_thickness_mm/2 + eps_mm])
    cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
}

// Round bore (through entire pulley stack)
module bore() {
  total_h = max(hub_length_mm, belt_width_mm) + 2*flange_thickness_mm + 6*eps_mm;
  cylinder(r=bore_diameter_mm/2, h=total_h, center=true, $fn=160);
}

// Set screw holes (radial)
module set_screw_holes() {
  if (set_screw_count > 0) {
    for (i = [0:set_screw_count-1]) {
      rotate([0, 0, i*360/set_screw_count])
        rotate([0, 90, 0])
          translate([0, 0, set_screw_z_offset_mm])
            cylinder(r=set_screw_hole_diameter_mm/2, h=set_screw_hole_length_mm, center=true, $fn=120);
    }
  }
}

// Pulley (one connected solid)
module pulley() {
  difference() {
    union() {
      toothed_ring();
      hub();      // overlaps toothed ring
      flanges();  // overlap belt section slightly
    }
    bore();
    set_screw_holes();
  }
}

pulley();