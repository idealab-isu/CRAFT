// Thermistor: Honeywell 135-104LAC-J01 style (radial epoxy bead with two continuous leads)
// Single connected solid; all placements derived from dimensions (no arbitrary offsets).

$fn = 64;

// -------------------- Parameters --------------------
head_d = 3.0;              //[1.5:6.0:0.1]  // epoxy bead diameter
head_h = 2.5;              //[1.25:5.0:0.1] // epoxy bead length (along lead axis)

neck_d = 1.6;              //[0.8:3.2:0.1]  // short transition/neck diameter
neck_l = 2.0;              //[1.0:4.0:0.1]  // neck length

lead_d = 0.5;              //[0.25:1.0:0.05]
lead_l = 25.0;             //[12.0:50.0:1]  // total lead length from bead exit direction
lead_pitch = 2.54;         //[1.27:5.08:0.01] // lead spacing (center-to-center)

lead_straight_l = 8.0;     //[3.0:20.0:0.5] // straight section before bend
bend_r = 1.0;              //[0.5:3.0:0.1]
bend_angle = 90;           //[0:120:1]

overlap = 0.8;             //[0.3:2.0:0.1]  // intentional overlap to guarantee connectivity
mark_flat_depth = 0.35;    //[0.1:0.8:0.05]  // flat on bead
meniscus_extra_d = 0.4;    //[0.0:1.2:0.05]
meniscus_l = 0.8;          //[0.2:2.0:0.05]
tip_chamfer_l = 0.8;       //[0.2:2.0:0.1]

// -------------------- Derived placement --------------------
// Model axis: X is lead direction (bead -> leads). Leads are offset in Y by +/- lead_pitch/2.
x_bead_center = 0;
x_bead_end    = head_h/2; // +X end of bead

x_neck_center = x_bead_end + neck_l/2 - overlap;
x_neck_end    = x_bead_end + neck_l - overlap; // where leads start (overlap into neck)

x_lead_center = x_neck_end + lead_l/2 - overlap; // overlap into neck for connectivity
x_tip_center  = x_neck_end + lead_l - tip_chamfer_l/2;

// Bend starts after straight length from neck end
x_bend_origin = x_neck_end + lead_straight_l - overlap;

// -------------------- Helpers --------------------
module x_cyl(d=1, h=1, center=true) {
  // Cylinder whose axis is X (OpenSCAD cylinder axis is Z by default)
  rotate([0, 90, 0]) cylinder(d=d, h=h, center=center);
}

// -------------------- Geometry modules --------------------
module bead_body() {
  // Rounded capsule bead along X
  hull() {
    translate([x_bead_center - (head_h/2 - head_d/2), 0, 0]) sphere(r=head_d/2);
    translate([x_bead_center + (head_h/2 - head_d/2), 0, 0]) sphere(r=head_d/2);
  }
}

module bead_flat_cut() {
  // Flat on +Z side
  translate([0, 0, head_d/2 - mark_flat_depth/2])
    cube([head_h*2, head_d*2, mark_flat_depth], center=true);
}

module neck_transition() {
  translate([x_neck_center, 0, 0])
    x_cyl(d=neck_d, h=neck_l, center=true);
}

module meniscus() {
  // Small conical meniscus between bead and neck, axis along X
  translate([x_bead_end - overlap + meniscus_l/2, 0, 0])
    rotate([0, 90, 0])
      cylinder(d1=neck_d + meniscus_extra_d, d2=0.01, h=meniscus_l, center=true);
}

module lead_straight(yoff=0) {
  translate([x_lead_center, yoff, 0])
    x_cyl(d=lead_d, h=lead_l, center=true);
}

module lead_tip_chamfer(yoff=0) {
  // Subtractive cone to chamfer the far end of the lead (axis along X)
  translate([x_tip_center, yoff, 0])
    rotate([0, 90, 0])
      cylinder(d1=lead_d, d2=0.01, h=tip_chamfer_l, center=true);
}

module lead_bend(yoff=0, sign=1) {
  // Bend arc in X-Z plane, connected at x_bend_origin.
  // rotate_extrude axis is Z; we build arc in XY then rotate into XZ.
  translate([x_bend_origin, yoff, 0])
    rotate([0, 90, 0])                 // make rotate_extrude axis align with X
      rotate([0, 0, sign*90])          // choose bend direction
        rotate_extrude(angle=bend_angle)
          translate([bend_r, 0, 0])
            circle(d=lead_d);
}

// -------------------- Assembly --------------------
module thermistor() {
  union() {
    // Body with flat
    difference() {
      bead_body();
      bead_flat_cut();
    }

    // Neck + meniscus (overlap bead)
    neck_transition();
    meniscus();

    // Leads (straight + optional bends), with chamfered tips
    difference() {
      union() {
        lead_straight(+lead_pitch/2);
        lead_straight(-lead_pitch/2);

        // Optional bends (kept connected by overlap at x_bend_origin)
        lead_bend(+lead_pitch/2, sign=1);
        lead_bend(-lead_pitch/2, sign=1);
      }
      union() {
        lead_tip_chamfer(+lead_pitch/2);
        lead_tip_chamfer(-lead_pitch/2);
      }
    }
  }
}

thermistor();