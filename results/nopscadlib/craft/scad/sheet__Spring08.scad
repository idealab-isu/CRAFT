// Bi-metal saw blade sheet (single connected solid) - STRUCTURAL visibility/connectivity fix
// Goal: recognizable long thin strip with toothed edge, all connected, in-frame.

// ---------- Parameters ----------
blade_L = 300; //[150:600:1]
blade_W = 12.5; //[6:25:0.1]
blade_T = 0.65; //[0.3:1.3:0.01]

tooth_pitch = 1.4; //[0.7:2.8:0.05]
tooth_H = 1.2; //[0.6:2.4:0.05]
tooth_tip_angle = 60; //[30:90:1]

hole_d = 6.5; //[3:13:0.1]
hole_edge_offset = 12; //[6:24:0.5]
hole_spacing = 276; //[138:552:1]

edge_chamfer = 0.25; //[0.1:0.6:0.01]
gullet_r = 0.35; //[0.15:0.8:0.01]

bimetal_strip_W = 2.2; //[1:4.5:0.1]
bimetal_strip_T = 0.12; //[0.05:0.3:0.01]

tooth_set_offset = 0.25; //[0.1:0.6:0.01]
tooth_set_W = 0.5; //[0.2:1.2:0.05]

// ---------- Robust overlap for boolean connectivity ----------
overlap = 1.0;   // 1-2mm overlap for guaranteed unions
eps = 0.01;

// ---------- Helpers ----------
function clamp(x, a, b) = min(max(x, a), b);

// ---------- Base solids ----------
module blade_body_sheet() {
  cube([blade_L, blade_W, blade_T], center=true);
}

// 2D tooth profile in XY (X along blade length, Y across width)
// Base at y=0, tip at y=-tooth_H
module tooth_unit_2d() {
  half_base = tooth_H / tan(tooth_tip_angle/2);
  polygon(points=[
    [-half_base, 0],
    [ half_base, 0],
    [ 0, -tooth_H]
  ]);
}

module tooth_unit() {
  // Extrude through thickness; centered so it overlaps into blade
  linear_extrude(height=blade_T + 2*overlap, center=true)
    tooth_unit_2d();
}

module mounting_hole_cyl() {
  cylinder(r=hole_d/2, h=blade_T + 4*overlap, center=true, $fn=64);
}

// Chamfer cutters at corners (subtractive)
module edge_chamfer_corner_box() {
  cube([edge_chamfer*2, edge_chamfer*2, blade_T + 4*overlap], center=true);
}

// Visual bimetal strip as a raised layer (kept connected with overlap)
module bimetal_strip_visual_layer() {
  // Ensure it intersects the blade in Z by overlap (not floating above)
  zc = blade_T/2 + bimetal_strip_T/2 - overlap;

  // Place near tooth edge but still inside blade by overlap
  // Tooth edge is at y = -blade_W/2
  yc = -blade_W/2 + bimetal_strip_W/2 + overlap;

  translate([0, yc, zc])
    cube([blade_L, bimetal_strip_W, bimetal_strip_T], center=true);
}

// Small alternating set bumps near tooth edge (kept connected)
module tooth_set_bump() {
  // Thick enough in Z to guarantee union with blade
  cube([tooth_set_W, tooth_set_offset*2, blade_T + 2*overlap], center=true);
}

// ---------- Operations ----------
module toothed_edge() {
  // Teeth run along full length and are attached to bottom edge (-Y)
  // FIX: place teeth so they protrude OUTSIDE the blade (recognizable silhouette),
  // while still overlapping into the blade for a solid union.
  n = max(1, floor(blade_L / tooth_pitch));
  union() {
    for (i = [0:n-1]) {
      x = -blade_L/2 + tooth_pitch*(i + 0.5);

      // Tooth profile base line (y=0) should sit slightly INSIDE the blade:
      // blade bottom edge is at y = -blade_W/2
      // so set base at y = -blade_W/2 + overlap
      y = -blade_W/2 + overlap;

      translate([x, y, 0]) tooth_unit();
    }
  }
}

module blade_plus_teeth() {
  union() {
    blade_body_sheet();
    toothed_edge();
  }
}

module mounting_holes() {
  usable = blade_L - 2*hole_edge_offset;
  hs = clamp(hole_spacing, 0, usable);
  union() {
    translate([-hs/2, 0, 0]) mounting_hole_cyl();
    translate([ hs/2, 0, 0]) mounting_hole_cyl();
  }
}

module edge_chamfers() {
  union() {
    translate([ blade_L/2 - edge_chamfer,  blade_W/2 - edge_chamfer, 0]) edge_chamfer_corner_box();
    translate([-blade_L/2 + edge_chamfer,  blade_W/2 - edge_chamfer, 0]) edge_chamfer_corner_box();
    translate([ blade_L/2 - edge_chamfer, -blade_W/2 + edge_chamfer, 0]) edge_chamfer_corner_box();
    translate([-blade_L/2 + edge_chamfer, -blade_W/2 + edge_chamfer, 0]) edge_chamfer_corner_box();
  }
}

module tooth_gullet_rounding() {
  // Subtractive gullets between teeth along the tooth edge
  // FIX: keep gullets mostly in the tooth region so they don't erase the blade/teeth entirely.
  n = max(1, floor(blade_L / tooth_pitch));
  union() {
    for (i = [0:n-1]) {
      x = -blade_L/2 + tooth_pitch*(i + 1); // between tooth centers

      // Put gullet center slightly OUTSIDE the blade bottom edge so it rounds the valleys.
      // Bottom edge: -blade_W/2. Place center below it by ~gullet_r, but still intersect teeth.
      y = -blade_W/2 - (gullet_r*0.6);

      translate([x, y, 0])
        cylinder(r=gullet_r, h=blade_T + 6*overlap, center=true, $fn=48);
    }
  }
}

module tooth_set_alternation() {
  // Small bumps near tooth edge to suggest set; kept connected to blade
  n = max(1, min(ceil(blade_L/tooth_pitch), 200));
  union() {
    for (i = [0:n-1]) {
      x = -blade_L/2 + tooth_pitch*(i + 0.5);

      // Place bumps slightly inside blade from bottom edge
      y = -blade_W/2 + (tooth_set_offset + tooth_set_W/2) + overlap;

      dx = (i % 2 == 0) ? (tooth_pitch*0.15) : (-tooth_pitch*0.15);
      translate([x + dx, y, 0]) tooth_set_bump();
    }
  }
}

module blade_with_visual_layers() {
  union() {
    blade_plus_teeth();
    bimetal_strip_visual_layer();
    tooth_set_alternation();
  }
}

module final_blade() {
  difference() {
    // Main connected solid
    blade_with_visual_layers();

    // Subtractions
    mounting_holes();
    tooth_gullet_rounding();
    edge_chamfers();
  }
}

// ---------- Final Model (visible, centered at origin) ----------
final_blade();