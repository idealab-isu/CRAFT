// Parameters
rod_diameter = 10; //[5:20:0.1]
rod_length = 40; //[20:80:1]
overall_height = 20; //[10:40:0.5]
bracket_width = 30; //[15:60:0.5]
bracket_depth = 20; //[10:40:0.5]
base_thickness = 5; //[2.5:10:0.5]
wall_thickness = 4; //[2:8:0.5]
rod_clearance = 0.2; //[0:1:0.05]
mount_hole_diameter = 4; //[2:8:0.1]
mount_hole_spacing = 20; //[10:40:0.5]
fillet_radius = 1; //[0:3:0.25]
overlap = 1; //[0.5:2:0.1]

// Rod - complete geometry
module rod() {
  color("Silver") {
    translate([0, 0, base_thickness/2 + (overall_height - base_thickness) - rod_diameter/2])
      rotate([90, 0, 0])
      cylinder(r=rod_diameter/2, h=rod_length, center=true, $fn=32);
  }
}

// Bracket with mounting holes and rod bore
module bracket() {
  color("DimGray") {
    difference() {
      union() {
        // Mounting base
        translate([0, 0, 0])
          cube([bracket_width, bracket_depth, base_thickness], center=true);
        // Support body
        translate([0, 0, base_thickness/2 + (overall_height - base_thickness + overlap)/2 - overlap])
          cube([bracket_width, wall_thickness, overall_height - base_thickness + overlap], center=true);
      }
      // Rod bore/cradle
      translate([0, 0, base_thickness/2 + (overall_height - base_thickness) - rod_diameter/2])
        rotate([90, 0, 0])
        cylinder(r=(rod_diameter + rod_clearance)/2, h=wall_thickness + 2*overlap, center=true, $fn=32);
      // Mounting holes
      translate([-mount_hole_spacing/2, 0, 0])
        cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true, $fn=32);
      translate([mount_hole_spacing/2, 0, 0])
        cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true, $fn=32);
    }
  }
}

// Assembly with optional fillets
module assembly() {
  if (fillet_radius > 0) {
    minkowski() {
      bracket();
      sphere(r=fillet_radius, center=true, $fn=16);
    }
  } else {
    bracket();
  }
  rod();
}

// Final assembly call
assembly();