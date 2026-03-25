// Dimension-calibrated (target: 10.00 x 23.00 x 6.35 mm)
scale([0.989247, 1.000000, 0.635000])
{
// Push-in fastener: head + cylindrical shank + split two-prong tapered tip
// Target bounding box: 23.0 (X length) x 10.0 (Y width) x 6.3 (Z height) mm
// Elongated along X. One connected solid.

$fn = 96;

// -------------------- Parameters --------------------
L_total = 23.0;          // overall length along X
W_max   = 10.0;          // max width (head diameter)
H_max   = 6.3;           // max height (shank diameter)

head_d = 10.0;           // head diameter
head_t = 2.2;            // head thickness along X

shank_d = 6.0;           // shank diameter
tip_L   = 6.0;           // tapered tip length along X
transition_L = 0.8;      // head-to-shank taper length

slot_w  = 1.2;           // slot width (Y)
slot_L  = 5.5;           // slot length along X (within tip)
slot_root = 0.35;        // uncut root at tip base for strength

leg_tip_d  = 4.6;        // tip diameter at end
leg_base_d = 6.0;        // tip diameter at base (matches shank)

edge_chamfer = 0.4;      // small end chamfers
overlap = 0.25;          // overlap to guarantee watertight unions

// -------------------- Derived --------------------
head_r  = min(head_d, W_max)/2;
shank_r = min(shank_d, H_max)/2;

shank_L = max(0.01, L_total - (head_t + transition_L + tip_L));

// Place model centered at origin along X
x0 = -L_total/2;                 // leftmost end
x1 =  L_total/2;                 // rightmost end

x_head_c  = x0 + head_t/2;
x_trans_c = x0 + head_t + transition_L/2;
x_shank_c = x0 + head_t + transition_L + shank_L/2;
x_tip_c   = x0 + head_t + transition_L + shank_L + tip_L/2;

x_tip_base = x0 + head_t + transition_L + shank_L; // start of tip (toward +X)

// -------------------- Modules --------------------
module head_disc() {
  translate([x_head_c, 0, 0])
    rotate([0, 90, 0])  // cylinder axis along X
      cylinder(r=head_r, h=head_t + overlap, center=true);
}

module head_to_shank_transition() {
  translate([x_trans_c, 0, 0])
    rotate([0, 90, 0])
      cylinder(r1=head_r, r2=shank_r, h=transition_L + overlap, center=true);
}

module shank_cylinder() {
  translate([x_shank_c, 0, 0])
    rotate([0, 90, 0])
      cylinder(r=shank_r, h=shank_L + overlap, center=true);
}

module tip_taper() {
  translate([x_tip_c, 0, 0])
    rotate([0, 90, 0])
      cylinder(r1=leg_base_d/2, r2=leg_tip_d/2, h=tip_L + overlap, center=true);
}

module tip_split_slot() {
  // Slot runs along X, centered in Y/Z, leaving a small uncut root at the base.
  slot_L_eff = min(slot_L, max(0.01, tip_L - slot_root));
  x_slot_c = x_tip_base + slot_root + slot_L_eff/2;

  translate([x_slot_c, 0, 0])
    cube([slot_L_eff + overlap, slot_w, leg_base_d + 2], center=true);
}

module chamfer_head_front() {
  // Chamfer at leftmost end of head (x0)
  translate([x0 + edge_chamfer/2, 0, 0])
    rotate([0, 90, 0])
      cylinder(r1=head_r, r2=max(head_r - edge_chamfer, 0.1),
               h=edge_chamfer + overlap, center=true);
}

module chamfer_tip_end() {
  // Chamfer at rightmost end of tip (x1)
  translate([x1 - edge_chamfer/2, 0, 0])
    rotate([0, 90, 0])
      cylinder(r1=max(leg_tip_d/2 - edge_chamfer, 0.1), r2=leg_tip_d/2,
               h=edge_chamfer + overlap, center=true);
}

module tip_two_prong() {
  difference() {
    tip_taper();
    tip_split_slot();
  }
}

// -------------------- Final (one connected solid) --------------------
union() {
  head_disc();
  head_to_shank_transition();
  shank_cylinder();
  tip_two_prong();
  chamfer_head_front();
  chamfer_tip_end();
}
}
