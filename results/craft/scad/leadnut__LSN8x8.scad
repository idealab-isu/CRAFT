// Leadscrew nut housing block: 8.0mm x 12.75mm x 19.0mm
// One connected solid (housing only). No separate leadscrew/leadnut parts.

// Parameters
block_width_mm  = 8.0;    //[4.0:16.0:0.25]   // X
block_height_mm = 12.75;  //[6.0:25.5:0.25]   // Y
block_length_mm = 19.0;   //[9.5:38.0:0.5]    // Z

clearance_mm = 0.2;       //[0.0:1.0:0.05]
chamfer_mm   = 0.5;       //[0.0:2.0:0.1]

bore_diameter_mm       = 6.0;  //[2.0:12.0:0.25]  // through-bore
nut_outer_diameter_mm  = 8.0;  //[4.0:16.0:0.25]  // counterbore/pocket diameter
nut_pocket_depth_mm    = 8.0;  //[0.0:19.0:0.5]   // pocket depth from one end along Z

mount_hole_diameter_mm = 3.0;  //[1.5:6.0:0.25]
mount_hole_spacing_mm  = 10.0; //[4.0:16.0:0.5]

overlap_mm = 1.0; //[0.5:2.0:0.1]
$fn = 64;

// Main housing (single solid with subtracted features)
module housing() {
  difference() {
    // Body
    cube([block_width_mm, block_height_mm, block_length_mm], center=true);

    // Through bore along Y (matches orthographic: circle on front/back faces)
    rotate([90, 0, 0])
      cylinder(d=bore_diameter_mm + 2*clearance_mm,
               h=block_height_mm + 2*overlap_mm,
               center=true);

    // Nut pocket (counterbore) from the -Z end, coaxial with bore, along Y
    // Positioned so pocket starts at -block_length/2 and extends +nut_pocket_depth
    translate([0, 0, -block_length_mm/2 + nut_pocket_depth_mm/2])
      rotate([90, 0, 0])
        cylinder(d=nut_outer_diameter_mm + 2*clearance_mm,
                 h=block_height_mm + 2*overlap_mm,
                 center=true);

    // Mounting holes along X, spaced along Z
    for (zpos = [-mount_hole_spacing_mm/2, mount_hole_spacing_mm/2])
      translate([0, 0, zpos])
        rotate([0, 90, 0])
          cylinder(d=mount_hole_diameter_mm,
                   h=block_width_mm + 2*overlap_mm,
                   center=true);

    // Corner chamfers (remove material at all 4 vertical edges, both ends)
    // Implemented as rotated cubes that intersect the corners.
    for (sx = [-1, 1], sz = [-1, 1])
      translate([sx*(block_width_mm/2 - chamfer_mm/2), 0, sz*(block_length_mm/2 - chamfer_mm/2)])
        rotate([0, 45, 0])
          cube([chamfer_mm, block_height_mm + 2*overlap_mm, chamfer_mm], center=true);
  }
}

housing();