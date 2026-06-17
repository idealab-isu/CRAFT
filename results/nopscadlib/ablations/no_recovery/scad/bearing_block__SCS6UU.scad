// Parameters
shaft_diameter = 6; //[3:12:0.1]
block_length = 30; //[15:60:0.5]
block_width = 25; //[12.5:50:0.5]
block_height = 20; //[10:40:0.5]
shaft_bore_clearance = 0.2; //[0.05:0.6:0.05]
bore_diameter = 6.2; //[6.05:7.5:0.05]
bearing_outer_diameter = 12; //[6:24:0.1]
bearing_length = 19; //[10:38:0.5]
bearing_pocket_diameter_clearance = 0.2; //[0.05:0.6:0.05]
bearing_pocket_diameter = 12.2; //[12.05:14.0:0.05]
bearing_pocket_length = 19.2; //[10:30:0.5]
mounting_hole_count = 4; //[2:6:1]
mounting_screw_diameter = 3; //[2:6:0.1]
mounting_hole_clearance = 0.3; //[0.1:0.8:0.05]
mounting_hole_diameter = 3.3; //[3.0:4.5:0.05]
mounting_hole_edge_margin = 4; //[2:8:0.5]
mounting_hole_spacing_x = 20; //[10:40:0.5]
mounting_hole_spacing_y = 15; //[8:30:0.5]
fillet_radius = 1; //[0:3:0.25]
chamfer = 0.5; //[0:2:0.1]
overlap = 1; //[0.5:2:0.1]
retention_slot_width = 2.5; //[1.5:5:0.1]
retention_slot_length = 22; //[12:30:0.5]

// SCS Bearing Block Hole Positions
module scs_bearing_block_hole_positions() {
  color("Silver") {
    union() {
      translate([mounting_hole_spacing_x/2, mounting_hole_spacing_y/2, 0])
        cylinder(r=mounting_hole_diameter/2, h=block_height + 2*overlap, center=true);
      translate([-mounting_hole_spacing_x/2, mounting_hole_spacing_y/2, 0])
        cylinder(r=mounting_hole_diameter/2, h=block_height + 2*overlap, center=true);
      translate([mounting_hole_spacing_x/2, -mounting_hole_spacing_y/2, 0])
        cylinder(r=mounting_hole_diameter/2, h=block_height + 2*overlap, center=true);
      translate([-mounting_hole_spacing_x/2, -mounting_hole_spacing_y/2, 0])
        cylinder(r=mounting_hole_diameter/2, h=block_height + 2*overlap, center=true);
    }
  }
}

// SBR Bearing Block
module sbr_bearing_block() {
  color("DimGray") {
    difference() {
      cube([block_length, block_width, block_height], center=true);
      translate([0, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=bore_diameter/2, h=block_length + 2*overlap, center=true);
      translate([0, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=bearing_pocket_diameter/2, h=bearing_pocket_length + 2*overlap, center=true);
      scs_bearing_block_hole_positions();
      translate([0, 0, block_height/4 + bore_diameter/4])
        cube([retention_slot_length, retention_slot_width, block_height/2 + bore_diameter/2 + overlap], center=true);
    }
  }
}

// SCS Bearing Block
module scs_bearing_block() {
  color("Black") {
    sbr_bearing_block();
  }
}

// SBR Bearing Block Assembly
module sbr_bearing_block_assembly() {
  color("Silver") {
    scs_bearing_block();
  }
}

// Assembly
module assembly() {
  sbr_bearing_block_assembly();
}

assembly();