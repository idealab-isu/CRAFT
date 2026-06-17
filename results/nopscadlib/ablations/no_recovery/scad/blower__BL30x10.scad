// Parameters
overall_length = 30.0; //[15.0:60.0:0.1]
overall_width = 30.0; //[15.0:60.0:0.1]
overall_depth = 10.1; //[5.0:20.2:0.1]
wall_thickness = 1.0; //[0.6:2.0:0.1]
top_thickness = 1.0; //[0.6:2.0:0.1]
base_thickness = 1.0; //[0.6:2.0:0.1]
clearance_overlap = 0.8; //[0.5:2.0:0.1]
impeller_hub_diameter = 8.0; //[4.0:16.0:0.1]
impeller_hub_height = 6.0; //[3.0:12.0:0.1]
impeller_blade_count = 25; //[10:40:1]
impeller_blade_thickness = 0.75; //[0.4:1.5:0.05]
impeller_twist_deg = -30.0; //[-60.0:60.0:1.0]
mount_hole_count = 2; //[2:4:1]
mount_hole_diameter = 3.0; //[2.0:5.0:0.1]
outlet_height = 6.0; //[3.0:9.0:0.1]
outlet_width = 8.0; //[4.0:14.0:0.1]
outlet_length = 8.0; //[4.0:16.0:0.1]
inlet_bore_diameter = 10.0; //[6.0:18.0:0.1]
impeller_cavity_diameter = 22.0; //[16.0:26.0:0.1]
volute_outer_diameter = 26.0; //[20.0:28.0:0.1]
volute_offset_x = 2.0; //[0.0:5.0:0.1]
lug_diameter = 7.0; //[5.0:12.0:0.1]
lug_thickness = 2.0; //[1.2:4.0:0.1]

// Blower module
module blower() {
  color([0.12, 0.12, 0.14]) {
    difference() {
      // Outer casing
      translate([0, 0, 0])
        cube([overall_length, overall_width, overall_depth], center=true);
      // Inner voids
      union() {
        translate([0, 0, (base_thickness - top_thickness) / 2])
          cube([overall_length - 2 * wall_thickness, overall_width - 2 * wall_thickness, overall_depth - top_thickness - base_thickness], center=true);
        translate([0, 0, (base_thickness - top_thickness) / 2])
          cylinder(h=overall_depth - top_thickness - base_thickness + 2 * clearance_overlap, r=impeller_cavity_diameter / 2, center=true);
        translate([volute_offset_x, 0, (base_thickness - top_thickness) / 2])
          cylinder(h=overall_depth - top_thickness - base_thickness + 2 * clearance_overlap, r=volute_outer_diameter / 2, center=true);
        translate([overall_length / 2 + (outlet_length + clearance_overlap) / 2 - clearance_overlap, 0, 0])
          cube([outlet_length + clearance_overlap, outlet_width, outlet_height], center=true);
        translate([overall_length / 2 - wall_thickness / 2, 0, 0])
          cube([wall_thickness + 2 * clearance_overlap, outlet_width, outlet_height], center=true);
      }
    }
    // Top cover
    translate([0, 0, overall_depth / 2 - top_thickness / 2])
      cube([overall_length, overall_width, top_thickness], center=true);
    // Base plate
    translate([0, 0, -overall_depth / 2 + base_thickness / 2])
      cube([overall_length, overall_width, base_thickness], center=true);
    // Screw lugs
    translate([overall_length / 2 + lug_diameter / 2 - clearance_overlap, overall_width / 4, -overall_depth / 2 + lug_thickness / 2])
      cylinder(h=lug_thickness, r=lug_diameter / 2, center=true);
    translate([overall_length / 2 + lug_diameter / 2 - clearance_overlap, -overall_width / 4, -overall_depth / 2 + lug_thickness / 2])
      cylinder(h=lug_thickness, r=lug_diameter / 2, center=true);
  }
}

// Fan module
module fan() {
  color([0.15, 0.15, 0.17]) {
    // Frame
    difference() {
      cube([overall_length, overall_width, 10], center=true);
      cylinder(d=overall_length - 4, h=12, center=true, $fn=32);
    }
    // Hub
    cylinder(d=impeller_hub_diameter, h=impeller_hub_height, center=true, $fn=24);
    // Blades
    for (i = [0:6]) {
      rotate([0, 0, i * 360 / 7])
        hull() {
          translate([impeller_hub_diameter / 2 + 2, 0, 0])
            cylinder(r=2, h=impeller_hub_height, $fn=12);
          translate([impeller_cavity_diameter / 2 - 3, 3, impeller_hub_height * 0.3])
            rotate([0, 10, 15])
            cylinder(r=2.5, h=impeller_hub_height * 0.7, $fn=12);
        }
    }
  }
}

// Blower Fan module
module blower_fan() {
  blower();
  translate([0, 0, overall_depth / 2 + 5])
    fan();
}

// Assembly module
module assembly() {
  blower_fan();
}

assembly();