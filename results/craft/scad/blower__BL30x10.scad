// Parameters
overall_length = 30.0; //[15.0:60.0:0.1]
overall_width = 30.0; //[15.0:60.0:0.1]
overall_depth = 10.1; //[5.0:20.2:0.1]
wall_thickness = 1.2; //[0.6:2.4:0.1]
base_thickness = 1.2; //[0.6:2.4:0.1]
top_thickness = 1.0; //[0.5:2.0:0.1]
inlet_bore_diameter = 12.0; //[6.0:24.0:0.1]
volute_outer_radius = 13.0; //[6.5:15.0:0.1]
volute_inner_radius = 9.5; //[4.75:13.0:0.1]
outlet_width = 8.0; //[4.0:16.0:0.1]
outlet_height = 6.0; //[3.0:9.0:0.1]
outlet_length = 6.0; //[3.0:12.0:0.1]
mounting_hole_count = 2; //[2:4:1]
mount_hole_diameter = 3.0; //[2.0:4.0:0.1]
mount_lug_diameter = 6.5; //[4.0:10.0:0.1]
mount_lug_thickness = 2.0; //[1.0:4.0:0.1]
impeller_radius = 8.5; //[4.0:12.0:0.1]
impeller_height = 6.8; //[3.0:8.5:0.1]
hub_radius = 3.0; //[1.5:6.0:0.1]
hub_height = 7.2; //[3.0:9.0:0.1]
blade_count = 18; //[8:30:1]
blade_thickness = 0.8; //[0.4:1.6:0.1]
blade_radial_length = 4.5; //[2.0:7.0:0.1]
blade_inner_radius = 3.6; //[2.0:6.0:0.1]
impeller_overlap_to_base = 0.8; //[0.5:2.0:0.1]
assembly_overlap = 0.8; //[0.5:2.0:0.1]

// Blower module
module blower() {
  color([0.15, 0.15, 0.17]) {
    // Base plate
    translate([0, 0, -overall_depth/2 + base_thickness/2])
      cube([overall_length, overall_width, base_thickness], center=true);

    // Side walls
    difference() {
      translate([0, 0, -overall_depth/2 + base_thickness + (overall_depth - base_thickness - top_thickness)/2])
        cube([overall_length, overall_width, overall_depth - base_thickness - top_thickness], center=true);
      translate([0, 0, -overall_depth/2 + base_thickness + (overall_depth - base_thickness - top_thickness)/2])
        cube([overall_length - 2*wall_thickness, overall_width - 2*wall_thickness, overall_depth - base_thickness - top_thickness + 2*assembly_overlap], center=true);
    }

    // Top cover with inlet bore
    difference() {
      translate([0, 0, overall_depth/2 - top_thickness/2])
        cube([overall_length, overall_width, top_thickness], center=true);
      translate([0, 0, overall_depth/2 - top_thickness/2])
        cylinder(r=inlet_bore_diameter/2, h=top_thickness + 2*assembly_overlap, center=true);
    }

    // Volute
    difference() {
      translate([0, 0, -overall_depth/2 + base_thickness + (overall_depth - base_thickness - top_thickness)/2])
        cylinder(r=volute_outer_radius, h=overall_depth - base_thickness - top_thickness, center=true);
      translate([0, 0, -overall_depth/2 + base_thickness + (overall_depth - base_thickness - top_thickness)/2])
        cylinder(r=volute_inner_radius, h=overall_depth - base_thickness - top_thickness + 2*assembly_overlap, center=true);
    }

    // Outlet nozzle
    difference() {
      translate([overall_length/2 + outlet_length/2 - assembly_overlap, 0, -overall_depth/2 + base_thickness + outlet_height/2])
        cube([outlet_length, outlet_width, outlet_height], center=true);
      translate([overall_length/2 + outlet_length/2 - assembly_overlap, 0, -overall_depth/2 + base_thickness + outlet_height/2])
        cube([outlet_length + 2*assembly_overlap, outlet_width - 2*wall_thickness, outlet_height - 2*wall_thickness], center=true);
    }

    // Mounting lugs
    translate([-overall_length/2 + mount_lug_diameter/2, 0, -overall_depth/2 + mount_lug_thickness/2])
      cylinder(r=mount_lug_diameter/2, h=mount_lug_thickness, center=true);
    translate([overall_length/2 - mount_lug_diameter/2, 0, -overall_depth/2 + mount_lug_thickness/2])
      cylinder(r=mount_lug_diameter/2, h=mount_lug_thickness, center=true);

    // Screw holes
    translate([-overall_length/2 + mount_lug_diameter/2, 0, 0])
      cylinder(r=mount_hole_diameter/2, h=overall_depth + 2*assembly_overlap, center=true);
    translate([overall_length/2 - mount_lug_diameter/2, 0, 0])
      cylinder(r=mount_hole_diameter/2, h=overall_depth + 2*assembly_overlap, center=true);
  }
}

// Fan module
module fan() {
  color([0.2, 0.2, 0.22]) {
    // Frame
    difference() {
      cube([overall_length, overall_width, 10], center=true);
      translate([0, 0, 0])
        cylinder(d=overall_length - 4, h=12, center=true, $fn=32);
    }
    // Hub
    translate([0, 0, 0])
      cylinder(d=hub_radius * 2, h=8, center=true, $fn=24);
    // Blades
    for (i = [0:6]) {
      rotate([0, 0, i * 360 / 7])
        hull() {
          translate([hub_radius + 2, 0, -3])
            cylinder(r=2, h=6, $fn=8);
          translate([impeller_radius - 3, 3, 0])
            rotate([0, 12, 20])
            cylinder(r=2.5, h=5, $fn=8);
        }
    }
  }
}

// Blower Fan module
module blower_fan() {
  color([0.15, 0.15, 0.17]) {
    // Frame
    difference() {
      cube([overall_length, overall_width, 10], center=true);
      translate([0, 0, 0])
        cylinder(d=overall_length - 4, h=12, center=true, $fn=32);
    }
    // Hub
    translate([0, 0, 0])
      cylinder(d=hub_radius * 2, h=8, center=true, $fn=24);
    // Blades
    for (i = [0:6]) {
      rotate([0, 0, i * 360 / 7])
        hull() {
          translate([hub_radius + 2, 0, -3])
            cylinder(r=2, h=6, $fn=8);
          translate([impeller_radius - 3, 3, 0])
            rotate([0, 12, 20])
            cylinder(r=2.5, h=5, $fn=8);
        }
    }
  }
}

// Assembly
module assembly() {
  blower();
  translate([0, 0, overall_depth/2 + 5]) fan();
  translate([0, 0, overall_depth/2 + 15]) blower_fan();
}

assembly();