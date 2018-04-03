clean:
	mv ./hello/vendor /tmp
	rm -rf hello && mkdir hello
	mv /tmp/vendor ./hello/

new:
	mkdir -p hello && cd hello && \
	bundle init && \
	sed -ie 's/# gem "rails"/gem "rails"/' Gemfile && \
	bundle install && \
	bundle exec rails new . -d postgresql -T -m ../template.rb	
