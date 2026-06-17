// Parameters
thickness = 3; //[1.5:6:0.5]
include_dial = 1; //[0:1:1]
body_diameter = 115; //[60:230:1]
body_height = 70; //[35:140:1]
bulge_width = 55; //[28:110:1]
bulge_extra_radius = 18; //[9:36:1]
bulge_height = 60; //[30:120:1]
bulge_overlap = 1; //[0.5:2:0.1]
base_interface_thickness = 3; //[1.5:8:0.5]
base_interface_overlap = 1; //[0.5:2:0.1]
shaft_diameter = 10; //[5:20:0.5]
shaft_length_above = 25; //[10:60:1]
shaft_overlap = 1; //[0.5:2:0.1]
mount_hole_count = 4; //[3:6:1]
mount_hole_diameter = 5; //[3:8:0.5]
mount_hole_radius = 45; //[25:90:1]
mount_hole_through_extra = 2; //[1:6:0.5]
dial_diameter = 60; //[30:120:1]
dial_thickness = 8; //[3:20:0.5]
dial_overlap = 1; //[0.5:2:0.1]

// Variac - complete geometry
module variac() {
  color("DimGray") {
    // Main body
    union() {
      // Body cylinder
      translate([0, 0, 0])
        cylinder(r=body_diameter/2, h=body_height, center=true, $fn=64);
      
      // Bulge
      translate([0, body_diameter/2 + bulge_extra_radius - bulge_overlap, 0])
        cube([bulge_width, 2*(body_diameter/2 + bulge_extra_radius), bulge_height], center=true);
      
      // Base interface
      translate([0, 0, -body_height/2 - base_interface_thickness/2 + base_interface_overlap])
        cylinder(r=body_diameter/2, h=base_interface_thickness, center=true, $fn=64);
    }
    
    // Shaft
    translate([0, 0, shaft_length_above/2 - shaft_overlap])
      cylinder(r=shaft_diameter/2, h=body_height + shaft_length_above, center=true, $fn=32);
    
    // Mounting holes
    difference() {
      union() {
        for (i = [0:mount_hole_count-1]) {
          rotate([0, 0, i*360/mount_hole_count])
            translate([mount_hole_radius, 0, -base_interface_thickness/2])
              cylinder(r=mount_hole_diameter/2, h=body_height + base_interface_thickness + mount_hole_through_extra, center=true, $fn=16);
        }
      }
    }
    
    // Dial (optional)
    if (include_dial) {
      translate([0, 0, body_height/2 + dial_thickness/2 - dial_overlap])
        cylinder(r=dial_diameter/2, h=dial_thickness, center=true, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  variac();
}

assembly();