// Parameters
tube_length = 100; //[50:200:1]
outer_W = 20; //[10:40:1]
outer_H = 20; //[10:40:1]
wall_t = 2; //[1:6:0.5]
eps = 0.8; //[0.2:2:0.1]
chamfer = 0.8; //[0.2:2:0.1]
fillet_r = 0.6; //[0.2:2:0.1]
end_face_trim = 0.5; //[0.2:2:0.1]

// Base Shapes
module outer_tube_body() {
  cube([outer_W, outer_H, tube_length], center=true);
}

module inner_void_cutout() {
  cube([outer_W - 2*wall_t, outer_H - 2*wall_t, tube_length + 2*eps], center=true);
}

module end_face_trim_block() {
  cube([outer_W + 2*eps, outer_H + 2*eps, end_face_trim], center=true);
}

module fillet_sphere() {
  sphere(r=fillet_r, center=true);
}

module chamfer_sphere() {
  sphere(r=chamfer, center=true);
}

module material_labeling() {
  cube([outer_W - 2*wall_t, outer_H - 2*wall_t, wall_t], center=true);
}

// Operations
module tube_shell_diff() {
  difference() {
    outer_tube_body();
    inner_void_cutout();
  }
}

module end_faces() {
  difference() {
    tube_shell_diff();
    translate([0, 0, tube_length/2 - end_face_trim/2 + eps]) end_face_trim_block();
    translate([0, 0, -tube_length/2 + end_face_trim/2 - eps]) end_face_trim_block();
  }
}

module edge_chamfers() {
  minkowski() {
    end_faces();
    chamfer_sphere();
  }
}

module fillets() {
  minkowski() {
    edge_chamfers();
    fillet_sphere();
  }
}

module final_model_union() {
  union() {
    fillets();
    translate([0, 0, -tube_length/2 + wall_t/2 - eps]) material_labeling();
  }
}

// Final Output
final_model_union();