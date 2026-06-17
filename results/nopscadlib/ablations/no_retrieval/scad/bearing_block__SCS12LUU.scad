// Long linear bearing block for 8.0mm shaft
// Block size: 42.0mm (W) x 70.0mm (L) x 24.0mm (H)
// One connected solid; all translate() values derived from dimensions.

// ---------- Parameters ----------
$fn = 96;

block_W = 42.0; //[21.0:84.0:0.5]
block_L = 70.0; //[35.0:140.0:0.5]
block_H = 24.0; //[12.0:48.0:0.5]

shaft_d = 8.0; //[4.0:16.0:0.1]
bore_clearance = 0.2; //[0.0:0.8:0.05]

// Bearing housing (visual/functional feature around shaft bore)
housing_d = 22.0; //[14.0:30.0:0.5]     // outer "bearing" boss diameter
housing_len = 50.0; //[30.0:68.0:0.5]   // length of boss along block_L
housing_relief_d = 16.0; //[10.0:24.0:0.5] // shallow relief ring diameter
housing_relief_depth = 1.5; //[0.5:4.0:0.1]

mount_hole_d = 5.0; //[3.0:10.0:0.1]
mount_hole_spacing_L = 50.0; //[25.0:100.0:0.5]
mount_hole_spacing_W = 26.0; //[13.0:52.0:0.5]
counterbore_d = 9.0; //[6.0:16.0:0.1]
counterbore_depth = 4.0; //[2.0:10.0:0.1]

set_screw_d = 4.0; //[2.0:8.0:0.1]
set_screw_z_from_top = 6.0; //[2.0:12.0:0.1] // distance from top surface to set screw axis

grease_port_d = 3.0; //[1.5:6.0:0.1]
grease_port_z_from_top = 3.0; //[1.0:8.0:0.1] // distance from top surface to grease port axis

edge_fillet_r = 1.0; //[0.0:3.0:0.1]
op_overlap = 1.0; //[0.5:2.0:0.1]

// ---------- Helpers ----------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module filleted_box(size=[10,10,10], r=1) {
  // Minkowski fillet; keep overall size by shrinking core
  core = [max(0.01, size[0]-2*r), max(0.01, size[1]-2*r), max(0.01, size[2]-2*r)];
  minkowski() {
    cube(core, center=true);
    sphere(r=r);
  }
}

// ---------- Main solid (body + bearing boss) ----------
module body_with_boss() {
  // Ensure boss fits within block length
  boss_len = clamp(housing_len, 0.01, block_L - 2*edge_fillet_r);
  union() {
    filleted_box([block_W, block_L, block_H], edge_fillet_r);

    // Bearing housing boss on TOP surface, centered on shaft axis (Y axis)
    // Connected by overlapping into the top face by op_overlap.
    translate([0, 0, block_H/2 - op_overlap])
      rotate([90, 0, 0])
        cylinder(h=boss_len, r=housing_d/2, center=true);
  }
}

// ---------- Cutouts ----------
module shaft_bore() {
  rotate([90, 0, 0])
    cylinder(h=block_L + 2*op_overlap, r=(shaft_d + bore_clearance)/2, center=true);
}

module mount_holes() {
  for (sx = [-1, 1], sy = [-1, 1])
    translate([sx*mount_hole_spacing_W/2, sy*mount_hole_spacing_L/2, 0])
      cylinder(h=block_H + 2*op_overlap, r=mount_hole_d/2, center=true);
}

module counterbores() {
  // From TOP face downward
  zc = block_H/2 - counterbore_depth/2 + op_overlap/2;
  for (sx = [-1, 1], sy = [-1, 1])
    translate([sx*mount_hole_spacing_W/2, sy*mount_hole_spacing_L/2, zc])
      cylinder(h=counterbore_depth + op_overlap, r=counterbore_d/2, center=true);
}

module set_screw_hole() {
  // Side-to-side (X axis), aimed at shaft bore; axis located near top
  z_axis = block_H/2 - set_screw_z_from_top;
  translate([0, 0, z_axis])
    rotate([0, 90, 0])
      cylinder(h=block_W + 2*op_overlap, r=set_screw_d/2, center=true);
}

module grease_port_hole() {
  // Vertical port from TOP down to intersect shaft bore
  zc = block_H/2 - grease_port_z_from_top;
  translate([0, 0, zc])
    cylinder(h=block_H + 2*op_overlap, r=grease_port_d/2, center=true);
}

module housing_relief() {
  // Shallow circular relief on top of boss to suggest bearing seat
  // Cut only a small depth from the top surface.
  zc = block_H/2 - housing_relief_depth/2 + op_overlap/2;
  translate([0, 0, zc])
    cylinder(h=housing_relief_depth + op_overlap, r=housing_relief_d/2, center=true);
}

module all_cutouts() {
  union() {
    shaft_bore();
    mount_holes();
    counterbores();
    set_screw_hole();
    grease_port_hole();
    housing_relief();
  }
}

// ---------- Final ----------
difference() {
  body_with_boss();
  all_cutouts();
}