// Dimension-calibrated (target: 46.19 x 40.00 x 10.00 mm)
scale([1.000000, 1.000000, 0.833333])
{
// Parameters
bbox_X = 46.19; //[23.095:92.38:0.01]
bbox_Y = 40; //[20:80:0.01]
H = 10; //[5:20:0.1]
outer_hex_flat_to_flat_Y = 40; //[20:80:0.01]
outer_hex_flat_to_flat_X = 46.19; //[23.095:92.38:0.01]
hole_d = 26; //[13:52:0.1]
lug_count = 10; //[6:24:1]
lug_radial_depth = 2.2; //[1.1:4.4:0.1]
lug_tangential_w = 3; //[1.5:6:0.1]
lug_height = 10; //[5:20:0.1]
pocket_depth = 2; //[1:4:0.1]
pocket_outer_d = 34; //[17:68:0.1]
pocket_inner_d = 28; //[14:56:0.1]
overlap = 1; //[0.5:2:0.1]
edge_chamfer = 0.8; //[0.3:2:0.1]
edge_fillet_r = 0.6; //[0.3:2:0.1]
lug_lead_in = 0.6; //[0.2:1.5:0.1]

// Hexagonal Collar Body
module outer_hex_collar_body() {
  linear_extrude(height=H, center=true)
    polygon(points=[
      [outer_hex_flat_to_flat_Y/sqrt(3), 0],
      [outer_hex_flat_to_flat_Y/(2*sqrt(3)), outer_hex_flat_to_flat_Y/2],
      [-outer_hex_flat_to_flat_Y/(2*sqrt(3)), outer_hex_flat_to_flat_Y/2],
      [-outer_hex_flat_to_flat_Y/sqrt(3), 0],
      [-outer_hex_flat_to_flat_Y/(2*sqrt(3)), -outer_hex_flat_to_flat_Y/2],
      [outer_hex_flat_to_flat_Y/(2*sqrt(3)), -outer_hex_flat_to_flat_Y/2]
    ]);
}

// Central Circular Through Opening
module central_circular_through_opening() {
  cylinder(r=hole_d/2, h=H + 2*overlap, center=true);
}

// Recessed Inner Annulus Pocket
module recessed_inner_annulus_pocket() {
  difference() {
    translate([0, 0, H/2 - pocket_depth/2])
      cylinder(r=pocket_outer_d/2, h=pocket_depth + overlap, center=true);
    translate([0, 0, H/2 - pocket_depth/2])
      cylinder(r=pocket_inner_d/2, h=pocket_depth + 2*overlap, center=true);
  }
}

// Internal Rectangular Lugs with Lead-in Chamfers
module internal_rectangular_lugs_castellation() {
  hull() {
    translate([hole_d/2 - (lug_radial_depth + overlap)/2, 0, 0])
      cube([lug_radial_depth + overlap, lug_tangential_w, lug_height + 2*overlap], center=true);
    translate([hole_d/2 - (lug_radial_depth + overlap)/2 + lug_lead_in/2, 0, 0])
      cube([max(lug_radial_depth - lug_lead_in, lug_radial_depth*0.2) + overlap, max(lug_tangential_w - 2*lug_lead_in, lug_tangential_w*0.4), lug_height + 2*overlap], center=true);
  }
}

// Full Lug Assembly
module lugs() {
  union() {
    for (i = [0:lug_count-1]) {
      rotate([0, 0, i*360/lug_count])
        internal_rectangular_lugs_castellation();
    }
  }
}

// Edge Chamfer
module edge_chamfer_hex(position_z) {
  translate([0, 0, position_z])
    linear_extrude(height=edge_chamfer, center=true)
      polygon(points=[
        [(outer_hex_flat_to_flat_Y - 2*edge_chamfer)/sqrt(3), 0],
        [(outer_hex_flat_to_flat_Y - 2*edge_chamfer)/(2*sqrt(3)), (outer_hex_flat_to_flat_Y - 2*edge_chamfer)/2],
        [-(outer_hex_flat_to_flat_Y - 2*edge_chamfer)/(2*sqrt(3)), (outer_hex_flat_to_flat_Y - 2*edge_chamfer)/2],
        [-(outer_hex_flat_to_flat_Y - 2*edge_chamfer)/sqrt(3), 0],
        [-(outer_hex_flat_to_flat_Y - 2*edge_chamfer)/(2*sqrt(3)), -(outer_hex_flat_to_flat_Y - 2*edge_chamfer)/2],
        [(outer_hex_flat_to_flat_Y - 2*edge_chamfer)/(2*sqrt(3)), -(outer_hex_flat_to_flat_Y - 2*edge_chamfer)/2]
      ]);
}

// Edge Fillet Kernel
module fillet_kernel_sphere() {
  sphere(r=edge_fillet_r);
}

// Complete Model
module complete_model_no_markings() {
  difference() {
    union() {
      // Outer Hex with Edge Chamfers
      hull() {
        outer_hex_collar_body();
        edge_chamfer_hex(H/2 - edge_chamfer/2);
        edge_chamfer_hex(-H/2 + edge_chamfer/2);
      }
      // Internal Lugs
      lugs();
    }
    // Recessed Pocket
    recessed_inner_annulus_pocket();
    // Central Through Hole
    central_circular_through_opening();
  }
}

// Render the complete model
complete_model_no_markings();
}
