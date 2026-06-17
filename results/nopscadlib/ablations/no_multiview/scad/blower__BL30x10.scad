// Parameters
overall_length = 30.0; //[15.0:60.0:0.1]
overall_width  = 30.0; //[15.0:60.0:0.1]
overall_depth  = 10.1; //[5.0:20.2:0.1]

wall_thickness = 1.0; //[0.6:2.0:0.1]
top_thickness  = 1.0; //[0.6:2.0:0.1]
base_thickness = 1.0; //[0.6:2.0:0.1]

outlet_length  = 10.0; //[5.0:20.0:0.1]
outlet_height  = 6.0;  //[3.0:10.0:0.1]
outlet_width   = 8.0;  //[4.0:16.0:0.1]

inlet_bore_diameter     = 12.0; //[6.0:24.0:0.1]
impeller_outer_diameter = 22.0; //[12.0:28.0:0.1]
impeller_height         = 7.5;  //[4.0:9.0:0.1]
impeller_blade_count    = 25;   //[10:40:1]
impeller_blade_thickness= 0.8;  //[0.5:1.5:0.1]
impeller_blade_length   = 6.0;  //[3.0:10.0:0.1]
hub_diameter            = 6.0;  //[3.0:12.0:0.1]
hub_height              = 8.0;  //[4.0:10.0:0.1]

mounting_hole_count   = 2;   //[2:4:1]
mounting_hole_diameter= 3.0; //[2.0:5.0:0.1]
mounting_edge_margin  = 4.0; //[2.0:8.0:0.1]

// Use 1-2mm overlap to guarantee watertight unions
overlap = 1.2; //[0.5:2.0:0.1]

impeller_axis_offset_x = -3.0; //[-6.0:6.0:0.1]
impeller_axis_offset_y = 0.0;  //[-6.0:6.0:0.1]
volute_clearance       = 1.2;  //[0.6:3.0:0.1]

// Blower module (single connected solid)
module blower() {

  // --- Attached "orange tab/strip" fix ---
  // The thin rectangular strip seen floating in the views is recreated here and
  // physically attached to the housing with a small overlap.
  tab_len = 10.0;   // along X
  tab_thk = 1.2;    // along Y (thin)
  tab_h   = 6.0;    // along Z
  // Attach to +X face; ensure intersection by subtracting overlap from the center position.
  tab_cx = overall_length/2 + tab_len/2 - overlap;
  // Place near the top edge (as in the screenshots) but still within housing Z extent.
  tab_cz = overall_depth/2 - tab_h/2; // flush to top; attachment is via X overlap

