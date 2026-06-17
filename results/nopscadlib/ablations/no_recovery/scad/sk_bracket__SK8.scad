// Parameters
rod_diameter = 8.0; //[4.0:16.0:0.1]
overall_height = 20.0; //[10.0:40.0:0.5]
bracket_width = 30.0; //[15.0:60.0:0.5]
bracket_depth = 20.0; //[10.0:40.0:0.5]
base_thickness = 5.0; //[2.5:10.0:0.25]
rod_center_height_from_base = 12.0; //[6.0:24.0:0.25]
rod_clearance = 0.2; //[0.0:0.6:0.05]
wall_thickness = 4.0; //[2.0:8.0:0.25]
mount_hole_diameter = 4.2; //[3.0:6.0:0.1]
mount_hole_spacing = 20.0; //[10.0:40.0:0.5]
clamp_bolt_diameter = 3.2; //[2.0:5.0:0.1]
clamp_bolt_spacing = 14.0; //[8.0:28.0:0.5]
eps = 0.8; //[0.5:2.0:0.1]
rod_length = 40.0; //[20.0:120.0:1]

// Rod - complete geometry
module rod() {
  color("Silver") {
    cylinder(r=rod_diameter/2, h=rod_length, center=true, $fn=64);
  }
}

// Bracket assembly
module bracket() {
  color("DimGray") {
    // Mounting base
    translate([0, 0, base_thickness/2])
      cube([bracket_width, bracket_depth, base_thickness], center=true);

    // Support body
    translate([0, 0, base_thickness + (overall_height - base_thickness)/2])
      cube([bracket_width, bracket_depth, overall_height - base_thickness], center=true);

    // Clamp bosses
    translate([clamp_bolt_spacing/2, 0, rod_center_height_from_base])
      rotate([90, 0, 0])
      cylinder(r=(clamp_bolt_diameter/2) + wall_thickness, h=bracket_depth, center=true, $fn=64);
    translate([-clamp_bolt_spacing/2, 0, rod_center_height_from_base])
      rotate([90, 0, 0])
      cylinder(r=(clamp_bolt_diameter/2) + wall_thickness, h=bracket_depth, center=true, $fn=64);
  }
}

// Subtract features
module subtract_features() {
  difference() {
    bracket();

    // Rod bore or cradle
    translate([0, 0, rod_center_height_from_base])
      rotate([90, 0, 0])
      cylinder(r=(rod_diameter/2) + rod_clearance, h=bracket_depth + 2*eps, center=true, $fn=64);

    // Mounting holes
    translate([mount_hole_spacing/2, 0, base_thickness/2])
      cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*eps, center=true, $fn=32);
    translate([-mount_hole_spacing/2, 0, base_thickness/2])
      cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*eps, center=true, $fn=32);

    // Clamp split slot
    translate([0, 0, base_thickness + (overall_height - base_thickness)/2])
      cube([wall_thickness, bracket_depth + 2*eps, overall_height - base_thickness + 2*eps], center=true);

    // Clamp bolt holes
    translate([clamp_bolt_spacing/2, 0, rod_center_height_from_base])
      rotate([90, 0, 0])
      cylinder(r=clamp_bolt_diameter/2, h=bracket_depth + 2*eps, center=true, $fn=32);
    translate([-clamp_bolt_spacing/2, 0, rod_center_height_from_base])
      rotate([90, 0, 0])
      cylinder(r=clamp_bolt_diameter/2, h=bracket_depth + 2*eps, center=true, $fn=32);
  }
}

// Assembly
module assembly() {
  union() {
    subtract_features();
    rod();
  }
}

assembly();