// Ball bearing: 5.0mm bore, 9.0mm OD, 2.5mm width
// Single connected solid (races + cage + balls fused with tiny overlaps)

$fn = 180;

// Target dimensions
bore_diameter_mm  = 5.0;
outer_diameter_mm = 9.0;
width_mm          = 2.5;

// Detailing (kept within envelope)
race_radial_thickness_mm = 0.85;   // ring wall thickness
race_lip_mm              = 0.35;   // small lips to suggest raceways
ball_diameter_mm         = 0.90;
num_balls                = 8;
cage_thickness_mm        = 0.55;   // axial thickness of cage ring
cage_radial_mm           = 0.45;   // radial thickness of cage ring
overlap_mm               = 0.06;   // small overlap to ensure one connected solid

// Derived radii
r_bore = bore_diameter_mm/2;
r_od   = outer_diameter_mm/2;

// Keep everything inside OD and outside bore
r_outer_race_inner = r_od - race_radial_thickness_mm;
r_inner_race_outer = r_bore + race_radial_thickness_mm;

// Ball center radius (between races), clamped to safe range
r_ball_center_nom = (r_outer_race_inner + r_inner_race_outer)/2;
r_ball_center_min = r_bore + race_radial_thickness_mm + ball_diameter_mm/2;
r_ball_center_max = r_od   - race_radial_thickness_mm - ball_diameter_mm/2;
r_ball_center     = min(max(r_ball_center_nom, r_ball_center_min), r_ball_center_max);

// Cage ring radii around ball centers
r_cage_mid   = r_ball_center;
r_cage_inner = r_cage_mid - cage_radial_mm/2;
r_cage_outer = r_cage_mid + cage_radial_mm/2;

// Ensure cage stays within races
r_cage_inner = max(r_cage_inner, r_inner_race_outer + overlap_mm);
r_cage_outer = min(r_cage_outer, r_outer_race_inner - overlap_mm);

// Modules
module outer_race() {
  difference() {
    cylinder(r=r_od, h=width_mm, center=true);
    // main bore of outer race
    cylinder(r=r_outer_race_inner, h=width_mm + 2*overlap_mm, center=true);

    // shallow raceway relief (visual)
    translate([0,0, width_mm/2 - race_lip_mm/2])
      cylinder(r=r_outer_race_inner + race_lip_mm, h=race_lip_mm + 2*overlap_mm, center=true);
    translate([0,0,-width_mm/2 + race_lip_mm/2])
      cylinder(r=r_outer_race_inner + race_lip_mm, h=race_lip_mm + 2*overlap_mm, center=true);
  }
}

module inner_race() {
  difference() {
    cylinder(r=r_inner_race_outer, h=width_mm, center=true);
    // true circular bore
    cylinder(r=r_bore, h=width_mm + 2*overlap_mm, center=true);

    // shallow raceway relief (visual)
    translate([0,0, width_mm/2 - race_lip_mm/2])
      cylinder(r=r_inner_race_outer - race_lip_mm, h=race_lip_mm + 2*overlap_mm, center=true);
    translate([0,0,-width_mm/2 + race_lip_mm/2])
      cylinder(r=r_inner_race_outer - race_lip_mm, h=race_lip_mm + 2*overlap_mm, center=true);
  }
}

module cage_ring() {
  // Thin ring that touches balls (fuses assembly) and sits between races
  difference() {
    cylinder(r=r_cage_outer, h=cage_thickness_mm, center=true);
    cylinder(r=r_cage_inner, h=cage_thickness_mm + 2*overlap_mm, center=true);
  }
}

module balls() {
  for (i = [0:num_balls-1]) {
    rotate([0,0, i*360/num_balls])
      translate([r_ball_center, 0, 0])
        sphere(r=ball_diameter_mm/2);
  }
}

// Final: one connected solid
union() {
  outer_race();
  inner_race();

  // Cage centered; slightly thicker overlap to guarantee fusion with balls/races
  scale([1,1,(cage_thickness_mm + 2*overlap_mm)/cage_thickness_mm])
    cage_ring();

  balls();
}