// Parameters
overall_width_mm = 40; //[20:80:1]
overall_length_mm = 40; //[20:80:1]
overall_depth_mm = 20; //[10:40:1]
wall_thickness_mm = 1.5; //[0.8:3:0.1]
inlet_diameter_mm = 20; //[10:35:0.5]
hub_diameter_mm = 8; //[4:16:0.5]
hub_height_mm = 10; //[5:20:0.5]
impeller_outer_diameter_mm = 30; //[18:38:0.5]
blade_count = 25; //[10:40:1]
blade_thickness_mm = 0.75; //[0.4:1.5:0.05]
outlet_width_mm = 12; //[6:24:0.5]
outlet_height_mm = 10; //[5:18:0.5]
outlet_offset_mm = 0; //[-5:5:0.5]
mount_hole_diameter_mm = 3.2; //[2:5:0.1]
mount_hole_pattern_mm = 32; //[20:60:1]
corner_radius_mm = 3; //[1:8:0.5]
clearance_mm = 0.5; //[0.2:1.5:0.1]
eps_mm = 1; //[0.5:2:0.1]
base_plate_thickness_mm = 2; //[1:4:0.5]
top_cover_thickness_mm = 2; //[1:4:0.5]
cavity_height_mm = 16; //[10:30:1]
volute_outer_radius_mm = 18; //[12:25:0.5]
outlet_length_mm = 14; //[8:30:1]

// Blower - complete geometry
module blower() {
  color([0.15, 0.15, 0.17]) {
    // Base Plate
    translate([0, 0, -overall_depth_mm/2 + base_plate_thickness_mm/2])
      cube([overall_width_mm, overall_length_mm, base_plate_thickness_mm], center=true);

    // Top Cover
    translate([0, 0, overall_depth_mm/2 - top_cover_thickness_mm/2])
      cube([overall_width_mm, overall_length_mm, top_cover_thickness_mm], center=true);

    // Volute Casing
    difference() {
      translate([0, 0, -overall_depth_mm/2 + base_plate_thickness_mm + cavity_height_mm/2])
        cylinder(r=volute_outer_radius_mm, h=cavity_height_mm, center=true);
      translate([0, 0, -overall_depth_mm/2 + base_plate_thickness_mm + cavity_height_mm/2])
        cylinder(r=volute_outer_radius_mm - wall_thickness_mm, h=cavity_height_mm + 2*eps_mm, center=true);
    }

    // Tangential Outlet
    difference() {
      translate([volute_outer_radius_mm + outlet_length_mm/2 - eps_mm, 0, -overall_depth_mm/2 + base_plate_thickness_mm + cavity_height_mm/2 + outlet_offset_mm])
        cube([outlet_length_mm, outlet_width_mm, outlet_height_mm], center=true);
      translate([volute_outer_radius_mm + outlet_length_mm/2 - eps_mm, 0, -overall_depth_mm/2 + base_plate_thickness_mm + cavity_height_mm/2 + outlet_offset_mm])
        cube([outlet_length_mm + 2*eps_mm, outlet_width_mm - 2*wall_thickness_mm, outlet_height_mm - 2*wall_thickness_mm], center=true);
    }

    // Screw Lugs
    for (i = [-1, 1], j = [-1, 1]) {
      translate([i * mount_hole_pattern_mm/2, j * mount_hole_pattern_mm/2, 0])
        difference() {
          cylinder(r=mount_hole_diameter_mm/2 + wall_thickness_mm + corner_radius_mm/4, h=overall_depth_mm, center=true);
          cylinder(r=mount_hole_diameter_mm/2, h=overall_depth_mm + 2*eps_mm, center=true);
        }
    }

    // Inlet Bore
    translate([0, 0, -overall_depth_mm/2 + base_plate_thickness_mm + cavity_height_mm/2 + top_cover_thickness_mm/2])
      cylinder(r=inlet_diameter_mm/2, h=top_cover_thickness_mm + cavity_height_mm + 2*eps_mm, center=true);
  }
}

// Fan - complete geometry
module fan() {
  color([0.12, 0.12, 0.14]) {
    // Frame
    difference() {
      cube([overall_width_mm, overall_length_mm, 10], center=true);
      cylinder(d=overall_width_mm - 4, h=12, center=true, $fn=32);
    }
    // Hub
    cylinder(d=hub_diameter_mm, h=hub_height_mm, center=true, $fn=24);
    // Blades
    for (i = [0:6]) {
      rotate([0, 0, i * 360 / 7])
        hull() {
          translate([hub_diameter_mm/2 + 2, 0, 0]) cylinder(r=2, h=hub_height_mm, $fn=12);
          translate([impeller_outer_diameter_mm/2 - 3, 3, hub_height_mm * 0.3]) rotate([0, 10, 15])
            cylinder(r=2.5, h=hub_height_mm * 0.7, $fn=12);
        }
    }
  }
}

// Blower Fan - complete geometry
module blower_fan() {
  color([0.2, 0.2, 0.22]) {
    // Frame
    difference() {
      cube([overall_width_mm, overall_length_mm, 10], center=true);
      cylinder(d=overall_width_mm - 4, h=12, center=true, $fn=32);
    }
    // Hub
    cylinder(d=hub_diameter_mm, h=hub_height_mm, center=true, $fn=24);
    // Blades
    for (i = [0:6]) {
      rotate([0, 0, i * 360 / 7])
        hull() {
          translate([hub_diameter_mm/2 + 2, 0, 0]) cylinder(r=2, h=hub_height_mm, $fn=12);
          translate([impeller_outer_diameter_mm/2 - 3, 3, hub_height_mm * 0.3]) rotate([0, 10, 15])
            cylinder(r=2.5, h=hub_height_mm * 0.7, $fn=12);
        }
    }
  }
}

// Assembly
module assembly() {
  blower();
  translate([0, 0, overall_depth_mm/2 + 5]) fan();
  translate([0, 0, overall_depth_mm/2 + 15]) blower_fan();
}

assembly();