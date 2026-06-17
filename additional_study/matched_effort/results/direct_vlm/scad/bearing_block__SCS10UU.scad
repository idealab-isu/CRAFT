$fn = 128;

// Linear bearing block for 8.0mm shaft
// Block size: 40.0mm x 35.0mm (X x Y)

shaft_d  = 8.0;
block_x  = 40.0;
block_y  = 35.0;
block_z  = 18.0;

clearance     = 0.25;                 // shaft clearance
shaft_hole_d  = shaft_d + 2*clearance;

edge_r = 1.2;                         // outer edge rounding

// Clamp split slot (opens to top, intersects bore)
slot_w   = 2.2;                       // split gap width (along Y)
slot_len = block_x + 2;               // through X

// Mounting holes (4x) through Z with counterbore on top
mount_hole_d = 5.0;
mount_cbo_d  = 9.0;
mount_cbo_h  = 3.0;
mount_edge_x = 7.0;
mount_edge_y = 7.0;

// Optional clamp screw holes across Y (2x), with head recess on +Y side
clamp_screw_d = 3.2;                  // M3 clearance
clamp_head_d  = 6.2;
clamp_head_h  = 2.2;
clamp_screw_x_offset = block_x * 0.22;
clamp_screw_z = block_z * 0.65;       // from bottom

eps = 0.2;

module rounded_block(size=[40,35,18], r=1.2) {
  x = size[0]; y = size[1]; z = size[2];
  rr = min(r, min(x,y)/2 - 0.01);
  hull() {
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*(x/2-rr), sy*(y/2-rr), 0])
        cylinder(r=rr, h=z, center=true);
  }
}

module bearing_block() {
  difference() {
    // Main body (verifiable overall size: block_x x block_y x block_z)
    rounded_block([block_x, block_y, block_z], edge_r);

    // Shaft bore along X axis (clear, continuous cylindrical channel)
    rotate([0, 90, 0])
      cylinder(d=shaft_hole_d, h=block_x + 2*eps, center=true);

    // Top split slot: from +Z face down past bore centerline
    slot_depth = (block_z/2) + (shaft_hole_d/2) + 1.0;
    translate([0, 0, (block_z/2) - (slot_depth/2) + eps/2])
      cube([slot_len, slot_w, slot_depth + eps], center=true);

    // Mounting holes (4x) through Z with counterbore on +Z face
    for (sx = [-1, 1], sy = [-1, 1]) {
      translate([sx*(block_x/2 - mount_edge_x), sy*(block_y/2 - mount_edge_y), 0]) {
        cylinder(d=mount_hole_d, h=block_z + 2*eps, center=true);
        translate([0, 0, (block_z/2) - (mount_cbo_h/2) + eps/2])
          cylinder(d=mount_cbo_d, h=mount_cbo_h + eps, center=true);
      }
    }

    // Clamp screw holes (2x) across Y, with head recess on +Y face
    for (sx = [-1, 1]) {
      translate([sx*clamp_screw_x_offset, 0, -block_z/2 + clamp_screw_z]) {
        rotate([90, 0, 0]) {
          cylinder(d=clamp_screw_d, h=block_y + 2*eps, center=true);
          translate([0, (block_y/2) - (clamp_head_h/2) + eps/2, 0])
            cylinder(d=clamp_head_d, h=clamp_head_h + eps, center=true);
        }
      }
    }
  }
}

bearing_block();