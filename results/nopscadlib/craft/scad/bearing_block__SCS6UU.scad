// Parameters
shaft_diameter_mm = 6; //[3:12:0.1]
block_length_mm = 30; //[15:60:0.5]
block_width_mm = 25; //[12.5:50:0.5]
block_height_mm = 18; //[9:36:0.5]
bearing_outer_diameter_mm = 12; //[8:24:0.1]
bearing_length_mm = 24; //[12:40:0.5]
bore_clearance_mm = 0.2; //[0:0.6:0.05]
mount_hole_diameter_mm = 4; //[2:6:0.1]
mount_hole_edge_margin_mm = 4; //[2:8:0.5]
counterbore_diameter_mm = 7.5; //[5:12:0.1]
counterbore_depth_mm = 3; //[1:8:0.5]
slit_width_mm = 0; //[0:2:0.1]
slit_depth_mm = 10; //[4:16:0.5]
clamp_screw_diameter_mm = 3; //[2:5:0.1]
clamp_screw_head_diameter_mm = 6; //[4:10:0.1]
clamp_screw_head_depth_mm = 2.5; //[1:6:0.5]
chamfer_mm = 1; //[0:3:0.25]
overlap_mm = 1; //[0.5:2:0.1]

// --- Added/derived parameters for structural connectivity ---
attach_overlap_mm = 1.5;                 // 1–2mm overlap to guarantee merges
shaft_stub_d_mm = bearing_outer_diameter_mm; // central cylindrical element diameter (matches bearing OD)
shaft_stub_h_mm = 14;                    // visible stub length below block
post_w_mm = 10;                          // rectangular vertical post width (X)
post_d_mm = 10;                          // rectangular vertical post depth (Y)
post_h_mm = 22;                          // rectangular vertical post height (Z)

// Linear Bearing - complete geometry (visual only; not part of printed solid)
module linear_bearing() {
  color("Silver")
    difference() {
      cylinder(r=bearing_outer_diameter_mm/2, h=bearing_length_mm, center=true, $fn=64);
      cylinder(r=shaft_diameter_mm/2, h=bearing_length_mm + 2*overlap_mm, center=true, $fn=64);
    }
}

// Right Trapezoid - complete geometry (kept, but will be attached/merged)
module right_trapezoid() {
  color("DimGray")
    linear_extrude(height=block_length_mm) {
      polygon(points=[
        [0, 0],
        [block_width_mm/2, 0],
        [block_width_mm/2 - chamfer_mm, chamfer_mm],
        [0, chamfer_mm]
      ]);
    }
}

// Scs Bearing Block Hole Positions - cutters
module scs_bearing_block_hole_positions() {
  union() {
    translate([ block_length_mm/2 - mount_hole_edge_margin_mm,  block_width_mm/2 - mount_hole_edge_margin_mm, 0])
      cylinder(r=mount_hole_diameter_mm/2, h=block_height_mm + 2*overlap_mm, center=true, $fn=32);
    translate([ block_length_mm/2 - mount_hole_edge_margin_mm, -(block_width_mm/2 - mount_hole_edge_margin_mm), 0])
      cylinder(r=mount_hole_diameter_mm/2, h=block_height_mm + 2*overlap_mm, center=true, $fn=32);
    translate([-(block_length_mm/2 - mount_hole_edge_margin_mm),  block_width_mm/2 - mount_hole_edge_margin_mm, 0])
      cylinder(r=mount_hole_diameter_mm/2, h=block_height_mm + 2*overlap_mm, center=true, $fn=32);
    translate([-(block_length_mm/2 - mount_hole_edge_margin_mm), -(block_width_mm/2 - mount_hole_edge_margin_mm), 0])
      cylinder(r=mount_hole_diameter_mm/2, h=block_height_mm + 2*overlap_mm, center=true, $fn=32);
  }
}

// Fastener Counterbore or Countersink - cutters
module fastener_counterbore_or_countersink() {
  union() {
    translate([ block_length_mm/2 - mount_hole_edge_margin_mm,  block_width_mm/2 - mount_hole_edge_margin_mm,
                block_height_mm/2 - (counterbore_depth_mm + overlap_mm)/2])
      cylinder(r=counterbore_diameter_mm/2, h=counterbore_depth_mm + overlap_mm, center=true, $fn=32);

    translate([ block_length_mm/2 - mount_hole_edge_margin_mm, -(block_width_mm/2 - mount_hole_edge_margin_mm),
                block_height_mm/2 - (counterbore_depth_mm + overlap_mm)/2])
      cylinder(r=counterbore_diameter_mm/2, h=counterbore_depth_mm + overlap_mm, center=true, $fn=32);

    translate([-(block_length_mm/2 - mount_hole_edge_margin_mm),  block_width_mm/2 - mount_hole_edge_margin_mm,
                block_height_mm/2 - (counterbore_depth_mm + overlap_mm)/2])
      cylinder(r=counterbore_diameter_mm/2, h=counterbore_depth_mm + overlap_mm, center=true, $fn=32);

