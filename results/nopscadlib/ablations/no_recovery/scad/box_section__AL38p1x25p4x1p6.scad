// Parameters
outer_width = 38.1; //[19.05:76.2:0.1]
outer_height = 25.4; //[12.7:50.8:0.1]
wall_thickness = 1.6; //[0.8:3.2:0.1]
length = 200; //[20:1000:1]
eps_overlap = 1; //[0.5:2:0.1]
void_clearance = 0.2; //[0:0.6:0.05]
profile_thickness = 2.4; //[1.2:6:0.1]
profile_leg = 10; //[5:25:0.5]
bezel_depth = 6; //[2:20:0.5]
bezel_outset = 3; //[1:10:0.5]
bracket_width = 25; //[12.5:60:0.5]
bracket_height = 25; //[12.5:60:0.5]
bracket_depth = 20; //[10:80:1]

// Box Section
module box_section() {
  color("Silver") difference() {
    cube([outer_width, outer_height, length], center=true);
    translate([0, 0, 0])
      cube([outer_width - 2*(wall_thickness + void_clearance), 
            outer_height - 2*(wall_thickness + void_clearance), 
            length + 2*eps_overlap], center=true);
  }
}

// Box Corner Profile Section
module box_corner_profile_section() {
  color("DimGray") union() {
    translate([outer_width/2 + profile_leg/2 - eps_overlap, 
               outer_height/2 - profile_thickness/2, 0])
      cube([profile_leg, profile_thickness, length], center=true);
    translate([outer_width/2 - profile_thickness/2, 
               outer_height/2 + profile_leg/2 - eps_overlap, 0])
      cube([profile_thickness, profile_leg, length], center=true);
  }
}

// Box Bezel Section
module box_bezel_section() {
  color("Black") difference() {
    translate([0, 0, length/2 + bezel_depth/2 - eps_overlap])
      cube([outer_width + 2*bezel_outset, 
            outer_height + 2*bezel_outset, 
            bezel_depth], center=true);
    translate([0, 0, length/2 + bezel_depth/2 - eps_overlap])
      cube([outer_width + 2*(bezel_outset - profile_thickness), 
            outer_height + 2*(bezel_outset - profile_thickness), 
            bezel_depth + 2*eps_overlap], center=true);
  }
}

// Box Corner Profile Sections
module box_corner_profile_sections() {
  union() {
    box_section();
    box_corner_profile_section();
  }
}

// Box Shelf Bracket Section
module box_shelf_bracket_section() {
  color("Silver") union() {
    translate([outer_width/2 + bracket_width/2 - eps_overlap, 0, -length/2 + profile_thickness/2])
      cube([bracket_width, bracket_height, profile_thickness], center=true);
    translate([outer_width/2 + profile_thickness/2 - eps_overlap, 0, -length/2 + bracket_depth/2])
      cube([profile_thickness, bracket_height, bracket_depth], center=true);
  }
}

// Assembly
module assembly() {
  union() {
    box_corner_profile_sections();
    box_bezel_section();
    box_shelf_bracket_section();
  }
}

assembly();