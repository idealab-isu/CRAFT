// Parameters
envelope_length_mm = 40; //[20:80:1]
envelope_width_mm = 40; //[20:80:1]
envelope_depth_mm = 20; //[10:40:1]
wall_thickness_mm = 2.2; //[1.1:4.4:0.1]
top_thickness_mm = 2; //[1:4:0.1]
bottom_thickness_mm = 2; //[1:4:0.1]
internal_clearance_mm = 0.6; //[0.2:1.5:0.1]
inlet_bore_d_mm = 18; //[10:28:0.5]
inlet_boss_d_mm = 22; //[14:34:0.5]
inlet_boss_h_mm = 2.5; //[1:6:0.1]
outlet_width_mm = 14; //[8:24:0.5]
outlet_height_mm = 8; //[5:16:0.5]
outlet_length_mm = 10; //[5:25:0.5]
outlet_overlap_mm = 1; //[0.5:2:0.1]
impeller_outer_d_mm = 28; //[18:36:0.5]
impeller_height_mm = 12; //[6:18:0.5]
hub_d_mm = 10; //[6:18:0.5]
hub_height_mm = 10; //[5:18:0.5]
blade_count = 20; //[12:36:1]
blade_thickness_mm = 1; //[0.6:2:0.1]
blade_radial_len_mm = 7; //[4:12:0.5]
blade_overlap_into_hub_mm = 1; //[0.5:2:0.1]
mount_hole_d_mm = 3.2; //[2.4:4.2:0.1]
lug_d_mm = 7.5; //[5:12:0.1]
lug_height_mm = 3; //[2:6:0.1]
lug_inset_mm = 4.5; //[2.5:8:0.1]
screw_hole_overlap_mm = 0.8; //[0.5:2:0.1]

// Blower
module blower() {
  color([0.12, 0.12, 0.14]) {
    difference() {
      // Volute casing
      union() {
        // Outer block
        translate([0, 0, 0])
          cube([envelope_length_mm, envelope_width_mm, envelope_depth_mm], center=true);
        // Outlet nozzle
        translate([envelope_length_mm/2 + outlet_length_mm/2 - outlet_overlap_mm, 0, 0])
          difference() {
            cube([outlet_length_mm, outlet_width_mm, outlet_height_mm], center=true);
            translate([0, 0, 0])
              cube([outlet_length_mm + 2*screw_hole_overlap_mm, outlet_width_mm - 2*wall_thickness_mm, outlet_height_mm - 2*wall_thickness_mm], center=true);
          }
        // Inlet boss ring
        translate([0, 0, envelope_depth_mm/2 - inlet_boss_h_mm/2])
          difference() {
            cylinder(r=inlet_boss_d_mm/2, h=inlet_boss_h_mm, center=true);
            cylinder(r=inlet_bore_d_mm/2, h=inlet_boss_h_mm + 2*screw_hole_overlap_mm, center=true);
          }
        // Mounting lugs
        for (x = [-1, 1], y = [-1, 1]) {
          translate([x * (envelope_length_mm/2 - lug_inset_mm), y * (envelope_width_mm/2 - lug_inset_mm), -envelope_depth_mm/2 + lug_height_mm/2 - 1])
            cylinder(r=lug_d_mm/2, h=lug_height_mm, center=true);
        }
      }
      // Inner cavity
      translate([0, 0, (top_thickness_mm - bottom_thickness_mm)/2])
        cube([envelope_length_mm - 2*wall_thickness_mm, envelope_width_mm - 2*wall_thickness_mm, envelope_depth_mm - top_thickness_mm - bottom_thickness_mm], center=true);
      // Inlet bore
      translate([0, 0, 0])
        cylinder(r=inlet_bore_d_mm/2, h=envelope_depth_mm + 2*screw_hole_overlap_mm, center=true);
      // Outlet port cut in casing
      translate([envelope_length_mm/2 - wall_thickness_mm/2, 0, 0])
        cube([wall_thickness_mm + 2*screw_hole_overlap_mm, outlet_width_mm - 2*wall_thickness_mm, outlet_height_mm - 2*wall_thickness_mm], center=true);
      // Mounting screw holes
      for (x = [-1, 1], y = [-1, 1]) {
        translate([x * (envelope_length_mm/2 - lug_inset_mm), y * (envelope_width_mm/2 - lug_inset_mm), 0])
          cylinder(r=mount_hole_d_mm/2, h=envelope_depth_mm + lug_height_mm + 2*screw_hole_overlap_mm, center=true);
      }
    }
  }
}

// Fan
module fan() {
  color([0.15, 0.15, 0.17]) {
    // Frame
    difference() {
      cube([envelope_length_mm, envelope_width_mm, 10], center=true);
      cylinder(d=envelope_length_mm-4, h=12, center=true, $fn=32);
    }
    // Hub
    cylinder(d=hub_d_mm, h=hub_height_mm, center=true, $fn=24);
    // Blades
    for (i = [0:6]) {
      rotate([0, 0, i*360/7])
        hull() {
          translate([hub_d_mm/2 + 2, 0, 0])
            cylinder(r=2, h=impeller_height_mm, $fn=12);
          translate([impeller_outer_d_mm/2 - 3, 3, impeller_height_mm*0.3])
            rotate([0, 10, 15])
            cylinder(r=2.5, h=impeller_height_mm*0.7, $fn=12);
        }
    }
  }
}

// Blower Fan
module blower_fan() {
  color([0.15, 0.15, 0.17]) {
    // Frame
    difference() {
      cube([envelope_length_mm, envelope_width_mm, 10], center=true);
      cylinder(d=envelope_length_mm-4, h=12, center=true, $fn=32);
    }
    // Hub
    cylinder(d=hub_d_mm, h=hub_height_mm, center=true, $fn=24);
    // Blades
    for (i = [0:6]) {
      rotate([0, 0, i*360/7])
        hull() {
          translate([hub_d_mm/2 + 2, 0, 0])
            cylinder(r=2, h=impeller_height_mm, $fn=12);
          translate([impeller_outer_d_mm/2 - 3, 3, impeller_height_mm*0.3])
            rotate([0, 10, 15])
            cylinder(r=2.5, h=impeller_height_mm*0.7, $fn=12);
        }
    }
  }
}

// Assembly
module assembly() {
  blower();
  translate([0, 0, envelope_depth_mm/2 + 5]) fan();
  translate([0, 0, envelope_depth_mm/2 + 15]) blower_fan();
}

assembly();