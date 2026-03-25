$fn=96;

clip_len = 60;
clip_w   = 18;
clip_t   = 2.2;

jaw_gap  = 3.2;
jaw_len  = 18;

hinge_r  = 6.5;
hinge_w  = clip_w;

spring_wire_r = 0.9;
spring_coil_r = 4.2;
spring_turns  = 2.25;

handle_len = 28;
handle_w   = 14;
handle_t   = 2.0;

module rounded_bar(len, w, t, r){
    hull(){
        translate([-(len/2 - r), 0, 0]) cylinder(h=t, r=r, center=true);
        translate([ (len/2 - r), 0, 0]) cylinder(h=t, r=r, center=true);
    }
}

module jaw_teeth(len, w, t, tooth_pitch=2.2, tooth_h=0.8){
    n = floor(len/tooth_pitch);
    for(i=[0:n-1]){
        x = -len/2 + (i+0.5)*tooth_pitch;
        translate([x, 0, -t/2 + tooth_h/2])
            cube([tooth_pitch*0.75, w*0.85, tooth_h], center=true);
    }
}

module half_clip(sign=1){
    yoff = sign*(jaw_gap/2 + clip_t/2);

    difference(){
        union(){
            // main arm
            translate([0, yoff, 0])
                rounded_bar(clip_len, clip_w, clip_t, r=clip_w/2);

            // jaw extension (slightly narrower)
            translate([clip_len/2 - jaw_len/2, yoff, 0])
                rounded_bar(jaw_len, clip_w*0.92, clip_t, r=(clip_w*0.92)/2);

            // hinge pad
            translate([-clip_len/2 + hinge_r*0.9, yoff, 0])
                cylinder(h=clip_t, r=hinge_r, center=true);

            // handle tab
            translate([-clip_len/2 + hinge_r*0.9 - handle_len/2, yoff, 0])
                rounded_bar(handle_len, handle_w, handle_t, r=handle_w/2);
        }

        // inner jaw relief to create gap
        translate([clip_len/2 - jaw_len/2, sign*(jaw_gap/2), 0])
            cube([jaw_len+2, clip_w*1.2, clip_t+1], center=true);

        // teeth on inner jaw face
        translate([clip_len/2 - jaw_len/2, yoff - sign*(clip_t/2 - 0.01), 0])
            rotate([sign>0 ? 0 : 180, 0, 0])
                jaw_teeth(jaw_len*0.9, clip_w*0.9, clip_t, tooth_pitch=2.2, tooth_h=0.8);

        // hinge hole
        translate([-clip_len/2 + hinge_r*0.9, yoff, 0])
            cylinder(h=clip_t+2, r=2.2, center=true);
    }
}

module spring(){
    // simple helical coil around X axis, centered at hinge
    steps = 220;
    pitch = 2.2;
    total_ang = 360*spring_turns;
    for(i=[0:steps-1]){
        a1 = total_ang*(i/steps);
        a2 = total_ang*((i+1)/steps);
        x1 = (a1/360)*pitch - (spring_turns*pitch)/2;
        x2 = (a2/360)*pitch - (spring_turns*pitch)/2;

        p1 = [x1, spring_coil_r*cos(a1), spring_coil_r*sin(a1)];
        p2 = [x2, spring_coil_r*cos(a2), spring_coil_r*sin(a2)];

        hull(){
            translate(p1) sphere(r=spring_wire_r);
            translate(p2) sphere(r=spring_wire_r);
        }
    }

    // legs
    leg_len = 16;
    translate([ (spring_turns*pitch)/2, 0, 0])
        rotate([0,90,0])
            cylinder(h=leg_len, r=spring_wire_r, center=false);

    translate([-(spring_turns*pitch)/2 - leg_len, 0, 0])
        rotate([0,90,0])
            cylinder(h=leg_len, r=spring_wire_r, center=false);
}

module swiss_clip(){
    union(){
        // two halves
        half_clip(1);
        half_clip(-1);

        // hinge pin
        translate([-clip_len/2 + hinge_r*0.9, 0, 0])
            cylinder(h=hinge_w + jaw_gap + 2, r=2.0, center=true);

        // spring at hinge
        translate([-clip_len/2 + hinge_r*0.9, 0, 0])
            rotate([0,90,0])
                spring();
    }
}

swiss_clip();