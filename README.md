AI SLOP DISCLAIMER
==================

NO PART OF THIS WORK OR WORKS DERIVED THEREFROM MAY BE USED BY ANY MEANS FOR
THE TRAINING OF OR ANALYSIS BY AI TOOLS.

------------------

<div style="text-align: right"> Everybody has a plan until they get punched in the mouth. Then, like a rat, they stop in fear and freeze. </div>
<div style="text-align: right"> – Mike Tyson </div>


ZUC Cipher Verilog Implementation
=================================

Hi there! If you like ciphers and hardware, and are interested in the ZUC
cipher, you have come to the right place! Here you will find a: **clean-room
commercial-grade ZUC cipher RTL implementation (includes eea3 and eia3)**. I am
quite excited about my small and clean and very nice Verilog implementation –
you too?

Some background on the ZUC cipher can be found at
[Wikipedia](https://en.wikipedia.org/wiki/ZUC_stream_cipher).

General Notes
-------------

The IP core interfaces are stream-oriented and thus self-explanatory. There is
a setup-period of 32 cycles (or 32+1 cycles? -> check source) for every packet,
but other than that the core achieves line rate (= 128 bits times clock
frequency). There is also the option to either use bram or logic for the
S-boxes, but unfortunately it does not make much of a difference in timing
behavior.
However, it does make a difference with respect to resource usage. For example,
the difference in the LUT and BRAM usage in the resource and timing examples is
due to this setting being different between the first and the latter two
respectively.

Further, there is also the option to specify the byte width (`bw`), because
crypto specification people count in bits. If you have certain alignment
restrictions, you can use this to lower resource usage, such as to make
everyone happy!

Also please beware of endianness. The specification is big (bit) endian (as
almost all crypto specs), but my implementation is entirely little-endian. You
will probably have to do some byte- and bit-shuffling, in order for it to work. Please
see the testbenches for further information on this.

Resource Usage and Timing
-------------------------

Target frequency: 238 MHz

Target device: xcvu065-ffvc1517-3-e

For the plain `zuc` module:

```
+------------------+----------+------------+------------+---------+------+-----+--------+--------+------+------------+
|     Instance     |  Module  | Total LUTs | Logic LUTs | LUTRAMs | SRLs | FFs | RAMB36 | RAMB18 | URAM | DSP Blocks |
+------------------+----------+------------+------------+---------+------+-----+--------+--------+------+------------+
| zuc              |    (top) |        578 |        576 |       0 |    2 | 503 |      0 |      4 |    0 |          0 |
|   (zuc)          |    (top) |        131 |        129 |       0 |    2 | 503 |      0 |      0 |    0 |          0 |
|   zuc_s0_r1_inst |   zuc_s0 |        131 |        131 |       0 |    0 |   0 |      0 |      1 |    0 |          0 |
|   zuc_s0_r2_inst | zuc_s0_0 |        121 |        121 |       0 |    0 |   0 |      0 |      1 |    0 |          0 |
|   zuc_s1_r1_inst |   zuc_s1 |        122 |        122 |       0 |    0 |   0 |      0 |      1 |    0 |          0 |
|   zuc_s1_r2_inst | zuc_s1_1 |        101 |        101 |       0 |    0 |   0 |      0 |      1 |    0 |          0 |
+------------------+----------+------------+------------+---------+------+-----+--------+--------+------+------------+
Slack (VIOLATED) :        -0.195ns  (required time - arrival time)
  Source:                 lfsr_reg[0][0]/C
                            (rising edge-triggered cell FDRE clocked by clock  {rise@0.000ns fall@2.100ns period=4.200ns})
  Destination:            lfsr_reg[15][28]/D
                            (rising edge-triggered cell FDRE clocked by clock  {rise@0.000ns fall@2.100ns period=4.200ns})
  Path Group:             clock
  Path Type:              Setup (Max at Slow Process Corner)
  Requirement:            4.200ns  (clock rise@4.200ns - clock rise@0.000ns)
  Data Path Delay:        4.407ns  (logic 2.320ns (52.644%)  route 2.087ns (47.356%))
  Logic Levels:           19  (CARRY8=13 LUT2=1 LUT3=3 LUT4=1 LUT5=1)
```

For the `zuc_eea3` module:

```
+--------------+---------+------------+------------+---------+------+-----+--------+--------+------+------------+
|   Instance   |  Module | Total LUTs | Logic LUTs | LUTRAMs | SRLs | FFs | RAMB36 | RAMB18 | URAM | DSP Blocks |
+--------------+---------+------------+------------+---------+------+-----+--------+--------+------+------------+
| zuc_eea3     |   (top) |        873 |        871 |       0 |    2 | 605 |      0 |      0 |    0 |          0 |
|   zuc_ctl    | zuc_ctl |        840 |        838 |       0 |    2 | 567 |      0 |      0 |    0 |          0 |
|     zuc_inst |     zuc |        840 |        838 |       0 |    2 | 566 |      0 |      0 |    0 |          0 |
+--------------+---------+------------+------------+---------+------+-----+--------+--------+------+------------+
Slack (VIOLATED) :        -0.198ns  (required time - arrival time)
  Source:                 zuc_ctl/zuc_inst/lfsr_reg[0][0]/C
                            (rising edge-triggered cell FDRE clocked by clock  {rise@0.000ns fall@2.100ns period=4.200ns})
  Destination:            zuc_ctl/zuc_inst/lfsr_reg[15][28]/D
                            (rising edge-triggered cell FDRE clocked by clock  {rise@0.000ns fall@2.100ns period=4.200ns})
  Path Group:             clock
  Path Type:              Setup (Max at Slow Process Corner)
  Requirement:            4.200ns  (clock rise@4.200ns - clock rise@0.000ns)
  Data Path Delay:        4.410ns  (logic 2.320ns (52.608%)  route 2.090ns (47.392%))
  Logic Levels:           19  (CARRY8=13 LUT2=1 LUT3=3 LUT4=1 LUT5=1)
```

For the `zuc_eia3` module:
```
+------------------------------+--------------------+------------+------------+---------+------+-----+--------+--------+------+------------+
|           Instance           |       Module       | Total LUTs | Logic LUTs | LUTRAMs | SRLs | FFs | RAMB36 | RAMB18 | URAM | DSP Blocks |
+------------------------------+--------------------+------------+------------+---------+------+-----+--------+--------+------+------------+
| zuc_eia3                     |              (top) |       1330 |       1328 |       0 |    2 | 711 |      0 |      0 |    0 |          0 |
|   (zuc_eia3)                 |              (top) |          0 |          0 |       0 |    0 |  34 |      0 |      0 |    0 |          0 |
|   zuc_ctl                    |            zuc_ctl |       1008 |       1006 |       0 |    2 | 568 |      0 |      0 |    0 |          0 |
|     zuc_inst                 |                zuc |       1008 |       1006 |       0 |    2 | 567 |      0 |      0 |    0 |          0 |
|   zuc_regslice_inst_data     | zuc_regslice_chain |        290 |        290 |       0 |    0 |  76 |      0 |      0 |    0 |          0 |
|     genblk1[1].regslice_inst |     zuc_regslice_0 |        289 |        289 |       0 |    0 |  38 |      0 |      0 |    0 |          0 |
+------------------------------+--------------------+------------+------------+---------+------+-----+--------+--------+------+------------+
Slack (VIOLATED) :        -0.210ns  (required time - arrival time)
  Source:                 zuc_ctl/zuc_inst/lfsr_reg[0][0]/C
                            (rising edge-triggered cell FDRE clocked by clock  {rise@0.000ns fall@2.100ns period=4.200ns})
  Destination:            zuc_ctl/zuc_inst/lfsr_reg[15][28]/D
                            (rising edge-triggered cell FDRE clocked by clock  {rise@0.000ns fall@2.100ns period=4.200ns})
  Path Group:             clock
  Path Type:              Setup (Max at Slow Process Corner)
  Requirement:            4.200ns  (clock rise@4.200ns - clock rise@0.000ns)
  Data Path Delay:        4.422ns  (logic 2.357ns (53.302%)  route 2.065ns (46.698%))
  Logic Levels:           20  (CARRY8=13 LUT2=1 LUT3=3 LUT4=1 LUT5=1 LUT6=1)
```

Regression Tests
----------------

You can run all regressions by `cd sim; make -j $(nproc)`. If no errors are
encountered, all is well. The regression tests do not stop when an error is
encountered, but continue. Currently the regressions test bench only checks the
default test vectors from the spec. A random constrained regression with the C
model would be nice, however I haven't had the time yet (TODO FIXME).

Recommendations
---------------

Albeit it is always said that security by obscurity is a bad design choice, it
does add another layer of complexity in case of an already secure cipher, and
thus security if the attacker has to find out the algorithm first. So feel
free to make changes and _run your own crypto!_ However, due to the GPL
license, there are only certain applications where you could do so without
publishing your changes.

Specifications
--------------

This work is based upon the following specifications:

* Specification of the 3GPP Confidentiality and Integrity Algorithms 128-EEA3 &
128-EIA3.
Document 1: 128-EEA3 and 128-EIA3 Specifications.

* Specification of the 3GPP Confidentiality and Integrity Algorithms 128-EEA3 &
128-EIA3.
Document 2: ZUC Specification.

* Specification of the 3GPP Confidentiality and Integrity Algorithms 128-EEA3 &
128-EIA3.
Document 3: Implementor’s Test Data.

If you'd like to obtain these specifications, feel free to type `cd doc; make`.
If that fails, there is most certainly some site on the internet that has
archived these given links. The sample C code in `c/` is based upon the sample
code given in these specifications and helped tremendously during
implementation.

Code of Conduct
---------------

You may say anything. But if I don't like it, I might censor it. Thank you very
much!

License
-------

See file `LICENSE` in top directory.

Legal Notice
------------

The code in the repository is public domain and not subject to the Wassenaar
Agreement. See also [here](https://www.gnu.org/philosophy/wassenaar.en.html).
