$fn=96;

// Pillow block bearing (UCP-style) for 10mm shaft
// Base: 67 x 53 mm
// Includes: base with 2 mounting holes, housing, bearing seat, shaft bore, top split line, and two set-screw holes.

base_L = 67.0;
base_W = 53.0;
base_T = 10.0;

mount_hole_d = 9.0;          // clearance for M8
mount_hole_x = 50.0;         // center-to-center along length
mount_hole_y = 0.0;          // centered across width

housing_L = 52.0;
housing_W = 40.0;
housing_H = 28.0;

seat_d = 30.0;               // bearing OD seat (approx for 10mm insert)
seat_len = 26.0;

shaft_d = 10.0;              // shaft bore
shaft_clear = 0.2;           // small clearance
shaft_bore_d = shaft_d + shaft_clear;

split_gap = 0.8;             // visual split line
split_z = base_T + housing_H*0.62;

setscrew_d = 4.2;            // clearance for M4
setscrew_len = 18.0;
setscrew_z = base_T + housing_H*0.72;
setscrew_y_off = housing_W*0.22;

fillet_r = 3.0;

module rounded_box(size=[10,10,10], r=2){
    // Minkowski rounded box (kept modest for renderability)
    sx = max(size[0]-2*r, 0.01);
    sy = max(size[1]-2*r, 0.01);
    sz = max(size[2]-2*r, 0.01);
    minkowski(){
        cube([sx,sy,sz], center=true);
        sphere(r=r);
    }
}

module base(){
    difference(){
        translate([0,0,base_T/2])
            rounded_box([base_L, base_W, base_T], r=fillet_r);

        // mounting holes
        for (x = [-mount_hole_x/2, mount_hole_x/2]){
            translate([x, mount_hole_y, -1])
                cylinder(d=mount_hole_d, h=base_T+2);
        }

        // slight underside relief (optional)
        translate([0,0,1.2])
            cube([base_L-10, base_W-10, 2.4], center=true);
    }
}

module housing(){
    // Main housing block with rounded edges
    translate([0,0,base_T + housing_H/2])
        rounded_box([housing_L, housing_W, housing_H], r=3.0);
}

module model(){
    difference(){
        union(){
            base();
            housing();

            // side ribs (stylized)
            for (sx = [-1,1]){
                translate([sx*(housing_L/2-6), 0, base_T + 10])
                    rotate([0,0,0])
                        rounded_box([10, housing_W-8, 18], r=2.0);
            }
        }

        // Bearing seat (cylindrical pocket through housing)
        translate([0,0,base_T + housing_H*0.55])
            rotate([0,90,0])
                cylinder(d=seat_d, h=seat_len, center=true);

        // Shaft bore through seat
        translate([0,0,base_T + housing_H*0.55])
            rotate([0,90,0])
                cylinder(d=shaft_bore_d, h=seat_len+10, center=true);

        // Top split line (thin cut)
        translate([0,0,split_z])
            cube([housing_L+2, housing_W+2, split_gap], center=true);

        // Set-screw holes (two, from top/front-ish into bore)
        for (yy = [-setscrew_y_off, setscrew_y_off]){
            translate([0, yy, setscrew_z])
                rotate([0,90,0])
                    cylinder(d=setscrew_d, h=setscrew_len, center=true);
        }

        // Slight chamfer on base top around housing footprint
        translate([0,0,base_T+0.01])
            linear_extrude(height=2.0, scale=1.06)
                square([housing_L-6, housing_W-6], center=true);
    }
}

model();