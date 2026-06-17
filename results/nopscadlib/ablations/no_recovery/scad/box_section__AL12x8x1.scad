// Parameters
outer_width_mm = 12; //[6:24:1]
outer_height_mm = 8; //[4:16:1]
wall_thickness_mm = 1; //[0.5:2:0.1]
length_mm = 100; //[50:200:1]
eps_mm = 0.5; //[0.2:2:0.1]
inner_width_mm = 10; //[4:22:1]
inner_height_mm = 6; //[2:14:1]
bezel_thickness_mm = 2; //[1:5:0.5]
bezel_outset_mm = 2; //[1:6:0.5]
corner_profile_leg_mm = 3; //[1.5:6:0.5]
corner_profile_length_mm = 20; //[10:60:1]
bracket_thickness_mm = 3; //[1.5:6:0.5]
bracket_width_mm = 16; //[8:32:1]
bracket_height_mm = 16; //[8:32:1]

// Box Section
module box_section() {
  color("Silver") difference() {
    cube([outer_width_mm, outer_height_mm, length_mm], center=true);
    translate([0, 0, 0])
      cube([inner_width_mm, inner_height_mm, length_mm + 2*eps_mm], center=true);
  }
}

// Box Bezel Section
module box_bezel_section() {
  color("DimGray") difference() {
    translate([0, 0, length_mm/2 - bezel_thickness_mm/2 + eps_mm/2])
      cube([outer_width_mm + 2*bezel_outset_mm, outer_height_mm + 2*bezel_outset_mm, bezel_thickness_mm], center=true);
    translate([0, 0, length_mm/2 - bezel_thickness_mm/2 + eps_mm/2])
      cube([outer_width_mm + eps_mm, outer_height_mm + eps_mm, bezel_thickness_mm + 2*eps_mm], center=true);
  }
}

// Box Corner Profile Section
module box_corner_profile_section() {
  color("Black") union() {
    cube([corner_profile_leg_mm, wall_thickness_mm, corner_profile_length_mm], center=true);
    cube([wall_thickness_mm, corner_profile_leg_mm, corner_profile_length_mm], center=true);
  }
}

// Box Corner Profile Sections
module box_corner_profile_sections() {
  union() {
    translate([outer_width_mm/2 - corner_profile_leg_mm/2 + eps_mm, outer_height_mm/2 - wall_thickness_mm/2 + eps_mm, length_mm/2 - corner_profile_length_mm/2 + eps_mm])
      box_corner_profile_section();
    translate([outer_width_mm/2 - corner_profile_leg_mm/2 + eps_mm, -outer_height_mm/2 + wall_thickness_mm/2 - eps_mm, length_mm/2 - corner_profile_length_mm/2 + eps_mm])
      box_corner_profile_section();
    translate([-outer_width_mm/2 + corner_profile_leg_mm/2 - eps_mm, outer_height_mm/2 - wall_thickness_mm/2 + eps_mm, length_mm/2 - corner_profile_length_mm/2 + eps_mm])
      box_corner_profile_section();
    translate([-outer_width_mm/2 + corner_profile_leg_mm/2 - eps_mm, -outer_height_mm/2 + wall_thickness_mm/2 - eps_mm, length_mm/2 - corner_profile_length_mm/2 + eps_mm])
      box_corner_profile_section();
  }
}

// Box Shelf Bracket Section
module box_shelf_bracket_section() {
  color("Silver") translate([outer_width_mm/2 + bracket_width_mm/2 - eps_mm, 0, 0]) {
    cube([bracket_width_mm, bracket_height_mm, bracket_thickness_mm], center=true);
  }
}

// Assembly
module assembly() {
  box_section();
  box_bezel_section();
  box_corner_profile_sections();
  box_shelf_bracket_section();
}

assembly();