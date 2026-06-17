// Parameters
thickness = 3; //[1.5:6:0.5]
dial = 1; //[0:1:1]
body_diameter = 90; //[45:180:1]
body_height = 55; //[28:110:1]
bulge_width = 42; //[21:84:1]
bulge_depth = 18; //[9:36:1]
bulge_height = 45; //[22:90:1]
shaft_diameter = 10; //[5:20:0.5]
shaft_length_above = 22; //[10:44:1]
shaft_length_below = 6; //[3:12:0.5]
mount_hole_count = 3; //[2:6:1]
mount_hole_circle_diameter = 70; //[35:140:1]
mount_hole_diameter = 5; //[3:10:0.5]
screw_shank_diameter = 4.5; //[3:8:0.5]
screw_head_diameter = 8.5; //[5:16:0.5]
screw_head_height = 3.5; //[2:7:0.5]
washer_outer_diameter = 10; //[6:20:0.5]
washer_thickness = 1.2; //[0.6:2.4:0.1]
dial_diameter = 60; //[30:120:1]
dial_thickness = 3; //[1.5:6:0.5]
knob_diameter = 28; //[14:56:1]
knob_height = 18; //[9:36:1]
overlap = 1; //[0.5:2:0.1]

$fn = 96;

// --- Helpers ---
function z_top() = body_height/2;
function z_bot() = -body_height/2;

// Variac Body with Bulge (single connected solid)
module variac_body_solid() {
  union() {
    // Main body
    cylinder(r=body_diameter/2, h=body_height, center=true);

    // Side bulge: a second cylinder blended into the main body
    // Place bulge center so it intersects main body by "overlap"
    // distance between centers = R_main + R_bulge - overlap
    bulge_r = bulge_width/2;
    center_dist = body_diameter/2 + bulge_r - overlap;

    // Use hull between two cylinders to create a smooth "peanut" body
    hull() {
      cylinder(r=body_diameter/2, h=body_height, center=true);
      translate([center_dist, 0, 0])
        cylinder(r=bulge_r, h=bulge_height, center=true);
    }

    // Ensure bulge has full height where needed (adds volume, still connected)
    translate([center_dist, 0, 0])
      cylinder(r=bulge_r, h=bulge_height, center=true);
  }
}

// Mounting holes (subtractive)
module mounting_holes_cut() {
  for (i = [0:mount_hole_count-1]) {
    rotate([0, 0, i*360/mount_hole_count])
      translate([mount_hole_circle_diameter/2, 0, 0])
        cylinder(r=mount_hole_diameter/2, h=body_height + 4*overlap, center=true, $fn=48);
  }
}

// Shaft (additive, overlaps into body so it is connected)
module shaft_solid() {
  shaft_h = body_height + shaft_length_above + shaft_length_below;
  // Center so it extends above and below body by specified amounts
  zc = (shaft_length_above - shaft_length_below)/2;
  translate([0, 0, zc])
    cylinder(r=shaft_diameter/2, h=shaft_h, center=true, $fn=64);
}

// Dial and knob (additive, overlap into body)
module dial_knob_solid() {
  if (dial) {
    // Dial face: overlap into body by "overlap"
    translate([0, 0, z_top() + dial_thickness/2 - overlap])
      cylinder(r=dial_diameter/2, h=dial_thickness, center=true, $fn=96);

    // Knob: overlap into dial by "overlap"
    translate([0, 0, z_top() + dial_thickness + knob_height/2 - 2*overlap])
      cylinder(r=knob_diameter/2, h=knob_height, center=true, $fn=64);
  }
}

// Mounting screws and washers (additive, but fused to body via overlap)
module mounting_screws_and_washers_solid() {
  // Place on top surface; ensure at least overlap into body
  stack_h = screw_head_height + washer_thickness;

  // Make shank long enough to penetrate into body by overlap
  shank_h = stack_h + 2*overlap;

  // Center of shank so its bottom goes into body by overlap
  zc_shank = z_top() + shank_h/2 - overlap;

  for (i = [0:mount_hole_count-1]) {
    rotate([0, 0, i*360/mount_hole_count])
      translate([mount_hole_circle_diameter/2, 0, 0]) {

        // Shank (fuses into body)
        translate([0, 0, zc_shank])
          cylinder(r=screw_shank_diameter/2, h=shank_h, center=true, $fn=32);

        // Head sits on top of shank; overlap into shank
        zc_head = z_top() + screw_head_height/2 - overlap;
        translate([0, 0, zc_head])
          cylinder(r=screw_head_diameter/2, h=screw_head_height, center=true, $fn=32);

        // Washer above head; overlap into head
        zc_washer = z_top() + screw_head_height + washer_thickness/2 - overlap;
        translate([0, 0, zc_washer])
          cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true, $fn=48);
      }
  }
}

// Assembly: ONE connected solid (union of all solids, with holes subtracted)
module assembly() {
  difference() {
    union() {
      variac_body_solid();
      shaft_solid();
      dial_knob_solid();
      mounting_screws_and_washers_solid();
    }
    mounting_holes_cut();
  }
}

assembly();