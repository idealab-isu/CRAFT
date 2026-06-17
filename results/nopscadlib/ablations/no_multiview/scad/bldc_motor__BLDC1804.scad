// Parameters
stator_diameter_mm = 23.0; //[12.0:46.0:0.1]
stator_height_mm   = 12.0; //[6.0:24.0:0.1]
center_bore_diameter_mm = 5.0; //[2.5:10.0:0.1]
tolerance_mm = 0.2; //[0.0:1.0:0.05]

ref_plane_thickness_mm = 0.8; //[0.4:2.0:0.1]
ref_plane_margin_mm    = 2.0; //[1.0:6.0:0.1]
ref_plane_offset_mm    = 0.5; //[0.2:2.0:0.1]

// Structural overlap to guarantee attachment (1-2mm as required)
attach_overlap_mm = 1.5;

// --- BLDC motor details (added missing part) ---
motor_can_extra_d_mm = 2.0;                 // motor can slightly larger than stator
motor_can_diameter_mm = stator_diameter_mm + motor_can_extra_d_mm;
motor_can_height_mm   = stator_height_mm;   // keep overall design consistent

endcap_thickness_mm = 1.2;                  // thin endcaps
shaft_diameter_mm   = 5.0;                  // typical small BLDC shaft
shaft_length_mm     = 10.0;                 // protrusion length
hub_diameter_mm     = 12.0;                 // "gold cylindrical part" (rotor hub)
hub_length_mm       = 6.0;                  // hub length

// Stator core with center bore
module stator_core() {
  color("DimGray")
  difference() {
    cylinder(r=stator_diameter_mm/2, h=stator_height_mm, center=true, $fn=96);
    cylinder(r=center_bore_diameter_mm/2, h=stator_height_mm + 2*tolerance_mm, center=true, $fn=96);
  }
}

// Motor can (outer shell) + endcaps (kept simple, physically connected)
module motor_can() {
  color([0.35, 0.35, 0.35])
  union() {
    // Outer can
    cylinder(r=motor_can_diameter_mm/2, h=motor_can_height_mm, center=true, $fn=128);

    // Front endcap (slight overlap into can)
    translate([0, 0, motor_can_height_mm/2 - endcap_thickness_mm/2 - attach_overlap_mm/2])
      cylinder(r=motor_can_diameter_mm/2, h=endcap_thickness_mm + attach_overlap_mm, center=true, $fn=128);

    // Rear endcap (slight overlap into can)
    translate([0, 0, -motor_can_height_mm/2 + endcap_thickness_mm/2 + attach_overlap_mm/2])
      cylinder(r=motor_can_diameter_mm/2, h=endcap_thickness_mm + attach_overlap_mm, center=true, $fn=128);
  }
}

// Gold rotor hub + shaft (FIXED: attached to motor body with guaranteed overlap; no gap/floating)
module rotor_hub_and_shaft() {
  // Place hub on +X side of motor can.
  // Motor can outer radius:
  can_r = motor_can_diameter_mm/2;

  // Hub is centered so its inner face penetrates the can by attach_overlap_mm.
  // Inner face x = hub_center_x - hub_length/2
  // Want inner face = can_r - attach_overlap_mm
  hub_center_x = can_r - attach_overlap_mm + hub_length_mm/2;

  // Shaft continues outward from hub, overlapping into hub by attach_overlap_mm.
  // Hub outer face x = hub_center_x + hub_length/2
  hub_outer_face_x = hub_center_x + hub_length_mm/2;
  shaft_center_x = hub_outer_face_x + shaft_length_mm/2 - attach_overlap_mm;

  color([0.8, 0.6, 0.2])  // gold/brass
  union() {
    // Rotor hub (gold cylindrical part) - now intersects motor can by attach_overlap_mm
    translate([hub_center_x, 0, 0])
      rotate([0, 90, 0])
        cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true, $fn=96);

    // Shaft - overlaps into hub by attach_overlap_mm
    translate([shaft_center_x, 0, 0])
      rotate([0, 90, 0])
        cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true, $fn=64);
  }
}

// Mounting face reference planes (kept as in original design)
module ref_planes() {
  color("Silver")
  union() {
    translate([0, 0,  stator_height_mm/2 + ref_plane_thickness_mm/2 - ref_plane_offset_mm])
      cube([stator_diameter_mm + 2*ref_plane_margin_mm,
            stator_diameter_mm + 2*ref_plane_margin_mm,
            ref_plane_thickness_mm], center=true);

    translate([0, 0, -stator_height_mm/2 - ref_plane_thickness_mm/2 + ref_plane_offset_mm])
      cube([stator_diameter_mm + 2*ref_plane_margin_mm,
            stator_diameter_mm + 2*ref_plane_margin_mm,
            ref_plane_thickness_mm], center=true);
  }
}

// BLDC motor assembly (added missing part; all connected via union with overlaps)
module bldc_motor() {
  union() {
    // Core stator (with bore)
    stator_core();

    // Outer can overlaps stator slightly to ensure a single connected solid
    // (stator radius is smaller; can encloses it, so they intersect by volume)
    motor_can();

    // Rotor hub + shaft attached to can (fixed gap/floating)
    rotor_hub_and_shaft();

    // Reference planes (intersect motor body by design)
    ref_planes();
  }
}

// Final assembly: single connected solid via union()
union() {
  bldc_motor();
}