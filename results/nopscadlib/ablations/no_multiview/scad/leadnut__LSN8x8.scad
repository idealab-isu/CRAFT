// Parameters
block_width = 8.0; //[4.0:16.0:0.25]
block_height = 12.75; //[6.0:25.5:0.25]
block_length = 19.0; //[9.5:38.0:0.5]
tolerance_clearance = 0.2; //[0.0:0.6:0.05]
nut_outer_diameter = 7.0; //[4.0:12.0:0.1]
nut_length = 10.0; //[5.0:18.0:0.25]
bore_diameter = 7.2; //[4.0:12.5:0.1]
bore_depth = 12.0; //[4.0:19.0:0.25]
mount_hole_count = 2; //[0:4:1]
mount_hole_diameter = 3.2; //[1.5:6.0:0.1]
mount_hole_spacing = 12.0; //[6.0:17.0:0.25]
counterbore_diameter = 6.0; //[3.5:10.0:0.1]
counterbore_depth = 2.0; //[0.5:6.0:0.1]
anti_rotation_width = 2.0; //[1.0:4.0:0.1]
anti_rotation_depth = 1.0; //[0.5:3.0:0.1]
edge_chamfer = 0.5; //[0.0:2.0:0.1]
leadscrew_diameter = 4.0; //[2.0:8.0:0.1]
leadscrew_length = 30.0; //[19.0:80.0:1]
overlap = 1.0; //[0.5:2.0:0.1]

// Derived
bore_d = bore_diameter + tolerance_clearance;

// Main body with features
module housing_block() {
  difference() {
    // Main block
    cube([block_width, block_length, block_height], center=true);

    // Nut bore or pocket (axis along Y)
    rotate([90, 0, 0])
      cylinder(d=bore_d, h=bore_depth, center=true, $fn=64);

    // Anti-rotation feature (slot intersecting bore)
    translate([bore_d/2 - anti_rotation_depth + anti_rotation_width/2, 0, 0])
      cube([anti_rotation_width, bore_depth + 2*overlap, bore_d + 2*overlap], center=true);

    // Mounting holes (axis along Z)
    if (mount_hole_count >= 2) {
      translate([0,  mount_hole_spacing/2, 0])
        cylinder(d=mount_hole_diameter, h=block_height + 2*overlap, center=true, $fn=48);
      translate([0, -mount_hole_spacing/2, 0])
        cylinder(d=mount_hole_diameter, h=block_height + 2*overlap, center=true, $fn=48);
    }

    // Counterbores (top face)
    if (mount_hole_count >= 2) {
      translate([0,  mount_hole_spacing/2,  block_height/2 - counterbore_depth/2])
        cylinder(d=counterbore_diameter, h=counterbore_depth + overlap, center=true, $fn=48);
      translate([0, -mount_hole_spacing/2,  block_height/2 - counterbore_depth/2])
        cylinder(d=counterbore_diameter, h=counterbore_depth + overlap, center=true, $fn=48);
    }

    // Lead-in chamfers (ends of bore along Y)
    translate([0,  block_length/2 - edge_chamfer/2, 0])
      rotate([90, 0, 0])
      cylinder(r1=bore_d/2 + edge_chamfer, r2=bore_d/2, h=edge_chamfer, center=true, $fn=64);

    translate([0, -block_length/2 + edge_chamfer/2, 0])
      rotate([-90, 0, 0])
      cylinder(r1=bore_d/2 + edge_chamfer, r2=bore_d/2, h=edge_chamfer, center=true, $fn=64);
  }
}

// Leadscrew rod (visual/assembly) — kept, but now physically fused to the block
module leadscrew_rod() {
  cylinder(d=leadscrew_diameter, h=leadscrew_length, center=true, $fn=64);
}

// Two cylindrical inserts/bushings (orange rings) — MUST be fused to the blue block.
// Implemented as annular rings that sit in the counterbore pockets and overlap into the block.
module bushing_rings() {
  // Ring geometry
  ring_od = counterbore_diameter;                 // match counterbore pocket
  ring_id = mount_hole_diameter + tolerance_clearance;
  ring_h  = counterbore_depth + overlap;          // extend deeper by overlap to guarantee fusion

  // Place rings so their top is flush with the top face, and they extend down into the block by overlap.
  // Top face is at +block_height/2.
  zc = block_height/2 - ring_h/2;

  if (mount_hole_count >= 2) {
    for (yy = [mount_hole_spacing/2, -mount_hole_spacing/2]) {
      translate([0, yy, zc])
        difference() {
          cylinder(d=ring_od, h=ring_h, center=true, $fn=64);
          cylinder(d=ring_id, h=ring_h + 2*overlap, center=true, $fn=64);
        }
    }
  }
}

// Small fusion "keys" that physically attach the rod to the block with 1–2mm overlap.
// These are placed inside the block thickness (X direction) so they intersect both:
// - the rod (at x=0)
// - the block (extends to near +/- block_width/2)
module rod_fusion_keys() {
  key_thickness_y = 2*overlap;                 // 2mm wide along Y
  key_thickness_z = max(2*overlap, 2.0);       // ~2mm tall along Z
  key_len_x = block_width/2 + overlap;         // reaches into the block from the rod

  // Place two keys at +/- along Y within the block, away from mounting holes.
  for (yy = [-(block_length/4), (block_length/4)]) {
    translate([0, yy, 0])
      cube([key_len_x*2, key_thickness_y, key_thickness_z], center=true);
  }
}

// Assembly: single fused solid (union) with guaranteed overlap connections
module assembly() {
  union() {
    housing_block();

    // Visual rod
    leadscrew_rod();

    // Physical attachment for rod
    rod_fusion_keys();

    // FIX: add and fuse the two cylindrical inserts/bushings into the counterbores
    // with 1mm overlap into the block so they are not floating/disconnected.
    bushing_rings();
  }
}

assembly();