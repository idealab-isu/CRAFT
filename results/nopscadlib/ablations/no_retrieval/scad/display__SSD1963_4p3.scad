// LCD display 4.3" — 105.5 x 67.2 x 3.4
// Features per spec:
// - Display window: [[-50, -26.5], [50, 31.5, 0.5]]
// - Bezel relief:  [[-105.5/2, -65/2 + 1], [105.5/2, 65/2 + 1, 1]]
// - Bottom connector: [[0, -34.5], [12, -31.5]]
// Model is ONE connected solid.

$fn = 64;

// Parameters
body_L = 105.5;
body_W = 67.2;
body_H = 3.4;

origin = [0, 0, 0];

// Display window (cut)
display_win_p1 = [-50, -26.5];
display_win_p2 = [ 50,  31.5];
display_win_depth = 0.5;

// Bezel relief (cut)
bezel_relief_p1 = [-body_L/2, -65/2 + 1];   // [-52.75, -31.5]
bezel_relief_p2 = [ body_L/2,  65/2 + 1];   // [ 52.75,  33.5]
bezel_relief_depth = 1.0;

// Bottom connector (solid)
connector_p1 = [0,  -34.5];
connector_p2 = [12, -31.5];
connector_H = 1.2;
connector_overlap = 0.8; // overlap into body to guarantee connectivity

// Mounting holes (cut)
mount_hole_d = 2.4;
mount_edge_margin_x = 4.5;
mount_edge_margin_y = 4.5;

// Corner rounding
corner_round_r = 2.0;

// Helpers
function rect_size(p1, p2) = [abs(p2[0]-p1[0]), abs(p2[1]-p1[1])];
function rect_center(p1, p2) = [(p1[0]+p2[0])/2, (p1[1]+p2[1])/2];

module rounded_box(size=[10,10,2], r=1) {
  // Robust rounded rectangle prism using hull of corner cylinders
  L = size[0]; W = size[1]; H = size[2];
  rr = min(r, min(L, W)/2 - 0.001);
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(L/2-rr), sy*(W/2-rr), 0])
        cylinder(r=rr, h=H, center=true);
  }
}

module lcd_main_body() {
  difference() {
    // Main body (centered at origin)
    translate(origin)
      rounded_box([body_L, body_W, body_H], r=corner_round_r);

    // Front bezel relief cut (from front face)
    bezel_sz = rect_size(bezel_relief_p1, bezel_relief_p2);
    bezel_ct = rect_center(bezel_relief_p1, bezel_relief_p2);
    translate([origin[0] + bezel_ct[0],
               origin[1] + bezel_ct[1],
               origin[2] + body_H/2 - bezel_relief_depth/2])
      cube([bezel_sz[0], bezel_sz[1], bezel_relief_depth + 0.02], center=true);

    // Front display window cut (from front face)
    win_sz = rect_size(display_win_p1, display_win_p2);
    win_ct = rect_center(display_win_p1, display_win_p2);
    translate([origin[0] + win_ct[0],
               origin[1] + win_ct[1],
               origin[2] + body_H/2 - display_win_depth/2])
      cube([win_sz[0], win_sz[1], display_win_depth + 0.02], center=true);

    // Mounting holes (through)
    for (xsgn = [-1, 1], ysgn = [-1, 1]) {
      translate([origin[0] + xsgn*(body_L/2 - mount_edge_margin_x),
                 origin[1] + ysgn*(body_W/2 - mount_edge_margin_y),
                 origin[2]])
        cylinder(d=mount_hole_d, h=body_H + 0.5, center=true);
    }
  }
}

module bottom_connector() {
  // Ensure non-zero dimensions
  conn_sz_xy = rect_size(connector_p1, connector_p2);
  conn_L = max(conn_sz_xy[0], 0.2);
  conn_W = max(conn_sz_xy[1], 0.2);
  conn_ct = rect_center(connector_p1, connector_p2);

  // Place so its top overlaps into the body by connector_overlap
  // Body bottom is at z = -body_H/2
  // Connector top should be at z = -body_H/2 + connector_overlap
  // => center z = top - connector_H/2
  conn_center_z = origin[2] + (-body_H/2 + connector_overlap) - connector_H/2;

  translate([origin[0] + conn_ct[0],
             origin[1] + conn_ct[1],
             conn_center_z])
    cube([conn_L, conn_W, connector_H], center=true);
}

module lcd_module() {
  union() {
    lcd_main_body();
    bottom_connector();
  }
}

color([0.85, 0.85, 0.8])
lcd_module();