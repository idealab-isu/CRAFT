// Parameters
outer_diameter = 30; //[15:60:0.5]
length = 22; //[11:44:0.5]
screw_diameter = 12; //[6:24:0.5]
inner_thread_pitch = 1.75; //[1:3:0.05]
thread_tap_drill_diameter = 10.2; //[8:11.5:0.1]
end_chamfer = 1; //[0.5:3:0.1]
lead_in_chamfer_angle_deg = 45; //[20:70:1]
knurl_rib_count = 24; //[8:64:1]
knurl_rib_depth = 1; //[0.3:2.5:0.1]
knurl_rib_width = 2; //[0.8:5:0.1]
knurl_rib_height = 18; //[8:40:0.5]
overlap = 1; //[0.5:2:0.1]

// Threaded Insert - complete geometry
module threaded_insert() {
  color([0.8, 0.6, 0.2]) { // Brass color
    difference() {
      // Outer body with knurling
      union() {
        // Main cylindrical body
        cylinder(r=outer_diameter/2, h=length, center=true);
        
        // Knurl ribs
        for (i = [0:knurl_rib_count-1]) {
          rotate([0, 0, i*360/knurl_rib_count])
          translate([outer_diameter/2 + (knurl_rib_depth + overlap)/2 - overlap, 0, 0])
          cube([knurl_rib_depth + overlap, knurl_rib_width, knurl_rib_height], center=true);
        }
      }
      
      // Internal threaded bore
      cylinder(r=thread_tap_drill_diameter/2, h=length + 2*overlap, center=true);
      
      // Installation entry chamfer
      translate([0, 0, length/2 - end_chamfer/2 + overlap/2])
      cylinder(r1=thread_tap_drill_diameter/2 + end_chamfer, r2=thread_tap_drill_diameter/2, h=end_chamfer, center=true);
      
      // Lead-in chamfer
      translate([0, 0, -length/2 + end_chamfer/2 - overlap/2])
      cylinder(r1=thread_tap_drill_diameter/2 + end_chamfer, r2=thread_tap_drill_diameter/2, h=end_chamfer, center=true);
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();