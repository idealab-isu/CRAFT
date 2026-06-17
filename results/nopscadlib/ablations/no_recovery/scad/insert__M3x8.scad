// Parameters
outer_diameter_mm = 8; //[4:16:0.1]
length_mm = 6; //[3:12:0.1]
screw_diameter_mm = 3; //[2:6:0.1]
inner_thread_minor_diameter_mm = 2.5; //[2:5:0.05]
lead_in_chamfer_mm = 0.5; //[0.2:1.5:0.05]
top_entry_chamfer_mm = 0.5; //[0.2:1.5:0.05]
rib_count = 12; //[6:24:1]
rib_radial_height_mm = 0.4; //[0.2:1:0.05]
rib_tangential_width_mm = 0.8; //[0.4:1.6:0.05]
rib_axial_height_mm = 4.5; //[2:10:0.1]
rib_z_margin_mm = 0.5; //[0.2:1.5:0.05]
overlap_mm = 0.8; //[0.5:2:0.1]

// Threaded Insert - complete geometry
module threaded_insert() {
  color([0.8, 0.6, 0.2]) { // Brass color
    difference() {
      union() {
        // Main body
        translate([0, 0, 0])
          cylinder(r=outer_diameter_mm/2, h=length_mm, center=true, $fn=64);
        
        // Ribs
        for (i = [0:rib_count-1]) {
          rotate([0, 0, i*360/rib_count])
            translate([outer_diameter_mm/2 - overlap_mm/2 + (rib_radial_height_mm + overlap_mm)/2, 0, 0])
              cube([rib_radial_height_mm + overlap_mm, rib_tangential_width_mm, rib_axial_height_mm], center=true);
        }
      }
      
      // Top entry chamfer
      translate([0, 0, length_mm/2 - top_entry_chamfer_mm/2])
        cylinder(r1=outer_diameter_mm/2, r2=0, h=top_entry_chamfer_mm, center=true, $fn=64);
      
      // Lead-in chamfer
      translate([0, 0, -length_mm/2 + lead_in_chamfer_mm/2])
        cylinder(r1=outer_diameter_mm/2, r2=0, h=lead_in_chamfer_mm, center=true, $fn=64);
      
      // Internal thread (approximated as a smooth bore)
      translate([0, 0, 0])
        cylinder(r=inner_thread_minor_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();