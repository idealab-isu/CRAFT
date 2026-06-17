// Parameters
thread_diameter_mm = 4.0; //[2.0:8.0:0.1]
thread_pitch_mm = 0.7; //[0.35:1.4:0.05]
across_flats_mm = 10.0; //[5.0:20.0:0.1]
thickness_mm = 3.75; //[1.9:7.5:0.05]
thread_clearance_mm = 0.2; //[0.0:0.6:0.05]
wing_count = 2; //[2:2:1]
wing_span_mm = 24.0; //[12.0:48.0:0.5]
wing_length_from_core_mm = 7.0; //[3.5:14.0:0.25]
wing_height_mm = 3.75; //[1.9:7.5:0.05]
wing_thickness_mm = 2.5; //[1.2:5.0:0.1]
wing_tip_radius_mm = 2.0; //[0.8:4.0:0.1]
wing_root_fillet_radius_mm = 1.0; //[0.5:2.0:0.1]
outer_edge_chamfer_mm = 0.3; //[0.0:1.0:0.05]
overlap_mm = 1.0; //[0.5:2.0:0.1]
hole_extra_height_mm = 2.0; //[1.0:6.0:0.5]

// Nut and Washer - complete geometry
module nut_and_washer() {
  color([0.85, 0.85, 0.8]) {
    // Hex Nut Core
    difference() {
      union() {
        // Hexagonal core
        translate([0, 0, -thickness_mm/2])
          cylinder(r=across_flats_mm/(2*cos(30)), h=thickness_mm, $fn=6);
        
        // Wings
        union() {
          translate([across_flats_mm/2 + (wing_length_from_core_mm + overlap_mm)/2 - overlap_mm, 0, 0])
            cube([wing_length_from_core_mm + overlap_mm, wing_thickness_mm, wing_height_mm], center=true);
          translate([-(across_flats_mm/2 + (wing_length_from_core_mm + overlap_mm)/2 - overlap_mm), 0, 0])
            cube([wing_length_from_core_mm + overlap_mm, wing_thickness_mm, wing_height_mm], center=true);
        }
        
        // Wing root fillets
        hull() {
          translate([across_flats_mm/2 - overlap_mm/2, 0, 0])
            sphere(r=wing_root_fillet_radius_mm);
          translate([-(across_flats_mm/2 - overlap_mm/2), 0, 0])
            sphere(r=wing_root_fillet_radius_mm);
        }
      }
      
      // Threaded through hole
      translate([0, 0, -thickness_mm/2])
        cylinder(r=(thread_diameter_mm + thread_clearance_mm)/2, h=thickness_mm + hole_extra_height_mm, $fn=32);
    }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();