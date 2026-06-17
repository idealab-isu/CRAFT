// Parameters
thickness = 3; //[1.5:6:0.5]
include_dial = 1; //[0:1:1]
body_diameter = 120; //[60:240:1]
body_height = 55; //[28:110:1]
bulge_width = 55; //[28:110:1]
bulge_depth = 18; //[9:36:1]
bulge_height = 45; //[22:90:1]
bulge_overlap = 1; //[0.5:2:0.1]
shaft_diameter = 10; //[5:20:0.5]
shaft_length = 25; //[12:50:1]
shaft_embed = 2; //[0.5:5:0.5]
mount_hole_count = 3; //[2:6:1]
mount_hole_radius = 2.6; //[1.5:4:0.1]
mount_hole_bcd = 90; //[45:180:1]
dial_diameter = 95; //[48:190:1]
dial_thickness = 3; //[1.5:8:0.5]
dial_clearance = 0.5; //[0.2:2:0.1]
knob_diameter = 35; //[18:70:1]
knob_height = 18; //[9:36:1]
knob_shaft_hole_radius = 5.2; //[2.6:10:0.1]
hardware_screw_radius = 2.5; //[1.5:4:0.1]
hardware_screw_length = 16; //[8:32:1]
washer_outer_radius = 5.5; //[3:11:0.1]
washer_thickness = 1.2; //[0.6:3:0.1]

// Variac - complete geometry
module variac() {
  color("DimGray") {
    // Main body with bulge
    union() {
      translate([0, 0, 0])
        cylinder(r=body_diameter/2, h=body_height, center=true);
      translate([0, -(body_diameter/2 + bulge_depth/2 - bulge_overlap), 0])
        cube([bulge_width, bulge_depth, bulge_height], center=true);
    }
    
    // Shaft
    translate([0, 0, (shaft_length - shaft_embed)/2])
      cylinder(r=shaft_diameter/2, h=body_height + shaft_length + shaft_embed, center=true);
    
    // Mounting holes
    for (i = [0:mount_hole_count-1]) {
      rotate([0, 0, i*360/mount_hole_count])
        translate([mount_hole_bcd/2, 0, 0])
          cylinder(r=mount_hole_radius, h=body_height + 2*thickness, center=true);
    }
  }
}

// Dial and Knob assembly
module dial_and_knob() {
  if (include_dial) {
    color("Silver") {
      // Dial face
      translate([0, 0, body_height/2 + thickness + dial_thickness/2 - dial_clearance])
        cylinder(r=dial_diameter/2, h=dial_thickness, center=true);
      
      // Knob
      translate([0, 0, body_height/2 + thickness + dial_thickness + knob_height/2 - dial_clearance])
        difference() {
          cylinder(r=knob_diameter/2, h=knob_height, center=true);
          cylinder(r=knob_shaft_hole_radius, h=knob_height + 2*thickness, center=true);
        }
    }
  }
}

// Screw and Washer assembly
module screw_and_washer_set() {
  color("Silver") {
    for (i = [0:mount_hole_count-1]) {
      rotate([0, 0, i*360/mount_hole_count]) {
        translate([mount_hole_bcd/2, 0, body_height/2 + thickness + dial_thickness + hardware_screw_length/2 - dial_clearance])
          cylinder(r=hardware_screw_radius, h=hardware_screw_length, center=true);
        
        translate([mount_hole_bcd/2, 0, body_height/2 + thickness + dial_thickness + washer_thickness/2 - dial_clearance])
          difference() {
            cylinder(r=washer_outer_radius, h=washer_thickness, center=true);
            cylinder(r=hardware_screw_radius + thickness/10, h=washer_thickness + 2*thickness/10, center=true);
          }
      }
    }
  }
}

// Assembly
module assembly() {
  variac();
  dial_and_knob();
  screw_and_washer_set();
}

assembly();