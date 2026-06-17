// Parameters
rod_diameter = 10.0; //[5.0:20.0:0.1]
rod_length = 60.0; //[30.0:120.0:1]
bracket_height = 20.0; //[10.0:40.0:0.5]
fit_clearance = 0.2; //[0.0:0.6:0.05]
wall_thickness = 4.0; //[2.0:8.0:0.5]
base_thickness = 5.0; //[2.5:10.0:0.5]
base_length = 40.0; //[20.0:80.0:1]
base_width = 20.0; //[10.0:40.0:1]
mount_hole_diameter = 4.5; //[3.0:8.0:0.1]
mount_hole_spacing = 30.0; //[15.0:60.0:1]
rod_center_height_from_base = 10.0; //[6.0:25.0:0.5]
clamp_gap = 2.0; //[0.5:6.0:0.5]
overlap = 1.0; //[0.5:2.0:0.1]

// Rod - complete geometry
module rod() {
  color("Silver") {
    cylinder(r=rod_diameter/2, h=rod_length, center=true, $fn=64);
  }
}

// Bracket assembly
module bracket_assembly() {
  color("DimGray") {
    // Mounting base
    translate([0, 0, base_thickness/2])
      cube([base_length, base_width, base_thickness], center=true);

    // Bracket body
    translate([0, 0, bracket_height/2])
      cube([base_width, base_width, bracket_height], center=true);

    // Rod seat or bore
    translate([0, 0, rod_center_height_from_base])
      rotate([90, 0, 0])
      cylinder(r=(rod_diameter/2) + fit_clearance, h=base_width + 2*overlap, center=true, $fn=64);

    // Mounting holes
    translate([mount_hole_spacing/2, 0, base_thickness/2])
      cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true, $fn=32);
    translate([-mount_hole_spacing/2, 0, base_thickness/2])
      cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true, $fn=32);

    // Clamp split or retention feature
    translate([0, 0, bracket_height/2])
      cube([base_width + 2*overlap, clamp_gap, bracket_height + 2*overlap], center=true);
  }
}

// Final assembly
module assembly() {
  difference() {
    union() {
      bracket_assembly();
    }
    // Subtract rod bore
    translate([0, 0, rod_center_height_from_base])
      rotate([90, 0, 0])
      cylinder(r=(rod_diameter/2) + fit_clearance, h=base_width + 2*overlap, center=true, $fn=64);

    // Subtract clamp split
    translate([0, 0, bracket_height/2])
      cube([base_width + 2*overlap, clamp_gap, bracket_height + 2*overlap], center=true);
  }
  // Add rod
  translate([0, 0, rod_center_height_from_base])
    rotate([0, 90, 0])
    rod();
}

assembly();