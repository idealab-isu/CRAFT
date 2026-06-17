// 8.0mm through-hole LED, 9.2mm body height (single connected solid)

// Parameters
led_diameter_mm = 8; //[4:16:0.1]
body_height_mm = 9.2; //[4.6:18.4:0.1]
through_hole = 1; //[0:1:1]
lead_count = 2; //[2:2:1]
lead_pitch_mm = 2.54; //[1.27:5.08:0.01]
lead_length_mm = 25; //[10:50:0.5]
lead_thickness_mm = 0.6; //[0.3:1.2:0.05]
rim_diameter_mm = 9.2; //[6:18.4:0.1]
rim_thickness_mm = 1.2; //[0.6:2.4:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// Derived
led_r = led_diameter_mm/2;
rim_r = rim_diameter_mm/2;

// LED Module (single connected solid)
module led() {
  // Place LED so rim bottom sits at Z=0 and leads extend downward
  // Z references:
  // rim: z in [0, rim_thickness]
  // body: z in [rim_thickness, rim_thickness + body_height]
  // leads: z in [-lead_length, overlap] (overlap into rim for connectivity)

  union() {
    // Rim (flange)
    translate([0, 0, rim_thickness_mm/2])
      cylinder(r=rim_r, h=rim_thickness_mm, center=true, $fn=96);

    // Body: cylindrical base + rounded dome top (typical T-1 3/4 style)
    // Cylindrical portion
    translate([0, 0, rim_thickness_mm + body_height_mm/2])
      cylinder(r=led_r, h=body_height_mm, center=true, $fn=96);

    // Rounded lens dome (hemisphere) on top, slightly overlapping into cylinder
    dome_r = led_r;
    translate([0, 0, rim_thickness_mm + body_height_mm - overlap_mm])
      intersection() {
        sphere(r=dome_r, $fn=96);
        // keep only upper half of sphere
        translate([0, 0, dome_r/2]) cube([2*dome_r+2, 2*dome_r+2, 2*dome_r], center=true);
      }

    // Leads (rectangular pins), connected into rim by overlap
    if (through_hole) {
      for (sx = [-1, 1]) {
        translate([sx*lead_pitch_mm/2, 0, -lead_length_mm/2 + overlap_mm/2])
          cube([lead_thickness_mm, lead_thickness_mm, lead_length_mm + overlap_mm], center=true);
      }
    }
  }
}

// Call
led();