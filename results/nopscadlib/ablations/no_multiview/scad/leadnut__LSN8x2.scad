// Parameters
block_width = 8.0; //[4.0:16.0:0.1]
block_height = 10.2; //[5.1:20.4:0.1]
block_length = 15.0; //[7.5:30.0:0.1]
tolerance_clearance = 0.2; //[0.0:0.6:0.05]
bore_diameter = 5.0; //[2.0:7.5:0.1]
nut_pocket_diameter = 8.0; //[4.0:12.0:0.1]
nut_pocket_depth = 4.0; //[0.0:10.2:0.1]
mount_hole_diameter = 3.0; //[1.5:5.0:0.1]
mount_hole_edge_margin_x = 2.0; //[1.0:3.5:0.1]
mount_hole_edge_margin_y = 3.0; //[1.5:6.0:0.1]
edge_chamfer = 0.0; //[0.0:1.5:0.1]
chamfer_overlap = 0.8; //[0.5:2.0:0.1]
leadscrew_diameter = 4.0; //[2.0:8.0:0.1]
leadscrew_length = 25.0; //[15.0:60.0:0.5]
leadscrew_overlap = 1.0; //[0.5:2.0:0.1]

// Small guaranteed overlap to fuse parts (1-2mm)
attach_overlap = 1.5;

// Housing block with features (kept as-is)
module housing_block() {
  difference() {
    // Main block
    color([0.85, 0.85, 0.8])
      cube([block_width, block_length, block_height], center=true);

    // Central bore (through Y axis)
    rotate([90, 0, 0])
      cylinder(d=bore_diameter + tolerance_clearance,
               h=block_length + 2*tolerance_clearance,
               center=true, $fn=32);

    // Nut capture pocket (from top face)
    if (nut_pocket_depth > 0) {
      translate([0, 0, block_height/2 - nut_pocket_depth/2])
        cylinder(d=nut_pocket_diameter + tolerance_clearance,
                 h=nut_pocket_depth,
                 center=true, $fn=32);
    }

    // Mounting holes (through Z axis)
    if (mount_hole_diameter > 0) {
      for (x = [-1, 1], y = [-1, 1]) {
        translate([x * (block_width/2 - mount_hole_edge_margin_x),
                   y * (block_length/2 - mount_hole_edge_margin_y),
                   0])
          cylinder(d=mount_hole_diameter + tolerance_clearance,
                   h=block_height + 2*tolerance_clearance,
                   center=true, $fn=32);
      }
    }

    // Edge chamfers
    if (edge_chamfer > 0) {
      for (x = [-1, 1], y = [-1, 1]) {
        translate([x * (block_width/2 - edge_chamfer + chamfer_overlap/2),
                   y * (block_length/2 - edge_chamfer + chamfer_overlap/2),
                   0])
          rotate([0, 0, 45])
            cube([edge_chamfer*2, edge_chamfer*2, block_height + 2*chamfer_overlap], center=true);
      }
    }
  }
}

// Assembly: make a SINGLE connected solid.
// Fix: the rod must be physically attached to the housing, not just passing through a hole.
// We add a small "boss" (solid collar) around the bore on BOTH sides of the block,
// overlapping the block by attach_overlap to guarantee fusion.
module assembly() {
  union() {
    // Main housing
    housing_block();

    // Leadscrew rod (visual/solid)
    // Oriented along Y to match the bore.
    color("SteelBlue")
      rotate([90, 0, 0])
        cylinder(d=leadscrew_diameter,
                 h=leadscrew_length,
                 center=true, $fn=32);

    // Attachment bosses (collars) to physically join rod to housing.
    // These create real material connection (not through the bore void),
    // overlapping into the block by 1.5mm.
    boss_d = max(bore_diameter + 2.0, leadscrew_diameter + 2.0); // modest collar, keeps design intent
    boss_h = attach_overlap * 2; // total thickness; half sits inside block, half outside

    // Place bosses at the two Y faces of the block, with overlap into the block.
    for (side = [-1, 1]) {
      translate([0, side * (block_length/2 - attach_overlap/2), 0])
        rotate([90, 0, 0])
          cylinder(d=boss_d,
                   h=boss_h,
                   center=true, $fn=48);
    }
  }
}

assembly();