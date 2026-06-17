$fn=96;

// Pillow block bearing (UCP-style) for 10.0mm shaft, 67x53 base
// Parametric, printable model (approximate geometry)

shaft_d = 10.0;

base_L = 67.0;
base_W = 53.0;
base_H = 12.0;

mount_hole_d = 9.0;
mount_hole_x = 50.0;   // center-to-center along length (approx)
mount_hole_y = 0.0;

pedestal_L = 52.0;
pedestal_W = 38.0;
pedestal_H = 18.0;

housing_outer_d = 40.0;
housing_len = 38.0;    // along X
housing_center_z = base_H + pedestal_H + housing_outer_d/2 - 6.0;

bore_d = shaft_d + 0.4;     // clearance
bearing_OD = 30.0;          // visual bearing seat
bearing_len = 18.0;

set_screw_d = 4.2;
set_screw_z = housing_center_z + housing_outer_d*0.18;

fillet_r = 3.0;

module rounded_box(size=[10,10,10], r=2, center=false){
    // Minkowski rounded box (kept modest for performance)
    sx=size[0]; sy=size[1]; sz=size[2];
    translate(center ? [-sx/2,-sy/2,-sz/2] : [0,0,0])
    minkowski(){
        cube([sx-2*r, sy-2*r, sz-2*r], center=false);
        sphere(r=r);
    }
}

module base(){
    difference(){
        rounded_box([base_L, base_W, base_H], r=fillet_r, center=true);

        // mounting holes
        for (sx=[-1,1]){
            translate([sx*mount_hole_x/2, mount_hole_y, 0])
                cylinder(d=mount_hole_d, h=base_H+2, center=true);
        }

        // slight underside relief (optional)
        translate([0,0,-base_H/2+1.2])
            cube([base_L-10, base_W-10, 2.4], center=true);
    }
}

module pedestal(){
    // block that supports the housing
    translate([0,0,base_H/2 + pedestal_H/2])
        rounded_box([pedestal_L, pedestal_W, pedestal_H], r=2.5, center=true);
}

module housing(){
    // main housing: capsule-like body along X with a cylindrical bore along X
    difference(){
        union(){
            // central cylinder along X
            translate([0,0,housing_center_z])
                rotate([0,90,0])
                    cylinder(d=housing_outer_d, h=housing_len, center=true);

            // end caps (slightly larger) to mimic cast shape
            for (sx=[-1,1]){
                translate([sx*(housing_len/2 - 2.0), 0, housing_center_z])
                    rotate([0,90,0])
                        cylinder(d=housing_outer_d*1.03, h=4.0, center=true);
            }

            // ribs down to pedestal
            for (sx=[-1,1]){
                translate([sx*(housing_len*0.22), 0, base_H + pedestal_H*0.55])
                    hull(){
                        translate([0,0,0])
                            cube([10, pedestal_W*0.85, 6], center=true);
                        translate([0,0,housing_center_z-(base_H + pedestal_H*0.55)])
                            rotate([0,90,0])
                                cylinder(d=housing_outer_d*0.55, h=10, center=true);
                    }
            }
        }

        // shaft bore (through along X)
        translate([0,0,housing_center_z])
            rotate([0,90,0])
                cylinder(d=bore_d, h=housing_len+6, center=true);

        // bearing seat (visual counterbore)
        translate([0,0,housing_center_z])
            rotate([0,90,0])
                cylinder(d=bearing_OD, h=bearing_len, center=true);

        // set screw holes (top, angled slightly)
        for (sx=[-1,1]){
            translate([sx*(housing_len*0.18), 0, set_screw_z])
                rotate([0, 20*sx, 90])
                    cylinder(d=set_screw_d, h=housing_outer_d+10, center=true);
        }

        // flatten bottom of housing slightly where it meets pedestal
        translate([0,0,base_H + pedestal_H - 1.0])
            cube([housing_len+10, housing_outer_d+10, 2.0], center=true);
    }
}

module pillow_block(){
    union(){
        base();
        pedestal();
        housing();
    }
}

pillow_block();