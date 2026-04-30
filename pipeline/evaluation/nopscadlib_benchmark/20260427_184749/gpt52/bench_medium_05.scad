$fn=64;

// Arduino Nano snap-fit holder with USB cutout
// Parametric (approximate Nano dimensions; adjust if needed)

nano_len = 45.0;
nano_wid = 18.0;
nano_thk = 2.0;

usb_w = 9.0;
usb_h = 4.0;

wall = 2.0;
base_thk = 2.0;
inner_clear = 0.6;

inner_len = nano_len + 2*inner_clear;
inner_wid = nano_wid + 2*inner_clear;
inner_h   = 8.0; // cavity height above base

outer_len = inner_len + 2*wall;
outer_wid = inner_wid + 2*wall;
outer_h   = base_thk + inner_h;

lip_h = 1.2;      // snap lip height
lip_in = 0.9;     // how far lip intrudes
clip_thk = 1.6;   // thickness of clip beam
clip_len = 14.0;  // length along Y
clip_gap = 0.4;   // clearance gap to allow flex

standoff_d = 4.0;
standoff_h = 2.2;

module rounded_box(size=[10,10,10], r=2, center=true){
    // Minkowski with sphere for rounded edges
    minkowski(){
        cube([size[0]-2*r, size[1]-2*r, size[2]-2*r], center=center);
        sphere(r=r);
    }
}

module case_shell(){
    difference(){
        // Outer body
        rounded_box([outer_len, outer_wid, outer_h], r=2.0, center=true);

        // Inner cavity (open top)
        translate([0,0, base_thk/2])
            cube([inner_len, inner_wid, inner_h + 0.2], center=true);

        // Open top cut (ensure fully open)
        translate([0,0, outer_h/2])
            cube([outer_len+2, outer_wid+2, outer_h], center=true);

        // USB port cutout on one short end (X- side)
        // Cut through wall and slightly into cavity
        translate([-outer_len/2 - 0.1, 0, -outer_h/2 + base_thk + 3.0])
            rotate([0,90,0])
                cube([usb_h + 2.0, usb_w + 2.0, wall + 3.0], center=true);

        // Small relief around USB area (wider)
        translate([-outer_len/2 - 0.1, 0, -outer_h/2 + base_thk + 3.0])
            rotate([0,90,0])
                cube([usb_h + 4.0, usb_w + 6.0, wall + 1.5], center=true);
    }
}

module standoffs(){
    // Four standoffs near corners inside cavity
    x = inner_len/2 - 4.0;
    y = inner_wid/2 - 4.0;
    z0 = -outer_h/2 + base_thk;

    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*x, sy*y, z0 + standoff_h/2])
            cylinder(d=standoff_d, h=standoff_h, center=true);
    }
}

module snap_clips(){
    // Two snap clips on long sides (Y+ and Y-), flexing outward
    // Clip beams are outside the cavity wall, with a lip intruding into cavity near top.
    z_base = -outer_h/2 + base_thk;
    z_top  = -outer_h/2 + base_thk + inner_h;

    for (sy=[-1,1]){
        // Beam
        translate([0, sy*(inner_wid/2 + wall - clip_thk/2), z_base + (inner_h*0.55)])
            cube([clip_len, clip_thk, inner_h*0.9], center=true);

        // Flex gap cut to allow snap action
        difference(){
            // nothing; use subtraction in main union via negative volume below
        }

        // Lip (intrudes into cavity)
        translate([0, sy*(inner_wid/2 + wall - clip_thk/2 - lip_in/2), z_top - lip_h/2])
            cube([clip_len-2.0, clip_thk + lip_in, lip_h], center=true);
    }
}

module clip_reliefs(){
    // Cut relief slots behind clips to allow flex
    z_base = -outer_h/2 + base_thk;
    for (sy=[-1,1]){
        translate([0, sy*(inner_wid/2 + wall/2), z_base + inner_h*0.55])
            cube([clip_len+2.0, wall + clip_gap, inner_h*0.95], center=true);
    }
}

module board_entry_chamfers(){
    // Simple lead-in chamfers at top inner edges using subtractive wedges (approximated with rotated cubes)
    z_top = -outer_h/2 + base_thk + inner_h;
    for (sy=[-1,1]){
        translate([0, sy*(inner_wid/2), z_top-0.6])
            rotate([45,0,0])
                cube([inner_len+2, 1.6, 1.6], center=true);
    }
    for (sx=[-1,1]){
        translate([sx*(inner_len/2), 0, z_top-0.6])
            rotate([0,45,0])
                cube([1.6, inner_wid+2, 1.6], center=true);
    }
}

difference(){
    union(){
        case_shell();
        standoffs();
        snap_clips();
    }
    clip_reliefs();
    board_entry_chamfers();
}