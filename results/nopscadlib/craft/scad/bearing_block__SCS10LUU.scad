// Long linear bearing block for 8.0mm shaft
// Block size: 40.0mm x 68.0mm (W x L)
// One connected solid (no separate bearing/parts)

shaft_diameter = 8;                 //[4:16:0.5]
block_width = 40;                   //[20:80:1]
block_length = 68;                  //[34:136:1]
block_height = 28;                  //[14:56:1]

bore_clearance = 0.2;               //[0:0.6:0.05]
bore_seat_diameter = 15;            //[10:30:0.5]   // LM8UU OD ~15
bore_seat_depth = 18;               //[8:26:1]      // depth of larger seat from top

mount_hole_diameter = 5;            //[3:8:0.5]
counterbore_diameter = 9;           //[6:14:0.5]
counterbore_depth = 4;              //[2:10:0.5]
mount_hole_edge_margin_x = 7;       //[4:14:0.5]
mount_hole_edge_margin_y = 10;      //[6:20:0.5]

clamp_slot_width = 2;               //[1:5:0.5]
clamp_slot_depth = 10;              //[4:20:0.5]

// Base / SCS-style features
base_thickness = 8;                 //[4:14:0.5]    // thicker mounting base at bottom
side_relief_depth = 2;              //[0:6:0.5]     // side relief pockets (cosmetic/weight)
side_relief_height = 10;            //[0:20:0.5]
corner_radius = 2;                  //[0:6:0.5]

overlap = 1;                        //[0.5:2:0.5]
$fn = 96;

// Derived
shaft_r = (shaft_diameter + bore_clearance)/2;
seat_r  = (bore_seat_diameter + bore_clearance)/2;

// Keep seat depth valid
seat_depth = min(bore_seat_depth, block_height - 2);

// Clamp slot: ensure it does NOT split the block into two separate halves.
// Keep at least a web of material on both sides of the slot.
min_web = 2; // mm
slot_w = min(clamp_slot_width, max(0.2, block_width - 2*min_web));

// Mount hole positions
module mount_holes_through() {
  for (sx = [-1, 1])
    for (sy = [-1, 1])
      translate([sx*(block_width/2 - mount_hole_edge_margin_x),
                 sy*(block_length/2 - mount_hole_edge_margin_y),
                 0])
        cylinder(r=mount_hole_diameter/2, h=block_height + 2*overlap, center=true);
}

module mount_counterbores_bottom() {
  for (sx = [-1, 1])
    for (sy = [-1, 1])
      translate([sx*(block_width/2 - mount_hole_edge_margin_x),
                 sy*(block_length/2 - mount_hole_edge_margin_y),
                 -block_height/2 + counterbore_depth/2])
        cylinder(r=counterbore_diameter/2, h=counterbore_depth + overlap, center=true);
}

// Rounded rectangular prism (optional corner radius)
module rounded_block(size=[40,68,28], r=2) {
  w=size[0]; l=size[1]; h=size[2];
  if (r <= 0) {
    cube([w,l,h], center=true);
  } else {
    // Minkowski with a short cylinder to round XY corners without changing Z
    minkowski() {
      cube([w-2*r, l-2*r, h], center=true);
      cylinder(r=r, h=0.01, center=true);
    }
  }
}

module long_linear_bearing_block() {
  difference() {
    // Solid body with optional rounded corners
    rounded_block([block_width, block_length, block_height], corner_radius);

    // Shaft through-bore along LENGTH (Y axis) - fully enclosed
    rotate([90, 0, 0])
      cylinder(r=shaft_r, h=block_length + 2*overlap, center=true);

    // Larger bearing seat from TOP side (not through), also along LENGTH
    translate([0, 0, block_height/2 - seat_depth/2])
      rotate([90, 0, 0])
        cylinder(r=seat_r, h=block_length + 2*overlap, center=true);

    // Clamp slot from TOP down to intersect the seat/bore (split clamp),
    // but NOT wide enough to cut the block into two separate plates.
    translate([0, 0, block_height/2 - clamp_slot_depth/2])
      cube([slot_w, block_length + 2*overlap, clamp_slot_depth + overlap], center=true);

    // Bottom base relief: create a step so the bottom "base" is thicker
    // (removes material from the upper portion only).
    translate([0, 0, (block_height/2 + (-block_height/2 + base_thickness))/2])
      cube([block_width + 2*overlap,
            block_length + 2*overlap,
            (block_height - base_thickness) + overlap], center=true);

    // Side relief pockets (typical SCS-style look), kept shallow so body remains strong
    if (side_relief_depth > 0 && side_relief_height > 0) {
      relief_h = min(side_relief_height, block_height - base_thickness - 1);
      relief_zc = -block_height/2 + base_thickness + relief_h/2;

      // Left/right pockets
      for (sx = [-1, 1]) {
        translate([sx*(block_width/2 - side_relief_depth/2),
                   0,
                   relief_zc])
          cube([side_relief_depth + overlap,
                block_length - 2*mount_hole_edge_margin_y,
                relief_h], center=true);
      }
    }

    // Mounting holes + counterbores
    mount_holes_through();
    mount_counterbores_bottom();
  }
}

long_linear_bearing_block();