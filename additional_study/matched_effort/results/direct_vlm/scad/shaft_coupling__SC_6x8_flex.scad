$fn = 128;

// Flexible shaft coupling: 6mm to 8mm bore, 19mm OD, 25mm long
// Typical helical-beam style with clamp slits and set-screw holes.

od = 19.0;
len = 25.0;

bore1_d = 6.0;   // one end
bore2_d = 8.0;   // other end

// Design details (reasonable defaults)
center_split = len/2;
bore_depth_each = len/2;     // each bore goes to the middle
center_web = 1.2;            // small web between bores (kept by not overdrilling)

clamp_slit_w = 1.2;
clamp_slit_depth = od*0.65;  // radial depth of slit cut
clamp_slit_len = 7.0;        // axial length of each clamp slit region
clamp_slit_offset = 2.0;     // distance from end to start of slit region

setscrew_d = 3.0;            // M3 clearance-ish
setscrew_head_d = 5.8;       // counterbore for socket head / grub access
setscrew_head_depth = 2.5;
setscrew_z_from_end = 6.0;   // axial position from each end

// Helical beam slots
slot_w = 1.6;
slot_depth = 2.6;            // radial depth into OD
slot_pitch = 4.2;            // axial spacing between turns
slot_turns = 5;              // number of helical cuts
slot_start_z = 3.0;
slot_end_z = len - 3.0;
slot_twist_deg = 540;        // total twist across length (approx)
slot_count = 3;              // number of interleaved helices

module coupling_body() {
    cylinder(d=od, h=len);
}

module stepped_bore() {
    // Bore from end 1 (z=0) to near center
    translate([0,0,-0.1])
        cylinder(d=bore1_d, h=bore_depth_each + 0.1);

    // Bore from end 2 (z=len) to near center
    translate([0,0,center_split + center_web])
        cylinder(d=bore2_d, h=(len - (center_split + center_web)) + 0.2);
}

module clamp_slits() {
    // Two slits per end, 90 degrees apart
    for (end = [0,1]) {
        z0 = end==0 ? clamp_slit_offset : (len - clamp_slit_offset - clamp_slit_len);
        for (a = [0,90]) {
            rotate([0,0,a])
                translate([od/2 - clamp_slit_depth, -clamp_slit_w/2, z0])
                    cube([clamp_slit_depth + 0.5, clamp_slit_w, clamp_slit_len], center=false);
        }
    }
}

module setscrew_holes() {
    // Radial set-screw holes, one per end, rotated 45 degrees relative to clamp slits
    for (end = [0,1]) {
        zc = end==0 ? setscrew_z_from_end : (len - setscrew_z_from_end);
        rotate([0,0,45 + end*90])
            translate([0,0,zc])
                rotate([0,90,0]) {
                    // through hole
                    translate([0,0,-od])
                        cylinder(d=setscrew_d, h=od*2);
                    // counterbore from outside
                    translate([0,0,od/2 - setscrew_head_depth])
                        cylinder(d=setscrew_head_d, h=setscrew_head_depth + 0.2);
                }
    }
}

module helical_slot(length, twist_deg, z0) {
    // Create a twisted rectangular cutter that removes a helical groove
    // Cutter is positioned near OD and twisted along Z.
    translate([0,0,z0])
        linear_extrude(height=length, twist=twist_deg, slices=ceil(length*6), convexity=10)
            translate([od/2 - slot_depth, -slot_w/2])
                square([slot_depth + 0.6, slot_w], center=false);
}

module helical_beam_cuts() {
    usable_len = slot_end_z - slot_start_z;
    // Interleaved helices around the circumference
    for (i = [0:slot_count-1]) {
        rotate([0,0, i*(360/slot_count)])
            helical_slot(usable_len, slot_twist_deg, slot_start_z);
    }

    // Add a few straight relief cuts near the center to increase flexibility
    for (a = [0,60,120]) {
        rotate([0,0,a])
            translate([od/2 - (slot_depth+0.2), -slot_w/2, center_split - 2.0])
                cube([slot_depth + 1.0, slot_w, 4.0], center=false);
    }
}

difference() {
    coupling_body();
    stepped_bore();
    clamp_slits();
    setscrew_holes();
    helical_beam_cuts();
}