$fn = 96;

// Target overall bounding size (X,Y,Z)
overall_length = 38;   // X
overall_width  = 31;   // Y
thickness      = 8.5;  // Z

// Bracket geometry (L-shape)
inner_corner_cutout_size = 18;   // square removed from one corner to form the L

// Mounting holes
hole_diameter = 5.5;
hole_center_offset_from_inner_corner = 12; // from inner corner along each leg

// Edge details
inner_corner_radius = 2;   // inside corner fillet radius (2D)
edge_chamfer = 1;          // top-edge chamfer (approx)

// Robust booleans + guaranteed physical attachment overlap
eps = 0.2;
attach_overlap = 1.5;      // 1–2mm overlap to guarantee connection

module chamfer_top_edges(x, y, z, c) {
  difference() {
    children();

    // Along +X edge (full Y)
    translate([ x/2 - c/2, 0, z/2 - c/2 ])
      rotate([0, 90, 0])
        linear_extrude(height = x + 2*eps, center = true)
          polygon(points=[[0,0],[c,0],[0,c]]);

    // Along -X edge (full Y)
    translate([ -x/2 + c/2, 0, z/2 - c/2 ])
      rotate([0, -90, 0])
        linear_extrude(height = x + 2*eps, center = true)
          polygon(points=[[0,0],[c,0],[0,c]]);

    // Along +Y edge (full X)
    translate([ 0, y/2 - c/2, z/2 - c/2 ])
      rotate([-90, 0, 0])
        linear_extrude(height = y + 2*eps, center = true)
          polygon(points=[[0,0],[c,0],[0,c]]);

    // Along -Y edge (full X)
    translate([ 0, -y/2 + c/2, z/2 - c/2 ])
      rotate([90, 0, 0])
        linear_extrude(height = y + 2*eps, center = true)
          polygon(points=[[0,0],[c,0],[0,c]]);
  }
}

module extrusion_bracket() {

  // Inner corner (where the cutout starts) in XY, for consistent placement
  inner_x = overall_length/2 - inner_corner_cutout_size;
  inner_y = overall_width/2  - inner_corner_cutout_size;

  chamfer_top_edges(overall_length, overall_width, thickness, edge_chamfer)
  difference() {

    // --- SOLID BODY (unioned) ---
    // Build the L as two rectangles that OVERLAP by 1–2mm at the joint.
    // This fixes the "right-side plate/arm floating" and the visible gap/step.
    union() {
      // X-leg: full length in X, reduced width in Y (bottom band)
      // Centered so its top edge reaches inner_y, plus overlap into the Y-leg.
      translate([
        0,
        (-overall_width/2 + inner_y)/2 - attach_overlap/2,
        0
      ])
        cube([
          overall_length,
          (overall_width - inner_corner_cutout_size) + attach_overlap,
          thickness
        ], center=true);

      // Y-leg: full width in Y, reduced length in X (left band)
      // Centered so its right edge reaches inner_x, plus overlap into the X-leg.
      translate([
        (-overall_length/2 + inner_x)/2 - attach_overlap/2,
        0,
        0
      ])
        cube([
          (overall_length - inner_corner_cutout_size) + attach_overlap,
          overall_width,
          thickness
        ], center=true);
    }

    // --- Inside corner fillet: remove a quarter-cylinder at the inner corner of the L ---
    translate([ inner_x, inner_y, 0 ])
      difference() {
        translate([inner_corner_radius/2, inner_corner_radius/2, 0])
          cube([inner_corner_radius + 2*eps, inner_corner_radius + 2*eps, thickness + 2*eps], center=true);

        translate([inner_corner_radius, inner_corner_radius, 0])
          cylinder(r=inner_corner_radius, h=thickness + 4*eps, center=true);
      }

    // --- Two through holes, measured from the inner corner along each leg ---
    // Hole on X-leg (to the left of inner corner, centered in remaining Y leg thickness)
    translate([
      inner_x - hole_center_offset_from_inner_corner,
      inner_y/2,
      0
    ])
      cylinder(r=hole_diameter/2, h=thickness + 2*eps, center=true);

    // Hole on Y-leg (below inner corner, centered in remaining X leg thickness)
    translate([
      inner_x/2,
      inner_y - hole_center_offset_from_inner_corner,
      0
    ])
      cylinder(r=hole_diameter/2, h=thickness + 2*eps, center=true);
  }
}

extrusion_bracket();