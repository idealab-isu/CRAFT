// Single-board computer (SBC) - 51.0mm x 21.0mm x 1.6mm
// One connected solid (no floating parts). No text/labels.

// ---------- Parameters ----------
pcb_L = 51.0;                 // length (X)
pcb_W = 21.0;                 // width  (Y)
pcb_T = 1.6;                  // thickness (Z)

hole_d = 2.7;
hole_edge_margin = 3.5;

chamfer_size = 1.0;

// Keep silkscreen as a shallow recess (doesn't break connectivity)
silk_depth = 0.05;
silk_margin = 1.5;
silk_line_w = 0.6;

// Connector placeholders (kept as solid blocks attached to PCB)
conn_usb_L = 12.0;
conn_usb_W = 8.0;
conn_usb_H = 4.0;

conn_header_L = 20.0;
conn_header_W = 5.0;
conn_header_H = 6.0;

// Small overlap to guarantee manifold union
conn_overlap = 0.8;

// Visual only
pcb_color = [0.0, 0.4, 0.2];
part_color = [0.2, 0.35, 0.55];

// ---------- Helpers ----------
module pcb_main_board() {
  color(pcb_color)
    cube([pcb_L, pcb_W, pcb_T], center=true);
}

module mount_hole_cyl(x, y) {
  translate([x, y, 0])
    cylinder(h=pcb_T*4, r=hole_d/2, center=true, $fn=48);
}

// Corner chamfer as a 45-degree wedge removed from each corner
module chamfer_wedge_at_corner(sx, sy) {
  // sx, sy are +/-1 selecting which corner
  // Place wedge so it removes material at the corner.
  translate([sx*(pcb_L/2 - chamfer_size), sy*(pcb_W/2 - chamfer_size), 0])
    rotate([0, 0, (sx==1 && sy==1) ? 0 :
                  (sx==1 && sy==-1) ? -90 :
                  (sx==-1 && sy==-1) ? 180 : 90])
      linear_extrude(height=pcb_T*4, center=true)
        polygon(points=[[0,0],[chamfer_size,0],[0,chamfer_size]]);
}

module silkscreen_recesses() {
  // A shallow recess on the top face; kept small so it doesn't cause render issues.
  translate([0, 0, pcb_T/2 - silk_depth/2]) {
    cube([pcb_L - 2*silk_margin, pcb_W - 2*silk_margin, silk_depth], center=true);
    cube([pcb_L - 2*silk_margin, silk_line_w, silk_depth], center=true);
    cube([silk_line_w, pcb_W - 2*silk_margin, silk_depth], center=true);
  }
}

// ---------- PCB operations ----------
module mounting_holes() {
  union() {
    mount_hole_cyl(-pcb_L/2 + hole_edge_margin, -pcb_W/2 + hole_edge_margin);
    mount_hole_cyl( pcb_L/2 - hole_edge_margin, -pcb_W/2 + hole_edge_margin);
    mount_hole_cyl(-pcb_L/2 + hole_edge_margin,  pcb_W/2 - hole_edge_margin);
    mount_hole_cyl( pcb_L/2 - hole_edge_margin,  pcb_W/2 - hole_edge_margin);
  }
}

module edge_chamfers() {
  union() {
    chamfer_wedge_at_corner( 1,  1);
    chamfer_wedge_at_corner( 1, -1);
    chamfer_wedge_at_corner(-1, -1);
    chamfer_wedge_at_corner(-1,  1);
  }
}

module pcb_with_features() {
  difference() {
    pcb_main_board();
    mounting_holes();
    edge_chamfers();
    silkscreen_recesses();
  }
}

// ---------- Components (connected to PCB) ----------
module conn_usb_placeholder() {
  // Attached on +X edge, centered in Y, sitting on top of PCB with overlap
  translate([
      pcb_L/2 - conn_usb_L/2 + conn_overlap,
      0,
      pcb_T/2 + conn_usb_H/2 - conn_overlap
    ])
    color(part_color)
      cube([conn_usb_L, conn_usb_W, conn_usb_H], center=true);
}

module conn_header_placeholder() {
  // Attached on +Y edge, centered in X, sitting on top of PCB with overlap
  translate([
      0,
      pcb_W/2 - conn_header_W/2 + conn_overlap,
      pcb_T/2 + conn_header_H/2 - conn_overlap
    ])
    color(part_color)
      cube([conn_header_L, conn_header_W, conn_header_H], center=true);
}

// Optional underside module to better resemble SBC while staying connected
module underside_module() {
  // A low-profile block on the bottom, attached with overlap
  mod_L = 22;
  mod_W = 9;
  mod_H = 3.2;
  translate([
      -pcb_L/2 + mod_L/2 + 6,                 // formula-based offset from edge
      -pcb_W/2 + mod_W/2 + 3,                 // formula-based offset from edge
      -pcb_T/2 - mod_H/2 + conn_overlap       // overlap into PCB
    ])
    color(part_color)
      cube([mod_L, mod_W, mod_H], center=true);
}

// ---------- Final Model (ONE connected solid) ----------
module complete_model() {
  union() {
    pcb_with_features();
    conn_usb_placeholder();
    conn_header_placeholder();
    underside_module();
  }
}

complete_model();