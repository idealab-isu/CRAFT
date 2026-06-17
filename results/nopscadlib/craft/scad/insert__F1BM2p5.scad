// Parameters
outer_diameter = 5.8; //[2.9:11.6:0.1]
length = 4.6; //[2.3:9.2:0.1]
screw_diameter = 2.5; //[1.25:5:0.05]
bore_minor_diameter = 2.05; //[1.0:4.1:0.05]
bore_major_diameter = 2.5; //[1.25:5:0.05]
end_chamfer_height = 0.3; //[0.15:0.6:0.05]
end_chamfer_angle_deg = 30; //[15:60:1]
lead_in_chamfer_height = 0.3; //[0.15:0.6:0.05]
lead_in_chamfer_angle_deg = 30; //[15:60:1]
knurl_depth = 0.3; //[0.15:0.6:0.05]
knurl_pitch = 0.8; //[0.4:1.6:0.05]
knurl_ring_height = 0.35; //[0.2:0.7:0.05]
knurl_count = 4; //[2:10:1]
overlap = 0.8; //[0.5:2:0.1]
bore_extra = 0.4; //[0.2:1.0:0.05]

// Threaded Insert - complete geometry
module threaded_insert() {
  color("Gold") {
    // Main body
    difference() {
      union() {
        // Insert body
        cylinder(h=length, r=outer_diameter/2, center=true);
        
        // External knurl/barbs
        for (i = [0:knurl_count-1]) {
          translate([0, 0, -length/2 + end_chamfer_height + knurl_ring_height/2 + overlap + i*knurl_pitch])
            cylinder(h=knurl_ring_height, r=outer_diameter/2 + knurl_depth, center=true);
        }
        
        // Lead-in chamfer
        translate([0, 0, length/2 - lead_in_chamfer_height/2])
          cylinder(h=lead_in_chamfer_height, r1=outer_diameter/2, r2=outer_diameter/2 - lead_in_chamfer_height, center=true);
        
        // Installation end chamfer
        translate([0, 0, -length/2 + end_chamfer_height/2])
          cylinder(h=end_chamfer_height, r1=outer_diameter/2 - end_chamfer_height, r2=outer_diameter/2, center=true);
      }
      
      // Internal thread bore
      cylinder(h=length + 2*bore_extra, r=bore_minor_diameter/2, center=true);
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();