const fpsMax = [
    400, 260, 180, 160, 144, 120, 100, 80, 60
];


const name = i => 'fps_max_' + (i === 0 ? 'default' : fpsMax[i]);

const {length} = fpsMax;
const last = length - 1;
for (let i = 0; i < length; ++i) {
    const prev = i > 0 ? i - 1 : last;
    const next = i >= last ? 0 : i + 1;
    const n = name(i);
    console.log(`alias ${n} "`,
        `echo moeshin >>> ${n};`,
        `fps_max ${fpsMax[i]};`,
        `alias fps_max_prev ${name(prev)};`,
        `alias fps_max_next ${name(next)};`,
        '"');
}
