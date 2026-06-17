// Parameters
outer_diameter_mm = 15.0; //[7.5:30.0:0.1]
length_mm = 12.0; //[6.0:24.0:0.1]
screw_nominal_diameter_mm = 6.0; //[3.0:12.0:0.1]
internal_thread_pitch_mm = 1.0; //[0.5:2.0:0.1]
internal_minor_diameter_mm = 5.0; //[2.5:10.0:0.1]
internal_clearance_diameter_mm = 6.4; //[3.2:12.8:0.1]
lead_in_chamfer_mm = 0.5; //[0.25:1.5:0.05]
installation_end_chamfer_mm = 0.5; //[0.25:1.5:0.05]
outer_knurl_depth_mm = 0.5; //[0.2:1.5:0.05]
outer_knurl_pitch_mm = 1.0; //[0.5:2.5:0.1]
knurl_groove_width_mm = 0.6; //[0.3:1.5:0.05]
knurl_groove_count = 8; //[3:20:1]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// Threaded Insert - complete geometry
module threaded_insert() {
  color("Brass") {
    // Insert Body
    difference() {
      cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);
      
      // Internal Bore
      translate([0, 0, 0])
        cylinder(r=internal_minor_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
      
      // Lead-in Chamfer
      translate([0, 0, length_mm/2 - lead_in_chamfer_mm/2])
        cylinder(r1=outer_diameter_mm/2, r2=outer_diameter_mm/2 - lead_in_chamfer_mm, h=lead_in_chamfer_mm, center=true);
      
      // Installation End Chamfer
      translate([0, 0, -length_mm/2 + installation_end_chamfer_mm/2])
        cylinder(r1=outer_diameter_mm/2, r2=outer_diameter_mm/2 - installation_end_chamfer_mm, h=installation_end_chamfer_mm, center=true);
      
      // Knurl Grooves
      for (i = [1:knurl_groove_count]) {
        translate([0, 0, -length_mm/2 + outer_knurl_pitch_mm*i])
          scale([(outer_diameter_mm - 2*outer_knurl_depth_mm)/outer_diameter_mm, (outer_diameter_mm - 2*outer_knurl_depth_mm)/outer_diameter_mm, 1])
          cylinder(r=outer_diameter_mm/2, h=knurl_groove_width_mm, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();