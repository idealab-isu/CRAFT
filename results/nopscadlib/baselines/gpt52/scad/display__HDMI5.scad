$fn=64;

module rounded_rect_2d(size=[10,10], r=1){
    w=size[0]; h=size[1];
    r2 = min(r, min(w,h)/2);
    offset(r=r2) offset(delta=-r2) square([w,h], center=true);
}

module rounded_box(size=[10,10,2], r=1){
    w=size[0]; h=size[1]; t=size[2];
    r2 = min(r, min(w,h)/2);
    linear_extrude(height=t, center=true)
        rounded_rect_2d([w,h], r2);
}

module rect_prism_xy(p1=[-5,-5], p2=[5,5], z=1, center_z=true){
    x1=min(p1[0],p2[0]); x2=max(p1[0],p2[0]);
    y1=min(p1[1],p2[1]); y2=max(p1[1],p2[1]);
    w=x2-x1; h=y2-y1;
    cx=(x1+x2)/2; cy=(y1+y2)/2;
    translate([cx,cy,0])
        cube([w,h,z], center=center_z);
}

module display_hdmi_5in(
    pcb_size=[121,76,2.85],
    pcb_offset=[0,0,1.9],
    aperture=[[-54,-30.225],[54,34.575,0.5]],
    touch=[[-58.7,-34],[58.7,36.25,1]],
    thread_len=2,
    ribbon_clear=[[-2.5,-39],[10.5,-33]],
    pcb_corner_r=2.0
){
    union(){
        translate(pcb_offset)
            color([0,0.5,0])
                rounded_box(pcb_size, pcb_corner_r);

        color([0.05,0.05,0.05,0.35])
            translate([0,0, (touch[1][2])/2])
                rect_prism_xy(touch[0], [touch[1][0], touch[1][1]], touch[1][2], center_z=true);

        difference(){
            translate([0,0, (aperture[1][2])/2])
                rect_prism_xy(aperture[0], [aperture[1][0], aperture[1][1]], aperture[1][2], center_z=true);

            translate([0,0, (aperture[1][2])/2])
                rect_prism_xy(ribbon_clear[0], ribbon_clear[1], aperture[1][2]+0.2, center_z=true);
        }

        for(x=[-1,1], y=[-1,1]){
            translate([x*(pcb_size[0]/2-4), y*(pcb_size[1]/2-4), pcb_offset[2] + pcb_size[2]/2 + thread_len/2])
                cylinder(d=2.4, h=thread_len, center=true);
        }
    }
}

display_hdmi_5in();