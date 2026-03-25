// Environmental sensor board (ONE connected solid)
// Target PCB: 65.0mm x 30.6mm x 1.6mm

$fn = 64;

// --- Parameters ---
board_length = 65.0;
board_width  = 30.6;
board_thickness = 1.6;

corner_radius = 2.5;

// Keep everything as ONE connected solid by ensuring overlap into PCB
overlap_z = 0.30; // overlap into PCB for all top/bottom features

// Silkscreen / copper (modeled as solids for visibility)
silk_thickness = 0.10;
silk_margin = 1.2;

copper_thickness = 0.08;

// Mounting holes
hole_radius = 1.6;
hole_inset_x = 4.0;
hole_inset_y = 4.0;
hole_extra_height = 2.0;

// Side connector "ears" (match renders: small tabs centered on left/right edges)
ear_len = 6.0;     // protrusion in X
ear_w   = 8.0;     // width in Y
ear_h   = 3.0;     // height above PCB

// Environmental sensor area (vented cap + frame)
vent_frame_l = 14.0;
vent_frame_w = 12.0;
vent_frame_h = 1.2;

vent_cap_d = 9.0;
vent_cap_h = 2.2;

vent_offset_x = 0.0; // centered like typical sensor breakout
vent_offset_y = 0.0;

// Header / connector block on one side (to look like a real board)
header_body_length = 18.0;
header_body_width  = 7.0;
header_body_height = 3.2;
header_overlap = 0.8;

pin_d = 0.9;
pin_h = 2.2;
pin_pitch = 2.54;
pin_count = 6;

// Misc components
chip1_l = 6.0;
chip1_w = 4.0;
chip1_h = 1.4;

chip2_l = 5.0;
chip2_w = 3.2;
chip2_h = 1.2;

cap_d = 3.2;
cap_h = 1.8;

// Pads
pad_length = 2.2;
pad_width  = 1.2;
pad_pitch  = 2.54;
pad_count  = 6;
pad_edge_inset = 1.0;

// Fiducials
fiducial_radius = 0.6;
fiducial_inset  = 3.0;

// --- Helpers ---
function clamp(v, lo, hi) = (v < lo) ? lo : ((v > hi) ? hi : v);

module rounded_rect_2d(l, w, r) {
  r2 = clamp(r, 0.01, min(l, w)/2 - 0.01);
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(l/2 - r2), sy*(w/2 - r2)]) circle(r=r2);
  }
}

module pcb_solid() {
  linear_extrude(height=board_thickness, center=true)
    rounded_rect_2d(board_length, board_width, corner_radius);
}

module mounting_hole_cutter(x, y) {
  translate([x, y, 0])
    cylinder(r=hole_radius, h=board_thickness + hole_extra_height, center=true);
}

module silkscreen_solid() {
  translate([0, 0, board_thickness/2 + silk_thickness/2 - overlap_z])
    linear_extrude(height=silk_thickness, center=true)
      rounded_rect_2d(board_length - 2*silk_margin,
                      board_width  - 2*silk_margin,
                      max(0.6, corner_radius-1.2));
}

module copper_pad_solid(x, y, l=pad_length, w=pad_width) {
  translate([x, y, board_thickness/2 + copper_thickness/2 - overlap_z])
    cube([l, w, copper_thickness], center=true);
}

module fiducial_solid(x, y) {
  translate([x, y, board_thickness/2 + copper_thickness/2 - overlap_z])
    cylinder(r=fiducial_radius, h=copper_thickness, center=true);
}

// Side ears centered on left/right edges (connected via overlap into PCB)
module side_ears_solid() {
  // Left ear
  translate([-board_length/2 - ear_len/2 + 1.0, 0,
             board_thickness/2 + ear_h/2 - overlap_z])
    cube([ear_len, ear_w, ear_h], center=true);

  // Right ear
  translate([ board_length/2 + ear_len/2 - 1.0, 0,
             board_thickness/2 + ear_h/2 - overlap_z])
    cube([ear_len, ear_w, ear_h], center=true);
}

// Header block near right edge (connected)
module header_solid() {
  translate([board_length/2 - header_body_length/2 + header_overlap,
             0,
             board_thickness/2 + header_body_height/2 - overlap_z])
    cube([header_body_length, header_body_width, header_body_height], center=true);

