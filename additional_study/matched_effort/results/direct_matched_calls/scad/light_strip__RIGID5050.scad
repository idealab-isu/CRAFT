$fn=96;

// Rigid light strip (diffuser + rigid base + end caps + mounting holes)
strip_len = 300;
strip_w   = 18;
strip_h   = 8;

base_h    = 4.5;
diff_h    = strip_h - base_h;

wall      = 1.6;     // base wall thickness
cap_len   = 6;

hole_d    = 3.2;
hole_head_d = 6.2;
hole_head_h = 1.6;
hole_offset = 18;

module rounded_box(l,w,h,r){
    r2 = min(r, min(l,w)/2);
    linear_extrude(height=h)
        offset(r=r2)
            square([l-2*r2, w-2*r2], center=true);
}

module base_shell(){
    // Outer base
    difference(){
        translate([0,0,base_h/2])
            rounded_box(strip_len, strip_w, base_h, 2.2);

        // Inner cavity (open top)
        translate([0,0,wall + (base_h-wall)/2])
            rounded_box(strip_len-2*wall, strip_w-2*wall, base_h-wall, 1.6);

        // Cable notch on underside near one end
        translate([-(strip_len/2 - 18), 0, 0])
            rotate([90,0,0])
                cylinder(d=6, h=strip_w+2, center=true);

        // Mounting holes (2x)
        for(x=[-strip_len/2 + hole_offset, strip_len/2 - hole_offset]){
            // Through hole
            translate([x,0,0])
                cylinder(d=hole_d, h=base_h+0.5, center=false);

            // Counterbore from underside
            translate([x,0,0])
                cylinder(d=hole_head_d, h=hole_head_h, center=false);
        }
    }
}

module diffuser(){
    // Slightly domed diffuser sitting on top of base
    diff_len = strip_len - 2*cap_len;
    diff_w   = strip_w - 1.2;
    r = diff_w/2;

    translate([0,0,base_h])
    intersection(){
        // Bounding box for length
        translate([0,0,diff_h/2])
            rounded_box(diff_len, diff_w, diff_h, 2.0);

        // Dome profile via cylinder intersection
        translate([0,0,0])
            rotate([0,90,0])
                cylinder(r=r, h=diff_len, center=true);
    }
}

module end_cap(side=1){
    // side: -1 left, +1 right
    x0 = side*(strip_len/2 - cap_len/2);
    translate([x0,0,strip_h/2])
    difference(){
        rounded_box(cap_len, strip_w, strip_h, 2.2);

        // Small recess to suggest diffuser interface
        translate([0,0,base_h + diff_h/2])
            rounded_box(cap_len+0.2, strip_w-2.0, diff_h+0.2, 1.6);

        // Wire exit on one cap
        if(side < 0){
            translate([-cap_len/2+1.2,0,base_h/2])
                rotate([0,90,0])
                    cylinder(d=6, h=cap_len+2, center=false);
        }
    }
}

module light_strip(){
    union(){
        base_shell();
        diffuser();
        end_cap(-1);
        end_cap(1);
    }
}

light_strip();