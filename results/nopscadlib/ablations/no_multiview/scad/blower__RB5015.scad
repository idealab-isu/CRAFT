// Parameters
overall_length_mm = 51.3; //[25.65:102.6:0.1]
overall_width_mm = 51; //[25.5:102:0.1]
overall_depth_mm = 15; //[7.5:30:0.1]
wall_thickness_mm = 1.5; //[0.75:3:0.1]
top_thickness_mm = 1.5; //[0.75:3:0.1]
base_thickness_mm = 1.5; //[0.75:3:0.1]
inlet_bore_diameter_mm = 24; //[12:48:0.1]
impeller_outer_diameter_mm = 46; //[23:92:0.1]
hub_diameter_mm = 16; //[8:32:0.1]
hub_height_mm = 10; //[5:20:0.1]
outlet_width_mm = 18; //[9:36:0.1]
outlet_height_mm = 10; //[5:20:0.1]
outlet_offset_mm = 0; //[-10:10:0.1]
mount_hole_diameter_mm = 3.2; //[1.6:6.4:0.1]
mount_hole_edge_margin_mm = 4; //[2:8:0.1]
clearance_mm = 0.4; //[0.2:1:0.05]
overlap_mm = 1; //[0.5:2:0.1]
cavity_height_mm = 12; //[6:24:0.1]
lug_diameter_mm = 8; //[4:16:0.1]

// Blower module
module blower() {
  color([0.15, 0.15, 0.17]) {
    // Base plate
    translate([0, 0, -overall_depth_mm/2 + base_thickness_mm/2])
      cube([overall_length_mm, overall_width_mm, base_thickness_mm], center=true);

    // Top cover plate
    translate([0, 0, overall_depth_mm/2 - top_thickness_mm/2])
      cube([overall_length_mm, overall_width_mm, top_thickness_mm], center=true);

    // Volute casing
    difference() {
      translate([0, 0, -overall_depth_mm/2 + base_thickness_mm + cavity_height_mm/2])
        cube([overall_length_mm, overall_width_mm, cavity_height_mm], center=true);

      // Impeller cavity
      translate([-overall_length_mm/2 + wall_thickness_mm + (impeller_outer_diameter_mm/2) + clearance_mm, 0, -overall_depth_mm/2 + base_thickness_mm + cavity_height_mm/2])
        cylinder(r=(impeller_outer_diameter_mm/2) + clearance_mm, h=cavity_height_mm + 2*overlap_mm, center=true);

      // Tangential outlet duct
      translate([overall_length_mm/2 - outlet_width_mm/2, outlet_offset_mm, -overall_depth_mm/2 + base_thickness_mm + cavity_height_mm/2])
        cube([outlet_width_mm + 2*overlap_mm, outlet_height_mm, cavity_height_mm + 2*overlap_mm], center=true);

      // Inlet bore
      translate([-overall_length_mm/2 + wall_thickness_mm + (impeller_outer_diameter_mm/2) + clearance_mm, 0, overall_depth_mm/2 - top_thickness_mm/2])
        cylinder(r=inlet_bore_diameter_mm/2, h=top_thickness_mm + 2*overlap_mm, center=true);

      // Screw holes
      translate([-overall_length_mm/2 + mount_hole_edge_margin_mm, -overall_width_mm/2 + mount_hole_edge_margin_mm, 0])
        cylinder(r=mount_hole_diameter_mm/2, h=overall_depth_mm + 2*overlap_mm, center=true);
      translate([overall_length_mm/2 - mount_hole_edge_margin_mm, -overall_width_mm/2 + mount_hole_edge_margin_mm, 0])
        cylinder(r=mount_hole_diameter_mm/2, h=overall_depth_mm + 2*overlap_mm, center=true);
    }

    // Mounting lugs
    translate([-overall_length_mm/2 + mount_hole_edge_margin_mm, -overall_width_mm/2 + mount_hole_edge_margin_mm, 0])
      cylinder(r=lug_diameter_mm/2, h=overall_depth_mm, center=true);
    translate([overall_length_mm/2 - mount_hole_edge_margin_mm, -overall_width_mm/2 + mount_hole_edge_margin_mm, 0])
      cylinder(r=lug_diameter_mm/2, h=overall_depth_mm, center=true);
  }
}

// Fan module
module fan() {
  color([0.12, 0.12, 0.14]) {
    // Frame
    difference() {
      cube([impeller_outer_diameter_mm, impeller_outer_diameter_mm, 10], center=true);
      cylinder(d=impeller_outer_diameter_mm - 4, h=12, center=true, $fn=32);
    }
    // Hub
    cylinder(d=hub_diameter_mm, h=hub_height_mm, center=true, $fn=24);

    // Blades
    for (i = [0:6]) {
      rotate([0, 0, i * 360 / 7]) {
        hull() {
          translate([hub_diameter_mm/2 + 2, 0, 0]) cylinder(r=2, h=hub_height_mm, $fn=12);
          translate([impeller_outer_diameter_mm/2 - 3, 3, hub_height_mm * 0.3]) rotate([0, 10, 15])
            cylinder(r=2.5, h=hub_height_mm * 0.7, $fn=12);
        }
      }
    }
  }
}

// Blower Fan module
module blower_fan() {
  color([0.2, 0.2, 0.22]) {
    // Frame
    difference() {
      cube([impeller_outer_diameter_mm, impeller_outer_diameter_mm, 10], center=true);
      cylinder(d=impeller_outer_diameter_mm - 4, h=12, center=true, $fn=32);
    }
    // Hub
    cylinder(d=hub_diameter_mm, h=hub_height_mm, center=true, $fn=24);

    // Blades
    for (i = [0:6]) {
      rotate([0, 0, i * 360 / 7]) {
        hull() {
          translate([hub_diameter_mm/2 + 2, 0, 0]) cylinder(r=2, h=hub_height_mm, $fn=12);
          translate([impeller_outer_diameter_mm/2 - 3, 3, hub_height_mm * 0.3]) rotate([0, 10, 15])
            cylinder(r=2.5, h=hub_height_mm * 0.7, $fn=12);
        }
      }
    }
  }
}

// Assembly module
module assembly() {
  blower();
  translate([0, 0, overall_depth_mm/2 + 5]) fan();
  translate([0, 0, overall_depth_mm/2 + 20]) blower_fan();
}

assembly();