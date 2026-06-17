// Parameters
type_vector_0 = 12; //[6:24:1]
type_vector_1 = 11; //[5.5:22:0.5]
type_vector_2 = 6; //[3:12:0.5]
type_vector_3 = 0.5; //[0.25:1:0.05]
thickness = 3; //[1.5:6:0.5]
shaft_length = 15; //[7.5:30:0.5]
value_flag = 0; //[0:1:1]
eps = 0.8; //[0.5:2:0.1]
panel_clearance = 0.5; //[0.2:1.5:0.1]
pot_body_d = 24; //[12:48:1]
pot_body_h = 16; //[8:32:1]
boss_d = 16; //[8:32:0.5]
boss_h = 2.5; //[1.25:5:0.25]
thread_d = 7; //[3.5:14:0.25]
thread_h = 8; //[4:16:0.5]
shaft_d = 6; //[3:12:0.5]
shaft_neck_d = 6; //[3:12:0.5]
shaft_neck_h = 2; //[0:6:0.5]
shaft_flat_depth = 1; //[0:3:0.25]
shaft_flat_h = 8; //[0:20:0.5]

// Potentiometer - complete geometry
module potentiometer() {
  color("DimGray") {
    // Potentiometer Body
    translate([0, 0, -(pot_body_h/2 + boss_h - eps)])
      cylinder(r=pot_body_d/2, h=pot_body_h, center=true, $fn=64);
    
    // Mounting Boss
    translate([0, 0, -boss_h/2])
      cylinder(r=boss_d/2, h=boss_h, center=true, $fn=64);
    
    // Threaded Bushing
    translate([0, 0, thread_h/2 - eps])
      cylinder(r=thread_d/2, h=thread_h, center=true, $fn=64);
    
    // Shaft Neck
    translate([0, 0, thread_h - eps + shaft_neck_h/2])
      cylinder(r=shaft_neck_d/2, h=shaft_neck_h, center=true, $fn=64);
    
    // Shaft Main
    difference() {
      translate([0, 0, thread_h - eps + shaft_neck_h - eps + shaft_length/2])
        cylinder(r=shaft_d/2, h=shaft_length, center=true, $fn=64);
      
      // Shaft Flat Cutter
      translate([0, (shaft_d/2 - shaft_flat_depth), thread_h - eps + shaft_neck_h - eps + (shaft_length - shaft_flat_h)/2 + shaft_flat_h/2])
        cube([shaft_d*2, shaft_d, shaft_flat_h], center=true);
    }
  }
}

// Assembly
module assembly() {
  potentiometer();
}

assembly();