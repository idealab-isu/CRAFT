// Toggle switch (connected solid) - 7.0mm body diameter, 13.6mm overall height

// Parameters
body_diameter_mm = 7; //[3.5:14:0.1]
overall_height_mm = 13.6; //[6.8:27.2:0.1]

body_height_mm = 9.6; //[4.8:19.2:0.1]
collar_diameter_mm = 9.5; //[5:19:0.1]
collar_height_mm = 4; //[2:8:0.1]

nut_diameter_mm = 11; //[6:22:0.1]
nut_thickness_mm = 2.2; //[1:4.4:0.1]
washer_diameter_mm = 11.5; //[6:23:0.1]
washer_thickness_mm = 0.8; //[0.4:1.6:0.1]

lever_diameter_mm = 2.5; //[1.2:5:0.1]
lever_height_mm = 4.8; //[2:10:0.1]
toggle_ball_diameter_mm = 3.5; //[2:7:0.1]

pin_count = 3; //[2:6:1]
pin_width_mm = 1; //[0.5:2:0.1]
pin_thickness_mm = 0.6; //[0.3:1.2:0.1]
pin_length_mm = 4; //[2:8:0.1]
pin_pitch_mm = 2.54; //[1.5:5.08:0.01]

overlap_mm = 1; //[0.5:2:0.1]
include_threads = 1; //[0:1:1]
include_nut_and_washer = 1; //[0:1:1]
include_terminals = 1; //[0:1:1]

$fn = 48;

// Toggle switch - complete geometry
module toggle() {
  // Derived: enforce overall height by solving for required bottom extension
  // Total height = bottom_ext + body_height + collar_height + lever_height + ball_d
  bottom_extension_mm = max(
    0,
    overall_height_mm - (body_height_mm + collar_height_mm + lever_height_mm + toggle_ball_diameter_mm)
  );

  union() {
    // Main body (centered at origin)
    cylinder(r=body_diameter_mm/2, h=body_height_mm, center=true);

    // Collar (threaded bushing region) - connected to top of body
    if (include_threads) {
      translate([0, 0, body_height_mm/2 + collar_height_mm/2 - overlap_mm])
        cylinder(r=collar_diameter_mm/2, h=collar_height_mm, center=true);
    }

    // Washer - sits on collar/top area, overlaps into collar for connectivity
    if (include_nut_and_washer) {
      translate([0, 0, body_height_mm/2 + collar_height_mm + washer_thickness_mm/2 - overlap_mm])
        cylinder(r=washer_diameter_mm/2, h=washer_thickness_mm, center=true);
    }

    // Nut - overlaps into washer for connectivity
    if (include_nut_and_washer) {
      translate([0, 0, body_height_mm/2 + collar_height_mm + washer_thickness_mm + nut_thickness_mm/2 - overlap_mm])
        cylinder(r=nut_diameter_mm/2, h=nut_thickness_mm, center=true, $fn=6);
    }

    // Lever - starts at top of collar (not above nut), overlaps into collar
    translate([0, 0, body_height_mm/2 + collar_height_mm + lever_height_mm/2 - overlap_mm])
      cylinder(r=lever_diameter_mm/2, h=lever_height_mm, center=true);

    // Toggle ball - overlaps into lever
    translate([0, 0, body_height_mm/2 + collar_height_mm + lever_height_mm - overlap_mm])
      sphere(r=toggle_ball_diameter_mm/2);

    // Bottom extension (to satisfy overall height) - connected to bottom of body
    if (bottom_extension_mm > 0) {
      translate([0, 0, -body_height_mm/2 - bottom_extension_mm/2 + overlap_mm])
        cylinder(r=lever_diameter_mm/2, h=bottom_extension_mm, center=true);
    }

    // Terminal pins - connected to bottom extension if present, otherwise to body
    if (include_terminals) {
      pin_attach_z = (bottom_extension_mm > 0)
        ? (-body_height_mm/2 - bottom_extension_mm + overlap_mm)   // bottom of extension
        : (-body_height_mm/2 + overlap_mm);                        // bottom of body

      for (i = [0:pin_count-1]) {
        x = (i - (pin_count-1)/2) * pin_pitch_mm;
        translate([x, 0, pin_attach_z - pin_length_mm/2 + overlap_mm])
          cube([pin_width_mm, pin_thickness_mm, pin_length_mm], center=true);
      }
    }
  }
}

toggle();