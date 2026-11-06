# Sopranle

A daily guessing game for *The Sopranos*. Each day you get a short clip of a scene and three tries to name the episode:

1. First try: 3 seconds of the clip
2. Second try: 5 seconds
3. Third try: 10 seconds

Wrong guesses tell you whether you have the right season, and whether the answer is earlier or later.

## Play

Open the hosted page, or run it locally on Windows by double-clicking `Play Sopranle.bat`. It starts a small server at `http://localhost:8000`. YouTube clips won't play if you open `index.html` straight from disk.

## Clips

The game uses 86 YouTube clips, one per episode, listed in `CLIPS` inside `index.html`. Each day's clip comes from `DAILY_ORDER`, starting on 5 November 2026 as puzzle #1.

To add a clip, append an entry to the end of `CLIPS`:

```js
{ id: 'YOUTUBE_VIDEO_ID', s: 3, e: 11, scene: 'Short description shown after the game', start: 4 },
```

`start` (optional) is the second in the video where the clip begins. It defaults to 1. If a clip stops being available on YouTube, the game loads a backup clip for that day.

Fan-made. Clips are embedded from YouTube and belong to their owners.
