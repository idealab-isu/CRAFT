// Parameters (mm)
primary_dimension = 39.14; //[19.57:78.28:0.01]
flange_width_mm = 39.14; //[19.57:78.28:0.01]
flange_height_mm = 12.55; //[6.275:25.1:0.01]
flange_thickness_mm = 1.12; //[0.56:2.24:0.01]
mounting_hole_pitch_mm = 33.32; //[16.66:66.64:0.01]
mounting_hole_diameter_mm = 3.2; //[1.6:6.4:0.01]
pin_pitch_mm = 2.29; //[1.145:4.58:0.01]
row_pitch_mm = 1.98; //[0.99:3.96:0.01]
pin_length_mm = 6; //[3:12:0.01]
pin_width_mm = 0.64; //[0.32:1.28:0.01]
edge_margin_mm = 2; //[1:4:0.01]
overlap_mm = 0.6; //[0.2:1.2:0.01]
hole_clearance_z_mm = 0.4; //[0.1:1:0.01]

// Quality
$fn=32;

// ---------- Helpers ----------
module rounded_rect_2d(w, h, r) {
  r2 = min(r, min(w, h)/2);
  hull() {
    translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
    translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
    translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
    translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
  }
}

// ---------- [MANDATORY] Detailed Pin Geometry ----------
module pin(len=pin_length_mm, w=pin_width_mm) {
  // Realistic "square post" pin with slight taper tip and small shoulder at base.
  // Oriented along +Z, centered at origin (matches plan's centered box usage).
  color([0.85, 0.72, 0.25]) { // gold/brass-like
    shoulder_h = max(0.25, min(0.6, len*0.12));
    tip_h      = max(0.35, min(1.2, len*0.18));
    body_h     = max(0.01, len - shoulder_h - tip_h);

    // Base shoulder (slightly wider)
    translate([0,0,-len/2 + shoulder_h/2])
      cube([w*1.15, w*1.15, shoulder_h], center=true);

    // Main square post
    translate([0,0,-len/2 + shoulder_h + body_h/2])
      cube([w, w, body_h], center=true);

    // Tapered/chamfered tip (square-to-smaller-square frustum)
    translate([0,0, len/2 - tip_h/2])
      linear_extrude(height=tip_h, center=true, scale=0.55)
        square([w, w], center=true);

    // Tiny end nub to catch highlights
    translate([0,0, len/2 - 0.12])
      cylinder(d=max(0.12, w*0.35), h=0.24, center=true, $fn=24);
  }
}

// ---------- Base Shapes from Plan ----------
module flange_plate() {
  color([0.75, 0.75, 0.77]) // aluminum/silver
    cube([flange_width_mm, flange_height_mm, flange_thickness_mm], center=true);
}

module mounting_hole_cyl() {
  cylinder(
    h = flange_thickness_mm + 2*hole_clearance_z_mm,
    r = mounting_hole_diameter_mm/2,
    center = true,
    $fn=32
  );
}

// ---------- Operations / Assembly ----------
module assembly() {
  // flange_with_holes = difference(flange_plate, mounting_holes_pair)
  union() {
    // Flange with holes
    difference() {
      flange_plate();

      // mounting_holes_pair = union(left, right)
      translate([-mounting_hole_pitch_mm/2, 0, 0]) mounting_hole_cyl();
      translate([ mounting_hole_pitch_mm/2, 0, 0]) mounting_hole_cyl();
    }

    // pin_array_15_positioned
    translate([0, 0, flange_thickness_mm/2 + pin_length_mm/2 - overlap_mm]) {
      // 15 pins in 3 rows x 5 columns, centered about origin
      // (Plan described "simplified 15-pin (3x5) header-style pin field")
      for (row = [0:2]) {
        for (col = [0:4]) {
          x = (col - 2) * pin_pitch_mm;
          y = (row - 1) * row_pitch_mm;
          translate([x, y, 0]) pin();
        }
      }
    }
  }
}

assembly();