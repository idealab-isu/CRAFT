// Parameters
thickness = 3; //[1.5:6:0.5]
dial = 1; //[0:1:1]
body_diameter = 90; //[45:180:1]
body_height = 55; //[28:110:1]
bulge_width = 42; //[21:84:1]
bulge_depth = 18; //[9:36:1]
bulge_height = 45; //[22:90:1]
shaft_diameter = 10; //[5:20:0.5]
shaft_length_above = 22; //[10:44:1]
shaft_length_inside = 6; //[3:12:1]
mount_hole_count = 3; //[2:6:1]
mount_hole_circle_diameter = 70; //[35:140:1]
mount_hole_diameter = 4.5; //[2.5:9:0.1]
mount_hole_depth = 12; //[6:24:1]
dial_diameter = 60; //[30:120:1]
dial_thickness = 3; //[1.5:8:0.5]
knob_diameter = 28; //[14:56:1]
knob_height = 18; //[9:36:1]
screw_shank_diameter = 4; //[2:8:0.1]
screw_head_diameter = 7.5; //[4:15:0.1]
screw_head_height = 2.5; //[1:6:0.1]
washer_outer_diameter = 10; //[5:20:0.1]
washer_thickness = 1.2; //[0.6:3:0.1]
overlap = 1; //[0.5:2:0.1]

// Variac Body with Bulge
module variac_body() {
  color("DimGray") {
    union() {
      // Main Body
      translate([0, 0, 0])
        cylinder(r=body_diameter/2, h=body_height, center=true, $fn=64);
      // Bulge
      translate([body_diameter/2 + (bulge_depth + overlap)/2 - overlap, 0, 0])
        cube([bulge_depth + overlap, bulge_width, bulge_height], center=true);
    }
  }
}

// Central Shaft
module central_shaft() {
  color("Silver") {
    translate([0, 0, body_height/4 + (shaft_length_above + shaft_length_inside)/2 - overlap/2])
      cylinder(r=shaft_diameter/2, h=body_height/2 + shaft_length_above + shaft_length_inside, center=true, $fn=32);
  }
}

// Mounting Holes
module mounting_holes() {
  for (i = [0:mount_hole_count-1]) {
    rotate([0, 0, i*360/mount_hole_count])
      translate([mount_hole_circle_diameter/2, 0, -body_height/2 + (mount_hole_depth + overlap)/2 - overlap/2])
        cylinder(r=mount_hole_diameter/2, h=mount_hole_depth + overlap, center=true, $fn=32);
  }
}

// Dial Assembly
module dial_assembly() {
  if (dial == 1) {
    color("Black") {
      union() {
        // Dial Face
        translate([0, 0, body_height/2 + dial_thickness/2 - overlap])
          cylinder(r=dial_diameter/2, h=dial_thickness, center=true, $fn=64);
        // Knob
        translate([0, 0, body_height/2 + dial_thickness + knob_height/2 - overlap])
          cylinder(r=knob_diameter/2, h=knob_height, center=true, $fn=32);
      }
    }
  }
}

// Mounting Screws and Washers
module mounting_screws_and_washers() {
  for (i = [0:mount_hole_count-1]) {
    rotate([0, 0, i*360/mount_hole_count]) {
      // Screw Shank
      translate([mount_hole_circle_diameter/2, 0, body_height/2 + (thickness + washer_thickness + screw_head_height + overlap)/2 - overlap])
        cylinder(r=screw_shank_diameter/2, h=thickness + washer_thickness + screw_head_height + overlap, center=true, $fn=16);
      // Screw Head
      translate([mount_hole_circle_diameter/2, 0, body_height/2 + thickness + washer_thickness + screw_head_height/2 - overlap])
        cylinder(r=screw_head_diameter/2, h=screw_head_height, center=true, $fn=16);
      // Washer
      translate([mount_hole_circle_diameter/2, 0, body_height/2 + thickness + washer_thickness/2 - overlap])
        cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true, $fn=16);
    }
  }
}

// Complete Variac Assembly
module variac() {
  difference() {
    variac_body();
    mounting_holes();
  }
  central_shaft();
  dial_assembly();
  mounting_screws_and_washers();
}

// Final Assembly
module assembly() {
  variac();
}

assembly();