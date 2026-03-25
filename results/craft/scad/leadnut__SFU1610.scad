// Leadscrew nut housing block: 16.0mm x 28.0mm x 42.5mm
// One connected solid (housing only; cavities/holes are subtractive)

$fn = 80;

// ---------- Parameters ----------
block_width_mm  = 16;    // X
block_length_mm = 42.5;  // Y
block_height_mm = 28;    // Z

// Nut pocket (internal cavity for nut body)
nut_pocket_clearance_mm = 0.25;
nut_major_diameter_mm   = 12;     // across flats/OD approximation for pocket height (Z)
nut_length_mm           = 20;     // along Y
nut_pocket_depth_mm     = 14;     // into block from -X face
nut_pocket_center_z_mm  = 0;

// Leadscrew through-bore (coaxial with nut)
leadscrew_diameter_mm        = 8;
leadscrew_bore_clearance_mm  = 0.4;

// Mounting holes (through Z)
mounting_hole_diameter_mm    = 4;
mounting_hole_edge_margin_mm = 3.0;   // keep holes clearly inside 16mm width

// Counterbore/countersink from +Z face
counterbore_diameter_mm = 7.5;
counterbore_depth_mm    = 3;

use_countersink = 0; // 0=counterbore, 1=countersink
countersink_top_diameter_mm = 8;
countersink_depth_mm        = 3;

chamfer_mm = 0.6;
eps_mm = 0.25;

// ---------- Helpers ----------
module mounting_holes_through() {
  xh = block_width_mm/2  - mounting_hole_edge_margin_mm;
  yh = block_length_mm/2 - mounting_hole_edge_margin_mm;

  for (sx = [-1, 1], sy = [-1, 1])
    translate([sx*xh, sy*yh, 0])
      cylinder(d=mounting_hole_diameter_mm,
               h=block_height_mm + 2*eps_mm, center=true);
}

module counterbores_or_sinks() {
  xh = block_width_mm/2  - mounting_hole_edge_margin_mm;
  yh = block_length_mm/2 - mounting_hole_edge_margin_mm;

  if (use_countersink == 0) {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*xh, sy*yh, block_height_mm/2 - (counterbore_depth_mm + eps_mm)/2])
        cylinder(d=counterbore_diameter_mm,
                 h=counterbore_depth_mm + eps_mm, center=true);
  } else {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*xh, sy*yh, block_height_mm/2 - (countersink_depth_mm + eps_mm)/2])
        cylinder(d1=countersink_top_diameter_mm, d2=mounting_hole_diameter_mm,
                 h=countersink_depth_mm + eps_mm, center=true);
  }
}

module nut_pocket() {
  // Pocket enters from -X face; centered in Y; centered at nut_pocket_center_z_mm in Z
  pocket_x = nut_pocket_depth_mm + 2*eps_mm;
  pocket_y = nut_length_mm + 2*nut_pocket_clearance_mm;
  pocket_z = nut_major_diameter_mm + 2*nut_pocket_clearance_mm;

  // Ensure it actually opens to the -X face by overcutting past the face
  // Center X so that pocket spans from (-block_width/2 - eps) to (-block_width/2 + nut_pocket_depth)
  pocket_center_x = -block_width_mm/2 - eps_mm + pocket_x/2;

  translate([pocket_center_x, 0, nut_pocket_center_z_mm])
    cube([pocket_x, pocket_y, pocket_z], center=true);

  // Lead-in chamfer/relief at the mouth on -X face (subtractive)
  mouth_x = chamfer_mm + 2*eps_mm;
  mouth_r2 = pocket_z/2;
  mouth_r1 = mouth_r2 + chamfer_mm;

  mouth_center_x = -block_width_mm/2 - eps_mm + mouth_x/2;

  translate([mouth_center_x, 0, nut_pocket_center_z_mm])
    rotate([0, 90, 0])
      cylinder(r1=mouth_r1, r2=mouth_r2, h=mouth_x, center=true);
}

module leadscrew_bore() {
  // Through-bore along X, centered in Y and at nut_pocket_center_z_mm in Z
  translate([0, 0, nut_pocket_center_z_mm])
    rotate([0, 90, 0])
      cylinder(d=leadscrew_diameter_mm + 2*leadscrew_bore_clearance_mm,
               h=block_width_mm + 2*eps_mm, center=true);
}

// ---------- Main housing ----------
module housing_block() {
  difference() {
    // Main body (exact requested overall dimensions)
    cube([block_width_mm, block_length_mm, block_height_mm], center=true);

    // Functional cavities/holes (subtractive, connected by definition)
    nut_pocket();
    leadscrew_bore();
    mounting_holes_through();
    counterbores_or_sinks();
  }
}

housing_block();