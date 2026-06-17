// Rigid light strip (single connected solid) - corrected for visible, non-degenerate geometry

// Parameters
strip_L = 1000; //[500:2000:10]
strip_W = 12;   //[6:24:1]
strip_H = 3;    //[2:6:0.5]

diffuser_H = 1.5; //[0.8:3:0.1]
diffuser_W = 10;  //[6:20:0.5]

base_t = 1;     //[0.5:2:0.1]
endcap_t = 2;   //[1:6:0.5]

hole_d = 3.5;           //[2:6:0.1]
hole_edge_margin = 10;  //[5:30:1]

wire_notch_W = 6; //[3:12:0.5]
wire_notch_H = 2; //[1:4:0.5]
wire_notch_L = 6; //[3:15:0.5]

led_pitch = 16.7;        //[8:33.4:0.1]
led_d = 2.2;             //[1:4:0.1]
led_dimple_depth = 0.4;  //[0.1:1:0.05]

tape_t = 0.6;   //[0.2:1.2:0.05]
fillet_r = 0.8; //[0.2:2:0.1]
overlap = 1;    //[0.5:2:0.1]

$fn = 48;

// Helpers
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

// Keep all thicknesses valid and avoid degenerate/blank renders
eps = 0.02;

base_tt     = max(base_t, eps);
diffuser_HH = max(diffuser_H, eps);
strip_HH    = max(strip_H, base_tt + diffuser_HH + eps); // ensure positive remaining height
endcap_tt   = max(endcap_t, eps);
tape_tt     = max(tape_t, eps);

diffuser_WW = clamp(diffuser_W, eps, strip_W - eps);
hole_margin = clamp(hole_edge_margin, hole_d/2 + 2, strip_L/2 - endcap_tt - 2);

fillet_rr = clamp(fillet_r, 0, min(strip_W, strip_HH)/6);

// Derived Z layout (bottom at -strip_HH/2, top at +strip_HH/2)
z_bot = -strip_HH/2;
z_top =  strip_HH/2;

z_base_c = z_bot + base_tt/2;
z_diff_c = z_bot + base_tt + diffuser_HH/2;

// Remaining "side wall" height above diffuser to reach full strip height
sidewall_H = max(eps, strip_HH - (base_tt + diffuser_HH));
z_side_c   = z_bot + base_tt + diffuser_HH + sidewall_H/2;

// Core solids (connected)
module body_core() {
  // Base plate (full width)
  translate([0, 0, z_base_c])
    cube([strip_L, strip_W, base_tt], center=true);

  // Diffuser/lens (narrower, on top of base)
  translate([0, 0, z_diff_c - overlap/2])
    cube([strip_L, diffuser_WW, diffuser_HH + overlap], center=true);

  // Side walls above diffuser to make a rigid bar and visible cross-section
  // Left wall
  translate([0, -(diffuser_WW/2 + (strip_W - diffuser_WW)/4), z_side_c])
    cube([strip_L, (strip_W - diffuser_WW)/2 + overlap, sidewall_H], center=true);
  // Right wall
  translate([0, +(diffuser_WW/2 + (strip_W - diffuser_WW)/4), z_side_c])
    cube([strip_L, (strip_W - diffuser_WW)/2 + overlap, sidewall_H], center=true);

  // Endcaps (full height) - overlap into body to ensure connectivity
  translate([-strip_L/2 + endcap_tt/2, 0, 0])
    cube([endcap_tt + overlap, strip_W, strip_HH], center=true);

  translate([ strip_L/2 - endcap_tt/2, 0, 0])
    cube([endcap_tt + overlap, strip_W, strip_HH], center=true);

  // Adhesive tape as a raised feature on the bottom (still connected)
  tape_w = max(eps, strip_W - 2*max(fillet_rr, 0));
  tape_L = max(eps, strip_L - 2*endcap_tt - 2);
  translate([0, 0, z_bot + tape_tt/2 + overlap/2])
    cube([tape_L, tape_w, tape_tt + overlap], center=true);
}

// Subtractive features
module mount_holes() {
  // Drill through full height
  h = strip_HH + 2*overlap;

  translate([-strip_L/2 + hole_margin, 0, 0])
    cylinder(h=h, r=hole_d/2, center=true);

  translate([ strip_L/2 - hole_margin, 0, 0])
    cylinder(h=h, r=hole_d/2, center=true);
}

module wire_exit_notch() {
  // Notch cut from left end, near bottom
  translate([-strip_L/2 + wire_notch_L/2, 0, z_bot + wire_notch_H/2])
    cube([wire_notch_L + overlap, wire_notch_W, wire_notch_H + overlap], center=true);
}

module led_dimples() {
  // Dimples on top surface of diffuser area (visible LED segmentation)
  ddepth = clamp(led_dimple_depth, eps, diffuser_HH - eps);
  zc = z_bot + base_tt + diffuser_HH - ddepth/2;
  h  = ddepth + 2*overlap;

  // Compute count from length and pitch, keep away from endcaps and holes
  usable_L = max(0, strip_L - 2*(endcap_tt + hole_margin));
  n = max(1, floor(usable_L / led_pitch));

  x0 = -strip_L/2 + endcap_tt + hole_margin + led_pitch/2;

  for (i = [0:n-1]) {
    x = x0 + i*led_pitch;
    if (x < strip_L/2 - endcap_tt - hole_margin)
      translate([x, 0, zc])
        cylinder(h=h, r=led_d/2, center=true);
  }
}

// Fillet via Minkowski (kept small to avoid huge compute)
module fillet_sphere() { sphere(r=fillet_rr); }

// Main assembly: one connected solid
module strip() {
  difference() {
    if (fillet_rr > 0.001) {
      minkowski() {
        union() { body_core(); }
        fillet_sphere();
      }
    } else {
      union() { body_core(); }
    }

    mount_holes();
    wire_exit_notch();
    led_dimples();
  }
}

strip();