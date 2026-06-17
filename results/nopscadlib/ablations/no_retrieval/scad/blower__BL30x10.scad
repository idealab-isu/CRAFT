// Parameters
L = 30.0; //[15.0:60.0:0.1]
W = 30.0; //[15.0:60.0:0.1]
H = 10.1; //[5.0:20.2:0.1]
wall_t = 1.2; //[0.6:2.4:0.1]
cavity_d = 24.0; //[12.0:48.0:0.1]
cavity_depth = 8.0; //[4.0:16.0:0.1]
inlet_d = 16.0; //[8.0:32.0:0.1]
outlet_w = 10.0; //[5.0:20.0:0.1]
outlet_h = 6.0; //[3.0:12.0:0.1]
outlet_len = 6.0; //[3.0:12.0:0.1]
impeller_d = 22.0; //[11.0:44.0:0.1]
impeller_h = 7.0; //[3.5:14.0:0.1]
hub_d = 6.0; //[3.0:12.0:0.1]
hub_h = 7.0; //[3.5:14.0:0.1]
blade_count = 9; //[5:16:1]
blade_t = 0.8; //[0.4:1.6:0.1]
blade_height = 6.5; //[3.0:13.0:0.1]
base_t = 1.0; //[0.5:2.0:0.1]
mount_hole_d = 2.2; //[1.2:4.4:0.1]
mount_hole_edge_offset = 3.0; //[1.5:6.0:0.1]
boss_od = 5.6; //[3.0:10.0:0.1]
boss_h = 6.0; //[3.0:9.0:0.1]
fillet_r = 2.0; //[0.8:4.0:0.1]
label_recess_depth = 0.4; //[0.2:1.0:0.1]
label_recess_margin = 4.0; //[2.0:8.0:0.1]
wire_slot_w = 3.0; //[1.5:6.0:0.1]
wire_slot_h = 2.0; //[1.0:4.0:0.1]
wire_slot_len = 4.0; //[2.0:8.0:0.1]
strut_w = 2.0; //[1.0:4.0:0.1]
strut_t = 1.2; //[0.6:2.4:0.1]
eps = 0.8; //[0.2:1.5:0.1]

// Base Shapes
module housing_main_body() {
  translate([0, 0, 0])
    cube([L, W, H], center=true);
}

module impeller_cavity() {
  translate([0, 0, H/2 - cavity_depth/2 + eps/2])
    cylinder(h=cavity_depth + eps, r=cavity_d/2, center=true);
}

module inlet_opening() {
  translate([0, 0, 0])
    cylinder(h=H + 2*eps, r=inlet_d/2, center=true);
}

module outlet_nozzle_outer() {
  translate([L/2 + outlet_len/2 - eps, 0, H/2 - outlet_h/2 - wall_t])
    cube([outlet_len, outlet_w, outlet_h], center=true);
}

module outlet_nozzle_inner() {
  translate([L/2 + outlet_len/2 - eps, 0, H/2 - outlet_h/2 - wall_t])
    cube([outlet_len + 2*eps, outlet_w - 2*wall_t, outlet_h - 2*wall_t], center=true);
}

module base_plate() {
  translate([0, 0, -H/2 + base_t/2 + eps])
    cube([L - 2*wall_t, W - 2*wall_t, base_t], center=true);
}

module mount_hole_cyl(pos) {
  translate(pos)
    cylinder(h=H + 2*eps, r=mount_hole_d/2, center=true);
}

module screw_boss(pos) {
  translate(pos)
    cylinder(h=boss_h, r=boss_od/2, center=true);
}

module corner_fillet_cyl(pos) {
  translate(pos)
    cylinder(h=H, r=fillet_r, center=true);
}

module label_recess() {
  translate([0, 0, H/2 - (label_recess_depth + eps)/2])
    cube([L - 2*label_recess_margin, W - 2*label_recess_margin, label_recess_depth + eps], center=true);
}

module wire_exit_slot() {
  translate([-L/2 + wall_t + wire_slot_len/2, 0, -H/2 + base_t + wire_slot_h/2])
    cube([wire_slot_len + 2*eps, wire_slot_w, wire_slot_h], center=true);
}