  // Pins under header, overlapping into PCB to keep one solid
  x0 = board_length/2 - header_body_length + 3.0;
  y_pin = 0;
  for (i = [0:pin_count-1]) {
    px = x0 + i*pin_pitch;
    translate([px, y_pin, board_thickness/2 - pin_h/2 + overlap_z])
      cylinder(d=pin_d, h=pin_h, center=true);
  }
}

// Environmental sensor "vented" area: frame + perforated cap (all connected)
module sensor_vent_solid() {
  // Frame
  translate([vent_offset_x, vent_offset_y,
             board_thickness/2 + vent_frame_h/2 - overlap_z])
    difference() {
      cube([vent_frame_l, vent_frame_w, vent_frame_h], center=true);
      // inner opening (through the frame only)
      cube([vent_frame_l-2.2, vent_frame_w-2.2, vent_frame_h+0.2], center=true);
    }

  // Cap (cylinder) sitting on frame/PCB
  translate([vent_offset_x, vent_offset_y,
             board_thickness/2 + vent_frame_h + vent_cap_h/2 - overlap_z])
    difference() {
      cylinder(d=vent_cap_d, h=vent_cap_h, center=true);

      // Perforation holes (do not cut through entire cap thickness to keep robustness)
      hole_d = 1.0;
      hole_h = vent_cap_h + 0.4;
      pitch = 2.2;
      for (ix = [-1, 0, 1], iy = [-1, 0, 1]) {
        // keep corners out for a "vent" look
        if (!(abs(ix)==1 && abs(iy)==1))
          translate([ix*pitch, iy*pitch, 0])
            cylinder(d=hole_d, h=hole_h, center=true);
      }
    }
}

// Misc components to make it recognizable as a sensor board (connected)
module misc_components_solid() {
  // Main MCU/IC left of center
  translate([-board_length*0.18, -6.0,
             board_thickness/2 + chip1_h/2 - overlap_z])
    cube([chip1_l, chip1_w, chip1_h], center=true);

  // Small IC near bottom-right quadrant
  translate([board_length*0.18, 7.0,
             board_thickness/2 + chip2_h/2 - overlap_z])
    cube([chip2_l, chip2_w, chip2_h], center=true);

  // Capacitors near left edge
  translate([-board_length/2 + 16.0, 7.0,
             board_thickness/2 + cap_h/2 - overlap_z])
    cylinder(d=cap_d, h=cap_h, center=true);

  translate([-board_length/2 + 20.0, -7.0,
             board_thickness/2 + cap_h/2 - overlap_z])
    cylinder(d=cap_d-0.4, h=cap_h, center=true);
}

module copper_features_solid() {
  // Left-side pads row
  xpad = -board_length/2 + pad_edge_inset + pad_length/2;
  y0 = -((pad_count-1)/2) * pad_pitch;
  for (i = [0:pad_count-1])
    copper_pad_solid(xpad, y0 + i*pad_pitch);

  // Small pads near vent area
  for (i = [0:3])
    copper_pad_solid(vent_offset_x + vent_frame_l/2 + 4.0, -4.0 + i*2.0, l=1.6, w=1.0);

  // Fiducials
  fiducial_solid(-board_length/2 + fiducial_inset,  board_width/2 - fiducial_inset);
  fiducial_solid( board_length/2 - fiducial_inset, -board_width/2 + fiducial_inset);
}

// --- Final assembly (ONE connected solid) ---
module environmental_sensor_board() {
  union() {
    // PCB with holes cut out
    difference() {
      pcb_solid();
      mounting_hole_cutter(-board_length/2 + hole_inset_x,  board_width/2 - hole_inset_y);
      mounting_hole_cutter( board_length/2 - hole_inset_x,  board_width/2 - hole_inset_y);
      mounting_hole_cutter(-board_length/2 + hole_inset_x, -board_width/2 + hole_inset_y);
      mounting_hole_cutter( board_length/2 - hole_inset_x, -board_width/2 + hole_inset_y);
    }

    // Visible layers / components (all overlap into PCB by overlap_z)
    silkscreen_solid();
    copper_features_solid();

    // Board features
    side_ears_solid();
    header_solid();
    sensor_vent_solid();
    misc_components_solid();
  }
}

environmental_sensor_board();