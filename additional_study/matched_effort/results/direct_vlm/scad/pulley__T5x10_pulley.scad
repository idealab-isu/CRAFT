$fn = 180;

// Timing pulley with 10 teeth and 15.0mm pitch diameter
// Teeth are modeled as outward protrusions (not grooves).
// Pitch diameter is enforced by placing the tooth pitch line on the pitch circle.

teeth        = 10;
pitch_d      = 15.0;
pitch_r      = pitch_d/2;
pitch        = PI * pitch_d / teeth;

pulley_width = 10;      // mm

// Tooth / body geometry (simple timing-pulley-like approximation)
tooth_height = 1.2;     // radial height above pitch circle
body_wall    = 1.6;     // radial thickness below pitch circle
root_r       = pitch_r - body_wall;     // inner/root cylinder radius
outer_r      = pitch_r + tooth_height;  // tooth tip radius

// Tooth shape controls (tangential width at pitch circle)
tooth_w      = 0.45 * pitch;  // tooth thickness along tangent at pitch circle
tooth_tip_w  = 0.28 * pitch;  // tooth thickness at tip (slightly narrower)
tooth_round  = 0.35;          // rounding radius for tooth corners (mm)

// Bore / hub
bore_d    = 5.0;  // mm
hub_d     = 0;    // set >0 for hub
hub_width = 0;

module rounded_trap_2d(w_base, w_tip, h, r){
    // Trapezoid centered at origin, height along +Y, base at y=0, tip at y=h
    // Rounded via offset (keeps it simple and robust)
    pts = [
        [-w_base/2, 0],
        [ w_base/2, 0],
        [ w_tip/2,  h],
        [-w_tip/2,  h]
    ];
    offset(r=r) offset(delta=-r)
        polygon(points=pts);
}

module pulley(){
    overlap = 0.25; // small overlap to guarantee connectivity

    difference(){
        union(){
            // Root cylinder (solid core)
            cylinder(h=pulley_width, r=root_r);

            // Teeth: pitch line at pitch_r, tooth extends from pitch_r to outer_r
            // Place tooth so its inner face overlaps slightly into the root cylinder.
            for(i=[0:teeth-1]){
                rotate([0,0, i*360/teeth])
                    translate([pitch_r - overlap, 0, 0])
                        linear_extrude(height=pulley_width)
                            rotate(90)  // make trapezoid height point radially outward (X)
                                rounded_trap_2d(
                                    w_base = tooth_w,
                                    w_tip  = tooth_tip_w,
                                    h      = (outer_r - pitch_r) + overlap,
                                    r      = tooth_round
                                );
            }

            // Optional hub (connected by overlap)
            if(hub_d > 0 && hub_width > 0){
                translate([0,0,(pulley_width - hub_width)/2 - overlap])
                    cylinder(h=hub_width + 2*overlap, d=hub_d);
            }
        }

        // Bore
        translate([0,0,-overlap])
            cylinder(h=pulley_width + 2*overlap, d=bore_d);
    }
}

pulley();