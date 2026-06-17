// Parameters
outer_width = 50.8; //[25.4:101.6:0.1]
outer_height = 38.1; //[19.05:76.2:0.1]
wall_thickness = 3.0; //[1.5:6.0:0.1]
length = 200; //[50:1000:1]
centered = 1; //[0:1:1]
corner_fillet_radius = 0; //[0:6:0.1]
eps = 0.5; //[0.2:2:0.1]
inner_width = 44.8; //[19.4:95.6:0.1]
inner_height = 32.1; //[13.05:70.2:0.1]
bezel_thickness = 2.0; //[1.0:6.0:0.1]
bezel_outset = 4.0; //[1.0:12.0:0.1]
corner_profile_leg = 10.0; //[5.0:25.0:0.1]
corner_profile_thickness = 3.0; //[1.5:8.0:0.1]
corner_profile_length = 25.0; //[10.0:80.0:1]
shelf_bracket_width = 25.0; //[10.0:60.0:0.5]
shelf_bracket_height = 25.0; //[10.0:60.0:0.5]
shelf_bracket_thickness = 4.0; //[2.0:10.0:0.1]

// Box Section
module box_section() {
  color("Silver") {
    difference() {
      cube([outer_width, outer_height, length], center=true);
      translate([0, 0, 0])
        cube([inner_width, inner_height, length], center=true);
    }
  }
}

// Box Bezel Section
module box_bezel_section() {
  color("DimGray") {
    difference() {
      cube([outer_width + 2*bezel_outset, outer_height + 2*bezel_outset, bezel_thickness], center=true);
      translate([0, 0, eps])
        cube([outer_width, outer_height, bezel_thickness + 2*eps], center=true);
    }
  }
}

// Box Corner Profile Section
module box_corner_profile_section() {
  color("Black") {
    union() {
      translate([outer_width/2 + corner_profile_leg/2 - eps, outer_height/2 + corner_profile_thickness/2 - eps, length/2 - corner_profile_length/2 + eps])
        cube([corner_profile_leg, corner_profile_thickness, corner_profile_length], center=true);
      translate([outer_width/2 + corner_profile_thickness/2 - eps, outer_height/2 + corner_profile_leg/2 - eps, length/2 - corner_profile_length/2 + eps])
        cube([corner_profile_thickness, corner_profile_leg, corner_profile_length], center=true);
    }
  }
}

// Box Corner Profile Sections
module box_corner_profile_sections() {
  box_corner_profile_section();
}

// Box Shelf Bracket Section
module box_shelf_bracket_section() {
  color("Silver") {
    translate([outer_width/2 + shelf_bracket_thickness/2 - eps, 0, -length/2 + shelf_bracket_height/2 - eps])
      cube([shelf_bracket_thickness, shelf_bracket_width, shelf_bracket_height], center=true);
  }
}

// Assembly
module assembly() {
  box_section();
  translate([0, 0, length/2 - bezel_thickness/2 + eps]) box_bezel_section();
  box_corner_profile_sections();
  box_shelf_bracket_section();
}

assembly();