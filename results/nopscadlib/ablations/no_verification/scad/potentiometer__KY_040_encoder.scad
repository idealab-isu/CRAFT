// Parameters
type_vector_0 = 12; //[6:24:0.5]
type_vector_1 = 12; //[6:24:0.5]
type_vector_2 = 6.5; //[3.25:13:0.25]
type_vector_3 = 1; //[0.5:2:0.1]
thickness = 3; //[1.5:6:0.5]
shaft_length = 15; //[7.5:30:0.5]
value = 0; //[0:1:1]
eps = 0.8; //[0.5:2:0.1]
body_w = 12; //[6:24:0.5]
body_d = 12; //[6:24:0.5]
body_h = 6.5; //[3.25:13:0.25]
corner_r = 1; //[0.5:2:0.1]
wafer_h = 1.2; //[0.6:2.4:0.1]
face_w = 14; //[7:28:0.5]
face_d = 14; //[7:28:0.5]
face_h = 1.5; //[0.8:3:0.1]
boss_d = 10; //[5:20:0.5]
boss_h = 2; //[1:4:0.1]
thread_d = 7; //[3.5:14:0.25]
thread_h = 6; //[3:12:0.25]
shaft_d = 6; //[3:12:0.25]
neck_d = 5; //[2.5:10:0.25]
neck_h = 2; //[1:4:0.1]
spigot_w = 3; //[1.5:6:0.25]
spigot_d = 2; //[1:4:0.25]
spigot_h = 1.5; //[0.8:3:0.1]
spigot_x_offset = 4; //[2:8:0.25]
tab_w = 2.5; //[1.25:5:0.25]
tab_d = 1.5; //[0.8:3:0.1]
tab_h = 1.2; //[0.6:2.4:0.1]

// Potentiometer - complete geometry
module potentiometer() {
  color([0.15, 0.2, 0.35]) {
    // Potentiometer Body
    translate([0, 0, 0])
      cube([body_w, body_d, body_h], center=true);

    // Wafer Section
    translate([0, 0, body_h/2 + wafer_h/2 - eps])
      cube([body_w, body_d, wafer_h], center=true);

    // Mounting Boss
    translate([0, 0, -body_h/2 - boss_h/2 + eps])
      cylinder(r=boss_d/2, h=boss_h, center=true);

    // Mounting Face Plate
    translate([0, 0, -body_h/2 - boss_h - face_h/2 + eps])
      cube([face_w, face_d, face_h], center=true);

    // Threaded Bushing
    translate([0, 0, -body_h/2 - boss_h - face_h - thread_h/2 + eps])
      cylinder(r=thread_d/2, h=thread_h, center=true);

    // Shaft Neck
    translate([0, 0, -body_h/2 - boss_h - face_h - thread_h - neck_h/2 + eps])
      cylinder(r=neck_d/2, h=neck_h, center=true);

    // Shaft
    translate([0, 0, -body_h/2 - boss_h - face_h - thread_h - neck_h - shaft_length/2 + eps])
      cylinder(r=shaft_d/2, h=shaft_length, center=true);

    // Anti-Rotation Spigot
    translate([spigot_x_offset, 0, -body_h/2 - boss_h - face_h/2 + eps])
      cube([spigot_w, spigot_d, spigot_h], center=true);

    // Retention Tabs
    union() {
      translate([body_w/2 + tab_d/2 - eps, 0, body_h/2 - tab_h/2])
        cube([tab_d, tab_w, tab_h], center=true);
      translate([-(body_w/2 + tab_d/2 - eps), 0, body_h/2 - tab_h/2])
        cube([tab_d, tab_w, tab_h], center=true);
      translate([0, body_d/2 + tab_d/2 - eps, body_h/2 - tab_h/2])
        cube([tab_w, tab_d, tab_h], center=true);
      translate([0, -(body_d/2 + tab_d/2 - eps), body_h/2 - tab_h/2])
        cube([tab_w, tab_d, tab_h], center=true);
    }
  }
}

// Assembly
module assembly() {
  potentiometer();
}

assembly();