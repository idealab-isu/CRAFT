// Parameters
shaft_diameter = 6.0; //[3.0:12.0:0.1]
block_length = 30.0; //[15.0:60.0:0.5]
block_width = 25.0; //[12.5:50.0:0.5]
block_height = 18.0; //[9.0:36.0:0.5]
bearing_outer_diameter = 12.0; //[8.0:24.0:0.1]
bearing_length = 19.0; //[10.0:38.0:0.5]
bearing_fit_clearance = 0.2; //[0.0:0.6:0.05]
mount_hole_diameter = 4.2; //[2.5:8.0:0.1]
mount_hole_spacing_x = 20.0; //[10.0:40.0:0.5]
mount_hole_spacing_y = 16.0; //[8.0:32.0:0.5]
fastener_head_recess_diameter = 8.0; //[5.0:16.0:0.1]
fastener_head_recess_depth = 3.0; //[1.0:8.0:0.1]
clamp_slot_width = 2.0; //[1.0:5.0:0.1]
clamp_screw_diameter = 3.0; //[2.0:6.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

// SCS Bearing Block
module scs_bearing_block() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Main block body (single solid)
      cube([block_length, block_width, block_height], center=true);

      // Bearing seat (along X)
      rotate([0, 90, 0])
        cylinder(r=(bearing_outer_diameter + bearing_fit_clearance)/2,
                 h=bearing_length + 2*overlap, center=true);

      // Shaft through bore (along X)
      rotate([0, 90, 0])
        cylinder(r=shaft_diameter/2,
                 h=block_length + 2*overlap, center=true);

      // Mounting holes (along Z)
      for (x = [-1, 1])
        for (y = [-1, 1])
          translate([x * mount_hole_spacing_x/2, y * mount_hole_spacing_y/2, 0])
            cylinder(r=mount_hole_diameter/2,
                     h=block_height + 2*overlap, center=true);

      // Counterbores (top face)
      for (x = [-1, 1])
        for (y = [-1, 1])
          translate([x * mount_hole_spacing_x/2,
                     y * mount_hole_spacing_y/2,
                     block_height/2 - fastener_head_recess_depth/2])
            cylinder(r=fastener_head_recess_diameter/2,
                     h=fastener_head_recess_depth + overlap, center=true);

      // Clamp slot (cuts from +Y side into the bearing seat)
      translate([0,
                 (bearing_outer_diameter + bearing_fit_clearance)/2 - clamp_slot_width/2,
                 0])
        cube([block_length + 2*overlap, clamp_slot_width, block_height + 2*overlap], center=true);

      // Clamp screw hole (across width, along Y)
      rotate([90, 0, 0])
        translate([0, 0, block_height/2 - (bearing_outer_diameter + bearing_fit_clearance)/2])
          cylinder(r=clamp_screw_diameter/2,
                   h=block_width + 2*overlap, center=true);
    }
  }
}

// Connected "hole position" markers
// FIX: Make them real attached plates (not tiny cubes) and overlap into the main body.
// This removes the floating/disconnected thin section and any visible gap.
module side_plate_marker(side=+1) { // side: +1 => +X, -1 => -X
  plate_thickness = 3.0;                 // visible thin plate
  plate_height    = block_height;        // match block height
  plate_width     = block_width;         // match block width
  attach_overlap  = 1.5;                 // 1-2mm guaranteed overlap into main body

  // Center of plate: just outside the face, but pushed in by attach_overlap so it intersects.
  x_pos = side * (block_length/2 + plate_thickness/2 - attach_overlap);

  color([0.75, 0.75, 0.77])
    translate([x_pos, 0, 0])
      cube([plate_thickness, plate_width, plate_height], center=true);
}

// SCS Bearing Block Assembly (unioned into one connected solid)
module scs_bearing_block_assembly() {
  union() {
    scs_bearing_block();

    // FIX: Replace floating markers with attached side plates that overlap the body.
    side_plate_marker(+1);
    side_plate_marker(-1);
  }
}

// Final Assembly
module assembly() {
  scs_bearing_block_assembly();
}

assembly();