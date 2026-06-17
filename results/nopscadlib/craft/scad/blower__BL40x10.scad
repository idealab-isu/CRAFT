// Parameters
overall_width = 40; //[20:80:0.5]
overall_length = 40; //[20:80:0.5]
overall_depth = 9.5; //[5:19:0.1]
wall_thickness = 1.5; //[0.8:3:0.1]
base_plate_thickness = 1.5; //[0.8:3:0.1]
top_cover_thickness = 1.5; //[0.8:3:0.1]
inlet_bore_diameter = 20; //[10:40:0.5]
outlet_width = 12; //[6:24:0.5]
outlet_height = 6; //[3:12:0.5]
outlet_length = 10; //[5:20:0.5]
impeller_outer_diameter = 34; //[17:38:0.5]
impeller_hub_diameter = 10; //[5:20:0.5]
impeller_blade_count = 25; //[10:40:1]
clearance_radial = 0.5; //[0.2:1.5:0.1]
clearance_axial = 0.5; //[0.2:1.5:0.1]
volute_outer_radius = 18; //[10:25:0.5]
volute_inner_radius = 15; //[8:22:0.5]
axis_offset_x = -4; //[-10:10:0.5]
axis_offset_y = 0; //[-10:10:0.5]
mount_hole_diameter = 3.2; //[2:5:0.1]
mount_hole_pitch = 32; //[20:38:0.5]
lug_diameter = 7; //[5:12:0.5]
overlap = 1; //[0.5:2:0.1]

// Blower module
module blower() {
  color([0.15, 0.15, 0.17]) {
    // Base plate
    translate([0, 0, -overall_depth/2 + base_plate_thickness/2])
      cube([overall_width, overall_length, base_plate_thickness], center=true);

    // Top cover plate
    translate([0, 0, overall_depth/2 - top_cover_thickness/2])
      cube([overall_width, overall_length, top_cover_thickness], center=true);

    // Side walls
    difference() {
      translate([0, 0, 0])
        cube([overall_width, overall_length, overall_depth - base_plate_thickness - top_cover_thickness + overlap*2], center=true);
      translate([0, 0, 0])
        cube([overall_width - 2*wall_thickness, overall_length - 2*wall_thickness, overall_depth - base_plate_thickness - top_cover_thickness + overlap*4], center=true);
    }

    // Volute
    difference() {
      translate([axis_offset_x, axis_offset_y, 0])
        cylinder(r=volute_outer_radius, h=overall_depth - base_plate_thickness - top_cover_thickness + overlap*2, center=true);
      translate([axis_offset_x, axis_offset_y, 0])
        cylinder(r=volute_inner_radius - wall_thickness, h=overall_depth - base_plate_thickness - top_cover_thickness + overlap*4, center=true);
    }

    // Outlet duct
    difference() {
      translate([overall_width/2 + (outlet_length + wall_thickness)/2 - overlap, axis_offset_y, 0])
        cube([outlet_length + wall_thickness, outlet_width + 2*wall_thickness, outlet_height + 2*wall_thickness], center=true);
      translate([overall_width/2 + (outlet_length + wall_thickness)/2 - overlap, axis_offset_y, 0])
        cube([outlet_length + wall_thickness + overlap*2, outlet_width, outlet_height], center=true);
    }

    // Outlet port cut in wall
    translate([overall_width/2 - wall_thickness/2, axis_offset_y, 0])
      cube([wall_thickness + overlap*4, outlet_width, outlet_height], center=true);

    // Inlet bore opening cut
    translate([axis_offset_x, axis_offset_y, overall_depth/2 - top_cover_thickness/2])
      cylinder(r=inlet_bore_diameter/2, h=top_cover_thickness + overlap*4, center=true);

    // Mounting lugs
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * mount_hole_pitch/2, y * mount_hole_pitch/2, -overall_depth/2 + base_plate_thickness/2])
        difference() {
          cylinder(r=lug_diameter/2, h=base_plate_thickness + overlap*2, center=true);
          cylinder(r=mount_hole_diameter/2, h=base_plate_thickness + overlap*6, center=true);
        }
    }
  }
}

// Fan module
module fan() {
  color([0.2, 0.2, 0.22]) {
    // Frame
    difference() {
      cube([overall_width, overall_width, 10], center=true);
      cylinder(d=overall_width-4, h=12, center=true, $fn=32);
    }
    // Hub
    cylinder(d=impeller_hub_diameter, h=8, center=true, $fn=24);
    // Blades
    for(i=[0:6]) rotate([0,0,i*360/7])
      hull() {
        translate([impeller_hub_diameter/2+2,0,-3]) cylinder(r=2, h=6, $fn=8);
        translate([impeller_outer_diameter/2-3,3,0]) rotate([0,12,20]) cylinder(r=2.5, h=5, $fn=8);
      }
  }
}

// Blower Fan module
module blower_fan() {
  blower();
  translate([0, 0, overall_depth/2 + 5]) fan();
}

// Assembly module
module assembly() {
  blower_fan();
}

assembly();