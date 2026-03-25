// Parameters
outer_diameter_mm = 15; //[7.5:30:0.1]
length_mm = 12; //[6:24:0.1]
screw_diameter_mm = 6; //[3:12:0.1]
thread_clearance_mm = 0.4; //[0.1:1:0.05]
chamfer_mm = 0.5; //[0.2:2:0.1]
rib_count = 24; //[8:60:1]
rib_radial_height_mm = 0.6; //[0.2:1.5:0.05]
rib_tangential_width_mm = 1.2; //[0.5:3:0.1]
rib_length_mm = 10.5; //[5:22:0.1]
rib_end_margin_mm = 0.75; //[0.3:2:0.05]
overlap_mm = 1; //[0.5:2:0.1]

// Module for the heat-set insert
module insert() {
  color("Brass") {
    // Main body
    cylinder(r=outer_diameter_mm/2, h=length_mm, center=true, $fn=64);
    
    // Lead-in chamfer
    translate([0, 0, length_mm/2 - chamfer_mm/2])
      cylinder(r1=outer_diameter_mm/2, r2=outer_diameter_mm/2 - chamfer_mm, h=chamfer_mm, center=true, $fn=64);
    
    // Installation end chamfer
    translate([0, 0, -length_mm/2 + chamfer_mm/2])
      cylinder(r1=outer_diameter_mm/2 - chamfer_mm, r2=outer_diameter_mm/2, h=chamfer_mm, center=true, $fn=64);
    
    // Ribs
    for (i = [0:rib_count-1]) {
      rotate([0, 0, i*360/rib_count])
        translate([outer_diameter_mm/2 - overlap_mm + (rib_radial_height_mm + overlap_mm)/2, 0, 0])
        cube([rib_radial_height_mm + overlap_mm, rib_tangential_width_mm, rib_length_mm], center=true);
    }
  }
}

// Module for the threaded insert
module threaded_insert() {
  difference() {
    insert();
    // Internal thread bore
    color("Silver") {
      cylinder(r=(screw_diameter_mm + thread_clearance_mm)/2, h=length_mm + 2*overlap_mm, center=true, $fn=64);
    }
  }
}

// Assembly of the insert
module assembly() {
  threaded_insert();
}

assembly();