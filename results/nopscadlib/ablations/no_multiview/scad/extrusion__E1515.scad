// Parameters
cross_section_width = 15; //[7.5:30:0.5]
cross_section_height = 15; //[7.5:30:0.5]
length = 100; //[50:200:1]
center = 1; //[0:1:1]
cornerHole = 1; //[0:1:1]
wall_thickness = 2.0; //[1.0:4.0:0.25]
slot_opening_width = 6.0; //[3.0:10.0:0.25]
slot_inner_width = 8.0; //[4.0:12.0:0.25]
slot_depth = 4.5; //[2.0:7.0:0.25]
slot_neck_depth = 1.8; //[0.8:3.5:0.1]
center_bore_diameter = 5.0; //[2.0:10.0:0.25]
corner_hole_diameter_base = 3.0; //[1.5:6.0:0.25]
corner_hole_inset = 3.5; //[2.0:6.0:0.25]
overlap = 1.0; //[0.5:2.0:0.25]

// Extrusion Profile Body
module extrusion_profile_body() {
  color("Silver") {
    cube([cross_section_width, cross_section_height, length], center=true);
  }
}

// T-Slot Channels
module t_slot_channels() {
  union() {
    translate([cross_section_width/2 - (slot_neck_depth + overlap)/2, 0, 0])
      cube([slot_neck_depth + overlap, slot_opening_width, length + 2*overlap], center=true);
    translate([cross_section_width/2 - (slot_depth + overlap)/2, 0, 0])
      cube([slot_depth + overlap, slot_inner_width, length + 2*overlap], center=true);
    translate([-cross_section_width/2 + (slot_neck_depth + overlap)/2, 0, 0])
      cube([slot_neck_depth + overlap, slot_opening_width, length + 2*overlap], center=true);
    translate([-cross_section_width/2 + (slot_depth + overlap)/2, 0, 0])
      cube([slot_depth + overlap, slot_inner_width, length + 2*overlap], center=true);
    translate([0, cross_section_height/2 - (slot_neck_depth + overlap)/2, 0])
      cube([slot_opening_width, slot_neck_depth + overlap, length + 2*overlap], center=true);
    translate([0, cross_section_height/2 - (slot_depth + overlap)/2, 0])
      cube([slot_inner_width, slot_depth + overlap, length + 2*overlap], center=true);
    translate([0, -cross_section_height/2 + (slot_neck_depth + overlap)/2, 0])
      cube([slot_opening_width, slot_neck_depth + overlap, length + 2*overlap], center=true);
    translate([0, -cross_section_height/2 + (slot_depth + overlap)/2, 0])
      cube([slot_inner_width, slot_depth + overlap, length + 2*overlap], center=true);
  }
}

// Center Bore
module center_bore() {
  color("Black") {
    cylinder(r=center_bore_diameter/2, h=length + 2*overlap, center=true);
  }
}

// Corner Holes
module corner_holes() {
  if (cornerHole) {
    union() {
      translate([cross_section_width/2 - corner_hole_inset, cross_section_height/2 - corner_hole_inset, 0])
        cylinder(r=(corner_hole_diameter_base*cornerHole)/2, h=length + 2*overlap, center=true);
      translate([-cross_section_width/2 + corner_hole_inset, cross_section_height/2 - corner_hole_inset, 0])
        cylinder(r=(corner_hole_diameter_base*cornerHole)/2, h=length + 2*overlap, center=true);
      translate([cross_section_width/2 - corner_hole_inset, -cross_section_height/2 + corner_hole_inset, 0])
        cylinder(r=(corner_hole_diameter_base*cornerHole)/2, h=length + 2*overlap, center=true);
      translate([-cross_section_width/2 + corner_hole_inset, -cross_section_height/2 + corner_hole_inset, 0])
        cylinder(r=(corner_hole_diameter_base*cornerHole)/2, h=length + 2*overlap, center=true);
    }
  }
}

// Box Corner Profile Section
module box_corner_profile_section() {
  color("DimGray") {
    translate([cross_section_width/2 - wall_thickness/2, cross_section_height/2 - wall_thickness/2, 0])
      cube([wall_thickness, wall_thickness, length], center=true);
  }
}

// Box Corner Profile Sections
module box_corner_profile_sections() {
  union() {
    box_corner_profile_section();
    translate([-cross_section_width + wall_thickness, 0, 0]) box_corner_profile_section();
    translate([0, -cross_section_height + wall_thickness, 0]) box_corner_profile_section();
    translate([-cross_section_width + wall_thickness, -cross_section_height + wall_thickness, 0]) box_corner_profile_section();
  }
}

// Extrusion Cross Section
module extrusion_cross_section() {
  difference() {
    extrusion_profile_body();
    t_slot_channels();
    center_bore();
    corner_holes();
  }
}

// Extrusion
module extrusion() {
  union() {
    extrusion_cross_section();
    box_corner_profile_sections();
  }
}

// Assembly
module assembly() {
  extrusion();
}

assembly();