// Parameters
outer_diameter_mm = 10; //[5:20:0.1]
length_mm = 8; //[4:16:0.1]
screw_nominal_diameter_mm = 4; //[2:8:0.1]
internal_thread_pitch_mm = 0.7; //[0.35:1.4:0.05]
internal_minor_diameter_mm = 3.3; //[2:6:0.05]
internal_tap_drill_mm = 3.3; //[2:6:0.05]
lead_in_chamfer_mm = 0.5; //[0.2:2:0.05]
end_chamfer_mm = 0.5; //[0.2:2:0.05]
knurl_depth_mm = 0.4; //[0.1:1:0.05]
knurl_pitch_mm = 1; //[0.5:2.5:0.1]
knurl_ring_count = 6; //[3:12:1]
knurl_ring_height_mm = 0.6; //[0.3:1.2:0.05]
knurl_teeth_count = 24; //[12:48:1]
knurl_tooth_width_mm = 1; //[0.5:2:0.05]
overlap_mm = 0.8; //[0.5:2:0.1]

// Threaded Insert - complete geometry
module threaded_insert() {
  color([0.8, 0.6, 0.2]) { // Brass color
    // Main body with chamfers
    union() {
      // Body
      cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);
      
      // Lead-in chamfer
      translate([0, 0, length_mm/2 - lead_in_chamfer_mm/2])
        cylinder(r1=outer_diameter_mm/2, r2=outer_diameter_mm/2 - lead_in_chamfer_mm, h=lead_in_chamfer_mm, center=true);
      
      // Installation end chamfer
      translate([0, 0, -length_mm/2 + end_chamfer_mm/2])
        cylinder(r1=outer_diameter_mm/2 - end_chamfer_mm, r2=outer_diameter_mm/2, h=end_chamfer_mm, center=true);
      
      // Knurl rings
      for (i = [0:knurl_ring_count-1]) {
        translate([0, 0, (-length_mm/2 + end_chamfer_mm + knurl_ring_height_mm/2) + i*knurl_pitch_mm])
          knurl_ring();
      }
    }
    
    // Internal bore
    difference() {
      cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);
      cylinder(r=internal_minor_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
    }
  }
}

// Knurl ring module
module knurl_ring() {
  union() {
    for (j = [0:knurl_teeth_count-1]) {
      rotate([0, 0, j*360/knurl_teeth_count])
        translate([outer_diameter_mm/2 + (knurl_depth_mm + overlap_mm)/2 - overlap_mm, 0, 0])
          cube([knurl_depth_mm + overlap_mm, knurl_tooth_width_mm, knurl_ring_height_mm], center=true);
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();