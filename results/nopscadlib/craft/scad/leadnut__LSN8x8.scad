// Parameters
block_width = 8.0; //[4.0:16.0:0.25]
block_height = 12.75; //[6.0:25.5:0.25]
block_length = 19.0; //[10.0:38.0:0.25]
tolerance_clearance = 0.2; //[0.0:0.6:0.05]
edge_chamfer = 0.5; //[0.0:2.0:0.1]
bore_diameter = 6.0; //[2.0:10.0:0.1]
bore_depth = 19.0; //[5.0:38.0:0.25]
nut_outer_diameter_or_af = 7.0; //[3.0:14.0:0.1]
nut_length_or_thickness = 6.0; //[2.0:12.0:0.25]
mount_hole_count = 2; //[0:4:1]
mount_hole_diameter = 3.0; //[0.0:6.0:0.1]
mount_hole_spacing = 10.0; //[4.0:18.0:0.25]
fastener_clearance_diameter = 3.4; //[0.0:7.0:0.1]
leadscrew_diameter = 4.0; //[2.0:8.0:0.1]
leadscrew_length = 35.0; //[19.0:80.0:0.5]
overlap = 1.0; //[0.5:2.0:0.1]

// Main housing with all features (kept as-is: it is a hollowed block)
module housing() {
  difference() {
    // Main body
    color([0.85, 0.85, 0.8]) cube([block_width, block_length, block_height], center=true);

    // Nut cavity / bore (Y axis)
    rotate([90, 0, 0])
      cylinder(d=bore_diameter + tolerance_clearance,
               h=bore_depth + 2*overlap, center=true, $fn=32);

    // Nut pocket (Y axis, near +Y face)
    translate([0,
               (block_length/2) - (nut_length_or_thickness/2) + overlap,
               0])
      rotate([90, 0, 0])
      cylinder(d=nut_outer_diameter_or_af + tolerance_clearance,
               h=nut_length_or_thickness + 2*overlap, center=true, $fn=32);

    // Mounting holes (Z axis)
    if (mount_hole_count >= 1) {
      translate([0,  mount_hole_spacing/2, 0])
        cylinder(d=mount_hole_diameter + tolerance_clearance,
                 h=block_height + 2*overlap, center=true, $fn=32);
      translate([0, -mount_hole_spacing/2, 0])
        cylinder(d=mount_hole_diameter + tolerance_clearance,
                 h=block_height + 2*overlap, center=true, $fn=32);
    }

    // Fastener clearance holes (Z axis)
    if (fastener_clearance_diameter > 0) {
      translate([ block_width/4, 0, 0])
        cylinder(d=fastener_clearance_diameter + tolerance_clearance,
                 h=block_height + 2*overlap, center=true, $fn=32);
      translate([-block_width/4, 0, 0])
        cylinder(d=fastener_clearance_diameter + tolerance_clearance,
                 h=block_height + 2*overlap, center=true, $fn=32);
    }

    // Chamfer cuts
    translate([(block_width/2) - edge_chamfer, (block_length/2) - edge_chamfer, 0])
      rotate([0, 0, 45])
      cube([edge_chamfer*2, edge_chamfer*2, block_height + 2*overlap], center=true);
    translate([(block_width/2) - edge_chamfer, -(block_length/2) + edge_chamfer, 0])
      rotate([0, 0, 45])
      cube([edge_chamfer*2, edge_chamfer*2, block_height + 2*overlap], center=true);
    translate([-(block_width/2) + edge_chamfer, (block_length/2) - edge_chamfer, 0])
      rotate([0, 0, 45])
      cube([edge_chamfer*2, edge_chamfer*2, block_height + 2*overlap], center=true);
    translate([-(block_width/2) + edge_chamfer, -(block_length/2) + edge_chamfer, 0])
      rotate([0, 0, 45])
      cube([edge_chamfer*2, edge_chamfer*2, block_height + 2*overlap], center=true);
  }
}

// Leadscrew (Y axis) with an external "bonding ring" that overlaps the housing material.
// This fixes the structural issue: the rod is no longer a separate body passing through a void.
// The ring is OUTSIDE the bore, so it intersects the housing solid and fuses via union().
module leadscrew_with_bond_ring() {
  // Bore is cut at (bore_diameter + tolerance_clearance)
  bore_cut_d = bore_diameter + tolerance_clearance;

  // Make the ring slightly larger than the cut bore so it sits in solid material.
  // Keep it small enough to fit within the block width/height.
  ring_outer_d = min(bore_cut_d + 2.0*overlap, min(block_width, block_height) - 0.6);
  ring_thickness_y = 2.0*overlap; // 2mm when overlap=1

  color("Silver")
  union() {
    // Main rod aligned with the bore axis (Y)
    rotate([90, 0, 0])
      cylinder(d=leadscrew_diameter, h=leadscrew_length, center=true, $fn=48);

    // Bonding ring centered in the housing: overlaps housing material radially by ~overlap
    // and overlaps along Y by ring_thickness_y.
    rotate([90, 0, 0])
      cylinder(d=ring_outer_d, h=ring_thickness_y, center=true, $fn=64);
  }
}

// Assembly (single connected solid)
module assembly() {
  union() {
    housing();
    // Centered so it passes through the housing; bond ring guarantees physical attachment (overlap)
    leadscrew_with_bond_ring();
  }
}

assembly();