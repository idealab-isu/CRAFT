// Parameters
screw_diameter = 4.0; //[2.0:8.0:0.1]
outer_diameter = 8.2; //[4.1:16.4:0.1]
length = 6.3; //[3.15:12.6:0.1]
inner_thread_diameter = 4.0; //[2.0:8.0:0.05]
inner_clearance = 0.4; //[0.1:1.0:0.05]
lead_in_chamfer_height = 0.8; //[0.4:1.6:0.05]
installation_end_chamfer_height = 0.6; //[0.3:1.2:0.05]
chamfer_radial_reduction = 0.6; //[0.3:1.2:0.05]
rib_count = 12; //[6:24:1]
rib_radial_height = 0.35; //[0.15:0.8:0.05]
rib_tangential_width = 1.0; //[0.5:2.0:0.05]
rib_axial_height = 4.8; //[2.4:9.6:0.1]
rib_overlap = 0.8; //[0.5:2.0:0.05]
rib_z_offset = 0.0; //[-1.0:1.0:0.05]

// Module for the heat-set insert
module insert() {
  color([0.8, 0.6, 0.2]) { // Brass color
    difference() {
      union() {
        // Main body
        cylinder(r=outer_diameter/2, h=length, center=true, $fn=64);
        
        // Ribs
        for (i = [0:rib_count-1]) {
          rotate([0, 0, i*360/rib_count])
          translate([outer_diameter/2 + (rib_radial_height + rib_overlap)/2 - rib_overlap, 0, rib_z_offset])
          cube([rib_radial_height + rib_overlap, rib_tangential_width, rib_axial_height], center=true);
        }
      }
      
      // Lead-in chamfer
      translate([0, 0, length/2 - lead_in_chamfer_height/2])
      rotate([180, 0, 0])
      cylinder(r1=outer_diameter/2, r2=outer_diameter/2 - chamfer_radial_reduction, h=lead_in_chamfer_height, center=true, $fn=64);
      
      // Installation end chamfer
      translate([0, 0, -length/2 + installation_end_chamfer_height/2])
      cylinder(r1=outer_diameter/2, r2=outer_diameter/2 - chamfer_radial_reduction, h=installation_end_chamfer_height, center=true, $fn=64);
    }
  }
}

// Module for the threaded insert
module threaded_insert() {
  color([0.8, 0.6, 0.2]) { // Brass color
    difference() {
      insert();
      
      // Internal thread (clearance hole)
      cylinder(r=(inner_thread_diameter + inner_clearance)/2, h=length + (lead_in_chamfer_height + installation_end_chamfer_height), center=true, $fn=64);
    }
  }
}

// Assembly of the insert
module assembly() {
  threaded_insert();
}

assembly();