# ZX0 v2 decompressor (forward, standard), for checking the packed heightmaps.
import sys
def unzx0(d):
    out = bytearray(); i = 0; bitmask = 0; bitval = 0; last_offset = 1; backtrack = False; last_byte = 0
    def read_byte():
        nonlocal i, last_byte
        last_byte = d[i]; i += 1; return last_byte
    def read_bit():
        nonlocal bitmask, bitval, backtrack
        if backtrack:
            backtrack = False; return last_byte & 1
        bitmask >>= 1
        if bitmask == 0:
            bitmask = 128; bitval = read_byte()
        return 1 if bitval & bitmask else 0
    def gamma(inverted=False):
        v = 1
        while not read_bit():
            v = (v << 1) | (read_bit() ^ inverted)
        return v
    state = 'lit'
    while True:
        if state == 'lit':
            n = gamma()
            for _ in range(n): out.append(read_byte())
            state = 'new' if read_bit() else 'last'
        elif state == 'last':
            n = gamma()
            for _ in range(n): out.append(out[-last_offset])
            state = 'new' if read_bit() else 'lit'
        else:
            msb = gamma(True)
            if msb == 256: return bytes(out)
            lsb = read_byte()
            last_offset = msb * 128 - (lsb >> 1)
            backtrack = True
            n = gamma() + 1
            for _ in range(n): out.append(out[-last_offset])
            state = 'new' if read_bit() else 'lit'
if __name__ == "__main__":
    sys.stdout.buffer.write(unzx0(open(sys.argv[1], 'rb').read()))
