// Parameters
type_v0 = 6; //[3:12:0.1]
type_v1 = 5.5; //[2.75:11:0.1]
type_v2 = 14.7; //[7.35:29.4:0.1]
type_v3 = 12; //[6:24:0.1]
alpha = 1; //[0.1:1:0.05]
eps = 0.8; //[0.5:2:0.1]
gearbox_w = 24; //[12:48:0.5]
gearbox_d = 18; //[9:36:0.5]
gearbox_h = 14.7; //[7.35:29.4:0.1]
boss_d = 12; //[6:24:0.5]
boss_h = 3.5; //[1.75:7:0.1]
shaft_d = 5.5; //[2.75:11:0.1]
shaft_len = 12; //[6:24:0.5]
motor_d = 24; //[12:48:0.5]
motor_len = 30; //[15:60:0.5]
hub_d = 10; //[5:20:0.5]
hub_h = 2.5; //[1.25:5:0.1]
screw_hole_d = 3; //[1.5:6:0.1]
screw_boss_d = 6; //[3:12:0.1]
screw_boss_extra_h = 2; //[1:6:0.1]
screw_spacing_x = 16; //[8:32:0.5]
screw_spacing_y = 12; //[6:24:0.5]
tag_w = 6; //[3:12:0.5]
tag_h = 10; //[5:20:0.5]
tag_t = 1.2; //[0.6:2.4:0.1]
tag_offset_x = 12; //[6:24:0.5]

// Gear Motor - complete geometry
module gear_motor() {
  color("DimGray") {
    // Gearbox housing with bosses
    difference() {
      union() {
        translate([0, 0, 0])
          cube([gearbox_w, gearbox_d, gearbox_h], center=true);
        translate([screw_spacing_x/2, screw_spacing_y/2, -screw_boss_extra_h/2])
          cylinder(r=screw_boss_d/2, h=gearbox_h + screw_boss_extra_h, center=true);
        translate([-screw_spacing_x/2, screw_spacing_y/2, -screw_boss_extra_h/2])
          cylinder(r=screw_boss_d/2, h=gearbox_h + screw_boss_extra_h, center=true);
        translate([screw_spacing_x/2, -screw_spacing_y/2, -screw_boss_extra_h/2])
          cylinder(r=screw_boss_d/2, h=gearbox_h + screw_boss_extra_h, center=true);
        translate([-screw_spacing_x/2, -screw_spacing_y/2, -screw_boss_extra_h/2])
          cylinder(r=screw_boss_d/2, h=gearbox_h + screw_boss_extra_h, center=true);
      }
      translate([screw_spacing_x/2, screw_spacing_y/2, -screw_boss_extra_h/2])
        cylinder(r=screw_hole_d/2, h=gearbox_h + screw_boss_extra_h + 2*eps, center=true);
      translate([-screw_spacing_x/2, screw_spacing_y/2, -screw_boss_extra_h/2])
        cylinder(r=screw_hole_d/2, h=gearbox_h + screw_boss_extra_h + 2*eps, center=true);
      translate([screw_spacing_x/2, -screw_spacing_y/2, -screw_boss_extra_h/2])
        cylinder(r=screw_hole_d/2, h=gearbox_h + screw_boss_extra_h + 2*eps, center=true);
      translate([-screw_spacing_x/2, -screw_spacing_y/2, -screw_boss_extra_h/2])
        cylinder(r=screw_hole_d/2, h=gearbox_h + screw_boss_extra_h + 2*eps, center=true);
    }
    
    // Shaft boss
    translate([0, 0, gearbox_h/2 + boss_h/2 - eps])
      cylinder(r=boss_d/2, h=boss_h, center=true);
    
    // Output shaft
    color("Silver") translate([0, 0, gearbox_h/2 + boss_h + shaft_len/2 - 2*eps])
      cylinder(r=shaft_d/2, h=shaft_len, center=true);
    
    // Motor can
    color("Black") translate([0, 0, -gearbox_h/2 - motor_len/2 + eps])
      cylinder(r=motor_d/2, h=motor_len, center=true);
    
    // Motor hub
    translate([0, 0, -gearbox_h/2 - motor_len - hub_h/2 + 2*eps])
      cylinder(r=hub_d/2, h=hub_h, center=true);
    
    // Electrical tags
    color("Silver") {
      translate([-tag_offset_x/2, 0, -gearbox_h/2 - motor_len + tag_h/2 - eps])
        cube([tag_w, tag_t, tag_h], center=true);
      translate([tag_offset_x/2, 0, -gearbox_h/2 - motor_len + tag_h/2 - eps])
        cube([tag_w, tag_t, tag_h], center=true);
    }
  }
}

// Assembly
module assembly() {
  gear_motor();
}

assembly();