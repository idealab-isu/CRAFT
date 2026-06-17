$fn = 128;

// HT 32 cap (approximation) - hollow end cap with internal socket + stop
// Dimensions in mm (typical HT DN32: OD ~ 40mm). Adjust as needed.
od        = 40.0;   // outer diameter of cap body
wall      = 2.2;    // wall thickness
h_total   = 28.0;   // total height
h_socket  = 22.0;   // insertion depth (internal cavity height)
roof      = 3.0;    // closed-end thickness (cap roof)
rim_h     = 2.0;    // external rim height at opening
rim_add   = 1.2;    // external rim radial add (diameter add)
chamfer   = 1.0;    // small edge chamfer
stop_h    = 1.6;    // internal stop ring height
stop_add  = 1.2;    // internal stop ring radial add (reduces ID locally)
lead_h    = 2.0;    // inner lead-in height

// Derived
id        = od - 2*wall;                 // nominal inner diameter at opening
h_void    = h_total - roof;              // cavity height available (from opening)
socket_h  = min(h_socket, h_void);       // clamp to avoid breaking through roof
stop_z    = max(0, socket_h - stop_h);   // stop ring near the closed end (inside cavity)
eps       = 0.02;

module chamfered_cylinder(h, d, c){
    c2 = min(c, d/4);
    hull(){
        cylinder(h=max(eps, h - c2), d=d);
        translate([0,0,max(eps, h - c2)])
            cylinder(h=max(eps, c2), d=max(eps, d - 2*c2));
    }
}

difference() {
    // OUTER SOLID (one connected body)
    union() {
        // main body with slight top chamfer
        chamfered_cylinder(h_total, od, chamfer);

        // external rim at opening (connected)
        cylinder(h=rim_h, d=od + rim_add);
    }

    // INNER CAVITY: open at bottom (z=0), closed at top by roof thickness
    // Main socket void (stops at z = socket_h, leaving roof above)
    cylinder(h=socket_h + eps, d=id);

    // Inner lead-in at opening (slightly larger at mouth)
    cylinder(h=lead_h, d1=id + 2.0, d2=id);

    // Internal stop shoulder: remove a smaller-diameter section near the closed end
    // This creates a step (shoulder) at z = stop_z inside the cavity.
    translate([0,0,stop_z])
        cylinder(h=stop_h + eps, d=id - 2*stop_add);

    // Outer bottom chamfer (subtractive) at the rim edge
    cylinder(h=1.2, d1=od + rim_add, d2=od - 0.8);
}