// Parameters
thread_diameter_mm = 5; //[2.5:10:0.1]
thread_pitch_mm = 0.8; //[0.4:1.6:0.05]
shank_length_mm = 25; //[12.5:50:0.5]
overall_length_mm = 40; //[20:80:0.5]
eye_outer_diameter_mm = 16; //[8:32:0.5]
eye_width_mm = 8; //[4:16:0.25]
eye_bore_diameter_mm = 5.2; //[3:10:0.05]
ball_sphere_diameter_mm = 10; //[6:20:0.25]
misalignment_angle_deg = 12; //[0:25:1]
chamfer_mm = 0.8; //[0.2:2:0.1]
tolerances_thread_clearance_mm = 0.15; //[0.05:0.4:0.01]
tolerances_bore_clearance_mm = 0.1; //[0.02:0.3:0.01]
outer_race_rim_mm = 1.2; //[0.6:2.4:0.1]
liner_thickness_mm = 0.6; //[0.3:1.2:0.05]
housing_neck_diameter_mm = 8; //[4:16:0.25]
housing_neck_length_mm = 6; //[3:12:0.25]
thread_runout_length_mm = 2; //[1:5:0.25]
overlap_mm = 1; //[0.5:2:0.1]
rod_diameter_mm = 5; //[2.5:10:0.1]
rod_length_mm = 20; //[10:60:0.5]

// Rod - complete geometry
module rod() {
  color("Silver") {
    cylinder(r=rod_diameter_mm/2, h=rod_length_mm, center=true, $fn=32);
  }
}

// Rod End Bearing - complete geometry
module rod_end_bearing() {
  color("DimGray") {
    // Eye outer
    cylinder(r=eye_outer_diameter_mm/2, h=eye_width_mm, center=true, $fn=64);
    
    // Neck
    translate([eye_outer_diameter_mm/2 + housing_neck_length_mm/2 - overlap_mm, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=housing_neck_diameter_mm/2, h=housing_neck_length_mm, center=true, $fn=32);
    
    // Threaded shank
    translate([eye_outer_diameter_mm/2 + housing_neck_length_mm - overlap_mm + shank_length_mm/2, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=(thread_diameter_mm - tolerances_thread_clearance_mm)/2, h=shank_length_mm, center=true, $fn=32);
    
    // Thread runout relief
    translate([eye_outer_diameter_mm/2 + housing_neck_length_mm - overlap_mm + thread_runout_length_mm/2, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=(thread_diameter_mm - tolerances_thread_clearance_mm)/2 - thread_pitch_mm*0.15, h=thread_runout_length_mm, center=true, $fn=32);
    
    // Eye through bore
    translate([0, 0, 0])
      rotate([90, 0, 0])
      cylinder(r=eye_bore_diameter_mm/2, h=eye_width_mm + overlap_mm*2, center=true, $fn=32);
    
    // Spherical bearing eye ball
    sphere(r=ball_sphere_diameter_mm/2, center=true, $fn=64);
    
    // Bearing shields or liners
    difference() {
      cylinder(r=eye_outer_diameter_mm/2 - outer_race_rim_mm, h=eye_width_mm - chamfer_mm*2, center=true, $fn=64);
      sphere(r=ball_sphere_diameter_mm/2 + tolerances_bore_clearance_mm, center=true, $fn=64);
    }
    
    // Outer race rim
    difference() {
      cylinder(r=eye_outer_diameter_mm/2, h=eye_width_mm, center=true, $fn=64);
      cylinder(r=eye_outer_diameter_mm/2 - outer_race_rim_mm, h=eye_width_mm + overlap_mm*2, center=true, $fn=64);
    }
    
    // Chamfers
    hull() {
      cylinder(r=eye_outer_diameter_mm/2 - chamfer_mm, h=eye_width_mm, center=true, $fn=64);
      translate([eye_outer_diameter_mm/2 + housing_neck_length_mm/2 - overlap_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=housing_neck_diameter_mm/2 - chamfer_mm*0.5, h=housing_neck_length_mm, center=true, $fn=32);
    }
  }
}

// Assembly
module assembly() {
  rod();
  translate([eye_outer_diameter_mm/2 + housing_neck_length_mm - overlap_mm + shank_length_mm + rod_length_mm/2 - overlap_mm, 0, 0])
    rod_end_bearing();
}

assembly();