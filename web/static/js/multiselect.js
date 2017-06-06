
  function renderTags ( select ) {
    let multiselectId = select.getAttribute( "data-multiselect-id" );

    let tagsContainer = document.querySelector(
      `.form-multiselect__tags[data-multiselect-id="${ multiselectId }"]`
    );

    let tags = Array.from( select.children ).map(
      ( domOption ) => ({
        name: domOption.textContent,
        id: domOption.getAttribute( "value" ),
        selected: domOption.selected
      })
    ).filter(
      ( option ) => option.selected
    );

    tagsContainer.innerHTML = tags.map(
      ( tag ) => `
        <span class="mdl-chip mdl-chip--deletable">
          <span class="mdl-chip__text">
            ${ tag.name }
          </span>
          <button
            type="button"
            class="mdl-chip__action form-multiselect__delete"
            data-multiselect-id="${ multiselectId }"
            data-multiselect-item-id="${ tag.id }"
            data-multiselect-delete
          >
            <i class="material-icons">cancel</i>
          </button>
        </span>
      `
    ).join("");
  }

  function emitChange ( element ) {
    if ( "createEvent" in document ) {
      var evt = document.createEvent( "HTMLEvents" );
      evt.initEvent( "change", false, true );
      element.dispatchEvent( evt );
    } else {
      element.fireEvent( "onchange" );
    }
  }

  function initializeMultiselects ( ) {
    document.addEventListener( "click",
      ( e ) => {
        if ( e.target.hasAttribute( "data-multiselect-add" ) ) {
          let multiselectId = e.target.getAttribute( "data-multiselect-id" );

          let itemId = document.querySelector(
            `.form-multiselect__dropdown[data-multiselect-id="${ multiselectId }"] option:checked`
          ).getAttribute( "value" );

          document.querySelector(
            `.form-multiselect__select[data-multiselect-id="${ multiselectId }"] option[value="${ itemId }"]`
          ).selected = true;

          let multiselect = document.querySelector(
            `.form-multiselect__select[data-multiselect-id="${ multiselectId }"]`
          );

          emitChange( multiselect );
        } else {
          if ( e.target.hasAttribute( "data-multiselect-delete" ) ) {
            let multiselectId = e.target.getAttribute( "data-multiselect-id" );
            let itemId = e.target.getAttribute( "data-multiselect-item-id" );

            document.querySelector(
              `.form-multiselect__select[data-multiselect-id="${ multiselectId }"] option[value="${ itemId }"]`
            ).selected = false;

            let multiselect = document.querySelector(
              `.form-multiselect__select[data-multiselect-id="${ multiselectId }"]`
            );

            emitChange( multiselect );
          }
        }
      }
    );

    Array.from(
      document.querySelectorAll( ".form-multiselect__select" )
    ).forEach(
      ( select ) => {
        select.addEventListener( "change", ( e ) => renderTags( e.target ) );
        renderTags( select );
      }
    );
  }

  module.exports.initializeMultiselects = initializeMultiselects;
