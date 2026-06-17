// Parameters
stator_diameter_mm = 28; //[14:56:0.5]
stator_height_mm = 27; //[13.5:54:0.5]
stator_bore_diameter_mm = 10; //[5:20:0.5]
rotor_outer_diameter_mm = 30; //[15:60:0.5]
rotor_height_mm = 27; //[13.5:54:0.5]
shaft_diameter_mm = 5; //[2.5:10:0.25]
shaft_extension_front_mm = 10; //[5:20:0.5]
shaft_extension_rear_mm = 5; //[2.5:10:0.5]
endcap_thickness_mm = 1.5; //[0.75:3:0.25]
clearance_mm = 0.2; //[0.05:0.6:0.05]
overlap_mm = 1; //[0.5:2:0.1]
buzzer_diameter_mm = 12; //[6:24:0.5]
buzzer_height_mm = 5; //[2.5:10:0.5]
buzzer_pin_diameter_mm = 2; //[1:4:0.25]
buzzer_pin_height_mm = 2; //[1:6:0.5]

// Buzzer / side component - FIXED: guaranteed physical attachment to rotor can
module buzzer() {
  rotor_r  = rotor_outer_diameter_mm/2;
  buzzer_r = buzzer_diameter_mm/2;

  // Place buzzer so it intersects the rotor side wall by overlap_mm (1-2mm recommended)
  // This removes any visible gap in top/bottom views and prevents floating geometry.
  buzzer_x = rotor_r + buzzer_r - overlap_mm;

  // Keep buzzer centered vertically on the motor so it doesn't appear offset/floating
  buzzer_z = 0;

  // Add a small "bridge" block that spans from inside the rotor radius to inside the buzzer,
  // guaranteeing a robust union even if render tolerances show a tiny gap.
  bridge_len = overlap_mm * 2;                 // thickness in X
  bridge_w   = buzzer_diameter_mm * 0.85;      // width in Y
  bridge_h   = buzzer_height_mm * 0.95;        // height in Z

  color([0.1, 0.1, 0.6])
  union() {
    // Buzzer body (main side component)
    translate([buzzer_x, 0, buzzer_z])
      cylinder(r=buzzer_r, h=buzzer_height_mm, center=true);

    // Buzzer pin - attached to buzzer body with overlap
    translate([buzzer_x, 0, buzzer_z + buzzer_height_mm/2 + buzzer_pin_height_mm/2 - overlap_mm])
      cylinder(r=buzzer_pin_diameter_mm/2, h=buzzer_pin_height_mm, center=true);

    // Bridge pad: centered at rotor outer radius so it intersects BOTH rotor and buzzer
    // Center X at rotor_r ensures half of the bridge is inside the rotor (by overlap),
    // and the other half reaches toward the buzzer.
    translate([rotor_r, 0, buzzer_z])
      cube([bridge_len, bridge_w, bridge_h], center=true);
  }
}

// Motor assembly (single connected solid via union)
module assembly() {
  union() {

    // Stator
    color("DimGray")
      difference() {
        cylinder(r=stator_diameter_mm/2, h=stator_height_mm, center=true);
        cylinder(r=stator_bore_diameter_mm/2, h=stator_height_mm + 2*overlap_mm, center=true);
      }

    // Rotor can
    color("Black")
      difference() {
        cylinder(r=rotor_outer_diameter_mm/2, h=rotor_height_mm, center=true);
        cylinder(r=stator_diameter_mm/2 + clearance_mm, h=rotor_height_mm + 2*overlap_mm, center=true);
      }

    // Endcaps (slightly overlapping rotor for guaranteed union)
    color("Silver")
    union() {
      translate([0, 0, rotor_height_mm/2 + endcap_thickness_mm/2 - overlap_mm])
        cylinder(r=rotor_outer_diameter_mm/2, h=endcap_thickness_mm, center=true);

      translate([0, 0, -rotor_height_mm/2 - endcap_thickness_mm/2 + overlap_mm])
        cylinder(r=rotor_outer_diameter_mm/2, h=endcap_thickness_mm, center=true);
    }

    // Central shaft (passes through, already connected)
    color("Silver")
      translate([0, 0, (shaft_extension_front_mm - shaft_extension_rear_mm)/2])
        cylinder(
          r=shaft_diameter_mm/2,
          h=stator_height_mm + shaft_extension_front_mm + shaft_extension_rear_mm + 2*endcap_thickness_mm,
          center=true
        );

    // Side component (buzzer/connector) - now guaranteed attached (overlap + bridge)
    buzzer();
  }
}

assembly();