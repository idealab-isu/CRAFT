// Units: mm

// --------------------
// Parameters
// --------------------
diameter_mm = 10.3; //[5.15:20.6:0.1]
length_mm = 28.5; //[14.25:57:0.1]
positive_terminal_diameter_mm = 4; //[2:8:0.1]
positive_terminal_height_mm = 1; //[0.5:2:0.1]
negative_terminal_recess_mm = 0; //[0:2.06:0.1]
edge_fillet_radius_mm = 0.3; //[0:1:0.05]  // Not used (fillets avoided)
overlap_mm = 0.8; //[0.5:2:0.1]

body_length_mm = 27.5; //[13.75:55:0.1]  // Derived: length_mm - positive_terminal_height_mm
body_radius_mm = 5.15; //[2.575:10.3:0.05] // Derived: diameter_mm/2
pos_radius_mm = 2; //[1:4:0.05] // Derived: positive_terminal_diameter_mm/2

$fn=32;

// --------------------
// Helpers
// --------------------
module ring2d(ro, ri) {
  difference() {
    circle(r=ro);
    circle(r=ri);
  }
}

// --------------------
// [MANDATORY] Battery - detailed reference geometry
// --------------------
module battery() {
  // Simple but recognizable: main can + positive button + thin top cap ring + optional negative recess
  color([0.78, 0.80, 0.82])  // steel/aluminum can look
  difference() {
    union() {
      // battery_body
      translate([0, 0, -positive_terminal_height_mm/2])
        cylinder(r=body_radius_mm, h=body_length_mm, center=true);

      // positive_terminal_bump
      translate([0, 0, length_mm/2 - positive_terminal_height_mm/2])
        cylinder(r=pos_radius_mm, h=positive_terminal_height_mm, center=true);

      // negative_terminal_flat (overlap to guarantee connectivity)
      translate([0, 0, -length_mm/2 + overlap_mm/2])
        cylinder(r=body_radius_mm, h=overlap_mm, center=true);

      // subtle positive-end cap ring (visual detail, very thin)
      // placed just below the bump on the positive end
      translate([0, 0, length_mm/2 - positive_terminal_height_mm - 0.25])
        linear_extrude(height=0.5, center=true)
          ring2d(ro=body_radius_mm, ri=max(body_radius_mm - 0.35, 0.01));
    }

    // negative_terminal_recess_cutter (0 disables)
    if (negative_terminal_recess_mm > 0)
      translate([0, 0, -length_mm/2 + negative_terminal_recess_mm/2])
        cylinder(r=body_radius_mm*0.6, h=negative_terminal_recess_mm, center=true);
  }

  // Slightly different color for the positive button (often plated)
  color([0.85, 0.83, 0.78])
    translate([0, 0, length_mm/2 - positive_terminal_height_mm/2])
      cylinder(r=pos_radius_mm*0.92, h=positive_terminal_height_mm*0.9, center=true);
}

// --------------------
// Assembly
// --------------------
module assembly() {
  battery();
}

assembly();