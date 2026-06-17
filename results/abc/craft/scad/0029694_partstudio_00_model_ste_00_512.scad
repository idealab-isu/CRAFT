// Dimension-calibrated (target: 0.11 x 0.11 x 0.02 mm)
scale([1.294118, 1.294118, 1.000000])
{
// Flat linkage bracket: central annulus + through-bore + two orthogonal forked clevis arms
// All translations are dimension-derived; model is one connected solid.

// ---------- Parameters (kept from original, but used correctly) ----------
bbox_x = 0.11;   //[0.055:0.22:0.001]
bbox_y = 0.11;   //[0.055:0.22:0.001]
bbox_z = 0.02;   //[0.01:0.04:0.001]

plate_t = 0.02;  //[0.01:0.04:0.001]

ring_od = 0.06;  //[0.03:0.11:0.001]
ring_id = 0.03;  //[0.015:0.06:0.001]
bore_d  = 0.02;  //[0.01:0.04:0.001]

arm_w   = 0.02;  //[0.01:0.04:0.001]
arm_len = 0.025; //[0.0125:0.05:0.001]

clevis_gap = 0.01;  //[0.005:0.02:0.001]
prong_w    = 0.005; //[0.0025:0.01:0.0005]

u_depth      = 0.01;  //[0.005:0.02:0.001]
u_end_radius = 0.005; //[0.0025:0.01:0.0005]

overlap = 0.001; //[0.0005:0.002:0.0001]

// ---------- Derived / safety ----------
$fn = 96;

ring_r  = ring_od/2;
arm_end = ring_r + arm_len;

// Ensure prongs exist (arm_w must be >= 2*prong_w + clevis_gap)
min_arm_w = 2*prong_w + clevis_gap;
arm_w_eff = max(arm_w, min_arm_w);

// Ensure U end radius fits inside the gap
u_r_eff = min(u_end_radius, clevis_gap/2 - 0.0001);

// ---------- Helpers ----------
module annulus(h, ro, ri) {
  difference() {
    cylinder(h=h, r=ro, center=true);
    cylinder(h=h + 2*overlap, r=ri, center=true);
  }
}

module u_slot_x() {
  // U-slot opening for +X clevis: open at the end, rounded bottom.
  // Removes material centered on X axis.
  union() {
    // rectangular throat (open end)
    translate([arm_end - u_depth/2, 0, 0])
      cube([u_depth + 2*overlap, clevis_gap, plate_t + 2*overlap], center=true);
    // rounded bottom
    translate([arm_end - u_depth, 0, 0])
      cylinder(h=plate_t + 2*overlap, r=u_r_eff, center=true);
  }
}

module u_slot_y() {
  // U-slot opening for +Y clevis: open at the end, rounded bottom.
  union() {
    translate([0, arm_end - u_depth/2, 0])
      cube([clevis_gap, u_depth + 2*overlap, plate_t + 2*overlap], center=true);
    translate([0, arm_end - u_depth, 0])
      cylinder(h=plate_t + 2*overlap, r=u_r_eff, center=true);
  }
}

module clevis_arm_x() {
  // Solid arm body (will be forked by subtracting U-slot)
  // Starts at ring outer edge and extends to arm_end.
  translate([ring_r + arm_len/2 - overlap, 0, 0])
    cube([arm_len + 2*overlap, arm_w_eff, plate_t], center=true);
}

module clevis_arm_y() {
  translate([0, ring_r + arm_len/2 - overlap, 0])
    cube([arm_w_eff, arm_len + 2*overlap, plate_t], center=true);
}

// ---------- Main geometry ----------
module main_solid() {
  // Plate-like bracket centered on annulus; no big square plate.
  union() {
    // Central ring (annulus)
    annulus(plate_t, ring_r, ring_id/2);

    // Two orthogonal arms
    clevis_arm_x();
    clevis_arm_y();
  }
}

module final_model() {
  difference() {
    main_solid();

    // Through bore
    cylinder(h=plate_t + 2*overlap, r=bore_d/2, center=true);

    // Fork openings (U-shaped) to create two-prong clevis ends
    u_slot_x();
    u_slot_y();
  }
}

// ---------- Output ----------
final_model();
}
