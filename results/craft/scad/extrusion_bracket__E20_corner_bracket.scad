// A extrusion bracket: [28, 28, 20]  (single connected solid)

// Parameters
width = 28; //[14:56:1]
depth = 28; //[14:56:1]
height = 20; //[10:40:1]
corner_radius = 1; //[0.5:3:0.5]
wall_thickness = 3; //[1.5:6:0.5]
relief_pocket_enabled = 1; //[0:1:1]
hole_count_per_leg = 1; //[1:2:1]
hole_diameter = 5.5; //[3:8:0.1]
hole_offset_from_edges = 9; //[5:18:0.5]
overlap = 1; //[0.5:2:0.5]
pocket_clearance = 0.5; //[0.2:1.5:0.1]
pocket_bottom_thickness = 3; //[1.5:8:0.5]

// (kept for compatibility; not used in final bracket-only output)
extrusion_size = 20; //[10:40:1]
extrusion_length = 80; //[40:200:5]
mounting_faces_X = 1; //[0:1:1]
mounting_faces_Y = 1; //[0:1:1]

$fn = 64;

// Rounded box helper (centered)
module rounded_box(sz=[10,10,10], r=1) {
  r2 = min(r, min(sz[0], min(sz[1], sz[2]))/2);
  minkowski() {
    cube([sz[0]-2*r2, sz[1]-2*r2, sz[2]-2*r2], center=true);
    sphere(r=r2);
  }
}

// L-bracket body: union of two plates (legs) with overlap to ensure connectivity
module bracket_body() {
  // Place inside corner at (0,0). Z centered at 0.
  // Leg along +X: size [width, wall_thickness, height]
  // Leg along +Y: size [wall_thickness, depth, height]
  union() {
    translate([width/2, wall_thickness/2, 0])
      rounded_box([width, wall_thickness, height], corner_radius);

    translate([wall_thickness/2, depth/2, 0])
      rounded_box([wall_thickness, depth, height], corner_radius);

    // Small fillet block at the inside corner to guarantee a robust union
    translate([wall_thickness/2, wall_thickness/2, 0])
      rounded_box([wall_thickness + 2*overlap, wall_thickness + 2*overlap, height], corner_radius);
  }
}

// Relief pocket (optional) to mimic typical extrusion bracket lightening
module relief_pocket() {
  // Pocket carved from the "outer" region, leaving walls and bottom thickness.
  // Keep pocket within the L envelope and avoid breaking through.
  pocket_h = max(0, height - pocket_bottom_thickness);
  if (pocket_h > 0) {
    translate([0, 0, -height/2 + pocket_bottom_thickness + pocket_h/2])
      union() {
        // Pocket in X-leg
        translate([width/2, wall_thickness/2, 0])
          cube([
              max(0, width - 2*(wall_thickness + pocket_clearance)),
              max(0, wall_thickness - 2*(pocket_clearance)),
              pocket_h + overlap
          ], center=true);

        // Pocket in Y-leg
        translate([wall_thickness/2, depth/2, 0])
          cube([
              max(0, wall_thickness - 2*(pocket_clearance)),
              max(0, depth - 2*(wall_thickness + pocket_clearance)),
              pocket_h + overlap
          ], center=true);
      }
  }
}

// Mounting holes (through thickness of each leg)
module mounting_holes() {
  // Hole through Y-thickness of X-leg (axis along Y)
  translate([width - hole_offset_from_edges, wall_thickness/2, 0])
    rotate([90, 0, 0])
      cylinder(d=hole_diameter, h=wall_thickness + 2*overlap, center=true);

  // Hole through X-thickness of Y-leg (axis along X)
  translate([wall_thickness/2, depth - hole_offset_from_edges, 0])
    rotate([0, 90, 0])
      cylinder(d=hole_diameter, h=wall_thickness + 2*overlap, center=true);

  // Optional second hole per leg (spaced along the long direction)
  if (hole_count_per_leg >= 2) {
    translate([hole_offset_from_edges, wall_thickness/2, 0])
      rotate([90, 0, 0])
        cylinder(d=hole_diameter, h=wall_thickness + 2*overlap, center=true);

    translate([wall_thickness/2, hole_offset_from_edges, 0])
      rotate([0, 90, 0])
        cylinder(d=hole_diameter, h=wall_thickness + 2*overlap, center=true);
  }
}

// Final bracket (single connected solid)
module extrusion_corner_bracket_3D() {
  difference() {
    bracket_body();
    if (relief_pocket_enabled) relief_pocket();
    mounting_holes();
  }
}

// Output: bracket only (no long extrusions)
extrusion_corner_bracket_3D();