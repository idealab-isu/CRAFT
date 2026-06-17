// Parameters
L = 51.3; //[25.65:102.6:0.1]
W = 51; //[25.5:102:0.1]
H = 15; //[7.5:30:0.1]
wall_t = 1.5; //[0.8:3:0.1]
outlet_w = 14; //[7:28:0.1]
outlet_h = 8; //[4:16:0.1]
outlet_len = 10; //[5:20:0.1]
impeller_od = 38; //[19:76:0.1]
impeller_thk = 10; //[5:20:0.1]
impeller_blades = 9; //[5:16:1]
hub_d = 10; //[5:20:0.1]
hub_h = 10; //[5:20:0.1]
inlet_d = 24; //[12:48:0.1]
cover_t = 1.5; //[0.8:3:0.1]
flange_t = 2; //[1:4:0.1]
mount_hole_d = 3.2; //[2:6.4:0.1]
mount_hole_edge_offset = 4; //[2:8:0.1]
eps = 1; //[0.5:2:0.1]
volute_r = 22; //[11:44:0.1]
volute_h = 13.5; //[7:27:0.1]
boss_d = 6.5; //[4:13:0.1]
boss_h = 10; //[5:20:0.1]
boss_hole_d = 2.6; //[1.6:5.2:0.1]
label_recess_depth = 0.6; //[0.3:1.2:0.1]
wire_slot_w = 6; //[3:12:0.1]
wire_slot_h = 3; //[1.5:6:0.1]
wire_slot_len = 8; //[4:16:0.1]
guide_thk = 1.2; //[0.6:2.4:0.1]
blade_len = 7; //[3.5:14:0.1]
blade_w = 3; //[1.5:6:0.1]

// Base Shapes
module housing_volute_outer() {
  translate([0, 0, -H/2 + flange_t + volute_h/2])
    cylinder(r=volute_r, h=volute_h, center=true);
}

module housing_volute_inner() {
  translate([0, 0, -H/2 + flange_t + wall_t + (volute_h - wall_t)/2])
    cylinder(r=volute_r - wall_t, h=volute_h - wall_t, center=true);
}

module outlet_nozzle_outer() {
  translate([volute_r + outlet_len/2 - eps, 0, -H/2 + flange_t + outlet_h/2])
    cube([outlet_len, outlet_w, outlet_h], center=true);
}

module outlet_nozzle_inner() {
  translate([volute_r + outlet_len/2 - eps, 0, -H/2 + flange_t + wall_t + (outlet_h - 2*wall_t)/2])
    cube([outlet_len + 2*eps, outlet_w - 2*wall_t, outlet_h - 2*wall_t], center=true);
}

module mounting_flange() {
  translate([0, 0, -H/2 + flange_t/2])
    cube([L, W, flange_t], center=true);
}

module top_cover_plate() {
  translate([0, 0, H/2 - cover_t/2])
    cube([L, W, cover_t], center=true);
}

module inlet_opening_cutter() {
  translate([0, 0, H/2 - cover_t/2])
    cylinder(r=inlet_d/2, h=cover_t + 2*eps, center=true);
}

module label_recess_cutter() {
  translate([0, 0, H/2 - (label_recess_depth + eps)/2])
    cube([L*0.55, W*0.35, label_recess_depth + eps], center=true);
}

module wire_exit_slot_cutter() {
  translate([L/2 - wire_slot_len/2, 0, -H/2 + flange_t + wire_slot_h/2])
    cube([wire_slot_len, wire_slot_w, wire_slot_h], center=true);
}

module mount_hole_cyl(pos) {
  translate(pos)
    cylinder(r=mount_hole_d/2, h=H + 2*eps, center=true);
}

module screw_boss(pos) {
  translate(pos)
    cylinder(r=boss_d/2, h=boss_h, center=true);
}

module screw_boss_hole(pos) {
  translate(pos)
    cylinder(r=boss_hole_d/2, h=boss_h + 2*eps, center=true);
}

module motor_hub() {
  translate([0, 0, -H/2 + flange_t + hub_h/2 - eps])
    cylinder(r=hub_d/2, h=hub_h, center=true);
}

module impeller_disk() {
  translate([0, 0, -H/2 + flange_t + impeller_thk/2])
    cylinder(r=impeller_od/2, h=impeller_thk, center=true);
}

