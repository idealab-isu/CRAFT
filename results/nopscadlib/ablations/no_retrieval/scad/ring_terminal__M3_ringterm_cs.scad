// Parameters
tongue_length = 18; //[9:36:1]
tongue_width = 10; //[5:20:1]
tongue_thickness = 1.2; //[0.6:2.4:0.1]
hole_diameter = 5.3; //[2.65:10.6:0.1]
ring_outer_diameter = 10; //[5:20:0.5]
neck_length = 6; //[3:12:1]
neck_width = 6; //[3:12:1]
barrel_length = 18; //[9:36:1]
barrel_outer_diameter = 6; //[3:12:0.5]
barrel_inner_diameter = 3.5; //[1.5:9:0.1]
overlap = 0.8; //[0.5:2:0.1]
crimp_indent_depth = 0.6; //[0.2:1.5:0.1]
crimp_indent_width = 2.2; //[1:5:0.1]
crimp_indent_count = 2; //[1:4:1]
sleeve_thickness = 1; //[0.5:2.5:0.1]
sleeve_length = 14; //[7:28:1]
sleeve_clearance = 0.3; //[0.1:1:0.1]
chamfer_size = 0.6; //[0.2:1.5:0.1]

// Base Shapes
module ring_tongue_disc() {
  translate([0, 0, 0])
    cylinder(r=ring_outer_diameter/2, h=tongue_thickness, center=true);
}

module tongue_rect() {
  translate([ring_outer_diameter/2 + tongue_length/2 - overlap, 0, 0])
    cube([tongue_length, tongue_width, tongue_thickness], center=true);
}

module tongue_to_barrel_neck() {
  translate([ring_outer_diameter/2 + tongue_length - overlap + neck_length/2 - overlap, 0, 0])
    cube([neck_length, neck_width, tongue_thickness], center=true);
}

module wire_barrel_outer() {
  translate([ring_outer_diameter/2 + tongue_length - overlap + neck_length - overlap + barrel_length/2 - overlap, 0, 0])
    rotate([0, 90, 0])
      cylinder(r=barrel_outer_diameter/2, h=barrel_length, center=true);
}

module mounting_hole() {
  translate([0, 0, 0])
    cylinder(r=hole_diameter/2, h=tongue_thickness + 2*overlap, center=true);
}

module barrel_wire_entry_hole() {
  translate([ring_outer_diameter/2 + tongue_length - overlap + neck_length - overlap + barrel_length/2 - overlap, 0, 0])
    rotate([0, 90, 0])
      cylinder(r=barrel_inner_diameter/2, h=barrel_length + 2*overlap, center=true);
}

module crimp_indent_1() {
  translate([ring_outer_diameter/2 + tongue_length - overlap + neck_length - overlap + barrel_length*(1/(crimp_indent_count+1)), barrel_outer_diameter/2 - crimp_indent_depth, 0])
    rotate([90, 0, 0])
      cylinder(r=barrel_outer_diameter/2, h=crimp_indent_width, center=true);
}

module crimp_indent_2() {
  translate([ring_outer_diameter/2 + tongue_length - overlap + neck_length - overlap + barrel_length*(2/(crimp_indent_count+1)), barrel_outer_diameter/2 - crimp_indent_depth, 0])
    rotate([90, 0, 0])
      cylinder(r=barrel_outer_diameter/2, h=crimp_indent_width, center=true);
}

module edge_chamfer_cut_ring_posx() {
  translate([ring_outer_diameter/2 - chamfer_size/2, 0, 0])
    rotate([0, 0, 45])
      cube([chamfer_size, ring_outer_diameter, tongue_thickness + 2*overlap], center=true);
}

module edge_chamfer_cut_ring_negx() {
  translate([-ring_outer_diameter/2 + chamfer_size/2, 0, 0])
    rotate([0, 0, 45])
      cube([chamfer_size, ring_outer_diameter, tongue_thickness + 2*overlap], center=true);
}

module insulation_sleeve_outer() {
  translate([ring_outer_diameter/2 + tongue_length - overlap + neck_length - overlap + (barrel_length - sleeve_length)/2 + sleeve_length/2 - overlap, 0, 0])
    rotate([0, 90, 0])
      cylinder(r=barrel_outer_diameter/2 + sleeve_clearance + sleeve_thickness, h=sleeve_length, center=true);
}

module insulation_sleeve_inner() {
  translate([ring_outer_diameter/2 + tongue_length - overlap + neck_length - overlap + (barrel_length - sleeve_length)/2 + sleeve_length/2 - overlap, 0, 0])
    rotate([0, 90, 0])
      cylinder(r=barrel_outer_diameter/2 + sleeve_clearance, h=sleeve_length + 2*overlap, center=true);
}

// Operations
module tongue_union() {
  union() {
    ring_tongue_disc();
    tongue_rect();
    tongue_to_barrel_neck();
  }
}

module tongue_with_hole() {
  difference() {
    tongue_union();
    mounting_hole();
  }
}

module barrel_solid() {
  union() {
    wire_barrel_outer();
  }
}

module barrel_hollow() {
  difference() {
    barrel_solid();
    barrel_wire_entry_hole();
  }
}

module barrel_with_crimps() {
  difference() {
    barrel_hollow();
    crimp_indent_1();
    crimp_indent_2();
  }
}

module metal_body_union() {
  union() {
    tongue_with_hole();
    barrel_with_crimps();
  }
}

module metal_body_with_edge_chamfers() {
  difference() {
    metal_body_union();
    edge_chamfer_cut_ring_posx();
    edge_chamfer_cut_ring_negx();
  }
}

module insulation_sleeve_hollow() {
  difference() {
    insulation_sleeve_outer();
    insulation_sleeve_inner();
  }
}

// Final Model
module complete_model() {
  union() {
    metal_body_with_edge_chamfers();
    insulation_sleeve_hollow();
  }
}

// Render the complete model
complete_model();