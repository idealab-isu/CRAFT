// Parameters
overall_x = 40; //[20:80:1]
overall_y = 40; //[20:80:1]
overall_z = 35; //[18:70:1]
base_plate_thickness = 4; //[2:8:1]
side_wall_thickness = 4; //[2:8:1]
gusset_thickness = 4; //[2:10:1]
hole_count = 2; //[2:4:1]
hole_diameter = 5.5; //[3:8:0.1]
hole_offset_from_inner_corner = 20; //[10:35:1]
extrusion_interface = 35; //[18:60:1]
extrusion_length = 80; //[40:200:1]
overlap = 1; //[0.5:2:0.1]

// Extrusion - complete geometry
module extrusion() {
  color([0.85, 0.85, 0.8]) {
    cube([extrusion_length, extrusion_interface, extrusion_interface], center=true);
  }
}

// Extrusion Corner Bracket Hole Positions - complete geometry
module extrusion_corner_bracket_hole_positions() {
  color("Silver") {
    translate([hole_offset_from_inner_corner, base_plate_thickness/2, 0])
      rotate([90, 0, 0])
      cylinder(r=hole_diameter/2, h=base_plate_thickness + 2*overlap, center=true);
    translate([base_plate_thickness/2, hole_offset_from_inner_corner, 0])
      rotate([0, 90, 0])
      cylinder(r=hole_diameter/2, h=base_plate_thickness + 2*overlap, center=true);
  }
}

// Extrusion Corner Bracket - complete geometry
module extrusion_corner_bracket() {
  color("DimGray") {
    union() {
      translate([overall_x/2, base_plate_thickness/2, 0])
        cube([overall_x, base_plate_thickness, overall_z], center=true);
      translate([base_plate_thickness/2, overall_y/2, 0])
        cube([base_plate_thickness, overall_y, overall_z], center=true);
      translate([0, 0, overall_z/2 - gusset_thickness/2])
        linear_extrude(height=gusset_thickness, center=true)
        polygon(points=[[0, 0], [overall_x, 0], [0, overall_y]]);
      translate([0, 0, -overall_z/2 + gusset_thickness/2])
        linear_extrude(height=gusset_thickness, center=true)
        polygon(points=[[0, 0], [overall_x, 0], [0, overall_y]]);
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
    translate([overall_x/2 + extrusion_length/2 - overlap, extrusion_interface/2, 0])
      extrusion();
    translate([extrusion_interface/2, overall_y/2 + extrusion_length/2 - overlap, 0])
      extrusion();
  }
}

// Assembly
module assembly() {
  extrusion_corner_bracket_assembly();
}

assembly();