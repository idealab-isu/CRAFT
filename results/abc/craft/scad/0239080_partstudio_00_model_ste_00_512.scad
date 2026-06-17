// Parameters
L = 0.41; //[0.205:0.82:0.001]
W = 0.04; //[0.02:0.08:0.001]
H_total = 0.01; //[0.005:0.02:0.0005]
plate_H = 0.006; //[0.003:0.012:0.0005]
stud_H = 0.004; //[0.002:0.008:0.0005]
stud_D = 0.02; //[0.01:0.04:0.001]
stud_count = 7; //[3:15:1]
end_margin = 0.03; //[0.015:0.06:0.001]
stud_centerline_offset_W = 0.0; //[-0.01:0.01:0.0005]
stud_top_rounding = 0.002; //[0.001:0.004:0.0005]
overlap = 0.0008; //[0.0005:0.002:0.0001]
edge_fillet_r = 0.001; //[0.0005:0.002:0.0001]
chamfer_len = 0.003; //[0.0015:0.006:0.0005]

// Base Plate
module base_plate() {
  color("Silver")
  translate([0, 0, 0])
    cube([L, W, plate_H], center=true);
}

// Stud Cylinder
module stud_cylinder(index) {
  translate([
    -L/2 + end_margin + index * ((L - 2*end_margin) / (stud_count-1)),
    stud_centerline_offset_W,
    plate_H/2 + (stud_H + overlap)/2 - overlap
  ])
  cylinder(h=stud_H + overlap, r=stud_D/2, center=true);
}

// Stud Rounding Sphere
module stud_rounding_sphere(index) {
  translate([
    -L/2 + end_margin + index * ((L - 2*end_margin) / (stud_count-1)),
    stud_centerline_offset_W,
    plate_H/2 + stud_H - stud_top_rounding
  ])
  sphere(r=stud_top_rounding, center=true);
}

// Stud Row
module stud_row() {
  union() {
    for (i = [0:stud_count-1]) {
      stud_cylinder(i);
      stud_rounding_sphere(i);
    }
  }
}

// Edge Fillets Kernel
module edge_fillets_kernel() {
  sphere(r=edge_fillet_r, center=true);
}

// End Chamfer Wedge
module end_chamfer_wedge(pos) {
  translate([
    pos * (L/2 - chamfer_len/2 + overlap),
    0,
    H_total/2 - plate_H/2
  ])
  cube([chamfer_len, W + 2*overlap, H_total + 2*overlap], center=true);
}

// Final Model
module final_model() {
  difference() {
    minkowski() {
      union() {
        base_plate();
        stud_row();
      }
      edge_fillets_kernel();
    }
    end_chamfer_wedge(1);
    end_chamfer_wedge(-1);
  }
}

// Render the final model
final_model();