
  const { showModal, hideModals } = require( "./modal.js" );

  function updateHolidayRow ( id ) {
    let dateString = [
      document.querySelector( `#${ id }_date_year option:checked` ).textContent,
      document.querySelector( `#${ id }_date_month option:checked` ).textContent,
      document.querySelector( `#${ id }_date_day option:checked` ).textContent
    ].join( " " );

    document.querySelector(
      `td[data-property="date"][data-holiday-id="${ id }"]`
    ).textContent = dateString;

    let description = document.querySelector(
      `#${ id }_description`
    ).value;

    document.querySelector(
      `td[data-property="description"][data-holiday-id="${ id }"]`
    ).textContent = description;
  }

  function removeHoliday ( id ) {
    let row = document.querySelector( `tr[data-holiday-id="${ id }"]` );
    row.parentNode.removeChild( row );
  };

  function initTerms ( ) {
    Array.from(
      document.querySelectorAll( ".update-holiday[data-holiday-id]" )
    ).forEach(
      ( button ) => updateHolidayRow( button.getAttribute( "data-holiday-id" ) )
    );

    document.addEventListener( "click",
      ( e ) => {
        if ( e.target.classList.contains( "add-form-field" ) ) {
          let dataset = e.target.dataset;
          let container = document.getElementById( dataset.container );
          let index = dataset.index;
          let newRow = dataset.template
            .replace( /\[0\]/g, `[${ index }]` )
            .replace( /_0_/g, `_${ index }_` )
            .replace( /_0/g, `_${ index }` );

          container.insertAdjacentHTML( "beforeend", newRow );
          dataset.index = parseInt( dataset.index ) + 1;

          componentHandler.upgradeDom();

          console.log( `.modal[data-holiday-id="term_holidays_${ index }"]` );
          showModal( `.modal[data-holiday-id="term_holidays_${ index }"]` );
        }

        if ( e.target.classList.contains( "show-holiday-modal" ) ) {
          let id = e.target.getAttribute( "data-holiday-id" );
          showModal( `.modal[data-holiday-id="${ id }"]` );
        }

        if ( e.target.classList.contains( "update-holiday" ) ) {
          hideModals();
          updateHolidayRow( e.target.getAttribute( "data-holiday-id" ) );
        }

        if ( e.target.classList.contains( "remove-holiday" ) ) {
          removeHoliday( e.target.getAttribute( "data-holiday-id" ) );
        }
      }
    );
  }

  module.exports.initTerms = initTerms;

