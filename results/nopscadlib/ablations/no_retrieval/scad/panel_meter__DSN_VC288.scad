// DSN-DC 100V 10A panel meter (improved recognizable geometry)
// One connected solid, no text. All placements derived from dimensions.

$fn = 64;

// ---------- Parameters ----------
bezel_W = 48; //[24:96:1]
bezel_H = 29; //[15:58:1]
bezel_T = 2.5; //[1.2:5:0.1]

housing_W = 45; //[22.5:90:1]
housing_H = 26; //[13:52:1]
housing_D = 24; //[12:48:1]

panel_cutout_W = 45; //[22.5:90:1]
panel_cutout_H = 26; //[13:52:1]
panel_T_min = 1; //[0.5:2:0.1]
panel_T_max = 4; //[2:8:0.1]

window_W = 36; //[18:72:1]
window_H = 14; //[7:28:1]
window_offset_Y = 0; //[-5:5:0.5]

wall_T = 1.6; //[0.8:3.2:0.1]
overlap = 1; //[0.5:2:0.1]

bezel_fillet_r = 1.2; //[0.5:3:0.1]

// Front face details (no text)
screen_recess = 0.9; //[0.2:1.6:0.1]
screen_recess_margin = 1.2; //[0.5:3:0.1]
inner_frame_T = 0.9; //[0.4:2:0.1]
inner_frame_margin = 2.2; //[1:5:0.1]
lens_T = 0.7; //[0.3:1.5:0.1]
lens_inset = 0.25; //[0.1:0.8:0.05]

// "Digit" bumps behind lens (raised segments, not text)
digit_plate_T = 0.8; //[0.4:1.6:0.1]
digit_margin = 2.0; //[1:4:0.1]
digit_cols = 3; //[2:4:1]
digit_gap = 1.2; //[0.6:2.5:0.1]
digit_seg_T = 0.55; //[0.2:1.2:0.05]
digit_seg_W = 1.2; //[0.6:2.5:0.1]
digit_seg_L = 5.2; //[3:9:0.1]

// Mounting clips
clip_count_per_side = 1; //[1:2:1]
clip_W = 6; //[3:12:0.5]
clip_H = 10; //[5:20:1]
clip_T = 1.5; //[0.8:3:0.1]
clip_overhang = 1.5; //[0.5:3:0.1]

// Rear terminal block + screws + wire exit
terminal_block_W = 22; //[10:40:1]
terminal_block_H = 12; //[5:20:1]
terminal_block_D = 9; //[4:16:1]
terminal_fillet_r = 1.0; //[0.5:2.5:0.1]

screw_term_r = 1.2; //[0.6:2.4:0.1]
screw_term_h = 3; //[1.5:6:0.5]
screw_count = 4; //[2:6:1]

wire_exit_W = 14; //[6:24:1]
wire_exit_H = 7; //[3:12:1]

// Rear connector "shroud" (typical DSN-DC rear protrusion)
connector_W = 28; //[14:50:1]
connector_H = 16; //[8:30:1]
connector_D = 6;  //[3:12:0.5]
connector_fillet_r = 1.2; //[0.5:3:0.1]

// Internal standoffs
standoff_r = 1.6; //[0.8:3.2:0.1]
standoff_h = 6; //[3:12:0.5]
standoff_inset = 5; //[3:10:0.5]

// ---------- Helpers ----------
module rounded_box(size=[10,10,10], r=1) {
  rr = min(r, min(size[0], min(size[1], size[2]))/2 - 0.01);
  minkowski() {
    cube([size[0]-2*rr, size[1]-2*rr, size[2]-2*rr], center=true);
    sphere(r=rr);
  }
}

module rounded_rect_plate(w,h,t,r) {
  translate([0,0,t/2]) rounded_box([w,h,t], r=r);
}

// ---------- Base Shapes ----------
module front_bezel_solid() {
  // Bezel sits from z=0..bezel_T
  translate([0,0,bezel_T/2])
    rounded_box([bezel_W, bezel_H, bezel_T], r=bezel_fillet_r);
}

module display_window_cut() {
  translate([0, window_offset_Y, bezel_T/2])
    cube([window_W, window_H, bezel_T + 2*overlap], center=true);
}

module screen_recess_cut() {
  recess_W = window_W + 2*screen_recess_margin;
  recess_H = window_H + 2*screen_recess_margin;
  translate([0, window_offset_Y, bezel_T - screen_recess/2 + overlap/2])
    cube([recess_W, recess_H, screen_recess + overlap], center=true);
}

module rear_housing_outer() {
  // Ensure overlap into bezel
  translate([0,0,bezel_T + housing_D/2 - overlap])
    cube([housing_W, housing_H, housing_D], center=true);
}

module rear_housing_inner_void() {
  inner_W = housing_W - 2*wall_T;
  inner_H = housing_H - 2*wall_T;
  inner_D = housing_D - wall_T; // keep front wall thickness
  translate([0,0,bezel_T + wall_T + inner_D/2 - overlap])
    cube([inner_W, inner_H, inner_D + 2*overlap], center=true);
}

