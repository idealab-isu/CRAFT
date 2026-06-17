$fn = 96;

// Parameters
block_L = 30; //[15:60:1]
block_W = 25; //[12.5:50:1]
block_H = 15; //[7.5:30:1]

shaft_d = 6; //[3:12:0.1]
bore_clearance = 0.2; //[0.05:0.6:0.05]

mount_hole_d = 3.2; //[2:6:0.1]
mount_hole_spacing_L = 20; //[10:40:1]
mount_hole_offset_W = 0; //[-5:5:0.5]
mount_counterbore_d = 6.2; //[4.5:10:0.1]
mount_counterbore_depth = 3; //[1:8:0.5]

grease_port_d = 2; //[1:4:0.1]
set_screw_d = 3; //[2:6:0.1]

chamfer = 0.5; //[0.2:2:0.1]
fillet_r = 0.8; //[0.2:2.5:0.1]

overlap = 1; //[0.5:2:0.1]
minkowski_eps = 0.01; //[0.005:0.05:0.005]

// ---------- Helpers ----------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Keep fillet valid for given block size
fillet_r_eff = clamp(fillet_r, 0, min(block_L, min(block_W, block_H))/2 - 0.01);

// Keep chamfer valid for given block size
chamfer_eff = clamp(chamfer, 0, min(block_L, min(block_W, block_H))/2 - 0.01);

// Ensure mounting holes stay inside the block (account for counterbore radius + fillet)
mount_x_max = block_L/2 - max(mount_counterbore_d/2, mount_hole_d/2) - fillet_r_eff - 0.2;
mount_spacing_eff = clamp(mount_hole_spacing_L, 0, 2*mount_x_max);
mount_x1 =  mount_spacing_eff/2;
mount_x2 = -mount_spacing_eff/2;

// ---------- Base Shapes ----------
module block_body_raw() {
  cube([block_L - 2*fillet_r_eff, block_W - 2*fillet_r_eff, block_H - 2*fillet_r_eff], center=true);
}

module fillet_sphere() {
  sphere(r=fillet_r_eff);
}

// Through-bore for shaft: along WIDTH (Y axis), clearly visible in TOP/BOTTOM views
module shaft_bore_cyl() {
  rotate([90, 0, 0])
    cylinder(h=block_W + 2*overlap, r=(shaft_d + bore_clearance)/2, center=true);
}

// Lead-in chamfers at both ends of the shaft bore (still through)
module bore_lead_in_posY() {
  translate([0, block_W/2 - chamfer_eff, 0])
    rotate([90, 0, 0])
      cylinder(h=2*chamfer_eff + minkowski_eps,
               r1=(shaft_d + bore_clearance)/2 + chamfer_eff,
               r2=(shaft_d + bore_clearance)/2,
               center=true);
}

module bore_lead_in_negY() {
  translate([0, -block_W/2 + chamfer_eff, 0])
    rotate([-90, 0, 0])
      cylinder(h=2*chamfer_eff + minkowski_eps,
               r1=(shaft_d + bore_clearance)/2 + chamfer_eff,
               r2=(shaft_d + bore_clearance)/2,
               center=true);
}

module shaft_bore() {
  union() {
    shaft_bore_cyl();
    bore_lead_in_posY();
    bore_lead_in_negY();
  }
}

// Mounting holes: through HEIGHT (Z axis), two holes along LENGTH (X axis)
module mount_hole_at(xpos) {
  translate([xpos, mount_hole_offset_W, 0])
    cylinder(h=block_H + 2*overlap, r=mount_hole_d/2, center=true);
}

module counterbore_at(xpos) {
  // Counterbore from TOP face (positive Z)
  translate([xpos, mount_hole_offset_W, block_H/2 - mount_counterbore_depth/2])
    cylinder(h=mount_counterbore_depth + overlap, r=mount_counterbore_d/2, center=true);
}

module mounting_holes_2x() {
  union() {
    mount_hole_at(mount_x1);
    mount_hole_at(mount_x2);
  }
}

module counterbores_2x() {
  union() {
    counterbore_at(mount_x1);
    counterbore_at(mount_x2);
  }
}

// Grease port: from TOP down to intersect the shaft bore (Z axis)
module grease_port_hole() {
  cylinder(h=block_H + 2*overlap, r=grease_port_d/2, center=true);
}

// Set screw: from RIGHT face (positive X) toward center to intersect shaft bore (X axis)
module set_screw_hole() {
  rotate([0, 90, 0])
    cylinder(h=block_L + 2*overlap, r=set_screw_d/2, center=true);
}

module all_cutters() {
  union() {
    shaft_bore();
    mounting_holes_2x();
    counterbores_2x();
    grease_port_hole();
    set_screw_hole();
  }
}

// ---------- Final Output ----------
module block_body_fillet() {
  minkowski() {
    block_body_raw();
    fillet_sphere();
  }
}

difference() {
  block_body_fillet();
  all_cutters();
}