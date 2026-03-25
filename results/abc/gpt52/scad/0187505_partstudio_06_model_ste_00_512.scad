$fn=64;

plate_x = 0.1;
plate_y = 0.1;
plate_t = 0.01;

corner_offset = 0.03;
diamond_hole_d = 0.012;

pent_r = 0.022;

module base_plate() {
    translate([0,0,0]) cube([plate_x, plate_y, plate_t], center=true);
}

module pentagon_cutout(h) {
    linear_extrude(height=h, center=true, convexity=10)
        polygon(points=[for(i=[0:4]) [pent_r*cos(90+i*72), pent_r*sin(90+i*72)]]);
}

module diamond_hole(h, d) {
    rotate([0,0,45]) translate([0,0,0]) cube([d,d,h], center=true);
}

module corner_holes(h) {
    for (sx=[-1,1], sy=[-1,1])
        translate([sx*(plate_x/2 - corner_offset), sy*(plate_y/2 - corner_offset), 0])
            diamond_hole(h, diamond_hole_d);
}

difference() {
    base_plate();
    pentagon_cutout(plate_t + 0.2);
    corner_holes(plate_t + 0.2);
}