
  function initTerms ( ) {
    function removeElement ( { target } ) {
      let li = document.getElementById( target.dataset.id );
      let hidden_id = document.getElementById( `${ target.dataset.id }_id` );

      if ( hidden_id ) {
        li.parentNode.removeChild( hidden_id );
      }

      li.parentNode.removeChild( li );
    };

    Array.from(
      document.querySelectorAll( ".remove-form-field" )
    ).forEach(
      ( el ) => {
        el.addEventListener( "click", ( e ) => removeElement( e ) );
      }
    );

    Array.from(
      document.querySelectorAll( ".add-form-field" )
    ).forEach(
      ( el ) => {
        el.addEventListener( "click",
          ( { target: { dataset } } ) => {
            let container = document.getElementById( dataset.container );
            let index = dataset.index;
            let newRow = dataset.template
              .replace( /\[0\]/g, `[${ index }]` )
              .replace( /_0_/g, `_${ index }_` )
              .replace( /_0/g, `_${ index }` );

            container.insertAdjacentHTML( "beforeend", newRow );
            dataset.index = parseInt( dataset.index ) + 1;

            Array.from(
              container.querySelectorAll( "a.remove-form-field" )
            ).forEach(
              ( el ) => {
                el.addEventListener( "click", ( e ) => removeElement( e ) );
              }
            );
          }
        );
      }
    );
  }

  module.exports.initTerms = initTerms;