
  const { showModal, hideModals } = require( "./modal.js" );

  function initAttendances ( ) {
    document.addEventListener( "click",
      ( e ) => {
        if ( e.target.classList.contains( "show-attendance-modal" ) ) {
          let id = e.target.getAttribute( "data-attendance-id" );
          showModal( `.modal[data-attendance-id="${ id }"]` );
        }

        if ( e.target.classList.contains( "update-attendance" ) ) {
          let id = e.target.getAttribute( "data-attendance-id" );

          const value = document.querySelector(
            `.modal[data-attendance-id='${id}'] option:checked`
          ).value;

          if ( value ) {
            document.querySelector(
              `button[data-attendance-id='${id}'] i`
            ).classList.add(
              "attendance-comment__icon--set"
            );
          } else {
            document.querySelector(
              `button[data-attendance-id='${id}'] i`
            ).classList.remove(
              "attendance-comment__icon--set"
            );
          }

          hideModals();
        }

      }
    );
  }

  module.exports.initAttendances = initAttendances;