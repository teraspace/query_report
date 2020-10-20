Forked by [Carlos Patiño] and published on Bitbucket for Virgina software startup.

New features over original Ashrafuzzman:

1. This fork make query_reports compatible with Ruby-on-rails 5
2. Excel exporting button
3. Subtotals rows
4. Setup format data on totals (for example: "n days", "gals" and others.
5. Show and hide titles, good for embebed the view on iframes.


###Write the action with a simple DSL and get a report with PDF and CSV export, gorgeous charts, out of box filters, with I18n support, etc...  

Create a report in Rails
------------------------

You would have to do the following tasks to create a report in rails,

- Create a route
- Create an action with following logic
    - Logic for filters
    - Logic for pagination
- Create a view
    - Write code to show HTML
    - Write code to generate Graph
- Generate PDF with prawn pdf and graph
- Logic to send that PDF file as email

Create a report with query report
---------------------------------

- Create a route
- Create an action with following logic
    - ~~Logic for filters~~
    - ~~Logic for pagination~~
- ~~Create a view~~
    - ~~Write code to show HTML~~
    - ~~Write code to generate Graph~~
- ~~Generate PDF with prawn pdf and graph~~
- ~~Logic to send that PDF file as email~~

For email, you have to implement the popup once.

Features
--------

- Allow to use and reuse filters using [ransack](https://github.com/activerecord-hackery/ransack), and also with custom query
- Paginates [kaminari](https://github.com/amatsuda/kaminari)
- Supports ajax out of box 
- Exports to PDF [prawn](https://github.com/prawnpdf/prawn), csv, json
- Supports to send report pdf as email
- Supports I18N

For a demo see [here](http://query-report-demo.herokuapp.com)

## The purpose
The purpose of this gem is to produce consistent reports quickly and manage them easily. Because all we need to
concentrate in a report is the query and filter.

## Getting started
Query report is tested with Rails 3. You can add it to your Gemfile with:

```ruby
gem "query_report"
```

Run the bundle command to install it.

Here is a sample controller which uses query report. And that is all you need, query report will generate all the view for you.

```ruby
require 'query_report/helper'  #need to require the helper

class InvoicesController < ApplicationController
  include QueryReport::Helper  #need to include it

  def index
    @invoices = Invoice.scoped

    reporter(@invoices) do
      filter :title, type: :text
      filter :created_at, type: :date, default: [5.months.ago, 1.months.from_now]
      filter :paid, type: :boolean, default: false

      column :title do |invoice|
        link_to invoice.title, invoice
      end
      column :total_paid, show_total: true
      column :total_charged, show_total: true
      column :paid
    end
  end
end
```

## License
MIT License. Copyright � 2014 [Ashrafuzzaman](http://ashrafuzzaman.github.io). See MIT-LICENSE for further details.

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/ashrafuzzaman/query_report/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

