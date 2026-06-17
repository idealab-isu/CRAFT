// Parameters
type_0 = 12; //[6:24:1]
type_1 = 11; //[6:22:1]
type_2 = 6; //[3:12:1]
type_3 = 0.5; //[0.25:1:0.05]
thickness = 3; //[1.5:6:0.5]
shaft_length = 15; //[7.5:30:1]
overlap = 1; //[0.5:2:0.1]
body_d = 12; //[6:24:1]
body_h = 11; //[5.5:22:1]
wafer_h = 2; //[1:4:0.5]
face_plate_h = 1.5; //[0.8:3:0.1]
face_plate_d = 14; //[7:28:1]
boss_d = 10; //[5:20:1]
boss_h = 2; //[1:5:0.5]
thread_d = 7; //[3.5:14:0.5]
thread_h = 6; //[3:12:0.5]
shaft_d = 6; //[3:12:0.5]
shaft_neck_d = 5; //[2.5:10:0.5]
shaft_neck_h = 2; //[0:6:0.5]
tab_w = 3; //[1.5:6:0.5]
tab_l = 4; //[2:8:0.5]
tab_t = 1; //[0.5:2.5:0.1]

// Potentiometer - complete geometry
module potentiometer() {
  union() {
    // Potentiometer Body
    color("DimGray")
    translate([0, 0, 0])
      cylinder(r=body_d/2, h=body_h, center=true);

    // Wafer Section
    color("Silver")
    translate([0, 0, (-body_h/2) + (wafer_h/2) + overlap])
      cylinder(r=(body_d/2) - type_3, h=wafer_h, center=true);

    // Face Plate
    color("Silver")
    translate([0, 0, (body_h/2) - (face_plate_h/2) - overlap])
      cylinder(r=face_plate_d/2, h=face_plate_h, center=true);

    // Boss
    color("Silver")
    translate([0, 0, (body_h/2) + (boss_h/2) - overlap])
      cylinder(r=boss_d/2, h=boss_h, center=true);

    // Threaded Bushing
    color("Silver")
    translate([0, 0, (body_h/2) + boss_h + (thread_h/2) - overlap])
      cylinder(r=thread_d/2, h=thread_h, center=true);

    // Shaft Neck
    color("Silver")
    translate([0, 0, (body_h/2) + boss_h + thread_h + (shaft_neck_h/2) - overlap])
      cylinder(r=shaft_neck_d/2, h=shaft_neck_h, center=true);

    // Shaft
    color("Silver")
    translate([0, 0, (body_h/2) + boss_h + thread_h + shaft_neck_h + (shaft_length/2) - overlap])
      cylinder(r=shaft_d/2, h=shaft_length, center=true);

    // Mounting Tab Positive X
    color("Silver")
    translate([(body_d/2) + (tab_l/2) - overlap, 0, (body_h/2) - (tab_t/2) - overlap])
      cube([tab_l, tab_w, tab_t], center=true);

    // Mounting Tab Negative X
    color("Silver")
    translate([-((body_d/2) + (tab_l/2) - overlap), 0, (body_h/2) - (tab_t/2) - overlap])
      cube([tab_l, tab_w, tab_t], center=true);
  }
}

// Assembly
module assembly() {
  potentiometer();
}

assembly();