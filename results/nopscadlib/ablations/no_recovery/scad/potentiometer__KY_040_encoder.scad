// Parameters
body_width = 12; //[6:24:0.5]
body_depth = 12; //[6:24:0.5]
body_height = 6.5; //[3.25:13:0.25]
body_corner_radius = 1; //[0.5:2:0.1]
mounting_thickness = 3; //[1.5:6:0.5]
boss_diameter = 9; //[6:14:0.5]
boss_height = 2; //[1:4:0.25]
thread_diameter = 7; //[5:12:0.5]
thread_height = 6; //[3:12:0.5]
shaft_diameter = 6; //[3:10:0.5]
shaft_length = 15; //[7.5:30:0.5]
face_plate_width = 14; //[10:28:0.5]
face_plate_depth = 14; //[10:28:0.5]
face_plate_thickness = 1; //[0.5:3:0.25]
wafer_thickness = 1.2; //[0.6:2.4:0.1]
wafer_margin = 0.6; //[0.3:1.5:0.1]
lug_width = 1.2; //[0.6:2.4:0.1]
lug_thickness = 0.8; //[0.4:1.6:0.1]
lug_length = 4; //[2:8:0.5]
lug_spacing = 2.5; //[1.5:5:0.25]
overlap = 0.8; //[0.5:2:0.1]
fillet_sphere_radius = 0.6; //[0.3:1.2:0.1]

// Potentiometer - complete geometry
module potentiometer() {
  color([0.85, 0.85, 0.8]) {
    // Body with rounded corners
    minkowski() {
      translate([0, 0, 0])
        cube([body_width - 2 * fillet_sphere_radius, body_depth - 2 * fillet_sphere_radius, body_height - 2 * fillet_sphere_radius], center=true);
      sphere(r=fillet_sphere_radius, center=true);
    }
    
    // Mounting boss thread
    translate([0, 0, body_height/2 + thread_height/2 - overlap])
      cylinder(r=thread_diameter/2, h=thread_height, center=true);
    
    // Mounting boss collar
    translate([0, 0, body_height/2 + boss_height/2 - overlap])
      cylinder(r=boss_diameter/2, h=boss_height, center=true);
    
    // Shaft
    translate([0, 0, body_height/2 + thread_height + shaft_length/2 - overlap])
      cylinder(r=shaft_diameter/2, h=shaft_length, center=true);
    
    // Face plate
    translate([0, 0, body_height/2 + face_plate_thickness/2 - overlap])
      cube([face_plate_width, face_plate_depth, face_plate_thickness], center=true);
    
    // Wafer section
    translate([0, 0, -body_height/2 + wafer_thickness/2 + overlap])
      cube([body_width - 2 * wafer_margin, body_depth - 2 * wafer_margin, wafer_thickness], center=true);
    
    // Solder lugs/pins
    union() {
      translate([0, 0, -body_height/2 - lug_length/2 + overlap])
        cube([lug_width, lug_thickness, lug_length], center=true);
      translate([-lug_spacing, 0, -body_height/2 - lug_length/2 + overlap])
        cube([lug_width, lug_thickness, lug_length], center=true);
      translate([lug_spacing, 0, -body_height/2 - lug_length/2 + overlap])
        cube([lug_width, lug_thickness, lug_length], center=true);
    }
  }
}

// Assembly
module assembly() {
  potentiometer();
}

assembly();