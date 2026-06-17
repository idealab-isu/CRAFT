// Parameters
rod_diameter = 16; //[8:32:0.1]
rod_length = 60; //[30:120:1]
overall_height = 27; //[14:54:0.1]
bracket_width = 40; //[20:80:0.1]
bracket_depth = 25; //[12.5:50:0.1]
base_thickness = 6; //[3:12:0.1]
wall_thickness = 6; //[3:12:0.1]
rod_clearance = 0.2; //[0:0.6:0.05]
mount_hole_diameter = 5; //[3:8:0.1]
mount_hole_spacing = 24; //[12:48:0.1]
mount_hole_edge_margin = 6; //[3:12:0.1]
clamp_bolt_diameter = 5; //[3:8:0.1]
clamp_slot_width = 2; //[1:4:0.1]
overlap = 1; //[0.5:2:0.1]
bore_diameter = 16.4; //[8.1:32.8:0.1]
upper_block_height = 21; //[10.5:42:0.1]
upper_block_depth = 25; //[12.5:50:0.1]

// Rod - complete geometry
module rod() {
  color("Silver") {
    cylinder(r=rod_diameter/2, h=rod_length, center=true, $fn=64);
  }
}

// Bracket - complete geometry
module bracket() {
  color("Silver") {
    difference() {
      union() {
        // Mounting base
        translate([0, 0, -overall_height/2 + base_thickness/2])
          cube([bracket_width, bracket_depth, base_thickness], center=true);
        // Bracket body
        translate([0, 0, -overall_height/2 + base_thickness + upper_block_height/2 - overlap])
          cube([bracket_width, upper_block_depth, upper_block_height], center=true);
      }
      // Rod seat or bore
      translate([0, 0, -overall_height/2 + base_thickness + upper_block_height/2 - overlap])
        rotate([0, 90, 0])
        cylinder(r=bore_diameter/2, h=bracket_width + 2*overlap, center=true, $fn=64);
      // Rod clamp feature
      translate([bracket_width/2 - clamp_slot_width/2, 0, -overall_height/2 + base_thickness + upper_block_height/2 - overlap])
        cube([clamp_slot_width, upper_block_depth + 2*overlap, upper_block_height + 2*overlap], center=true);
      // Clamp bolt hole
      translate([0, 0, -overall_height/2 + base_thickness + upper_block_height/2 - overlap])
        rotate([90, 0, 0])
        cylinder(r=clamp_bolt_diameter/2, h=upper_block_depth + 2*overlap, center=true, $fn=64);
      // Mount holes
      translate([-mount_hole_spacing/2, 0, -overall_height/2 + base_thickness/2])
        cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true, $fn=64);
      translate([mount_hole_spacing/2, 0, -overall_height/2 + base_thickness/2])
        cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  bracket();
  translate([0, 0, -overall_height/2 + base_thickness + upper_block_height/2 - overlap])
    rod();
}

assembly();