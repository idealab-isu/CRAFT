// Parameters
shank_diameter = 6; //[3:12:0.1]
head_diameter = 12; //[6:24:0.1]
length = 10; //[5:20:0.1]
head_height = 6; //[3:12:0.1]
socket_af = 5; //[2.5:10:0.1]
socket_depth = 4; //[2:8:0.1]
thread_length = 10; //[5:20:0.1]
thread_minor_diameter = 5.2; //[2.6:10.4:0.1]
washer_outer_diameter = 12; //[6:24:0.1]
washer_thickness = 1.5; //[0.8:3:0.1]
washer_hole_diameter = 6.5; //[3.5:13:0.1]
overlap = 1; //[0.5:2:0.1]

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Screw Body with Thread
    union() {
      translate([0, 0, -length/2])
        cylinder(h=length, r=shank_diameter/2, center=true, $fn=32);
      translate([0, 0, -thread_length/2])
        cylinder(h=thread_length, r=thread_minor_diameter/2, center=true, $fn=32);
    }
    
    // Cylindrical Head
    translate([0, 0, head_height/2 - overlap])
      cylinder(h=head_height, r=head_diameter/2, center=true, $fn=32);
    
    // Hex Socket Recess
    difference() {
      translate([0, 0, head_height - socket_depth/2])
        cylinder(h=socket_depth + 2*overlap, r=socket_af/(2*cos(30)), center=true, $fn=6);
    }
  }
  
  // Washer
  color("Silver") {
    difference() {
      translate([0, 0, -washer_thickness/2 + overlap])
        cylinder(h=washer_thickness, r=washer_outer_diameter/2, center=true, $fn=32);
      translate([0, 0, -washer_thickness/2 + overlap])
        cylinder(h=washer_thickness + 2*overlap, r=washer_hole_diameter/2, center=true, $fn=32);
    }
  }
}

// Assembly
module assembly() {
  screw_and_washer();
}

assembly();