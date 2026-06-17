// Parameters
type_0 = 12; //[6:24:1]
type_1 = 11; //[6:22:1]
type_2 = 6; //[3:12:1]
type_3 = 0.5; //[0.25:1:0.05]
thickness = 3; //[1.5:6:0.5]
shaft_length = 18; //[9:36:1]
value_flag = 0; //[0:1:1]
eps = 0.8; //[0.4:1.6:0.1]
body_d = 24; //[12:48:1]
body_total_h = 18; //[9:36:1]
gangs = 1; //[1:3:1]
wafer_h = 2; //[1:4:0.5]
gap_h = 2; //[1:4:0.5]
boss_d = 16; //[8:32:1]
boss_h = 2.5; //[1.25:5:0.25]
face_w = 18; //[9:36:1]
face_h = 14; //[7:28:1]
face_t = 1.5; //[0.75:3:0.25]
thread_d = 10; //[5:20:0.5]
thread_h = 8; //[4:16:0.5]
shaft_d = 6; //[3:12:0.5]
neck_d = 7; //[3.5:14:0.5]
neck_h = 2; //[0:6:0.5]
flat_depth = 1; //[0:2.5:0.25]
spigot_enable = 0; //[0:1:1]
spigot_w = 6; //[3:12:0.5]
spigot_h = 3; //[1.5:6:0.5]
spigot_l = 4; //[2:8:0.5]
spigot_x = 8; //[0:16:0.5]

// Potentiometer - complete geometry
module potentiometer() {
  color("DimGray") {
    // Body sections (gangs)
    translate([0, 0, boss_h + (body_total_h + (gangs - 1) * gap_h) / 2 - eps])
      cylinder(r=body_d/2, h=body_total_h + (gangs - 1) * gap_h, center=true);

    // Wafer (if defined)
    translate([0, 0, boss_h + wafer_h/2 - eps])
      cylinder(r=(body_d/2) * 0.98, h=wafer_h, center=true);

    // Boss
    translate([0, 0, boss_h/2])
      cylinder(r=boss_d/2, h=boss_h, center=true);

    // Faceplate
    translate([0, 0, boss_h - face_t/2])
      cube([face_w, face_h, face_t], center=true);

    // Threaded bushing
    translate([0, 0, -thread_h/2 + eps])
      cylinder(r=thread_d/2, h=thread_h, center=true);

    // Shaft neck
    translate([0, 0, -thread_h - neck_h/2 + eps])
      cylinder(r=neck_d/2, h=neck_h, center=true);

    // Shaft
    difference() {
      translate([0, 0, -thread_h - neck_h - shaft_length/2 + eps])
        cylinder(r=shaft_d/2, h=shaft_length, center=true);
      // Shaft flat cut
      translate([0, shaft_d/2 - flat_depth, -thread_h - neck_h - shaft_length/2 + eps])
        cube([shaft_d*2, shaft_d*2, shaft_length + eps*2], center=true);
    }

    // Spigot (if enabled)
    if (spigot_enable) {
      translate([spigot_x, 0, boss_h + spigot_h/2 - eps])
        cube([spigot_l, spigot_w, spigot_h], center=true);
    }
  }
}

// Assembly
module assembly() {
  potentiometer();
}

assembly();