// Parameters
outer_diameter = 5.8; //[2.9:11.6:0.1]
length = 4.6; //[2.3:9.2:0.1]
screw_diameter = 2.5; //[1.25:5:0.05]
inner_thread_pitch = 0.45; //[0.2:0.9:0.01]
internal_thread_depth = 4.6; //[2.3:9.2:0.1]
end_chamfer = 0.3; //[0.15:0.6:0.05]
external_knurl_depth = 0.3; //[0.15:0.6:0.05]
knurl_count = 8; //[4:16:1]
knurl_groove_width = 0.35; //[0.2:0.7:0.05]
knurl_margin = 0.5; //[0.25:1:0.05]
bore_clearance = 0.2; //[0.05:0.4:0.05]
overlap = 0.8; //[0.5:2:0.1]

// Threaded Insert - complete geometry
module threaded_insert() {
  color("Brass") {
    difference() {
      // Insert body with chamfers
      union() {
        // Main cylindrical body
        cylinder(r=outer_diameter/2, h=length, center=true);
        
        // Lead-in chamfers
        translate([0, 0, length/2 - end_chamfer/2])
          cylinder(r1=outer_diameter/2, r2=outer_diameter/2 - end_chamfer, h=end_chamfer, center=true);
        translate([0, 0, -length/2 + end_chamfer/2])
          cylinder(r1=outer_diameter/2 - end_chamfer, r2=outer_diameter/2, h=end_chamfer, center=true);
      }
      
      // External knurling profile
      for (i = [0:knurl_count-1]) {
        translate([0, 0, -length/2 + knurl_margin + (i + 0.5) * (length - 2 * knurl_margin) / knurl_count])
          cylinder(r=outer_diameter/2 - external_knurl_depth, h=knurl_groove_width, center=true);
      }
      
      // Internal screw bore
      cylinder(r=(screw_diameter + bore_clearance)/2, h=internal_thread_depth + 2*overlap, center=true);
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();