// Parameters
thread_diameter_mm = 4; //[2:8:0.1]
length_mm = 10; //[5:20:0.5]
head_diameter_mm = 8; //[4:16:0.1]
head_height_mm = 4; //[2:8:0.1]
socket_across_flats_mm = 3; //[1.5:6:0.1]
socket_depth_mm = 2.5; //[1:6:0.1]
washer_outer_diameter_mm = 9; //[6:18:0.1]
washer_inner_diameter_mm = 4.5; //[3:9:0.1]
washer_thickness_mm = 1; //[0.5:3:0.1]
overlap_mm = 0.8; //[0.5:2:0.1]

// Screw and Washer - Complete Geometry
module screw_and_washer() {
  // Screw
  color("DimGray") {
    union() {
      // Threaded Shaft
      translate([0, 0, -length_mm/2])
        cylinder(h=length_mm, r=thread_diameter_mm/2, center=true);
      
      // Cylindrical Head
      translate([0, 0, head_height_mm/2 - overlap_mm])
        cylinder(h=head_height_mm, r=head_diameter_mm/2, center=true);
    }
    
    // Hex Socket Recess
    translate([0, 0, head_height_mm - socket_depth_mm/2])
      rotate([0, 0, 0])
      difference() {
        cylinder(h=socket_depth_mm + overlap_mm, r=socket_across_flats_mm/(2*cos(30)), center=true);
      }
  }
  
  // Washer
  color("Silver") {
    translate([0, 0, head_height_mm - overlap_mm]) {
      difference() {
        // Washer Outer
        cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true);
        
        // Washer Hole
        translate([0, 0, 0])
          cylinder(h=washer_thickness_mm + 2*overlap_mm, r=washer_inner_diameter_mm/2, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  screw_and_washer();
}

assembly();