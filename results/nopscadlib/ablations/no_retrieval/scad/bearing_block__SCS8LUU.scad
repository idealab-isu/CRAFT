// Long linear bearing block for 6.0mm shaft
// Block size: 34.0mm (W, X) x 58.0mm (L, Y)
// One connected solid; all translate() values derived from dimensions.

$fn = 96;

// Parameters
block_W = 34.0; //[17.0:68.0:0.5]
block_L = 58.0; //[29.0:116.0:0.5]
block_H = 20.0; //[10.0:40.0:0.5]

shaft_d = 6.0; //[3.0:12.0:0.1]
bore_clearance = 0.2; //[0.0:0.6:0.05]

mount_hole_d = 4.2; //[2.0:8.0:0.1]
mount_hole_spacing_L = 40.0; //[20.0:80.0:0.5]
mount_hole_offset_W = 10.0; //[6.0:16.0:0.5]
mount_counterbore_d = 8.0; //[6.0:14.0:0.2]
mount_counterbore_depth = 4.0; //[2.0:8.0:0.2]

edge_chamfer_r = 0.8; //[0.0:2.0:0.1]

set_screw_d = 3.0; //[2.0:6.0:0.1]
set_screw_z_from_top = 6.0; //[3.0:12.0:0.5]

lube_port_d = 2.0; //[1.0:4.0:0.1]
lube_port_depth = 6.0; //[3.0:12.0:0.5]

op_overlap = 1.0; //[0.5:2.0:0.1]

// Visible "bearing block" features
housing_boss_d = 18.0;   // outer boss around shaft bore (top/bottom)
housing_boss_h = 6.0;    // boss height (each boss)
relief_slot_w = 2.0;     // clamp slit width
relief_slot_depth = 2.0; // how far slit cuts into boss/body

// Derived
bore_r = (shaft_d + bore_clearance)/2;
boss_r = housing_boss_d/2;

// Keep boss inside width after fillet
boss_r_eff = min(boss_r, block_W/2 - edge_chamfer_r);

// Clamp/slot depth from top: must reach into body beyond top boss
slot_cut_depth_from_top = housing_boss_h + relief_slot_depth;

// Helpers
function clamp(x, a, b) = min(max(x, a), b);

// Ensure mounting holes stay inside block
mount_x = clamp(mount_hole_offset_W, -block_W/2 + mount_counterbore_d/2 + edge_chamfer_r,
                               block_W/2 - mount_counterbore_d/2 - edge_chamfer_r);
mount_y_half = min(mount_hole_spacing_L/2, block_L/2 - mount_counterbore_d/2 - edge_chamfer_r);

// Base Shapes
module block_body_with_edge_fillet() {
  // Rounded rectangular block with exact overall size via minkowski
  minkowski() {
    cube([block_W - 2*edge_chamfer_r,
          block_L - 2*edge_chamfer_r,
          block_H - 2*edge_chamfer_r], center=true);
    sphere(r=edge_chamfer_r);
  }
}

module bearing_housing_bosses() {
  // Two bosses (top and bottom) centered on shaft axis, connected to body by overlap
  union() {
    translate([0, 0,  block_H/2 + housing_boss_h/2 - op_overlap/2])
      cylinder(h=housing_boss_h + op_overlap, r=boss_r_eff, center=true);

    translate([0, 0, -block_H/2 - housing_boss_h/2 + op_overlap/2])
      cylinder(h=housing_boss_h + op_overlap, r=boss_r_eff, center=true);
  }
}

module shaft_bore_through() {
  // Bore runs through LENGTH (Y axis)
  rotate([90, 0, 0])
    cylinder(h=block_L + 2*op_overlap, r=bore_r, center=true);
}

module mount_holes_2x() {
  // Two mounting holes along length, offset in width
  for (sy = [-1, 1]) {
    translate([mount_x, sy*mount_y_half, 0])
      cylinder(h=block_H + 2*housing_boss_h + 6*op_overlap, r=mount_hole_d/2, center=true);
  }
}

module mount_counterbores_2x() {
  // Counterbores on TOP face
  for (sy = [-1, 1]) {
    translate([mount_x, sy*mount_y_half,
               block_H/2 - mount_counterbore_depth/2 + op_overlap/2])
      cylinder(h=mount_counterbore_depth + op_overlap, r=mount_counterbore_d/2, center=true);
  }
}

module lubrication_port() {
  // Small port from TOP down toward bore
  translate([0, 0, block_H/2 - lube_port_depth/2 + op_overlap/2])
    cylinder(h=lube_port_depth + op_overlap, r=lube_port_d/2, center=true);
}

module retention_set_screw_hole() {
  // Set screw from RIGHT side (X+) into bore, located near top
  translate([0, 0, block_H/2 - set_screw_z_from_top])
    rotate([0, 90, 0])
      cylinder(h=block_W + 2*housing_boss_h + 6*op_overlap, r=set_screw_d/2, center=true);
}

module clamp_relief_slot_top() {
  // Slit from TOP down into the boss/body, runs along Y (length), centered on bore axis.
  slot_h = slot_cut_depth_from_top;
  translate([0, 0, block_H/2 - slot_h/2 + op_overlap/2])
    cube([relief_slot_w, block_L + 2*op_overlap, slot_h + op_overlap], center=true);
}

module clamp_relief_slot_bottom() {
  // Matching slit from BOTTOM up (to match typical long bearing block look)
  slot_h = slot_cut_depth_from_top;
  translate([0, 0, -block_H/2 + slot_h/2 - op_overlap/2])
    cube([relief_slot_w, block_L + 2*op_overlap, slot_h + op_overlap], center=true);
}

module all_subtractive_features() {
  union() {
    shaft_bore_through();
    mount_holes_2x();
    mount_counterbores_2x();
    lubrication_port();
    retention_set_screw_hole();
    clamp_relief_slot_top();
    clamp_relief_slot_bottom();
  }
}

// Final Output
module bearing_block_complete() {
  difference() {
    union() {
      block_body_with_edge_fillet();
      bearing_housing_bosses(); // connected via overlap
    }
    all_subtractive_features();
  }
}

color("Silver") bearing_block_complete();