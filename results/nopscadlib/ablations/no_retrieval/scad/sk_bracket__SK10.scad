// Parameters
rod_d = 10.0; //[5.0:20.0:0.1]
bore_clearance = 0.2; //[0.0:1.0:0.05]
bracket_h = 20.0; //[10.0:40.0:0.5]
base_L = 40.0; //[20.0:80.0:1]
base_W = 20.0; //[10.0:40.0:1]
base_T = 6.0; //[3.0:12.0:0.5]
support_block_L = 20.0; //[10.0:40.0:1]
support_block_W = 20.0; //[10.0:40.0:1]
mount_hole_d = 5.0; //[3.0:10.0:0.1]
mount_hole_spacing = 28.0; //[14.0:56.0:0.5]
overlap = 1.0; //[0.5:2.0:0.1]
slot_w = 2.0; //[1.0:4.0:0.1]
set_screw_d = 4.0; //[2.0:8.0:0.1]
fillet_r = 1.0; //[0.5:3.0:0.1]

// Base block
module base_block() {
  translate([0, 0, base_T/2])
    cube([base_L, base_W, base_T], center=true);
}

// Support block
module support_block() {
  translate([0, 0, base_T + (bracket_h - base_T)/2 - overlap/2])
    cube([support_block_L, support_block_W, bracket_h - base_T], center=true);
}

// Rod support bore
module rod_support_bore() {
  translate([0, 0, base_T + (bracket_h - base_T)/2])
    rotate([90, 0, 0])
      cylinder(h=support_block_W + 2*overlap, r=(rod_d + bore_clearance)/2, center=true);
}

// Mounting holes
module mount_hole_1() {
  translate([-mount_hole_spacing/2, 0, base_T/2])
    cylinder(h=base_T + 2*overlap, r=mount_hole_d/2, center=true);
}

module mount_hole_2() {
  translate([mount_hole_spacing/2, 0, base_T/2])
    cylinder(h=base_T + 2*overlap, r=mount_hole_d/2, center=true);
}

// Set screw hole
module set_screw_hole() {
  translate([0, 0, base_T + (bracket_h - base_T)/2])
    rotate([0, 90, 0])
      cylinder(h=support_block_L + 2*overlap, r=set_screw_d/2, center=true);
}

// Split clamp slot
module split_clamp_slot() {
  translate([support_block_L/2 - slot_w/2, 0, base_T + (bracket_h - base_T)/2])
    cube([slot_w, support_block_W + 2*overlap, bracket_h - base_T + 2*overlap], center=true);
}

// Fillets and chamfers sphere
module fillets_chamfers_sphere() {
  sphere(r=fillet_r, center=true);
}

// Assemble bracket
module bracket() {
  difference() {
    union() {
      base_block();
      support_block();
    }
    rod_support_bore();
    union() {
      mount_hole_1();
      mount_hole_2();
    }
    set_screw_hole();
    split_clamp_slot();
  }
}

// Final output with fillets and chamfers
minkowski() {
  bracket();
  fillets_chamfers_sphere();
}