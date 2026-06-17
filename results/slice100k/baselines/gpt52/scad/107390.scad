$fn=64;

bbox_x = 3.0;
bbox_y = 1.2;
bbox_z = 9.0;

arc_angle = 220;          // degrees, C-shaped opening
r_mid = 3.2;              // mid radius to fit within 9mm length
radial_thk = 1.2;         // ring radial thickness
height_y = bbox_y;        // thickness in Y
inner_r = r_mid - radial_thk/2;
outer_r = r_mid + radial_thk/2;

tab_len = 0.9;            // along tangent direction
tab_radial_extra = 0.25;  // thickened ends
tab_y_extra = 0.15;

facet_n = 10;             // faceted outer surface
facet_depth = 0.18;

module ring_sector(r1, r2, ang, h){
    linear_extrude(height=h, center=true, convexity=10)
        difference(){
            circle(r=r2, $fn=128);
            circle(r=r1, $fn=128);
            rotate(ang/2) translate([0,0]) square([2*r2+2, 2*r2+2], center=true);
            rotate(-ang/2) translate([0,0]) square([2*r2+2, 2*r2+2], center=true);
        }
}

module end_tab(sign=1){
    a = sign*arc_angle/2;
    r_tab = outer_r + tab_radial_extra/2;
    translate([0,0,0])
    rotate([0,0,a])
    translate([r_mid,0,0])
    rotate([0,0,90])
    cube([tab_len, radial_thk + tab_radial_extra, height_y + tab_y_extra], center=true);
}

module faceted_outer(){
    for(i=[0:facet_n-1]){
        ang = -arc_angle/2 + (i+0.5)*arc_angle/facet_n;
        rotate([0,0,ang])
            translate([outer_r - facet_depth/2,0,0])
                cube([facet_depth, 2*(outer_r+2), height_y+2], center=true);
    }
}

module clamp_segment(){
    difference(){
        union(){
            ring_sector(inner_r, outer_r, arc_angle, height_y);
            end_tab(1);
            end_tab(-1);
        }
        // concave inner channel (slightly deeper than inner radius)
        ring_sector(0, inner_r + 0.05, arc_angle+2, height_y+0.4);
        // facet the outer surface
        faceted_outer();
        // trim to bounding box
        cube([bbox_x, bbox_y, bbox_z], center=true);
    }
}

rotate([90,0,0])  // make elongated along Z
clamp_segment();