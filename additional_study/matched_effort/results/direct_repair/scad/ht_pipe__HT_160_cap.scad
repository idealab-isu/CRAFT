$fn=180;

// HT 160 cap (approximation)
// Dimensions in mm
d_nominal = 160;          // nominal pipe OD
wall = 4.0;               // cap wall thickness
cap_depth = 55;           // insertion depth
top_thickness = 6.0;      // closed end thickness
lip_height = 6.0;         // small outer lip height
lip_extra = 3.0;          // lip radial extra beyond body OD
chamfer = 1.2;            // edge chamfer size

// Derived
od_body = d_nominal + 2*wall;     // outer diameter of cap body
id_body = d_nominal;              // inner diameter (fits pipe OD)
h_total = cap_depth + top_thickness + lip_height;

module chamfered_cylinder(d, h, c=1.0){
    // Simple chamfer on top and bottom edges using hull of two cylinders
    // c is chamfer size
    if (c <= 0) {
        cylinder(d=d, h=h);
    } else {
        hull() {
            translate([0,0,0]) cylinder(d=d-2*c, h=0.01);
            translate([0,0,c]) cylinder(d=d, h=h-2*c);
            translate([0,0,h-0.01]) cylinder(d=d-2*c, h=0.01);
        }
    }
}

module ht160_cap(){
    difference(){
        union(){
            // Main outer body (closed end included)
            chamfered_cylinder(d=od_body, h=cap_depth + top_thickness, c=chamfer);

            // Outer lip near opening
            translate([0,0,cap_depth + top_thickness])
                chamfered_cylinder(d=od_body + 2*lip_extra, h=lip_height, c=chamfer);
        }

        // Hollow interior (leave top_thickness at closed end)
        translate([0,0,0])
            cylinder(d=id_body, h=cap_depth);

        // Slight lead-in chamfer at opening (inside)
        translate([0,0,cap_depth-2.0])
            cylinder(d1=id_body, d2=id_body+3.0, h=2.0);

        // Small relief at very opening to avoid sharp edge
        translate([0,0,cap_depth + top_thickness + lip_height - 1.2])
            cylinder(d1=id_body+2.0, d2=id_body, h=1.2);
    }
}

ht160_cap();