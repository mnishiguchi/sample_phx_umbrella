import { Presence } from 'phoenix';
import Player from './player';

// Video
export default {
  init(socket, element) {
    if (!element) return;
    const playerId = element.getAttribute('data-player-id');
    const videoId = element.getAttribute('data-id');
    socket.connect();
    Player.init(element.id, playerId, () => {
      this.onPlayerLoaded(videoId, socket);
    });
  },

  onPlayerLoaded(videoId, socket) {
    const msgContainer = document.getElementById('msg-container');
    const msgInput = document.getElementById('msg-input');
    const postButton = document.getElementById('msg-submit');
    const userList = document.getElementById('user-list');

    // Bump this value every time we see a new annotation. Then whenever we
    // rejoin following a crash or disconnect, we can send our `last_seen_id` to
    // the server. That way, the server can only send the data we missed.
    let lastSeenId = 0;

    // Let the user join the channel for a specified video.
    const videoChannel = socket.channel(`videos:${videoId}`, () => {
      return { last_seen_id: lastSeenId };
    });

    const presence = new Presence(videoChannel);

    // Render our users as list items when users join or leave the app.
    presence.onSync(() => {
      userList.innerHTML = presence
        .list((id, { metas: [first, ...rest], user: user }) => {
          const count = rest.length + 1;
          return `<li>${user.username}: (${count})</li>`;
        })
        .join('');
    });

    postButton.addEventListener('click', (e) => {
      const payload = { body: msgInput.value, at: Player.getCurrentTime() };

      // Sent a new annotation to the server.
      videoChannel.push('new_annotation', payload).receive('error', (e) => {
        console.log(e);
      });

      // Clear the input.
      msgInput.value = '';
    });

    // When we push an event to the server, we can opt to receive a response.
    videoChannel.on('new_annotation', (resp) => {
      lastSeenId = resp.id;
      this.renderAnnotation(msgContainer, resp);
    });

    // Have the annotations clicable so we can jump to the exact time the
    // annotation was made by clicking it.
    msgContainer.addEventListener('click', (e) => {
      e.preventDefault();

      const seconds =
        e.target.getAttribute('data-seek') || e.target.parentNode.getAttribute('data-seek');
      if (!seconds) return;

      Player.seekTo(seconds);
    });

    videoChannel
      .join()
      .receive('ok', ({ annotations }) => {
        const ids = annotations.map((annotation) => annotation.id);
        if (ids.length > 0) {
          lastSeenId = Math.max(...ids);
        }

        this.scheduleMessages(msgContainer, annotations);
      })
      .receive('error', (reason) => {
        console.log('join failed', reason);
      });
  },

  // Append an annotation to msgContainer. Scrolls the msgContainer at the
  // right point.
  renderAnnotation(msgContainer, { user, body, at }) {
    const template = document.createElement('div');

    template.innerHTML = `
    <a href="#" data-seek="${this.esc(at)}">
      [${this.formatTime(at)}]
      <b>${this.esc(user.username)}</b>: ${this.esc(body)}
    </a>
    `;
    msgContainer.appendChild(template);
    msgContainer.scrollTop = msgContainer.scrollHeight;
  },

  // Schedules messages to be rendered based on the current player time.
  // Every second, renders all annotations occuring at or before the currrent
  // player time.
  scheduleMessages(msgContainer, annotations) {
    clearTimeout(this.scheduleTimer);
    this.scheduleTimer = setTimeout(() => {
      const currentTime = Player.getCurrentTime();
      const remainingAnnotations = this.renderAtTime(annotations, currentTime, msgContainer);
      this.scheduleMessages(msgContainer, remainingAnnotations);
    }, 1000);
  },

  // Renders all annotations occuring at or before the currrent player time.
  // Returns the remaining annotations.
  renderAtTime(annotations, seconds, msgContainer) {
    return annotations.filter((annotation) => {
      // For those yet to appear.
      if (seconds < annotation.at) {
        return true;
      }

      this.renderAnnotation(msgContainer, annotation);
      return false;
    });
  },

  // Accepts current player time in milliseconds and formats it.
  //
  // EXAMPLES
  //
  //    > formatTime(93202)
  //    "01:33"
  //
  formatTime(at) {
    const date = new Date(null);
    date.setSeconds(at / 1000);
    return date.toISOString().substr(14, 5);
  },

  // Escapes user input before injecting values into the page. This strategy
  // protects our users from XSS attacks.
  //
  // EXAMPLES
  //
  //    > esc('<script>alert("destroy it")</script>')
  //    '&lt;script&gt;alert("destroy it")&lt;/script&gt;'
  //
  esc(str) {
    const div = document.createElement('div');
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
  },
};
