// Parameters
outer_diameter_mm = 3.0; //[1.5:6.0:0.1]
length_mm = 4.6; //[2.3:9.2:0.1]
screw_nominal_diameter_mm = 3.0; //[1.5:6.0:0.1]
internal_thread_pitch_mm = 0.5; //[0.25:1.0:0.05]
internal_thread_class = 6; //[4:8:1]
lead_in_chamfer_angle_deg = 30; //[15:60:1]
end_chamfer_mm = 0.2; //[0.1:0.6:0.05]
thread_minor_diameter_mm = 2.5; //[2.2:2.8:0.05]
thread_bore_extra_clearance_mm = 0.1; //[0.0:0.3:0.05]
overlap_mm = 0.8; //[0.5:2.0:0.1]

// Threaded Insert - complete geometry
module threaded_insert() {
  color("Brass") {
    difference() {
      // Insert body
      translate([0, 0, 0])
        cylinder(r=outer_diameter_mm/2, h=length_mm, center=true, $fn=64);
      
      // Installation lead-in chamfer
      translate([0, 0, length_mm/2 - end_chamfer_mm/2])
        cylinder(r1=outer_diameter_mm/2, r2=0, h=end_chamfer_mm, center=true, $fn=64);
      
      // End face chamfer
      translate([0, 0, -length_mm/2 + end_chamfer_mm/2])
        cylinder(r1=outer_diameter_mm/2, r2=0, h=end_chamfer_mm, center=true, $fn=64);
      
      // Internal thread bore
      translate([0, 0, 0])
        cylinder(r=(thread_minor_diameter_mm + thread_bore_extra_clearance_mm)/2, h=length_mm + 2*overlap_mm, center=true, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();