module wire_exit_opening() {
  translate([0,0,bezel_T + housing_D - wall_T/2 - overlap])
    cube([wire_exit_W, wire_exit_H, wall_T + 2*overlap], center=true);
}

module panel_cutout_interface_solid() {
  zc = bezel_T + panel_T_max/2 - overlap;
  translate([0,0,zc])
    cube([panel_cutout_W, panel_cutout_H, panel_T_max], center=true);
}

// ---------- Front face details (solid additions, no text) ----------
module inner_bezel_frame_solid() {
  // Raised inner frame around the window (typical DSN-DC bezel step)
  frame_outer_W = window_W + 2*inner_frame_margin;
  frame_outer_H = window_H + 2*inner_frame_margin;
  frame_inner_W = window_W + 2*screen_recess_margin; // keep some border
  frame_inner_H = window_H + 2*screen_recess_margin;

  zc = bezel_T - inner_frame_T/2 - overlap/2; // overlap into bezel
  translate([0,0,zc])
    difference() {
      cube([frame_outer_W, frame_outer_H, inner_frame_T], center=true);
      cube([frame_inner_W, frame_inner_H, inner_frame_T + 2*overlap], center=true);
    }
}

module lens_solid() {
  // Thin "lens" plate behind the window opening, connected to bezel via overlap
  lens_W = window_W - 2*lens_inset;
  lens_H = window_H - 2*lens_inset;
  zc = bezel_T - lens_T/2 - overlap/2; // slightly into bezel thickness
  translate([0, window_offset_Y, zc])
    cube([lens_W, lens_H, lens_T], center=true);
}

module digit_plate_solid() {
  // Plate behind lens, connected to front wall (inside housing)
  plate_W = window_W - 2*digit_margin;
  plate_H = window_H - 2*digit_margin;
  // Place just behind bezel/front wall: start at bezel_T + wall_T
  zc = bezel_T + wall_T + digit_plate_T/2 - overlap;
  translate([0, window_offset_Y, zc])
    cube([plate_W, plate_H, digit_plate_T], center=true);
}

module seven_seg_digit(xc=0, yc=0, zc=0, scale=1) {
  // Simple raised segments (no text), all connected to digit plate by overlap
  segW = digit_seg_W*scale;
  segL = digit_seg_L*scale;
  segT = digit_seg_T;

  // Digit bounding box (for segment placement)
  digitW = segL + 2*segW;
  digitH = segL + 2*segW;

  // Segment centers relative to digit center
  // a (top), d (bottom), g (middle) horizontal
  // b (upper right), c (lower right), f (upper left), e (lower left) vertical
  union() {
    // a
    translate([xc, yc + (digitH/2 - segW/2), zc])
      cube([segL, segW, segT], center=true);
    // d
    translate([xc, yc - (digitH/2 - segW/2), zc])
      cube([segL, segW, segT], center=true);
    // g
    translate([xc, yc, zc])
      cube([segL, segW, segT], center=true);

    // f
    translate([xc - (digitW/2 - segW/2), yc + (digitH/4), zc])
      cube([segW, segL/2, segT], center=true);
    // e
    translate([xc - (digitW/2 - segW/2), yc - (digitH/4), zc])
      cube([segW, segL/2, segT], center=true);
    // b
    translate([xc + (digitW/2 - segW/2), yc + (digitH/4), zc])
      cube([segW, segL/2, segT], center=true);
    // c
    translate([xc + (digitW/2 - segW/2), yc - (digitH/4), zc])
      cube([segW, segL/2, segT], center=true);
  }
}

module digit_segments_solid() {
  // Place 3 digits across the window area, raised slightly above digit plate
  plate_W = window_W - 2*digit_margin;
  plate_H = window_H - 2*digit_margin;

  // Digit layout
  usable_W = plate_W;
  digitW = (digit_seg_L + 2*digit_seg_W);
  total_W = digit_cols*digitW + (digit_cols-1)*digit_gap;
  scale = min(1, usable_W / max(total_W, 0.01));

  digitW_s = digitW*scale;
  gap_s = digit_gap*scale;

  // Z: sit on top of digit plate with overlap
  zc = bezel_T + wall_T + digit_plate_T - digit_seg_T/2 + overlap/2;

  x0 = - ( (digit_cols-1)*(digitW_s + gap_s) )/2;
  for (i=[0:digit_cols-1]) {
    xi = x0 + i*(digitW_s + gap_s);
    seven_seg_digit(xc=xi, yc=window_offset_Y, zc=zc, scale=scale);
  }

