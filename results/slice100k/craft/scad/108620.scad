// Parameters
OD_flange = 8.6; //[4.3:17.2:0.01]
H_total = 6.19; //[3.095:12.38:0.01]
H_flange = 2.0; //[1.0:4.0:0.01]
OD_boss = 5.0; //[2.5:10.0:0.01]
H_boss = 4.19; //[2.095:8.38:0.01]
overlap = 0.6; //[0.2:1.5:0.01]
chamfer_h = 0.25; //[0.1:0.8:0.01]
fillet_r = 0.35; //[0.1:1.0:0.01]
mark_r = 0.25; //[0.1:0.6:0.01]

// Base Shapes
module flange_disk() {
  translate([0, 0, -H_total/2 + H_flange/2])
    cylinder(r=OD_flange/2, h=H_flange, center=true);
}

module center_boss() {
  translate([0, 0, -H_total/2 + H_flange + H_boss/2 - overlap])
    cylinder(r=OD_boss/2, h=H_boss, center=true);
}

module shoulder_interface() {
  translate([0, 0, -H_total/2 + H_flange - overlap])
    cylinder(r=OD_boss/2, h=overlap*2, center=true);
}

module edge_chamfer_flange_top() {
  translate([0, 0, -H_total/2 + H_flange - chamfer_h/2])
    rotate([180, 0, 0])
      cylinder(r1=OD_flange/2, r2=0, h=chamfer_h, center=true);
}

module edge_chamfer_boss_top() {
  translate([0, 0, H_total/2 - chamfer_h/2])
    rotate([180, 0, 0])
      cylinder(r1=OD_boss/2, r2=0, h=chamfer_h, center=true);
}

module edge_fillet_flange_outer() {
  translate([0, 0, -H_total/2 + fillet_r])
    rotate_extrude()
      translate([OD_flange/2 - fillet_r, 0, 0])
        circle(r=fillet_r);
}

module edge_fillet_boss_outer() {
  translate([0, 0, H_total/2 - fillet_r])
    rotate_extrude()
      translate([OD_boss/2 - fillet_r, 0, 0])
        circle(r=fillet_r);
}

module surface_marking_1() {
  translate([OD_boss/2 - mark_r, 0, H_total/2 - mark_r])
    sphere(r=mark_r, center=true);
}

module surface_marking_2() {
  translate([0, OD_boss/2 - mark_r, H_total/2 - mark_r])
    sphere(r=mark_r, center=true);
}

// Final Model
union() {
  union() {
    union() {
      flange_disk();
      center_boss();
      shoulder_interface();
    }
    edge_chamfer_flange_top();
    edge_chamfer_boss_top();
  }
  edge_fillet_flange_outer();
  edge_fillet_boss_outer();
  surface_marking_1();
  surface_marking_2();
}