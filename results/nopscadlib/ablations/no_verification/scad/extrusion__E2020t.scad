// Parameters
profile_width = 20.0; //[10.0:40.0:0.5]
profile_height = 20.0; //[10.0:40.0:0.5]
length = 100.0; //[50.0:200.0:1]
center = 1; //[0:1:1]
cornerHole = 1; //[0:1:1]
wall_thickness = 2.0; //[1.0:4.0:0.25]
slot_opening = 6.0; //[3.0:10.0:0.25]
slot_depth = 6.0; //[3.0:10.0:0.25]
slot_cavity_width = 10.0; //[6.0:16.0:0.25]
center_bore_diameter = 5.0; //[3.0:10.0:0.25]
corner_hole_diameter = 4.2; //[2.0:8.0:0.1]
corner_hole_offset = 6.0; //[4.0:10.0:0.25]
overlap = 1.0; //[0.5:2.0:0.1]

// Extrusion - complete geometry
module extrusion() {
  color("Silver") {
    difference() {
      // Main body
      cube([profile_width, profile_height, length], center=true);
      
      // Center bore
      translate([0, 0, 0])
        cylinder(r=center_bore_diameter/2, h=length + 2*overlap, center=true);
      
      // T-slot channels
      union() {
        // X-direction slots
        for (i = [-1, 1]) {
          translate([i * (profile_width/2 - (slot_depth + 2*overlap)/2 + overlap), 0, 0]) {
            cube([slot_depth + 2*overlap, slot_opening, length + 2*overlap], center=true);
            cube([slot_depth + 2*overlap, slot_cavity_width, length + 2*overlap], center=true);
          }
        }
        // Y-direction slots
        for (i = [-1, 1]) {
          translate([0, i * (profile_height/2 - (slot_depth + 2*overlap)/2 + overlap), 0]) {
            cube([slot_opening, slot_depth + 2*overlap, length + 2*overlap], center=true);
            cube([slot_cavity_width, slot_depth + 2*overlap, length + 2*overlap], center=true);
          }
        }
      }
      
      // Corner holes
      if (cornerHole) {
        for (x = [-1, 1], y = [-1, 1]) {
          translate([x * (profile_width/2 - corner_hole_offset), y * (profile_height/2 - corner_hole_offset), 0])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
        }
      }
    }
  }
}

// Box Corner Profile Section - complete geometry
module box_corner_profile_section() {
  color("DimGray") {
    cube([wall_thickness, wall_thickness, length], center=true);
  }
}

// Box Corner Profile Sections - complete geometry
module box_corner_profile_sections() {
  union() {
    box_corner_profile_section();
    mirror([1, 0, 0]) box_corner_profile_section();
    mirror([0, 1, 0]) box_corner_profile_section();
    mirror([1, 1, 0]) box_corner_profile_section();
  }
}

// Extrusion Cross Section - complete geometry
module extrusion_cross_section() {
  difference() {
    extrusion();
    box_corner_profile_sections();
  }
}

// Assembly
module assembly() {
  extrusion_cross_section();
}

assembly();