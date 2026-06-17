// Thermistor: EPCOS B57560G104F (small bead/disc with two radial leads)
// One connected solid, no floating parts, no text/labels.

// ---------- Parameters ----------
bead_d      = 2.2;   //[1.2:4.0:0.1]  // bead/disc diameter
bead_t      = 1.6;   //[0.8:3.0:0.1]  // bead/disc thickness (along Z)
bead_edge_r = 0.25;  //[0.1:0.6:0.05] // edge rounding

lead_d      = 0.5;   //[0.25:1.0:0.05]
lead_len    = 25;    //[12.5:50:0.5]  // straight length from bead edge to end
lead_pitch  = 2.5;   //[1.25:5.0:0.1] // lead spacing (center-to-center)

lead_embed  = 0.8;   //[0.3:2.0:0.1]  // how far leads penetrate into bead (along X)
overlap     = 0.4;   //[0.1:1.5:0.05] // overlap to guarantee manifold union

$fn = 64;

// ---------- Helpers ----------
module bead_raw() {
  // Disc centered at origin, thickness along Z
  cylinder(r=bead_d/2 - bead_edge_r, h=bead_t - 2*bead_edge_r, center=true);
}

module bead() {
  // Rounded disc via minkowski
  minkowski() {
    bead_raw();
    sphere(r=bead_edge_r);
  }
}

module lead_at(yoff=0) {
  // Leads run along X, centered at y = +/- lead_pitch/2, z = 0
  // Start inside bead at x = -(bead_d/2 - lead_embed), extend outward to negative X.
  lead_total = lead_len + lead_embed;

  // Cylinder is centered, so place its center at:
  // x_center = start_x - lead_total/2 + overlap
  start_x   = -(bead_d/2 - lead_embed);
  x_center  = start_x - lead_total/2 + overlap;

  translate([x_center, yoff, 0])
    rotate([0, 90, 0])
      cylinder(r=lead_d/2, h=lead_total, center=true);
}

module complete_model() {
  union() {
    bead();
    lead_at( lead_pitch/2);
    lead_at(-lead_pitch/2);
  }
}

// ---------- Output ----------
complete_model();