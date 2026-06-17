// Parameters
outer_diameter_mm = 12; //[6:24:0.1]
length_mm = 10; //[5:20:0.1]
screw_diameter_mm = 5; //[2.5:10:0.1]
internal_thread_pitch_mm = 0.8; //[0.4:1.6:0.05]
internal_minor_diameter_mm = 4.2; //[3:6:0.05]
internal_thread_depth_mm = 10; //[5:20:0.1]
top_chamfer_height_mm = 0.8; //[0.2:2:0.05]
top_chamfer_angle_deg = 45; //[20:70:1]
bottom_chamfer_height_mm = 0.8; //[0.2:2:0.05]
bottom_chamfer_angle_deg = 45; //[20:70:1]
external_knurl_depth_mm = 0.4; //[0.1:1:0.05]
external_knurl_pitch_mm = 1; //[0.5:2.5:0.1]
knurl_ring_thickness_mm = 0.6; //[0.3:1.5:0.05]
knurl_ring_count = 7; //[3:20:1]
has_top_flange = 0; //[0:1:1]
top_flange_diameter_mm = 12; //[6:26:0.1]
top_flange_thickness_mm = 0; //[0:3:0.1]
overlap_mm = 0.8; //[0.2:2:0.1]

// Threaded Insert - complete geometry
module threaded_insert() {
  color([0.8, 0.6, 0.2]) { // Brass color
    difference() {
      union() {
        // Insert body with knurl rings
        union() {
          cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);
          for (i = [1:knurl_ring_count]) {
            translate([0, 0, -length_mm/2 + (length_mm/(knurl_ring_count+1))*i])
              cylinder(r=outer_diameter_mm/2 + external_knurl_depth_mm, h=knurl_ring_thickness_mm, center=true);
          }
        }
        // Optional top flange
        if (has_top_flange) {
          translate([0, 0, length_mm/2 + top_flange_thickness_mm/2 - overlap_mm])
            cylinder(r=top_flange_diameter_mm/2, h=top_flange_thickness_mm, center=true);
        }
      }
      // Internal thread bore
      cylinder(r=internal_minor_diameter_mm/2, h=internal_thread_depth_mm + 2*overlap_mm, center=true);
      // Top chamfer
      translate([0, 0, length_mm/2 - (top_chamfer_height_mm + overlap_mm)/2])
        rotate([180, 0, 0])
        cylinder(r1=outer_diameter_mm/2 + overlap_mm, r2=0, h=top_chamfer_height_mm + overlap_mm, center=true);
      // Bottom chamfer
      translate([0, 0, -length_mm/2 + (bottom_chamfer_height_mm + overlap_mm)/2])
        cylinder(r1=outer_diameter_mm/2 + overlap_mm, r2=0, h=bottom_chamfer_height_mm + overlap_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();