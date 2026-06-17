// Parameters (match: A potentiometer: [12, 11, 6, 0.5])
type_0 = 12; //[6:24:1]
type_1 = 11; //[6:22:1]
type_2 = 6;  //[3:12:1]
type_3 = 0.5;//[0.25:2:0.25]

eps = 0.5;   //[0.25:2:0.25]  // overlap amount to guarantee connectivity

// Primary dims driven by the 4-tuple
body_d   = type_0;   // 12
body_h   = type_1;   // 11
shaft_d  = type_2;   // 6
detail_t = type_3;   // 0.5

// Derived/secondary dims (kept proportional and connected)
boss_d = body_d * 0.85;
boss_h = max(2, body_h * 0.18);

wafer_d = body_d;
wafer_t = max(2, body_h * 0.18);

face_plate_w = body_d + 2;
face_plate_h = body_d + 2;
face_plate_t = max(1.5, 3*detail_t);

thread_d = max(shaft_d + 1, body_d * 0.58);
thread_h = max(6, body_h * 0.55);

shaft_neck_d = shaft_d + 0.5;
shaft_neck_h = max(2, body_h * 0.18);

shaft_length = max(15, body_h * 1.35);
shaft_flat_depth = 1;

tab_w = max(3, body_d * 0.25);
tab_l = max(4, body_d * 0.33);
tab_t = max(1.5, 3*detail_t);

spigot_w = max(4, body_d * 0.33);
spigot_h = max(2, body_h * 0.18);
spigot_t = max(2, body_h * 0.18);
spigot_x_offset = body_d * 0.33;

$fn = 64;

// Potentiometer - ONE connected solid
module potentiometer() {
  union() {

    // Body centered at z=0
    cylinder(r=body_d/2, h=body_h, center=true);

    // Boss on top of body (overlap into body)
    translate([0, 0, body_h/2 + boss_h/2 - eps])
      cylinder(r=boss_d/2, h=boss_h, center=true);

    // Wafer above boss (overlap into boss)
    translate([0, 0, body_h/2 + boss_h + wafer_t/2 - 2*eps])
      cylinder(r=wafer_d/2, h=wafer_t, center=true);

    // Face plate at top of body (overlap into body)
    translate([0, 0, body_h/2 - face_plate_t/2 + eps])
      cube([face_plate_w, face_plate_h, face_plate_t], center=true);

    // Threaded bushing below body (overlap into body)
    translate([0, 0, -body_h/2 - thread_h/2 + eps])
      cylinder(r=thread_d/2, h=thread_h, center=true);

    // Shaft neck below thread (overlap into thread)
    translate([0, 0, -body_h/2 - thread_h - shaft_neck_h/2 + 2*eps])
      cylinder(r=shaft_neck_d/2, h=shaft_neck_h, center=true);

    // Shaft with flat below neck (overlap into neck)
    difference() {
      translate([0, 0, -body_h/2 - thread_h - shaft_neck_h - shaft_length/2 + 3*eps])
        cylinder(r=shaft_d/2, h=shaft_length, center=true);

      translate([0, shaft_d/2 - shaft_flat_depth,
                 -body_h/2 - thread_h - shaft_neck_h - shaft_length/2 + 3*eps])
        cube([shaft_d*1.2, shaft_d, shaft_length*1.1], center=true);
    }

    // Mounting tabs: ensure they intersect the face plate (not just touch)
    translate([face_plate_w/2 + tab_l/2 - 2*eps, 0, body_h/2 - face_plate_t/2 + eps])
      cube([tab_l, tab_w, tab_t], center=true);

    translate([-(face_plate_w/2 + tab_l/2 - 2*eps), 0, body_h/2 - face_plate_t/2 + eps])
      cube([tab_l, tab_w, tab_t], center=true);

    // Spigot on wafer edge (overlap into wafer)
    translate([spigot_x_offset, 0, body_h/2 + boss_h + wafer_t/2 - 2*eps])
      cube([spigot_w, spigot_h, spigot_t], center=true);
  }
}

potentiometer();