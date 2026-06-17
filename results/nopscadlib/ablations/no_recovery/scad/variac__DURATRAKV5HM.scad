// Parameters
thickness = 3; //[1.5:6:0.5]
include_dial = 1; //[0:1:1]
include_fasteners = 0; //[0:1:1]
body_diameter = 115; //[60:230:1]
body_height = 70; //[35:140:1]
bulge_width = 55; //[28:110:1]
bulge_depth = 18; //[8:40:1]
bulge_height = 60; //[30:120:1]
shaft_diameter = 10; //[5:20:0.5]
shaft_length_above = 25; //[10:60:1]
mount_hole_diameter = 5; //[3:10:0.5]
mount_hole_radius = 45; //[25:90:1]
mount_hole_count = 4; //[3:6:1]
dial_diameter = 95; //[50:190:1]
dial_thickness = 3; //[1.5:8:0.5]
knob_diameter = 35; //[15:70:1]
knob_height = 18; //[8:40:1]
fastener_shaft_diameter = 4; //[2:8:0.5]
fastener_head_diameter = 8; //[4:16:0.5]
fastener_head_height = 3; //[1.5:8:0.5]
washer_outer_diameter = 10; //[6:20:0.5]
washer_thickness = 1.5; //[0.8:4:0.1]
overlap = 1; //[0.5:2:0.1]

// Variac Body with Bulge
module variac_body() {
  color("DimGray") {
    union() {
      // Main Body
      translate([0, 0, 0])
        cylinder(h=body_height, r=body_diameter/2, center=true, $fn=64);
      // Bulge
      translate([0, body_diameter/2 + bulge_depth/2 - overlap, 0])
        cube([bulge_width, bulge_depth, bulge_height], center=true);
    }
  }
}

// Shaft
module shaft() {
  color("Silver") {
    translate([0, 0, shaft_length_above/2])
      cylinder(h=body_height + shaft_length_above, r=shaft_diameter/2, center=true, $fn=32);
  }
}

// Mounting Holes
module mounting_holes() {
  for (i = [0:mount_hole_count-1]) {
    rotate([0, 0, i*360/mount_hole_count])
      translate([mount_hole_radius, 0, 0])
        cylinder(h=body_height + 2*overlap, r=mount_hole_diameter/2, center=true, $fn=32);
  }
}

// Dial Assembly
module dial_assembly() {
  if (include_dial) {
    color("Black") {
      union() {
        // Dial Face
        translate([0, 0, body_height/2 + dial_thickness/2 - overlap])
          cylinder(h=dial_thickness, r=dial_diameter/2, center=true, $fn=64);
        // Knob
        translate([0, 0, body_height/2 + dial_thickness - overlap + knob_height/2])
          cylinder(h=knob_height, r=knob_diameter/2, center=true, $fn=32);
      }
    }
  }
}

// Fasteners
module fasteners() {
  if (include_fasteners) {
    color("Silver") {
      for (i = [0:mount_hole_count-1]) {
        rotate([0, 0, i*360/mount_hole_count]) {
          translate([mount_hole_radius, 0, body_height/2 + (dial_thickness + washer_thickness + fastener_head_height)/2 - overlap])
            cylinder(h=dial_thickness + washer_thickness + fastener_head_height + overlap, r=fastener_shaft_diameter/2, center=true, $fn=32);
          translate([mount_hole_radius, 0, body_height/2 + dial_thickness + washer_thickness + fastener_head_height/2 - overlap])
            cylinder(h=fastener_head_height, r=fastener_head_diameter/2, center=true, $fn=32);
          translate([mount_hole_radius, 0, body_height/2 + dial_thickness + washer_thickness/2 - overlap])
            cylinder(h=washer_thickness, r=washer_outer_diameter/2, center=true, $fn=32);
        }
      }
    }
  }
}

// Complete Variac Assembly
module variac() {
  difference() {
    variac_body();
    mounting_holes();
  }
  shaft();
  dial_assembly();
  fasteners();
}

// Final Assembly
module assembly() {
  variac();
}

assembly();