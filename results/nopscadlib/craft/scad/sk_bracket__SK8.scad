// Shaft support bracket for 8.0mm rod, 20.0mm tall
// Connectivity-fixed: single continuous solid, no floating halves, no center split

// Parameters
rod_diameter = 8.0; //[4.0:16.0:0.1]
bracket_height = 20.0; //[10.0:40.0:0.5]
bracket_width  = 30.0; //[15.0:60.0:0.5]
bracket_depth  = 20.0; //[10.0:50.0:0.5]

base_thickness = 5.0;  //[2.5:12.0:0.5]
wall_thickness = 4.0;  //[2.0:10.0:0.5]
rod_clearance  = 0.2;  //[0.0:0.6:0.05]

mount_hole_count = 2; //[1:4:1]
mount_hole_diameter = 4.2; //[2.0:8.0:0.1]
mount_hole_spacing  = 20.0; //[10.0:50.0:0.5]
mount_hole_edge_margin = 5.0; //[2.0:15.0:0.5]

clamp_split = 1; //[0:1:1]
clamp_split_slot_width = 1.2; //[0.6:3.0:0.1]

overlap = 1.0; //[0.5:2.0:0.1]
$fn = 96;

module bracket() {
  rod_r = (rod_diameter + 2*rod_clearance)/2;

  // Rod axis positioned to keep bottom wall = base_thickness and top wall = wall_thickness
  rod_axis_z = -bracket_height/2 + base_thickness + rod_r;

  // Slot should NOT split the part into left/right halves.
  // Ensure a solid "spine" remains by limiting slot depth in X.
  // Keep at least 2mm of material at the far side of the slot.
  min_spine = 2.0;
  slot_x = min(clamp_split_slot_width, max(0.2, bracket_width - min_spine));

  // Slot runs along depth (Y), from top surface down to (just past) rod axis.
  slot_h = (bracket_height/2 - rod_axis_z) + overlap;
  slot_z = rod_axis_z + slot_h/2;

  // Place slot so it opens from ONE outer face only (prevents center split).
  // Start at +X face and cut inward by slot_x, with slight overlap into the body.
  slot_center_x = bracket_width/2 - slot_x/2 + overlap;

  union() {
    difference() {
      // Main body (single solid)
      cube([bracket_width, bracket_depth, bracket_height], center=true);

      // Rod bore (through depth)
      translate([0, 0, rod_axis_z])
        rotate([90, 0, 0])
          cylinder(r=rod_r, h=bracket_depth + 2*overlap, center=true);

      // Clamp split slot: from +X outside face inward, down from top to bore axis region
      if (clamp_split)
        translate([slot_center_x, 0, slot_z])
          cube([slot_x + 2*overlap, bracket_depth + 2*overlap, slot_h], center=true);

      // Mounting holes through base thickness only (along Z)
      hole_z = -bracket_height/2 + base_thickness/2;

      if (mount_hole_count <= 1) {
        translate([0, 0, hole_z])
          cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true);
      } else if (mount_hole_count == 2) {
        for (x = [-mount_hole_spacing/2, mount_hole_spacing/2])
          translate([x, 0, hole_z])
            cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true);
      } else {
        usable_w = bracket_width - 2*mount_hole_edge_margin;
        step = (mount_hole_count > 1) ? (usable_w/(mount_hole_count-1)) : 0;
        for (i = [0:mount_hole_count-1]) {
          x = -usable_w/2 + i*step;
          translate([x, 0, hole_z])
            cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true);
        }
      }
    }
  }
}

bracket();