module internal_strut_1() {
  translate([-cavity_d/4, 0, -H/2 + base_t + strut_t/2])
    cube([cavity_d/2, strut_w, strut_t], center=true);
}

module internal_strut_2() {
  translate([0, -cavity_d/4, -H/2 + base_t + strut_t/2])
    cube([strut_w, cavity_d/2, strut_t], center=true);
}

module impeller_rotor() {
  translate([0, 0, H/2 - cavity_depth + impeller_h/2 + eps])
    cylinder(h=impeller_h, r=impeller_d/2, center=true);
}

module motor_hub() {
  translate([0, 0, H/2 - cavity_depth + hub_h/2 + eps])
    cylinder(h=hub_h, r=hub_d/2, center=true);
}

module impeller_blade_proto() {
  translate([hub_d/2 + ((impeller_d - hub_d)/2)/2 - eps, 0, H/2 - cavity_depth + blade_height/2 + eps])
    cube([(impeller_d - hub_d)/2, blade_t, blade_height], center=true);
}

// Operations
module outlet_nozzle_shell() {
  difference() {
    outlet_nozzle_outer();
    outlet_nozzle_inner();
  }
}

module corner_fillets_union() {
  union() {
    corner_fillet_cyl([L/2 - fillet_r, W/2 - fillet_r, 0]);
    corner_fillet_cyl([-L/2 + fillet_r, W/2 - fillet_r, 0]);
    corner_fillet_cyl([-L/2 + fillet_r, -W/2 + fillet_r, 0]);
    corner_fillet_cyl([L/2 - fillet_r, -W/2 + fillet_r, 0]);
  }
}

module housing_with_nozzle_and_fillets() {
  union() {
    housing_main_body();
    outlet_nozzle_shell();
    corner_fillets_union();
  }
}

module housing_hollowed() {
  difference() {
    housing_with_nozzle_and_fillets();
    impeller_cavity();
    inlet_opening();
    label_recess();
    wire_exit_slot();
  }
}

module mounting_holes_4x() {
  union() {
    mount_hole_cyl([L/2 - mount_hole_edge_offset, W/2 - mount_hole_edge_offset, 0]);
    mount_hole_cyl([-L/2 + mount_hole_edge_offset, W/2 - mount_hole_edge_offset, 0]);
    mount_hole_cyl([-L/2 + mount_hole_edge_offset, -W/2 + mount_hole_edge_offset, 0]);
    mount_hole_cyl([L/2 - mount_hole_edge_offset, -W/2 + mount_hole_edge_offset, 0]);
  }
}

module housing_with_mount_holes() {
  difference() {
    housing_hollowed();
    mounting_holes_4x();
  }
}

module screw_bosses() {
  union() {
    screw_boss([L/2 - mount_hole_edge_offset, W/2 - mount_hole_edge_offset, -H/2 + base_t + boss_h/2]);
    screw_boss([-L/2 + mount_hole_edge_offset, W/2 - mount_hole_edge_offset, -H/2 + base_t + boss_h/2]);
    screw_boss([-L/2 + mount_hole_edge_offset, -W/2 + mount_hole_edge_offset, -H/2 + base_t + boss_h/2]);
    screw_boss([L/2 - mount_hole_edge_offset, -W/2 + mount_hole_edge_offset, -H/2 + base_t + boss_h/2]);
  }
}

module internal_struts() {
  union() {
    internal_strut_1();
    internal_strut_2();
  }
}

module impeller_blades() {
  union() {
    for (i = [0:blade_count-1]) {
      rotate([0, 0, i*360/blade_count])
        impeller_blade_proto();
    }
  }
}

module impeller_assembly() {
  union() {
    impeller_rotor();
    motor_hub();
    impeller_blades();
  }
}

// Final Model
module complete_model() {
  union() {
    housing_with_mount_holes();
    base_plate();
    screw_bosses();
    internal_struts();
    impeller_assembly();
  }
}

// Render the complete model
color([0.12, 0.12, 0.14]) complete_model();