// Parameters
envelope_width = 40; //[20:80:1]
envelope_length = 40; //[20:80:1]
envelope_height = 20; //[10:40:1]
casing_wall_thickness = 1.5; //[0.8:3:0.1]
top_cover_thickness = 1.5; //[0.8:3:0.1]
base_thickness = 1.5; //[0.8:3:0.1]
inlet_diameter = 24; //[12:48:1]
outlet_width = 12; //[6:24:1]
outlet_height = 8; //[4:16:1]
outlet_offset_from_center = 0; //[-10:10:0.5]
impeller_outer_diameter = 30; //[15:60:1]
impeller_hub_diameter = 10; //[5:20:1]
impeller_blade_count = 25; //[10:60:1]
impeller_blade_thickness = 0.8; //[0.4:1.6:0.1]
impeller_axial_height = 14; //[7:28:1]
impeller_to_casing_radial_clearance = 0.5; //[0.2:1.5:0.1]
impeller_to_cover_axial_clearance = 0.5; //[0.2:1.5:0.1]
mount_hole_diameter = 3.2; //[2:6:0.1]
mount_hole_edge_offset = 4; //[2:10:0.5]
connection_overlap = 1; //[0.5:2:0.1]
impeller_blade_radial_length = 8; //[4:16:0.5]
impeller_blade_radial_overlap_into_hub = 1; //[0.5:3:0.1]
lug_diameter = 8; //[5:14:0.5]

// Blower module
module blower() {
  color("DimGray") {
    difference() {
      // Volute casing main body outer block
      translate([0, 0, 0])
        cube([envelope_width, envelope_length, envelope_height], center=true);
      // Volute casing main body inner cavity block
      translate([0, 0, (base_thickness - top_cover_thickness) / 2])
        cube([envelope_width - 2 * casing_wall_thickness, envelope_length - 2 * casing_wall_thickness, envelope_height - top_cover_thickness - base_thickness], center=true);
      // Inlet bore cylinder
      translate([0, 0, 0])
        cylinder(r=inlet_diameter / 2, h=envelope_height + 2 * connection_overlap, center=true);
      // Tangential outlet nozzle cut box
      translate([envelope_width / 2 - (outlet_width + 2 * connection_overlap) / 2 + connection_overlap, outlet_offset_from_center + envelope_length / 4, 0])
        cube([outlet_width + 2 * connection_overlap, envelope_length / 2 + 2 * connection_overlap, outlet_height], center=true);
    }
    // Mounting lugs
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * (envelope_width / 2 - mount_hole_edge_offset), y * (envelope_length / 2 - mount_hole_edge_offset), 0])
        cylinder(r=lug_diameter / 2, h=envelope_height, center=true);
    }
    // Screw holes
    color("Black") {
      for (x = [-1, 1], y = [-1, 1]) {
        translate([x * (envelope_width / 2 - mount_hole_edge_offset), y * (envelope_length / 2 - mount_hole_edge_offset), 0])
          cylinder(r=mount_hole_diameter / 2, h=envelope_height + 2 * connection_overlap, center=true);
      }
    }
  }
}

// Fan module
module fan() {
  color([0.15, 0.15, 0.17]) {
    // Frame
    difference() {
      cube([envelope_width, envelope_length, 10], center=true);
      cylinder(d=envelope_width - 4, h=12, center=true, $fn=32);
    }
    // Hub
    cylinder(d=impeller_hub_diameter, h=8, center=true, $fn=24);
    // Blades
    for (i = [0:6]) {
      rotate([0, 0, i * 360 / 7])
        hull() {
          translate([impeller_hub_diameter / 2 + 2, 0, 0])
            cylinder(r=2, h=impeller_axial_height, $fn=12);
          translate([impeller_outer_diameter / 2 - 3, 3, impeller_axial_height * 0.3])
            rotate([0, 10, 15])
            cylinder(r=2.5, h=impeller_axial_height * 0.7, $fn=12);
        }
    }
  }
}

// Blower Fan module
module blower_fan() {
  color([0.15, 0.15, 0.17]) {
    // Frame
    difference() {
      cube([envelope_width, envelope_length, 10], center=true);
      cylinder(d=envelope_width - 4, h=12, center=true, $fn=32);
    }
    // Hub
    cylinder(d=impeller_hub_diameter, h=8, center=true, $fn=24);
    // Blades
    for (i = [0:6]) {
      rotate([0, 0, i * 360 / 7])
        hull() {
          translate([impeller_hub_diameter / 2 + 2, 0, 0])
            cylinder(r=2, h=impeller_axial_height, $fn=12);
          translate([impeller_outer_diameter / 2 - 3, 3, impeller_axial_height * 0.3])
            rotate([0, 10, 15])
            cylinder(r=2.5, h=impeller_axial_height * 0.7, $fn=12);
        }
    }
  }
}

// Assembly module
module assembly() {
  blower();
  translate([0, 0, envelope_height / 2 + 1.5]) fan();
  translate([0, 0, envelope_height / 2 + 15]) blower_fan();
}

assembly();