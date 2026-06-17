// Linear bearing block for 8.0mm shaft
// Block size: 42.0mm (X) x 36.0mm (Y) x 20.0mm (Z)
// One connected solid (bearing shown as a void only; no separate floating parts)

$fn = 96;

// Parameters
shaft_diameter_mm = 8.0; //[4.0:16.0:0.1]
block_length_mm = 42.0;  //[21.0:84.0:0.5]   // X
block_width_mm  = 36.0;  //[18.0:72.0:0.5]   // Y
block_height_mm = 20.0;  //[10.0:40.0:0.5]   // Z

tolerance_mm = 0.2; //[0.0:0.6:0.05]
overlap_mm = 1.0;   //[0.5:2.0:0.1]

// Mounting
mount_hole_diameter_mm = 5.0; //[2.5:10.0:0.1]
mount_hole_spacing_x_mm = 30.0; //[15.0:60.0:0.5]
mount_hole_spacing_y_mm = 24.0; //[12.0:48.0:0.5]
counterbore_diameter_mm = 9.0; //[6.0:16.0:0.1]
counterbore_depth_mm = 4.0; //[2.0:10.0:0.5]
edge_margin_mm = 6.0; //[3.0:12.0:0.5]

// Clamp slot (SCS-style split)
retention_slot_width_mm = 2.0;  //[1.0:5.0:0.1]
retention_slot_height_mm = 16.0; //[8.0:19.0:0.5]
retention_slot_overlap_mm = 1.0; //[0.5:2.0:0.1]

// Bottom wedge/foot (simple trapezoid rib)
wedge_base_mm = 10.0; //[5.0:20.0:0.5]
wedge_top_mm = 6.0;   //[3.0:15.0:0.5]
wedge_height_mm = 8.0; //[4.0:16.0:0.5]
wedge_thickness_mm = 6.0; //[3.0:12.0:0.5]

// Derived / safety clamps
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

bore_d = shaft_diameter_mm + tolerance_mm;

// Ensure holes stay inside block with margins
sx = clamp(mount_hole_spacing_x_mm, 0, block_length_mm - 2*edge_margin_mm);
sy = clamp(mount_hole_spacing_y_mm, 0, block_width_mm  - 2*edge_margin_mm);

// Ensure counterbore depth not exceeding block
cb_depth = clamp(counterbore_depth_mm, 0, block_height_mm - 0.5);

// Wedge placement: attached to bottom face, near -X side, with overlap
wedge_zc = -block_height_mm/2 + wedge_height_mm/2 - overlap_mm;
wedge_xc = -block_length_mm/2 + wedge_base_mm/2 - overlap_mm;

// Clamp slot placement: tangent-ish to bore on +Y side, cut through full X
slot_yc = (bore_d/2) + (retention_slot_width_mm/2) - retention_slot_overlap_mm;

// Modules
module mounting_holes() {
  for (x = [-1, 1])
    for (y = [-1, 1]) {
      translate([x*sx/2, y*sy/2, 0]) {
        // Through hole (Z axis)
        cylinder(d=mount_hole_diameter_mm, h=block_height_mm + 2*overlap_mm, center=true);

        // Counterbore from top face (Z+)
        translate([0, 0, block_height_mm/2 - cb_depth/2 + overlap_mm])
          cylinder(d=counterbore_diameter_mm, h=cb_depth + 2*overlap_mm, center=true);
      }
    }
}

module bore_through() {
  // Shaft bore along Y so it is visible in TOP/BOTTOM views
  rotate([90, 0, 0])
    cylinder(d=bore_d, h=block_width_mm + 2*overlap_mm, center=true);
}

module clamp_slot() {
  // Slot cuts along X, positioned on +Y side of bore
  translate([0, slot_yc, 0])
    cube([block_length_mm + 2*overlap_mm, retention_slot_width_mm, retention_slot_height_mm], center=true);
}

module bottom_wedge() {
  // Trapezoid extruded along Y, attached to bottom of block
  translate([wedge_xc, 0, wedge_zc])
    rotate([90, 0, 0])
      linear_extrude(height=wedge_thickness_mm, center=true)
        polygon(points=[
          [0, 0],
          [wedge_base_mm, 0],
          [wedge_top_mm, wedge_height_mm],
          [0, wedge_height_mm]
        ]);
}

module bearing_block() {
  difference() {
    union() {
      cube([block_length_mm, block_width_mm, block_height_mm], center=true);
      bottom_wedge(); // connected via calculated overlap
    }
    bore_through();
    mounting_holes();
    clamp_slot();
  }
}

bearing_block();