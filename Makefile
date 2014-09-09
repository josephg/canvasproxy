
proxy.min.js: proxy.coffee
	coffee -cp $< | uglifyjs -cm > $@

watch:
	coffee -bcw proxy.coffee
