// Parameters
type_vector_0 = 6; //[3:12:0.1]
type_vector_1 = 5.5; //[2.75:11:0.1]
type_vector_2 = 14.7; //[7.35:29.4:0.1]
type_vector_3 = 12; //[6:24:0.1]
alpha = 1; //[0.1:1:0.05]
eps = 1; //[0.5:2:0.1]
gearbox_w = 24; //[12:48:0.5]
gearbox_d = 18; //[9:36:0.5]
gearbox_h = 14; //[7:28:0.5]
motor_diam = 24; //[12:48:0.5]
motor_len = 30; //[15:60:0.5]
hub_diam = 10; //[5:20:0.5]
hub_len = 3; //[1.5:6:0.25]
shaft_diam = 4; //[2:8:0.25]
shaft_len = 12; //[6:24:0.5]
shaft_boss_diam = 12; //[6:24:0.5]
shaft_boss_h = 3; //[1.5:6:0.25]
screw_boss_diam = 6; //[3:12:0.25]
screw_boss_h = 2; //[1:6:0.25]
screw_hole_diam = 3; //[1.5:6:0.25]
screw_spacing_x = 16; //[8:32:0.5]
screw_spacing_y = 10; //[5:20:0.5]
tag_w = 6; //[3:12:0.25]
tag_t = 1.2; //[0.6:2.4:0.1]
tag_l = 10; //[5:20:0.5]

// Gear Motor - complete geometry
module gear_motor() {
  color("DimGray") {
    // Gearbox housing
    translate([0, 0, 0])
      cube([gearbox_w, gearbox_d, gearbox_h], center=true);

    // Motor can
    translate([0, 0, -gearbox_h/2 - motor_len/2 + eps])
      cylinder(h=motor_len, r=motor_diam/2, center=true, $fn=64);

    // Motor hub
    translate([0, 0, -gearbox_h/2 - motor_len - hub_len/2 + eps])
      cylinder(h=hub_len, r=hub_diam/2, center=true, $fn=32);

    // Shaft
    translate([0, 0, gearbox_h/2 + shaft_len/2 - eps])
      cylinder(h=shaft_len, r=shaft_diam/2, center=true, $fn=32);

    // Shaft boss
    translate([0, 0, gearbox_h/2 - shaft_boss_h/2 + eps])
      cylinder(h=shaft_boss_h, r=shaft_boss_diam/2, center=true, $fn=32);

    // Mounting screw bosses
    union() {
      translate([screw_spacing_x/2, screw_spacing_y/2, -screw_boss_h/2])
        cylinder(h=gearbox_h + screw_boss_h, r=screw_boss_diam/2, center=true, $fn=32);
      translate([-screw_spacing_x/2, screw_spacing_y/2, -screw_boss_h/2])
        cylinder(h=gearbox_h + screw_boss_h, r=screw_boss_diam/2, center=true, $fn=32);
      translate([screw_spacing_x/2, -screw_spacing_y/2, -screw_boss_h/2])
        cylinder(h=gearbox_h + screw_boss_h, r=screw_boss_diam/2, center=true, $fn=32);
      translate([-screw_spacing_x/2, -screw_spacing_y/2, -screw_boss_h/2])
        cylinder(h=gearbox_h + screw_boss_h, r=screw_boss_diam/2, center=true, $fn=32);
    }

    // Electrical tags
    translate([-motor_diam/2 - tag_w/2 + eps, 0, -gearbox_h/2 - motor_len + tag_l/2 + eps])
      cube([tag_w, tag_t, tag_l], center=true);
    translate([motor_diam/2 + tag_w/2 - eps, 0, -gearbox_h/2 - motor_len + tag_l/2 + eps])
      cube([tag_w, tag_t, tag_l], center=true);
  }

  // Drilled holes for screws
  color("Black") {
    difference() {
      union() {
        translate([screw_spacing_x/2, screw_spacing_y/2, -screw_boss_h/2])
          cylinder(h=gearbox_h + screw_boss_h + 2*eps, r=screw_hole_diam/2, center=true, $fn=32);
        translate([-screw_spacing_x/2, screw_spacing_y/2, -screw_boss_h/2])
          cylinder(h=gearbox_h + screw_boss_h + 2*eps, r=screw_hole_diam/2, center=true, $fn=32);
        translate([screw_spacing_x/2, -screw_spacing_y/2, -screw_boss_h/2])
          cylinder(h=gearbox_h + screw_boss_h + 2*eps, r=screw_hole_diam/2, center=true, $fn=32);
        translate([-screw_spacing_x/2, -screw_spacing_y/2, -screw_boss_h/2])
          cylinder(h=gearbox_h + screw_boss_h + 2*eps, r=screw_hole_diam/2, center=true, $fn=32);
      }
    }
  }
}

// Assembly
module assembly() {
  gear_motor();
}

assembly();