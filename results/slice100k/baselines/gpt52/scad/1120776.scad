$fn=96;

th = 2.5;

bbox_x = 18.3;
bbox_y = 21.6;

lobe_r = 5.0;
lobe_offset_x = 4.15;
lobe_y = 6.0;

tip_y = bbox_y/2;

big_hole_d = 6.2;
small_hole_d = 3.0;

small_hole_y = 0.0;
small_hole_x = 3.6;

module plate_outline_2d() {
    hull() {
        translate([-lobe_offset_x, -bbox_y/2 + lobe_y]) circle(r=lobe_r);
        translate([ lobe_offset_x, -bbox_y/2 + lobe_y]) circle(r=lobe_r);
        translate([0, tip_y]) circle(r=1.2);
    }
}

module holes_2d() {
    translate([-lobe_offset_x, -bbox_y/2 + lobe_y]) circle(d=big_hole_d);
    translate([ lobe_offset_x, -bbox_y/2 + lobe_y]) circle(d=big_hole_d);

    translate([-small_hole_x, small_hole_y]) circle(d=small_hole_d);
    translate([ small_hole_x, small_hole_y]) circle(d=small_hole_d);
}

difference() {
    linear_extrude(height=th, center=true)
        plate_outline_2d();

    translate([0,0,0])
        linear_extrude(height=th+0.6, center=true)
            holes_2d();
}