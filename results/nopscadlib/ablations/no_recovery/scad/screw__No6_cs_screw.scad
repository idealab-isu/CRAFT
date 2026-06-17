// Parameters
shaft_diameter_mm = 3.5; //[1.75:7:0.05]
length_mm = 10; //[5:20:0.5]
head_diameter_mm = 7; //[3.5:14:0.1]
head_height_mm = 3; //[1.5:6:0.1]
threaded = 1; //[0:1:1]
thread_pitch_mm = 0.6; //[0.3:1.2:0.05]
thread_depth_mm = 0.2; //[0.05:0.5:0.01]
thread_ring_thickness_mm = 0.25; //[0.1:0.6:0.01]
thread_ring_count = 12; //[4:30:1]
washer_outer_diameter_mm = 8; //[4:16:0.1]
washer_thickness_mm = 1; //[0.5:2:0.05]
tolerance_mm = 0; //[0:0.5:0.01]
overlap_mm = 0.8; //[0.5:2:0.1]

// Screw and Washer - Complete Geometry
module screw_and_washer() {
  color("DimGray") {
    // Screw Shaft
    translate([0, 0, -length_mm/2])
      cylinder(h=length_mm, r=shaft_diameter_mm/2 + tolerance_mm, center=true);

    // Screw Head
    translate([0, 0, head_height_mm/2 - overlap_mm])
      cylinder(h=head_height_mm, r=head_diameter_mm/2 + tolerance_mm, center=true);

    // Washer
    difference() {
      translate([0, 0, -washer_thickness_mm/2 + overlap_mm])
        cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2 + tolerance_mm, center=true);
      translate([0, 0, -washer_thickness_mm/2 + overlap_mm])
        cylinder(h=washer_thickness_mm + 2*overlap_mm, r=shaft_diameter_mm/2 + tolerance_mm, center=true);
    }

    // Thread Representation
    if (threaded) {
      for (i = [0:thread_ring_count-1]) {
        translate([0, 0, -(thread_pitch_mm*i + thread_ring_thickness_mm/2)])
          cylinder(h=thread_ring_thickness_mm, r=shaft_diameter_mm/2 + tolerance_mm + thread_depth_mm, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  screw_and_washer();
}

assembly();