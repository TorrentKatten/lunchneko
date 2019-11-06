FROM ruby:2.5.7

COPY . /lunchneko
WORKDIR /lunchneko

RUN bundle install

ENTRYPOINT ["bundle", "exec", "ruby", "lunch_neko.rb"]