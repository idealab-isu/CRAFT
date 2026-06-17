// Parameters
thread_nominal_diameter_mm = 5; //[2.5:10:0.1]
thread_pitch_mm = 0.8; //[0.4:1.6:0.05]
across_flats_mm = 9.2; //[4.6:18.4:0.1]
thickness_mm = 4; //[2:8:0.1]
hole_clearance_mm = 0.5; //[0.1:1.2:0.05]
hole_tap_allowance_mm = 0.2; //[0.05:0.5:0.05]
hole_mode = 0; //[0:1:1]
lead_in_chamfer_mm = 0.3; //[0.1:0.8:0.05]
chamfer_radial_extra_mm = 0.4; //[0.1:1.2:0.05]
washer_outer_diameter_mm = 10; //[6:20:0.1]
washer_thickness_mm = 1; //[0.5:2.5:0.1]
overlap_mm = 0.8; //[0.2:2:0.1]
cut_extra_mm = 1; //[0.5:3:0.1]

// Nut and Washer - complete geometry
module nut_and_washer() {
  color("DimGray") {
    // Hex Nut Body
    difference() {
      cylinder(r=across_flats_mm/(2*cos(30)), h=thickness_mm, center=true, $fn=6);
      // Central Thread Hole
      cylinder(r=((thread_nominal_diameter_mm + hole_clearance_mm)*(1-hole_mode) + 
                  (thread_nominal_diameter_mm - hole_tap_allowance_mm)*hole_mode)/2, 
               h=thickness_mm + 2*cut_extra_mm, center=true);
      // Chamfer or Lead-in Edges Top
      translate([0, 0, thickness_mm/2 - lead_in_chamfer_mm/2])
        rotate([180, 0, 0])
        cylinder(r1=((thread_nominal_diameter_mm + hole_clearance_mm)*(1-hole_mode) + 
                     (thread_nominal_diameter_mm - hole_tap_allowance_mm)*hole_mode)/2 + chamfer_radial_extra_mm, 
                 r2=0, h=lead_in_chamfer_mm, center=true);
      // Chamfer or Lead-in Edges Bottom
      translate([0, 0, -thickness_mm/2 + lead_in_chamfer_mm/2])
        cylinder(r1=((thread_nominal_diameter_mm + hole_clearance_mm)*(1-hole_mode) + 
                     (thread_nominal_diameter_mm - hole_tap_allowance_mm)*hole_mode)/2 + chamfer_radial_extra_mm, 
                 r2=0, h=lead_in_chamfer_mm, center=true);
    }
    
    // Washer Ring
    translate([0, 0, -thickness_mm/2 - washer_thickness_mm/2 + overlap_mm])
      difference() {
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
        cylinder(r=((thread_nominal_diameter_mm + hole_clearance_mm)*(1-hole_mode) + 
                    (thread_nominal_diameter_mm - hole_tap_allowance_mm)*hole_mode)/2, 
                 h=washer_thickness_mm + 2*cut_extra_mm, center=true);
      }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();