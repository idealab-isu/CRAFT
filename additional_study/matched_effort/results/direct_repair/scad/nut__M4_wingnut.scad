$fn = 96;

// Wing nut for M4 (4.0mm) screw
// 10.0mm across flats, 3.75mm thick

across_flats = 10.0;
thickness    = 3.75;

screw_d      = 4.0;
clearance    = 0.35;          // typical clearance for M4
hole_d       = screw_d + clearance;

hex_r = across_flats / sqrt(3); // circumradius for given across-flats

// Wing geometry (simple, printable wings)
wing_span_total = 22.0;       // overall width including wings
wing_len_each   = (wing_span_total - 2*hex_r) / 2;
wing_width      = 7.0;        // front-to-back width of each wing
wing_root_round = 1.2;        // fillet-ish via hull
edge_chamfer    = 0.6;        // top/bottom chamfer amount

module hex_prism(h, r){
  linear_extrude(height=h)
    polygon([for(i=[0:5]) [r*cos(60*i), r*sin(60*i)]]);
}

module chamfered_body(){
  // Create a slight chamfer by hulling three slices
  hull(){
    translate([0,0,0])           linear_extrude(height=0.01) offset(delta=0) body_2d();
    translate([0,0,edge_chamfer]) linear_extrude(height=0.01) offset(delta=-edge_chamfer) body_2d();
  }
  translate([0,0,edge_chamfer])
    linear_extrude(height=thickness-2*edge_chamfer)
      offset(delta=-edge_chamfer) body_2d();
  hull(){
    translate([0,0,thickness-edge_chamfer]) linear_extrude(height=0.01) offset(delta=-edge_chamfer) body_2d();
    translate([0,0,thickness])              linear_extrude(height=0.01) offset(delta=0) body_2d();
  }
}

module body_2d(){
  // Union of hex and two wings
  union(){
    // Hex core
    polygon([for(i=[0:5]) [hex_r*cos(60*i), hex_r*sin(60*i)]]);
    // Wings (left/right), made by hulling two circles to get rounded ends
    for(side=[-1,1]){
      hull(){
        translate([side*(hex_r-0.2), 0]) circle(r=wing_root_round);
        translate([side*(hex_r + wing_len_each), 0]) circle(r=wing_width/2);
      }
    }
  }
}

difference(){
  chamfered_body();

  // Through hole for screw
  translate([0,0,-0.5])
    cylinder(h=thickness+1.0, d=hole_d, $fn=96);

  // Optional slight countersink on both sides for easier start
  cs_d = hole_d + 1.2;
  cs_h = 0.6;
  translate([0,0,-0.01])
    cylinder(h=cs_h, d1=cs_d, d2=hole_d, $fn=96);
  translate([0,0,thickness-cs_h+0.01])
    cylinder(h=cs_h, d1=hole_d, d2=cs_d, $fn=96);
}