$fn=128;

// Flexible shaft coupling: 6mm to 8mm bore, 19mm OD, 25mm long
// Typical helical beam coupling style with clamp slits and set-screw holes.

od = 19.0;
len = 25.0;

bore1_d = 6.0;   // one end
bore2_d = 8.0;   // other end

center_split = len/2;

hub_wall_min = 2.0;          // ensure enough wall around bores
beam_slot_width = 1.2;
beam_slot_depth = od*0.42;   // radial depth into body
beam_slot_pitch = 4.0;       // axial pitch of helix
beam_slot_turns = 3.0;       // number of turns
beam_slot_count = 2;         // two opposing helical slots

clamp_slit_width = 1.2;
clamp_slit_depth = od*0.48;
clamp_slit_len = 7.0;        // length from each end inward

setscrew_d = 3.0;            // M3 clearance-ish
setscrew_head_d = 6.0;       // counterbore for socket head
setscrew_head_depth = 2.5;
setscrew_z_offset = 5.0;     // from each end

// Derived checks (soft)
min_wall1 = (od - bore1_d)/2;
min_wall2 = (od - bore2_d)/2;
assert(min_wall1 >= hub_wall_min && min_wall2 >= hub_wall_min, "OD too small for requested bores and minimum wall.");

module coupling_body() {
    difference() {
        // Outer cylinder
        cylinder(d=od, h=len);

        // Stepped bores
        translate([0,0,0])
            cylinder(d=bore1_d, h=center_split + 0.2);
        translate([0,0,center_split-0.1])
            cylinder(d=bore2_d, h=len - center_split + 0.2);

        // Center relief (optional small chamfer/relief at step)
        translate([0,0,center_split-0.25])
            cylinder(d=max(bore1_d,bore2_d)+0.8, h=0.5);

        // Helical beam slots (two opposing)
        for (i=[0:beam_slot_count-1]) {
            rotate([0,0,i*180])
                helical_slot();
        }

        // Clamp slits at each end (two opposing per end)
        for (end=[0,1]) {
            z0 = (end==0) ? 0 : (len - clamp_slit_len);
            translate([0,0,z0])
                clamp_slits();
        }

        // Set-screw holes (one per end, perpendicular to axis)
        // Place at 90 degrees to avoid aligning with clamp slit
        for (end=[0,1]) {
            zc = (end==0) ? setscrew_z_offset : (len - setscrew_z_offset);
            rotate([0,0,90])
                translate([0,0,zc])
                    setscrew_hole();
        }
    }
}

module helical_slot() {
    // Create a helical cut by twisting a rectangular prism around Z
    // Positioned near the outer radius, cutting inward.
    slot_len = beam_slot_turns * beam_slot_pitch;
    z_start = (len - slot_len)/2;

    translate([0,0,z_start])
        linear_extrude(height=slot_len, twist=beam_slot_turns*360, slices=slot_len*6, convexity=10)
            translate([od/2 - beam_slot_depth, -beam_slot_width/2, 0])
                square([beam_slot_depth, beam_slot_width], center=false);
}

module clamp_slits() {
    // Two opposing axial slits from end inward
    for (a=[0,180]) {
        rotate([0,0,a])
            translate([od/2 - clamp_slit_depth, -clamp_slit_width/2, 0])
                cube([clamp_slit_depth, clamp_slit_width, clamp_slit_len], center=false);
    }
}

module setscrew_hole() {
    // Through-hole across diameter with a shallow counterbore on one side
    // Drill direction: X axis
    // Through hole
    translate([0,0,0])
        rotate([0,90,0])
            cylinder(d=setscrew_d, h=od+2, center=true);

    // Counterbore on +X side
    translate([od/2 - setscrew_head_depth/2, 0, 0])
        rotate([0,90,0])
            cylinder(d=setscrew_head_d, h=setscrew_head_depth+0.2, center=true);
}

coupling_body();