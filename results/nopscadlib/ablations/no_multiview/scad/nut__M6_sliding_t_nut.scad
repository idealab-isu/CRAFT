// Parameters
screw_nominal_diameter_mm = 6.0; //[3.0:12.0:0.1]
thread_pitch_mm = 1.0; //[0.5:2.0:0.1]
across_flats_mm = 8.0; //[4.0:16.0:0.1]
thickness_mm = 6.6; //[3.3:13.2:0.1]
t_slot_width_mm = 12.0; //[8.0:24.0:0.1]
t_slot_neck_width_mm = 8.0; //[5.0:16.0:0.1]
t_slot_depth_mm = 6.0; //[3.0:12.0:0.1]
t_slot_entry_chamfer_mm = 0.5; //[0.0:2.0:0.1]
edge_chamfer_mm = 0.3; //[0.0:1.5:0.1]
corner_fillet_mm = 0.0; //[0.0:2.0:0.1]
threaded = 1; //[0:1:1]
thread_tap_drill_diameter_mm = 5.0; //[3.0:10.0:0.1]
clearance_hole_diameter_mm = 6.6; //[6.0:8.0:0.1]
tolerance_mm = 0.2; //[0.0:0.6:0.05]
overlap_mm = 0.8; //[0.5:2.0:0.1]
hex_circumradius_mm = 4.6188; //[2.3094:9.2376:0.0001]
body_width_mm = 7.6; //[4.0:15.0:0.1]
body_length_mm = 14.0; //[8.0:28.0:0.1]
wing_thickness_mm = 2.0; //[1.0:4.0:0.1]
wing_length_mm = 10.0; //[6.0:20.0:0.1]
wing_drop_mm = 2.0; //[1.0:4.0:0.1]
washer_outer_diameter_mm = 12.0; //[8.0:24.0:0.1]
washer_thickness_mm = 1.6; //[0.8:3.2:0.1]
assembly_gap_mm = 0.8; //[0.0:5.0:0.1]

// Nut and Washer - complete geometry
module nut_and_washer() {
  color("DimGray") {
    // Hexagonal profile
    cylinder(r=hex_circumradius_mm, h=thickness_mm, center=true, $fn=6);
    
    // T-slot nut body
    translate([0, 0, 0])
      cube([body_length_mm, body_width_mm, thickness_mm], center=true);
    
    // Retention wings
    translate([0, -(body_width_mm/2 + wing_thickness_mm/2 - overlap_mm), -(thickness_mm/2 - wing_drop_mm/2 - overlap_mm)])
      cube([wing_length_mm, wing_thickness_mm, wing_drop_mm], center=true);
    translate([0, (body_width_mm/2 + wing_thickness_mm/2 - overlap_mm), -(thickness_mm/2 - wing_drop_mm/2 - overlap_mm)])
      cube([wing_length_mm, wing_thickness_mm, wing_drop_mm], center=true);
    
    // Internal thread or clearance hole
    difference() {
      cylinder(r=((threaded*thread_tap_drill_diameter_mm) + ((1-threaded)*clearance_hole_diameter_mm))/2, h=thickness_mm + 2*overlap_mm, center=true);
    }
    
    // Lead-in chamfers
    difference() {
      cylinder(r=hex_circumradius_mm + edge_chamfer_mm, h=t_slot_entry_chamfer_mm, center=true);
      translate([0, 0, (thickness_mm/2 - t_slot_entry_chamfer_mm/2 + overlap_mm/2)])
        rotate([180, 0, 0])
        cylinder(r=hex_circumradius_mm + edge_chamfer_mm, h=t_slot_entry_chamfer_mm, center=true);
      translate([0, 0, -(thickness_mm/2 - t_slot_entry_chamfer_mm/2 + overlap_mm/2)])
        cylinder(r=hex_circumradius_mm + edge_chamfer_mm, h=t_slot_entry_chamfer_mm, center=true);
    }
  }
  
  // Washer
  color("Silver") {
    difference() {
      translate([0, 0, (thickness_mm/2 + washer_thickness_mm/2 + assembly_gap_mm - overlap_mm)])
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
      translate([0, 0, (thickness_mm/2 + washer_thickness_mm/2 + assembly_gap_mm - overlap_mm)])
        cylinder(r=(((threaded*thread_tap_drill_diameter_mm) + ((1-threaded)*clearance_hole_diameter_mm))/2) + tolerance_mm/2, h=washer_thickness_mm + 2*overlap_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();