// Parameters
thread_diameter_mm = 4.0; //[2.0:8.0:0.1]
thread_pitch_mm = 0.7; //[0.4:1.5:0.05]
thread_modeling = 0; //[0:1:1]
across_flats_mm = 10.0; //[5.0:20.0:0.1]
thickness_mm = 3.75; //[1.8:7.5:0.05]
wing_count = 2; //[2:2:1]
wing_span_mm = 26.0; //[16.0:40.0:0.5]
wing_length_from_hex_mm = 8.0; //[4.0:16.0:0.5]
wing_thickness_mm = 3.0; //[1.5:6.0:0.1]
wing_height_mm = 8.0; //[4.0:16.0:0.5]
wing_root_fillet_radius_mm = 2.0; //[0.8:5.0:0.1]
hex_edge_chamfer_mm = 0.6; //[0.2:1.5:0.05]
bore_clearance_mm = 0.2; //[0.0:0.6:0.05]
overlap_mm = 1.0; //[0.5:2.0:0.1]
eps_mm = 0.2; //[0.05:0.5:0.05]
washer_outer_diameter_mm = 12.0; //[8.0:24.0:0.5]
washer_thickness_mm = 0.8; //[0.4:2.0:0.05]

// Nut and Washer - complete geometry
module nut_and_washer() {
  color("Silver") {
    // Hex Nut Body
    difference() {
      cylinder(r=across_flats_mm/(2*cos(30)), h=thickness_mm, center=true, $fn=6);
      // Internal Thread or Bore
      translate([0, 0, 0])
        cylinder(r=(thread_diameter_mm + bore_clearance_mm)/2, h=thickness_mm + 2*eps_mm, center=true);
    }
    
    // Wings
    union() {
      // Positive Wing
      translate([across_flats_mm/(2*cos(30)) + (wing_length_from_hex_mm + overlap_mm)/2 - overlap_mm, 0, 0])
        union() {
          cube([wing_length_from_hex_mm + overlap_mm, wing_height_mm, wing_thickness_mm], center=true);
          hull() {
            translate([across_flats_mm/(2*cos(30)) - overlap_mm, 0, 0])
              rotate([90, 0, 0])
              cylinder(r=wing_root_fillet_radius_mm, h=wing_thickness_mm, center=true);
            translate([across_flats_mm/(2*cos(30)) + wing_length_from_hex_mm - overlap_mm, 0, 0])
              rotate([90, 0, 0])
              cylinder(r=wing_root_fillet_radius_mm, h=wing_thickness_mm, center=true);
          }
        }
      
      // Negative Wing
      translate([-(across_flats_mm/(2*cos(30)) + (wing_length_from_hex_mm + overlap_mm)/2 - overlap_mm), 0, 0])
        union() {
          cube([wing_length_from_hex_mm + overlap_mm, wing_height_mm, wing_thickness_mm], center=true);
          hull() {
            translate([-(across_flats_mm/(2*cos(30)) - overlap_mm), 0, 0])
              rotate([90, 0, 0])
              cylinder(r=wing_root_fillet_radius_mm, h=wing_thickness_mm, center=true);
            translate([-(across_flats_mm/(2*cos(30)) + wing_length_from_hex_mm - overlap_mm), 0, 0])
              rotate([90, 0, 0])
              cylinder(r=wing_root_fillet_radius_mm, h=wing_thickness_mm, center=true);
          }
        }
    }
    
    // Washer Flange
    translate([0, 0, -(thickness_mm/2 + washer_thickness_mm/2 - overlap_mm)])
      cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
    
    // Edge Chamfers
    difference() {
      // Top Chamfer
      translate([0, 0, thickness_mm/2 - (hex_edge_chamfer_mm + eps_mm)/2])
        cylinder(r1=across_flats_mm/(2*cos(30)) + eps_mm, r2=across_flats_mm/(2*cos(30)) - hex_edge_chamfer_mm, h=hex_edge_chamfer_mm + eps_mm, center=true);
      
      // Bottom Chamfer
      translate([0, 0, -(thickness_mm/2 - (hex_edge_chamfer_mm + eps_mm)/2)])
        rotate([180, 0, 0])
        cylinder(r1=across_flats_mm/(2*cos(30)) + eps_mm, r2=across_flats_mm/(2*cos(30)) - hex_edge_chamfer_mm, h=hex_edge_chamfer_mm + eps_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();