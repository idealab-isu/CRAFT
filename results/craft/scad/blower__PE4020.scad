// Parameters
width_mm = 40; //[20:80:1]
length_mm = 40; //[20:80:1]
depth_mm = 20; //[10:40:1]
wall_thk = 2; //[1:5:0.5]
base_thk = 2; //[1:5:0.5]
top_thk = 2; //[1:5:0.5]
clearance = 0.6; //[0.2:2:0.1]
overlap = 1; //[0.5:2:0.1]
inlet_bore_d = 18; //[10:30:1]
impeller_outer_d = 28; //[16:36:1]
impeller_height = 14; //[8:18:1]
hub_d = 10; //[6:18:1]
hub_height = 16; //[8:20:1]
blade_count = 20; //[8:40:1]
blade_thk = 1; //[0.6:2:0.1]
blade_radial_len = 6; //[3:10:0.5]
outlet_w = 12; //[6:20:1]
outlet_h = 10; //[6:18:1]
outlet_len = 14; //[8:30:1]
lug_r = 4; //[2:8:0.5]
mount_hole_d = 3.2; //[2:5:0.1]
mount_pitch = 32; //[20:60:1]

// PE4020 Blower
module blower() {
  color([0.15, 0.15, 0.17]) {
    // Base Plate
    translate([0, 0, (-depth_mm/2) + (base_thk/2)])
      cube([width_mm, length_mm, base_thk], center=true);

    // Top Cover
    translate([0, 0, (depth_mm/2) - (top_thk/2)])
      cube([width_mm, length_mm, top_thk], center=true);

    // Side Walls
    difference() {
      translate([0, 0, 0])
        cube([width_mm, length_mm, depth_mm - base_thk - top_thk], center=true);
      translate([0, 0, 0])
        cube([width_mm - 2*wall_thk, length_mm - 2*wall_thk, depth_mm - base_thk - top_thk + 2*overlap], center=true);
    }

    // Outlet Nozzle
    difference() {
      translate([(width_mm/2) + (outlet_len/2) - overlap, 0, 0])
        cube([outlet_len, outlet_w, outlet_h], center=true);
      translate([(width_mm/2) + (outlet_len/2) - overlap, 0, 0])
        cube([outlet_len + 2*overlap, outlet_w - 2*wall_thk, outlet_h - 2*wall_thk], center=true);
    }

    // Mounting Lugs
    for (i = [0:3]) {
      translate([mount_pitch/2 * cos(i*90), mount_pitch/2 * sin(i*90), 0])
        cylinder(r=lug_r, h=base_thk + top_thk + (depth_mm - base_thk - top_thk), center=true);
    }

    // Mounting Holes
    for (i = [0:3]) {
      translate([mount_pitch/2 * cos(i*90), mount_pitch/2 * sin(i*90), 0])
        cylinder(r=mount_hole_d/2, h=depth_mm + 2*overlap, center=true);
    }

    // Inlet Bore
    translate([0, 0, (depth_mm/2) - (top_thk/2)])
      cylinder(r=inlet_bore_d/2, h=top_thk + 2*overlap, center=true);
  }
}

// Fan
module fan() {
  color([0.2, 0.2, 0.22]) {
    // Frame
    difference() {
      cube([width_mm, width_mm, 10], center=true);
      cylinder(d=width_mm-4, h=12, center=true, $fn=32);
    }
    // Hub
    cylinder(d=hub_d, h=8, center=true, $fn=24);
    // Blades
    for (i = [0:6]) {
      rotate([0, 0, i*360/7])
        hull() {
          translate([hub_d/2 + 2, 0, 0]) cylinder(r=2, h=8, $fn=12);
          translate([width_mm/2 - 3, 3, 2.4]) rotate([0, 10, 15]) cylinder(r=2.5, h=5.6, $fn=12);
        }
    }
  }
}

// Blower Fan
module blower_fan() {
  color([0.2, 0.2, 0.22]) {
    // Frame
    difference() {
      cube([width_mm, width_mm, 10], center=true);
      cylinder(d=width_mm-4, h=12, center=true, $fn=32);
    }
    // Hub
    cylinder(d=hub_d, h=8, center=true, $fn=24);
    // Blades
    for (i = [0:6]) {
      rotate([0, 0, i*360/7])
        hull() {
          translate([hub_d/2 + 2, 0, 0]) cylinder(r=2, h=8, $fn=12);
          translate([width_mm/2 - 3, 3, 2.4]) rotate([0, 10, 15]) cylinder(r=2.5, h=5.6, $fn=12);
        }
    }
  }
}

// Assembly
module assembly() {
  blower();
  translate([0, 0, depth_mm/2 + 5]) fan();
  translate([0, 0, depth_mm/2 + 15]) blower_fan();
}

assembly();