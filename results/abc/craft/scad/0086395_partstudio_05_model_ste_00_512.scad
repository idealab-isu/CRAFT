// Dimension-calibrated (target: 0.09 x 0.01 x 0.11 mm)
scale([0.955556, 0.750000, 0.924837])
{
// Parameters
bbox_x = 0.09; //[0.045:0.18:0.001]
bbox_y = 0.01; //[0.005:0.02:0.001]
bbox_z = 0.11; //[0.055:0.22:0.001]
L = 0.11; //[0.055:0.22:0.001]
W_max = 0.09; //[0.045:0.18:0.001]
T = 0.01; //[0.005:0.02:0.001]
nose_L = 0.02; //[0.01:0.04:0.001]
nose_tip_W = 0.02; //[0.01:0.04:0.001]
nose_tip_T = 0.006; //[0.003:0.012:0.001]
mount_L = 0.03; //[0.015:0.06:0.001]
mid_L = 0.06; //[0.03:0.12:0.001]
mid_W = 0.06; //[0.03:0.12:0.001]
step_pos_from_mount = 0.03; //[0.015:0.06:0.001]
step_W_drop = 0.03; //[0.015:0.06:0.001]
facet_depth = 0.004; //[0.002:0.008:0.001]
slot_depth = 0.02; //[0.01:0.04:0.001]
slot_width = 0.03; //[0.015:0.06:0.001]
slot_opening_W = 0.04; //[0.02:0.08:0.001]
fork_leg_W = 0.015; //[0.0075:0.03:0.001]
hole_d = 0.003; //[0.0015:0.006:0.0005]
hole_spacing = 0.01; //[0.005:0.02:0.001]
hole_edge_margin = 0.008; //[0.004:0.016:0.001]
overlap = 0.001; //[0.0005:0.002:0.0005]
csk_d = 0.006; //[0.003:0.012:0.0005]
csk_h = 0.002; //[0.001:0.004:0.0005]
edge_chamfer = 0.0015; //[0.0005:0.003:0.0005]
bevel_depth = 0.001; //[0.0005:0.002:0.0005]

// Main Prismatic Body
module main_prismatic_body() {
  translate([0, 0, -L/2 + mount_L/2])
    cube([W_max, T, mount_L], center=true);
}

// Stepped Transition Section
module stepped_transition_section() {
  translate([0, 0, -L/2 + mount_L + mid_L/2 - overlap])
    cube([W_max - step_W_drop, T, mid_L], center=true);
}

// Forked U-Slot End
module forked_u_slot_end() {
  translate([0, 0, -L/2 + mount_L + mid_L + (L - mount_L - mid_L)/2 - overlap])
    cube([slot_opening_W, T, L - mount_L - mid_L], center=true);
}

// Tapered Chamfered Nose End
module tapered_chamfered_nose_end() {
  translate([0, 0, L/2 - nose_L/2 + overlap])
    rotate([90, 0, 0])
    cylinder(h=nose_L, r1=slot_opening_W/2, r2=nose_tip_W/2, center=true);
}

// U-Slot Cut
module u_slot_cut() {
  translate([0, 0, -L/2 + mount_L + mid_L + (L - mount_L - mid_L) - slot_depth/2 + overlap])
    cube([slot_width, T + 2*overlap, slot_depth], center=true);
}

// Angular Flats Facets
module angular_flats_facets() {
  difference() {
    union() {
      translate([-(W_max/2 - facet_depth), 0, 0])
        rotate([0, 0, 25])
        cube([facet_depth*2, T + 2*overlap, L], center=true);
      translate([W_max/2 - facet_depth, 0, 0])
        rotate([0, 0, -25])
        cube([facet_depth*2, T + 2*overlap, L], center=true);
      translate([-((W_max - step_W_drop)/2 - facet_depth), 0, -L/2 + mount_L + mid_L/2])
        rotate([0, 0, 35])
        cube([facet_depth*2, T + 2*overlap, mid_L], center=true);
      translate([((W_max - step_W_drop)/2 - facet_depth), 0, -L/2 + mount_L + mid_L/2])
        rotate([0, 0, -35])
        cube([facet_depth*2, T + 2*overlap, mid_L], center=true);
    }
  }
}

// Three Through Holes on Mount Face
module three_through_holes_on_mount_face() {
  for (i = [0:2]) {
    translate([0, 0, -L/2 + hole_edge_margin + i*hole_spacing])
      rotate([90, 0, 0])
      cylinder(h=T + 2*overlap, r=hole_d/2, center=true);
  }
}

// Hole Countersinks
module hole_countersinks() {
  for (i = [0:2]) {
    translate([0, T/2 - csk_h/2 + overlap, -L/2 + hole_edge_margin + i*hole_spacing])
      rotate([90, 0, 0])
      cylinder(h=csk_h, r1=csk_d/2, r2=hole_d/2, center=true);
  }
}

// Edge Chamfers Fillets
module edge_chamfers_fillets() {
  difference() {
    union() {
      translate([-(W_max/2 - edge_chamfer), 0, 0])
        rotate([0, 0, 45])
        cube([edge_chamfer*2, T + 2*overlap, L], center=true);
      translate([W_max/2 - edge_chamfer, 0, 0])
        rotate([0, 0, -45])
        cube([edge_chamfer*2, T + 2*overlap, L], center=true);
    }
  }
}

// Cosmetic Face Bevels
module cosmetic_face_bevels() {
  difference() {
    union() {
      translate([0, T/2 - bevel_depth, 0])
        rotate([10, 0, 0])
        cube([W_max + 2*overlap, bevel_depth*2, L + 2*overlap], center=true);
      translate([0, -T/2 + bevel_depth, 0])
        rotate([-10, 0, 0])
        cube([W_max + 2*overlap, bevel_depth*2, L + 2*overlap], center=true);
    }
  }
}

// Final Geometry
difference() {
  union() {
    main_prismatic_body();
    stepped_transition_section();
    forked_u_slot_end();
    tapered_chamfered_nose_end();
  }
  u_slot_cut();
  angular_flats_facets();
  three_through_holes_on_mount_face();
  hole_countersinks();
  edge_chamfers_fillets();
  cosmetic_face_bevels();
}
}
