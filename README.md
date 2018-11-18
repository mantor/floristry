# Floristry

The goal of this gem is to help you represent [Ruote's workflows](http://ruote.rubyforge.org/) using standard Rails
facilities, e.g. partials, helpers, render, models, etc.

Ruote::Trail is an [isolated engine](http://guides.rubyonrails.org/engines.html) which provides basic
behaviors and representation of Ruote's Flow Expression, e.g. define, sequence, concurrence, if, wait, participant, inc,
set. Obviously, you can override their default behaviors and representations by defining your owns.

To override a view, simply create a new one in:

    /app/views/floristry/_participant.html.erb.

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

    gem 'active-trail'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active-trail
    
Then register the service in the ruote engine:

```ruby
RuoteKit.engine.add_service('trail',
                            'floristry/observer',
                            'Floristry::Observer',
                            'archive' => 'Floristry::Archive::ActiveRecord')
```

## Usage

TODO

### Era - :pass, :present, :future

The following methods are available on each Expressions to identify its era:

```
active?
inactive?

is_past?
is_present?
is_future?
```

## Extend
New behaviors ca be added to low-level Expression such as Expression (root), BranchExpression or LeafExpression
to affect all Expressions at once, only Leaves or only Branches.

Create a file called /config/initializers/active-trail.rb containing modules with the desired behaviors. Then
use the following config to define which module will be included in the which low-level Expression.

```ruby
module FloristryBranchBehavior
  def xyz
    # ...
  end

  # ...
end

Floristry.configure do |config|
  config.add_branch_expression_behavior = FloristryBranchBehavior
  #config.add_leaf_expression_behavior = FloristryLeafBehavior
  #config.add_expression_behavior = FloristryBehavior
end
```

## TODO

1.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

GPLv2

## Source

https://github.com/northox/active-trail

## Author

Mantor Organization