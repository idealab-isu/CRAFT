// Parameters
length = 26; //[13:52:1]
width = 25; //[12.5:50:1]
thickness = 4.7; //[2.35:9.4:0.1]
hole_count = 2; //[2:2:1]
hole_diameter = 5; //[2.5:10:0.1]
hole_center_offset_from_inner_corner = 10; //[5:20:0.5]
corner_radius = 0; //[0:5:0.5]
rib_thickness = 2; //[1:4:0.5]
rib_height = 10; //[5:20:1]
overlap = 1; //[0.5:2:0.1]
extrusion_size = 20; //[10:40:1]
extrusion_length = 60; //[30:120:1]
inner_corner_bracket_size = 12; //[6:24:1]

// Extrusion - complete geometry
module extrusion() {
  color("Silver") {
    cube([extrusion_length, extrusion_size, extrusion_size], center=true);
  }
}

// Extrusion Inner Corner Bracket - complete geometry
module extrusion_inner_corner_bracket() {
  color("DimGray") {
    difference() {
      cube([inner_corner_bracket_size, inner_corner_bracket_size, inner_corner_bracket_size], center=true);
      translate([0, 0, -inner_corner_bracket_size/2])
        cylinder(d=hole_diameter, h=inner_corner_bracket_size, center=true, $fn=32);
    }
  }
}

// Extrusion Corner Bracket - complete geometry
module extrusion_corner_bracket() {
  color("Silver") {
    difference() {
      cube([length, width, thickness], center=true);
      translate([-length/2 + hole_center_offset_from_inner_corner, -width/2 + hole_center_offset_from_inner_corner, 0])
        cylinder(d=hole_diameter, h=thickness + 2*overlap, center=true, $fn=32);
      translate([length/2 - hole_center_offset_from_inner_corner, width/2 - hole_center_offset_from_inner_corner, 0])
        cylinder(d=hole_diameter, h=thickness + 2*overlap, center=true, $fn=32);
    }
  }
}

// Extrusion Corner Bracket 3D - complete geometry
module extrusion_corner_bracket_3D() {
  color("Silver") {
    union() {
      extrusion_corner_bracket();
      translate([0, -width/2 + rib_thickness/2 - overlap, thickness/2 + rib_height/2 - overlap])
        cube([length, rib_thickness, rib_height], center=true);
      translate([-length/2 + rib_thickness/2 - overlap, 0, thickness/2 + rib_height/2 - overlap])
        cube([rib_thickness, width, rib_height], center=true);
    }
  }
}

// Extrusion Corner Bracket Hole Positions - complete geometry
module extrusion_corner_bracket_hole_positions() {
  color("Black") {
    translate([-length/2 + hole_center_offset_from_inner_corner, -width/2 + hole_center_offset_from_inner_corner, thickness/2 + hole_diameter/4 - overlap])
      sphere(r=hole_diameter/4, center=true);
    translate([length/2 - hole_center_offset_from_inner_corner, width/2 - hole_center_offset_from_inner_corner, thickness/2 + hole_diameter/4 - overlap])
      sphere(r=hole_diameter/4, center=true);
  }
}

// Assembly
module assembly() {
  extrusion();
  translate([0, -width/2 - extrusion_size/2 + overlap, -thickness/2 - extrusion_size/2 + overlap]) extrusion();
  translate([-length/2 - extrusion_size/2 + overlap, 0, -thickness/2 - extrusion_size/2 + overlap]) extrusion();
  translate([-length/2 + inner_corner_bracket_size/2 - overlap, -width/2 + inner_corner_bracket_size/2 - overlap, -thickness/2 - inner_corner_bracket_size/2 + overlap]) extrusion_inner_corner_bracket();
  extrusion_corner_bracket_3D();
  extrusion_corner_bracket_hole_positions();
}

assembly();