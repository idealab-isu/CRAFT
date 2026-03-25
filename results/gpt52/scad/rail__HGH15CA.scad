$fn=64;

rail_w = 15.0;
rail_h = 15.0;
rail_l = 100.0;

module countersunk_hole(thru_d=3.4, head_d=6.5, head_h=2.2, depth=20) {
    union() {
        cylinder(d=thru_d, h=depth, center=true);
        translate([0,0,depth/2 - head_h/2])
            cylinder(d1=head_d, d2=thru_d, h=head_h, center=true);
    }
}

module rail_body(w=15, h=15, l=100) {
    difference() {
        union() {
            translate([0,0,0]) cube([l,w,h], center=true);

            // Side chamfers (approximate)
            translate([0,  w/2,  h/2]) rotate([0,90,0]) linear_extrude(height=l, center=true)
                polygon(points=[[0,0],[0,1.2],[1.2,0]]);
            translate([0, -w/2,  h/2]) rotate([0,90,0]) linear_extrude(height=l, center=true)
                polygon(points=[[0,0],[0,1.2],[1.2,0]]);
            translate([0,  w/2, -h/2]) rotate([0,90,0]) linear_extrude(height=l, center=true)
                polygon(points=[[0,0],[0,1.2],[1.2,0]]);
            translate([0, -w/2, -h/2]) rotate([0,90,0]) linear_extrude(height=l, center=true)
                polygon(points=[[0,0],[0,1.2],[1.2,0]]);
        }

        // Top raceway grooves (two)
        groove_r = 2.2;
        groove_y = 4.2;
        translate([0,  groove_y,  h/2 - 1.6]) rotate([0,90,0])
            cylinder(r=groove_r, h=l+2, center=true);
        translate([0, -groove_y,  h/2 - 1.6]) rotate([0,90,0])
            cylinder(r=groove_r, h=l+2, center=true);

        // Side relief grooves (four)
        side_r = 1.6;
        side_z = 2.0;
        translate([0,  w/2 - 1.2,  side_z]) rotate([0,90,0])
            cylinder(r=side_r, h=l+2, center=true);
        translate([0,  w/2 - 1.2, -side_z]) rotate([0,90,0])
            cylinder(r=side_r, h=l+2, center=true);
        translate([0, -w/2 + 1.2,  side_z]) rotate([0,90,0])
            cylinder(r=side_r, h=l+2, center=true);
        translate([0, -w/2 + 1.2, -side_z]) rotate([0,90,0])
            cylinder(r=side_r, h=l+2, center=true);

        // Mounting holes along length (countersunk from top)
        hole_count = 5;
        hole_pitch = 20;
        for (i = [0:hole_count-1]) {
            x = -((hole_count-1)*hole_pitch)/2 + i*hole_pitch;
            translate([x, 0, h/2 - 0.01])
                rotate([180,0,0])
                    countersunk_hole(thru_d=3.4, head_d=6.5, head_h=2.2, depth=h+6);
        }
    }
}

module end_cap(w=15, h=15, t=2.0) {
    difference() {
        translate([0,0,0]) cube([t,w,h], center=true);
        // small corner rounds via subtraction
        r = 1.2;
        for (sy=[-1,1], sz=[-1,1]) {
            translate([0, sy*(w/2 - r), sz*(h/2 - r)])
                rotate([0,90,0]) cylinder(r=r, h=t+1, center=true);
        }
    }
}

module linear_guide_rail(w=15, h=15, l=100) {
    union() {
        rail_body(w=w, h=h, l=l);
        translate([ l/2 - 1.0, 0, 0]) end_cap(w=w, h=h, t=2.0);
        translate([-l/2 + 1.0, 0, 0]) end_cap(w=w, h=h, t=2.0);
    }
}

linear_guide_rail(w=rail_w, h=rail_h, l=rail_l);