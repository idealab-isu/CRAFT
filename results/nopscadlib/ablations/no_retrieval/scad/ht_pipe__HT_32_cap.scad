$fn = 128;

// Parameters (approx. HT 32 cap proportions)
cap_OD       = 40;   //[20:80:0.5]
cap_length   = 35;   //[18:70:0.5]
wall_thk     = 2.5;  //[1.2:5:0.1]
end_thk      = 3;    //[1.5:6:0.1]
socket_ID    = 35;   //[28:45:0.5]
socket_depth = 25;   //[12:50:0.5]
stop_thk     = 2;    //[1:5:0.1]
chamfer      = 1;    //[0.5:3:0.1]
overlap      = 0.6;  //[0.2:2:0.1]
rib_count    = 16;   //[8:32:1]
rib_radial   = 1.2;  //[0.6:2.5:0.1]
rib_width    = 3;    //[1.5:6:0.1]
rib_length   = 22;   //[10:40:0.5]
fillet_r     = 0.8;  //[0.3:2:0.1]

// Derived / safety
cap_R   = cap_OD/2;
sock_R  = socket_ID/2;

// Place socket opening at the "bottom" (negative Z), closed end at +Z
z_bottom = -cap_length/2;
z_top    =  cap_length/2;

// Ensure valid geometry
socket_depth_eff = min(socket_depth, cap_length - end_thk - 0.01);
socket_depth_eff = max(0.01, socket_depth_eff);
chamfer_eff      = min(chamfer, socket_depth_eff);
chamfer_eff      = max(0.01, chamfer_eff);

// Ribs sit on the outside surface and overlap slightly into the body
rib_center_r = cap_R + rib_radial/2 - overlap;

// --- Base solids ---
module outer_body() {
    cylinder(h=cap_length, r=cap_R, center=true);
}

// Inner cavity: straight bore + lead-in chamfer at opening
module inner_cavity() {
    union() {
        // Main bore (from opening upward)
        translate([0,0, z_bottom + socket_depth_eff/2])
            cylinder(h=socket_depth_eff + overlap, r=sock_R, center=true);

        // Lead-in chamfer at opening
        translate([0,0, z_bottom + chamfer_eff/2])
            cylinder(h=chamfer_eff + overlap, r1=sock_R + chamfer_eff, r2=sock_R, center=true);
    }
}

// Internal stop shoulder: leave a smaller bore above the socket depth
// (i.e., subtract a smaller-diameter continuation so a visible step remains)
module inner_stop_bore() {
    stop_bore_r = max(0.01, sock_R - stop_thk);
    stop_bore_h = cap_length - socket_depth_eff; // from stop plane to top
    translate([0,0, z_bottom + socket_depth_eff + stop_bore_h/2])
        cylinder(h=stop_bore_h + overlap, r=stop_bore_r, center=true);
}

// Outer grip ribs (axial)
module rib() {
    // Center ribs around the socket region; ensure they stay within cap length
    rib_len_eff = min(rib_length, socket_depth_eff);
    translate([rib_center_r, 0, z_bottom + socket_depth_eff/2])
        cube([rib_radial, rib_width, rib_len_eff], center=true);
}

module ribs() {
    for (i=[0:rib_count-1])
        rotate([0,0, i*360/rib_count]) rib();
}

// Main cap (ONE connected solid)
module cap_solid() {
    union() {
        difference() {
            outer_body();
            // Subtract cavity and the smaller stop-bore continuation to create a visible internal step
            inner_cavity();
            inner_stop_bore();
        }
        // Add ribs with slight overlap into body for watertight union
        ribs();
    }
}

// Fillet outer edges slightly (kept small to avoid heavy geometry)
module cap_fillet() {
    minkowski() {
        cap_solid();
        sphere(r=fillet_r);
    }
}

cap_fillet();