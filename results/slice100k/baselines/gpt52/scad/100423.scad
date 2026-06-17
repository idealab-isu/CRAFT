$fn=64;

sx=6.2;
sy=6.0;
sz=11.6;

module lowpoly_spiral_rosette(sx=6.2, sy=6.0, sz=11.6, n=28, m=18, twist=520, pinch=0.55, center_sink=0.62) {
    function lerp(a,b,t)=a+(b-a)*t;
    function clamp(x,a,b)=x<a?a:(x>b?b:x);
    function smoothstep(t)=let(tt=clamp(t,0,1)) tt*tt*(3-2*tt);

    function r_outer(t)=
        let(s=smoothstep(t))
        (1 - pinch*pow(abs(2*t-1),1.35)) * (0.98 - 0.06*s);

    function r_inner(t)=
        let(s=smoothstep(t))
        (0.10 + 0.10*(1-abs(2*t-1))) * (0.85 - 0.25*s);

    function z_of(t)=lerp(-sz/2, sz/2, t);

    function ang_of(t)=twist*t;

    function p_outer(t, a)=
        let(ro=r_outer(t), ang=a+ang_of(t))
        [ (sx/2)*ro*cos(ang), (sy/2)*ro*sin(ang), z_of(t) ];

    function p_inner(t, a)=
        let(ri=r_inner(t), ang=a+ang_of(t)*1.15)
        [ (sx/2)*ri*cos(ang), (sy/2)*ri*sin(ang), z_of(t) - (sz*center_sink)*(0.15+0.85*(1-abs(2*t-1))) ];

    module band(t0, t1) {
        for (i=[0:n-1]) {
            a0=360*i/n;
            a1=360*(i+1)/n;

            o00=p_outer(t0,a0);
            o01=p_outer(t0,a1);
            o10=p_outer(t1,a0);
            o11=p_outer(t1,a1);

            in00=p_inner(t0,a0);
            in01=p_inner(t0,a1);
            in10=p_inner(t1,a0);
            in11=p_inner(t1,a1);

            polyhedron(
                points=[
                    o00,o01,o11,o10,
                    in00,in01,in11,in10
                ],
                faces=[
                    [0,1,2],[0,2,3],
                    [4,7,6],[4,6,5],
                    [0,4,5],[0,5,1],
                    [1,5,6],[1,6,2],
                    [2,6,7],[2,7,3],
                    [3,7,4],[3,4,0]
                ],
                convexity=10
            );
        }
    }

    union() {
        for (j=[0:m-1]) {
            t0=j/m;
            t1=(j+1)/m;
            band(t0,t1);
        }
    }
}

lowpoly_spiral_rosette(sx=sx, sy=sy, sz=sz, n=30, m=20, twist=560, pinch=0.58, center_sink=0.60);