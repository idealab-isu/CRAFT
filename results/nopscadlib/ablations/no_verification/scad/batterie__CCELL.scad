// Parameters
height_mm = 50.0; //[25.0:100.0:0.1]
diameter_mm = 26.2; //[13.1:52.4:0.1]
positive_terminal_diameter_mm = 6.0; //[3.0:12.0:0.1]
positive_terminal_height_mm = 1.5; //[0.75:3.0:0.05]
negative_terminal_diameter_mm = 10.0; //[5.0:20.0:0.1]
negative_terminal_height_mm = 0.2; //[0.1:0.6:0.05]
terminal_overlap_mm = 0.8; //[0.5:2.0:0.1]

$fn = 96;

// Battery - one connected solid, oriented along Z (height)
module battery() {
  body_h = height_mm;
  body_r = diameter_mm/2;

  pos_h = positive_terminal_height_mm;
  pos_r = positive_terminal_diameter_mm/2;

  neg_h = negative_terminal_height_mm;
  neg_r = negative_terminal_diameter_mm/2;

  overlap = terminal_overlap_mm;

  // Keep overlap smaller than each terminal height to avoid inversion
  overlap_pos = min(overlap, pos_h*0.9);
  overlap_neg = min(overlap, neg_h*0.9);

  union() {
    // Main cylindrical body (50mm tall, 26.2mm diameter)
    cylinder(h=body_h, r=body_r, center=true);

    // Positive terminal (top), overlapped into body to ensure connectivity
    translate([0, 0, body_h/2 + pos_h/2 - overlap_pos])
      cylinder(h=pos_h, r=pos_r, center=true);

    // Negative terminal (bottom), overlapped into body to ensure connectivity
    translate([0, 0, -body_h/2 - neg_h/2 + overlap_neg])
      cylinder(h=neg_h, r=neg_r, center=true);
  }
}

battery();