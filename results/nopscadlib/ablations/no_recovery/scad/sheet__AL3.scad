// Parameters
plate_length = 300; //[150:600:1]
plate_width = 200; //[100:400:1]
plate_thickness = 10; //[5:20:1]
corner_radius = 5; //[0:20:1]
chamfer_size = 1; //[0:5:0.5]
corner_overlap = 1; //[0.5:2:0.5]
hole_diameter = 8; //[3:20:0.5]
hole_edge_margin = 20; //[10:60:1]
hole_through_extra = 2; //[1:5:0.5]
texture_depth = 0.2; //[0:1:0.05]
texture_pitch = 20; //[10:60:1]
texture_dimple_radius = 3; //[1:10:0.5]

// Base shapes
module tooling_plate_body() {
  translate([0, 0, 0])
    cube([plate_length, plate_width, plate_thickness], center=true);
}

module corner_round_cyl() {
  translate([plate_length/2 - corner_radius, plate_width/2 - corner_radius, 0])
    cylinder(h=plate_thickness + 2*corner_overlap, r=corner_radius, center=true);
}

module corner_round_cyl_2() {
  translate([-plate_length/2 + corner_radius, plate_width/2 - corner_radius, 0])
    cylinder(h=plate_thickness + 2*corner_overlap, r=corner_radius, center=true);
}

module corner_round_cyl_3() {
  translate([-plate_length/2 + corner_radius, -plate_width/2 + corner_radius, 0])
    cylinder(h=plate_thickness + 2*corner_overlap, r=corner_radius, center=true);
}

module corner_round_cyl_4() {
  translate([plate_length/2 - corner_radius, -plate_width/2 + corner_radius, 0])
    cylinder(h=plate_thickness + 2*corner_overlap, r=corner_radius, center=true);
}

module corner_chamfer_cut_1() {
  translate([plate_length/2 - chamfer_size/2, plate_width/2 - chamfer_size/2, 0])
    cube([chamfer_size, chamfer_size, plate_thickness + 2*corner_overlap], center=true);
}

module corner_chamfer_cut_2() {
  translate([-plate_length/2 + chamfer_size/2, plate_width/2 - chamfer_size/2, 0])
    cube([chamfer_size, chamfer_size, plate_thickness + 2*corner_overlap], center=true);
}

module corner_chamfer_cut_3() {
  translate([-plate_length/2 + chamfer_size/2, -plate_width/2 + chamfer_size/2, 0])
    cube([chamfer_size, chamfer_size, plate_thickness + 2*corner_overlap], center=true);
}

module corner_chamfer_cut_4() {
  translate([plate_length/2 - chamfer_size/2, -plate_width/2 + chamfer_size/2, 0])
    cube([chamfer_size, chamfer_size, plate_thickness + 2*corner_overlap], center=true);
}

module mount_hole_1() {
  translate([plate_length/2 - hole_edge_margin, plate_width/2 - hole_edge_margin, 0])
    cylinder(h=plate_thickness + hole_through_extra, r=hole_diameter/2, center=true);
}

module mount_hole_2() {
  translate([-plate_length/2 + hole_edge_margin, plate_width/2 - hole_edge_margin, 0])
    cylinder(h=plate_thickness + hole_through_extra, r=hole_diameter/2, center=true);
}

module mount_hole_3() {
  translate([-plate_length/2 + hole_edge_margin, -plate_width/2 + hole_edge_margin, 0])
    cylinder(h=plate_thickness + hole_through_extra, r=hole_diameter/2, center=true);
}

module mount_hole_4() {
  translate([plate_length/2 - hole_edge_margin, -plate_width/2 + hole_edge_margin, 0])
    cylinder(h=plate_thickness + hole_through_extra, r=hole_diameter/2, center=true);
}

module texture_dimple_1() {
  translate([-texture_pitch/2, -texture_pitch/2, plate_thickness/2 - texture_depth + texture_dimple_radius])
    sphere(r=texture_dimple_radius, center=true);
}

module texture_dimple_2() {
  translate([texture_pitch/2, -texture_pitch/2, plate_thickness/2 - texture_depth + texture_dimple_radius])
    sphere(r=texture_dimple_radius, center=true);
}

module texture_dimple_3() {
  translate([-texture_pitch/2, texture_pitch/2, plate_thickness/2 - texture_depth + texture_dimple_radius])
    sphere(r=texture_dimple_radius, center=true);
}

module texture_dimple_4() {
  translate([texture_pitch/2, texture_pitch/2, plate_thickness/2 - texture_depth + texture_dimple_radius])
    sphere(r=texture_dimple_radius, center=true);
}

// Operations
module corner_radii_or_chamfers_union() {
  union() {
    corner_round_cyl();
    corner_round_cyl_2();
    corner_round_cyl_3();
    corner_round_cyl_4();
  }
}

module plate_with_corner_radii() {
  union() {
    tooling_plate_body();
    corner_radii_or_chamfers_union();
  }
}

module chamfer_cuts_union() {
  union() {
    corner_chamfer_cut_1();
    corner_chamfer_cut_2();
    corner_chamfer_cut_3();
    corner_chamfer_cut_4();
  }
}

module plate_with_corners() {
  difference() {
    plate_with_corner_radii();
    chamfer_cuts_union();
  }
}

module mounting_holes_union() {
  union() {
    mount_hole_1();
    mount_hole_2();
    mount_hole_3();
    mount_hole_4();
  }
}

module plate_with_mounting_holes() {
  difference() {
    plate_with_corners();
    mounting_holes_union();
  }
}

module surface_texture_union() {
  union() {
    texture_dimple_1();
    texture_dimple_2();
    texture_dimple_3();
    texture_dimple_4();
  }
}

module plate_with_surface_texture() {
  difference() {
    plate_with_mounting_holes();
    surface_texture_union();
  }
}

// Final output
color("Silver") plate_with_surface_texture();