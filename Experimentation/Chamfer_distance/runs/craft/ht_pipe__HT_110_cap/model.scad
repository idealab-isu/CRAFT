// Parameters
primary_dimension_mm = 110; //[55:220:1]
pipe_od_mm = 110; //[55:220:1]
pipe_wall_mm = 3.2; //[1.6:6.4:0.1]
cap_wall_mm = 4; //[2:8:0.1]
cap_insertion_depth_mm = 45; //[22.5:90:1]
cap_top_thickness_mm = 5.5; //[2.75:11:0.5]
cap_flange_radial_mm = 6.6; //[3.3:13.2:0.2]
internal_stop_thickness_mm = 3; //[1.5:6:0.1]
internal_stop_radial_mm = 2.2; //[1.1:4.4:0.1]
lead_in_chamfer_depth_mm = 6.6; //[3.3:13.2:0.2]
interference_mm = 0.3; //[0.1:0.8:0.05]
interference_band_length_mm = 8.8; //[4.4:17.6:0.2]
interference_band_offset_from_mouth_mm = 11; //[5.5:22:0.5]
overlap_mm = 1; //[0.5:2:0.1]
pipe_length_ref_mm = 80; //[40:160:1]

// Ht Pipe - complete geometry
module ht_pipe() {
  color([0.0, 0.4, 0.2]) {
    difference() {
      cylinder(r=pipe_od_mm/2, h=pipe_length_ref_mm, center=true);
      translate([0, 0, -overlap_mm/2])
        cylinder(r=pipe_od_mm/2 - pipe_wall_mm, h=pipe_length_ref_mm + overlap_mm, center=true);
    }
  }
}

// Ht Cap - complete geometry
module ht_cap() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      union() {
        translate([0, 0, 0])
          cylinder(r=pipe_od_mm/2 + cap_wall_mm, h=cap_insertion_depth_mm + cap_top_thickness_mm, center=true);
        translate([0, 0, cap_insertion_depth_mm/2])
          cylinder(r=pipe_od_mm/2 + cap_wall_mm + cap_flange_radial_mm, h=cap_top_thickness_mm, center=true);
      }
      translate([0, 0, -cap_top_thickness_mm/2 - overlap_mm/2])
        cylinder(r=pipe_od_mm/2, h=cap_insertion_depth_mm + overlap_mm, center=true);
      translate([0, 0, -(cap_insertion_depth_mm + cap_top_thickness_mm)/2 + internal_stop_thickness_mm/2 - overlap_mm/2])
        cylinder(r=pipe_od_mm/2 - internal_stop_radial_mm, h=internal_stop_thickness_mm + overlap_mm, center=true);
      translate([0, 0, -(cap_insertion_depth_mm + cap_top_thickness_mm)/2 + lead_in_chamfer_depth_mm/2])
        cylinder(r1=pipe_od_mm/2 + cap_wall_mm + overlap_mm, r2=pipe_od_mm/2 - overlap_mm, h=lead_in_chamfer_depth_mm, center=true);
      translate([0, 0, -(cap_insertion_depth_mm + cap_top_thickness_mm)/2 + interference_band_offset_from_mouth_mm + interference_band_length_mm/2])
        cylinder(r=pipe_od_mm/2 - interference_mm, h=interference_band_length_mm, center=true);
    }
  }
}

// Rd Box Cap - complete geometry
module rd_box_cap() {
  color([0.1, 0.1, 0.6]) {
    translate([0, 0, cap_insertion_depth_mm/2 + cap_top_thickness_mm/2])
      cube([primary_dimension_mm*0.18, primary_dimension_mm*0.12, primary_dimension_mm*0.06], center=true);
  }
}

// Assembly
module assembly() {
  ht_cap();
  ht_pipe();
  rd_box_cap();
}

assembly();