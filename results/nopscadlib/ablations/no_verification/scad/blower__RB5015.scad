// Parameters
overall_length_mm = 51.3; //[25.65:102.6:0.1]
overall_width_mm = 51; //[25.5:102:0.1]
overall_depth_mm = 15; //[7.5:30:0.1]
wall_thickness_mm = 1.5; //[0.75:3:0.05]
base_thickness_mm = 1.5; //[0.75:3:0.05]
top_thickness_mm = 1.5; //[0.75:3:0.05]
inlet_bore_diameter_mm = 24; //[12:48:0.1]
outlet_width_mm = 18; //[9:36:0.1]
outlet_height_mm = 10; //[5:20:0.1]
outlet_offset_mm = 0; //[-10:10:0.1]
impeller_outer_diameter_mm = 46; //[23:92:0.1]
impeller_hub_diameter_mm = 12; //[6:24:0.1]
impeller_hub_height_mm = 10; //[5:20:0.1]
impeller_blade_count = 25; //[10:60:1]
impeller_blade_thickness_mm = 0.75; //[0.4:1.5:0.05]
mount_hole_diameter_mm = 3.2; //[1.6:6.4:0.1]
mount_hole_count = 2; //[2:4:1]
mount_hole_edge_margin_mm = 4; //[2:8:0.1]
clearance_mm = 0.6; //[0.2:1.5:0.05]
overlap_mm = 1; //[0.5:2:0.1]
lug_diameter_mm = 8; //[6:14:0.1]
shaft_boss_diameter_mm = 6; //[3:12:0.1]

// Blower - Detailed geometry
module blower() {
  color([0.15, 0.15, 0.17]) {
    // Base Plate
    translate([0, 0, -overall_depth_mm/2 + base_thickness_mm/2])
      cube([overall_length_mm, overall_width_mm, base_thickness_mm], center=true);

    // Top Cover Plate
    translate([0, 0, overall_depth_mm/2 - top_thickness_mm/2])
      cube([overall_length_mm, overall_width_mm, top_thickness_mm], center=true);

    // Blower Casing Volute
    difference() {
      translate([0, 0, 0])
        cylinder(h=overall_depth_mm - base_thickness_mm - top_thickness_mm, 
                 r=impeller_outer_diameter_mm/2 + wall_thickness_mm + clearance_mm, center=true);
      translate([0, 0, 0])
        cylinder(h=overall_depth_mm - base_thickness_mm - top_thickness_mm + 2*overlap_mm, 
                 r=impeller_outer_diameter_mm/2 + clearance_mm, center=true);
    }

    // Outlet Exit Duct
    difference() {
      translate([(impeller_outer_diameter_mm/2 + wall_thickness_mm + clearance_mm) + 
                 (outlet_width_mm + 2*wall_thickness_mm)/2 - overlap_mm, 
                 outlet_offset_mm, 
                 -overall_depth_mm/2 + base_thickness_mm + outlet_height_mm/2])
        cube([outlet_width_mm + 2*wall_thickness_mm, outlet_width_mm + 2*wall_thickness_mm, outlet_height_mm], center=true);
      translate([(impeller_outer_diameter_mm/2 + wall_thickness_mm + clearance_mm) + 
                 (outlet_width_mm + 2*wall_thickness_mm)/2 - overlap_mm, 
                 outlet_offset_mm, 
                 -overall_depth_mm/2 + base_thickness_mm + outlet_height_mm/2])
        cube([outlet_width_mm, outlet_width_mm, outlet_height_mm + 2*overlap_mm], center=true);
    }

    // Inlet Bore Opening
    translate([0, 0, overall_depth_mm/2 - top_thickness_mm/2])
      cylinder(h=top_thickness_mm + 2*overlap_mm, r=inlet_bore_diameter_mm/2, center=true);

    // Mounting Screw Lugs
    translate([-overall_length_mm/2 + mount_hole_edge_margin_mm, 0, 
               -overall_depth_mm/2 + (base_thickness_mm + wall_thickness_mm)/2])
      cylinder(h=base_thickness_mm + wall_thickness_mm, r=lug_diameter_mm/2, center=true);
    translate([overall_length_mm/2 - mount_hole_edge_margin_mm, 0, 
               -overall_depth_mm/2 + (base_thickness_mm + wall_thickness_mm)/2])
      cylinder(h=base_thickness_mm + wall_thickness_mm, r=lug_diameter_mm/2, center=true);

    // Mounting Holes
    translate([-overall_length_mm/2 + mount_hole_edge_margin_mm, 0, 0])
      cylinder(h=overall_depth_mm + 2*overlap_mm, r=mount_hole_diameter_mm/2, center=true);
    translate([overall_length_mm/2 - mount_hole_edge_margin_mm, 0, 0])
      cylinder(h=overall_depth_mm + 2*overlap_mm, r=mount_hole_diameter_mm/2, center=true);
  }
}

// Fan - Detailed geometry
module fan() {
  color([0.2, 0.2, 0.22]) {
    // Frame
    difference() {
      cube([overall_length_mm, overall_width_mm, 10], center=true);
      cylinder(d=overall_length_mm-4, h=12, center=true, $fn=32);
    }
    // Hub
    cylinder(d=impeller_hub_diameter_mm, h=impeller_hub_height_mm, center=true, $fn=24);
    // Blades
    for(i=[0:6]) rotate([0,0,i*360/7])
      hull() {
        translate([impeller_hub_diameter_mm/2 + 2, 0, 0]) 
          cylinder(r=2, h=impeller_hub_height_mm, $fn=12);
        translate([impeller_outer_diameter_mm/2 - 3, 3, impeller_hub_height_mm*0.3]) 
          rotate([0,10,15]) cylinder(r=2.5, h=impeller_hub_height_mm*0.7, $fn=12);
      }
  }
}

// Blower Fan - Detailed geometry
module blower_fan() {
  color([0.2, 0.2, 0.22]) {
    // Frame
    difference() {
      cube([overall_length_mm, overall_width_mm, 10], center=true);
      cylinder(d=overall_length_mm-4, h=12, center=true, $fn=32);
    }
    // Hub
    cylinder(d=impeller_hub_diameter_mm, h=impeller_hub_height_mm, center=true, $fn=24);
    // Blades
    for(i=[0:6]) rotate([0,0,i*360/7])
      hull() {
        translate([impeller_hub_diameter_mm/2 + 2, 0, 0]) 
          cylinder(r=2, h=impeller_hub_height_mm, $fn=12);
        translate([impeller_outer_diameter_mm/2 - 3, 3, impeller_hub_height_mm*0.3]) 
          rotate([0,10,15]) cylinder(r=2.5, h=impeller_hub_height_mm*0.7, $fn=12);
      }
  }
}

// Assembly
module assembly() {
  blower();
  translate([0, 0, overall_depth_mm/2 + 5]) fan();
  translate([0, 0, overall_depth_mm/2 + 20]) blower_fan();
}

assembly();