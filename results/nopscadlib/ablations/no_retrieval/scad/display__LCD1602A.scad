// LCD 1602A display module (approx) - overall PCB: 71.3mm x 24.3mm
// One connected solid, no text.

// ---------- Parameters ----------
module_L = 71.3;   // PCB length (X)
module_W = 24.3;   // PCB width  (Y)
module_T = 1.6;    // PCB thickness (Z)

bezel_L = 64.0;
bezel_W = 16.0;
bezel_H = 3.0;

window_L = 56.0;
window_W = 12.0;

mount_hole_d = 3.2;
mount_hole_edge_x = 2.5;
mount_hole_edge_y = 2.0;

pin_count = 16;
pin_pitch = 2.54;
pin_d = 0.64;
pin_h = 6.0;

header_body_L = 40.64; // 16 * 2.54
header_body_W = 2.5;
header_body_H = 2.5;
header_edge_y = 2.0;
header_edge_x = 5.0;

back_comp_L = 30.0;
back_comp_W = 10.0;
back_comp_H = 3.0;
back_comp_offset_x = 0.0;
back_comp_offset_y = 0.0;

overlap = 0.8;     // intentional overlap to ensure watertight union
$fn = 48;

// ---------- Helpers ----------
module mounting_holes_cut() {
  for (x = [-1, 1], y = [-1, 1]) {
    translate([x * (module_L/2 - mount_hole_edge_x),
               y * (module_W/2 - mount_hole_edge_y),
               0])
      cylinder(h = module_T + 2*overlap, r = mount_hole_d/2, center = true);
  }
}

module pcb_solid() {
  cube([module_L, module_W, module_T], center=true);
}

module bezel_with_window() {
  // Bezel sits on top of PCB and overlaps slightly into it
  translate([0, 0, module_T/2 + bezel_H/2 - overlap])
    difference() {
      cube([bezel_L, bezel_W, bezel_H], center=true);
      // Window cutout through bezel
      cube([window_L, window_W, bezel_H + 2*overlap], center=true);
    }
}

module pin_header() {
  // Place header along bottom edge (negative Y), on top side of PCB
  header_y = -module_W/2 + header_edge_y + header_body_W/2;

  // Plastic body
  translate([-module_L/2 + header_edge_x + header_body_L/2,
             header_y,
             module_T/2 + header_body_H/2 - overlap])
    cube([header_body_L, header_body_W, header_body_H], center=true);

  // Pins: ensure they intersect the plastic body (connected solid)
  for (i = [0:pin_count-1]) {
    translate([-module_L/2 + header_edge_x + i*pin_pitch,
               header_y,
               module_T/2 + pin_h/2 - overlap])
      cylinder(h=pin_h, r=pin_d/2, center=true);
  }
}

module backside_component() {
  // Backside component touches PCB underside with overlap
  translate([back_comp_offset_x,
             back_comp_offset_y,
             -module_T/2 - back_comp_H/2 + overlap])
    cube([back_comp_L, back_comp_W, back_comp_H], center=true);
}

// ---------- Complete connected solid ----------
module complete_module() {
  union() {
    // PCB with holes cut
    difference() {
      pcb_solid();
      mounting_holes_cut();
    }

    // Bezel (connected to PCB via overlap)
    bezel_with_window();

    // Header + pins (connected to PCB via overlap)
    pin_header();

    // Backside component (connected to PCB via overlap)
    backside_component();

    // Tiny "tie" rib to guarantee single connected solid even if parameters change:
    // Connects bezel down into PCB interior (hidden under bezel footprint).
    translate([0, 0, module_T/2 - overlap/2])
      cube([bezel_L - 2, bezel_W - 2, overlap], center=true);
  }
}

complete_module();