// Parameters
plate_L = 300; //[150:600:1]
plate_W = 200; //[100:400:1]
plate_T = 12; //[6:24:1]
chamfer_C = 10; //[5:20:1]
edge_fillet_R = 2; //[1:6:0.5]
connect_overlap = 1; //[0.5:2:0.5]

// Base Shapes
module plate_body() {
  translate([0, 0, 0])
    cube([plate_L, plate_W, plate_T], center=true);
}

module corner_chamfer_cut_NE() {
  translate([plate_L/2 - chamfer_C/2 + connect_overlap, plate_W/2 - chamfer_C/2 + connect_overlap, 0])
    rotate([0, 0, 45])
      cube([chamfer_C, chamfer_C, plate_T + 2*connect_overlap], center=true);
}

module corner_chamfer_cut_NW() {
  translate([-plate_L/2 + chamfer_C/2 - connect_overlap, plate_W/2 - chamfer_C/2 + connect_overlap, 0])
    rotate([0, 0, 45])
      cube([chamfer_C, chamfer_C, plate_T + 2*connect_overlap], center=true);
}

module corner_chamfer_cut_SW() {
  translate([-plate_L/2 + chamfer_C/2 - connect_overlap, -plate_W/2 + chamfer_C/2 - connect_overlap, 0])
    rotate([0, 0, 45])
      cube([chamfer_C, chamfer_C, plate_T + 2*connect_overlap], center=true);
}

module corner_chamfer_cut_SE() {
  translate([plate_L/2 - chamfer_C/2 + connect_overlap, -plate_W/2 + chamfer_C/2 - connect_overlap, 0])
    rotate([0, 0, 45])
      cube([chamfer_C, chamfer_C, plate_T + 2*connect_overlap], center=true);
}

module edge_fillet_sphere() {
  translate([0, 0, 0])
    sphere(r=edge_fillet_R, center=true);
}

// Operations
module corner_chamfers() {
  difference() {
    plate_body();
    corner_chamfer_cut_NE();
    corner_chamfer_cut_NW();
    corner_chamfer_cut_SW();
    corner_chamfer_cut_SE();
  }
}

module edge_fillet() {
  minkowski() {
    corner_chamfers();
    edge_fillet_sphere();
  }
}

// Final Output
color("Silver") edge_fillet();