# Used to run Flack in a container
FROM ruby:2.3.8-jessie

EXPOSE 7007:7007

RUN apt-get update && apt-get install git
RUN git clone https://github.com/floraison/flack
RUN rm -rf /flack/envs/dev/lib/taskers
RUN git clone https://github.com/mantor/taskers /flack/envs/dev/lib/taskers
RUN sed -i 's/bundle exec rackup -p $(PORT)/bundle exec rackup -p $(PORT) --host 0.0.0.0/g' flack/Makefile
RUN cd flack && bundle install && make migrate
