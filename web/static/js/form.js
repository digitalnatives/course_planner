
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

    Array.from(
      document.querySelectorAll( ".is-invalid select" )
    ).forEach(
      ( select ) =>
        select.addEventListener(
          "focus",
          ( e ) => {
            let name = e.target.getAttribute( "name" );

            let match = name.match( /\[(?:year|month|day|hour|minute)\]$/ );

            if ( match ) {
              let nameBeginning = name.slice( 0, match.index );

              Array.from(
                document.querySelectorAll( `select[name^="${ nameBeginning }"]` )
              ).forEach(
                ( select ) => select.parentNode.classList.remove( "is-invalid" )
              )
            } else {
              e.target.parentNode.classList.remove( "is-invalid" );
            }
          },
          { once: true }
        )
    );

    document.addEventListener( "click",
      ( e ) => {
        if ( e.target.classList.contains( "attendance-form__button" ) ) {
          const radios = Array.from(
            e.target.parentNode.querySelectorAll( "input[type='radio']" )
          );

          const checkedIndex = radios.findIndex(
            ( radio ) => radio.checked
          );

          radios[ (checkedIndex + 1 ) % radios.length ].checked = true;
        }
      }
    );
  }

  module.exports = { initForm };