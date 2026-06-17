// Parameters
shank_diameter_mm = 6.0; //[3.0:12.0:0.1]
head_diameter_mm = 12.0; //[6.0:24.0:0.1]
length_mm = 10.0; //[5.0:30.0:0.5]
head_height_mm = 6.0; //[3.0:12.0:0.1]
socket_hex_af_mm = 5.0; //[2.5:10.0:0.1]
socket_depth_mm = 4.0; //[2.0:8.0:0.1]
thread_pitch_mm = 1.0; //[0.5:2.0:0.05]
thread_length_mm = 7.0; //[3.0:20.0:0.5]
thread_representation = 1; //[0:1:1]
washer_outer_diameter_mm = 14.0; //[8.0:28.0:0.1]
washer_thickness_mm = 1.0; //[0.5:3.0:0.1]
washer_hole_diameter_mm = 6.5; //[6.1:13.0:0.1]
overlap_mm = 0.8; //[0.2:2.0:0.1]
tip_chamfer_height_mm = 1.0; //[0.5:2.5:0.1]
tip_chamfer_reduction_mm = 1.0; //[0.3:2.0:0.1]
head_to_shank_fillet_height_mm = 0.8; //[0.3:2.0:0.1]
thread_groove_depth_mm = 0.25; //[0.1:0.6:0.05]
thread_groove_width_mm = 0.35; //[0.15:0.8:0.05]

// Screw and Washer - Complete Geometry
module screw_and_washer() {
  color("DimGray") {
    // Screw Body
    union() {
      // Shank
      translate([0, 0, -head_height_mm/2])
        cylinder(h=length_mm - head_height_mm, r=shank_diameter_mm/2, center=true);
      
      // Head
      translate([0, 0, length_mm/2 - head_height_mm/2])
        cylinder(h=head_height_mm, r=head_diameter_mm/2, center=true);
      
      // Head to Shank Fillet
      translate([0, 0, length_mm/2 - head_height_mm - head_to_shank_fillet_height_mm/2 + overlap_mm])
        cylinder(h=head_to_shank_fillet_height_mm, r1=head_diameter_mm/2, r2=shank_diameter_mm/2, center=true);
      
      // Tip Chamfer
      translate([0, 0, -length_mm/2 + tip_chamfer_height_mm/2])
        cylinder(h=tip_chamfer_height_mm, r1=shank_diameter_mm/2, r2=shank_diameter_mm/2 - tip_chamfer_reduction_mm, center=true);
    }
    
    // Hex Socket Recess
    difference() {
      translate([0, 0, length_mm/2 - socket_depth_mm/2])
        cylinder(h=socket_depth_mm + overlap_mm, r=socket_hex_af_mm/(2*cos(30)), center=true);
    }
    
    // Cosmetic Thread Representation
    if (thread_representation == 1) {
      difference() {
        translate([0, 0, -length_mm/2 + thread_length_mm/2 + tip_chamfer_height_mm - overlap_mm])
          cylinder(h=thread_length_mm, r=shank_diameter_mm/2 - thread_groove_depth_mm, center=true);
      }
    }
  }
  
  // Washer
  color("Silver") {
    difference() {
      translate([0, 0, length_mm/2 - head_height_mm - washer_thickness_mm/2 + overlap_mm])
        cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true);
      translate([0, 0, length_mm/2 - head_height_mm - washer_thickness_mm/2 + overlap_mm])
        cylinder(h=washer_thickness_mm + 2*overlap_mm, r=washer_hole_diameter_mm/2, center=true);
    }
  }
}

// Assembly
module assembly() {
  screw_and_washer();
}

assembly();