$fn=96;

// Pillow block bearing for 8.0mm shaft, 55.0mm x 42.0mm base
// Parametric, printable approximation (not a vendor-exact model)

shaft_d = 8.0;

base_x = 55.0;
base_y = 42.0;
base_z = 8.0;

pedestal_z = 18.0;          // height above base to housing centerline
housing_len = 38.0;         // along X
housing_od = 28.0;          // outer diameter of housing body
cap_flat_z = 6.0;           // top flatten amount (creates a "cap" look)

bore_clear = 0.25;          // clearance for shaft
bore_d = shaft_d + 2*bore_clear;

insert_od = 16.0;           // visual "bearing insert" OD
insert_len = housing_len - 6.0;

mount_hole_d = 6.5;         // for M6 clearance
mount_hole_x_off = 20.0;    // from center along X
mount_hole_y_off = 14.0;    // from center along Y
mount_csk_d = 12.0;         // counterbore diameter
mount_csk_depth = 3.0;

fillet_r = 3.0;             // base corner radius

module rounded_rect_prism(x,y,z,r){
    linear_extrude(height=z)
        offset(r=r)
            square([x-2*r, y-2*r], center=true);
}

module pillow_block(){
    difference(){
        union(){
            // Base
            rounded_rect_prism(base_x, base_y, base_z, fillet_r);

            // Pedestal (supports housing)
            translate([0,0,base_z])
                hull(){
                    // bottom footprint
                    translate([0,0,0])
                        rounded_rect_prism(34, 28, 1.0, 2.5);
                    // top footprint near housing
                    translate([0,0,pedestal_z-2.0])
                        rounded_rect_prism(26, 22, 1.0, 2.0);
                }

            // Housing body (cylinder along X) with slight top flatten
            translate([0,0,base_z + pedestal_z])
                intersection(){
                    rotate([0,90,0])
                        cylinder(d=housing_od, h=housing_len, center=true);
                    // flatten top a bit
                    translate([0,0,-housing_od/2])
                        cube([housing_len+2, housing_od+2, housing_od - cap_flat_z], center=true);
                }

            // Small side ribs blending pedestal to housing
            translate([0,0,base_z])
                for (s=[-1,1]){
                    hull(){
                        translate([s*12, 0, 2])
                            rounded_rect_prism(10, 18, 2, 2);
                        translate([s*10, 0, pedestal_z+6])
                            rounded_rect_prism(8, 14, 2, 2);
                    }
                }
        }

        // Shaft bore through housing (along X)
        translate([0,0,base_z + pedestal_z])
            rotate([0,90,0])
                cylinder(d=bore_d, h=housing_len+4, center=true);

        // Visual insert relief (slightly larger pocket)
        translate([0,0,base_z + pedestal_z])
            rotate([0,90,0])
                cylinder(d=insert_od, h=insert_len, center=true);

        // Mounting holes (4) through base with counterbore from top
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*mount_hole_x_off, sy*mount_hole_y_off, -0.1])
                cylinder(d=mount_hole_d, h=base_z+0.2);

            translate([sx*mount_hole_x_off, sy*mount_hole_y_off, base_z-mount_csk_depth])
                cylinder(d=mount_csk_d, h=mount_csk_depth+0.2);
        }

        // Slight underside relief (optional) to reduce elephant foot
        translate([0,0,-0.01])
            linear_extrude(height=0.8)
                offset(r=1.0)
                    square([base_x-6, base_y-6], center=true);
    }
}

pillow_block();