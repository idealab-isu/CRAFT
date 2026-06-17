// Parameters
outer_diameter = 5.8; //[2.9:11.6:0.1]
length = 7.1; //[3.55:14.2:0.1]
screw_diameter = 5; //[2.5:10:0.1]
thread_pitch = 0.8; //[0.4:1.6:0.05]
internal_thread_diameter = 4.2; //[3.5:5:0.05]
chamfer_length = 0.5; //[0.25:1:0.05]
chamfer_angle_deg = 45; //[30:60:1]
overlap = 0.8; //[0.5:2:0.1]

// Threaded Insert - complete geometry
module threaded_insert() {
  color("Brass") {
    // Insert body with chamfers
    union() {
      // Main cylindrical body
      translate([0, 0, 0])
        cylinder(r=outer_diameter/2, h=length, center=true, $fn=64);
      
      // Lead-in chamfer
      translate([0, 0, length/2 - (chamfer_length + overlap)/2])
        cylinder(r1=outer_diameter/2, r2=outer_diameter/2 - chamfer_length, h=chamfer_length + overlap, center=true, $fn=64);
      
      // Installation end chamfer
      translate([0, 0, -length/2 + (chamfer_length + overlap)/2])
        cylinder(r1=outer_diameter/2 - chamfer_length, r2=outer_diameter/2, h=chamfer_length + overlap, center=true, $fn=64);
    }
    
    // Internal thread interface (clearance hole)
    difference() {
      translate([0, 0, 0])
        cylinder(r=internal_thread_diameter/2, h=length + 2*overlap, center=true, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();