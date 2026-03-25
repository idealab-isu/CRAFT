// Parameters
bbox_xy = 16.76; //[8.38:33.52:0.01]
bbox_z = 6.35; //[3.175:12.7:0.01]
disk_d = 12.0; //[6.0:24.0:0.01]
disk_h = 6.35; //[3.175:12.7:0.01]
lug_radial_len = 2.38; //[1.19:4.76:0.01]
lug_w = 4.2; //[2.1:8.4:0.01]
lug_h = 6.35; //[3.175:12.7:0.01]
lug_count = 4; //[4:4:1]
lug_angle_step = 90; //[90:90:1]
blend_r = 0.3; //[0.15:0.6:0.01]
overlap = 0.8; //[0.5:2.0:0.1]
chamfer_z = 0.25; //[0.1:0.6:0.01]
rounding_r = 0.25; //[0.1:0.6:0.01]
disk_r = 6.0; //[3.0:12.0:0.01]
lug_len = 2.38; //[1.19:4.76:0.01]
max_extent_r = 8.38; //[4.19:16.76:0.01]

// Main cylindrical disk
module main_cylindrical_disk() {
  cylinder(r=disk_d/2, h=disk_h, center=true);
}

// Lug at 0 degrees
module lug_0_deg() {
  translate([disk_d/2 + (lug_radial_len + overlap)/2 - overlap, 0, 0])
    cube([lug_radial_len + overlap, lug_w, lug_h], center=true);
}

// Lug at 90 degrees
module lug_90_deg() {
  translate([0, disk_d/2 + (lug_radial_len + overlap)/2 - overlap, 0])
    rotate([0, 0, 90])
    cube([lug_radial_len + overlap, lug_w, lug_h], center=true);
}

// Lug at 180 degrees
module lug_180_deg() {
  translate([-(disk_d/2 + (lug_radial_len + overlap)/2 - overlap), 0, 0])
    cube([lug_radial_len + overlap, lug_w, lug_h], center=true);
}

// Lug at 270 degrees
module lug_270_deg() {
  translate([0, -(disk_d/2 + (lug_radial_len + overlap)/2 - overlap), 0])
    rotate([0, 0, 90])
    cube([lug_radial_len + overlap, lug_w, lug_h], center=true);
}

// Lug to disk blend edges
module lug_to_disk_blend_edges() {
  sphere(r=blend_r, center=true);
}

// Top and bottom chamfer
module top_bottom_chamfer() {
  sphere(r=chamfer_z, center=true);
}

// Edge fillets
module edge_fillets() {
  sphere(r=rounding_r, center=true);
}

// Internal relief cutouts if needed for solidity
module internal_relief_cutouts_if_needed_for_solidity() {
  cylinder(r=blend_r, h=bbox_z + overlap, center=true);
}

// Bounding box limit cube
module bbox_limit_cube() {
  cube([bbox_xy, bbox_xy, bbox_z], center=true);
}

// Final model
module final_model() {
  difference() {
    intersection() {
      minkowski() {
        minkowski() {
          union() {
            main_cylindrical_disk();
            lug_0_deg();
            lug_90_deg();
            lug_180_deg();
            lug_270_deg();
          }
          lug_to_disk_blend_edges();
        }
        edge_fillets();
      }
      bbox_limit_cube();
    }
    internal_relief_cutouts_if_needed_for_solidity();
  }
}

// Render the final model
color("Silver") final_model();