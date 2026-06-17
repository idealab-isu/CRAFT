$fn=220;

// HT 110 end cap (approximate) with visible rim, wall thickness, internal socket + stop, and chamfers.
// Z=0 is the open end (bottom). Cap is closed at the top.

module ht110_cap(
    d_nom=110,            // nominal pipe OD
    wall=3.2,             // cap wall thickness
    height=55,            // overall height
    top_th=4.0,           // closed top thickness
    clearance=0.6,        // clearance for pipe fit (added to inner diameter)
    rim_add=2.2,          // extra radial thickness at outer rim (reinforcement)
    rim_h=10,             // height of reinforced rim at opening
    leadin_h=2.0,         // inner lead-in height at opening
    leadin_add=1.2,       // inner lead-in radial expansion
    outer_ch=1.2,         // outer bottom chamfer height
    stop_h=2.0,           // internal stop ring height
    stop_add=1.6,         // internal stop ring radial reduction (makes a shoulder)
    socket_depth=32       // depth of socket from opening to stop
){
    eps = 0.02;

    d_body = d_nom;                       // main outer diameter
    d_rim  = d_nom + 2*rim_add;           // reinforced rim OD
    d_in_fit = d_nom - 2*wall + clearance; // inner diameter for pipe fit

    // Ensure socket depth doesn't collide with top thickness
    socket_depth_eff = min(socket_depth, height - top_th - stop_h - 0.5);

    // Stop ring creates a smaller ID above the socket depth
    d_in_stop = d_in_fit - 2*stop_add;

    // Safety clamps
    d_in_stop2 = max(1, d_in_stop);

    difference() {
        // OUTER SOLID (one connected body)
        union() {
            // Main outer cylinder
            cylinder(h=height, d=d_body);

            // Reinforced rim at opening (connected, overlaps main body)
            cylinder(h=rim_h, d=d_rim);

            // Outer bottom chamfer (connected, slight taper)
            cylinder(h=outer_ch, d1=d_rim, d2=d_rim - 2*outer_ch);

            // Slight top edge softening (tiny chamfer)
            translate([0,0,height-outer_ch])
                cylinder(h=outer_ch, d1=d_body, d2=d_body - 2*outer_ch);
        }

        // INNER CAVITY (open at bottom, closed at top)
        // 1) Lead-in flare at opening for easier insertion
        translate([0,0,0])
            cylinder(h=leadin_h, d1=d_in_fit + 2*leadin_add, d2=d_in_fit);

        // 2) Main socket (pipe insertion) down to stop
        translate([0,0,leadin_h - eps])
            cylinder(h=socket_depth_eff - (leadin_h - eps), d=d_in_fit);

        // 3) Stop ring: above socket depth, reduce ID to create shoulder
        //    This leaves material (a ring) at the transition.
        translate([0,0,socket_depth_eff])
            cylinder(h=stop_h, d=d_in_stop2);

        // 4) Upper void above stop (keeps cap hollow but leaves top thickness)
        translate([0,0,socket_depth_eff + stop_h - eps])
            cylinder(h=height - top_th - (socket_depth_eff + stop_h) + eps, d=d_in_fit);

        // 5) Inner top relief (tiny) to avoid razor edge inside
        translate([0,0,height-top_th])
            cylinder(h=top_th + eps, d1=d_in_fit, d2=d_in_fit - 2*outer_ch);
    }
}

ht110_cap();