noise-player
============

Plays noises.

Runs as an interactive process which can play/pause and switch songs to an arbitrary seek point at any time. Can accept a list of songs and seek points to pre-cache and queue to play.

# Commands

- clear
    - removes all upcoming from queue
- stop
    - runs clear and stops playback
- play <queue>
    - interrupts current queue and plays queue
- enqueue <queue>
    - appends queue to current queue
- pause
    - pauses current queue (no-op if not applicable)
- unpause
    - unpauses current queue (no-op if not applicable)
- seek <time>
    - seeks to time within current track
- get-queue
    - displays current queue

# Queues

Queues are a list of `{filename, start-seek-pos}` objects.
