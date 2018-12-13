# Floristry
The goal of this gem is to help you represent [Flor's workflows](https://github.com/floraison/flor) using standard Rails facilities, e.g. partials, helpers, render, models, etc.

Floristry is an [isolated engine](http://guides.rubyonrails.org/engines.html) which provides basic behaviors and representations to Flor's workflow language, e.g. sequence, concurrence, task, if, sleep, cron. Obviously, you can override their default behaviors (e.g. model) and representations (e.g. partial) your owns.

To override a view, simply create a new one in:

    /app/views/floristry/_cron.html.erb.

## Features
TODO

### Hierarchy
- Procedure
    - Leaf Procedure
        - Tasker
        - If
        - Wait
        - ...
    - Branch Procedure
        - Sequence
        - Concurrence
        - ...
        
### Era - :pass, :present, :future
The following methods are available on each Procedures to identify its era:

```
active?
inactive?

is_past?
is_present?
is_future?
```

### Extend
New behaviors ca be added to low-level Procedure such as Procedure (root), BranchProcedure or LeafProcedure to affect all Procedures at once, only Leaves or only Branches respectively.

Create a file called /config/initializers/floristry.rb containing modules with the desired behaviors. Then use the following config to define which module will be included in the which low-level Procedure.

```ruby
module FloristryBranchBehavior
  def xyz
    # ...
  end

  # ...
end

Floristry.configure do |config|
  config.add_branch_Procedure_behavior = FloristryBranchBehavior
  #config.add_leaf_Procedure_behavior = FloristryLeafBehavior
  #config.add_Procedure_behavior = FloristryBehavior
end
```

## Requirements
TODO

## Installation
1. Add this line to your application's Gemfile:

    `gem 'floristry'`

2. And then execute:

    `$ bundle install`

3. Then register the service in flor engine by running:

    `rails g floristry:install --flack-and-flor`
    
    This will our default Taskers and install [Flack](https://github.com/floraison/flack) and [Flor](https://github.com/floraison/flor) one directory level below your app ( ../). Remove the `--flack-and-flor` switch if you already have them installed.

4. TODO

## Usage
TODO

## Contributing
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Do your stuff
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

## License
GPLv2

## Source
https://github.com/mantor/floristry

## Authors
- Danny Fullerton - Mantor Organization
- Jean-Francois Rioux - Mantor Organization
