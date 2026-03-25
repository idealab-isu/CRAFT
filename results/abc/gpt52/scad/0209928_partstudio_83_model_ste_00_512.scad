$fn=96;

outer_d = 34;
h = 6.0;

chamfer = 0.6;

groove_from_top = 1.2;
groove_w = 1.6;
groove_depth = 1.0;

lug_len = 10.0;
lug_w = 12.0;
lug_h = h;

notch_w = 4.0;
notch_len = 3.0;
notch_h = 2.2;

module chamfered_cylinder(d=34, h=6, c=0.6) {
    union() {
        translate([0,0,c]) cylinder(d=d, h=h-2*c);
        cylinder(d1=d-2*c, d2=d, h=c);
        translate([0,0,h-c]) cylinder(d1=d, d2=d-2*c, h=c);
    }
}

module sleeve_body() {
    chamfered_cylinder(d=outer_d, h=h, c=chamfer);
}

module circumferential_groove() {
    translate([0,0,h-groove_from_top-groove_w])
        difference() {
            cylinder(d=outer_d+0.2, h=groove_w);
            cylinder(d=outer_d-2*groove_depth, h=groove_w+0.2);
        }
}

module lug_with_notch() {
    difference() {
        translate([outer_d/2, -lug_w/2, 0])
            cube([lug_len, lug_w, lug_h], center=false);

        translate([outer_d/2 + lug_len - notch_len, -notch_w/2, h - notch_h])
            cube([notch_len+0.2, notch_w, notch_h+0.2], center=false);
    }
}

difference() {
    union() {
        sleeve_body();
        lug_with_notch();
    }
    circumferential_groove();
}