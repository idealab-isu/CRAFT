// Parameters
bbox_X = 0.08; //[0.04:0.16:0.001]
bbox_Y = 0.05; //[0.025:0.1:0.001]
bbox_Z = 0.07; //[0.035:0.14:0.001]
plate_t = 0.006; //[0.003:0.012:0.001]
base_Lx = 0.08; //[0.04:0.16:0.001]
base_Wy = 0.05; //[0.025:0.1:0.001]
upright_Ly = 0.05; //[0.025:0.1:0.001]
upright_Hz = 0.07; //[0.035:0.14:0.001]
gusset_t = 0.006; //[0.003:0.012:0.001]
gusset_leg_x = 0.03; //[0.015:0.06:0.001]
gusset_leg_z = 0.04; //[0.02:0.08:0.001]
hole_sq = 0.006; //[0.003:0.012:0.001]
hole_rot_deg = 45; //[0:45:1]
base_hole_pitch_x = 0.018; //[0.009:0.036:0.001]
base_hole_pitch_y = 0.016; //[0.008:0.032:0.001]
base_hole_count_x = 3; //[1:6:1]
base_hole_count_y = 2; //[1:6:1]
upright_hole_pitch_y = 0.016; //[0.008:0.032:0.001]
upright_hole_pitch_z = 0.02; //[0.01:0.04:0.001]
upright_hole_count_y = 2; //[1:6:1]
upright_hole_count_z = 3; //[1:6:1]
slot_base_L = 0.03; //[0.015:0.06:0.001]
slot_base_W = 0.008; //[0.004:0.016:0.001]
slot_upright_L = 0.03; //[0.015:0.06:0.001]
slot_upright_W = 0.008; //[0.004:0.016:0.001]
slot_corner_r = 0.002; //[0.001:0.004:0.001]
overlap = 0.001; //[0.0005:0.002:0.0005]
tab_t = 0.003; //[0.0015:0.006:0.0005]
tab_L = 0.012; //[0.006:0.024:0.001]
tab_W = 0.01; //[0.005:0.02:0.001]
fillet_r = 0.001; //[0.0005:0.002:0.0005]

// Base Plate
module base_plate() {
  translate([0, 0, plate_t/2])
    cube([base_Lx, base_Wy, plate_t], center=true);
}

// Upright Plate
module upright_plate() {
  translate([-base_Lx/2 + plate_t/2 - overlap, 0, upright_Hz/2])
    cube([plate_t, upright_Ly, upright_Hz], center=true);
}

// Triangular Gusset
module triangular_gusset() {
  translate([-base_Lx/2 + plate_t - overlap + gusset_leg_x/2, 0, plate_t + gusset_leg_z/2])
    rotate([90, 0, 0])
      linear_extrude(height=gusset_t, center=true)
        polygon(points=[[0, 0], [gusset_leg_x, 0], [0, gusset_leg_z]]);
}

// Edge Tabs/Steps
module edge_tabs_steps() {
  translate([base_Lx/2 - tab_L/2, 0, plate_t + tab_t/2 - overlap])
    cube([tab_L, tab_W, tab_t], center=true);
}

// Diamond Hole
module diamond_hole() {
  rotate([0, 0, hole_rot_deg])
    cube([hole_sq, hole_sq, plate_t + 2*overlap], center=true);
}

// Base Diamond Hole Pattern
module base_diamond_hole_pattern() {
  union() {
    for (x = [-base_hole_pitch_x, 0, base_hole_pitch_x])
      for (y = [-base_hole_pitch_y/2, base_hole_pitch_y/2])
        translate([x, y, plate_t/2])
          diamond_hole();
  }
}

// Upright Diamond Hole Pattern
module upright_diamond_hole_pattern() {
  union() {
    for (y = [-upright_hole_pitch_y/2, upright_hole_pitch_y/2])
      for (z = [upright_Hz/2 - upright_hole_pitch_z, upright_Hz/2, upright_Hz/2 + upright_hole_pitch_z])
        translate([-base_Lx/2 + plate_t/2 - overlap, y, z])
          rotate([hole_rot_deg, 0, 0])
            cube([plate_t + 2*overlap, hole_sq, hole_sq], center=true);
  }
}

// Base Rectangular Slot
module base_rectangular_slot() {
  hull() {
    translate([base_Lx/2 - slot_base_L/2 - plate_t, 0, plate_t/2])
      cylinder(r=slot_corner_r, h=plate_t + 2*overlap, center=true);
    translate([base_Lx/2 + slot_base_L/2 - plate_t, 0, plate_t/2])
      cylinder(r=slot_corner_r, h=plate_t + 2*overlap, center=true);
  }
  scale([1, slot_base_W/(2*slot_corner_r), 1])
    children();
}

// Upright Rectangular Slot
module upright_rectangular_slot() {
  hull() {
    translate([-base_Lx/2 + plate_t/2 - overlap, 0, upright_Hz/2 - slot_upright_L/2])
      rotate([0, 90, 0])
        cylinder(r=slot_corner_r, h=plate_t + 2*overlap, center=true);
    translate([-base_Lx/2 + plate_t/2 - overlap, 0, upright_Hz/2 + slot_upright_L/2])
      rotate([0, 90, 0])
        cylinder(r=slot_corner_r, h=plate_t + 2*overlap, center=true);
  }
  scale([slot_upright_W/(2*slot_corner_r), 1, 1])
    children();
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

// All Cutouts Union
module all_cutouts_union() {
  union() {
    base_diamond_hole_pattern();
    upright_diamond_hole_pattern();
    base_rectangular_slot();
    upright_rectangular_slot();
  }
}

// Bracket with Holes and Slots
module bracket_with_holes_slots() {
  difference() {
    main_solid_union();
    all_cutouts_union();
  }
}

// Chamfers and Fillets
module chamfers_fillets() {
  minkowski() {
    bracket_with_holes_slots();
    sphere(r=fillet_r, center=true);
  }
}

// Final Output
chamfers_fillets();