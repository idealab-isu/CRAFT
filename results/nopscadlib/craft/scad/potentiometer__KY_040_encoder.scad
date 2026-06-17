// Parameters
body_width = 12; //[6:24:0.5]
body_depth = 12; //[6:24:0.5]
body_height = 6.5; //[3.25:13:0.25]
corner_radius = 1; //[0.5:2:0.1]
thickness = 3; //[1.5:6:0.5]
shaft_length = 15; //[7.5:30:0.5]
eps = 0.8; //[0.5:2:0.1]
boss_d = 7; //[3.5:14:0.5]
boss_h = 1.5; //[0.75:3:0.25]
thread_d = 7; //[4:12:0.5]
thread_h = 6; //[3:12:0.5]
shaft_d = 6; //[3:10:0.5]
face_plate_w = 14; //[10:28:0.5]
face_plate_d = 10; //[6:20:0.5]
face_plate_t = 1; //[0.5:2:0.1]
spigot_w = 4; //[2:8:0.5]
spigot_d = 3; //[1.5:6:0.5]
spigot_h = 2; //[1:4:0.25]
spigot_offset_x = 4; //[0:8:0.5]
wafer_count = 2; //[1:4:1]
wafer_t = 1; //[0.5:2:0.25]
tab_w = 2.5; //[1.5:5:0.25]
tab_d = 1.5; //[1:3:0.25]
tab_h = 1.2; //[0.6:2.4:0.1]

// Potentiometer - complete geometry
module potentiometer() {
  color("DimGray") {
    // Body with rounded corners
    minkowski() {
      translate([0, 0, 0])
        cube([body_width - 2*corner_radius, body_depth - 2*corner_radius, body_height], center=true);
      sphere(r=corner_radius, center=true);
    }
    
    // Boss
    translate([0, 0, body_height/2 + boss_h/2 - eps])
      cylinder(r=boss_d/2, h=boss_h, center=true);
    
    // Threaded bushing
    translate([0, 0, body_height/2 + boss_h + thread_h/2 - eps])
      cylinder(r=thread_d/2, h=thread_h, center=true);
    
    // Shaft
    translate([0, 0, body_height/2 + boss_h + thread_h + shaft_length/2 - eps])
      cylinder(r=shaft_d/2, h=shaft_length, center=true);
    
    // Face plate
    translate([0, 0, body_height/2 + face_plate_t/2 - eps])
      cube([face_plate_w, face_plate_d, face_plate_t], center=true);
    
    // Mounting spigot
    translate([spigot_offset_x, 0, body_height/2 + spigot_h/2 - eps])
      cube([spigot_w, spigot_d, spigot_h], center=true);
    
    // Wafer sections
    for (i = [0:wafer_count-1]) {
      translate([0, 0, -body_height/2 + wafer_t/2 + (i+1)*(body_height - wafer_count*wafer_t)/(wafer_count+1) + i*wafer_t])
        cube([body_width - 2*corner_radius, body_depth - 2*corner_radius, wafer_t], center=true);
    }
    
    // Anti-rotation tabs
    translate([-(face_plate_w/2 + tab_w/2 - eps), 0, body_height/2 + tab_h/2 - eps])
      cube([tab_w, tab_d, tab_h], center=true);
    translate([face_plate_w/2 + tab_w/2 - eps, 0, body_height/2 + tab_h/2 - eps])
      cube([tab_w, tab_d, tab_h], center=true);
  }
}

// Assembly
module assembly() {
  potentiometer();
}

assembly();