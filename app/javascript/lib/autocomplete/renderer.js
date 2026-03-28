export class Renderer {
  renderAutocompletableSuggestions(autocompletables, options = {}) {
    const { selectedAutocompletable } = options
    let html = ""

    autocompletables.forEach((autocompletable) => {
      const isSelected = autocompletable === selectedAutocompletable
      const multipleAttr = autocompletable.type === "group" ? "multiple" : ""
      const selectedAriaSelectedAttrs = isSelected ? "selected aria-selected" : ""

      html += `
        <suggestion-option class="autocomplete__item flex align-center gap unpad" role="option" value="${autocompletable.value}" ${multipleAttr} ${selectedAriaSelectedAttrs}>
          ${
            autocompletable.pending
              ? `Add <strong>${autocompletable.name}…</strong>`
              : autocompletable.noResultsLabel
              ? `<span class="txt--disable-truncate">${autocompletable.noResultsLabel}</span>`
              : this.renderAutocompletable(autocompletable)
          }
        </suggestion-option>
      `
    })

    return html
  }

  renderAutocompletable(autocompletable) {
    if (autocompletable.type === "room_mention") {
      return this.#renderRoomMention(autocompletable)
    }

    const html = `
      <button class="autocomplete__btn btn btn--borderless btn--transparent min-width flex-item-grow justify-start" data-value="${autocompletable.value}">
        <span class="avatar">
          <img src="${autocompletable.avatar_url}" class="automcomplete__avatar" role="presentation" />
        </span>
        <span class="autocompletable__name">${autocompletable.name}</span>
        <a href="#" class="autocompletable__unselect" aria-label="Remove ${autocompletable.name}" data-behavior="unselect_autocompletable">×</a>
      </button>
    `

    return html
  }

  #renderRoomMention(autocompletable) {
    const html = `
      <button class="autocomplete__btn btn btn--borderless btn--transparent min-width flex-item-grow justify-start" data-value="${autocompletable.value}">
        <span class="avatar avatar--room">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" width="20" height="20">
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
          </svg>
        </span>
        <span class="autocompletable__name">Everyone in room</span>
        <a href="#" class="autocompletable__unselect" aria-label="Remove room mention" data-behavior="unselect_autocompletable">×</a>
      </button>
    `

    return html
  }
}
