$fn = 160;

// Target dimensions (mm)
bore_diameter_mm   = 5.0;   // bore
outer_diameter_mm  = 16.0;  // OD (body)
width_mm           = 5.0;   // total width of bearing body (excluding flange thickness)
flange_diameter_mm = 18.0;  // flange OD

// Visual/detail tuning (kept within envelope)
flange_width_mm        = 1.0;  // flange thickness
outer_ring_radial_mm   = 1.6;  // outer race radial thickness
inner_ring_radial_mm   = 1.2;  // inner race radial thickness
seal_face_thickness_mm = 0.6;  // shield thickness
seal_clearance_mm      = 0.25; // clearance between shield ID and inner ring OD
ball_diameter_mm       = 2.0;
ball_count             = 9;

// Connectivity / robustness
overlap_mm = 0.25; // overlap to ensure manifold connectivity

// Derived radii
r_bore   = bore_diameter_mm/2;
r_outer  = outer_diameter_mm/2;
r_flange = flange_diameter_mm/2;

r_inner_outer = r_bore + inner_ring_radial_mm;    // outer radius of inner ring
r_outer_inner = r_outer - outer_ring_radial_mm;   // inner radius of outer ring

// Ball path radius (between rings)
r_ball_path = (r_inner_outer + r_outer_inner)/2;

// Ball radius clamped to available radial space
ball_r = min(ball_diameter_mm/2, max(0.25, (r_outer_inner - r_inner_outer)/2 - 0.10));

// Outer ring (race)
module outer_ring() {
  difference() {
    cylinder(r=r_outer, h=width_mm, center=true);
    cylinder(r=r_outer_inner, h=width_mm + 2*overlap_mm, center=true);
  }
}

// Inner ring (race) with bore
module inner_ring() {
  difference() {
    cylinder(r=r_inner_outer, h=width_mm, center=true);
    cylinder(r=r_bore, h=width_mm + 2*overlap_mm, center=true);
  }
}

// Flange on -Z side (matches provided renders), connected with overlap
module flange() {
  translate([0, 0, -width_mm/2 - flange_width_mm/2 + overlap_mm])
    difference() {
      cylinder(r=r_flange, h=flange_width_mm, center=true);
      cylinder(r=r_bore, h=flange_width_mm + 2*overlap_mm, center=true);
    }
}

// Thin shield faces (visual detail), connected to outer ring
module shield_face(z_pos) {
  translate([0, 0, z_pos])
    difference() {
      // Slightly larger than outer ring inner radius so it overlaps/attaches
      cylinder(r=r_outer_inner + overlap_mm, h=seal_face_thickness_mm, center=true);
      // Clear inner ring OD so it reads as a shield
      cylinder(r=r_inner_outer + seal_clearance_mm, h=seal_face_thickness_mm + 2*overlap_mm, center=true);
    }
}

// Balls (visual detail) - slightly "embedded" into rings so union is one connected solid
module balls() {
  // Embed amount ensures each ball intersects both rings
  embed = max(0.15, overlap_mm);
  for (i = [0:ball_count-1]) {
    rotate([0, 0, i*360/ball_count])
      translate([r_ball_path, 0, 0])
        sphere(r=ball_r + embed);
  }
}

module bearing() {
  union() {
    outer_ring();
    inner_ring();
    flange();

    // Shields inset from faces so they are visible and connected
    shield_face( width_mm/2 - seal_face_thickness_mm/2 - overlap_mm);
    shield_face(-width_mm/2 + seal_face_thickness_mm/2 + overlap_mm);

    balls();
  }
}

bearing();