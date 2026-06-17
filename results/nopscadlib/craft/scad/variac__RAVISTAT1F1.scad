// Parameters
thickness = 3; //[1.5:6:0.5]
dial_enabled = 1; //[0:1:1]
overlap = 1; //[0.5:2:0.1]
body_diameter = 90; //[60:180:1]
body_height = 55; //[35:110:1]
bulge_width = 34; //[20:70:1]
bulge_extra_radius = 12; //[6:24:1]
bulge_height = 45; //[25:90:1]
mount_hole_count = 3; //[2:6:1]
mount_hole_circle_diameter = 70; //[45:140:1]
mount_hole_diameter = 5; //[3:10:0.5]
shaft_diameter = 10; //[6:20:0.5]
shaft_length_above = 22; //[10:60:1]
shaft_length_below = 2; //[0:10:0.5]
dial_diameter = 60; //[35:120:1]
dial_thickness = 6; //[3:15:0.5]
dial_hub_diameter = 18; //[10:40:0.5]
screw_shank_diameter = 4; //[2.5:8:0.5]
screw_head_diameter = 8; //[5:16:0.5]
screw_head_height = 3; //[1.5:8:0.5]
washer_outer_diameter = 10; //[6:20:0.5]
washer_thickness = 1.2; //[0.6:3:0.1]
screw_length = 16; //[8:40:1]

$fn = 96;

// Variac - ONE connected solid (no floating parts)
module variac() {

  // Key Z references (centered body)
  body_top_z = body_height/2;
  body_bot_z = -body_height/2;

  // Top base ring (sits on top of body, overlaps slightly)
  base_h = thickness;
  base_center_z = body_top_z + base_h/2 - overlap;

  // Dial (optional) sits on top of base, overlaps slightly
  dial_h = dial_thickness;
  dial_center_z = body_top_z + base_h + dial_h/2 - overlap;

  // Shaft spans through body and protrudes above/below
  shaft_h = body_height + shaft_length_above + shaft_length_below;
  shaft_center_z = (shaft_length_above - shaft_length_below)/2;

  // Bulge: side box attached to cylinder (Y+ direction), computed to intersect
  bulge_y = body_diameter/2 + bulge_extra_radius - overlap;

  // Screw/washer stack sits on top of dial (or base if dial disabled)
  top_stack_base_z = dial_enabled ? (dial_center_z + dial_h/2) : (base_center_z + base_h/2);

  // Ensure hardware is connected to the dial/base by overlapping downward
  washer_center_z = top_stack_base_z + washer_thickness/2 - overlap;
  head_center_z   = top_stack_base_z + washer_thickness + screw_head_height/2 - overlap;
  shank_center_z  = top_stack_base_z + washer_thickness + screw_head_height + screw_length/2 - overlap;

  // Mount hole positions
  hole_r = mount_hole_circle_diameter/2;

  // Build as a single union (no separate disconnected parts)
  union() {

    // Main body + bulge + top base ring (all connected)
    union() {
      cylinder(h=body_height, r=body_diameter/2, center=true);

      // Side bulge (connected by overlap into main cylinder)
      translate([0, bulge_y, 0])
        cube([bulge_width, bulge_extra_radius*2, bulge_height], center=true);

      // Top base interface (connected to body)
      translate([0, 0, base_center_z])
        cylinder(h=base_h, r=body_diameter/2, center=true);
    }

    // Shaft (connected through body)
    translate([0, 0, shaft_center_z])
      cylinder(h=shaft_h, r=shaft_diameter/2, center=true);

    // Dial + hub (connected to base)
    if (dial_enabled) {
      union() {
        translate([0, 0, dial_center_z])
          cylinder(h=dial_h, r=dial_diameter/2, center=true);

        // Hub overlaps slightly into dial for guaranteed connectivity
        translate([0, 0, dial_center_z])
          cylinder(h=dial_h + 2*overlap, r=dial_hub_diameter/2, center=true);
      }
    }

    // Screws + washers + heads (connected to dial/base via overlap)
    for (i = [0:mount_hole_count-1]) {
      x = cos(i*360/mount_hole_count) * hole_r;
      y = sin(i*360/mount_hole_count) * hole_r;

      union() {
        // Washer
        translate([x, y, washer_center_z])
          cylinder(h=washer_thickness, r=washer_outer_diameter/2, center=true);

        // Head
        translate([x, y, head_center_z])
          cylinder(h=screw_head_height, r=screw_head_diameter/2, center=true);

        // Shank (extends upward)
        translate([x, y, shank_center_z])
          cylinder(h=screw_length, r=screw_shank_diameter/2, center=true);

        // Overlap post down into dial/base to guarantee connectivity
        translate([x, y, top_stack_base_z - overlap/2])
          cylinder(h=overlap, r=screw_shank_diameter/2, center=true);
      }
    }
  }
}

// Assembly
variac();