  // Decimal point bump near rightmost digit (common on these modules)
  dp_r = (digit_seg_W*0.55)*scale;
  dp_x = x0 + (digit_cols-1)*(digitW_s + gap_s) + digitW_s/2 - dp_r*2;
  dp_y = window_offset_Y - ( (digit_seg_L + 2*digit_seg_W)*scale )/2 + dp_r*2;
  translate([dp_x, dp_y, zc])
    cylinder(r=dp_r, h=digit_seg_T, center=true);
}

// ---------- Rear details ----------
module rear_terminal_block() {
  // Terminal block attached to rear face of housing (connected with overlap)
  zc = bezel_T + housing_D - terminal_block_D/2 - overlap;
  translate([0,0,zc])
    rounded_box([terminal_block_W, terminal_block_H, terminal_block_D], r=terminal_fillet_r);
}

module screw_terminal_bumps() {
  // Cylindrical bumps on terminal block rear face (detail)
  // Place on the rear-most face of terminal block
  zc = bezel_T + housing_D - terminal_block_D + screw_term_h/2 - overlap;

  // Arrange screws in 2 columns x 2 rows (or more if screw_count changes)
  cols = 2;
  rows = ceil(screw_count/cols);

  xspan = terminal_block_W - 2*(terminal_fillet_r + screw_term_r + 1);
  yspan = terminal_block_H - 2*(terminal_fillet_r + screw_term_r + 1);

  xstep = (cols>1) ? (xspan/(cols-1)) : 0;
  ystep = (rows>1) ? (yspan/(rows-1)) : 0;

  for (k=[0:screw_count-1]) {
    c = k % cols;
    r = floor(k/cols);
    x = -xspan/2 + c*xstep;
    y = -yspan/2 + r*ystep;
    translate([x, y, zc])
      cylinder(r=screw_term_r, h=screw_term_h, center=true);
  }
}

module rear_connector_shroud() {
  // Larger rear protrusion around/behind terminal area (typical module back shape)
  // Connected to housing rear face with overlap
  zc = bezel_T + housing_D + connector_D/2 - overlap;
  translate([0,0,zc])
    rounded_box([connector_W, connector_H, connector_D], r=connector_fillet_r);
}

module rear_connector_cavity_cut() {
  // Shallow cavity on the rear shroud face to suggest connector recess
  // (cut into shroud only; keep model one solid)
  cav_W = connector_W - 2*(connector_fillet_r + 1.2);
  cav_H = connector_H - 2*(connector_fillet_r + 1.2);
  cav_D = connector_D*0.55;

  zc = bezel_T + housing_D + connector_D - cav_D/2 + overlap/2;
  translate([0,0,zc])
    cube([cav_W, cav_H, cav_D + overlap], center=true);
}

// ---------- Mounting clips ----------
module mounting_clip(side=1, y=0) {
  x = side*(housing_W/2 + clip_T/2 - clip_overhang);
  z = bezel_T + clip_H/2 - overlap;
  translate([x, y, z])
    cube([clip_T, clip_W, clip_H], center=true);
}

module mounting_clips() {
  if (clip_count_per_side <= 1) {
    mounting_clip(-1, 0);
    mounting_clip( 1, 0);
  } else {
    yoff = (housing_H/2 - clip_W/2 - wall_T);
    mounting_clip(-1,  yoff);
    mounting_clip(-1, -yoff);
    mounting_clip( 1,  yoff);
    mounting_clip( 1, -yoff);
  }
}

// ---------- Internal standoffs ----------
module internal_pcb_standoffs() {
  x = housing_W/2 - wall_T - standoff_inset;
  y = housing_H/2 - wall_T - standoff_inset;
  z = bezel_T + wall_T + standoff_h/2 - overlap;

  translate([-x,-y,z]) cylinder(r=standoff_r, h=standoff_h, center=true);
  translate([ x,-y,z]) cylinder(r=standoff_r, h=standoff_h, center=true);
  translate([-x, y,z]) cylinder(r=standoff_r, h=standoff_h, center=true);
  translate([ x, y,z]) cylinder(r=standoff_r, h=standoff_h, center=true);
}

// ---------- Assemblies ----------
module front_bezel() {
  difference() {
    front_bezel_solid();
    display_window_cut();
    screen_recess_cut();
  }
}

module rear_housing_shell() {
  difference() {
    rear_housing_outer();
    rear_housing_inner_void();
    wire_exit_opening();
  }
}

module complete_model() {
  // One connected solid: all parts overlap into housing/bezel by 'overlap'
  difference() {
    union() {
      front_bezel();
      rear_housing_shell();
      panel_cutout_interface_solid();

      // Front details (connected)
      inner_bezel_frame_solid();
      lens_solid();
      digit_plate_solid();
      digit_segments_solid();

      // External details (connected)
      mounting_clips();
      rear_terminal_block();
      screw_terminal_bumps();
      rear_connector_shroud();

      // Internal details (connected)
      internal_pcb_standoffs();
    }

    // Cut a recess into the rear connector shroud to suggest connector block
    rear_connector_cavity_cut();
  }
}

// ---------- Render ----------
complete_model();