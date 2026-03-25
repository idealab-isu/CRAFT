// Threaded heat-set insert (M4), 10mm OD, 8mm long

$fn = 128;

// Parameters
screw_diameter      = 4.0;   //[2.0:8.0:0.1]   // nominal screw major diameter
thread_pitch_mm     = 0.7;   //[0.35:1.4:0.05] // M4 coarse = 0.7
outer_diameter      = 10.0;  //[5.0:20.0:0.1]
length              = 8.0;   //[4.0:16.0:0.1]
chamfer_mm          = 0.5;   //[0.2:1.5:0.05]
tolerance_mm        = 0.15;  //[0.0:0.3:0.01]  // clearance for screw/print
rib_count           = 24;    //[8:48:1]
rib_depth           = 0.6;   //[0.2:1.2:0.05]
rib_width           = 0.8;   //[0.3:2.0:0.05]
overlap_mm          = 0.8;   //[0.5:2.0:0.1]

// Internal thread approximation (helical groove) parameters
thread_depth_mm     = 0.35;  // radial depth of thread groove (visual/functional approximation)
thread_profile_w_mm = 0.55;  // width of groove profile (controls "sharpness")
thread_turns_extra  = 0.5;   // extend thread slightly beyond ends for clean cut

// Derived
outer_r = outer_diameter/2;
inner_major_d = screw_diameter + tolerance_mm;                 // through-hole major (clearance)
inner_minor_d = max(0.1, inner_major_d - 2*thread_depth_mm);   // minor diameter after groove
inner_major_r = inner_major_d/2;
inner_minor_r = inner_minor_d/2;

module chamfered_cylinder(h, r, chamfer) {
    // One connected solid: main cylinder + two chamfer frustums
    union() {
        cylinder(h=h - 2*chamfer, r=r, center=true);
        translate([0,0, (h/2 - chamfer/2)])
            cylinder(h=chamfer, r1=r, r2=max(0.01, r - chamfer), center=true);
        translate([0,0, -(h/2 - chamfer/2)])
            cylinder(h=chamfer, r1=max(0.01, r - chamfer), r2=r, center=true);
    }
}

module knurl_ribs() {
    // Ribs protrude outward and overlap into body by overlap_mm to ensure connectivity
    rib_h = length - 2*chamfer_mm; // keep ribs off chamfers
    for (i = [0:rib_count-1]) {
        rotate([0,0, i*360/rib_count])
            translate([outer_r + rib_depth/2 - overlap_mm, 0, 0])
                cube([rib_depth + 2*overlap_mm, rib_width, rib_h], center=true);
    }
}

module internal_thread_cut() {
    // Helical groove cut into the bore to make "threading" visible.
    // Implemented as a twisted linear_extrude of a small rectangle placed at the bore radius.
    turns = length/thread_pitch_mm + 2*thread_turns_extra;
    twist_deg = 360*turns;

    translate([0,0,0])
        linear_extrude(height=length + 2*overlap_mm, center=true, twist=twist_deg, slices=max(60, ceil(turns*80)))
            translate([inner_minor_r + thread_depth_mm/2, 0, 0])
                square([thread_depth_mm, thread_profile_w_mm], center=true);
}

module insert_body() {
    // Outer body with ribs, then subtract bore + thread groove
    difference() {
        union() {
            chamfered_cylinder(length, outer_r, chamfer_mm);
            knurl_ribs();
        }

        // Central through-hole (clearance for M4 screw)
        cylinder(h=length + 4*overlap_mm, r=inner_major_r, center=true);

        // Thread groove (visual/functional approximation)
        internal_thread_cut();
    }
}

module assembly() {
    color([0.85, 0.85, 0.8]) insert_body();
}

assembly();