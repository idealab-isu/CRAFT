// Short cylinder with two opposing rectangular lugs (symmetric spool/T-bar-through-drum)
// Bounding box target: X=11.68, Y=6.6, Z=6.99 (mm)

$fn = 96;

// Parameters
bbox_X = 11.68; //[5.84:23.36:0.01]
bbox_Y = 6.6;   //[3.3:13.2:0.01]
bbox_Z = 6.99;  //[3.495:13.98:0.01]

cyl_D = 6.6;    //[3.3:13.2:0.01]
cyl_H = 6.99;   //[3.495:13.98:0.01]

lug_total_span_X = 11.68; //[5.84:23.36:0.01]
lug_thk_Y = 2.54;         //[1.27:5.08:0.01]  // lug thickness in Y
lug_H = 3.5;              //[1.75:7.0:0.01]   // lug height in Z (centered)

overlap = 0.2;            //[0.05:1.0:0.05]   // small overlap to ensure connectivity

// Derived
lug_len_each = (lug_total_span_X - cyl_D)/2;  // each lug length in X
lug_center_x = cyl_D/2 + lug_len_each/2 - overlap;

// Base shapes
module cyl_body() {
    cylinder(d=cyl_D, h=cyl_H, center=true);
}

module lug_at(sign=1) {
    translate([sign*lug_center_x, 0, 0])
        cube([lug_len_each, lug_thk_Y, lug_H], center=true);
}

// Final solid (single connected component)
union() {
    cyl_body();
    lug_at( 1);
    lug_at(-1);
}