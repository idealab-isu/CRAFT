// SMD package target overall size: [9.90, 3.90, 1.25]
// One connected solid with visible end terminations and a shallow top recess.

$fn = 48;

// Target overall dimensions
body_length = 9.9;   //[5:20:0.1]
body_width  = 3.9;   //[2:8:0.1]
body_height = 1.25;  //[0.6:2.5:0.05]

// Visual details
marking_depth    = 0.08; //[0.02:0.2:0.01]
marking_margin_x = 1.2;  //[0.5:3:0.1]
marking_margin_y = 0.6;  //[0.3:2:0.1]

chamfer_size = 0.25; //[0.1:0.6:0.05]

// Terminations (end caps) - kept within overall length
metallization_length    = 0.9;  //[0.4:2:0.05]
metallization_inset     = 0.05; //[0:0.3:0.01]
metallization_thickness = 0.06; //[0.02:0.2:0.01]

// Small overlap to guarantee connectivity / robust booleans
overlap = 0.08; //[0.01:0.3:0.01]

// --- Helpers ---
function clamp(v, lo, hi) = min(max(v, lo), hi);

// Ensure termination length is valid and does not exceed half the body length
term_len = clamp(metallization_length, 0.2, body_length/2 - 0.05);

// --- Base shapes ---
module smd_body() {
  cube([body_length, body_width, body_height], center=true);
}

module top_marking_cut() {
  mx = max(0.01, body_length - 2*marking_margin_x);
  my = max(0.01, body_width  - 2*marking_margin_y);
  cube([mx, my, marking_depth], center=true);
}

// Chamfer cutters: remove small wedges at the 4 top corners (visible in renders)
module chamfer_cutters() {
  // Use rotated cubes to create diagonal chamfers at top corners
  for (sx = [-1, 1], sy = [-1, 1]) {
    translate([sx*(body_length/2 - chamfer_size/2),
               sy*(body_width/2  - chamfer_size/2),
               body_height/2 - chamfer_size/2])
      rotate([0,0,45])
        cube([chamfer_size*sqrt(2), chamfer_size*sqrt(2), chamfer_size + 2*overlap], center=true);
  }
}

// Termination pads: wrap around ends (top+bottom+side coverage) but stay within overall length
module metallization_pads() {
  pad_x = term_len;
  pad_y = max(0.01, body_width - 2*metallization_inset);
  pad_z = body_height + 2*metallization_thickness;

  // Place each pad so its OUTER face is flush with the body end (overall length remains body_length)
  // Center offset: body_end - pad_x/2 + small overlap into body
  xoff = (body_length/2 - pad_x/2) - overlap;

  for (sx = [-1, 1]) {
    translate([sx*xoff, 0, 0])
      cube([pad_x, pad_y, pad_z], center=true);
  }
}

// Body with marking recess and chamfers
module body_with_details() {
  difference() {
    smd_body();

    // Marking recess on top face
    translate([0, 0, body_height/2 - marking_depth/2 + overlap/2])
      top_marking_cut();

    // Top corner chamfers
    chamfer_cutters();
  }
}

// Final connected model
module complete_model() {
  union() {
    body_with_details();
    metallization_pads();
  }
}

color([0.85, 0.85, 0.8]) complete_model();