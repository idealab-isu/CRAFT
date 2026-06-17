$fn=96;

body_d = 0.76;
body_h = 4.7;

module toggle_switch(body_d=0.76, body_h=4.7) {
    // Simple cylindrical body representation
    cylinder(d=body_d, h=body_h, center=false);
}

toggle_switch(body_d, body_h);