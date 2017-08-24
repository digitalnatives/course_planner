
  function showModal ( selector ) {
    let modal = document.querySelector( selector );
    modal.classList.add( "modal--visible" );
  }

  function hideModals ( ) {
    Array.from( document.querySelectorAll( ".modal" ) ).forEach(
      ( modal ) => modal.classList.remove( "modal--visible" )
    );
  }

  module.exports = { showModal, hideModals };
