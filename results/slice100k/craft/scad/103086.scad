// Parameters
L = 55.44; //[27.72:110.88:0.01]
W = 31.55; //[15.78:63.1:0.01]
H = 37.52; //[18.76:75.04:0.01]
bar_thk = 8.0; //[4.0:16.0:0.1]
bar_h = 12.0; //[6.0:24.0:0.1]
leg_tall_h = 37.52; //[18.76:37.52:0.01]
leg_short_h = 24.0; //[12.0:37.52:0.1]
leg_len = 12.0; //[6.0:24.0:0.1]
throat_w = 15.55; //[7.78:31.1:0.01]
throat_h = 25.52; //[12.76:51.04:0.01]
hex_af = 8.0; //[4.0:16.0:0.1]
hex_pos_from_end = 10.0; //[5.0:20.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
chamfer_len = 4.0; //[2.0:8.0:0.1]
fillet_r = 1.2; //[0.5:3.0:0.1]
eps = 0.2; //[0.05:0.5:0.05]

// Base Shapes
module main_bar() {
  translate([0, 0, -H/2 + bar_thk/2])
    cube([L, bar_h, bar_thk], center=true);
}

module end_leg_tall() {
  translate([-L/2 + leg_len/2, 0, 0])
    cube([leg_len, W, leg_tall_h], center=true);
}

module end_leg_short() {
  translate([L/2 - leg_len/2, 0, -H/2 + leg_short_h/2])
    cube([leg_len, W, leg_short_h], center=true);
}

module u_throat_opening() {
  translate([0, 0, -H/2 + bar_thk + throat_h/2])
    cube([L - 2*leg_len + 2*eps, throat_w, throat_h + 2*eps], center=true);
}

module hex_through_hole() {
  translate([-L/2 + hex_pos_from_end, 0, -H/2 + bar_thk/2])
    rotate([90, 0, 0])
      linear_extrude(height=W + 2*eps, center=true)
        polygon(points=[
          [hex_af/sqrt(3), 0],
          [hex_af/(2*sqrt(3)), hex_af/2],
          [-hex_af/(2*sqrt(3)), hex_af/2],
          [-hex_af/sqrt(3), 0],
          [-hex_af/(2*sqrt(3)), -hex_af/2],
          [hex_af/(2*sqrt(3)), -hex_af/2]
        ]);
}

module tall_leg_outer_chamfer_or_taper() {
  translate([-L/2 + chamfer_len/2, 0, 0])
    rotate([0, 15, 0])
      cube([chamfer_len, W + 2*eps, leg_tall_h + 2*eps], center=true);
}

module edge_fillets() {
  sphere(r=fillet_r, center=true);
}

// Operations
module u_bracket_raw_union() {
  union() {
    main_bar();
    end_leg_tall();
    end_leg_short();
  }
}

module u_bracket_with_throat() {
  difference() {
    u_bracket_raw_union();
    u_throat_opening();
  }
}

module u_bracket_with_hex_hole() {
  difference() {
    u_bracket_with_throat();
    hex_through_hole();
  }
}

module u_bracket_with_taper() {
  difference() {
    u_bracket_with_hex_hole();
    tall_leg_outer_chamfer_or_taper();
  }
}

module u_bracket_fillet_minkowski() {
  minkowski() {
    u_bracket_with_taper();
    edge_fillets();
  }
}

module u_bracket_final() {
  intersection() {
    u_bracket_fillet_minkowski();
    main_bar();
  }
}

// Final Output
u_bracket_final();