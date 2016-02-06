noise-player
============

**NOT WORKING ON THIS ANYMORE SINCE AMAROK WORKS NOW**

Plays noises.

Runs as an interactive process which can play/pause and switch songs to an arbitrary seek point at any time. Can accept a list of songs and seek points to pre-cache and queue to play.

# Commands

- clear
    - removes all upcoming from queue
- stop
    - runs clear and stops playback
- loop_on/off
    - turn looping on or off
- random_on/off
    - turn shuffle on or off
- interrupt <queue>
    - interrupts current queue and plays queue
- enqueue <queue>
    - appends queue to current queue
- pause
    - pauses current queue (no-op if not applicable)
- play
    - unpauses current queue (no-op if not applicable)
- seek <time>
    - seeks to time within current track (no-op if not applicable)
- next/prev
    - skip forward and back
- get-queue
    - displays current queue in json

# Queues

Queues are a list of files.
