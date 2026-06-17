// Parameters
outer_diameter = 5.8; //[2.9:11.6:0.1]
length = 4.6; //[2.3:9.2:0.1]
screw_diameter = 3; //[1.5:6:0.1]
internal_thread_pitch = 0.5; //[0.25:1:0.05]
internal_bore_diameter = 2.6; //[2.2:3.2:0.05]
lead_in_chamfer_height = 0.3; //[0.15:0.8:0.05]
lead_in_chamfer_angle_deg = 45; //[20:70:1]
end_chamfer_height = 0.3; //[0.15:0.8:0.05]
end_chamfer_angle_deg = 45; //[20:70:1]
rib_count = 12; //[6:24:1]
rib_radial_height = 0.35; //[0.15:0.8:0.05]
rib_tangential_width = 0.6; //[0.3:1.2:0.05]
rib_length_margin = 0.4; //[0.2:1:0.05]
overlap = 0.8; //[0.5:2:0.1]

// Threaded Insert - complete geometry
module threaded_insert() {
  color([0.8, 0.6, 0.2]) { // Brass color
    difference() {
      union() {
        // Main body
        cylinder(r=outer_diameter/2, h=length, center=true);
        
        // Ribs
        for (i = [0:rib_count-1]) {
          rotate([0, 0, i*360/rib_count])
          translate([outer_diameter/2 + (rib_radial_height + overlap)/2 - overlap, 0, 0])
          cube([rib_radial_height + overlap, rib_tangential_width, length - 2*rib_length_margin], center=true);
        }
      }
      
      // Lead-in chamfer
      translate([0, 0, length/2 - (lead_in_chamfer_height + overlap)/2])
      cylinder(r1=outer_diameter/2, r2=outer_diameter/2 - lead_in_chamfer_height, h=lead_in_chamfer_height + overlap, center=true);
      
      // Installation end chamfer
      translate([0, 0, -length/2 + (end_chamfer_height + overlap)/2])
      cylinder(r1=outer_diameter/2, r2=outer_diameter/2 - end_chamfer_height, h=end_chamfer_height + overlap, center=true);
      
      // Internal thread bore
      cylinder(r=internal_bore_diameter/2, h=length + 2*overlap, center=true);
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();