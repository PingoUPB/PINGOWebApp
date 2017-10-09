/*jslint eqeq: true, es5: true, evil: true, sloppy: true, vars: true, white: true, browser: true, devel: true */
var countdown_end, state = 0;
var connected, show_view, event_page, sound_enabled =  false;
var view_url = "";
var jug, timeout = null;

function disableUI() {
    if(show_view) {
        if(event_page) {
            setTimeout(function() { jQuery.getScript(view_url); }, 1000);
        } else {
            setTimeout(function() { window.location.reload(); }, 1000);
        }
    } else {
        $("#overmsg").show();
        $("#countdown-container").hide();
        $("#vote-button").hide();
        $("#survey-content").hide();
    }
}
function enableUI() {
    location.reload(); // TODO
}

function pageShown(evt){
    if (evt.persisted) { // fires when view is loaded from cache (e. g. after minimizing or sleeping)
        $.ajax({
          url: window.location,
          dataType: "json",
          success: function(data) {
            if(data != state){
                enableUI();
            }
          },
          error: enableUI
        });
    }
}

function now(){
    return new Date().getTime();
}

/**
 * Update and format countdown and color in red during last 10 seconds
 * Calls itself every 200 ms.
 * by F. Stallmann
 */
function updateCountdown() {
  var countdown = Math.floor((countdown_end - now())/1000);

  if(countdown > 0) {
    if(countdown <= 10) {
      $( "#countdown" ).css('color', 'red');
      $( "#countdown" ).animate({fontSize: "2.5em"}, 200);
    }
    if(show_view && sound_enabled && countdown == 10){
      document.getElementById("sound").play();
    }
    var seconds = countdown % 60;
    $( "#countdown" ).text( Math.floor(countdown / 60) + ':' + (seconds < 10 ? '0' + seconds : seconds) );
  }
  else {
    $( "#countdown" ).text( "0:00" );
    disableUI();
    if(window.parent.postMessage !== undefined){
        window.parent.postMessage("stopped", "*");
      }
    return true;
  }
  timeout = setTimeout(function() { updateCountdown(); }, 200);
}

/*
 * Set new countdown. by F. Stallmann
 */
function setCountdown(countdown) {
  countdown_end = countdown + now();
}

function startCountdown(time){
    $("#countdown-container").show();
    setCountdown(time);
    updateCountdown();
}
function stopCountdown(){
    $('#countdown').stopCountDown();
    $("#countdown-container").hide();
    clearTimeout(timeout);
}


function setVoterCount(count, list){
    $('#voter-count').text(count);
    if(list){
        $('#votes-'+list).text(count);
    }
}
