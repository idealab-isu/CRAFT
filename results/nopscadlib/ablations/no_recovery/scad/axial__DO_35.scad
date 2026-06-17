// Parameters
L = 3.4; //[1.7:6.8:0.1]
OD = 1.75; //[0.9:3.5:0.05]
t = 0.3; //[0.15:0.6:0.05]
ID = 1.15; //[0.5:2.8:0.05]
overlap = 0.6; //[0.2:1.2:0.1]
chamfer = 0.2; //[0.05:0.4:0.05]
fillet_r = 0.08; //[0.02:0.2:0.01]
eps = 0.02; //[0.01:0.1:0.01]

// Base Shapes
module axial_body() {
  translate([0, 0, 0])
    cylinder(h=L, r=OD/2, center=true);
}

module inner_bore() {
  translate([0, 0, 0])
    cylinder(h=L + 2*overlap, r=ID/2, center=true);
}

module end_chamfer_top() {
  translate([0, 0, L/2 - chamfer/2 + eps])
    cylinder(h=chamfer, r1=OD/2 + eps, r2=0, center=true);
}

module end_chamfer_bottom() {
  translate([0, 0, -L/2 + chamfer/2 - eps])
    cylinder(h=chamfer, r1=OD/2 + eps, r2=0, center=true);
}

module fillet_sphere() {
  translate([0, 0, 0])
    sphere(r=fillet_r, center=true);
}

module markings() {
  translate([0, 0, 0])
    cube([eps, eps, eps], center=true);
}

// Operations
module sleeve_raw() {
  difference() {
    axial_body();
    inner_bore();
  }
}

module sleeve_chamfered() {
  difference() {
    sleeve_raw();
    end_chamfer_top();
    end_chamfer_bottom();
  }
}

module sleeve_fillet_pre() {
  minkowski() {
    sleeve_chamfered();
    fillet_sphere();
  }
}

module sleeve_fillet_trim() {
  difference() {
    sleeve_fillet_pre();
    inner_bore();
  }
}

module final_model() {
  union() {
    sleeve_fillet_trim();
    markings();
  }
}

// Final Output
final_model();