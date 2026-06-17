// 3.0mm THT LED (connected solid), body height = 3.15mm

$fn = 96;

// Parameters
body_diameter = 3.0; //[1.5:6.0:0.1]
body_height = 3.15; //[1.6:6.3:0.05]          // cylindrical body height (not including dome)
lens_dome_height = 1.6; //[0.8:3.2:0.05]       // rounded top height above cylinder
flange_thickness = 0.55; //[0.2:1.2:0.05]
flange_diameter = 3.6; //[3.0:5.0:0.05]

lead_diameter = 0.5; //[0.25:1.0:0.05]
lead_length_below_body = 25.0; //[12.5:50.0:0.5]
lead_pitch = 2.54; //[1.27:5.08:0.01]

flat_side_depth = 0.35; //[0.15:0.7:0.05]

internal_cup_radius = 0.55; //[0.3:1.1:0.05]
internal_cup_height = 0.6; //[0.3:1.2:0.05]
internal_post_radius = 0.25; //[0.12:0.5:0.02]
internal_post_height = 1.2; //[0.6:2.4:0.05]

overlap = 0.2; //[0.05:1.0:0.05]

// Derived
body_r = body_diameter/2;
flange_r = flange_diameter/2;

z_body_bottom = 0;
z_body_top    = z_body_bottom + body_height;
z_flange_bot  = z_body_bottom;
z_flange_top  = z_flange_bot + flange_thickness;
z_dome_base   = z_body_top;
z_dome_top    = z_dome_base + lens_dome_height;

total_height = body_height + lens_dome_height;

// LED outer body (cylinder + flange + rounded dome) with a flat side
module led_body() {
  difference() {
    union() {
      // Main cylindrical body
      translate([0,0,(z_body_bottom+z_body_top)/2])
        cylinder(h=body_height, r=body_r, center=true);

      // Flange at bottom
      translate([0,0,(z_flange_bot+z_flange_top)/2])
        cylinder(h=flange_thickness, r=flange_r, center=true);

      // Rounded dome: intersection of sphere and a limiting cylinder to keep a clean profile
      intersection() {
        // Sphere centered so its top reaches z_dome_top
        translate([0,0,z_dome_top - body_r])
          sphere(r=body_r);

        // Keep only the portion above the cylinder top, and within body radius
        translate([0,0,(z_dome_base + z_dome_top)/2])
          cylinder(h=lens_dome_height + 2*overlap, r=body_r, center=true);
      }
    }

    // Flat side (D-shape) cut through full height
    // Place cut near +X side; depth is how much is removed from the circular outline.
    translate([body_r - flat_side_depth/2, 0, total_height/2])
      cube([flat_side_depth, body_diameter*1.6, total_height + 2*overlap], center=true);
  }
}

// Internal features (kept small and connected inside body)
module internal_anvil_cup() {
  // Slightly embedded above bottom so it is inside the body volume
  z0 = z_body_bottom + internal_cup_height/2 + overlap;
  difference() {
    translate([-lead_pitch/2, 0, z0])
      cylinder(h=internal_cup_height, r=internal_cup_radius, center=true);
    translate([-lead_pitch/2, 0, z0 + overlap/2])
      cylinder(h=internal_cup_height + overlap, r=max(0.01, internal_cup_radius - lead_diameter/6), center=true);
  }
}

module internal_post() {
  z0 = z_body_bottom + internal_post_height/2 + overlap;
  translate([lead_pitch/2, 0, z0])
    cylinder(h=internal_post_height, r=internal_post_radius, center=true);
}

// Straight lead exiting from bottom (no side protrusions)
module lead(xpos) {
  // Lead starts slightly inside body to guarantee union connectivity
  z_top = z_body_bottom + overlap;
  z_bot = z_body_bottom - lead_length_below_body;

  translate([xpos, 0, (z_top + z_bot)/2])
    cylinder(h=(z_top - z_bot), r=lead_diameter/2, center=true);
}

// Complete LED Model (single connected solid)
module led_complete_model() {
  union() {
    led_body();

    // Leads
    lead(-lead_pitch/2);
    lead( lead_pitch/2);

    // Internal metal parts (optional visual detail, still connected)
    internal_anvil_cup();
    internal_post();
  }
}

led_complete_model();