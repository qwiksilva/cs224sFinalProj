
Directory Structure for CD-ROM r63_1.1 (hub5e_00).

  hub5e_00/english :: directory containing 40 English conversations
                      (.sph), and one index file (hub5e_00.pem).

  hub5e_00/doc     :: directory containing any supporting evaluation
		      documentation.

  hub5e_00/readme.txt :: This file.


Each waveform is a sphere headered, two channel interleaved mulaw
file.

Each line in the PEM index file, contains information regarding one
speech segment to be processed.

  PEM index file format:

      <waveform_id> <channel> <speaker> <beg_time> <end_time>
      ...


