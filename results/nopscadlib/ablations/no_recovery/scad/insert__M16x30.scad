// Parameters
outer_diameter_mm = 30; //[15:60:0.5]
length_mm = 25; //[12.5:50:0.5]
screw_diameter_mm = 16; //[8:32:0.5]
bore_major_diameter_mm = 16; //[8:32:0.5]
wall_thickness_mm = 7; //[3.5:14:0.5]
bore_minor_diameter_mm = 14; //[7:28:0.5]
internal_thread_pitch_mm = 2; //[0.5:5:0.1]
end_chamfer_mm = 1; //[0.5:3:0.1]
lead_in_length_mm = 2; //[0.5:6:0.1]
installation_entry_chamfer_mm = 1; //[0.5:4:0.1]
knurl_depth_mm = 0.5; //[0:2:0.1]
knurl_pitch_mm = 1.5; //[0.8:4:0.1]
knurl_count = 40; //[12:120:1]
knurl_height_mm = 18; //[8:40:0.5]
knurl_band_center_offset_mm = 0; //[-10:10:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// Threaded Insert - complete geometry
module threaded_insert() {
  color("Gold") {
    // Insert Body
    difference() {
      union() {
        // Main Body
        translate([0, 0, 0])
          cylinder(r=outer_diameter_mm/2, h=length_mm, center=true, $fn=64);
        
        // Knurl Ribs
        for (i = [0:knurl_count-1]) {
          rotate([0, 0, i*360/knurl_count])
            translate([outer_diameter_mm/2 - overlap_mm + (knurl_depth_mm + overlap_mm)/2, 0, knurl_band_center_offset_mm])
              cube([knurl_depth_mm + overlap_mm, outer_diameter_mm*0.06, knurl_height_mm], center=true);
        }
      }
      
      // External End Chamfers
      translate([0, 0, length_mm/2 - (end_chamfer_mm + overlap_mm)/2])
        cylinder(r1=outer_diameter_mm/2 + end_chamfer_mm, r2=outer_diameter_mm/2, h=end_chamfer_mm + overlap_mm, center=true, $fn=64);
      translate([0, 0, -length_mm/2 + (end_chamfer_mm + overlap_mm)/2])
        cylinder(r1=outer_diameter_mm/2 + end_chamfer_mm, r2=outer_diameter_mm/2, h=end_chamfer_mm + overlap_mm, center=true, $fn=64);
    }
    
    // Internal Threaded Bore
    translate([0, 0, 0])
      cylinder(r=bore_major_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true, $fn=64);
    
    // Lead-in Chamfer
    translate([0, 0, length_mm/2 - (lead_in_length_mm + overlap_mm)/2])
      cylinder(r1=bore_major_diameter_mm/2 + lead_in_length_mm, r2=bore_major_diameter_mm/2, h=lead_in_length_mm + overlap_mm, center=true, $fn=64);
    
    // Installation Entry Chamfer
    translate([0, 0, -length_mm/2 + (installation_entry_chamfer_mm + overlap_mm)/2])
      cylinder(r1=bore_major_diameter_mm/2 + installation_entry_chamfer_mm, r2=bore_major_diameter_mm/2, h=installation_entry_chamfer_mm + overlap_mm, center=true, $fn=64);
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();