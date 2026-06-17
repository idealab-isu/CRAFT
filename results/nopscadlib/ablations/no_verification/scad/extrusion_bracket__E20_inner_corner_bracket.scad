// Parameters
width_x_mm = 26; //[13:52:0.5]
depth_y_mm = 25; //[12.5:50:0.5]
thickness_z_mm = 4.7; //[2.35:9.4:0.1]
hole_count = 2; //[1:4:1]
hole_diameter_mm = 5; //[3:10:0.1]
corner_radius_mm = 1; //[0.5:3:0.1]
chamfer_mm = 0.5; //[0:1.5:0.1]
hole_edge_margin_x_mm = 6; //[3:12:0.5]
hole_edge_margin_y_mm = 6; //[3:12:0.5]
hole_spacing_x_mm = 14; //[8:28:0.5]
hole_position_y_mm = 0; //[-6:6:0.5]
hole_clearance_extra_mm = 0.2; //[0:0.6:0.05]
hole_cut_extra_z_mm = 1; //[0.5:3:0.1]
extrusion_size_mm = 20; //[10:40:1]
extrusion_length_mm = 40; //[20:120:1]
extrusion_gap_to_bracket_mm = 0.5; //[0.2:2:0.1]

// Extrusion - complete geometry
module extrusion() {
  color([0.75, 0.75, 0.77]) {
    cube([extrusion_size_mm, extrusion_size_mm, extrusion_length_mm], center=true);
  }
}

// Extrusion Corner Bracket Hole Positions - complete geometry
module extrusion_corner_bracket_hole_positions() {
  color("Silver") {
    translate([-hole_spacing_x_mm/2, hole_position_y_mm, 0])
      cylinder(r=(hole_diameter_mm + hole_clearance_extra_mm)/2, h=thickness_z_mm + 2*hole_cut_extra_z_mm, center=true);
    translate([hole_spacing_x_mm/2, hole_position_y_mm, 0])
      cylinder(r=(hole_diameter_mm + hole_clearance_extra_mm)/2, h=thickness_z_mm + 2*hole_cut_extra_z_mm, center=true);
  }
}

// Extrusion Inner Corner Bracket - complete geometry
module extrusion_inner_corner_bracket() {
  color("DimGray") {
    cube([extrusion_size_mm, extrusion_size_mm, thickness_z_mm], center=true);
  }
}

// Extrusion Corner Bracket Assembly - complete geometry
module extrusion_corner_bracket_assembly() {
  color("Silver") {
    difference() {
      union() {
        // Bracket body with rounded corners
        minkowski() {
          union() {
            cube([width_x_mm - 2*corner_radius_mm, depth_y_mm - 2*corner_radius_mm, thickness_z_mm], center=true);
            translate([width_x_mm/2 - corner_radius_mm, depth_y_mm/2 - corner_radius_mm, 0])
              cylinder(r=corner_radius_mm, h=thickness_z_mm, center=true);
            mirror([1, 0, 0])
              translate([width_x_mm/2 - corner_radius_mm, depth_y_mm/2 - corner_radius_mm, 0])
              cylinder(r=corner_radius_mm, h=thickness_z_mm, center=true);
            mirror([0, 1, 0])
              translate([width_x_mm/2 - corner_radius_mm, depth_y_mm/2 - corner_radius_mm, 0])
              cylinder(r=corner_radius_mm, h=thickness_z_mm, center=true);
            mirror([1, 1, 0])
              translate([width_x_mm/2 - corner_radius_mm, depth_y_mm/2 - corner_radius_mm, 0])
              cylinder(r=corner_radius_mm, h=thickness_z_mm, center=true);
          }
          sphere(r=chamfer_mm, center=true);
        }
      }
      // Mounting holes
      extrusion_corner_bracket_hole_positions();
    }
  }
}

// Extrusion Corner Bracket - complete geometry
module extrusion_corner_bracket() {
  extrusion_corner_bracket_assembly();
}

// Assembly
module assembly() {
  extrusion();
  translate([0, 0, -(thickness_z_mm/2 + extrusion_length_mm/2 - extrusion_gap_to_bracket_mm)])
    extrusion_inner_corner_bracket();
  translate([0, 0, 0])
    extrusion_corner_bracket();
}

assembly();