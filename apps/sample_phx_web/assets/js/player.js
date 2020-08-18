// A video player object. It builds an API for video players with most important features for our
// app. It will insulate us from changes in youTube and also let us add other video players over
// time. https://developers.google.com/youtube/iframe_api_reference
export default {
  player: null,

  // Parameters:
  // - domId: the HTMP container ID to hold the iframe.
  // - playerId: a video id.
  // - onReady: a callback.
  init(domId, playerId, onReady) {
    // Wire up YouTube's special callback onYouTubeIframeAPIReady.
    window.onYouTubeIframeAPIReady = () =>
      this.onYouTubeIframeAPIReady(domId, playerId, onReady);

    this.insertYouTubeScriptTag();
  },

  onYouTubeIframeAPIReady(domId, playerId, onReady) {
    // Create the player with the YouTube iframe API.
    this.player = new YT.Player(domId, {
      height: '360',
      width: '420',
      videoId: playerId,
      events: {
        onReady,
        onStateChange: this.onPlayerStateChange(event),
      },
    });
  },

  insertYouTubeScriptTag() {
    const youtubeScriptTag = document.createElement('script');
    youtubeScriptTag.src = 'https://www.youtube.com/iframe_api';
    const firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(youtubeScriptTag, firstScriptTag);
  },

  onPlayerStateChange(event) {},

  getCurrentTime() {
    return Math.floor(this.player.getCurrentTime() * 1000);
  },

  seekTo(millsec) {
    return this.player.seekTo(millsec / 1000);
  },
};
