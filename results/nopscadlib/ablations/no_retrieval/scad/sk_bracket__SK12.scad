// Parameters
rod_d = 12.0; //[6.0:24.0:0.1]
bracket_h = 23.0; //[12.0:46.0:0.5]
base_L = 50.0; //[25.0:100.0:1]
base_W = 30.0; //[15.0:60.0:1]
base_t = 6.0; //[3.0:12.0:0.5]
support_W = 18.0; //[9.0:36.0:0.5]
support_L = 20.0; //[10.0:40.0:0.5]
bore_d = 12.2; //[6.2:24.6:0.05]
bore_center_h = 17.0; //[10.0:34.0:0.5]
mount_hole_d = 5.0; //[3.0:10.0:0.1]
mount_hole_spacing = 32.0; //[16.0:64.0:1]
mount_hole_edge_offset = 9.0; //[5.0:18.0:0.5]
set_screw_d = 4.0; //[2.0:8.0:0.1]
set_screw_z = 17.0; //[10.0:34.0:0.5]
clamp_slot_w = 2.0; //[1.0:4.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
fillet_r = 1.0; //[0.5:3.0:0.1]

// Base block
module base_block() {
  translate([0, 0, base_t/2])
    cube([base_L, base_W, base_t], center=true);
}

// Rod bore support body
module rod_bore_support_body() {
  translate([0, 0, base_t + (bracket_h - base_t)/2 - overlap])
    cube([support_L, support_W, bracket_h - base_t], center=true);
}

// Rod bore
module rod_bore() {
  translate([0, 0, bore_center_h])
    rotate([0, 90, 0])
      cylinder(h=support_L + 2*overlap, r=bore_d/2, center=true);
}

// Mounting holes
module mount_hole_1() {
  translate([-mount_hole_spacing/2, 0, base_t/2])
    cylinder(h=base_t + 2*overlap, r=mount_hole_d/2, center=true);
}

module mount_hole_2() {
  translate([mount_hole_spacing/2, 0, base_t/2])
    cylinder(h=base_t + 2*overlap, r=mount_hole_d/2, center=true);
}

// Set screw hole
module set_screw_hole() {
  translate([0, 0, set_screw_z])
    rotate([90, 0, 0])
      cylinder(h=support_W + 2*overlap, r=set_screw_d/2, center=true);
}

// Split clamp slot
module split_clamp_slot() {
  translate([0, 0, base_t + (bracket_h - base_t)/2 - overlap])
    cube([support_L + 2*overlap, clamp_slot_w, bracket_h - base_t + 2*overlap], center=true);
}

// Fillet sphere
module fillet_sphere() {
  sphere(r=fillet_r, center=true);
}

// Assemble the bracket
module shaft_support_bracket() {
  difference() {
    union() {
      base_block();
      rod_bore_support_body();
    }
    rod_bore();
    mount_hole_1();
    mount_hole_2();
    set_screw_hole();
    split_clamp_slot();
  }
}

// Apply fillets and chamfers
minkowski() {
  shaft_support_bracket();
  fillet_sphere();
}