window.addEventListener('message', function(e) {
	if (e.data=="top") scroll(0,0);
});

$(function() {
  var lang_re = /https?\:\/\/.*\/(..)\/.*/i;
  var lang = lang_re.exec(window.location);
  if (lang) lang = lang[1]; 
  window.lang = (["es","ca"].indexOf(lang)==-1) ? "es" : lang;
})
