/**
 * @author Dev
 */
$(document).ready( function() {
  if ($('#date').val() == "") {
    $('#date').val(new Date().toString());
  }
  
  $('#title').on('input', function() {
    $('#url').val(titleToUrlPart($('#title').val()));
  } );
  
  $('#text').on('input', function() {
    //send an ajax request to our action
    $.ajax({
      type: "POST",
      url: "/preview",
      //serialize the form and use it as data for our ajax request
      data: { text: $('#text').val() },
      //the type of data we are expecting back from server, could be json too
      dataType: "html",
      success: function(data) {
        //if our ajax request is successful, replace the content of our preview div with the response data
        $('#preview').html(data);
      }
    });
  });
  
  $('#browserid').click(function() {
    navigator.id.get(gotAssertion);
  });
});

// Takes the title and sanitizes it into a string
// that can be used in a url link
// titleToUrlPart('Testing #123') = testing-123
function titleToUrlPart(title) {
  var url = title.toLowerCase();
  url = url.replace("'", "");
  var regex = /[a-z|0-9]+/gi;
  var matches = url.match(regex);
  url = "";
  if (matches != null) {
    for (i=0; i<matches.length; i++) {
       url = url + matches[i] + "-";
    }
    url = url.replace("--", "-");
    url = url.replace(/-$/, "");
  }
  return url;
}

function gotAssertion(assertion) {
  // got an assertion, now send it up to the server for verification  
  if (assertion !== null) {
    $.ajax({  
      type: 'POST',  
      url: '/auth/login',  
      data: { assertion: assertion },  
      success: function(res, status, xhr) {  
        window.location.reload();
      },  
      error: function(xhr, status, res) {
        alert("login failure" + res);
      }
    });
  }
};
