// Parameters
thickness = 3; //[1.5:6:0.5]
include_dial = 1; //[0:1:1]
include_mounting_hardware = 1; //[0:1:1]
overlap = 1; //[0.5:2:0.1]
body_diameter = 120; //[60:240:1]
body_height = 70; //[35:140:1]
bulge_width = 55; //[28:110:1]
bulge_depth = 18; //[9:36:1]
bulge_height = 60; //[30:120:1]
shaft_diameter = 10; //[5:20:0.5]
shaft_length = 25; //[10:60:1]
mount_hole_diameter = 5; //[3:10:0.5]
mount_hole_spacing_x = 80; //[40:160:1]
mount_hole_spacing_y = 60; //[30:120:1]
dial_diameter = 90; //[45:180:1]
dial_thickness = 6; //[3:15:0.5]
dial_hub_diameter = 22; //[11:44:0.5]
dial_hub_height = 10; //[5:25:0.5]
screw_shaft_diameter = 4; //[2:8:0.5]
screw_length = 16; //[8:40:1]
washer_outer_diameter = 10; //[5:20:0.5]
washer_thickness = 1.5; //[0.8:4:0.1]

$fn = 96;

// Variac - complete geometry (ONE connected solid)
module variac() {

  // Ensure robust overlap even if user sets overlap too small
  ov = max(overlap, 0.6);

  // Derived Z positions (centered body at z=0)
  body_top_z = body_height/2;
  body_bot_z = -body_height/2;

  // Dial stack sits on top face and overlaps into body
  dial_z = body_top_z + dial_thickness/2 - ov;
  hub_z  = body_top_z + dial_thickness + dial_hub_height/2 - ov;

  // Shaft protrudes from top face and overlaps into body
  shaft_z = body_top_z + shaft_length/2 - ov;

  // Hardware: place on top face and overlap into body
  washer_z = body_top_z + washer_thickness/2 - ov;
  screw_z  = body_top_z + washer_thickness + screw_length/2 - ov;

  // Bulge: attach to side of cylinder with overlap
  bulge_x = body_diameter/2 + bulge_depth/2 - ov;

  union() {

    // Main body + bulge with mounting holes cut out
    difference() {
      union() {
        // Main cylindrical body
        cylinder(h=body_height, r=body_diameter/2, center=true);

        // Side bulge (connected)
        translate([bulge_x, 0, 0])
          cube([bulge_depth, bulge_width, bulge_height], center=true);
      }

      // Mounting holes (through body)
      for (x = [-1, 1], y = [-1, 1]) {
        translate([x * mount_hole_spacing_x/2, y * mount_hole_spacing_y/2, 0])
          cylinder(h=body_height + 4*ov, r=mount_hole_diameter/2, center=true, $fn=48);
      }
    }

    // Shaft (connected to top of body)
    translate([0, 0, shaft_z])
      cylinder(h=shaft_length + 2*ov, r=shaft_diameter/2, center=true, $fn=48);

    // Dial + hub (connected to body via overlap)
    if (include_dial) {
      translate([0, 0, dial_z])
        cylinder(h=dial_thickness + 2*ov, r=dial_diameter/2, center=true);

      translate([0, 0, hub_z])
        cylinder(h=dial_hub_height + 2*ov, r=dial_hub_diameter/2, center=true, $fn=64);
    }

    // Mounting screws and washers (connected by overlapping into body top region)
    if (include_mounting_hardware) {
      for (x = [-1, 1], y = [-1, 1]) {
        // Washer
        translate([x * mount_hole_spacing_x/2, y * mount_hole_spacing_y/2, washer_z])
          cylinder(h=washer_thickness + 2*ov, r=washer_outer_diameter/2, center=true, $fn=48);

        // Screw shaft
        translate([x * mount_hole_spacing_x/2, y * mount_hole_spacing_y/2, screw_z])
          cylinder(h=screw_length + 2*ov, r=screw_shaft_diameter/2, center=true, $fn=48);
      }
    }
  }
}

// Assembly
module assembly() {
  variac();
}

assembly();