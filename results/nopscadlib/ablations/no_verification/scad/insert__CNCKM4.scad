// Parameters
outer_diameter_mm = 4.0; //[2.0:8.0:0.1]
length_mm = 6.3; //[3.15:12.6:0.1]
screw_nominal_diameter_mm = 4.0; //[2.0:8.0:0.1]
internal_thread_pitch_mm = 0.7; //[0.35:1.4:0.05]
internal_thread_minor_diameter_mm = 3.3; //[2.5:4.0:0.05]
end_chamfer_mm = 0.3; //[0.15:0.8:0.05]
outer_retention_depth_mm = 0.2; //[0.1:0.6:0.05]
outer_retention_pitch_mm = 0.8; //[0.4:1.6:0.05]
rib_groove_width_mm = 0.35; //[0.2:0.8:0.05]
rib_count = 8; //[6:16:1]
overlap_mm = 0.8; //[0.5:2.0:0.1]

// Threaded Insert - complete geometry
module threaded_insert() {
  color("Brass") {
    difference() {
      // Insert body
      translate([0, 0, 0])
        cylinder(r=outer_diameter_mm/2, h=length_mm, center=true, $fn=64);
      
      // Internal bore
      translate([0, 0, 0])
        cylinder(r=internal_thread_minor_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true, $fn=64);
      
      // Lead-in chamfers
      translate([0, 0, length_mm/2 - (end_chamfer_mm + overlap_mm)/2])
        cylinder(r1=outer_diameter_mm/2 + overlap_mm, r2=outer_diameter_mm/2 - end_chamfer_mm, h=end_chamfer_mm + overlap_mm, center=true, $fn=64);
      translate([0, 0, -length_mm/2 + (end_chamfer_mm + overlap_mm)/2])
        cylinder(r1=outer_diameter_mm/2 - end_chamfer_mm, r2=outer_diameter_mm/2 + overlap_mm, h=end_chamfer_mm + overlap_mm, center=true, $fn=64);
      
      // Outer retention grooves
      intersection() {
        union() {
          for (i = [0:rib_count-1]) {
            rotate([0, 0, i*360/rib_count])
              translate([0, outer_diameter_mm/2 - outer_retention_depth_mm/2, 0])
                cube([2*(outer_diameter_mm/2 + overlap_mm), outer_retention_depth_mm, rib_groove_width_mm], center=true);
          }
        }
        union() {
          for (j = [0:7]) {
            translate([0, outer_diameter_mm/2 - outer_retention_depth_mm/2, -(length_mm/2 - end_chamfer_mm) + rib_groove_width_mm/2 + j*outer_retention_pitch_mm])
              cube([2*(outer_diameter_mm/2 + overlap_mm), outer_retention_depth_mm, rib_groove_width_mm], center=true);
          }
        }
      }
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();