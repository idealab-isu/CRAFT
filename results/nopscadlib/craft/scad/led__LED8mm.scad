// 8.0mm through-hole LED, 9.2mm body height (body only; no extra plate/board)
// Model is ONE connected solid (lens + flange + leads)

led_diameter_mm   = 8.0;   //[4:16:0.1]
body_height_mm    = 9.2;   //[4.6:18.4:0.1]

lead_count        = 2;     //[2:2:1]
lead_length_mm    = 25.0;  //[2.5:40:0.1]
lead_pitch_mm     = 2.54;  //[1.27:5.08:0.01]
lead_thickness_mm = 0.5;   //[0.3:1:0.01]

rim_thickness_mm  = 1.0;   //[0.5:2:0.05]
rim_diameter_mm   = 9.2;   //[6:18.4:0.1]

$fn = 96;

// Derived
led_r = led_diameter_mm/2;
rim_r = rim_diameter_mm/2;

// Split body height into cylindrical base + domed lens (total = body_height_mm)
dome_h = min(led_diameter_mm*0.55, body_height_mm*0.60);
base_h = body_height_mm - dome_h;

// Small overlap to guarantee manifold unions
ov = 0.2;

module led_8mm_tht() {
  union() {
    // Flange: z = 0 .. rim_thickness_mm
    translate([0, 0, rim_thickness_mm/2])
      cylinder(r=rim_r, h=rim_thickness_mm, center=true);

    // Cylindrical body base: z = rim_thickness_mm .. rim_thickness_mm + base_h
    translate([0, 0, rim_thickness_mm + base_h/2 - ov/2])
      cylinder(r=led_r, h=base_h + ov, center=true);

    // Domed lens: starts at z = rim_thickness_mm + base_h
    // Use an ellipsoidal cap made from a scaled sphere, clipped to keep only the upper portion.
    translate([0, 0, rim_thickness_mm + base_h - ov])
      intersection() {
        scale([1, 1, dome_h/led_r])
          sphere(r=led_r);

        // Keep only the upper half (dome) and extend slightly for overlap
        translate([0, 0, led_r/2])
          cube([2*led_diameter_mm, 2*led_diameter_mm, 2*led_diameter_mm], center=true);
      }

    // Leads: attach to underside of flange (touch/overlap at z=0) and extend downward
    for (sx = [-1, 1]) {
      translate([sx*lead_pitch_mm/2, 0, -lead_length_mm/2 + ov/2])
        cube([lead_thickness_mm, lead_thickness_mm, lead_length_mm + ov], center=true);
    }
  }
}

led_8mm_tht();