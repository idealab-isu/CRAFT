// Parameters
profile_width = 40; //[20:80:1]
profile_height = 40; //[20:80:1]
length = 100; //[50:200:1]
center = 1; //[0:1:1]
cornerHole = 1; //[0:1:1]
eps = 1; //[0.2:2:0.1]
outer_fillet_r = 2; //[0:6:0.5]
wall = 2.5; //[1.5:5:0.1]
slot_opening = 8; //[4:14:0.5]
slot_neck = 6; //[3:12:0.5]
slot_depth = 10; //[6:16:0.5]
slot_head_width = 12; //[8:18:0.5]
slot_head_depth = 6; //[3:10:0.5]
center_bore_d = 8; //[4:16:0.5]
web_thickness = 3; //[1.5:6:0.5]
corner_hole_d = 4.2; //[0:8:0.1]
corner_hole_inset = 8; //[5:14:0.5]

// Extrusion - complete geometry
module extrusion() {
  color("Silver") {
    difference() {
      // Outer body
      cube([profile_width, profile_height, length], center=true);
      
      // T-slot channels
      union() {
        translate([profile_width/2 - (slot_depth + eps)/2, 0, 0])
          cube([slot_depth + eps, slot_opening, length + 2*eps], center=true);
        translate([profile_width/2 - slot_depth + slot_head_depth/2, 0, 0])
          cube([slot_head_depth + eps, slot_head_width, length + 2*eps], center=true);
        translate([-profile_width/2 + (slot_depth + eps)/2, 0, 0])
          cube([slot_depth + eps, slot_opening, length + 2*eps], center=true);
        translate([-profile_width/2 + slot_depth - slot_head_depth/2, 0, 0])
          cube([slot_head_depth + eps, slot_head_width, length + 2*eps], center=true);
        translate([0, profile_height/2 - (slot_depth + eps)/2, 0])
          cube([slot_opening, slot_depth + eps, length + 2*eps], center=true);
        translate([0, profile_height/2 - slot_depth + slot_head_depth/2, 0])
          cube([slot_head_width, slot_head_depth + eps, length + 2*eps], center=true);
        translate([0, -profile_height/2 + (slot_depth + eps)/2, 0])
          cube([slot_opening, slot_depth + eps, length + 2*eps], center=true);
        translate([0, -profile_height/2 + slot_depth - slot_head_depth/2, 0])
          cube([slot_head_width, slot_head_depth + eps, length + 2*eps], center=true);
      }
      
      // Center bore and internal webs
      union() {
        cylinder(r=center_bore_d/2, h=length + 2*eps, center=true);
        cube([profile_width - 2*(slot_depth - slot_head_depth) - 2*wall, web_thickness, length], center=true);
        cube([web_thickness, profile_height - 2*(slot_depth - slot_head_depth) - 2*wall, length], center=true);
      }
      
      // Corner holes
      if (cornerHole) {
        union() {
          translate([profile_width/2 - corner_hole_inset, profile_height/2 - corner_hole_inset, 0])
            cylinder(r=corner_hole_d/2, h=length + 2*eps, center=true);
          translate([profile_width/2 - corner_hole_inset, -profile_height/2 + corner_hole_inset, 0])
            cylinder(r=corner_hole_d/2, h=length + 2*eps, center=true);
          translate([-profile_width/2 + corner_hole_inset, profile_height/2 - corner_hole_inset, 0])
            cylinder(r=corner_hole_d/2, h=length + 2*eps, center=true);
          translate([-profile_width/2 + corner_hole_inset, -profile_height/2 + corner_hole_inset, 0])
            cylinder(r=corner_hole_d/2, h=length + 2*eps, center=true);
        }
      }
    }
  }
}

// Extrusion Cross Section - complete geometry
module extrusion_cross_section() {
  color("DimGray") {
    cube([profile_width, profile_height, wall], center=true);
  }
}

// Box Corner Profile Section - complete geometry
module box_corner_profile_section() {
  color("Black") {
    cube([wall, wall, length], center=true);
  }
}

// Box Corner Profile Sections - complete geometry
module box_corner_profile_sections() {
  color("Black") {
    union() {
      translate([profile_width/2 - wall/2, profile_height/2 - wall/2, 0])
        cube([wall, wall, length], center=true);
      translate([-profile_width/2 + wall/2, profile_height/2 - wall/2, 0])
        cube([wall, wall, length], center=true);
      translate([profile_width/2 - wall/2, -profile_height/2 + wall/2, 0])
        cube([wall, wall, length], center=true);
      translate([-profile_width/2 + wall/2, -profile_height/2 + wall/2, 0])
        cube([wall, wall, length], center=true);
    }
  }
}

// Assembly
module assembly() {
  extrusion();
  translate([0, 0, length/2 + wall/2]) extrusion_cross_section();
  translate([0, 0, -length/2 - wall/2]) box_corner_profile_section();
  translate([0, 0, -length/2 - wall/2]) box_corner_profile_sections();
}

assembly();