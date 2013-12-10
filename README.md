# WARNING
NOT READY FOR PRODUCTION

# RuoteTrail

The goal of this gem is to help you represent [Ruote's workflows](http://ruote.rubyforge.org/) using standard Rails
facilities, e.g. partials, helpers, render, models, etc.

Ruote::Trail is an [isolated engine](http://guides.rubyonrails.org/engines.html) which provides basic
behaviors and representation of Ruote's Flow Expression, e.g. define, sequence, concurrence, if, wait, participant, inc,
set. You can easily override their default behaviors and representations by defining your own in your application.

Adding new behaviors to the `participant expression` can be done by creating a new model in:

    /app/models/ruote_trail/participant.rb

To override a view, simply create a new one in:

    /app/views/ruote_trail/_participant.html.erb.

## Hierarchy

- Expression
    - Leaf Expression
        - Participant
        - If
        - Wait
        - ...
    - Branch Expression
        - Define
        - Sequence
        - Concurrence
        - ...

## Installation

TODO

Add this line to your application's Gemfile:

    gem 'ruote-trail-on-rails'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruote-trail-on-rails
    
Then register the service in the ruote engine:

```ruby
RuoteKit.engine.add_service('trail',
                            'ruote/trail/observer',
                            'RuoteTrail::Observer',
                            'archive' => 'Ruote::Trail::Archive::ActiveRecord')
```

## Usage

New behaviors ca be added to low-level Expression such as Expression (root), BranchExpression or LeafExpression
to affect all Expressions at once, only Leaves or only Branches.

Create a file called /config/initializers/ruote-trail-on-rails.rb containing modules with the desired behaviors. Then
use the following config to define which module will be included in the which low-level Expression.

```ruby
module RuoteTrailBranchBehavior
  def xyz
    # ...
  end

  # ...
end

RuoteTrail.configure do |config|
  config.add_branch_expression_behavior = RuoteTrailBranchBehavior
  #config.add_leaf_expression_behavior = RuoteTrailLeafBehavior
  #config.add_expression_behavior = RuoteTrailBehavior
end
```

### :pass, :present, :future

The following methods are available on each Expressions to identify its era:

```
active?
disabled?
in_past?
in_present?
in_future?
```

## TODO

1. Extract RuoteTrail::Observer in a separate gem.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

GPLv2

## Source

https://github.com/northox/ruote-trail-on-rails

## Author

Danny Fullerton - Mantor Organization
