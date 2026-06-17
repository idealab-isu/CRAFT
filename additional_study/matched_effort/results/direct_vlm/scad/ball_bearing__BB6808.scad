$fn = 180;

// Bearing target dimensions (mm)
bore_d = 40.0;
od_d   = 52.0;
width  = 7.0;

// Geometry controls (kept parametric but derived from dimensions)
eps = 0.25;                 // small overlap to guarantee connectivity
ring_thickness = 2.0;       // radial thickness of each ring (fits within (od-bore)/2 = 6mm)
race_gap = (od_d - bore_d)/2 - 2*ring_thickness;  // remaining radial space between rings

inner_od = bore_d + 2*ring_thickness;             // inner ring outer diameter
outer_id = od_d   - 2*ring_thickness;             // outer ring inner diameter

// Ball sizing and placement (ensure balls touch both rings for ONE connected solid)
ball_d = min(width*0.85, race_gap + 2*eps);        // slightly larger than gap to overlap into rings
ball_r = ball_d/2;

// Ball path radius centered in the raceway
ball_path_r = (inner_od/2 + outer_id/2)/2;

// Ball count based on circumference and ball size (clamped)
n_balls = max(8, floor(2*PI*ball_path_r/(ball_d*1.15)));

module ring(outer_d, inner_d, h){
    difference(){
        cylinder(d=outer_d, h=h, center=true);
        cylinder(d=inner_d, h=h+0.2, center=true);
    }
}

module bearing(){
    union(){
        // Outer ring
        ring(od_d, outer_id, width);

        // Inner ring
        ring(inner_od, bore_d, width);

        // Balls (slightly squashed in Z so they fit within width while still visible in side view)
        for(i=[0:n_balls-1]){
            rotate([0,0,360*i/n_balls])
                translate([ball_path_r,0,0])
                    scale([1,1,(width - 0.4)/ball_d])
                        sphere(d=ball_d);
        }

        // Thin cage/bridge to ensure robust single-solid connectivity across all features
        // (connects inner and outer rings through the raceway with slight overlap)
        difference(){
            cylinder(d=outer_id + 2*eps, h=width - 0.6, center=true);
            cylinder(d=inner_od - 2*eps, h=width - 0.6 + 0.2, center=true);
        }
    }
}

bearing();