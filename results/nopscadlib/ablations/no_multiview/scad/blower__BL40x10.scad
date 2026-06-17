// Parameters
footprint_x = 40.0; //[20.0:80.0:0.5]
footprint_y = 40.0; //[20.0:80.0:0.5]
overall_depth_z = 9.5; //[5.0:19.0:0.1]
wall_thickness = 1.6; //[0.8:3.2:0.1]
base_thickness = 1.2; //[0.6:2.4:0.1]
top_thickness = 1.2; //[0.6:2.4:0.1]
clearance = 0.6; //[0.2:1.5:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
mount_hole_diameter = 3.2; //[2.0:6.0:0.1]
mount_hole_edge_margin = 4.0; //[2.0:8.0:0.5]
outlet_width = 12.0; //[6.0:24.0:0.5]
outlet_height = 6.0; //[3.0:9.5:0.5]
outlet_length = 12.0; //[6.0:30.0:0.5]
outlet_offset_y = 0.0; //[-10.0:10.0:0.5]
outlet_center_z = 0.0; //[-2.0:2.0:0.1]
impeller_outer_diameter = 28.0; //[18.0:36.0:0.5]
impeller_hub_diameter = 10.0; //[6.0:18.0:0.5]
impeller_blade_count = 20; //[8:40:1]
blade_thickness = 0.8; //[0.4:1.6:0.1]
blade_radial_length = 6.0; //[3.0:12.0:0.5]
bore_diameter = 3.0; //[1.5:6.0:0.1]

// Blower module
module blower() {
  color([0.12, 0.12, 0.14]) {
    difference() {
      // Outer casing
      translate([0, 0, 0])
        cube([footprint_x, footprint_y, overall_depth_z], center=true);
      // Inner cavity
      translate([0, 0, 0])
        cube([footprint_x - 2*wall_thickness, footprint_y - 2*wall_thickness, overall_depth_z - base_thickness - top_thickness], center=true);
    }
    // Outlet duct
    difference() {
      translate([footprint_x/2 + outlet_length/2 - overlap, outlet_offset_y, outlet_center_z])
        cube([outlet_length, outlet_width, outlet_height], center=true);
      translate([footprint_x/2 + outlet_length/2 - overlap, outlet_offset_y, outlet_center_z])
        cube([outlet_length + 2*overlap, outlet_width - 2*wall_thickness, outlet_height - 2*wall_thickness], center=true);
    }
    // Mounting holes
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * (footprint_x/2 - mount_hole_edge_margin), y * (footprint_y/2 - mount_hole_edge_margin), 0])
        cylinder(r=mount_hole_diameter/2, h=overall_depth_z + 2*overlap, center=true);
    }
  }
}

// Fan module
module fan() {
  color([0.15, 0.15, 0.17]) {
    // Frame
    difference() {
      cube([footprint_x, footprint_y, 10], center=true);
      cylinder(d=footprint_x - 4, h=12, center=true, $fn=32);
    }
    // Hub
    cylinder(d=impeller_hub_diameter, h=8, center=true, $fn=24);
    // Blades
    for (i = [0:6]) {
      rotate([0, 0, i * 360 / 7])
        hull() {
          translate([impeller_hub_diameter/2 + 2, 0, 0])
            cylinder(r=2, h=8, $fn=12);
          translate([impeller_outer_diameter/2 - 3, 3, 2.4])
            rotate([0, 10, 15])
            cylinder(r=2.5, h=5.6, $fn=12);
        }
    }
  }
}

// Blower Fan module
module blower_fan() {
  color([0.15, 0.15, 0.17]) {
    // Frame
    difference() {
      cube([footprint_x, footprint_y, 10], center=true);
      cylinder(d=footprint_x - 4, h=12, center=true, $fn=32);
    }
    // Hub
    cylinder(d=impeller_hub_diameter, h=8, center=true, $fn=24);
    // Blades
    for (i = [0:6]) {
      rotate([0, 0, i * 360 / 7])
        hull() {
          translate([impeller_hub_diameter/2 + 2, 0, 0])
            cylinder(r=2, h=8, $fn=12);
          translate([impeller_outer_diameter/2 - 3, 3, 2.4])
            rotate([0, 10, 15])
            cylinder(r=2.5, h=5.6, $fn=12);
        }
    }
  }
}

// Assembly module
module assembly() {
  blower();
  translate([0, 0, overall_depth_z/2 + 5]) fan();
  translate([0, 0, overall_depth_z/2 + 15]) blower_fan();
}

assembly();