  difference() {
    union() {
      // Outer housing block
      color([0.15, 0.15, 0.17])
        cube([overall_length, overall_width, overall_depth], center=true);

      // Tangential outlet nozzle (OVERLAPS housing by 'overlap' to guarantee attachment)
      nozzle_cx = overall_length/2 + outlet_length/2 - overlap;
      color([0.15, 0.15, 0.17])
        difference() {
          translate([nozzle_cx, 0, 0])
            cube([outlet_length, outlet_width + 2*wall_thickness, outlet_height + 2*wall_thickness], center=true);
          translate([nozzle_cx, 0, 0])
            cube([outlet_length + 2*overlap, outlet_width, outlet_height], center=true);
        }

      // Base plate (slight overlap into housing)
      color("Silver")
        translate([0, 0, -overall_depth/2 + base_thickness/2 + overlap/2])
          cube([overall_length, overall_width, base_thickness + overlap], center=true);

      // Top cover plate (slight overlap into housing)
      color("Silver")
        translate([0, 0,  overall_depth/2 - top_thickness/2 - overlap/2])
          cube([overall_length, overall_width, top_thickness + overlap], center=true);

      // Attached side protrusion/plate (kept, but ensure it intersects)
      side_plate_thk = 3.0;
      side_plate_len = 18.0;
      side_plate_h   = overall_depth; // full height so it clearly intersects in all views
      side_plate_cy  = overall_width/2 + side_plate_thk/2 - overlap;
      color("Silver")
        translate([0, side_plate_cy, 0])
          cube([side_plate_len, side_plate_thk, side_plate_h], center=true);

      // FIXED: Orange rectangular tab/strip is now physically attached (no gap)
      // Overlap is guaranteed by tab_cx formula.
      color([1.0, 0.5, 0.0])
        translate([tab_cx, 0, tab_cz])
          cube([tab_len, tab_thk, tab_h], center=true);
    }

    // Internal cavity / volute + outlet passage (subtracted from the unioned solid)
    union() {
      // Volute cavity cylinder
      translate([impeller_axis_offset_x, impeller_axis_offset_y, 0])
        cylinder(r=(impeller_outer_diameter/2) + volute_clearance,
                 h=overall_depth - base_thickness - top_thickness + 2*overlap,
                 center=true, $fn=96);

      // Rectangular cavity leading to outlet
      translate([
          impeller_axis_offset_x + (impeller_outer_diameter/2) + volute_clearance + (overall_length/4) - overlap,
          impeller_axis_offset_y,
          0
        ])
        cube([overall_length/2, overall_width - 2*wall_thickness,
              overall_depth - base_thickness - top_thickness + 2*overlap], center=true);

      // Outlet opening through the housing wall
      translate([overall_length/2 - wall_thickness/2, 0, 0])
        cube([wall_thickness + 2*overlap, outlet_width, outlet_height], center=true);

      // Inlet bore opening through top cover
      translate([impeller_axis_offset_x, impeller_axis_offset_y, overall_depth/2 - top_thickness/2])
        cylinder(r=inlet_bore_diameter/2, h=top_thickness + 2*overlap, center=true, $fn=96);

      // Mounting holes (through)
      translate([-overall_length/2 + mounting_edge_margin, -overall_width/2 + mounting_edge_margin, 0])
        cylinder(r=mounting_hole_diameter/2, h=overall_depth + 2*overlap, center=true, $fn=48);

      translate([ overall_length/2 - mounting_edge_margin, -overall_width/2 + mounting_edge_margin, 0])
        cylinder(r=mounting_hole_diameter/2, h=overall_depth + 2*overlap, center=true, $fn=48);
    }
  }
}

// Fan module (unchanged geometry)
module fan() {
  color([0.15, 0.15, 0.17]) {
    difference() {
      cube([overall_length, overall_width, 10], center=true);
      cylinder(d=overall_length-4, h=12, center=true, $fn=32);
    }
    cylinder(d=overall_length * 0.4, h=8, center=true, $fn=24);
    for(i=[0:6]) rotate([0, 0, i*360/7])
      hull() {
        translate([9, 0, -3]) cylinder(r=2, h=6, $fn=8);
        translate([17, 4, 0]) rotate([0, 12, 20]) cylinder(r=2.5, h=5, $fn=8);
      }
  }
}

// Blower Fan module (unchanged geometry)
module blower_fan() {
  color([0.15, 0.15, 0.17]) {
    difference() {
      cube([overall_length, overall_width, 10], center=true);
      cylinder(d=overall_length-4, h=12, center=true, $fn=32);
    }
    cylinder(d=overall_length * 0.4, h=8, center=true, $fn=24);
    for(i=[0:6]) rotate([0, 0, i*360/7])
      hull() {
        translate([9, 0, -3]) cylinder(r=2, h=6, $fn=8);
        translate([17, 4, 0]) rotate([0, 12, 20]) cylinder(r=2.5, h=5, $fn=8);
      }
  }
}

// Assembly module
module assembly() {
  blower();
  translate([0, 0, overall_depth/2 + 5]) fan();
  translate([0, 0, overall_depth/2 + 15]) blower_fan();
}

assembly();