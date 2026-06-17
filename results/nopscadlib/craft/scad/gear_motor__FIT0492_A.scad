// Gear motor (connected solid) tuned to match: [6, 5.5, 14.7, 12]

$fn = 64;

// Parameters (kept, but connectivity fixed and model made a single connected solid)
type_0 = 6;   //[3:12:0.1]
type_1 = 5.5; //[2.75:11:0.1]
type_2 = 14.7;//[7.35:29.4:0.1]
type_3 = 12;  //[6:24:0.1]

eps = 0.8;    //[0.5:2:0.1]
overlap = 0.6; // intentional overlap to guarantee watertight unions

gearbox_w = 18; //[9:36:0.1]
gearbox_d = 12; //[6:24:0.1]
gearbox_h = 14; //[7:28:0.1]

motor_d = 12;   //[6:24:0.1]
motor_len = 24; //[12:48:0.1]

shaft_d = 3;    //[1.5:6:0.1]
shaft_len = 10; //[5:20:0.1]

boss_d = 8;     //[4:16:0.1]
boss_h = 2.5;   //[1.25:5:0.1]

screw_hole_d = 2.2; //[1.1:4.4:0.1]
screw_boss_d = 4.8; //[2.4:9.6:0.1]
screw_boss_h = 2;   //[1:4:0.1]

// Keep offsets within gearbox footprint so bosses are clearly attached
screw_offset_x = min(6, gearbox_w/2 - screw_boss_d/2 - 0.8); //[3:12:0.1]
screw_offset_y = min(4, gearbox_d/2 - screw_boss_d/2 - 0.8); //[2:8:0.1]

tag_w = 4;   //[2:8:0.1]
tag_t = 0.8; //[0.4:1.6:0.1]
tag_len = 6; //[3:12:0.1]

module gear_motor() {
  // Z layout (all formulas; no arbitrary placement)
  // Gearbox centered at z=0
  z_gb = 0;

  // Motor attached to bottom face of gearbox with slight overlap
  z_motor = z_gb - (gearbox_h/2 + motor_len/2 - overlap);

  // Boss sits on top face of gearbox with overlap
  z_boss = z_gb + (gearbox_h/2 + boss_h/2 - overlap);

  // Shaft sits on top of boss with overlap
  z_shaft = z_gb + (gearbox_h/2 + boss_h + shaft_len/2 - 2*overlap);

  // Electrical tags near motor bottom, attached to motor side with overlap
  z_tag = z_motor - (motor_len/2 - tag_len/2 - overlap);
  x_tag = motor_d/2 + tag_w/2 - overlap;

  difference() {
    // ONE connected solid: union of all external geometry
    union() {
      // Gearbox body
      translate([0, 0, z_gb])
        cube([gearbox_w, gearbox_d, gearbox_h], center=true);

      // Screw bosses (extend slightly below gearbox for visible mounting features)
      for (sx = [-screw_offset_x, screw_offset_x])
        for (sy = [-screw_offset_y, screw_offset_y])
          translate([sx, sy, z_gb - (gearbox_h/2) + (gearbox_h + screw_boss_h)/2 - overlap])
            cylinder(r=screw_boss_d/2, h=gearbox_h + screw_boss_h, center=true);

      // Motor can (connected to gearbox)
      translate([0, 0, z_motor])
        cylinder(r=motor_d/2, h=motor_len, center=true);

      // Shaft boss (connected to gearbox)
      translate([0, 0, z_boss])
        cylinder(r=boss_d/2, h=boss_h, center=true);

      // Output shaft (connected to boss)
      translate([0, 0, z_shaft])
        cylinder(r=shaft_d/2, h=shaft_len, center=true);

      // Electrical tags (connected to motor)
      translate([-x_tag, 0, z_tag])
        cube([tag_w, tag_t, tag_len], center=true);
      translate([ x_tag, 0, z_tag])
        cube([tag_w, tag_t, tag_len], center=true);
    }

    // Mounting holes (subtracted; do not break connectivity)
    for (sx = [-screw_offset_x, screw_offset_x])
      for (sy = [-screw_offset_y, screw_offset_y])
        translate([sx, sy, z_gb - (gearbox_h/2) + (gearbox_h + screw_boss_h)/2 - overlap])
          cylinder(r=screw_hole_d/2, h=gearbox_h + screw_boss_h + 2*eps, center=true);
  }
}

gear_motor();