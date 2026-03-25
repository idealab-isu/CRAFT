// Dimension-calibrated (target: 0.08 x 0.05 x 0.07 mm)
scale([1.002303, 0.905574, 1.166344])
{
// Parameters
bbox_X = 0.08; //[0.04:0.16:0.001]
bbox_Y = 0.05; //[0.025:0.1:0.001]
bbox_Z = 0.07; //[0.035:0.14:0.001]
base_L = 0.08; //[0.04:0.16:0.001]
base_W = 0.05; //[0.025:0.1:0.001]
base_T = 0.01; //[0.005:0.02:0.001]
upright_W = 0.05; //[0.025:0.1:0.001]
upright_H = 0.06; //[0.03:0.12:0.001]
upright_T = 0.01; //[0.005:0.02:0.001]
gusset_T = 0.01; //[0.005:0.02:0.001]
gusset_leg_base = 0.03; //[0.015:0.06:0.001]
gusset_leg_upright = 0.03; //[0.015:0.06:0.001]
sq_hole_d = 0.008; //[0.004:0.016:0.001]
sq_hole_rot_deg = 45; //[0:90:1]
base_hole_pitch_X = 0.018; //[0.009:0.036:0.001]
base_hole_pitch_Y = 0.016; //[0.008:0.032:0.001]
upright_hole_pitch_X = 0.018; //[0.009:0.036:0.001]
upright_hole_pitch_Z = 0.02; //[0.01:0.04:0.001]
slot_base_L = 0.03; //[0.015:0.06:0.001]
slot_base_W = 0.01; //[0.005:0.02:0.001]
slot_upright_L = 0.03; //[0.015:0.06:0.001]
slot_upright_W = 0.01; //[0.005:0.02:0.001]
slot_corner_r = 0.003; //[0.001:0.006:0.001]
tab_count = 3; //[1:6:1]
tab_L = 0.006; //[0.003:0.012:0.001]
tab_W = 0.004; //[0.002:0.008:0.001]
tab_H = 0.004; //[0.002:0.008:0.001]
overlap = 0.001; //[0.0005:0.002:0.0005]
cut_extra = 0.02; //[0.01:0.04:0.001]
edge_round_r = 0.001; //[0.0005:0.002:0.0005]

// Base Plate
module base_plate() {
  translate([0, 0, base_T/2])
    cube([base_L, base_W, base_T], center=true);
}

// Upright Plate
module upright_plate() {
  translate([-base_L/2 + upright_T/2 - overlap, 0, upright_H/2])
    cube([upright_T, upright_W, upright_H], center=true);
}

// Gusset
module triangular_gusset() {
  translate([-base_L/2 + overlap, 0, base_T + overlap])
    rotate([90, 0, 0])
      linear_extrude(height=gusset_T, center=true)
        polygon(points=[[0, 0], [gusset_leg_base, 0], [0, gusset_leg_upright]]);
}

// Edge Tabs
module edge_tabs_steps() {
  union() {
    translate([base_L/2 - tab_L/2 + overlap, 0, tab_H/2])
      cube([tab_L, tab_W, tab_H], center=true);
    translate([base_L/2 - tab_L/2 + overlap, base_W/4, tab_H/2])
      cube([tab_L, tab_W, tab_H], center=true);
    translate([base_L/2 - tab_L/2 + overlap, -base_W/4, tab_H/2])
      cube([tab_L, tab_W, tab_H], center=true);
  }
}

// Base Diamond Square Hole Pattern
module base_diamond_square_hole_pattern() {
  union() {
    for (x = [-base_hole_pitch_X, 0, base_hole_pitch_X])
      for (y = [-base_hole_pitch_Y/2, base_hole_pitch_Y/2])
        rotate([0, 0, sq_hole_rot_deg])
          translate([x, y, base_T/2])
            cube([sq_hole_d, sq_hole_d, base_T + cut_extra], center=true);
  }
}

// Upright Diamond Square Hole Pattern
module upright_diamond_square_hole_pattern() {
  union() {
    for (z = [-upright_hole_pitch_Z/2, upright_hole_pitch_Z/2])
      for (y = [0, upright_W/4])
        rotate([sq_hole_rot_deg, 0, 0])
          translate([-base_L/2 + upright_T/2 - overlap, y, z + upright_H/2])
            cube([upright_T + cut_extra, sq_hole_d, sq_hole_d], center=true);
  }
}

// Base Rectangular Slot Cutout
module base_rectangular_slot_cutout() {
  minkowski() {
    translate([base_L/4, 0, base_T/2])
      cube([slot_base_L, slot_base_W, base_T + cut_extra], center=true);
    sphere(r=slot_corner_r, center=true);
  }
}

// Upright Rectangular Slot Cutout
module upright_rectangular_slot_cutout() {
  minkowski() {
    translate([-base_L/2 + upright_T/2 - overlap, 0, upright_H*0.6])
      cube([upright_T + cut_extra, slot_upright_W, slot_upright_L], center=true);
    sphere(r=slot_corner_r, center=true);
  }
}

// Main Solid Union
module main_solid_union() {
  union() {
    base_plate();
    upright_plate();
    triangular_gusset();
    edge_tabs_steps();
  }
}

// Cutouts Union
module cutouts_union() {
  union() {
    base_diamond_square_hole_pattern();
    upright_diamond_square_hole_pattern();
    base_rectangular_slot_cutout();
    upright_rectangular_slot_cutout();
  }
}

// Bracket with Cutouts
module bracket_with_cutouts() {
  difference() {
    main_solid_union();
    cutouts_union();
  }
}

// Small Edge Chamfers/Fillets
module small_edge_chamfers_fillets() {
  minkowski() {
    bracket_with_cutouts();
    sphere(r=edge_round_r, center=true);
  }
}

// Final Output
small_edge_chamfers_fillets();
}
