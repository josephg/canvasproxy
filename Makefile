
canvasproxy.min.js: canvasproxy.coffee
	coffee -cp $< | uglifyjs -cm > $@

watch:
	coffee -cw canvasproxy.coffee
