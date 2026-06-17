// Parameters
screw_diameter = 3; //[1.5:6:0.1]
across_flats = 6; //[3:12:0.1]
thickness = 2.75; //[1.4:5.5:0.05]
hole_style_is_clearance = 1; //[0:1:1]
clearance_diameter_if_clearance = 3.2; //[2.8:4.5:0.05]
tap_drill_diameter_if_tapped = 2.5; //[2:3:0.05]
corner_chamfer = 0.2; //[0:1:0.05]
t_slot_major_width = 10; //[6:20:0.1]
t_slot_minor_width = 6; //[4:12:0.1]
t_slot_lip_height = 0.8; //[0.3:2:0.05]
t_slot_lip_depth = 1.2; //[0.5:3:0.05]
t_slot_clearance = 0.1; //[0:0.5:0.05]
connection_overlap = 0.8; //[0.5:2:0.1]
nut_and_washer_enable = 0; //[0:1:1]
washer_outer_diameter = 7; //[5:14:0.1]
washer_thickness = 0.8; //[0.4:2:0.05]
viz_standoff = 0.6; //[0:2:0.05]

// Nut and Washer - complete geometry
module nut_and_washer() {
  if (nut_and_washer_enable) {
    union() {
      // Washer
      color("Silver") translate([0, 0, thickness/2 + viz_standoff + washer_thickness/2 - connection_overlap])
        cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true, $fn=32);
      
      // Nut
      color("DimGray") translate([0, 0, thickness/2 + viz_standoff + washer_thickness + thickness/2 - connection_overlap])
        difference() {
          cylinder(r=across_flats/(2*cos(30)), h=thickness, center=true, $fn=6);
          cylinder(r=screw_diameter/2, h=thickness + 2*connection_overlap, center=true, $fn=32);
        }
    }
  }
}

// T-slot nut body
module t_slot_nut_body() {
  union() {
    // Hex outer profile
    color("DimGray") translate([0, 0, 0])
      cylinder(r=across_flats/(2*cos(30)), h=thickness, center=true, $fn=6);
    
    // T-slot nut body block
    translate([0, 0, 0])
      cube([t_slot_major_width - 2*t_slot_clearance, across_flats, thickness], center=true);
    
    // Retention lips
    translate([-(t_slot_major_width - 2*t_slot_clearance)/2 + t_slot_lip_depth/2 - connection_overlap/2, 0, -thickness/2 + t_slot_lip_height/2 - connection_overlap/2])
      cube([t_slot_lip_depth, t_slot_minor_width - 2*t_slot_clearance, t_slot_lip_height], center=true);
    translate([(t_slot_major_width - 2*t_slot_clearance)/2 - t_slot_lip_depth/2 + connection_overlap/2, 0, -thickness/2 + t_slot_lip_height/2 - connection_overlap/2])
      cube([t_slot_lip_depth, t_slot_minor_width - 2*t_slot_clearance, t_slot_lip_height], center=true);
    
    // Lead-in chamfers
    translate([0, 0, thickness/2 - corner_chamfer/2])
      cylinder(r1=across_flats/(2*cos(30)) + corner_chamfer, r2=across_flats/(2*cos(30)), h=corner_chamfer, center=true, $fn=6);
    translate([0, 0, -thickness/2 + corner_chamfer/2])
      cylinder(r1=across_flats/(2*cos(30)), r2=across_flats/(2*cos(30)) + corner_chamfer, h=corner_chamfer, center=true, $fn=6);
  }
}

// Assembly
module assembly() {
  difference() {
    t_slot_nut_body();
    // Central screw hole
    translate([0, 0, 0])
      cylinder(r=((hole_style_is_clearance*clearance_diameter_if_clearance + (1-hole_style_is_clearance)*tap_drill_diameter_if_tapped)/2), h=thickness + 2*connection_overlap, center=true, $fn=32);
  }
  nut_and_washer();
}

assembly();