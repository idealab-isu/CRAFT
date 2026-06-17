// 3.0mm THT LED, 3.15mm body height (standalone, one connected solid)

// Parameters
led_diameter_mm = 3.0;          //[1.5:6.0:0.1]
body_height_mm  = 3.15;         //[1.6:6.3:0.05]   // cylindrical lens height (excluding rim)
lead_length_mm  = 5.0;          //[2.5:10.0:0.1]
right_angle     = 0;            //[0:6:1]
lead_pitch_mm   = 2.54;         //[1.27:5.08:0.01]
lead_thickness_mm = 0.5;        //[0.25:1.0:0.05]
rim_thickness_mm  = 0.6;        //[0.3:1.2:0.05]
rim_diameter_mm   = 3.6;        //[3.0:7.2:0.05]
lead_overlap_mm   = 0.8;        //[0.5:2.0:0.1]
eps_mm            = 0.2;        //[0.05:0.5:0.05]

$fn = 96;

// LED Module (single connected solid)
module led() {
  r_body = led_diameter_mm/2;
  r_rim  = rim_diameter_mm/2;

  // Z references
  z_rim_center  = rim_thickness_mm/2;                 // rim spans z=[0..rim_thickness]
  z_body_base   = rim_thickness_mm;                   // body starts on top of rim
  z_body_center = z_body_base + body_height_mm/2;     // cylinder center
  z_dome_center = z_body_base + body_height_mm;       // hemisphere center at top of cylinder

  // Leads: extend up into rim by lead_overlap_mm to ensure connectivity
  lead_total_h = lead_length_mm + rim_thickness_mm + lead_overlap_mm;
  z_lead_center = (rim_thickness_mm - lead_overlap_mm)/2 - lead_length_mm/2;

  color("red")
  union() {
    // Rim flange
    translate([0, 0, z_rim_center])
      cylinder(r=r_rim, h=rim_thickness_mm, center=true);

    // Cylindrical lens body (exactly body_height_mm tall)
    translate([0, 0, z_body_center])
      cylinder(r=r_body, h=body_height_mm, center=true);

    // Rounded dome (hemisphere) on top
    intersection() {
      translate([0, 0, z_dome_center])
        sphere(r=r_body);
      // keep only upper half to form a dome
      translate([0, 0, z_dome_center + r_body/2])
        cube([2*r_body + 2*eps_mm, 2*r_body + 2*eps_mm, r_body + 2*eps_mm], center=true);
    }

    // Leads (two square pins)
    for (sx = [-1, 1]) {
      translate([sx*lead_pitch_mm/2, 0, z_lead_center])
        cube([lead_thickness_mm, lead_thickness_mm, lead_total_h], center=true);
    }

    // Optional right-angle bend (kept connected; disabled by default)
    if (right_angle > 0) {
      bend_len = right_angle;
      // Bend starts just below rim bottom, with overlap into vertical lead
      z_bend_center = -lead_thickness_mm/2 - eps_mm;

      for (sx = [-1, 1]) {
        // short vertical stub to ensure overlap at the bend
        translate([sx*lead_pitch_mm/2, -(bend_len/2 + lead_thickness_mm/2 - eps_mm), z_bend_center + lead_thickness_mm/2])
          cube([lead_thickness_mm, lead_thickness_mm, lead_thickness_mm + lead_overlap_mm], center=true);

        // horizontal segment
        translate([sx*lead_pitch_mm/2, -(bend_len/2 + lead_thickness_mm/2 - eps_mm), z_bend_center])
          cube([lead_thickness_mm, bend_len + lead_overlap_mm, lead_thickness_mm], center=true);
      }
    }
  }
}

led();