
  const days = [ "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" ];

  function isoDate ( date ) {
    return date.toISOString( ).slice( 0, 10 );
  }

  function getToday ( ) {
    return isoDate( new Date( ) );
  }

  function getMonday ( currentDate ) {
    const now = currentDate ? new Date( currentDate ) : new Date();
    const day = now.getDay( );
    const diff = now.getDate( ) - day + ( day == 0 ? -6 : 1 );

    const monday = new Date( now.setDate( diff ) );
    return isoDate( monday );
  }

  function toHours ( timeString ) {
    return timeString.split( /[:.]/ ).map(
      ( value, index ) => value * Math.pow( 60, -index )
    ).reduce(
      ( a, b ) => a + b
    );
  }

  function renderName ( user ) {
    return [
      user.name,
      user.family_name,
      user.nick_name && `(${user.nick_name})`
    ].filter(
      ( item ) => !!item
    ).join( " " );
  }

  function renderDay ( date ) {
    return days[ date.getDay() ] || "";
  }

  function renderHour ( hour ) {
    return `${hour}`.slice(0, 5);
  }

  function updatePointer ( ) {
    const now = new Date();
    const hours = now.getHours() + now.getMinutes() / 60;
    const top = ( hours - 8 ) * 50;

    const pointer = document.querySelector( ".calendar__classes-pointer" );

    if ( pointer ) {
      pointer.style.top = `${top}px`;
    }
  }

  function renderSlots(startDate, slots, calendar, displayEvery, isDayView) {
    const anchorDay = isDayView ? new Date( startDate ) : new Date( getMonday(startDate) );
    const slot_css_class = isDayView ? "calendar__day_full" : "calendar__day";
    const dayArray = isDayView ? new Array( 1 ) : new Array( 7 );

    return dayArray.fill( new Date(anchorDay) ).map(
      ( monday, index ) => {
        const day = new Date( monday );
        day.setDate( day.getDate() + index );
        return day;
      }
    ).map(
      ( date ) => {
        let stack = slots.filter(
          // filter the slots so they will contain the slots of the current day
          ( cl ) => cl.date === isoDate( date )
        ).sort().map(
          // add number hours, and index for them
          ( cl, index ) =>
            Object.assign( {}, cl, {
              a: toHours( cl.start ),
              b: toHours( cl.finish ),
              index
            })
        ).map(
          // add edges to slots that contains the overlapping slots (bot not the actual slot)
          ( cl1, _, slots ) => Object.assign( {}, cl1, {
            edges:
              slots.filter(
                ( cl2 ) =>
                  cl1 !== cl2 && (
                    ( cl1.a <  cl2.a && cl2.a <  cl1.b ) ||
                    ( cl1.a <  cl2.b && cl2.b <  cl1.b ) ||
                    ( cl2.a <  cl1.a && cl1.a <  cl2.b ) ||
                    ( cl2.a <  cl1.b && cl1.b <  cl2.b ) ||
                    ( cl1.a == cl2.a )                   ||
                    ( cl1.b == cl2.b )
                  )
              ).map(
                ( cl ) => cl.index
              )
          })
        )

        /*
            calculate connected components of the graph
        */

        let slotsWithComponents = [];

        let componentCounter = 0;

        while ( stack.length ) {
          // pop the top of the stack
          let [ cl ] = stack.slice( -1 );

          // separate the rest into connected & not connected arrays
          let { connected, notConnected } = stack.slice( 0, -1 ).reduce(
            ( acc, item ) => ({
              connected:
                item.edges.includes( cl.index ) ? acc.connected.concat( [ item ] ) : acc.connected,
              notConnected:
                item.edges.includes( cl.index ) ? acc.notConnected : acc.notConnected.concat( [ item ] )
            }), { connected: [], notConnected: [] }
          )

          // set component if it does not present
          if ( !( "component" in cl ) ) {
            cl = Object.assign( {}, cl, { component: componentCounter++ } );
          }

          // set the component of the connected vertexes to the same
          connected = connected.map(
            ( connectedCl ) => Object.assign( {}, connectedCl, { component: cl.component } )
          );

          // we move the connected vertexes to the top of the stack
          stack = notConnected.concat( connected );

          // add the current to the output array
          slotsWithComponents = slotsWithComponents.concat( [ cl ] );
        }

        /*
            color components of the graph
        */

        let everyColoredSlots = slotsWithComponents.reduce(
          // separate them by component
          ( components, cl ) =>
            Object.assign(
              [],
              components,
              { [cl.component]: (components[ cl.component ] || []).concat( [ cl ] ) }
            )
          , []
        ).map(
          // color the components
          ( slots, _ ) => {
            let maxColor = 0;

            stack = slots.slice().sort(
              ( cl1, cl2 ) => cl1.edges.length > cl2.edges.length
            );

            let coloredSlots = [];

            while ( stack.length ) {
              let [ cl ] = stack.slice( -1 );
              stack = stack.slice( 0, -1 );

              const connectedColors = coloredSlots.filter(
                ( connectedCl ) => connectedCl.edges.includes( cl.index )
              ).map(
                ( connectedCl ) => connectedCl.color
              );

              let color = 0;

              while ( connectedColors.includes( color ) ) {
                color++;
              }

              cl = Object.assign( {}, cl, { color } );

              coloredSlots = coloredSlots.concat( [ cl ] );

              maxColor = Math.max( maxColor, color );
            }

            coloredSlots = coloredSlots.map(
              ( cl ) => Object.assign( {}, cl, { maxColor } )
            );

            return coloredSlots;
          }
        ).reduce(
          // merge the components into one array
          ( acc, component ) => acc.concat( component ), []
        )

        return { slots: everyColoredSlots, date };
      }
    ).map(
      // calculate dimensions from the hours and colors
      ( day ) => Object.assign( {}, day, {
        slots:
          day.slots.map(
            ( cl ) => {
              const top = ( cl.a - 8 ) * 50;
              const height = ( cl.b - 8 ) * 50 - top;
              const left = cl.color / (cl.maxColor+1) * 100;
              const width = 100 / (cl.maxColor+1);

              return Object.assign( {}, cl, { top, height, left, width } );
            }
          )
      })
    ).map(
      ( day ) => `
        <div class="${slot_css_class}">
          <div class="calendar__day-header">
            ${ renderDay( day.date ) }, ${ isoDate( day.date ) }
          </div>
          <div class="calendar__classes">
            ${
              new Array( 13 ).fill( 1 ).map(
                ( time ) => `
                  <div
                    class="
                      calendar__classes-hour
                      ${ [0,6].includes( day.date.getDay() ) ? "calendar__classes-hour--weekend" : "" }
                    "
                  ></div>
                `
              ).join( "" )
            }
            ${
              day.slots.map(
                ( cl, i ) => `
                  <div
                    class="calendar__class ${cl.color_css_class}"
                    style="
                      top: ${ cl.top }px;
                      height: ${ cl.height }px;
                      left: ${ cl.left }%;
                      width: ${ cl.width }%;
                    "
                    id="${ isoDate( day.date ) }__${ cl.index }"
                  >
                    <div class="calendar__class-course">
                      ${ cl.primary_name }
                    </div>
                    <div class="calendar__class-teachers">
                      ${ cl.primary_users.map( ( teacher ) => renderName( teacher ) ).join( ", " ) }
                    </div>
                    <div class="calendar__class-time">
                      ${ cl.place ? cl.place + "," : "" }
                      ${ renderHour( cl.start ) }-${ renderHour( cl.finish ) }
                    </div>
                  </div>
                  <div
                    class="mdl-tooltip
                    ${isDayView ? "mdl-tooltip--center" : (cl.color < cl.maxColor / 2) ? "mdl-tooltip--left" : "mdl-tooltip--right"}"
                    for="${ isoDate( day.date ) }__${ cl.index }"
                  >
                    ${ cl.primary_name }<br />
                    ${ cl.primary_users.map( ( teacher ) => renderName( teacher ) ).join( ", " ) }<br />
                    ${ cl.place ? cl.place + "," : "" }
                    ${ renderHour( cl.start ) }-${ renderHour( cl.finish ) }
                  </div>
                `
              ).join( "" )
            }
            ${ isoDate(day.date) === getToday() ? "<div class=\"calendar__classes-pointer\"></div>" : "" }
          </div>
        </div>
      `
    ).join( "" );
  }


  function createCalendarSlots(classes, events){
    var classSlots = classes.map(function(item) {
        var slot = new Object();
        slot.primary_name = item.course_name;
        slot.secondary_name = item.term_name;
        slot.description = "";
        slot.date = item.date;
        slot.start = item.starting_at;
        slot.finish = item.finishes_at;
        slot.place = item.classroom;
        slot.primary_users = item.teachers;
        slot.seconday_users = [];
        slot.color_css_class = "calendar__slot__class_color";
        return slot;
      });

    var eventSlots = events.map(function(item) {
        var slot = new Object();
        slot.primary_name = item.name;
        slot.secondary_name = "";
        slot.description = item.description;
        slot.date = item.date;
        slot.start = item.starting_time;
        slot.finish = item.finishing_time;
        slot.place = item.location;
        slot.primary_users = [];
        slot.seconday_users = item.users;
        slot.color_css_class = "calendar__slot__event_color";
        return slot;
      });

    return classSlots.concat(eventSlots);
  }

  function renderCalendar ( startDate, renderedSlots, calendar, displayEvery, isDayView ) {
    const monday = new Date( getMonday(startDate) );

    let previousMonday = new Date( monday );
    previousMonday.setDate( monday.getDate() - 7 );

    let nextMonday = new Date( monday );
    nextMonday.setDate( monday.getDate() + 7 );

    let previousDay = new Date( startDate );
    previousDay.setDate( previousDay.getDate() - 1 );

    let nextDay = new Date( startDate );
    nextDay.setDate( nextDay.getDate() + 1);

    calendar.innerHTML = `
      <div class="calendar__switch">
        <label class="mdl-switch mdl-js-switch mdl-js-ripple-effect" for="day_view-switch">
          <span class="mdl-switch__label">Day view</span>
          <input
            type="checkbox"
            id="day_view-switch"
            class="mdl-switch__input"
            ${isDayView ? "checked" : ""}
          >
        </label>
      </div>

      <div class="row">
        ${
          isDayView ?
            `
              <div class="col-xs-4 col-md-3 col-lg-2">
                <a
                  class="mdl-button mdl-js-button"
                  href="/schedule?date=${ isoDate(previousDay) }&dayView=true"
                >
                  Previous day
                </a>
              </div>
              <div class="col-xs-4 col-md-3 col-lg-2">
                <a
                  class="mdl-button mdl-js-button"
                  href="/schedule?date=${ isoDate(new Date()) }&dayView=true"
                >
                  Today
                </a>
              </div>

              <div class="col-xs-4 col-md-3 col-md-offset-3 col-lg-2 col-lg-offset-6">
                <a
                  class="mdl-button mdl-js-button"
                  href="/schedule?date=${ isoDate(nextDay) }&dayView=true"
                >
                  Next day
                </a>
              </div>`
          : `<div class="col-xs-4 col-md-3 col-lg-2">
              <a
                class="mdl-button mdl-js-button"
                href="/schedule?date=${ isoDate(previousMonday) }"
              >
                previous week
              </a>
            </div>
            <div class="col-xs-4 col-md-3 col-lg-2">
              <a
                class="mdl-button mdl-js-button"
                href="/schedule?date=${ getMonday( ) }"
              >
                current week
              </a>
            </div>

            <div class="col-xs-4 col-md-3 col-md-offset-3 col-lg-2 col-lg-offset-6">
              <a
                class="mdl-button mdl-js-button"
                href="/schedule?date=${ isoDate(nextMonday) }"
              >
                next week
              </a>
            </div>`
        }
      </div>

      <div class="calendar">
        <div class="calendar__time">
          <div class="calendar__time-header"></div>
          ${
            new Array(13).fill(8).map(
              ( startTime, index ) => startTime + index
            ).map(
              ( time ) => `<div class="calendar__time-hour">${ renderHour( time ) }</div>`
            ).join( "" )
          }
        </div>
        <div class="calendar__days">
          ${ renderedSlots }
        </div>
      </div>
      ${
        ( USER_ROLE === "Teacher" || USER_ROLE === "Student" ) ?
          `<div class="calendar__switch">
            <label class="mdl-switch mdl-js-switch mdl-js-ripple-effect" for="calendar-switch">
              <span class="mdl-switch__label calendar__switch-label">Display every slot</span>
              <input
                type="checkbox"
                id="calendar-switch"
                class="mdl-switch__input"
                ${ displayEvery ? "checked" : "" }
              >
            </label>
          </div>`
        : ""
      }
    `;

    componentHandler.upgradeDom();

    updatePointer();
    setInterval( updatePointer, 10000 );
  }

  var calendarPointerInterval = null;

  function xhrGet ( path ) {
    return new Promise(
      function ( resolve, reject ) {
        const req = new XMLHttpRequest( );

        req.addEventListener( "load",
          function ( ) {
            var parsedData = JSON.parse( this.responseText );
            resolve(parsedData);
          }
        );

        req.addEventListener( "error", reject );

        req.open( "GET", path );
        req.setRequestHeader("authorization", `Bearer ${JWT}`)
        req.send( );
      }
    )
  }

  function loadCalendar ( displayEvery = false) {
    const calendar = document.querySelector( ".calendar__wrapper" );

    const queryStringEntries = window.location.search.slice( 1 ).split( "&" ).map(
      ( pairString ) => pairString.split( "=" ).map( decodeURIComponent )
    )

    const startDateParameter = queryStringEntries.filter(
      ( pair ) => pair[0] === "date"
    );

    let startDate = startDateParameter.length === 0 ? isoDate(new Date()) : startDateParameter[0][1];

    const dayViewParameter = queryStringEntries.filter(
      ( pair ) => pair[0] === "dayView"
    )

    let isDayView = dayViewParameter.length;

    let queryDate = isDayView ? startDate : getMonday( startDate );

    Promise.all([
      xhrGet(`/api/calendar?date=${ queryDate }&my_classes=${ !displayEvery }`),
      xhrGet(`/api/events?date=${ queryDate }&my_events=${ !displayEvery }`)
    ]).then(
      function ( responses ) {

        let slots = createCalendarSlots(responses[0].classes, responses[1].events)
        let renderedSlots = renderSlots(queryDate, slots, calendar, displayEvery, isDayView);
        renderCalendar( queryDate, renderedSlots, calendar, displayEvery, isDayView);

        clearInterval( calendarPointerInterval );
        updatePointer();
        calendarPointerInterval = setInterval( updatePointer, 10000 );
      }
    ).catch(
      function ( err ) {
        console.log(err);
      }
    )
  }

  function initCalendar ( ) {
    const calendar = document.querySelector( ".calendar__wrapper" );

    if ( calendar ) {
      loadCalendar();

      document.addEventListener( "change",
        function ( e ) {
          if ( e.target.id === "calendar-switch" ) {
            loadCalendar(e.target.checked);
          } else if ( e.target.id === "day_view-switch" ) {
            const otherEntries = window.location.search.slice(1).split("&").filter(
              ( pair ) => pair.split("=")[0] != "dayView"
            )

            if ( e.target.checked ) {
              window.location.search = "?" + otherEntries.concat("dayView=true").join("&");
            } else {
              window.location.search = "?" + otherEntries.join("&");
            }

          }
        }
      )
    }
  }

  module.exports.initCalendar = initCalendar;