    translate([-(block_length_mm/2 - mount_hole_edge_margin_mm), -(block_width_mm/2 - mount_hole_edge_margin_mm),
                block_height_mm/2 - (counterbore_depth_mm + overlap_mm)/2])
      cylinder(r=counterbore_diameter_mm/2, h=counterbore_depth_mm + overlap_mm, center=true, $fn=32);
  }
}

// Bearing Retention Feature - cutters
module bearing_retention_feature() {
  union() {
    translate([0, 0, block_height_mm/2 - (slit_depth_mm + overlap_mm)/2])
      cube([block_length_mm + 2*overlap_mm, slit_width_mm, slit_depth_mm + overlap_mm], center=true);

    translate([0, 0, block_height_mm/2 - slit_depth_mm + (bearing_outer_diameter_mm/2)])
      rotate([90, 0, 0])
        cylinder(r=clamp_screw_diameter_mm/2, h=block_width_mm + 2*overlap_mm, center=true, $fn=32);

    translate([0, block_width_mm/2 - (clamp_screw_head_depth_mm + overlap_mm)/2,
               block_height_mm/2 - slit_depth_mm + (bearing_outer_diameter_mm/2)])
      rotate([90, 0, 0])
        cylinder(r=clamp_screw_head_diameter_mm/2, h=clamp_screw_head_depth_mm + overlap_mm, center=true, $fn=32);
  }
}

// Chamfers or Fillets - cutters (kept as-is)
module chamfers_or_fillets() {
  union() {
    translate([ block_length_mm/2 - chamfer_mm/2,  block_width_mm/2 - chamfer_mm/2, 0])
      cube([chamfer_mm, chamfer_mm, block_height_mm + 2*overlap_mm], center=true);
    translate([ block_length_mm/2 - chamfer_mm/2, -(block_width_mm/2 - chamfer_mm/2), 0])
      cube([chamfer_mm, chamfer_mm, block_height_mm + 2*overlap_mm], center=true);
    translate([-(block_length_mm/2 - chamfer_mm/2),  block_width_mm/2 - chamfer_mm/2, 0])
      cube([chamfer_mm, chamfer_mm, block_height_mm + 2*overlap_mm], center=true);
    translate([-(block_length_mm/2 - chamfer_mm/2), -(block_width_mm/2 - chamfer_mm/2), 0])
      cube([chamfer_mm, chamfer_mm, block_height_mm + 2*overlap_mm], center=true);
  }
}

// Main block body with all cut features (single body)
module bearing_block_body() {
  difference() {
    cube([block_length_mm, block_width_mm, block_height_mm], center=true);

    // Bearing seat through X
    rotate([0, 90, 0])
      cylinder(r=(bearing_outer_diameter_mm + bore_clearance_mm)/2,
               h=block_length_mm + 2*overlap_mm, center=true, $fn=64);

    // Mounting holes + counterbores + clamp features + chamfers
    scs_bearing_block_hole_positions();
    fastener_counterbore_or_countersink();
    bearing_retention_feature();
    chamfers_or_fillets();
  }
}

// --- Added: central cylindrical shaft/bearing element (PHYSICALLY ATTACHED) ---
module central_cyl_stub_attached() {
  // Attach to bottom face of block with 1–2mm overlap into the block
  // Block bottom is at z = -block_height/2
  translate([0, 0, -block_height_mm/2 - shaft_stub_h_mm/2 + attach_overlap_mm])
    cylinder(r=shaft_stub_d_mm/2, h=shaft_stub_h_mm, center=true, $fn=96);
}

// --- Added: rectangular vertical post/shaft segment (PHYSICALLY ATTACHED) ---
module vertical_post_attached() {
  // Attach to top face of block with 1–2mm overlap into the block
  // Block top is at z = +block_height/2
  translate([0, 0, block_height_mm/2 + post_h_mm/2 - attach_overlap_mm])
    cube([post_w_mm, post_d_mm, post_h_mm], center=true);
}

// --- Kept: right trapezoid, but now attached/merged to the top surface ---
module right_trapezoid_attached() {
  // right_trapezoid() extrudes along +Z from z=0..block_length_mm (not centered)
  // Place its base slightly inside the top of the block to guarantee union.
  translate([0, 0, block_height_mm/2 - attach_overlap_mm])
    right_trapezoid();
}

// Final single-solid assembly (all parts connected via overlap and union)
module assembly() {
  union() {
    color("Black") bearing_block_body();

    // Fix floating/attachment issues:
    color("Silver") central_cyl_stub_attached();   // central cylindrical element now merged to block
    color("DimGray") vertical_post_attached();     // rectangular post now merged to block
    color("DimGray") right_trapezoid_attached();   // ensure trapezoid is not floating

    // Optional visual bearing (kept separate; comment out for printing)
    // It is centered at origin; the block is also centered at origin.
    // linear_bearing();
  }
}

assembly();