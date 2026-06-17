// Parameters
length_mm = 10; //[5:20:1]
major_diameter_mm = 4; //[2:8:0.1]
minor_diameter_mm = 3.1; //[1.55:6.2:0.1]
thread_pitch_mm = 0.7; //[0.35:1.4:0.05]
socket_af_mm = 2; //[1:4:0.1]
socket_depth_mm = 2; //[1:4:0.1]
tolerance_mm = 0.1; //[0.05:0.3:0.01]
overlap_mm = 1; //[0.5:2:0.1]
thread_runout_len_mm = 1; //[0.5:2:0.1]
tip_chamfer_len_mm = 1; //[0.5:2:0.1]
major_radius_mm = 2; //[1:4:0.1]
minor_radius_mm = 1.55; //[0.775:3.1:0.1]
socket_radius_mm = 1.1547; //[0.577:2.3094:0.01]

// Screw - complete geometry
module screw() {
  color("DimGray") {
    // Grub screw body
    cylinder(r=major_diameter_mm/2, h=length_mm, center=true);

    // Threaded shaft
    translate([0, 0, -thread_runout_len_mm/2])
      cylinder(r=major_diameter_mm/2, h=length_mm - thread_runout_len_mm, center=true);

    // Thread runout
    translate([0, 0, length_mm/2 - thread_runout_len_mm/2])
      cylinder(r=minor_diameter_mm/2, h=thread_runout_len_mm + overlap_mm, center=true);

    // Chamfer or point tip
    translate([0, 0, -length_mm/2 + tip_chamfer_len_mm/2 - overlap_mm/2])
      rotate([180, 0, 0])
      cylinder(r1=major_diameter_mm/2, r2=0, h=tip_chamfer_len_mm, center=true);

    // Hex socket drive
    translate([0, 0, length_mm/2 - socket_depth_mm/2])
      difference() {
        cylinder(r=socket_radius_mm, h=socket_depth_mm + overlap_mm, center=true);
        rotate([0, 0, 0])
          cylinder(r=socket_radius_mm, h=socket_depth_mm + overlap_mm, center=true);
      }
  }
}

// Assembly
module assembly() {
  screw();
}

assembly();