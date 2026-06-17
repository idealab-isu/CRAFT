// Parameters
shaft_diameter = 9.0; //[4.5:18.0:0.1]
block_width = 50.0; //[25.0:100.0:0.5]
block_length = 85.0; //[42.5:170.0:0.5]
block_height = 30.0; //[15.0:60.0:0.5]
bore_diameter = 9.2; //[9.0:10.0:0.05]
mount_hole_count = 4; //[2:6:1]
mount_hole_diameter = 5.5; //[3.0:8.0:0.1]
edge_margin = 8.0; //[4.0:16.0:0.5]
counterbore_diameter = 10.0; //[7.0:16.0:0.1]
counterbore_depth = 4.0; //[1.5:10.0:0.1]
retention_flat_depth = 1.5; //[0.5:4.0:0.1]
retention_flat_width = 6.0; //[3.0:12.0:0.5]
retention_flat_length = 20.0; //[10.0:60.0:0.5]
overlap = 1.0; //[0.5:2.0:0.1]

// Bearing Block Housing
module scs_bearing_block() {
  color("Silver") {
    cube([block_width, block_length, block_height], center=true);
  }
}

// Shaft Bore
module shaft_bore() {
  rotate([90, 0, 0]) translate([0, 0, 0])
    cylinder(r=bore_diameter/2, h=block_length + 2*overlap, center=true);
}

// Mounting Hole Through
module mounting_hole_through() {
  cylinder(r=mount_hole_diameter/2, h=block_height + 2*overlap, center=true);
}

// Mounting Hole Counterbore
module mounting_hole_counterbore() {
  cylinder(r=counterbore_diameter/2, h=counterbore_depth + overlap, center=true);
}

// Bore Retention Flat Cut
module bore_retention_flat_cut() {
  cube([retention_flat_depth + overlap, retention_flat_length, retention_flat_width], center=true);
}

// Mounting Hole Positions
module sbr_bearing_block_hole_positions() {
  union() {
    translate([(block_width/2 - edge_margin), (block_length/2 - edge_margin), 0]) mounting_hole_through();
    translate([(-block_width/2 + edge_margin), (block_length/2 - edge_margin), 0]) mounting_hole_through();
    translate([(block_width/2 - edge_margin), (-block_length/2 + edge_margin), 0]) mounting_hole_through();
    translate([(-block_width/2 + edge_margin), (-block_length/2 + edge_margin), 0]) mounting_hole_through();
  }
}

// Mounting Hole Counterbore Positions
module scs_bearing_block_hole_positions() {
  union() {
    translate([(block_width/2 - edge_margin), (block_length/2 - edge_margin), (block_height/2 - counterbore_depth/2)]) mounting_hole_counterbore();
    translate([(-block_width/2 + edge_margin), (block_length/2 - edge_margin), (block_height/2 - counterbore_depth/2)]) mounting_hole_counterbore();
    translate([(block_width/2 - edge_margin), (-block_length/2 + edge_margin), (block_height/2 - counterbore_depth/2)]) mounting_hole_counterbore();
    translate([(-block_width/2 + edge_margin), (-block_length/2 + edge_margin), (block_height/2 - counterbore_depth/2)]) mounting_hole_counterbore();
  }
}

// Bore Retention Features
module bore_retention_features() {
  union() {
    translate([(bore_diameter/2 - retention_flat_depth/2), 0, 0]) bore_retention_flat_cut();
    translate([(-bore_diameter/2 + retention_flat_depth/2), 0, 0]) bore_retention_flat_cut();
  }
}

// Final Assembly
module scs_bearing_block_assembly() {
  difference() {
    scs_bearing_block();
    shaft_bore();
    sbr_bearing_block_hole_positions();
    scs_bearing_block_hole_positions();
    bore_retention_features();
  }
}

// Assembly
module assembly() {
  scs_bearing_block_assembly();
}

assembly();