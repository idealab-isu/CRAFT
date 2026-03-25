// Double-ended clevis-like sleeve/rod with forked (U-shaped) open ends
// Bounding box target: 4.0 x 20.8 x 4.0 mm (X x Y x Z), elongated along X

$fn = 64;

// Parameters
L = 20.8;                 // overall length (X)
D = 4.0;                  // overall diameter / max Y,Z
slot_depth = 2.6;         // how far the U-slot goes in from each end (along X)
slot_width = 1.6;         // slot opening width (along Y)
end_land = 0.3;           // solid material at very end before slot starts (along X)
transition_len = 1.0;     // localized taper length near ends (along X)
transition_d_reduction = 0.4; // taper down near ends (diameter reduction)
tip_round = 0.25;         // small rounding on prong tips
slot_root_radius = 0.4;   // rounding at slot root
overlap = 0.6;            // boolean overlap to ensure connectivity
eps = 0.02;

// Derived
R = D/2;
Rt = (D - transition_d_reduction)/2;

// Main cylindrical body (constant diameter)
module main_body() {
  rotate([0,90,0]) cylinder(r=R, h=L - 2*transition_len, center=true);
}

// End tapers (slight reduction near ends)
module end_taper_left() {
  translate([-(L/2 - transition_len/2), 0, 0])
    rotate([0,90,0])
      cylinder(r1=Rt, r2=R, h=transition_len + overlap, center=true);
}

module end_taper_right() {
  translate([(L/2 - transition_len/2), 0, 0])
    rotate([0,90,0])
      cylinder(r1=R, r2=Rt, h=transition_len + overlap, center=true);
}

// Small end cylinders at reduced diameter to keep overall silhouette slender (no enlarged caps)
module end_stub_left() {
  translate([-(L/2 - (end_land/2)), 0, 0])
    rotate([0,90,0])
      cylinder(r=Rt, h=end_land + overlap, center=true);
}

module end_stub_right() {
  translate([(L/2 - (end_land/2)), 0, 0])
    rotate([0,90,0])
      cylinder(r=Rt, h=end_land + overlap, center=true);
}

// U-slot cutter from each end (opens at the end face, creating two prongs)
module slot_cutter_left() {
  // Center of cutter spans from x = -L/2 to x = -L/2 + end_land + slot_depth
  translate([-(L/2) + (end_land + slot_depth)/2, 0, 0])
    cube([end_land + slot_depth + overlap, slot_width, D + 2*eps], center=true);
}

module slot_cutter_right() {
  translate([(L/2) - (end_land + slot_depth)/2, 0, 0])
    cube([end_land + slot_depth + overlap, slot_width, D + 2*eps], center=true);
}

// Slot root rounding (at inner end of slot)
module slot_root_round_left() {
  translate([-(L/2) + end_land + slot_depth, 0, 0])
    rotate([90,0,0])
      cylinder(r=slot_root_radius, h=slot_width + 2*eps, center=true);
}

module slot_root_round_right() {
  translate([(L/2) - (end_land + slot_depth), 0, 0])
    rotate([90,0,0])
      cylinder(r=slot_root_radius, h=slot_width + 2*eps, center=true);
}

// Prong tip rounding: subtract small spheres at the four outer corners of the slot opening
module prong_tip_rounders() {
  // Left end (at x = -L/2)
  for (sy = [-1, 1], sz = [-1, 1])
    translate([-(L/2) + tip_round, sy*(slot_width/2), sz*(D/2)])
      sphere(r=tip_round);

  // Right end (at x = +L/2)
  for (sy = [-1, 1], sz = [-1, 1])
    translate([(L/2) - tip_round, sy*(slot_width/2), sz*(D/2)])
      sphere(r=tip_round);
}

// Final model: one connected solid with open forked ends
module final_model() {
  difference() {
    union() {
      main_body();
      end_taper_left();
      end_taper_right();
      end_stub_left();
      end_stub_right();
    }
    // Cut U-slots
    slot_cutter_left();
    slot_cutter_right();

    // Round slot roots
    slot_root_round_left();
    slot_root_round_right();

    // Round prong tips (small chamfer/round impression)
    prong_tip_rounders();
  }
}

final_model();