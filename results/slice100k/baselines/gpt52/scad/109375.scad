$fn=64;

L = 149.2;
W = 27.2;
T = 2.6;

spine_w = 6.0;
tab_w = W;
tab_h = 4.0;

n_tabs = 9;
end_margin = 8.0;

module spine() {
    cube([spine_w, L, T], center=true);
}

module tab_at(ypos) {
    translate([0, ypos, 0])
        cube([tab_w, tab_h, T], center=true);
}

module rack() {
    union() {
        spine();
        for (i = [0 : n_tabs-1]) {
            y = -L/2 + end_margin + (L - 2*end_margin) * (i/(n_tabs-1));
            tab_at(y);
        }
    }
}

rack();