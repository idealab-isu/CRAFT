// Parameters
outer_diameter_mm = 25.0; //[12.5:50.0:0.1]
length_mm = 18.5; //[9.25:37.0:0.1]
screw_nominal_diameter_mm = 10.0; //[5.0:20.0:0.1]
internal_thread_pitch_mm = 1.5; //[0.5:3.0:0.1]
thread_clearance_mm = 0.4; //[0.0:1.0:0.05]
top_chamfer_mm = 0.5; //[0.0:2.0:0.1]
bottom_chamfer_mm = 0.5; //[0.0:2.0:0.1]
thread_start_lead_in_mm = 1.0; //[0.0:4.0:0.1]
overlap_mm = 0.8; //[0.2:2.0:0.1]

// Threaded Insert - complete geometry
module threaded_insert() {
  color("Brass") {
    difference() {
      // Insert body
      cylinder(r=outer_diameter_mm/2, h=length_mm, center=true, $fn=64);
      
      // Internal thread bore
      cylinder(r=(screw_nominal_diameter_mm + thread_clearance_mm)/2, 
               h=length_mm + 2*overlap_mm, center=true, $fn=64);
      
      // Lead-in chamfer
      translate([0, 0, -length_mm/2 + (thread_start_lead_in_mm + overlap_mm)/2 - overlap_mm])
        rotate([180, 0, 0])
        cylinder(r1=(screw_nominal_diameter_mm + thread_clearance_mm)/2 + thread_start_lead_in_mm, 
                 r2=(screw_nominal_diameter_mm + thread_clearance_mm)/2, 
                 h=thread_start_lead_in_mm + overlap_mm, center=true, $fn=64);
      
      // Installation end chamfer
      translate([0, 0, -length_mm/2 + (bottom_chamfer_mm + overlap_mm)/2 - overlap_mm])
        rotate([180, 0, 0])
        cylinder(r1=outer_diameter_mm/2, r2=outer_diameter_mm/2 - bottom_chamfer_mm, 
                 h=bottom_chamfer_mm + overlap_mm, center=true, $fn=64);
      
      // Top end chamfer
      translate([0, 0, length_mm/2 - (top_chamfer_mm + overlap_mm)/2 + overlap_mm])
        cylinder(r1=outer_diameter_mm/2, r2=outer_diameter_mm/2 - top_chamfer_mm, 
                 h=top_chamfer_mm + overlap_mm, center=true, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();