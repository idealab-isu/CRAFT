// Parameters
rod_d = 8.0; //[4.0:16.0:0.1]
bore_clearance = 0.2; //[0.0:0.8:0.05]
bracket_h = 20.0; //[10.0:40.0:0.5]
base_L = 40.0; //[20.0:80.0:1]
base_W = 20.0; //[10.0:40.0:1]
base_t = 6.0; //[3.0:12.0:0.5]
support_W = 16.0; //[8.0:32.0:1]
support_D = 12.0; //[8.0:30.0:1]
mount_hole_d = 4.2; //[3.0:8.0:0.1]
mount_hole_spacing = 28.0; //[14.0:56.0:1]
rib_t = 4.0; //[2.0:10.0:0.5]
rib_L = 18.0; //[10.0:36.0:1]
overlap = 1.0; //[0.5:2.0:0.1]
clamp_gap = 1.2; //[0.6:2.5:0.1]
boss_d = 10.0; //[6.0:20.0:0.5]
boss_len = 8.0; //[4.0:20.0:0.5]
clamp_screw_d = 4.2; //[3.0:8.0:0.1]
counterbore_d = 8.0; //[6.0:14.0:0.5]
counterbore_depth = 3.0; //[1.5:8.0:0.5]
countersink_d = 8.0; //[6.0:14.0:0.5]
countersink_depth = 2.0; //[1.0:5.0:0.5]
fillet_r = 1.0; //[0.0:3.0:0.25]

// Base block
module base_block() {
  translate([0, 0, base_t/2])
    cube([base_L, base_W, base_t], center=true);
}

// Support block
module support_block() {
  translate([0, 0, base_t + (bracket_h - base_t)/2 - overlap/2])
    cube([support_D, support_W, bracket_h - base_t], center=true);
}

// Rib block
module rib_block() {
  translate([-(support_D/2) - (rib_L/2) + overlap, 0, base_t + (bracket_h - base_t)/2 - overlap/2])
    cube([rib_L, rib_t, bracket_h - base_t], center=true);
}

// Rod support bore
module rod_support_bore() {
  translate([0, 0, base_t + (bracket_h - base_t)/2])
    rotate([90, 0, 0])
      cylinder(r=(rod_d + bore_clearance)/2, h=support_W + 2*overlap, center=true);
}

// Mounting holes
module mount_hole_1() {
  translate([-mount_hole_spacing/2, 0, base_t/2])
    cylinder(r=mount_hole_d/2, h=base_t + 2*overlap, center=true);
}

module mount_hole_2() {
  translate([mount_hole_spacing/2, 0, base_t/2])
    cylinder(r=mount_hole_d/2, h=base_t + 2*overlap, center=true);
}

// Mounting hole countersinks
module mount_countersink_1() {
  translate([-mount_hole_spacing/2, 0, base_t - (countersink_depth + overlap)/2])
    rotate([180, 0, 0])
      cylinder(r1=countersink_d/2, r2=0, h=countersink_depth + overlap, center=true);
}

module mount_countersink_2() {
  translate([mount_hole_spacing/2, 0, base_t - (countersink_depth + overlap)/2])
    rotate([180, 0, 0])
      cylinder(r1=countersink_d/2, r2=0, h=countersink_depth + overlap, center=true);
}

// Clamp split slot
module clamp_split_slot() {
  translate([0, 0, base_t + (bracket_h - base_t)/2])
    cube([support_D + 2*overlap, clamp_gap, bracket_h - base_t + 2*overlap], center=true);
}

// Clamp screw boss
module clamp_screw_boss() {
  translate([support_D/2 + boss_len/2 - overlap, 0, base_t + (bracket_h - base_t)/2])
    rotate([0, 90, 0])
      cylinder(r=boss_d/2, h=boss_len, center=true);
}

// Clamp screw through-hole
module clamp_screw_through() {
  translate([boss_len/2 - overlap, 0, base_t + (bracket_h - base_t)/2])
    rotate([0, 90, 0])
      cylinder(r=clamp_screw_d/2, h=support_D + boss_len + 4*overlap, center=true);
}

// Clamp counterbore
module clamp_counterbore() {
  translate([support_D/2 + (counterbore_depth + overlap)/2 - overlap, 0, base_t + (bracket_h - base_t)/2])
    rotate([0, 90, 0])
      cylinder(r=counterbore_d/2, h=counterbore_depth + overlap, center=true);
}

// Fillet sphere
module fillet_sphere() {
  sphere(r=fillet_r, center=true);
}

// Main geometry
module bracket() {
  difference() {
    union() {
      base_block();
      support_block();
      rib_block();
      clamp_screw_boss();
    }
    mount_hole_1();
    mount_hole_2();
    mount_countersink_1();
    mount_countersink_2();
    rod_support_bore();
    clamp_split_slot();
    clamp_screw_through();
    clamp_counterbore();
  }
}

// Final output with fillets
minkowski() {
  bracket();
  fillet_sphere();
}