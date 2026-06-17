// Parameters
leg_length_x = 40; //[20:80:1]
leg_length_y = 40; //[20:80:1]
height_z = 35; //[18:70:1]
base_thickness = 5; //[3:10:1]
side_thickness = 5; //[3:10:1]
overlap = 1; //[0.5:2:0.5]
hole_count_per_face = 1; //[1:2:1]
hole_offset_from_inner_corner = 15; //[8:30:1]
hole_diameter = 9; //[6:12:0.5]
extrusion_size = 40; //[20:80:1]
extrusion_length_x = 60; //[40:120:1]
extrusion_length_y = 60; //[40:120:1]

// Extrusion - complete geometry
module extrusion() {
  color([0.75, 0.75, 0.77]) {
    // X-axis extrusion
    translate([extrusion_length_x/2 - overlap, extrusion_size/2, extrusion_size/2])
      cube([extrusion_length_x, extrusion_size, extrusion_size], center=true);
    // Y-axis extrusion
    translate([extrusion_size/2, extrusion_length_y/2 - overlap, extrusion_size/2])
      cube([extrusion_size, extrusion_length_y, extrusion_size], center=true);
  }
}

// Extrusion Inner Corner Bracket - complete geometry
module extrusion_inner_corner_bracket() {
  color("Silver") {
    union() {
      // Base plates
      translate([leg_length_x/2, base_thickness/2, height_z/2])
        cube([leg_length_x, base_thickness, height_z], center=true);
      translate([base_thickness/2, leg_length_y/2, height_z/2])
        cube([base_thickness, leg_length_y, height_z], center=true);
      // Side gussets
      translate([leg_length_x/2, leg_length_y/2, side_thickness/2])
        linear_extrude(height=side_thickness, center=true)
        polygon(points=[[0, 0], [leg_length_x, 0], [0, leg_length_y]]);
      translate([leg_length_x/2, leg_length_y/2, height_z - side_thickness/2])
        linear_extrude(height=side_thickness, center=true)
        polygon(points=[[0, 0], [leg_length_x, 0], [0, leg_length_y]]);
    }
  }
}

// Extrusion Corner Bracket - complete geometry
module extrusion_corner_bracket() {
  color("Silver") {
    union() {
      // Base plates
      translate([leg_length_x/2, base_thickness/2, height_z/2])
        cube([leg_length_x, base_thickness, height_z], center=true);
      translate([base_thickness/2, leg_length_y/2, height_z/2])
        cube([base_thickness, leg_length_y, height_z], center=true);
      // Side gussets
      translate([leg_length_x/2, leg_length_y/2, side_thickness/2])
        linear_extrude(height=side_thickness, center=true)
        polygon(points=[[0, 0], [leg_length_x, 0], [0, leg_length_y]]);
      translate([leg_length_x/2, leg_length_y/2, height_z - side_thickness/2])
        linear_extrude(height=side_thickness, center=true)
        polygon(points=[[0, 0], [leg_length_x, 0], [0, leg_length_y]]);
    }
  }
}

// Extrusion Corner Bracket 3D - complete geometry
module extrusion_corner_bracket_3D() {
  color("Silver") {
    union() {
      // Base plates
      translate([leg_length_x/2, base_thickness/2, height_z/2])
        cube([leg_length_x, base_thickness, height_z], center=true);
      translate([base_thickness/2, leg_length_y/2, height_z/2])
        cube([base_thickness, leg_length_y, height_z], center=true);
      // Side gussets
      translate([leg_length_x/2, leg_length_y/2, side_thickness/2])
        linear_extrude(height=side_thickness, center=true)
        polygon(points=[[0, 0], [leg_length_x, 0], [0, leg_length_y]]);
      translate([leg_length_x/2, leg_length_y/2, height_z - side_thickness/2])
        linear_extrude(height=side_thickness, center=true)
        polygon(points=[[0, 0], [leg_length_x, 0], [0, leg_length_y]]);
    }
  }
}

// Extrusion Corner Bracket Hole Positions - complete geometry
module extrusion_corner_bracket_hole_positions() {
  color("Silver") {
    union() {
      // Holes for X face
      translate([hole_offset_from_inner_corner, base_thickness/2, height_z/2])
        rotate([90, 0, 0])
        cylinder(r=hole_diameter/2, h=base_thickness + 2*overlap, center=true);
      // Holes for Y face
      translate([base_thickness/2, hole_offset_from_inner_corner, height_z/2])
        rotate([0, 90, 0])
        cylinder(r=hole_diameter/2, h=base_thickness + 2*overlap, center=true);
    }
  }
}

// Assembly
module assembly() {
  extrusion();
  translate([0, 0, 0]) extrusion_inner_corner_bracket();
  translate([0, 0, 0]) extrusion_corner_bracket();
  translate([0, 0, 0]) extrusion_corner_bracket_3D();
  translate([0, 0, 0]) extrusion_corner_bracket_hole_positions();
}

assembly();