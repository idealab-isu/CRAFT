// Parameters
rail_length = 100.0; //[50.0:200.0:1.0]
rail_width = 15.0; //[7.5:30.0:0.5]
rail_height = 15.0; //[7.5:30.0:0.5]
hole_diameter = 3.5; //[2.0:7.0:0.1]
hole_count = 4; //[2:8:1]
end_margin = 12.0; //[6.0:24.0:0.5]
chamfer_size = 1.0; //[0.5:3.0:0.1]
fillet_radius = 0.8; //[0.3:2.0:0.1]
minkowski_sphere_radius = 0.6; //[0.2:1.5:0.1]
connect_overlap = 1.0; //[0.5:2.0:0.1]
marking_depth = 0.3; //[0.1:1.0:0.1]

// Rail Body
module rail_body() {
  color("Silver")
  cube([rail_width, rail_length, rail_height], center=true);
}

// Mounting Holes
module mounting_hole(position) {
  translate(position)
  rotate([90, 0, 0])
  cylinder(h=rail_height + 2*connect_overlap, r=hole_diameter/2, center=true);
}

module mounting_holes() {
  union() {
    for (i = [0:hole_count-1]) {
      mounting_hole([0, -rail_length/2 + end_margin + i*(rail_length - 2*end_margin)/(hole_count - 1), 0]);
    }
  }
}

// End Chamfers
module end_chamfer_wedge_posY() {
  linear_extrude(height=rail_width + 2*connect_overlap, center=true)
  rotate([0, 0, 90])
  polygon(points=[
    [-rail_height/2 - connect_overlap, rail_length/2 - chamfer_size - connect_overlap],
    [rail_height/2 + connect_overlap, rail_length/2 - chamfer_size - connect_overlap],
    [rail_height/2 + connect_overlap, rail_length/2 + connect_overlap]
  ]);
}

module end_chamfer_wedge_negY() {
  linear_extrude(height=rail_width + 2*connect_overlap, center=true)
  rotate([0, 0, -90])
  polygon(points=[
    [-rail_height/2 - connect_overlap, -rail_length/2 + chamfer_size + connect_overlap],
    [rail_height/2 + connect_overlap, -rail_length/2 + chamfer_size + connect_overlap],
    [rail_height/2 + connect_overlap, -rail_length/2 - connect_overlap]
  ]);
}

module end_chamfers() {
  union() {
    end_chamfer_wedge_posY();
    end_chamfer_wedge_negY();
  }
}

// Fillet Sphere Tool
module fillet_sphere_tool() {
  sphere(r=minkowski_sphere_radius, center=true);
}

// Engraved Markings (ignored per no-text rule)
module engraved_markings() {
  translate([0, 0, rail_height/2 - marking_depth/2 + connect_overlap])
  cube([rail_width*0.6, rail_length*0.4, marking_depth], center=true);
}

// Complete Model
difference() {
  minkowski() {
    difference() {
      difference() {
        rail_body();
        mounting_holes();
      }
      end_chamfers();
    }
    fillet_sphere_tool();
  }
  engraved_markings();
}