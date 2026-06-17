// Parameters
body_width = 12; //[6:24:0.5]
body_depth = 12; //[6:24:0.5]
body_height = 6.5; //[3.25:13:0.25]
body_rounding_radius = 1; //[0.5:2:0.1]
panel_thickness = 3; //[1.5:6:0.5]
shaft_length = 15; //[7.5:30:0.5]
overlap = 1; //[0.5:2:0.1]
boss_diameter = 7; //[3.5:14:0.25]
boss_height = 2; //[1:4:0.25]
thread_diameter = 7; //[3.5:14:0.25]
thread_height = 6; //[3:12:0.5]
shaft_diameter = 6; //[3:12:0.25]
wafer_thickness = 1; //[0.5:2:0.1]
wafer_scale = 0.92; //[0.8:1:0.01]
spigot_diameter = 2; //[1:4:0.1]
spigot_height = 1.5; //[0.75:3:0.1]
spigot_offset_x = 4; //[2:8:0.25]

// Potentiometer - complete geometry
module potentiometer() {
  color("DimGray") {
    // Potentiometer Body
    translate([0, 0, -(boss_height + body_height / 2)])
      minkowski() {
        cube([body_width - 2 * body_rounding_radius, body_depth - 2 * body_rounding_radius, body_height - 2 * body_rounding_radius], center=true);
        sphere(r=body_rounding_radius, center=true);
      }
    
    // Mounting Boss/Bushing
    translate([0, 0, -boss_height / 2])
      cylinder(r=boss_diameter / 2, h=boss_height, center=true, $fn=32);
    
    // Threaded Bushing
    translate([0, 0, thread_height / 2 - overlap])
      cylinder(r=thread_diameter / 2, h=thread_height, center=true, $fn=32);
    
    // Shaft
    translate([0, 0, thread_height + shaft_length / 2 - 2 * overlap])
      cylinder(r=shaft_diameter / 2, h=shaft_length, center=true, $fn=32);
    
    // Face Plate/Wafer
    translate([0, 0, -boss_height - wafer_thickness / 2 + overlap])
      cube([body_width * wafer_scale, body_depth * wafer_scale, wafer_thickness], center=true);
    
    // Anti-Rotation Spigot
    translate([spigot_offset_x, 0, -boss_height + spigot_height / 2 - overlap])
      cylinder(r=spigot_diameter / 2, h=spigot_height, center=true, $fn=32);
  }
}

// Assembly
module assembly() {
  potentiometer();
}

assembly();