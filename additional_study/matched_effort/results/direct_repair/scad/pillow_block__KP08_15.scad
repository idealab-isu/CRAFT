$fn = 96;

// Pillow block bearing for 8.0mm shaft, 55.0mm x 42.0mm base
// Parametric, printable housing with through-bore and two mounting holes.

shaft_d = 8.0;

base_L = 55.0;
base_W = 42.0;
base_T = 8.0;

mount_hole_d = 6.5;          // clearance for M6
mount_hole_spacing = 40.0;   // center-to-center along length
mount_hole_edge_margin = (base_L - mount_hole_spacing)/2;

housing_outer_d = 28.0;      // outer diameter of bearing boss
housing_len = 26.0;          // length of boss along X
housing_center_z = base_T + housing_outer_d/2 - 2.0; // slightly sunk into base

cap_thickness = 6.0;         // top cap thickness
cap_width = 34.0;            // cap width along Y
cap_len = 30.0;              // cap length along X

set_screw_d = 3.3;           // clearance for M3
set_screw_z = housing_center_z + housing_outer_d*0.15;

fillet_r = 3.0;

module rounded_rect_prism(l, w, h, r){
    r2 = min(r, min(l,w)/2);
    linear_extrude(height=h)
        offset(r=r2)
            square([l-2*r2, w-2*r2], center=true);
}

module pillow_block(){
    difference(){
        union(){
            // Base with rounded corners
            translate([0,0,base_T/2])
                rounded_rect_prism(base_L, base_W, base_T, fillet_r);

            // Main cylindrical boss (bearing housing)
            translate([0,0,housing_center_z])
                rotate([0,90,0])
                    cylinder(d=housing_outer_d, h=housing_len, center=true);

            // Side ribs to base
            rib_h = housing_center_z - base_T;
            rib_t = 6.0;
            rib_len = housing_len;
            for (sy = [-1,1]){
                translate([0, sy*(base_W/2 - rib_t/2 - 2.0), base_T + rib_h/2])
                    cube([rib_len, rib_t, rib_h], center=true);
            }

            // Top cap block
            translate([0,0,housing_center_z + housing_outer_d/2 + cap_thickness/2 - 1.0])
                rounded_rect_prism(cap_len, cap_width, cap_thickness, 2.0);
        }

        // Shaft bore through boss (and cap)
        translate([0,0,housing_center_z])
            rotate([0,90,0])
                cylinder(d=shaft_d + 0.4, h=base_L + 20, center=true);

        // Relief pocket inside boss to reduce material (optional)
        translate([0,0,housing_center_z])
            rotate([0,90,0])
                cylinder(d=max(shaft_d+6.0, 14.0), h=housing_len-6.0, center=true);

        // Mounting holes (2x) through base
        for (sx = [-1,1]){
            translate([sx*mount_hole_spacing/2, 0, 0])
                cylinder(d=mount_hole_d, h=base_T + 2, center=false);
            // counterbore (top) for socket head
            translate([sx*mount_hole_spacing/2, 0, base_T-3.0])
                cylinder(d=11.5, h=3.2, center=false);
        }

        // Set screw hole (radial into bore) from +Y side
        translate([0, base_W/2 + 1, set_screw_z])
            rotate([90,0,0])
                cylinder(d=set_screw_d, h=base_W + 10, center=true);

        // Split line slot (cap separation hint) - shallow groove
        translate([0,0,housing_center_z + housing_outer_d/2 - 1.0])
            cube([cap_len+2, cap_width+2, 1.2], center=true);
    }
}

pillow_block();