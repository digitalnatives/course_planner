
  function initForm ( ) {
    Array.from(
      document.querySelectorAll( ".form-init input" )
    ).forEach(
      ( input ) =>
        input.addEventListener(
          "blur",
          ( e ) => e.target.parentNode.classList.remove( "form-init" ),
          { once: true }
        )
    );
  }

  module.exports = { initForm };