// Display module (v3.0) - 84.5mm x 54.5mm
// Single connected solid, no floating parts, no text

$fn = 64;

// Parameters
board_L = 84.5; //[42.25:169:0.1]
board_W = 54.5; //[27.25:109:0.1]
board_T = 1.6;  //[0.8:3.2:0.1]

active_L = 70;  //[35:140:0.1]
active_W = 40;  //[20:80:0.1]
active_T = 1;   //[0.5:2:0.1]
active_offset_X = 0; //[-10:10:0.1]
active_offset_Y = 0; //[-10:10:0.1]

hole_d = 3.2; //[1.6:6.4:0.1]
hole_edge_margin = 4.5; //[2.25:9:0.1]

connector_cutout_L = 18; //[9:36:0.1]
connector_cutout_W = 6;  //[3:12:0.1]
connector_cutout_edge_inset = 0; //[0:5:0.1]

bezel_wall = 2.5;   //[1.25:5:0.1]
bezel_height = 1.2; //[0.6:2.4:0.1]

fillet_r = 3; //[1.5:6:0.1]
overlap = 0.6; //[0.5:2:0.1]

// ---------- Helpers ----------
module rounded_rect_prism(L, W, H, r, center=true) {
  // Robust rounded rectangle prism using hull of corner cylinders
  // Ensures visible geometry and avoids "subtracting fillets" mistakes.
  translate(center ? [0,0,0] : [L/2, W/2, H/2])
    hull() {
      for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(L/2 - r), sy*(W/2 - r), 0])
          cylinder(h=H, r=r, center=true);
    }
}

module hole_at(x, y) {
  translate([x, y, 0])
    cylinder(h=board_T + 4*overlap, r=hole_d/2, center=true);
}

// ---------- Main solids ----------
module pcb_solid() {
  // Rounded PCB outline (fillets are part of the solid, not subtracted)
  rounded_rect_prism(board_L, board_W, board_T, fillet_r, center=true);
}

module mounting_holes_cut() {
  x = board_L/2 - hole_edge_margin;
  y = board_W/2 - hole_edge_margin;
  union() {
    hole_at( x,  y);
    hole_at(-x,  y);
    hole_at( x, -y);
    hole_at(-x, -y);
  }
}

module connector_cutout_cut() {
  // Cutout on the +Y edge, fully intersects PCB thickness
  translate([0,
             board_W/2 - connector_cutout_edge_inset - connector_cutout_W/2,
             0])
    cube([connector_cutout_L, connector_cutout_W, board_T + 4*overlap], center=true);
}

module active_area_boss() {
  // Slightly raised boss to show thickness/detail; overlaps into PCB for connectivity
  translate([active_offset_X,
             active_offset_Y,
             board_T/2 + active_T/2 - overlap])
    cube([active_L, active_W, active_T], center=true);
}

module bezel_ring() {
  // Bezel ring around active area; overlaps into PCB for connectivity
  translate([active_offset_X,
             active_offset_Y,
             board_T/2 + bezel_height/2 - overlap])
    difference() {
      cube([active_L + 2*bezel_wall, active_W + 2*bezel_wall, bezel_height], center=true);
      cube([active_L, active_W, bezel_height + 4*overlap], center=true);
    }
}

// ---------- Complete model (ONE connected solid) ----------
module complete_model() {
  union() {
    // PCB with holes and connector cutout removed
    difference() {
      pcb_solid();
      mounting_holes_cut();
      connector_cutout_cut();
    }

    // Add raised features (connected via overlap)
    active_area_boss();
    bezel_ring();
  }
}

complete_model();