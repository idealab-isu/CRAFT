// Dimension-calibrated (target: 24.41 x 99.32 x 3.00 mm)
scale([0.769899, 1.000205, 1.000333])
{
// Parameters
L_total = 99.32; //[49.66:198.64:0.01]
W_max = 24.41; //[12.2:48.82:0.01]
T = 3; //[1.5:6:0.1]
L_mount = 24; //[12:48:0.1]
W_mount = 24.41; //[12.2:48.82:0.01]
L_blade = 75.32; //[37.66:150.64:0.01]
W_blade = 12; //[6:24:0.1]
L_tip = 10; //[5:20:0.1]
tooth_pitch = 3; //[1.5:6:0.1]
tooth_depth = 2; //[1:4:0.1]
tooth_count = 22; //[8:44:1]
tooth_relief_r = 0.6; //[0.3:1.2:0.05]
hole_d = 4; //[2:8:0.1]
hole_spacing = 12; //[6:24:0.1]
hole_edge_margin = 5; //[2.5:10:0.1]
star_outer_r = 5.5; //[2.75:11:0.1]
star_inner_r = 3.2; //[1.6:6.4:0.1]
star_points = 8; //[5:12:1]
transition_L = 6; //[3:12:0.1]
overlap = 1; //[0.5:2:0.1]
edge_chamfer = 0.6; //[0.3:1.2:0.05]
hole_chamfer_d = 5.2; //[4.2:8.4:0.1]
hole_chamfer_h = 0.6; //[0.3:1.2:0.05]
engrave_depth = 0.4; //[0.2:0.8:0.05]
engrave_w = 1.2; //[0.6:2.4:0.1]
engrave_L = 18; //[9:36:0.5]

// Base Shapes
module main_blade_plate() {
  translate([(-L_total/2) + L_mount + transition_L + L_blade/2, 0, 0])
    cube([L_blade, W_blade, T], center=true);
}

module mounting_plate_diamond() {
  translate([(-L_total/2) + L_mount/2, 0, 0])
    linear_extrude(height=T, center=true)
      polygon(points=[
        [L_mount/2, 0],
        [0, W_mount/2],
        [-L_mount/2, 0],
        [0, -W_mount/2]
      ]);
}

module mounting_plate_to_blade_transition() {
  translate([(-L_total/2) + L_mount + transition_L/2, 0, 0])
    linear_extrude(height=T, center=true)
      polygon(points=[
        [-transition_L/2, -W_mount/2],
        [-transition_L/2, W_mount/2],
        [transition_L/2, W_blade/2],
        [transition_L/2, -W_blade/2]
      ]);
}

module pointed_tip_chamfer() {
  translate([(-L_total/2) + L_mount + transition_L + L_blade - L_tip/2, 0, 0])
    linear_extrude(height=T, center=true)
      polygon(points=[
        [-L_tip/2, -W_blade/2],
        [-L_tip/2, W_blade/2],
        [L_tip/2, 0]
      ]);
}

module serrated_edge_teeth() {
  translate([(-L_total/2) + L_mount + transition_L + (tooth_count*tooth_pitch)/2, 0, 0])
    linear_extrude(height=T, center=true)
      polygon(points=[
        [0, W_blade/2],
        [tooth_pitch/2, W_blade/2 - tooth_depth],
        [tooth_pitch, W_blade/2],
        [tooth_pitch*3/2, W_blade/2 - tooth_depth],
        [tooth_pitch*2, W_blade/2],
        [tooth_pitch*5/2, W_blade/2 - tooth_depth],
        [tooth_pitch*3, W_blade/2],
        [tooth_pitch*7/2, W_blade/2 - tooth_depth],
        [tooth_pitch*4, W_blade/2],
        [tooth_pitch*9/2, W_blade/2 - tooth_depth],
        [tooth_pitch*5, W_blade/2],
        [tooth_pitch*11/2, W_blade/2 - tooth_depth],
        [tooth_pitch*6, W_blade/2],
        [tooth_pitch*13/2, W_blade/2 - tooth_depth],
        [tooth_pitch*7, W_blade/2],
        [tooth_pitch*15/2, W_blade/2 - tooth_depth],
        [tooth_pitch*8, W_blade/2],
        [tooth_pitch*17/2, W_blade/2 - tooth_depth],
        [tooth_pitch*9, W_blade/2],
        [tooth_pitch*19/2, W_blade/2 - tooth_depth],
        [tooth_pitch*10, W_blade/2],
        [tooth_pitch*21/2, W_blade/2 - tooth_depth],
        [tooth_pitch*11, W_blade/2],
        [tooth_pitch*23/2, W_blade/2 - tooth_depth],
        [tooth_pitch*12, W_blade/2],
        [tooth_pitch*25/2, W_blade/2 - tooth_depth],
        [tooth_pitch*13, W_blade/2],
        [tooth_pitch*27/2, W_blade/2 - tooth_depth],
        [tooth_pitch*14, W_blade/2],
        [tooth_pitch*29/2, W_blade/2 - tooth_depth],
        [tooth_pitch*15, W_blade/2],
        [tooth_pitch*31/2, W_blade/2 - tooth_depth],
        [tooth_pitch*16, W_blade/2],
        [tooth_pitch*33/2, W_blade/2 - tooth_depth],
        [tooth_pitch*17, W_blade/2],
        [tooth_pitch*35/2, W_blade/2 - tooth_depth],
        [tooth_pitch*18, W_blade/2],
        [tooth_pitch*37/2, W_blade/2 - tooth_depth],
        [tooth_pitch*19, W_blade/2],
        [tooth_pitch*39/2, W_blade/2 - tooth_depth],
        [tooth_pitch*20, W_blade/2],
        [tooth_pitch*41/2, W_blade/2 - tooth_depth],
        [tooth_pitch*21, W_blade/2],
        [tooth_pitch*43/2, W_blade/2 - tooth_depth],
        [tooth_pitch*22, W_blade/2],
        [tooth_pitch*22, W_blade/2 + tooth_depth],
        [0, W_blade/2 + tooth_depth]
      ]);
}

module tooth_root_relief() {
  translate([(-L_total/2) + L_mount + transition_L + tooth_pitch/2, W_blade/2 - tooth_depth, 0])
    cylinder(r=tooth_relief_r, h=T + overlap, center=true);
}

module mount_hole_1() {
  translate([(-L_total/2) + hole_edge_margin, 0, 0])
    cylinder(r=hole_d/2, h=T + overlap, center=true);
}

module mount_hole_2() {
  translate([(-L_total/2) + hole_edge_margin + hole_spacing, 0, 0])
    cylinder(r=hole_d/2, h=T + overlap, center=true);
}

module central_star_cutout() {
  translate([(-L_total/2) + L_mount/2, 0, 0])
    linear_extrude(height=T + overlap, center=true)
      polygon(points=[
        [star_outer_r, 0],
        [star_inner_r*0.70710678, star_inner_r*0.70710678],
        [0, star_outer_r],
        [-star_inner_r*0.70710678, star_inner_r*0.70710678],
        [-star_outer_r, 0],
        [-star_inner_r*0.70710678, -star_inner_r*0.70710678],
        [0, -star_outer_r],
        [star_inner_r*0.70710678, -star_inner_r*0.70710678]
      ]);
}

module edge_fillet_chamfer_details() {
  translate([(-L_total/2) + L_mount + transition_L + L_blade/2, 0, T/2 - edge_chamfer/2])
    linear_extrude(height=edge_chamfer, center=true)
      square([L_blade, W_blade], center=true);
}

module hole_chamfers() {
  translate([(-L_total/2) + hole_edge_margin, 0, T/2 - hole_chamfer_h/2])
    cylinder(r1=hole_chamfer_d/2, r2=0, h=hole_chamfer_h, center=true);
}

module engraving_or_markings() {
  translate([(-L_total/2) + L_mount + transition_L + L_blade/2, -W_blade/4, T/2 - engrave_depth/2])
    cube([engrave_L, engrave_w, engrave_depth], center=true);
}

// Operations
module blade_plus_tip() {
  union() {
    main_blade_plate();
    pointed_tip_chamfer();
  }
}

module mount_plus_transition() {
  union() {
    mounting_plate_diamond();
    mounting_plate_to_blade_transition();
  }
}

module main_solid_pre_teeth() {
  union() {
    mount_plus_transition();
    blade_plus_tip();
  }
}

module main_solid_with_teeth() {
  union() {
    main_solid_pre_teeth();
    serrated_edge_teeth();
  }
}

module main_solid_with_teeth_relief() {
  difference() {
    main_solid_with_teeth();
    tooth_root_relief();
  }
}

module main_solid_cut_holes_star() {
  difference() {
    main_solid_with_teeth_relief();
    mount_hole_1();
    mount_hole_2();
    central_star_cutout();
  }
}

module main_solid_with_hole_chamfers() {
  difference() {
    main_solid_cut_holes_star();
    hole_chamfers();
    translate([hole_spacing, 0, 0]) hole_chamfers();
    translate([0, 0, -(T - hole_chamfer_h)]) hole_chamfers();
    translate([hole_spacing, 0, -(T - hole_chamfer_h)]) hole_chamfers();
  }
}

module main_solid_with_edge_details() {
  difference() {
    main_solid_with_hole_chamfers();
    edge_fillet_chamfer_details();
  }
}

module final_model() {
  difference() {
    main_solid_with_edge_details();
    engraving_or_markings();
  }
}

// Final Output
final_model();
}