module impeller_blade(angle) {
  rotate([0, 0, angle])
    translate([hub_d/2 + blade_len/2 - eps, 0, -H/2 + flange_t + impeller_thk/2])
      cube([blade_len, blade_w, impeller_thk], center=true);
}

module impeller_blade_curvature_detail() {
  translate([0, 0, -H/2 + flange_t + impeller_thk/2])
    rotate_extrude() circle(r=impeller_od/2 - wall_t);
}

module internal_flow_guide_1() {
  translate([volute_r/2 - eps, 0, -H/2 + flange_t + wall_t + (volute_h - wall_t)/2])
    cube([volute_r, guide_thk, volute_h - wall_t], center=true);
}

module internal_flow_guide_2() {
  rotate([0, 0, 45])
    translate([volute_r*0.35 - eps, volute_r*0.35, -H/2 + flange_t + wall_t + (volute_h - wall_t)/2])
      cube([volute_r*0.7, guide_thk, volute_h - wall_t], center=true);
}

module fillets_chamfers_proxy() {
  translate([L/2 - wall_t, W/2 - wall_t, -H/2 + flange_t + wall_t])
    sphere(r=wall_t);
}

// Operations
module housing_shell() {
  difference() {
    housing_volute_outer();
    housing_volute_inner();
  }
}

module outlet_shell() {
  difference() {
    outlet_nozzle_outer();
    outlet_nozzle_inner();
  }
}

module housing_with_outlet() {
  union() {
    housing_shell();
    outlet_shell();
  }
}

module impeller_blades_union() {
  union() {
    for (i = [0:impeller_blades-1])
      impeller_blade(i * 360/impeller_blades);
  }
}

module impeller() {
  union() {
    impeller_disk();
    impeller_blades_union();
    motor_hub();
    impeller_blade_curvature_detail();
  }
}

module cover_with_inlet() {
  difference() {
    top_cover_plate();
    inlet_opening_cutter();
    label_recess_cutter();
  }
}

module bosses_union() {
  union() {
    screw_boss([volute_r*0.55, volute_r*0.55, -H/2 + flange_t + boss_h/2 - eps]);
    screw_boss([volute_r*0.55, -volute_r*0.55, -H/2 + flange_t + boss_h/2 - eps]);
    screw_boss([-volute_r*0.55, volute_r*0.55, -H/2 + flange_t + boss_h/2 - eps]);
    screw_boss([-volute_r*0.55, -volute_r*0.55, -H/2 + flange_t + boss_h/2 - eps]);
  }
}

module bosses_drilled() {
  difference() {
    bosses_union();
    screw_boss_hole([volute_r*0.55, volute_r*0.55, -H/2 + flange_t + boss_h/2 - eps]);
    screw_boss_hole([volute_r*0.55, -volute_r*0.55, -H/2 + flange_t + boss_h/2 - eps]);
    screw_boss_hole([-volute_r*0.55, volute_r*0.55, -H/2 + flange_t + boss_h/2 - eps]);
    screw_boss_hole([-volute_r*0.55, -volute_r*0.55, -H/2 + flange_t + boss_h/2 - eps]);
  }
}

module internal_guides_union() {
  union() {
    internal_flow_guide_1();
    internal_flow_guide_2();
  }
}

module main_solid_pre_holes() {
  union() {
    mounting_flange();
    housing_with_outlet();
    cover_with_inlet();
    bosses_drilled();
    impeller();
    internal_guides_union();
    fillets_chamfers_proxy();
  }
}

module main_solid_with_mount_holes() {
  difference() {
    main_solid_pre_holes();
    mount_hole_cyl([L/2 - mount_hole_edge_offset, W/2 - mount_hole_edge_offset, 0]);
    mount_hole_cyl([L/2 - mount_hole_edge_offset, -W/2 + mount_hole_edge_offset, 0]);
    mount_hole_cyl([-L/2 + mount_hole_edge_offset, W/2 - mount_hole_edge_offset, 0]);
    mount_hole_cyl([-L/2 + mount_hole_edge_offset, -W/2 + mount_hole_edge_offset, 0]);
    wire_exit_slot_cutter();
  }
}

// Final Output
main_solid_with_mount_holes();