// Parameters
bracket_size_x = 28; //[14:56:1]
bracket_size_y = 28; //[14:56:1]
extrusion_interface_size = 20; //[10:40:1]
bracket_depth_z = 20; //[10:40:1]
base_thickness = 4; //[2:8:1]
gusset_thickness = 4; //[2:8:1]
hole_diameter = 5.5; //[3:8:0.1]
hole_offset_from_corner = 10; //[6:18:0.5]
hole_slot_span = 3; //[1:6:0.5]
hole_depth_extra = 2; //[1:6:0.5]
overlap = 1; //[0.5:2:0.1]
extrusion_length = 60; //[30:120:1]
extrusion_wall = 2; //[1:4:0.5]

// Extrusion - complete geometry
module extrusion() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer extrusion
      cube([extrusion_length, extrusion_interface_size, extrusion_interface_size], center=true);
      // Inner cutout
      translate([0, 0, 0])
        cube([extrusion_length + 2*overlap, extrusion_interface_size - 2*extrusion_wall, extrusion_interface_size - 2*extrusion_wall], center=true);
    }
  }
}

// Extrusion Corner Bracket Hole Positions - complete geometry
module extrusion_corner_bracket_hole_positions() {
  color("Silver") {
    union() {
      // X-axis hole slot
      hull() {
        translate([hole_offset_from_corner + hole_slot_span/2, bracket_depth_z/2, base_thickness/2])
          rotate([90, 0, 0])
          cylinder(r=hole_diameter/2, h=base_thickness + gusset_thickness + hole_depth_extra, center=true);
        translate([hole_offset_from_corner - hole_slot_span/2, bracket_depth_z/2, base_thickness/2])
          rotate([90, 0, 0])
          cylinder(r=hole_diameter/2, h=base_thickness + gusset_thickness + hole_depth_extra, center=true);
      }
      // Y-axis hole slot
      hull() {
        translate([bracket_depth_z/2, hole_offset_from_corner + hole_slot_span/2, base_thickness/2])
          rotate([0, 90, 0])
          cylinder(r=hole_diameter/2, h=base_thickness + gusset_thickness + hole_depth_extra, center=true);
        translate([bracket_depth_z/2, hole_offset_from_corner - hole_slot_span/2, base_thickness/2])
          rotate([0, 90, 0])
          cylinder(r=hole_diameter/2, h=base_thickness + gusset_thickness + hole_depth_extra, center=true);
      }
    }
  }
}

// Extrusion Corner Bracket - complete geometry
module extrusion_corner_bracket() {
  color("Silver") {
    union() {
      // Base plates
      union() {
        translate([bracket_size_x/2, bracket_depth_z/2, base_thickness/2])
          cube([bracket_size_x, bracket_depth_z, base_thickness], center=true);
        translate([bracket_depth_z/2, bracket_size_y/2, base_thickness/2])
          cube([bracket_depth_z, bracket_size_y, base_thickness], center=true);
      }
      // Gussets
      union() {
        translate([bracket_size_x/2, bracket_size_y/2, base_thickness + gusset_thickness/2 - overlap])
          linear_extrude(height=gusset_thickness, center=true)
          polygon(points=[[0, 0], [bracket_size_x, 0], [0, bracket_size_y]]);
        translate([bracket_size_x/2, bracket_depth_z/2, base_thickness/2])
          rotate([90, 0, 0])
          linear_extrude(height=gusset_thickness, center=true)
          polygon(points=[[0, 0], [bracket_size_x, 0], [0, bracket_depth_z]]);
        translate([bracket_depth_z/2, bracket_size_y/2, base_thickness/2])
          rotate([0, 90, 0])
          linear_extrude(height=gusset_thickness, center=true)
          polygon(points=[[0, 0], [bracket_size_y, 0], [0, bracket_depth_z]]);
      }
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
    extrusion();
    translate([0, 0, extrusion_interface_size/2 + base_thickness/2])
      extrusion_corner_bracket_3D();
  }
}

// Assembly
module assembly() {
  extrusion_corner_bracket_assembly();
}

assembly();