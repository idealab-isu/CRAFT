// Parameters
overall_length = 38; //[19:76:0.5]
overall_width = 31; //[15.5:62:0.5]
overall_thickness = 8.5; //[4.25:17:0.25]
base_plate_length = 38; //[19:76:0.5]
base_plate_width = 31; //[15.5:62:0.5]
gusset_thickness = 4; //[2:8:0.5]
gusset_leg_x = 26; //[13:52:0.5]
gusset_leg_y = 22; //[11:44:0.5]
hole_diameter = 5.5; //[3:8:0.1]
hole_offset_from_corner = 15; //[8:30:0.5]
hole_spacing_along_leg = 12; //[6:24:0.5]
hole_edge_margin = 7; //[4:14:0.5]
overlap = 1; //[0.5:2:0.1]
extrusion_size = 20; //[10:40:1]
extrusion_length = 60; //[30:120:1]
assembly_gap = 0.5; //[0:2:0.1]

// Extrusion - complete geometry
module extrusion() {
  color([0.85, 0.85, 0.8]) {
    union() {
      translate([extrusion_length/2 + assembly_gap, extrusion_size/2, extrusion_size/2])
        cube([extrusion_length, extrusion_size, extrusion_size], center=true);
      translate([extrusion_size/2, extrusion_length/2 + assembly_gap, extrusion_size/2])
        cube([extrusion_size, extrusion_length, extrusion_size], center=true);
    }
  }
}

// Extrusion Corner Bracket Hole Positions - complete geometry
module extrusion_corner_bracket_hole_positions() {
  color("Silver") {
    union() {
      translate([hole_offset_from_corner, base_plate_width - hole_edge_margin, overall_thickness/2])
        cylinder(r=hole_diameter/2, h=overall_thickness + 2*overlap, center=true);
      translate([hole_offset_from_corner + hole_spacing_along_leg, base_plate_width - hole_edge_margin, overall_thickness/2])
        cylinder(r=hole_diameter/2, h=overall_thickness + 2*overlap, center=true);
      translate([base_plate_width - hole_edge_margin, hole_offset_from_corner, overall_thickness/2])
        cylinder(r=hole_diameter/2, h=overall_thickness + 2*overlap, center=true);
      translate([base_plate_width - hole_edge_margin, hole_offset_from_corner + hole_spacing_along_leg, overall_thickness/2])
        cylinder(r=hole_diameter/2, h=overall_thickness + 2*overlap, center=true);
    }
  }
}

// Extrusion Corner Bracket - complete geometry
module extrusion_corner_bracket() {
  color("Silver") {
    union() {
      translate([base_plate_length/2, base_plate_width/2, overall_thickness/2])
        cube([base_plate_length, base_plate_width, overall_thickness], center=true);
      translate([base_plate_width/2, base_plate_length/2, overall_thickness/2])
        cube([base_plate_width, base_plate_length, overall_thickness], center=true);
      translate([0, 0, gusset_thickness/2])
        linear_extrude(height=gusset_thickness)
          polygon(points=[[0, 0], [gusset_leg_x, 0], [0, gusset_leg_y]]);
      translate([0, 0, overall_thickness - gusset_thickness/2])
        linear_extrude(height=gusset_thickness)
          polygon(points=[[0, 0], [gusset_leg_x, 0], [0, gusset_leg_y]]);
    }
  }
}

// Extrusion Corner Bracket 3D - complete geometry
module extrusion_corner_bracket_3D() {
  difference() {
    extrusion_corner_bracket();
    extrusion_corner_bracket_hole_positions();
  }
}

// Extrusion Corner Bracket Assembly - complete geometry
module extrusion_corner_bracket_assembly() {
  union() {
    extrusion_corner_bracket_3D();
    extrusion();
  }
}

// Assembly
module assembly() {
  extrusion_corner_bracket_assembly();
}

assembly();