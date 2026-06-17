// Parameters
thread_diameter = 3.0; //[1.5:6.0:0.1]
overall_length = 20.0; //[10.0:40.0:0.5]
outer_diameter = 8.0; //[4.0:16.0:0.5]
thread_gender = 0; //[0:1:1]
thread_length_top = 10.0; //[5.0:20.0:0.5]
thread_length_bottom = 10.0; //[5.0:20.0:0.5]
through_thread = 1; //[0:1:1]
chamfer = 0.8; //[0.0:2.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
clearance = 0.2; //[0.0:0.6:0.05]

// Standoff - complete geometry
module standoff() {
  color("Silver") {
    // Main body with chamfers
    difference() {
      cylinder(h=overall_length, r=outer_diameter/2, center=true);
      translate([0, 0, overall_length/2 - chamfer/2])
        cylinder(h=chamfer, r1=outer_diameter/2, r2=outer_diameter/2 - chamfer, center=true);
      translate([0, 0, -overall_length/2 + chamfer/2])
        cylinder(h=chamfer, r1=outer_diameter/2 - chamfer, r2=outer_diameter/2, center=true);
    }
    
    // Threaded bore or stud
    if (thread_gender == 0) { // Female
      if (through_thread == 1) {
        translate([0, 0, 0])
          cylinder(h=overall_length + 2*overlap, r=(thread_diameter + clearance)/2, center=true);
      } else {
        difference() {
          translate([0, 0, overall_length/2 - (thread_length_top + overlap)/2])
            cylinder(h=thread_length_top + overlap, r=(thread_diameter + clearance)/2, center=true);
          translate([0, 0, -overall_length/2 + (thread_length_bottom + overlap)/2])
            cylinder(h=thread_length_bottom + overlap, r=(thread_diameter + clearance)/2, center=true);
        }
      }
    } else { // Male
      translate([0, 0, overall_length/2 + thread_length_top/2 - overlap])
        cylinder(h=thread_length_top, r=thread_diameter/2, center=true);
      translate([0, 0, -overall_length/2 - thread_length_bottom/2 + overlap])
        cylinder(h=thread_length_bottom, r=thread_diameter/2, center=true);
    }
  }
}

// Pillar - complete geometry
module pillar() {
  color("DimGray") {
    // Main body with chamfers
    difference() {
      cylinder(h=overall_length, r=outer_diameter/2, center=true);
      translate([0, 0, overall_length/2 - chamfer/2])
        cylinder(h=chamfer, r1=outer_diameter/2, r2=outer_diameter/2 - chamfer, center=true);
      translate([0, 0, -overall_length/2 + chamfer/2])
        cylinder(h=chamfer, r1=outer_diameter/2 - chamfer, r2=outer_diameter/2, center=true);
    }
  }
}

// Assembly
module assembly() {
  standoff();
  translate([0, 0, overall_length + 5]) pillar(); // Adjust position to connect
}

assembly();