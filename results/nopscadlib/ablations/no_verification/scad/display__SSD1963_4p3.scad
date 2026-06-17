// LCD display 4.3"
// Overall: 105.5 x 67.2 x 3.4
// Active/aperture: [-50,-26.5] to [50,31.5] depth 0.5
// Touch/glass outline: [-105.5/2, -65/2+1] to [105.5/2, 65/2+1] thickness 1
// Connector feature region: [[0,-34.5],[12,-31.5]]

$fn = 64;

// Parameters
overall_width = 105.5;
overall_height = 67.2;
overall_thickness = 3.4;

// Aperture (active area recess)
aperture_min_x = -50;
aperture_min_y = -26.5;
aperture_max_x = 50;
aperture_max_y = 31.5;
aperture_cut_depth = 0.5;

// Glass/touch overlay
touchscreen_min_x = -overall_width/2;
touchscreen_min_y = -65/2 + 1;   // -31.5
touchscreen_max_x =  overall_width/2;
touchscreen_max_y =  65/2 + 1;   //  33.5
touchscreen_thickness = 1.0;

// Back PCB (kept smaller than body)
pcb_width = 100;
pcb_height = 60;
pcb_thickness = 1.6;
pcb_gap = 2;

// Mounting holes (through body)
mount_hole_diameter = 3;
mount_hole_edge_margin_x = 6;
mount_hole_edge_margin_y = 6;

// Back connector bump (from given points)
connector_width = 12;
connector_height = (-31.5) - (-34.5); // 3
connector_thickness = 4;
connector_center_x = 0;
connector_center_y = (-34.5 + -31.5)/2; // -33

// Robustness
overlap = 0.6;
eps = 0.15;

// Derived
aperture_w = aperture_max_x - aperture_min_x;
aperture_h = aperture_max_y - aperture_min_y;
aperture_cx = (aperture_min_x + aperture_max_x)/2;
aperture_cy = (aperture_min_y + aperture_max_y)/2;

touch_w = touchscreen_max_x - touchscreen_min_x;
touch_h = touchscreen_max_y - touchscreen_min_y;
touch_cx = (touchscreen_min_x + touchscreen_max_x)/2;
touch_cy = (touchscreen_min_y + touchscreen_max_y)/2;

// Z layout (ensure ONE connected solid by overlapping layers)
z_body_top = overall_thickness/2;
z_body_bot = -overall_thickness/2;

// Glass overlaps into body
z_glass_center = z_body_top + touchscreen_thickness/2 - overlap;

// PCB overlaps into body (fix: previously floated due to pcb_gap)
z_pcb_center = z_body_bot - pcb_thickness/2 + overlap;

// Connector overlaps into PCB (and thus into body)
z_conn_center = z_pcb_center - pcb_thickness/2 - connector_thickness/2 + overlap;

module display_connected_solid() {
  union() {
    // Main body with recess + holes
    difference() {
      cube([overall_width, overall_height, overall_thickness], center=true);

      // Aperture recess from front face
      translate([aperture_cx, aperture_cy,
                 z_body_top - (aperture_cut_depth + eps)/2 + eps/2])
        cube([aperture_w, aperture_h, aperture_cut_depth + eps], center=true);

      // Mounting holes through body
      for (x = [-1, 1], y = [-1, 1]) {
        translate([x * (overall_width/2 - mount_hole_edge_margin_x),
                   y * (overall_height/2 - mount_hole_edge_margin_y),
                   0])
          cylinder(d=mount_hole_diameter, h=overall_thickness + 2*eps, center=true);
      }
    }

    // Glass/touch overlay
    translate([touch_cx, touch_cy, z_glass_center])
      cube([touch_w, touch_h, touchscreen_thickness], center=true);

    // Back PCB (connected to body via overlap)
    translate([0, 0, z_pcb_center])
      cube([pcb_width, pcb_height, pcb_thickness], center=true);

    // Back connector bump (connected to PCB via overlap)
    translate([connector_center_x, connector_center_y, z_conn_center])
      cube([connector_width, connector_height, connector_thickness], center=true);
  }
}

display_connected_solid();